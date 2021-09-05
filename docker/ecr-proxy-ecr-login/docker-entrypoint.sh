#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [ -z "${AWS_ACCESS_KEY_ID+x}" ]; then
  echo "Error: please set the AWS_ACCESS_KEY_ID variable" >&2
  exit 1
fi

if [ -z "${AWS_SECRET_ACCESS_KEY+x}" ]; then
  echo "Error: please set the AWS_SECRET_ACCESS_KEY variable" >&2
  exit 1
fi

if [ -z "${AWS_REGION+x}" ]; then
  echo "Error: please set the AWS_REGION variable" >&2
  exit 1
fi

if [ -z "${OUTPUT_FILE+x}" ]; then
  echo "Error: please set the OUTPUT_FILE variable" >&2
  exit 1
fi

trap 'exit 0' SIGTERM

# test the credential for validity
aws sts get-caller-identity

while true; do
  aws ecr get-login-password >"$OUTPUT_FILE"
  echo "$(date) refreshed the password"
  sleep 6h &
  wait $!
done
