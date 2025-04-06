-- lua/micropython/upload.lua

local logs = require("micropython.logs")
local core = require("micropython.core")
local state = require("micropython.state")

local M = {}

local function ensure_installed(tool)
  if vim.fn.executable(tool) == 0 then
    return false
  end
  return true
end

local function copy_current_file_to_device(buf)
  local full_path = vim.api.nvim_buf_get_name(buf)
  if full_path == "" then
    logs.add("[Error] No file associated with current buffer")
    return false
  end

  local cmd = { "mpremote", "cp", full_path, ":main.py" }
  logs.add("$ " .. table.concat(cmd, " "))

  local output = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error
  if exit_code ~= 0 then
    logs.add("[Error] " .. output)
    return false
  end

  return true
end

function M.run()
  local visible_buf = vim.api.nvim_get_current_buf()

  logs.show()
  if not ensure_installed("mpremote") then
    logs.add(string.format("[Error] Required tool '%s' is not installed.", "mpremote"))
    logs.add_end_line()
    return false
  end

  if not copy_current_file_to_device(visible_buf) then
    logs.add_end_line()
    return false
  end

  logs.hide()
  return true
end

function M.stop()
  if core.is_running(state._run.job_id) then
    vim.fn.jobstop(state._run.job_id)
    state._run.job_id = 0
  end

  local prev_win = state._run.floating.win
  if prev_win ~= -1 and vim.api.nvim_win_is_valid(prev_win) then
    vim.api.nvim_win_close(prev_win, true)
  end

  local buf = state._run.floating.buf
  if buf ~= -1 and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end

  state._run.floating = { buf = -1, win = -1 }
end

return M
