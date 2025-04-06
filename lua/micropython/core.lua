-- lua/micropython/core.lua

local M = {}

M.is_running = function(job_id)
  if not job_id or job_id == 0 then
    return false
  end
  local result = vim.fn.jobwait({ job_id }, 0)[1]
  return result == -1
end

M.find_window_with_buf = function(buf)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      return win
    end
  end
  return nil
end

M.create_bottom_window = function(buf)
  vim.cmd.vsplit()
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.cmd("wincmd J")
  vim.api.nvim_win_set_height(win, 15)
  return win
end

return M
