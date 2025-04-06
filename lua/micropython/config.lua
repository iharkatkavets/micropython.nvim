-- lua/micropython/config.lua

local M = {}

M.opts = {
  port = "/dev/cu.usbmodem101",
}

function M.setup(user_opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, user_opts or {})
end

return M
