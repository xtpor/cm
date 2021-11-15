#!/bin/sh
set -eu
root="$( cd "$(dirname "$0")"; pwd -P )"

name="postgres"

docker run -d \
  --name "$name" \
  --network app \
  -p 5432:5432 \
  -v "postgres-data:/var/lib/postgresql/data" \
  -e "POSTGRES_PASSWORD=postgrespassword" \
  postgres:13.3

