local M = {}

function M.setup()
    return {
        chat = {
            buffer_id = nil,
            channel_id = nil,
            window_id = nil,
            last_context = nil,
            last_input = "",
            pending_input = false,
            editor_active = false,
        },
        source = {
            buffer_id = nil,
        },
    }
end

function M.reset_state()
    _G.NvimKiroPlugin.state.chat.buffer_id = nil
    _G.NvimKiroPlugin.state.chat.channel_id = nil
    _G.NvimKiroPlugin.state.chat.window_id = nil
    _G.NvimKiroPlugin.state.chat.last_context = nil
    _G.NvimKiroPlugin.state.chat.last_input = ""
    _G.NvimKiroPlugin.state.chat.editor_active = false
    _G.NvimKiroPlugin.state.source.buffer_id = nil
end

return M
