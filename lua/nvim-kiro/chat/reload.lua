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
        -- Diff - open diff view (deferred to avoid E811)
        vim.v.fcs_choice = ""
        vim.schedule(function()
            vim.cmd("rightbelow vert new | set buftype=nofile | r # | 0d_ | diffthis")
            local scratch_buf = vim.api.nvim_get_current_buf()
            vim.cmd("wincmd p | diffthis")
            vim.api.nvim_create_autocmd("BufWritePost", {
                buffer = bufnr,
                callback = function()
                    local confirm = vim.fn.confirm("Save this as the final version?", "&Yes\n&No", 2)
                    if confirm == 1 then
                        vim.cmd("diffoff!")
                        if vim.api.nvim_buf_is_valid(scratch_buf) then
                            vim.cmd("bdelete " .. scratch_buf)
                        end
                        return true -- removes the autocmd
                    end
                end,
            })
        end)
    end
end

return M
