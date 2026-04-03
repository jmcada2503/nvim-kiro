_G.NvimKiroPlugin = _G.NvimKiroPlugin or {}
_G.NvimKiroPlugin.settings = {}
_G.NvimKiroPlugin.state = {}

local config = require("nvim-kiro.config")
local state = require("nvim-kiro.state")
local M = {}

-- setup NvimKiroPlugin options and merge them with user provided ones.
function M.setup(opts)
    _G.NvimKiroPlugin.settings = config.setup(opts)
    _G.NvimKiroPlugin.state = state.setup()

    local chat = require("nvim-kiro.chat")
    local interface = require("nvim-kiro.chat.interface")

    -- setup plugin commands
    local function guard(fn)
        return function()
            if _G.NvimKiroPlugin.state.chat.editor_active then
                vim.notify("Close KiroChat edit mode first (:w to send, :q! to cancel)", vim.log.levels.WARN)
                return
            end
            fn()
        end
    end

    vim.api.nvim_create_user_command("KiroChat", guard(function()
        chat.toggle_chat()
    end), {})
    vim.api.nvim_create_user_command("KiroAddFileToContext", guard(function()
        chat.add_current_file_to_context()
    end), {})
    vim.api.nvim_create_user_command("KiroAddSelectionToContext", guard(function()
        chat.add_selection_to_context()
    end), {range=true})
    vim.api.nvim_create_user_command("KiroAgentSwap", guard(function()
        chat.select_agent()
    end), {})

    vim.defer_fn(function()
        interface.initialize_cli_agent()
    end, 100)
end

return M
