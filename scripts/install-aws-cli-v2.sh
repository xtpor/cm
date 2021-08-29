#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# for Raspberry Pi
# install aws cli v2 on armhf raspberry pi
# please copy this file onto the pi


# clone the aws cli repo
cd /tmp
sudo rm -rf aws-cli || true
git clone https://github.com/aws/aws-cli

# installed the pip package
cd aws-cli
git checkout v2
sudo python3 -m pip install -r requirements.txt
sudo python3 -m pip install .
