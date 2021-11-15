#!/bin/sh
set -eu
root="$( cd "$(dirname "$0")"; pwd -P )"

name="adminer"

docker run -d \
  --name "$name" \
  --network app \
  -p 8080:8080 \
  adminer
