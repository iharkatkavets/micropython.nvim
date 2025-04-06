-- lua/micropython/init.lua

local run = require("micropython.run")
local connect = require("micropython.connect")
local logs = require("micropython.logs")
local state = require("micropython.state")
local tools = require("micropython.tools")
local configurator = require("micropython.configurator")
local config = require("micropython.config")
local job_manager = require("micropython.job_manager")

local M = {}

local create_commands = function()
  vim.api.nvim_create_user_command("MPConnect", function()
    job_manager.stop_all_except_connect()
    connect.connect()
  end, { desc = "Connect to MicroPython device" })

  vim.api.nvim_create_user_command("MPUpload", function()
    -- not ready yet
  end, { desc = "Upload current file to MicroPython device" })

  vim.api.nvim_create_user_command("MPUploadAll", function()
    -- not ready yet
  end, { desc = "Upload all python files to MicroPython device" })

  vim.api.nvim_create_user_command("MPRun", function()
    job_manager.stop_all()
    run.run()
  end, { desc = "Run current file on MicroPython device" })

  vim.api.nvim_create_user_command("MPLogs", function()
    logs.show()
  end, { desc = "View logs and executed commands" })
end

M.setup = function(user_opts)
  config.setup(user_opts)
  state._opts = vim.tbl_deep_extend("force", state._opts, config.opts or {})

  if not state._opts.port or not tools.file_exists(state._opts.port) then
    configurator.pick_port(function(port)
      state._opts.port = port
      M.setup(user_opts)
    end)
    return false
  end

  create_commands()
end

return M
