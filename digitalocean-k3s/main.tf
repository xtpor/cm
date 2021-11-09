
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.15.0"
    }

    null = {
      source = "hashicorp/null"
      version = "3.1.0"
    }
  }
}

variable "digitalocean_api_token" {
  sensitive = true
}

variable "ssh_key_md5" {
}

provider "digitalocean" {
  token = var.digitalocean_api_token
}

resource "digitalocean_droplet" "k3s_test_0" {
  image  = "debian-10-x64"
  name   = "k3s-test-0"
  region = "sgp1"
  size   = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_key_md5]
  user_data = file("${path.module}/debian-10-x64-cloudinit.sh")

  provisioner "local-exec" {
    command = "sh ${path.module}/provisioner.sh root@${digitalocean_droplet.k3s_test_0.ipv4_address}"
  }
}

resource "digitalocean_droplet" "k3s_test_1" {
  image  = "debian-10-x64"
  name   = "k3s-test-1"
  region = "sgp1"
  size   = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_key_md5]
  user_data = file("${path.module}/debian-10-x64-cloudinit.sh")

  provisioner "local-exec" {
    command = "sh ${path.module}/provisioner.sh root@${digitalocean_droplet.k3s_test_1.ipv4_address}"
  }
}

resource "null_resource" "k3s_master_node" {
  provisioner "local-exec" {
    command = "k3sup install --host ${digitalocean_droplet.k3s_test_0.ipv4_address} --user root"
  }
}


resource "null_resource" "k3s_worker_node_0" {
  depends_on = [
    null_resource.k3s_master_node
  ]

  provisioner "local-exec" {
    command = "k3sup join --ip ${digitalocean_droplet.k3s_test_1.ipv4_address} --server-ip ${digitalocean_droplet.k3s_test_0.ipv4_address} --user root"
  }
}