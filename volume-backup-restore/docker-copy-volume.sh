#!/bin/sh

volume_src="$1"
volume_dst="$2"

docker volume create "$volume_dst"

docker run --rm \
  -v "$volume_src:/volume1" \
  -v "$volume_dst:/volume2" \
  alpine cp -a /volume1/. /volume2/
