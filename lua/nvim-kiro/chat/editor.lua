local M = {}

local utils = require("nvim-kiro.chat.utils")
local interface = require("nvim-kiro.chat.interface")
local config = require("nvim-kiro.config")

local state = _G.NvimKiroPlugin.state

function M.open()
    if not interface.is_window_open() then
        return
    end

    state.chat.editor_active = true

    -- Close chat window
    interface.close_window()

    -- Create editable scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "Kiro Chat [Edit Mode]")
    vim.bo[buf].buftype = "acwrite"
    vim.bo[buf].filetype = "markdown"

    -- Populate with current prompt
    local lines = vim.split(state.chat.last_input, "\n", { plain = true })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Open buffer using same window style as chat
    local window_config = config.get_window_config()
    if window_config then
        window_config.title = " Kiro Chat - [Edit Mode] "
        vim.api.nvim_open_win(buf, true, window_config)
    else
        vim.cmd("50vsplit")
        vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
    end
    vim.bo[buf].modified = false
    vim.wo.number = true
    vim.wo.relativenumber = true

    vim.notify("Edit prompt. :w to send, :q! to cancel", vim.log.levels.INFO)

    -- Make :q behave as :q! (skip modified check)
    vim.api.nvim_create_autocmd("QuitPre", {
        buffer = buf,
        once = true,
        callback = function()
            vim.bo[buf].modified = false
        end,
    })

    -- Save handler
    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = buf,
        once = true,
        callback = function()
            local edited_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local new_input = table.concat(edited_lines, "\n")

            utils.remove_user_input()
            state.chat.last_input = new_input
            utils.add_user_input()

            vim.bo[buf].modified = false
            state.chat.editor_active = false
            vim.api.nvim_buf_delete(buf, { force = true })

            interface.open_window()
        end,
    })

    -- Cancel handler
    vim.api.nvim_create_autocmd("BufWinLeave", {
        buffer = buf,
        once = true,
        callback = function()
            if not state.chat.editor_active then
                return
            end
            state.chat.editor_active = false
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(buf) then
                    vim.api.nvim_buf_delete(buf, { force = true })
                end
                interface.open_window()
            end)
        end,
    })
end

return M
