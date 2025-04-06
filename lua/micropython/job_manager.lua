-- lua/micropython/job_manager.lua

local connect = require("micropython.connect")
local run = require("micropython.run")

local M = {}

M.stop_all_except_connect = function()
  run.stop()
end

M.stop_all_except_run = function()
  connect.stop()
end

M.stop_all = function()
  connect.stop()
  run.stop()
end

return M
