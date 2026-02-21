local M = {}

function M.setup()
    vim.opt.autoread = true

    -- Set up autocmd for file changes
    vim.api.nvim_create_autocmd("FileChangedShell", {
        pattern = "*",
        callback = function()
            M.handle_file_change()
        end,
    })

    -- Trigger checktime on various events
    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
        pattern = "*",
        callback = function()
            if vim.fn.mode() ~= "c" then
                vim.cmd("checktime")
            end
        end,
    })
end

function M.handle_file_change()
    local bufnr = vim.api.nvim_get_current_buf()

    -- Check if buffer has unsaved changes
    if vim.bo[bufnr].modified then
        M.prompt_conflict_resolution(bufnr)
    else
        -- Auto-reload silently
        vim.v.fcs_choice = ""
    end
end

function M.prompt_conflict_resolution(bufnr)
    local choice =
        vim.fn.confirm("File changed on disk. You have unsaved changes. Do you want to load the new version?", "&Yes\n&No\n&Diff", 2)

    if choice == 1 then
        -- Yes - discard local changes
        vim.cmd("edit!")
    elseif choice == 2 then
        -- No - keep local changes
        vim.v.fcs_choice = ""
    elseif choice == 3 then
        -- Diff - open diff view
        vim.cmd("diffthis")
        vim.cmd("vsplit | edit! | diffthis")
    end
end

return M
