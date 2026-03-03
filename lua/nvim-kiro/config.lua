local log = require("nvim-kiro.utils.log")

local M = {}
local settings = _G.NvimKiroPlugin.settings

--- NvimKiroPlugin configuration with its default values.
---
---@type table
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
M.options = {
    -- Prints useful logs about what event are triggered, and reasons actions are executed.
    debug = false,
    -- What type of window to open the map in.
    window_type = "float",
    -- Toggle reload module
    reload = true,
    -- Set keybinding to hide the chat window (Use special keys as this will run when the terminal is open)
    close_keymap = "<C-q>",
    cli_agent = {
        -- Set cli agent binnary name
        binnary = "kiro-cli",
        -- Set command that opens the chat interface with cli agent
        command = "kiro-cli chat"
    },
}

---@private
local defaults = vim.deepcopy(M.options)

--- Defaults NvimKiroPlugin options by merging user provided options with the default plugin values.
---
---@param options table Module config table.
---
---@private
function M.defaults(options)
    M.options =
        vim.deepcopy(vim.tbl_deep_extend("keep", options or {}, defaults or {}))

    -- let your user know that they provided a wrong value, this is reported when your plugin is executed.
    assert(
        type(M.options.debug) == "boolean",
        "`debug` must be a boolean (`true` or `false`)."
    )

    return M.options
end

function M.get_window_config()
    if settings.window_type == "float" then
        local ui = vim.api.nvim_list_uis()[1]
        local width = math.floor(ui.width * 0.8)
        local height = math.floor(ui.height * 0.8)

        return {
            relative = "editor",
            width = width,
            height = height,
            row = math.floor((ui.height - height) / 2),
            col = math.floor((ui.width - width) / 2),
            style = "minimal",
            border = "rounded",
            title = " Kiro Chat ",
            title_pos = "center",
        }
    end

    return nil -- Use split
end


--- Define your nvim-kiro setup.
---
---@param options table Module config table..
function M.setup(options)
    M.options = M.defaults(options or {})

    if M.options.reload then
        require("nvim-kiro.chat.reload").setup()
    end

    settings = M.options
    return M.options
end

return M
