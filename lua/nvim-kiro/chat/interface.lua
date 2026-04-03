local M = {}
local log = require("nvim-kiro.utils.log")
local config = require("nvim-kiro.config")
local keybindings = require("nvim-kiro.chat.keybindings")
local state_module = require("nvim-kiro.state")

local state = _G.NvimKiroPlugin.state
local settings = _G.NvimKiroPlugin.settings

local function setup_keybindings()
    if not M.is_buffer_open() then
        log.error(
            "chat",
            "The function \"setup_keybindings\" has been called, but there's no buffer open"
        )
        return
    end

    keybindings.setup_keybindings()
end


function M.is_agent_installed()
    if vim.fn.executable(settings.cli_agent.binnary) == 0 then
        return false
    end
    return true
end

function M.initialize_cli_agent()
    if not M.is_agent_installed() then
        log.agent_not_installed()
        return
    end

    -- Save current buffer before creating new one
    local current_buffer = vim.api.nvim_get_current_buf()

    M.open_buffer()
    vim.api.nvim_set_current_buf(state.chat.buffer_id) -- Switch to chat buffer to open channel in it
    M.open_channel()
    setup_keybindings()

    -- Switch back to original buffer
    if vim.api.nvim_buf_is_valid(current_buffer) then
        vim.api.nvim_set_current_buf(current_buffer)
    end
end

function M.is_buffer_open()
    if
        state.chat.channel_id
        and state.chat.buffer_id
        and vim.api.nvim_buf_is_valid(state.chat.buffer_id)
    then
        return true
    end
    return false
end

function M.is_window_open()
    if state.chat.window_id and vim.api.nvim_win_is_valid(state.chat.window_id) then
        return true
    end
    return false
end

function M.open_window()
    if M.is_window_open() then
        vim.api.nvim_set_current_win(state.chat.window_id)
        vim.cmd("startinsert")
        return
    end

    local window_config = config.get_window_config()
    if window_config then
        state.chat.window_id = vim.api.nvim_open_win(state.chat.buffer_id, true, window_config)
    else
        vim.cmd("50vsplit")
        state.chat.window_id = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(state.chat.window_id, state.chat.buffer_id)
    end
    vim.cmd("startinsert")
end

-- Creates chat buffer
function M.open_buffer()
    -- If buffer exists don't create a new one
    if state.chat.buffer_id and vim.api.nvim_buf_is_valid(state.chat.buffer_id) then
        return
    end

    state.chat.buffer_id = vim.api.nvim_create_buf(false, true)

    -- Set buffer options
    vim.bo[state.chat.buffer_id].bufhidden = "hide"
    vim.bo[state.chat.buffer_id].buflisted = false
end

-- Opens channel in current buffer (Focus desired buffer before calling this method)
function M.open_channel()
    -- If channel exists don't create a new one
    if state.chat.channel_id then
        return
    end

    -- Start channel with command
    state.chat.channel_id = vim.fn.termopen(settings.cli_agent.command, {
        on_exit = function()
            M.close_window()
            state_module.reset_state()
            M.initialize_cli_agent()
        end
    })
end

function M.close_window()
    if not M.is_window_open() then
        log.error(
            "chat.interface",
            "The function \"close_window\" has been called, but there's no window open"
        )
        return
    end

    vim.api.nvim_win_close(state.chat.window_id, true)
    state.chat.window_id = nil
end

return M
