local conf = require("nvim-kiro.config")

local M = {}

-- setup NvimKiroPlugin options and merge them with user provided ones.
function M.setup(opts)
    _G.NvimKiroPlugin = _G.NvimKiroPlugin or {}
    _G.NvimKiroPlugin.config = conf.setup(opts)

    local chat = require("nvim-kiro.chat")

    -- setup plugin commands
    vim.api.nvim_create_user_command("KiroChat", function()
        chat.toggle_chat()
    end, {})
    vim.api.nvim_create_user_command("KiroAddFileToContext", function()
        chat.add_current_file_to_context()
    end, {})
    vim.api.nvim_create_user_command("KiroAddSelectionToContext", function()
        chat.add_selection_to_context()
    end, {range=true})
end

return M
