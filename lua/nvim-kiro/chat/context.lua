local M = {}

function M.get_context()
    local bufnr = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(bufnr)

    -- Handle unnamed or special buffers
    if bufname == "" or vim.bo[bufnr].buftype ~= "" then
        return nil
    end

    local cwd = vim.fn.getcwd()
    local relative_path = vim.fn.fnamemodify(bufname, ":.")
    local line_num = vim.fn.line(".")

    return string.format("Context: file=%s line=%d root=%s", relative_path, line_num, cwd)
end

return M
