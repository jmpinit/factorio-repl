local inspect = require('inspect')

local EventEmitter = require('event_emitter')

local testEmitter = EventEmitter:new()

testEmitter:on('a', function() print('a emitted') end)
testEmitter:emit('a')

testEmitter:on('b', function() print('b emitted') end)

testEmitter:emit('b')
testEmitter:emit('a')
