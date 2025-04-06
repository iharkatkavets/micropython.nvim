-- lua/micropython/logs.lua

local state = require("micropython.state")

local M = {}

local function timestamp()
  return os.date("%Y-%m-%d %H:%M:%S")
end

local create_buf_if_needed = function(opts)
  if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then
    return opts.buf
  else
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = "picodevlog"
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].modifiable = true
    return buf
  end
end

function M.show(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  local xrow = math.floor((vim.o.lines - height) / 2)
  local ycol = math.floor((vim.o.columns - width) / 2)

  local buf = create_buf_if_needed(state._logs.floating)

  local win_opts = {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = xrow,
    col = ycol,
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
  state._logs.floating.buf = buf
  state._logs.floating.win = win
end

M.info = function(msg)
  M.add(string.format("%s [INFO] %s", timestamp(), msg))
end

function M.warn(msg)
  M.add(string.format("%s [WARN] %s", timestamp(), msg))
end

M.error = function(msg)
  M.add(string.format("%s [ERROR] %s", timestamp(), msg))
end

function M.add(msg)
  local floating = state._logs.floating
  state._logs.floating.buf = create_buf_if_needed(floating)
  if vim.api.nvim_buf_is_valid(floating.buf) then
    local lines = type(msg) == "table" and msg or vim.split(msg, "\n", {})
    if vim.api.nvim_buf_get_lines(floating.buf, 0, 1, false)[1] == "" then
      vim.api.nvim_buf_set_lines(floating.buf, 0, 1, false, lines)
    else
      vim.api.nvim_buf_set_lines(floating.buf, -1, -1, false, lines)
    end
  end
end

function M.hide()
  local floating = state._logs.floating
  if vim.api.nvim_win_is_valid(floating.win) and vim.api.nvim_buf_is_valid(floating.buf) then
    vim.api.nvim_win_hide(state._logs.floating.win)
  end
end

return M
