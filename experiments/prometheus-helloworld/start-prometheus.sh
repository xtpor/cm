#!/bin/bash
set -euo pipefail
IFS=$'\t\n'
root="$( cd "$(dirname "$0")"; pwd -P )"


container_name="prometheus"

docker create --name "$container_name" --network private --rm -p 9090:9090 prom/prometheus:v2.31.1

docker cp "$root/prometheus.yml" "$container_name:/etc/prometheus/prometheus.yml"

docker cp "$root/alert-rules.yml" "$container_name:/etc/prometheus/alert-rules.yml"

docker start "$container_name"