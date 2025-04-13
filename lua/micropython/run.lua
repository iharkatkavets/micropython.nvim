-- lua/micropython/run.lua

local logs = require("micropython.logs")
local core = require("micropython.core")
local state = require("micropython.state")
local configurator = require("micropython.configurator")
local uv = vim.uv

local M = {}

local function run(file)
  local buf = state._run.floating.buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    local prev_win = state._run.floating.win
    if prev_win ~= -1 and vim.api.nvim_win_is_valid(prev_win) then
      vim.api.nvim_win_close(prev_win, true)
    end
    buf = vim.api.nvim_create_buf(true, false)
  end

  local win = core.find_window_with_buf(buf)
  if not win then
    win = core.create_bottom_window(buf)
  end

  local job_id = state._run.job_id
  if job_id == 0 and state._opts.port then
    local cmd = { "mpremote", "run", file }
    logs.sinfo("Exec: " .. table.concat(cmd, " "))
    job_id = vim.fn.termopen(cmd, {
      on_exit = function()
        logs.sinfo("Exit 'Run' job_id " .. job_id)
      end,
    })
  end

  vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })

  state._run.floating = { buf = buf, win = win }
  state._run.job_id = job_id
  logs.sinfo("Create 'Run' job_id " .. job_id)
end

local function pick_port_if_needed(callback)
  if not state._opts.port then
    configurator.pick_port(function(port)
      state._opts.port = port
      callback()
    end)
  else
    callback()
  end
end

function M.run(file)
  pick_port_if_needed(function()
    M.show(file)
  end)
end

local function select_file(callback)
  local files = {}
  local cwd = vim.fn.getcwd()

  local handle = uv.fs_scandir(cwd)
  if handle then
    while true do
      local name, type = vim.loop.fs_scandir_next(handle)
      if not name then
        break
      end
      if type == "file" then
        table.insert(files, name)
      end
    end
  end

  if #files == 0 then
    logs.error("No files found in current directory.")
    return
  end

  vim.ui.select(files, {
    prompt = "Pick a file to run:",
  }, function(choice)
    if choice then
      callback(choice)
    end
  end)
end

function M.select_then_run()
  select_file(function(file)
    pick_port_if_needed(function()
      run(file)
    end)
  end)
end

local function select_current_buffer(callback)
  local file_buf = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(file_buf)
  callback(file_path)
end

function M.run_current_buffer()
  select_current_buffer(function(file)
    if file ~= "" then
      run(file)
    else
      M.select_then_run()
    end
  end)
end

function M.stop()
  if core.is_running(state._run.job_id) then
    vim.fn.jobstop(state._run.job_id)
    logs.sinfo("Stop 'Run' job_id " .. state._run.job_id)
    state._run.job_id = 0
  end

  local prev_win = state._run.floating.win
  if prev_win ~= -1 and vim.api.nvim_win_is_valid(prev_win) then
    vim.api.nvim_win_close(prev_win, true)
    logs.sinfo("Close 'Run' win " .. prev_win)
  end

  local buf = state._run.floating.buf
  if buf ~= -1 and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
    logs.sinfo("Delete 'Run' buf " .. buf)
  end

  state._run.floating = { buf = -1, win = -1 }
end

return M
