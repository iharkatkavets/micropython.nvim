-- lua/micropython/init_pico.lua

local logs = require("micropython.logs")
local configurator = require("micropython.configurator")
local state = require("micropython.state")

local M = {}

M.init = function()
  M.ask_to_create_venv_and_install_stubs(function()
    M.ask_to_create_pyrightconfig(function()
      configurator.pick_port(function(port)
        state._opts.port = port
      end)
    end)
  end)
end

local function create_pyrightconfig()
  local config_path = vim.fn.getcwd() .. "/pyrightconfig.json"
  if vim.fn.filereadable(config_path) == 1 then
    logs.warn("`pyrightconfig.json` already exists")
    return
  end

  local config = {
    typeCheckingMode = "basic",
    reportMissingImports = false,
    extraPaths = {},
    venvPath = ".",
    venv = ".venv",
    pythonVersion = "3.9",
    executionEnvironments = {
      {
        root = ".",
      },
    },
  }

  local json = vim.fn.json_encode(config)
  local fd = io.open(config_path, "w")
  if fd then
    fd:write(json)
    fd:close()
    logs.info("Created `pyrightconfig.json` for Pico")
  else
    logs.error("Failed to write pyrightconfig.json")
  end
end

M.ask_to_create_pyrightconfig = function(callback)
  vim.ui.select({ "Yes", "No" }, { prompt = "Do you want to create a pyrightconfig.json?" }, function(choice)
    if choice == "Yes" then
      create_pyrightconfig()
    end
    if callback then
      callback()
    end
  end)
end

local function create_venv(callback)
  -- python3 -m venv .venv && source .venv/bin/activate
  vim.fn.jobstart({ "python3", "-m", "venv", ".venv" }, {
    on_exit = function(_, code)
      if code == 0 then
        print("Virtual environment created at .venv/")
        callback()
      else
        print("Failed to create virtual environment")
        callback()
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

function M.ask_to_create_venv_and_install_stubs(callback)
  M.ask_to_create_venv(function(choice)
    if choice == "Yes" then
      M.ask_install_stubs(function()
        if callback then
          callback()
        end
      end)
    else
      callback()
    end
  end)
end

function M.ask_to_create_venv(callback)
  vim.ui.select({ "Yes", "No" }, { prompt = "Do you want to use a venv?" }, function(choice)
    if choice == "Yes" then
      create_venv(function()
        callback(choice)
      end)
    end
  end)
end

local function install_stubs(callback)
  -- pip install -U micropython-rp2-pico-w-stubs --no-user --target ./typings
  local pip_path = vim.fn.getcwd() .. "/.venv/bin/pip"
  vim.fn.jobstart({ pip_path, "install", "-U", "micropython-rp2-pico-w-stubs", "--no-user", "--target", "./typings" }, {
    on_exit = function(_, code)
      if code == 0 then
        logs.info("Installed stubs at ./typings")
        callback()
      else
        logs.error("Failed to install stubs")
        callback()
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

function M.ask_install_stubs(callback)
  vim.ui.select({ "Yes", "No" }, { prompt = "Do you want to install micropython-rp2-pico-w-stubs?" }, function(choice)
    if choice == "Yes" then
      install_stubs()
    end
    callback()
  end)
end

return M
