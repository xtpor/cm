#!/bin/bash
set -euo pipefail
IFS=$'\t\n'
# root="$( cd "$(dirname "$0")"; pwd -P )"


container_name="grafana"

docker create --name "$container_name" --network private --rm -p 3000:3000 grafana/grafana:8.2.5

docker start "$container_name"