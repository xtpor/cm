#!/bin/sh
set -eu

restart_wireguard() {
  echo "restarting $1"
  ssh "$1" "sudo systemctl restart wg-quick@wg0"
  echo "restart complete."
}

restart_wireguard "admin@cherry.local"
restart_wireguard "admin@dewberry.local"
restart_wireguard "admin@elderberry.local"
restart_wireguard "admin@fig.local"
restart_wireguard "root@ruby.tintinho.net"