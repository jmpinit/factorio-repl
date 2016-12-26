# Factorio REPL

## Setup

0. Install Docker and a recent (>v6) version of [Node.js](https://nodejs.org/en/download/)
1. Download the [headless form of the game](https://www.factorio.com/download-headless) for Linux
and unpack it in the bin folder so you end up with **bin/factorio/<game-stuff>**.
2. `docker build -t=factorio-server .`. Grab the container ID when finished.
3. `./run.sh` to start the server.
4. Start Factorio and connect to the multiplayer server that is now running at **127.0.0.1:34190**
5. In **repl-server** run `node src/index.js` to start the actual REPL console.
6. In the chat run `/c remote.call('repl', 'open', 'ws://<your computer's ip>:8080')`, substituting
your computer's IP address.
7. The REPL should now be setup. Try running `return game.players[1].name` in the REPL console.
