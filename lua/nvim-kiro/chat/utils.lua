local M = {}

local log = require("nvim-kiro.utils.log")

local state = _G.NvimKiroPlugin.state

function M.remove_user_input()
    vim.fn.chansend(state.chat.channel_id, string.rep("\b", #state.chat.last_input))
    state.chat.pending_input = true
end

function M.add_user_input()
    vim.fn.chansend(state.chat.channel_id, state.chat.last_input)
    state.chat.pending_input = false
end

-- Temporarily removes user input from the terminal, executes a callback function,
-- then restores the user input. This allows operations to be performed on the
-- terminal buffer without interfering with the user's current input text.
function M.reposition_user_input(callback)
    M.remove_user_input()
    if callback then
        callback()
    end
    vim.defer_fn(M.add_user_input, 100)
end

return M
