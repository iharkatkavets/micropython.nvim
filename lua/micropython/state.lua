-- lua/micropython/state.lua

local M = {
  _opts = {
    port = nil,
  },
  _connect = {
    job_id = 0,
    floating = {
      buf = -1,
      win = -1,
    },
  },
  _run = {
    job_id = 0,
    floating = {
      buf = -1,
      win = -1,
    },
  },
  _logs = {
    floating = {
      buf = -1,
      win = -1,
    },
  },
  _terminal = {
    floating = {
      buf = -1,
      win = -1,
    },
    job_id = 0,
  },
}

return M
