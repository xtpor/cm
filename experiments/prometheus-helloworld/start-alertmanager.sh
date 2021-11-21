#!/bin/bash
set -euo pipefail
IFS=$'\t\n'
root="$( cd "$(dirname "$0")"; pwd -P )"


container_name="alertmanager"

docker stop "$container_name" >/dev/null 2>&1 || true
docker rm "$container_name" >/dev/null 2>&1 || true

docker create --name "$container_name" --network private -p 9093:9093 prom/alertmanager:v0.23.0

docker cp "$root/alertmanager.yml" "$container_name:/etc/alertmanager/alertmanager.yml"

docker start "$container_name"