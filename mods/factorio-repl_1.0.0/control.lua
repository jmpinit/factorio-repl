local json = require('json')

-- function which returns a different, unique ID every time it is called
local uuid = (function()
  local id = 0

  return function()
    local uniqueId = id
    id = id + 1
    return tostring(uniqueId)
  end
end)()

remote.add_interface('repl', {
  open= function(address)
    remote.call('websocket', 'open', uuid(), address)
  end,
  handleOpen= function(rpcId, connectionId)
    global.replConnectionId = connectionId
    game.print('connection opened')
  end,
  handleMessage = function(connectionId, message)
    game.print('got message: '..message)

    if global.replConnectionId == connectionId then
      game.print('processing message')

      local messageData = json:decode(message)

      if messageData.method == 'run' then
        local code = messageData.params[1]
        local fn, err = loadstring(code)

        local result;

        if err == nil then
          status, result = pcall(fn)

          if not status then 
            -- something went wrong
            err = result -- likely an error message
            result = nil
          end
        end

        local reply = {
          result= result,
          error= err,
          id= messageData.id,
        }

        local serializedReply = json:encode(reply)
        game.print('replying: '..serializedReply)
        remote.call('websocket', 'send', connectionId, serializedReply)
      end
    end
  end,
})

remote.call('websocket', 'setup', {
  interface= 'repl',
  on_open= 'handleOpen',
  on_message= 'handleMessage',
})
