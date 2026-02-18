local log = require("nvim-kiro.util.log")

local NvimKiroPlugin = {}

--- NvimKiroPlugin configuration with its default values.
---
---@type table
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
NvimKiroPlugin.options = {
    -- Prints useful logs about what event are triggered, and reasons actions are executed.
    debug = false,
    -- What type of window to open the map in.
    window_type = "split",
    -- Toggle reload module
    reload = true,
    -- Set keybinding to hide the chat window (Use special keys as this will run when the terminal is open)
    close_keymap = "<C-q>",
}

---@private
local defaults = vim.deepcopy(NvimKiroPlugin.options)

--- Defaults NvimKiroPlugin options by merging user provided options with the default plugin values.
---
---@param options table Module config table. See |NvimKiroPlugin.options|.
---
---@private
function NvimKiroPlugin.defaults(options)
    NvimKiroPlugin.options =
        vim.deepcopy(vim.tbl_deep_extend("keep", options or {}, defaults or {}))

    -- let your user know that they provided a wrong value, this is reported when your plugin is executed.
    assert(
        type(NvimKiroPlugin.options.debug) == "boolean",
        "`debug` must be a boolean (`true` or `false`)."
    )

    return NvimKiroPlugin.options
end

--- Define your nvim-kiro setup.
---
---@param options table Module config table. See |NvimKiroPlugin.options|.
---
---@usage `require("nvim-kiro").setup()` (add `{}` with your |NvimKiroPlugin.options| table)
function NvimKiroPlugin.setup(options)
    NvimKiroPlugin.options = NvimKiroPlugin.defaults(options or {})

    log.warn_deprecation(NvimKiroPlugin.options)

    if NvimKiroPlugin.options.reload then
        require("nvim-kiro.reload").setup()
    end
    return NvimKiroPlugin.options
end

return NvimKiroPlugin
