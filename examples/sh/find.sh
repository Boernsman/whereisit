#!/usr/bin/env sh

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <server_ip> <server_port>"
  exit 1
fi

SERVER_IP=$1
SERVER_PORT=$2

curl -X GET "${SERVER_IP}:${SERVER_PORT}/api/devices"

echo "----- DONE -----"
