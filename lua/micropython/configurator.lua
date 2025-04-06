-- lua/micropython/configurator.lua

local M = {}

M.pick_port = function(callback)
  local ports = M.get_ports_list()

  if #ports == 0 then
    vim.notify("No serial ports found", vim.log.levels.WARN)
    return
  end

  vim.ui.select(ports, { prompt = "Select serial port:" }, function(choice)
    if choice then
      local port = choice:match("^%S+")
      if port and callback then
        callback(port)
      end
    end
  end)
end

M.get_ports_list = function()
  local result = vim.fn.systemlist("mpremote connect list")

  local ports = {}
  for _, port in ipairs(result) do
    table.insert(ports, port)
  end
  return ports
end

return M
