#!/bin/bash
set -euo pipefail
IFS=$'\t\n'

aws_account_id="444718235796"
aws_region="ap-southeast-1"
local_port="5000"

set -x

ansible-playbook playbook.yml \
  -i inventory.txt \
  -u admin \
  --extra-vars "aws_account_id=$aws_account_id" \
  --extra-vars "aws_region=$aws_region" \
  --extra-vars "local_port=$local_port"
