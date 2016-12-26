const readline = require('readline');
const random = require('ddp-random');
const WebSocketServer = require('ws').Server

const wss = new WebSocketServer({ port: 8081 });

const repling = false;
const resultPromises = [];

function call(methodName, params) {
  const results = wss.clients.map(client => {
    const id = random.id();

    client.send(JSON.stringify({
      method: 'run',
      params: params,
      id,
    }));

    return new Promise((fulfill, reject) => {
      resultPromises[id] = { fulfill, reject };
    });
  });

  return Promise.all(results);
}

function processLine(line) {
  if (line.trim() === '') {
    return;
  }

  return call('run', [line]);
}

console.log('waiting for connection...')

wss.on('connection', ws => {
  ws.on('message', message => {
    let reply;

    try {
      reply = JSON.parse(message);

      if (reply.id === undefined) {
        throw new Error('Message lacks ID field');
      }

      if (!(reply.id in resultPromises)) {
        throw new Error('Not a known call ID');
      }
    } catch (e) {
      console.error(`Got bad message: ${message}\nParsing error: ${e.message}`);
      return;
    }

    if (reply.error) {
      resultPromises[reply.id].reject(new Error(reply.error));
    } else {
      resultPromises[reply.id].fulfill(reply.result);
    }
  });

  if (!repling) {
    console.log('connected!');

    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    rl.on('line', line => {
      processLine(line)
        .then(result => {
          console.log(`=${result}`);
          process.stdout.write('> ');
        })
        .catch(err => {
          console.log(`error: ${err.message}`);
          process.stdout.write('> ');
        });
    });

    process.stdout.write('> ');
  }
});
