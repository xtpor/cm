#!/usr/bin/env python3
# Usage: generate.py <network.json> <output-dir>
import subprocess
import os
import pathlib
import json
import sys
import itertools
import ipaddress


def generate_keypair():
    a = subprocess.run(["wg", "genkey"], capture_output=True)
    if a.returncode != 0:
        raise Exception("error while generating key pair")
    privatekey = a.stdout.decode("utf8").strip()

    b = subprocess.run(["wg", "pubkey"], input=privatekey.encode("utf8"), capture_output=True)
    if b.returncode != 0:
        raise Exception("error while generating key pair")
    publickey = b.stdout.decode("utf8").strip()

    return (publickey, privatekey)

def load_keys(spec, keypairs_file):
    hosts = get_hosts(spec)
    keypairs_file = os.path.join(output_directory, "keypairs.json")

    if not os.path.exists(keypairs_file):
        with open(keypairs_file, "w") as f:
            f.write(json.dumps({ "keypairs": dict() }, indent=2))
            print("created a new empty keypairs.json file")

    keypairs = dict()
    with open(keypairs_file, "r") as f:
        keypairs = json.loads(f.read())["keypairs"]

    for host in hosts:
        if host["name"] in keypairs:
            kp = keypairs[host["name"]]
            host["public_key"] = kp["public_key"]
            host["private_key"] = kp["private_key"]
        else:
            (pub, priv) = generate_keypair()
            keypairs[host["name"]] = { "private_key": priv, "public_key": pub }
            host["public_key"] = pub
            host["private_key"] = priv
            print("generated key pair for node '%s'" % host["name"])

    with open(keypairs_file, "w") as f:
        f.write(json.dumps({ "keypairs": keypairs }, indent=2))

def generate_config(spec, output_directory):
    top_prefix = spec["cidr"]
    top_prefixlen = ipaddress.IPv4Network(top_prefix).prefixlen

    def generate_config_file(host):
        lines = []
        lines.append("[Interface]")
        lines.append("PrivateKey = %s" % host["private_key"])
        lines.append("Address = %s/%s" % (host["ip"], top_prefixlen))
        lines.append("ListenPort = 51820")
        lines.append("")

        for route in host["normalized_routes"]:
            lines.append("[Peer]")
            lines.append("PublicKey = %s" % host_by_name(spec, route["peer"])["public_key"])
            lines.append("AllowedIPs = %s" % ", ".join(route["prefix"]))
            if route["address"] != None:
                lines.append("Endpoint = %s" % route["address"])
            lines.append("PersistentKeepalive = 30")
            lines.append("")

        return "".join([line + "\n" for line in lines])

    for host in get_hosts(spec):
        text = generate_config_file(host)
        filename = os.path.join(output_directory, "%s.conf" % host["name"])
        with open(filename, "w") as f:
            f.write(text)
            print("generated wireguard config for %s" % host["name"])

def generate_hosts(spec, output_directory):
    for host in get_hosts(spec):
        lines = []
        for other_host in get_hosts(spec):
            if other_host != host:
                lines.append("%s\t%s\t# managed by wireguard" % (other_host["ip"], other_host["name"]))

        text = "".join([line + "\n" for line in lines])
        filename = os.path.join(output_directory, "%s.hosts" % host["name"])
        with open(filename, "w") as f:
            f.write(text)
            print("generated hosts file for %s" % host["name"])

def get_hosts(entity):
    if entity["kind"] == "host":
        return [entity]
    elif entity["kind"] == "network":
        node_list = []
        for peer in entity["peers"]:
            for node in get_hosts(peer):
                node_list.append(node)
        return node_list
    else:
        raise Exception("unexpected entity kind %s" % (entity["kind"]))

def host_by_ip(spec, ip):
    return [host for host in get_hosts(spec) if host["ip"] == ip][0]

def host_by_name(spec, name):
    return [host for host in get_hosts(spec) if host["name"] == name][0]

def get_networks(entity):
    if entity["kind"] == "host":
        return []
    elif entity["kind"] == "network":
        node_list = [entity]
        for peer in entity["peers"]:
            for node in get_networks(peer):
                node_list.append(node)
        return node_list
    else:
        raise Exception("unexpected entity kind %s" % (entity["kind"]))

