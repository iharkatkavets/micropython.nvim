-- lua/micropython/init.lua

local run = require("micropython.run")
local connect = require("micropython.connect")
local logs = require("micropython.logs")
local state = require("micropython.state")
local tools = require("micropython.tools")
local config = require("micropython.config")
local job_manager = require("micropython.job_manager")
local pico_proj = require("micropython.pico_proj")
local configurator = require("micropython.configurator")

local M = {}

local create_commands = function()
  vim.api.nvim_create_user_command("MPInitPicoProj", function()
    pico_proj.init()
  end, {
    desc = "Init Raspberry Pi Pico project",
  })

  vim.api.nvim_create_user_command("MPConnect", function()
    job_manager.stop_all_except_connect()
    connect.connect()
  end, { desc = "Connect to MicroPython device" })

  vim.api.nvim_create_user_command("MPSelectPort", function()
    configurator.pick_port(function(port)
      state._opts.port = port
    end)
  end, { desc = "Select the device" })

  vim.api.nvim_create_user_command("MPUpload", function()
    -- not ready yet
  end, { desc = "Upload current file to MicroPython device" })

  vim.api.nvim_create_user_command("MPUploadAll", function()
    -- not ready yet
  end, { desc = "Upload all python files to MicroPython device" })

  vim.api.nvim_create_user_command("MPRun", function(user_opts)
    job_manager.stop_all()
    local first_arg = user_opts.fargs[1]
    if first_arg then
      run.run(first_arg)
    else
      run.select_then_run()
    end
  end, { desc = "Run the file on MicroPython device", nargs = "?" })

  vim.api.nvim_create_user_command("MPRunCurrent", function()
    job_manager.stop_all()
    run.run_current_buffer()
  end, { desc = "Run the current buffer on MicroPython device" })

  vim.api.nvim_create_user_command("MPLogs", function()
    logs.show()
  end, { desc = "View logs and executed commands" })
end

M.setup = function(user_opts)
  config.setup(user_opts)
  state._opts = vim.tbl_deep_extend("force", state._opts, config.opts or {})
  create_commands()
end

return M
