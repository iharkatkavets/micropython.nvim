local state = {
  floating = {
    buf = -1,
    win = -1,
  },
}

local function open_bottom_float(opts)
  opts = opts or {}

  local width = opts.width or vim.o.columns
  local height = opts.height or 5

  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
    print("Reuse buf")
  else
    buf = vim.api.nvim_create_buf(false, true)
    print("Create buf")
  end

  local row = vim.o.lines - height - 2 -- Adjust for cmd line & statusline
  local col = math.floor((vim.o.columns - width) / 2) -- Center it horizontally by default

  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })

  return { buf = buf, win = win }
end

vim.api.nvim_create_user_command("Pico", function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = open_bottom_float({ buf = state.floating.buf })
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end, {})
