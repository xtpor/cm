#!/bin/bash
set -euo pipefail
IFS=$'\t\n'
root="$( cd "$(dirname "$0")"; cd ..; pwd -P )"

# provision a pvc
kubecfg update -A pvcName=openldap-data -A nodeName=fig jobs/provision-local-path-pvc.jsonnet

kubectl wait --for=condition=complete --timeout=120s job/pin-pvc-openldap-data



# initialize the volume
openldap_config=$(cat <<-EOF
{
  organization: "Tintin Ho's Lab",
  domain: "lab.tintinho.net",
  adminUserPassword: "adminpassword",
  configUserPassword: "configpassword",
  readonlyUserPassword: "readonlypassword"
}
EOF
)
kubecfg update \
  -A jobName=initialize-openldap-data \
  -A pvcName=openldap-data \
  --tla-code config="$openldap_config" \
  "$root/apps/openldap/initialize-volume.jsonnet"

kubectl wait --for=condition=complete --timeout=120s job/initialize-openldap-data

# create the Deployment and the Service resource
kubecfg update \
  -A name=openldap \
  -A pvcName=openldap-data \
  "$root/apps/openldap/manifests.jsonnet"