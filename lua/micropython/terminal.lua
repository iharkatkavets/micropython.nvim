-- lua/micropython/terminal.lua

local state = require("micropython.state")

local M = {}

local create_buf_if_needed = function(opts)
  local buf = nil
  if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(true, false)
    vim.bo[buf].filetype = "mpremote"
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].modifiable = true
  end
  return buf
end

M.show = function(opts)
  opts = opts or {}

  local width = opts.width or vim.o.columns
  local height = opts.height or 5
  local cmd_and_status_line_height = 2
  local xrow = vim.o.lines - height - cmd_and_status_line_height
  local ycol = math.floor((vim.o.columns - width) / 2) -- Center it horizontally by default
  local buf = create_buf_if_needed(state._terminal.floating)

  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = xrow,
    col = ycol,
    style = "minimal",
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)
  state._terminal.floating = { buf = buf, win = win }
  if vim.bo[state._terminal.floating.buf] ~= "terminal" then
    vim.cmd.terminal()
  end
  state._terminal.job_id = vim.bo.channel

  vim.fn.chansend(state._terminal.job_id, { "echo 'hi'\r\n" })
end

M.close = function()
  vim.api.nvim_win_hide(state._terminal.floating.win)
end

return M
