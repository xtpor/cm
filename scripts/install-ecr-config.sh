#!/bin/bash
# for Raspberry Pi
set -euo pipefail
IFS=$'\n\t'

ssh_host="$1"
user="root"

aws_credential_file=$(
  cat <<- EOF
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
EOF
)

docker_config_file=$(
  cat <<- EOF
{
  "credHelpers": {
    "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com": "ecr-login"
  }
}
EOF
)

ssh "$ssh_host" "sudo -u $user mkdir -p ~$user/.aws"
echo "$aws_credential_file" | ssh "$ssh_host" "sudo -u $user tee ~$user/.aws/credentials > /dev/null"

ssh "$ssh_host" "sudo -u $user mkdir -p ~$user/.docker"
echo "$docker_config_file" | ssh "$ssh_host" "sudo -u $user tee ~$user/.docker/config.json > /dev/null"

echo "done."
