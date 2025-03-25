local M = {}

M.setup = function()
  -- nothing
end

local first_fn = function(lines)
  for i, line in ipairs(lines) do
    print(i .. line)
  end
end

return M
