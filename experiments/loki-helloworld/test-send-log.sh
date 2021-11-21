#!/bin/bash
set -euo pipefail
IFS=$'\t\n'

set -x

curl -X POST -d "json=$2" "http://localhost:9880/$1"