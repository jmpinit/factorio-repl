local WebSocketInterface = require('websocket_interface')

-- function which returns a different, unique ID every time it is called
local uuid = (function()
  local id = 0

  return function()
    local uniqueId = id
    id = id + 1
    return tostring(uniqueId)
  end
end)()

function setup(interfaceSpec)
  if interfaceSpec.interface == nil or
      interfaceSpec.on_open == nil or
      interfaceSpec.on_message == nil then
    error('Invalid interface, must specify interface name, on_open, and on_message')
  end

  global.interfaceSpec = interfaceSpec
end

function open(rpcId, address)
  if global.interfaceSpec == nil then
    error('Interface not setup. Call "setup" with callbacks first')
  end

  local ws = WebSocketInterface:new()
  local connectionId = uuid()

  -- everything sent via the remote interfaces must be serializable, so we cannot directly return
  -- the WebSocketInterface instance and must call a given callback interface with the data instead
  ws:on('message', function(message)
    remote.call(global.interfaceSpec.interface, global.interfaceSpec.on_message, connectionId, message)
  end)

  ws:on('_send', function (data)
    game.write_file('tx/'..connectionId..'.pipe', data, true, 0)
  end)

  if global.websockets == nil then
    global.websockets = {}
  end

  global.websockets[connectionId] = ws

  -- ask the helper program to create the WebSocket
  game.write_file('command.pipe', 'open,'..connectionId..','..address..'\n', true, 0)

  remote.call(global.interfaceSpec.interface, global.interfaceSpec.on_open, rpcId, connectionId)
end

function send(connectionId, data)
  if global.websockets[connectionId] == nil then
    game.print('tx for invalid connection ID: '..connectionId)
    return
  end

  game.print('tx['..connectionId..']: '..data)

  local ws = global.websockets[connectionId]
  ws:send(data)
end

function receive(connectionId, data)
  if global.websockets[connectionId] == nil then
    game.print('receive for invalid connection ID: '..connectionId)
    return
  end

  game.print('receive['..connectionId..']: '..data)

  local ws = global.websockets[connectionId]
  ws:_receive(data)
end

remote.add_interface('websocket', {
  setup= setup,
  open= open,
  send= send,
  -- called via RCON by the external helper program which has the actual WebSocket connection
  _receive= receive,
})
