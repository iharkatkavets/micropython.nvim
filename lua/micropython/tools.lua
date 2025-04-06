-- lua/micropython/tools.lua

local M = {}

M.file_exists = function(path)
  ---@diagnostic disable-next-line: undefined-field
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == "char"
end

M.executable_exists = function(tool)
  return vim.fn.executable(tool) == 1
end

return M
