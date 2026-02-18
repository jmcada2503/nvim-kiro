local M = {}

local state = {
    bufnr = nil,
    chan_id = nil,
    win_id = nil,
    source_bufnr = nil,
    last_context = nil,
    last_input = "",
}

local config = _G.NvimKiroPlugin.config

local function get_window_config()
    if config.window_type == "float" then
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

local function update_context()
    if state.source_bufnr and vim.api.nvim_buf_is_valid(state.source_bufnr) then
        -- Get context from the source buffer
        local bufname = vim.api.nvim_buf_get_name(state.source_bufnr)
        if bufname ~= "" and vim.bo[state.source_bufnr].buftype == "" then
            local cwd = vim.fn.getcwd()
            local relative_path = vim.fn.fnamemodify(bufname, ":.")
            local line_num = vim.api.nvim_buf_get_mark(state.source_bufnr, ".")[1]
            state.last_context =
                string.format("\n[Context: file=%s line=%d root=%s]", relative_path, line_num, cwd)
        end
    end
end

function M.open_chat()
    if vim.fn.executable("kiro-cli") == 0 then
        vim.notify(
            "kiro-cli not found in PATH. Please install kiro-cli first.",
            vim.log.levels.ERROR
        )
        return
    end

    -- If window exists and is valid, just focus it
    if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
        vim.api.nvim_set_current_win(state.win_id)
        return
    end

    -- If buffer exists but window doesn't, recreate window
    if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
        local win_config = get_window_config()
        if win_config then
            state.win_id = vim.api.nvim_open_win(state.bufnr, true, win_config)
        else
            vim.cmd("vsplit")
            state.win_id = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(state.win_id, state.bufnr)
        end
        vim.cmd("startinsert")
        return
    end

    -- Store source buffer before creating chat
    state.source_bufnr = vim.api.nvim_get_current_buf()
    update_context()

    -- Create buffer first
    state.bufnr = vim.api.nvim_create_buf(false, true)

    -- Create window with buffer
    local win_config = get_window_config()
    if win_config then
        state.win_id = vim.api.nvim_open_win(state.bufnr, true, win_config)
    else
        vim.cmd("vsplit")
        state.win_id = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(state.win_id, state.bufnr)
    end

    -- Start terminal in the buffer
    state.chan_id = vim.fn.termopen("kiro-cli chat", {
        on_exit = function()
            state.bufnr = nil
            state.chan_id = nil
            state.win_id = nil
        end,
    })

    -- Set buffer options
    vim.bo[state.bufnr].bufhidden = "hide"
    vim.bo[state.bufnr].buflisted = false

    -- Setup keybinds
    M.setup_keybinds()

    vim.cmd("startinsert")
    vim.notify("Kiro chat opened", vim.log.levels.INFO)
end

function M.close_chat()
    if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
        vim.api.nvim_win_close(state.win_id, true)
        state.win_id = nil
    end
end

function M.toggle_chat()
    if state.win_id and vim.api.nvim_win_is_valid(state.win_id) then
        M.close_chat()
    else
        M.open_chat()
    end
end

function M.setup_keybinds()
    if not state.bufnr then
        return
    end

    -- Add custom keymap to close in terminal mode
    vim.api.nvim_buf_set_keymap(state.bufnr, "t", config.close_keymap, "<C-\\><C-n>:KiroChat<CR>", {
        noremap = true,
        silent = true,
    })

    -- Add q to close in normal mode
    vim.api.nvim_buf_set_keymap(state.bufnr, "n", "q", "", {
        noremap = true,
        callback = function()
            M.close_chat()
        end,
    })

    -- Track input characters
    for i = 32, 126 do
        local char = string.char(i)
        vim.keymap.set("t", char, function()
            state.last_input = state.last_input .. char
            return char
        end, { buffer = state.bufnr, expr = true })
    end

    -- Track backspace
    vim.keymap.set("t", "<BS>", function()
        state.last_input = state.last_input:sub(1, -2)
        return "<BS>"
    end, { buffer = state.bufnr, expr = true })

    -- Map Enter to send context then pass through
    vim.keymap.set("t", "<CR>", function()
        local trimmed = state.last_input:match("^%s*(.-)%s*$")

        -- Skip context for: commands starting with /, or single char responses (y/n/t)
        local skip_context = trimmed:match("^/") or trimmed:match("^[ynt]$")

        if state.last_context and state.chan_id and not skip_context then
            vim.fn.chansend(state.chan_id, state.last_context .. "\n")
        end
        state.last_input = "" -- Reset for next input
        return "<CR>"
    end, { buffer = state.bufnr, expr = true })

    -- Map ESC to close chat window in terminal mode
    vim.keymap.set(
        "t",
        "<Esc>",
        "<C-\\><C-n>:KiroChat<CR>",
        {
            noremap = true,
            silent = true,
        }
    )
end

return M
