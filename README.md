<p align="center">
  <h1 align="center">nvim-kiro</h2>
</p>

<p align="center" style="color:gray">
    A Neovim plugin that integrates kiro-cli chat functionality directly into your editor with automatic "context passing"

</p>
<br>

## Table of Contents

* [Overview](#overview)
* [Requirements](#requirements)
* [Installation](#installation)
* [Commands](#commands)
* [Keybindings](#keybindings)
* [Configuration](#configuration)
* [Troubleshooting](#troubleshooting)
* [Additional Resources](#additional-resources)

---
<br>

## Overview

nvim-kiro is a Neovim plugin that integrates kiro-cli chat functionality directly into your editor with automatic context passing. It provides a seamless way to interact with Kiro AI while maintaining awareness of your current file, line number, and project context.

**Key Features:**
- Terminal-based chat interface (split or floating window)
- Automatic context injection (file path, line number, project root)
- Smart file reload handling with conflict detection
- Minimal configuration with sensible defaults

---
<br>

## Requirements

- **Neovim** 0.8.0 or later
- **kiro-cli** must be installed and available in your PATH

### Installing kiro-cli

For installation instructions, see the [kiro-cli installation guide](https://github.com/aws/kiro-cli#installation).

To verify kiro-cli is installed:
```bash
which kiro-cli
```

---
<br>

## Installation

### Using lazy.nvim

```lua
{
    'jmcada/nvim-kiro',
    config = function()
        require('nvim-kiro').setup()
    end
}
```

Or with [config options](#configuration)

```lua
{
    'jmcada/nvim-kiro',
    config = function()
        require('nvim-kiro').setup({
            debug = false,
            window_type = 'split',
            reload = true,
            close_keymap = '<C-q>'
        })
    end
}
```

---
<br>

## Commands

### User Commands

| Command | Description |
|---------|-------------|
| `:KiroChat` | Toggle the Kiro chat window (open/close) |

---
<br>

## Keybindings

### Chat Window Keybindings

These keybindings are active **only** in the Kiro chat buffer:

| Mode | Key | Action | Notes |
|------|-----|--------|-------|
| Terminal | `<C-q>` | Hide chat window | Configurable via `close_keymap` |
| Terminal | `<Esc>` | Hide chat window | Returns to previous buffer |
| Normal | `q` | Close chat window | Must exit terminal mode first (`<C-\><C-n>`) |

### Exiting Terminal Mode

To use normal mode keybindings in the chat window:
1. Press `<C-\>` then `<C-n>` to exit terminal insert mode
2. Now you can use `q` to close the window

Or use `<C-q>` directly from terminal mode (default binding).

### Global Keybindings

No global keybindings are set by default. Users can add their own:

```lua
-- Example: Add global keybinding to toggle chat
vim.keymap.set('n', '<leader>kt', ':KiroChat<CR>', { desc = 'Toggle Kiro Chat' })
```

---
<br>

## Configuration

### Default Configuration

```lua
{
    -- Enable debug logging
    debug = false,

    -- Window type: 'split' or 'float'
    window_type = 'split',

    -- Enable automatic file reload handling
    reload = true,

    -- Keybinding to close chat from terminal mode
    close_keymap = '<C-q>'
}
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `debug` | boolean | `false` | Print debug logs for events and actions |
| `window_type` | string | `'split'` | Window type: `'split'` (vertical split) or `'float'` (floating window) |
| `reload` | boolean | `true` | Enable automatic file reload with conflict detection |
| `close_keymap` | string | `'<C-q>'` | Terminal mode keybinding to close chat window |

---
<br>

## Troubleshooting

### Common Issues

**Chat window doesn't open:**
- Verify `kiro-cli` is installed: `which kiro-cli`
- Check debug logs: `require('nvim-kiro').setup({ debug = true })`

**Context not being sent:**
- Ensure you're in a file buffer (not unnamed or special buffer)
- Check that source buffer is valid when chat opens

**File reload not working:**
- Verify `reload = true` in config
- Check that `autoread` is set: `:set autoread?`

**Keybindings not working:**
- Ensure you're in the correct mode (terminal vs normal)
- Use `<C-\><C-n>` to exit terminal mode before using normal mode bindings

---
<br>

## Additional Resources

- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html)
- [kiro-cli Documentation](https://github.com/aws/kiro-cli)

---
<br>

> **Questions or Issues?**
> 
> Open an issue on GitHub with:
> - Neovim version (`:version`)
> - Plugin configuration
> - Steps to reproduce
> - Debug logs (if applicable)

