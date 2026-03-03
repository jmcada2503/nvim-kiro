local M = {}

local log = require("nvim-kiro.utils.log")
local interface = require("nvim-kiro.chat.interface")

local state = _G.NvimKiroPlugin.state

function M.get_context()
    if not (state.source.buffer_id and vim.api.nvim_buf_is_valid(state.source.buffer_id)) then
        log.error(
            "chat.context",
            "The \"get_context\" method was called, but the state.source.buffer_id is not valid, there's no source to get context from"
        )
        return
    end

    local buffer_name = vim.api.nvim_buf_get_name(state.source.buffer_id)

    -- Handle unnamed or special buffers
    if buffer_name == "" or vim.bo[state.source.buffer_id].buftype ~= "" then
        log.error(
            "chat.context",
            "The \"get_context\" method was called, but the state.source.buffer_id buffer is unnamed or is an special buffer"
        )
        return
    end

    local cwd = vim.fn.getcwd()
    local relative_path = vim.fn.fnamemodify(buffer_name, ":.")
    local line_number = vim.fn.line(".")

    return string.format("[Context: file=%s line=%d root=%s]", relative_path, line_number, cwd)
end

-- Update context from current buffer
function M.update_context()
    state.source.buffer_id = vim.api.nvim_get_current_buf()
    state.chat.last_context = M.get_context()
end

function M.get_current_file_context()
    local file_path = vim.api.nvim_buf_get_name(0)
    return "/context add " .. file_path .. "\r"
end

function M.get_selection_context()
    state.source.buffer_id = vim.api.nvim_get_current_buf()
    local current_file_context = M.get_context()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local lines = vim.fn.getregion(start_pos, end_pos)
    if #lines == 0 then
        log.error(
            "chat.context",
            "You must select something first, to add it as context to the chat..."
        )
        return
    end
    local selection = table.concat(lines, "\n")

    return string.format(
        "\n%s\n```\n%s\n```\n\n",
        current_file_context,
        selection
    )
end

return M
