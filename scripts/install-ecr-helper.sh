#!/bin/bash
# for Raspberry Pi
# install docker ecr credential helper
set -euo pipefail
IFS=$'\n\t'


# clone the aws cli repo
cd /tmp
sudo rm -rf amazon-ecr-credential-helper || true
git clone https://github.com/awslabs/amazon-ecr-credential-helper

# installed the pip package
cd amazon-ecr-credential-helper
git checkout v0.5.0
make docker
sudo cp bin/local/docker-credential-ecr-login /usr/local/bin/
