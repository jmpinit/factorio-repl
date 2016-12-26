#!/bin/bash

set -o errexit

cd /opt/websocket-connector
mkdir -p /opt/factorio/script-output/tx
node src/index.js /opt/factorio/script-output/command.pipe &

cd /opt/factorio/bin/x64
./factorio \
  --mod-directory /opt/mods \
  --rcon-port 1337 \
  --rcon-password secret \
  --server-settings /var/factorio/server-settings.json \
  --start-server map.zip