def add_direct_routes(entity):
    top_prefix = entity["cidr"]

    for network in get_networks(entity):
        for peer in network["peers"]:
            if peer["kind"] == "host":
                gateway = host_by_ip(entity, network["default_gateway"])
                if peer != gateway:
                    gateway["routes"].append({
                        "prefix": "%s/32" % peer["ip"],
                        "peer": peer["name"],
                        "address": None,
                    })
                    peer["default_route"] = {
                        "prefix": top_prefix,
                        "peer": gateway["name"],
                        "address": gateway["private_address"] if network["private"] else gateway["address"],
                    }
            elif peer["kind"] == "network":
                gateway = host_by_ip(entity, network["default_gateway"])
                sub_gateway = host_by_ip(entity, peer["default_gateway"])
                if gateway != sub_gateway:
                    gateway["routes"].append({
                        "prefix": peer["cidr"],
                        "peer": sub_gateway["name"],
                        "address": None,
                    })
                    sub_gateway["default_route"] = {
                        "prefix": top_prefix,
                        "peer": gateway["name"],
                        "address": gateway["address"],
                    }
            else:
                raise Exception("unexpected entity kind %s" % (entity["kind"]))

def add_mesh_routes(entity):
    def get_endpoint(peer):
        if peer["kind"] == "host":
            return peer
        elif peer["kind"] == "network":
            gateway = host_by_ip(entity, peer["default_gateway"])
            return { "name": gateway["name"], "ip": gateway["ip"], "private_address": peer["private_address"] }
        else:
            raise Exception("unexpected entity kind %s" % (entity["kind"]))

    top_prefix = entity["cidr"]

    for network in get_networks(entity):
        if network["mesh"]:
            gateway = host_by_ip(entity, network["default_gateway"])
            non_gateway_peers = [p for p in [get_endpoint(p) for p in network["peers"]] if p != gateway]

            for (peer1, peer2) in itertools.combinations(non_gateway_peers, 2):
                peer1["routes"].append({
                    "prefix": "%s/32" % peer2["ip"],
                    "peer": peer2["name"],
                    "address": peer2["private_address"],
                })
                peer2["routes"].append({
                    "prefix": "%s/32" % peer1["ip"],
                    "peer": peer1["name"],
                    "address": peer1["private_address"],
                })

def normalize_routes(spec):
    for host in get_hosts(spec):
        normalized_routes = []

        for route in host["routes"]:
            normalized_routes.append({
                "prefix": [route["prefix"]],
                "peer": route["peer"],
                "address": route["address"],
            })

        if host["default_route"] != None:
            initial_prefix = ipaddress.IPv4Network(host["default_route"]["prefix"])

            remaining_prefixes = [initial_prefix]
            new_remaining_prefixes = []
            for route in host["routes"]:
                route_prefix = ipaddress.IPv4Network(route["prefix"])
                for rp in remaining_prefixes:
                    if rp.overlaps(route_prefix):
                        new_remaining_prefixes.extend(rp.address_exclude(route_prefix))
                    else:
                        new_remaining_prefixes.append(rp)

                remaining_prefixes = new_remaining_prefixes
                new_remaining_prefixes = []

            normalized_routes.append({
                "prefix": [str(p) for p in  remaining_prefixes],
                "peer": host["default_route"]["peer"],
                "address": host["default_route"]["address"],
            })

        host["normalized_routes"] = normalized_routes

def prepare(entity):
    for host in get_hosts(entity):
        host["routes"] = []
        host["default_route"] = None

if __name__ == "__main__":
    spec_filename = sys.argv[1]
    output_directory = sys.argv[2]

    with open(spec_filename, "r") as f:
        spec = json.loads(f.read())

    prepare(spec)
    add_direct_routes(spec)
    add_mesh_routes(spec)
    normalize_routes(spec)

    subprocess.run(["mkdir", "-p", output_directory])
    load_keys(spec, output_directory)
    generate_config(spec, output_directory)
    generate_hosts(spec, output_directory)

    # print(json.dumps(get_hosts(spec), indent=2))
