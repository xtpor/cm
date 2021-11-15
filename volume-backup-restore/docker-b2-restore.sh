#!/bin/sh
set -eu
root="$( cd "$(dirname "$0")"; pwd -P )"

docker run --rm -it \
  -v "postgres-data:/volume" \
  -e "B2_KEY_ID=0005ecd2d1741e10000000003" \
  -e "B2_APPLICATION_KEY=K0007VQQ96NCwzbwjQtO/IMM6GjhCGQ" \
  -e "B2_BUCKET=tintinho" \
  -e "B2_PATH=backups/test/postgres-data4.tar" \
  b2-restore-volume
