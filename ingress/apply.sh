#!/bin/sh
set -eu
root="$( cd "$(dirname "$0")"; pwd -P )"


export DOCKER_HOST="ssh://root@ruby.tintinho.net"
container_name="caddy"

docker stop "$container_name" || true
docker rm "$container_name" || true

docker create \
  --name "$container_name" \
  -v caddy-data:/data \
  -p 80:80 \
  -p 443:443 \
  caddy:2.4.3

docker cp "$root/Caddyfile" "$container_name:/etc/caddy/Caddyfile"

docker start "$container_name"
