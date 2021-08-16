#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


SSH_HOST="pi@raspberrypi.local"
: ${NEW_HOSTNAME:="banana"}

add_key() {
  ssh-copy-id -oStrictHostKeyChecking=no -i "$1" "$SSH_HOST"
}

enable_password_less_sudo() {
  ssh -oStrictHostKeyChecking=no "$SSH_HOST" 'sudo bash -s' <<- EOF
    set -e

    if ! grep -qxF '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' /etc/sudoers; then
      echo '%sudo ALL=(ALL:ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo
    fi
EOF
}

add_admin_account() {
  admin_password=$(openssl rand -hex 16)

  ssh -oStrictHostKeyChecking=no "$SSH_HOST" 'sudo bash -s' <<- EOF
    set -e

    if ! id admin > /dev/null; then
      useradd -m admin
      usermod -aG sudo admin
      echo "admin:$admin_password" | chpasswd

      mkdir ~admin/.ssh
      cat ~pi/.ssh/authorized_keys > ~admin/.ssh/authorized_keys
      chmod 700 ~admin/.ssh
      chmod 600 ~admin/.ssh/authorized_keys
      chown -R admin:admin ~admin/.ssh
    fi
EOF
}

install_software() {
  ssh -oStrictHostKeyChecking=no "$SSH_HOST" 'sudo bash -s' <<- EOF
    set -e
    set -x

    apt-get install -y \
      git \
      bash \
      vim \
      htop \
      wget \
      curl

    # install my minimal vim config
    curl https://raw.githubusercontent.com/xtpor/dotfiles/master/.vimrc.min > ~root/.vimrc
    chown root:root ~root/.vimrc

    curl https://raw.githubusercontent.com/xtpor/dotfiles/master/.vimrc.min > ~admin/.vimrc
    chown admin:admin ~admin/.vimrc

    curl https://raw.githubusercontent.com/xtpor/dotfiles/master/.vimrc.min > ~pi/.vimrc
    chown pi:pi ~pi/.vimrc
EOF
}

install_wireguard() {
  ssh -oStrictHostKeyChecking=no "$SSH_HOST" 'sudo bash -s' <<- EOF
    set -e
    set -x

    apt-get install -y build-essential git

    git clone https://git.zx2c4.com/wireguard-tools /tmp/wireguard-tools
    make -C /tmp/wireguard-tools/src -j\$(nproc)
    make -C /tmp/wireguard-tools/src install
    perl -pi -e 's/#{1,}?net.ipv4.ip_forward ?= ?(0|1)/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
    modprobe wireguard
EOF
}

install_docker() {
  ssh -oStrictHostKeyChecking=no "$SSH_HOST" 'sudo bash -s' <<- EOF
    set -e
    set -x

    apt-get update
    apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      lsb-release

    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
      "deb [arch=armhf signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
      \$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io

    usermod -aG docker admin
    docker run --rm hello-world
EOF
}

change_default_password() {
  ssh -oStrictHostKeyChecking=no "$SSH_HOST" 'sudo bash -s' <<- EOF
    set -e
    hostname "$NEW_HOSTNAME"
    echo "$NEW_HOSTNAME" > /etc/hostname
EOF
}

wrapping_up() {
  pi_password=$(openssl rand -hex 16)

  ssh -oStrictHostKeyChecking=no "$SSH_HOST" 'sudo bash -s' <<- EOF
    set -e

    # set the new hostname
    hostname "$NEW_HOSTNAME"
    echo "$NEW_HOSTNAME" > /etc/hostname

    # change the default password for pi
    echo "pi:$pi_password" | chpasswd

    # reboot
    sudo reboot now
    exit
EOF
}

add_key ~/.ssh/id_rsa.pub
add_key ~/.ssh/mobile_rsa.pub

enable_password_less_sudo
add_admin_account
install_software
install_wireguard
install_docker

wrapping_up
