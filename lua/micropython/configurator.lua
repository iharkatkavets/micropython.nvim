-- lua/micropython/configurator.lua

local logs = require("micropython.logs")

local M = {}

local function get_ports_list()
  local result = vim.fn.systemlist("mpremote connect list")

  local ports = {}
  for _, port in ipairs(result) do
    table.insert(ports, port)
  end
  return ports
end

M.pick_port = function(callback)
  local ports = get_ports_list()

  if #ports == 0 then
    logs.error("No serial ports found")
    return
  end

  vim.ui.select(ports, { prompt = "Select serial port:" }, function(choice)
    if choice then
      local port = choice:match("^%S+")
      if port and callback then
        logs.info("Select port " .. port)
        callback(port)
      end
    end
  end)
end

return M
