#!/bin/sh
set -eux

sudo apt update -y

sudo apt install -y \
  htop \
  git \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  zip \
  unzip \
  lsb-release

# install docker

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io

sudo systemctl start docker


# install wireguard

echo "deb http://deb.debian.org/debian buster-backports main" > /etc/apt/sources.list.d/buster-backports.list
apt-get update -y
apt-get install -y linux-headers-cloud-amd64
apt-get install -y wireguard wireguard-dkms