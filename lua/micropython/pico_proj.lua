-- lua/micropython/init_pico.lua

local M = {}

M.init = function()
  local config_path = vim.fn.getcwd() .. "/pyrightconfig.json"
  if vim.fn.filereadable(config_path) == 1 then
    vim.notify("pyrightconfig.json already exists", vim.log.levels.WARN)
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
    vim.notify("Created pyrightconfig.json for Pico", vim.log.levels.INFO)
  else
    vim.notify("Failed to write pyrightconfig.json", vim.log.levels.ERROR)
  end
end

return M
