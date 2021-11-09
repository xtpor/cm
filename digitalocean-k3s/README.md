
# digitalocean-k3s

## prerequisite

- `terraform`
- `k3sup`

##

build a cluster on droplet on digitalocean with

- wireguard vpn
- docker
- k3s agent / master node


the goal is to allow it to scale up and down


```bash
ssh-keygen -l -E md5 -f ~/.ssh/id_rsa.pub
```


k3sup install --host ruby.tintinho.net --user root
k3sup join --ip $AGENT_IP --server-ip $SERVER_IP --user $root
