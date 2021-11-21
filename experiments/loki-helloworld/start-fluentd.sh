#!/bin/sh
set -eu
root="$( cd "$(dirname "$0")"; pwd -P )"

container_name="fluentd"

docker stop "$container_name" >/dev/null 2>&1 || true
docker rm "$container_name" >/dev/null 2>&1 || true

docker create \
  --name "$container_name" \
  --network private \
  -p 9880:9880 \
  -p 24224:24224 \
  grafana/fluent-plugin-loki:main-88feda4-amd64 \
  -c /fluentd/etc/fluentd.conf

docker cp "$root/fluentd.conf" "$container_name:/fluentd/etc/fluentd.conf"

docker start "$container_name"