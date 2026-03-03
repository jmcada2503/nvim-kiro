local M = {}

local log = require("nvim-kiro.utils.log")
local interface = require("nvim-kiro.chat.interface")
local actions = require("nvim-kiro.chat.actions")
local context = require("nvim-kiro.chat.context")
local utils = require("nvim-kiro.chat.utils")

local state = _G.NvimKiroPlugin.state
local settings = _G.NvimKiroPlugin.settings

function M.open_chat()
    if not interface.is_buffer_open() then
        log.error(
            "chat",
            "The \"open_chat\" method was called, but there's no chat buffer"
        )
        return
    end

    -- Update context before opening chat buffer
    context.update_context()

    -- If window exists and is valid, just focus it
    if interface.is_window_open() then
        vim.api.nvim_set_current_win(state.win_id)
        return
    end

    interface.open_window()
end

function M.toggle_chat()
    if interface.is_window_open() then
        interface.close_window()
    else
        M.open_chat()
    end
end

function M.add_current_file_to_context()
    if not interface.is_buffer_open() then
        log.error(
            "chat.context",
            "The \"add_current_file_to_context\" method was called, but there's no chat buffer. Use :KiroChat to create it."
        )
        return
    end

    local file_context = context.get_current_file_context()
    utils.reposition_user_input(function()
        vim.fn.chansend(
            state.chat.channel_id,
            file_context
        )
    end)
    M.open_chat()
end

function M.add_selection_to_context()
    if not interface.is_buffer_open() then
        log.error(
            "chat.context",
            "The \"add_selection_to_context\" method was called, but there's no chat buffer. Use :KiroChat to create it."
        )
        return
    end
    local file_context = context.get_current_file_context()
    local selection_context = context.get_selection_context()
    utils.reposition_user_input(function()
        vim.fn.chansend(
            state.chat.channel_id,
            file_context
        )
        state.chat.last_input = selection_context .. state.chat.last_input
    end)
    M.open_chat()
end

function M.select_agent()
    if not interface.is_buffer_open() then
        log.error(
            "chat.actions",
            "The \"select_agent\" method was called, but there's no chat buffer. Use :KiroChat to create it."
        )
        return
    end

    local agent_swap = actions.get_agent_swap()
    utils.remove_user_input()
    vim.fn.chansend(
        state.chat.channel_id,
        agent_swap
    )
    M.open_chat()
end

return M
