# Implementation Plan - nvim-kiro Plugin

**Problem Statement:**
Create a Neovim plugin that integrates kiro-cli chat functionality with automatic context passing (filename, line number, root directory) and handles concurrent file editing without sync conflicts.

**Requirements:**
1. [x] Toggleable chat interface (split window with text buffer, configurable to floating)
2. [x] Automatic context injection on every message (filename, line#, root directory)
3. [x] Non-blocking file editing with smart reload handling:
   [x] - Auto-reload if no unsaved changes
   [x] - Prompt with options (Load/OK/Diff) if unsaved changes exist
4. [x] Simple configuration with sensible defaults, room for expansion
5. [x] Enter key sends messages (Ctrl+j for newlines)
6. [ ] Inject selected content as context to the chat
   [ ] - Inject selected content always before the user prompt (even when the user promp is already written)
7. [x] Inject current file as context to the chat
8. [ ] Command to generate a commit message

**Background:**

Based on research of amazonq.nvim and Neovim plugin patterns:
- Neovim plugins use Lua with a standard structure: `lua/`, `plugin/`, `doc/`
- Terminal buffers can be created with `vim.fn.termopen()` or `vim.fn.jobstart()`
- Communication happens via `vim.fn.chansend()` to send data to the terminal
- File change detection uses `FileChangedShell` autocmd event
- The `autoread` option combined with `checktime` enables automatic reloading
- Plugin managers like lazy.nvim support `dev = true` for local development

Architecture:
- Use terminal buffer running `kiro-cli chat` in interactive mode
- Intercept Enter key in terminal insert mode to prepend context before sending
- Set up autocmds for `FileChangedShell` to handle kiro-cli's file modifications
- Use float window by default (configurable to split)

**Task Breakdown:**

**Task 1: Create basic plugin structure and setup function**
- Objective: Establish the plugin directory structure and minimal setup function
- Create directory structure: `lua/nvim-kiro/`, `plugin/`
- Implement `lua/nvim-kiro/init.lua` with `setup()` function that accepts config table
- Define default config: `{ window_type = 'split' }` (minimal for now)
- Store config in module-level variable for access by other modules
- Demo: Can call `require('nvim-kiro').setup()` in Neovim config without errors

**Task 2: Implement context extraction module**
- Objective: Extract current file context (filename, line number, root directory)
- Create `lua/nvim-kiro/context.lua`
- Implement `get_context()` function that returns:
  - Relative filepath from project root (using `vim.fn.getcwd()`)
  - Current line number (using `vim.fn.line('.')`)
  - Project root directory
- Format as: `Context: file=<path> line=<num> root=<dir>`
- Handle edge cases: unnamed buffers, non-file buffers
- Demo: Call function from command line and see formatted context string

**Task 3: Create chat buffer with kiro-cli terminal**
- Objective: Open a split window with terminal running kiro-cli chat
- Create `lua/nvim-kiro/chat.lua`
- Implement `open_chat()` function that:
  - Creates vertical split on right side (`vim.cmd('vsplit')`)
  - Opens terminal buffer with `vim.fn.termopen('kiro-cli chat')`
  - Stores buffer number and channel ID for later communication
  - Sets buffer options: `bufhidden=hide`, `buflisted=false`
- Implement `close_chat()` function to hide the buffer
- Implement `toggle_chat()` function to open/close
- Demo: Run toggle function and see kiro-cli chat appear in split, can type and interact normally

**Task 4: Add context injection on message send**
- Objective: Automatically prepend context when user presses Enter
- In `chat.lua`, set up terminal buffer keymapping for `<CR>` in insert mode
- On Enter press:
  - Get current line content from chat buffer
  - Get context from original buffer (not chat buffer)
  - Format message: `Context: ... \n<user message>`
  - Send to kiro-cli via `vim.fn.chansend()`
  - Clear the input line in chat buffer
- Handle empty messages (don't send)
- Demo: Type message in chat, press Enter, see context prepended in kiro-cli output

**Task 5: Register plugin command and test locally**
- Objective: Create `:KiroChat` command and test with lazy.nvim dev mode
- Create `plugin/nvim-kiro.vim` (or `plugin/nvim-kiro.lua`)
- Register `:KiroChat` command that calls `require('nvim-kiro.chat').toggle_chat()`
- Add README.md with installation instructions for lazy.nvim:
  ```lua
  { dir = '~/path/to/nvim-kiro', dev = true, opts = {} }
  ```
- Demo: Run `:KiroChat` command, chat opens with working context injection

**Task 6: Implement smart file reload on external changes**
- Objective: Auto-reload files modified by kiro-cli, with conflict handling
- Create `lua/nvim-kiro/reload.lua`
- Set up `FileChangedShell` autocmd that triggers on external file changes
- Implement logic:
  - If buffer not modified: silently reload with `vim.cmd('checktime')`
  - If buffer modified: show prompt with options:
    - `L` - Load kiro's changes (discard local)
    - `O` - Keep local changes (ignore kiro's)
    - `D` - Open diff view (use `vim.cmd('diffthis')`)
- Call this setup from main `init.lua` setup function
- Demo: Have kiro-cli modify an open file, see it reload automatically; make local edits, have kiro modify same file, see prompt appear

**Task 7: Polish and documentation**
- Objective: Add error handling, improve UX, document usage
- Add error handling for kiro-cli not found in PATH
- Add visual feedback when chat opens (status message)
- Improve chat buffer appearance (set window width, add border if floating)
- Create comprehensive README.md with:
  - Installation instructions (lazy.nvim, vim-plug, manual)
  - Configuration options
  - Usage examples
  - Troubleshooting section
- Add help doc (`doc/nvim-kiro.txt`) with `:help nvim-kiro`
- Demo: Clean, documented plugin ready for daily use
