#!/bin/sh
set -eu

mc >/dev/null 2>&1 || true

export MC_HOST_b2="https://$B2_KEY_ID:$B2_APPLICATION_KEY@s3.us-west-000.backblazeb2.com"

path="b2/$B2_BUCKET/$B2_PATH"
volume_size="$(mc stat --json "$path" | jq '.size')"

mc cat "$path" | pv -s "$volume_size" | tar -C /volume -xf -
