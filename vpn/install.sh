#!/bin/sh
# Install wireguard config on the target machine
# install.sh <ssh-host> <config-name>

ssh_host="$1"
config_name="$2"
root="$( cd "$(dirname "$0")"; pwd -P )"

echo "installing wireguard $config_name on $ssh_host"

remote_tmp_dir=$(ssh "$ssh_host" 'mktemp -d')
scp "$root/res/${config_name}.conf" "$ssh_host:$remote_tmp_dir/wg0.conf"
scp "$root/res/${config_name}.hosts" "$ssh_host:$remote_tmp_dir/hosts"


ssh "$ssh_host" 'sudo bash -s' <<- EOF
sed '/managed by wireguard/d' /etc/hosts > "$remote_tmp_dir/new-hosts"
cat "$remote_tmp_dir/hosts" >> "$remote_tmp_dir/new-hosts"
mv "$remote_tmp_dir/new-hosts" "/etc/hosts"

sudo mv "$remote_tmp_dir/wg0.conf" /etc/wireguard/wg0.conf
sudo systemctl enable wg-quick@wg0
sudo systemctl restart wg-quick@wg0
wg
EOF

echo "done."
