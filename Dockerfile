FROM ubuntu:16.04

# install node.js
RUN apt-get update --fix-missing && apt-get install -y curl
RUN curl https://nodejs.org/dist/v6.9.2/node-v6.9.2-linux-x64.tar.gz | \
  tar --strip-components 1 -xvz -C /usr/local \
  --exclude='CHANGELOG.md' --exclude='LICENSE' --exclude='README.md'

# setup the game server
WORKDIR /opt/factorio
COPY ./bin/factorio/ .
WORKDIR /opt/factorio/bin/x64/
RUN ./factorio --create map

# add the websocket-connector
WORKDIR /opt/websocket-connector
COPY ./websocket-connector .

# add the mods
WORKDIR /opt/mods/factorio-repl_1.0.0
COPY mods/factorio-repl_1.0.0 .
WORKDIR /opt/mods/websocket_1.0.0
COPY mods/websocket_1.0.0 .

# add the settings
WORKDIR /var/factorio
COPY server-settings.json .

WORKDIR /opt/app
COPY launch.sh .

# make Factorio server reachable
EXPOSE 34197

CMD ./launch.sh
