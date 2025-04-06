-- lua/micropython/run.lua

local logs = require("micropython.logs")
local core = require("micropython.core")
local state = require("micropython.state")
local configurator = require("micropython.configurator")

local M = {}

function M.run()
  if not state._opts.port then
    configurator.pick_port(function(port)
      state._opts.port = port
      M.show(state._opts)
    end)
  else
    M.show(state._opts)
  end
end

M.show = function(opts)
  opts = opts or {}

  local file_buf = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(file_buf)
  if file_path == "" then
    logs.add("[Error] No file associated with current buffer")
    return
  end

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
  local port = opts.port
  if job_id == 0 and port then
    local cmd = { "mpremote", "run", file_path }
    logs.info("Exec: " .. table.concat(cmd, " "))
    job_id = vim.fn.termopen(cmd, {
      on_exit = function()
        logs.info("Exit 'Run' job_id " .. job_id)
      end,
    })
  end

  vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })

  state._run.floating = { buf = buf, win = win }
  state._run.job_id = job_id
  logs.info("Create 'Run' job_id " .. job_id)
end

function M.stop()
  if core.is_running(state._run.job_id) then
    vim.fn.jobstop(state._run.job_id)
    logs.info("Stop 'Run' job_id " .. state._run.job_id)
    state._run.job_id = 0
  end

  local prev_win = state._run.floating.win
  if prev_win ~= -1 and vim.api.nvim_win_is_valid(prev_win) then
    vim.api.nvim_win_close(prev_win, true)
    logs.info("Close 'Run' win " .. prev_win)
  end

  local buf = state._run.floating.buf
  if buf ~= -1 and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
    logs.info("Delete 'Run' buf " .. buf)
  end

  state._run.floating = { buf = -1, win = -1 }
end

return M
