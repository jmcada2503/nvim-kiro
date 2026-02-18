local conf = require("nvim-kiro.config")

local M = {}

-- setup NvimKiroPlugin options and merge them with user provided ones.
function M.setup(opts)
    _G.NvimKiroPlugin = _G.NvimKiroPlugin or {}
    _G.NvimKiroPlugin.config = conf.setup(opts)
end

return M
