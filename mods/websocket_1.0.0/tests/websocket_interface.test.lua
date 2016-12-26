local WebSocketInterface = require('websocket_interface')

local testSocket = WebSocketInterface:new()

testSocket:on('open', function() print('opened') end)
testSocket:open('ws://localhost:1337')
