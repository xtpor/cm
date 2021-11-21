#!/bin/bash
set -euo pipefail
IFS=$'\t\n'
root="$( cd "$(dirname "$0")"; pwd -P )"

docker_cp_mkdirp() {
  # WARNING this is a hack
  # create directory before the container starts
  temp_dir=$(mktemp -d)
  mkdir -p "$temp_dir$2"
  docker cp "$temp_dir/." "$1:/"
}

container_name="loki"
volume_name="loki-data"

docker stop "$container_name" >/dev/null 2>&1 || true
docker rm "$container_name" >/dev/null 2>&1 || true

docker create \
  --name "$container_name" \
  --network private \
  -v "$volume_name:/loki" \
  -p 3100:3100 \
  grafana/loki:2.2.1 \
  -config.file=/etc/loki/loki.yml


docker cp "$root/loki.yml" "$container_name:/etc/loki/loki.yml"

docker_cp_mkdirp "$container_name" "/etc/loki/rules/fake"
docker cp "$root/alert-rules.yml" "$container_name:/etc/loki/rules/fake/alert-rules.yml"

docker start "$container_name"