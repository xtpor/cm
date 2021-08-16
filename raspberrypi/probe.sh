#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


HOST="raspberrypi.local"

until nc -vzw 2 $HOST 22; do sleep 2; done
