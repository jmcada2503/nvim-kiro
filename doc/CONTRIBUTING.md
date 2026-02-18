# Contributing

## Project Structure

```
nvim-kiro/
├── lua/nvim-kiro/           # Core plugin logic
│   ├── init.lua             # Main entry point, setup function
│   ├── config.lua           # Configuration management
│   ├── main.lua             # Enable/disable/toggle logic
│   ├── state.lua            # Global state management
│   ├── chat.lua             # Chat buffer and terminal management
│   ├── context.lua          # Context extraction utilities
│   ├── reload.lua           # File change detection and reload
│   └── util/
│       └── log.lua          # Logging utilities
├── plugin/
│   └── nvim-kiro.lua        # Plugin initialization, commands
├── doc/
│   ├── nvim-kiro-plugin.txt # Vim help documentation
│   └── plan.md              # Original implementation plan
├── tests/
│   ├── test_API.lua         # API tests
│   └── helpers.lua          # Test utilities
├── scripts/
│   └── minimal_init.lua     # Minimal config for testing
├── .github/                 # GitHub workflows and templates
├── Makefile                 # Build, test, lint commands
├── README.md                # User-facing documentation
└── stylua.toml              # Lua formatting config
```

### Module Responsibilities

| Module | Purpose |
|--------|---------|
| `init.lua` | Public API (`setup()`, `toggle()`, `enable()`, `disable()`) |
| `config.lua` | Configuration defaults and validation |
| `main.lua` | Internal enable/disable logic |
| `state.lua` | Global plugin state (enabled/disabled) |
| `chat.lua` | Terminal buffer creation, keybindings, context injection |
| `context.lua` | Extract file/line/root context from current buffer |
| `reload.lua` | Handle external file changes with conflict resolution |
| `util/log.lua` | Debug logging and deprecation warnings |

---
<br>

## Architecture

### Chat Flow

```
User opens chat (:KiroChat)
    ↓
chat.lua creates terminal buffer
    ↓
Runs `kiro-cli chat` in terminal
    ↓
User types message and presses Enter
    ↓
Intercept Enter key → get context from source buffer
    ↓
Send context + message to kiro-cli via chansend()
    ↓
Kiro responds in terminal
```

### Context Injection

The plugin tracks the **source buffer** (the file you were editing when you opened chat) and extracts context from it:

```lua
-- Format: [Context: file=<path> line=<num> root=<dir>]
```

Context is sent **before** the user's message when Enter is pressed, but skipped for:
- Commands starting with `/` (e.g., `/quit`)
- Single character responses (e.g., `y`, `n`, `t`)

### File Reload Logic

```
External file change detected (FileChangedShell)
    ↓
Check if buffer has unsaved changes
    ↓
No changes → Auto-reload silently
    ↓
Has changes → Prompt user:
    [L]oad - Discard local changes, load external
    [O]K - Keep local changes, ignore external
    [D]iff - Open diff view for manual merge
```

---
<br>

## API Reference

### Public API

#### `setup(opts)`

Initialize the plugin with configuration options.

```lua
require('nvim-kiro').setup({
    debug = true,
    window_type = 'float'
})
```

**Parameters:**
- `opts` _(table, optional)_: Configuration options

**Returns:** None

---

#### `toggle()`

Toggle the plugin enabled/disabled state.

```lua
require('nvim-kiro').toggle()
```

**Returns:** None

---

#### `enable(scope)`

Enable the plugin.

```lua
require('nvim-kiro').enable()
```

**Parameters:**
- `scope` _(string, optional)_: Internal identifier for logging

**Returns:** None

---

#### `disable()`

Disable the plugin.

```lua
require('nvim-kiro').disable()
```

**Returns:** None

---
<br>

### Chat API

#### `open_chat()`

Open the Kiro chat window. If already open, focuses the existing window.

```lua
require('nvim-kiro.chat').open_chat()
```

**Behavior:**
- Checks if `kiro-cli` is in PATH
- Stores source buffer for context extraction
- Creates terminal buffer with `kiro-cli chat`
- Sets up keybindings
- Enters terminal insert mode

**Returns:** None

---

#### `close_chat()`

Close the Kiro chat window (hides the buffer).

```lua
require('nvim-kiro.chat').close_chat()
```

**Returns:** None

---

#### `toggle_chat()`

Toggle the chat window open/closed.

```lua
require('nvim-kiro.chat').toggle_chat()
```

**Returns:** None

---
<br>

### Context API

#### `get_context()`

Extract context from the current buffer.

```lua
local context = require('nvim-kiro.context').get_context()
-- Returns: "Context: file=lua/init.lua line=42 root=/home/user/project"
```

**Returns:**
- `string | nil`: Formatted context string, or `nil` for unnamed/special buffers

---
<br>

### Reload API

#### `setup()`

Initialize file reload handling with autocmds.

```lua
require('nvim-kiro.reload').setup()
```

**Sets up:**
- `autoread` option
- `FileChangedShell` autocmd
- `FocusGained`, `BufEnter`, `CursorHold`, `CursorHoldI` autocmds for `checktime`

**Returns:** None

---
<br>

## Development Workflow

### Local Development Setup

1. **Clone the repository:**
   ```bash
   git clone <repo-url> ~/projects/nvim-kiro
   ```

2. **Configure lazy.nvim for local development:**
   ```lua
   {
       dir = '~/projects/nvim-kiro',
       dev = true,
       opts = {
           debug = true  -- Enable debug logging during development
       }
   }
   ```

3. **Reload Neovim** and the plugin will load from your local directory

### Making Changes

1. **Edit plugin files** in `lua/nvim-kiro/`
2. **Reload Neovim** or use `:luafile %` to reload current file
3. **Test changes** with `:KiroChat` or Lua API calls
4. **Check logs** if `debug = true` is set

---
