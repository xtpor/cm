#!/bin/bash
set -euo pipefail
IFS=$'\t\n'
root="$( cd "$(dirname "$0")"; cd ..; pwd -P )"


# provision a pvc
kubecfg update -A pvcName=tiddlywiki-data -A nodeName=fig jobs/provision-local-path-pvc.jsonnet
kubectl wait --for=condition=complete --timeout=120s job/pin-pvc-tiddlywiki-data

# initialize the volume
kubecfg update \
  -A jobName=initialize-tiddlywiki-data \
  -A pvcName=tiddlywiki-data \
  "$root/apps/tiddlywiki/initialize-volume.jsonnet"
kubectl wait --for=condition=complete --timeout=120s job/initialize-tiddlywiki-data

# create the kubernetes resources
tiddlywiki_config=$(cat <<-EOF
{
  ldapHost: "openldap",
  ldapPort: "389",
  ldapBaseDN: "dc=lab,dc=tintinho,dc=net",
  ldapBindDN: "cn=readonly,dc=lab,dc=tintinho,dc=net",
  ldapBindPassword: "readonlypassword",
  ldapSearchFilter: "(uid=%(username)s)",
}
EOF
)
kubecfg update \
  -A name=tiddlywiki \
  -A pvcName=tiddlywiki-data \
  --tla-code config="$tiddlywiki_config" \
  "$root/apps/tiddlywiki/manifests.jsonnet"