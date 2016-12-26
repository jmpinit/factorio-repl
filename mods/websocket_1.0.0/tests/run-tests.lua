oldrequire = require
require = function(path)
  startChar = path.sub(0, 1)

  if startChar ~= '.' and startChar ~= '/' then
    -- is a naked module name
    path = './'..path
  end

  local modulePath = path..'.lua'
  local moduleFn = assert(loadfile(modulePath))
  status, errOrModule = pcall(moduleFn)

  assert(status == true)

  return errOrModule
end

dofile('./tests/event_emitter.test.lua')
dofile('./tests/websocket_interface.test.lua')
