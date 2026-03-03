local M = {}

local log = require("nvim-kiro.utils.log")
local interface = require("nvim-kiro.chat.interface")
local context = require("nvim-kiro.chat.context")
local utils = require("nvim-kiro.chat.utils")

local state = _G.NvimKiroPlugin.state

function M.get_agent_swap()
    return "/agent swap\r"
end

return M
