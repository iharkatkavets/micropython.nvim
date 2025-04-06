-- lua/micropython/connect.lua

local state = require("micropython.state")
local logs = require("micropython.logs")
local configurator = require("micropython.configurator")
local core = require("micropython.core")

local M = {}

function M.connect()
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

  local buf = state._connect.floating.buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    local prev_win = state._connect.floating.win
    if prev_win ~= -1 and vim.api.nvim_win_is_valid(prev_win) then
      vim.api.nvim_win_close(prev_win, true)
    end
    buf = vim.api.nvim_create_buf(true, false)
  end

  local win = core.find_window_with_buf(buf)
  if not win then
    vim.cmd.vsplit()
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
    vim.cmd("wincmd J")
    vim.api.nvim_win_set_height(win, 15)
  end

  local job_id = state._connect.job_id
  local port = opts.port
  if job_id == 0 and port then
    job_id = vim.fn.termopen({ "mpremote", "connect", port }, {
      on_exit = function()
        state._connect.floating.buf = -1
        state._connect.job_id = 0
      end,
    })
  end

  vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })

  state._connect.floating = { buf = buf, win = win }
  state._connect.job_id = job_id
end

M.close = function()
  vim.api.nvim_win_hide(state._connect.floating.win)
end

M.stop = function()
  if core.is_running(state._connect.job_id) then
    logs.add("Stop Connect job_id " .. state._connect.job_id)
    vim.fn.jobstop(state._connect.job_id)
    state._connect.job_id = 0
  end

  local prev_win = state._connect.floating.win
  if prev_win ~= -1 and vim.api.nvim_win_is_valid(prev_win) then
    logs.add("Close Connect win " .. prev_win)
    vim.api.nvim_win_close(prev_win, true)
  end

  local buf = state._connect.floating.buf
  if buf ~= -1 and vim.api.nvim_buf_is_valid(buf) then
    logs.add("Delete Connect buf " .. buf)
    vim.api.nvim_buf_delete(buf, { force = true })
  end

  state._connect.floating = { buf = -1, win = -1 }
end

return M
