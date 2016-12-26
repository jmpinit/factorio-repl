local EventEmitter = {}

function EventEmitter:new()
  self.__index = self
  emitter = { listeners= {} }
  setmetatable(emitter, self)
  return emitter
end

function EventEmitter:emit(event, data)
  local eventListeners = self.listeners[event]

  if eventListeners == nil then
    return
  end

  for _, callback in pairs(eventListeners) do
    callback(data)
  end
end

function EventEmitter:on(event, callback)
  if self.listeners[event] == nil then
    self.listeners[event] = {}
  end

  table.insert(self.listeners[event], callback)
end

return EventEmitter
