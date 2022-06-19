#!/bin/sh
set -eu

monitor_interval=5m
trap "exit 0" SIGTERM
echo "start monitoring the duckdns domain $DOMAIN"

while true; do
  public_ip="$( curl ifconfig.me )"
  echo "$(date) public ip is $public_ip"

  dns_ip="$( dig +short "$DOMAIN" )"
  echo "$(date) ip of the dns record is $dns_ip"


  if [ "$public_ip" = "$dns_ip" ]; then
    echo "$(date) both ips matches"
  else
    curl "https://www.duckdns.org/update/$DOMAIN/$TOKEN/$public_ip"
    echo "$(date) set the ip address of $DOMAIN to $public_ip"
  fi

  echo "$(date) waiting for $monitor_interval before the next check"
  sleep "$monitor_interval" &
  wait $!
done


