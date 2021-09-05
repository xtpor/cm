#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [ -z "${CADDY_ADMIN_ENDPOINT+x}" ]; then
  echo "Error: please set the CADDY_ADMIN_ENDPOINT variable"
  exit 1
fi

if [ -z "${REGISTRY_URL+x}" ]; then
  echo "Error: please set the REGISTRY_URL variable"
  exit 1
fi

if [ -z "${REGISTRY_USERNAME+x}" ]; then
  echo "Error: please set the REGISTRY_USERNAME variable"
  exit 1
fi

if [ -z "${REGISTRY_PASSWORD_FILE+x}" ]; then
  echo "Error: please set the REGISTRY_PASSWORD_FILE variable"
  exit 1
fi

if [ -z "${UPDATE_INTERVAL+x}" ]; then
  echo "Error: please set the UPDATE_INTERVAL variable"
  exit 1
fi

touch "$REGISTRY_PASSWORD_FILE"

while true; do
  password=$(cat "$REGISTRY_PASSWORD_FILE")
  export REGISTRY_BASIC_CREDENTIAL=$(echo "$REGISTRY_USERNAME:$password" | base64 -w 0)

  cat "Caddyfile.tpl" | envsubst > /tmp/Caddyfile
  echo "$(date) generated caddyfile"

  curl "$CADDY_ADMIN_ENDPOINT/load" \
    -X POST \
    -H "Content-Type: text/caddyfile" \
    --data-binary @/tmp/Caddyfile \
    && echo "$(date) reloaded the generated caddyfile"

  sleep "$UPDATE_INTERVAL" &
  wait $!
done
