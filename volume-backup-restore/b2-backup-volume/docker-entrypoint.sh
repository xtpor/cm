#!/bin/sh
set -eu

mc >/dev/null 2>&1 || true

export MC_HOST_b2="https://$B2_KEY_ID:$B2_APPLICATION_KEY@s3.us-west-000.backblazeb2.com"

path="b2/$B2_BUCKET/$B2_PATH"
volume_size="$(($(du -sk /volume | cut -f1) * 1000))"

tar -C /volume -cf - . | pv -s "$volume_size" | mc pipe "$path"
