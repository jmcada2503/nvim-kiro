local M = {}

local log = require("nvim-kiro.utils.log")
local utils = require("nvim-kiro.chat.utils")

local state = _G.NvimKiroPlugin.state
local settings = _G.NvimKiroPlugin.settings

function M.setup_keybindings()
    -- Track input characters
    for i = 32, 126 do
        local char = string.char(i)
        vim.keymap.set("t", char, function()
            state.chat.last_input = state.chat.last_input .. char
            return char
        end, { buffer = state.chat.buffer_id, expr = true })
    end

    -- Track backspace
    vim.keymap.set("t", "<BS>", function()
        state.chat.last_input = state.chat.last_input:sub(1, -2)
        return "<BS>"
    end, { buffer = state.chat.buffer_id, expr = true })

    -- Track Control + C
    vim.keymap.set("t", "<C-c>", function()
        state.chat.last_input = ""
        return "<C-c>"
    end, { buffer = state.chat.buffer_id, expr = true })

    -- Map Enter to send context then pass through
    vim.keymap.set("t", "<CR>", function()
        local trimmed = state.chat.last_input:match("^%s*(.-)%s*$")

        -- Skip context for:
        -- * commands starting with /
        -- * commands starting with !
        -- * single char responses (y/n/t)
        -- * empty responses ""
        local skip_context = (
            trimmed:match("^/")
            or trimmed:match("^[ynt]$")
            or trimmed:match("^!")
            or trimmed:match("^$")
        )

        if state.chat.last_context and state.chat.channel_id and not skip_context then
            vim.fn.chansend(state.chat.channel_id, "\n" .. state.chat.last_context .. "\n")
        end
        
        state.chat.last_input = ""

        if trimmed:match("^$") and state.chat.pending_input then
            vim.fn.chansend(state.chat.channel_id, "\r")
            utils.add_user_input()
            return
        end

        return "<CR>"
    end, { buffer = state.chat.buffer_id, expr = true })

    -- Map ESC to enter normal mode in terminal mode
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", {
        buffer = state.chat.buffer_id,
        noremap = true,
        silent = true,
    })

    -- Map configurable key to close in normal mode
    vim.keymap.set("n", settings.close_normal_keymap, ":KiroChat<CR>", {
        buffer = state.chat.buffer_id,
        noremap = true,
        silent = true,
    })

    -- Add custom keymap to close in terminal mode
    vim.api.nvim_buf_set_keymap(state.chat.buffer_id, "t", settings.close_keymap, "<C-\\><C-n>:KiroChat<CR>", {
        noremap = true,
        silent = true,
    })
end

return M
