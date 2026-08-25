## Neovim Lua API Essentials


### Introduction
Neovim's Lua API provides a powerful, embedded scripting interface for configuration, plugin development, and automation. Built on Lua 5.1 (with LuaJIT for performance on supported platforms), it offers modules like `vim.api` for low-level access, `vim.fn` for Vimscript compatibility, and higher-level utilities for options, keymaps, and more. In LazyVim, which relies heavily on Lua for its modular configuration, this API is central to customizing keymaps, autocmds, and plugins without Vimscript. This guide covers essentials based on official documentation, focusing on practical usage. Note: Lua 5.1 remains the stable interface; later Lua versions are not supported. Behavior may vary with Neovim versions or LuaJIT implementations.

### Core Modules Overview
Neovim's Lua API is layered: inherited Vim functions via `vim.fn`, native Nvim calls in `vim.api`, and Lua-specific enhancements. Key modules include:
- `vim.api`: Direct C API bindings.
- `vim.fn`: Vimscript function wrappers.
- `vim.opt` and `vim.o`: Option setters.
- `vim.keymap`: Mapping utilities.
- `vim.cmd`: Command execution.
- Scoped variables: `vim.g`, `vim.b`, etc.

In LazyVim, require these implicitly via `require('vim')` or directly in config files like `lua/config/options.lua`.

**Key Points**
- All modules support type conversion between Lua and Vimscript.
- Use `require` for loading custom modules from `~/.config/nvim/lua/`.
- [Unverified]: As of 2026, no major API deprecations noted in recent searches; check `:help news` for updates.

### Setting Options
Options control editor behavior, with global (`vim.o`), buffer-local (`vim.bo`), and window-local (`vim.wo`) scopes. `vim.opt` provides a fluent, table-like interface, while `vim.o` mimics `:set`.

**Key Points**
- `vim.opt` supports append/prepend/remove operations.
- Always query with `:get()` for current values.
- In LazyVim, set options in `lua/config/options.lua` to override defaults.

**Example**
Using `vim.opt` for list-like options:
```lua
-- In lua/config/options.lua
vim.opt.wildignore:append { '*.o', '*.a' }
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
print(vim.opt.listchars:get())  -- For debugging
```

**Output**
The `get()` might return a table like `{ tab = '» ', trail = '·', nbsp = '␣' }`, depending on the option type.

Using `vim.o` for direct assignment:
```lua
vim.o.termguicolors = true
vim.bo.shiftwidth = 2  -- Buffer-local
```

Behavior may vary if options are overridden by plugins or autocmds.

### Key Mappings
`vim.keymap.set` and `del` handle mappings across modes, with options for buffers, silence, and descriptions. Preferred over legacy `nvim_set_keymap`.

**Key Points**
- Modes: 'n' (normal), 'v' (visual), etc., or tables for multiple.
- Options: `buffer`, `silent`, `expr`, `desc`.
- LazyVim uses this in `lua/config/keymaps.lua` for custom bindings.

**Example**
Basic mapping:
```lua
-- In lua/config/keymaps.lua
vim.keymap.set('n', '<leader>ff', function() require('telescope.builtin').find_files() end, { desc = 'Find files' })
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
```

For buffer-local:
```lua
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = 0, desc = 'Hover documentation' })
```

Deleting:
```lua
vim.keymap.del('n', '<leader>ff')
```

**Output**
No direct output; mappings appear in `:map` output with descriptions.

### Autocommands
Autocommands trigger actions on events like `BufEnter`. Use `nvim_create_autocmd` and groups for organization.

**Key Points**
- Events: Strings or tables (e.g., { 'BufRead', 'BufNewFile' }).
- Options: `pattern`, `command` or `callback`, `group`, `desc`.
- Groups prevent duplicates in LazyVim reloads.
- Clear with `nvim_clear_autocmds`.

**Example**
Filetype-specific:
```lua
-- In a LazyVim plugin spec or autocmds.lua
local group = vim.api.nvim_create_augroup('MyGroup', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  group = group,
  callback = function() vim.opt.wrap = true end,
  desc = 'Enable wrap for markdown',
})
```

**Output**
On entering a markdown buffer, `wrap` option activates; no visible output unless errors.

### User Commands
Define custom `:Commands` with `nvim_create_user_command`, supporting arguments and completion.

**Key Points**
- `nargs`: 0, 1, '*', etc.
- `complete`: Function for argument suggestions.
- Buffer-local variants available.
- Delete with `nvim_del_user_command`.

**Example**
Simple command:
```lua
vim.api.nvim_create_user_command('Greet', function(opts)
  print('Hello, ' .. (opts.args or 'world'))
end, { nargs = '?' })
```

With completion:
```lua
vim.api.nvim_create_user_command('Color', function(opts)
  vim.cmd('hi Error guibg=' .. opts.args)
end, {
  nargs = 1,
  complete = function() return { 'red', 'green', 'blue' } end,
})
```

**Output**
`:Greet Neovim` prints "Hello, Neovim".

### Vimscript Integration
`vim.fn` calls Vim functions; `vim.cmd` executes commands.

**Key Points**
- Use for legacy features not in native API.
- Multiline with `[[ ]]` heredoc.
- In LazyVim, minimize for pure Lua configs.

**Example**
```lua
vim.fn.mkdir('~/mydir', 'p')
vim.cmd [[
  augroup MyAug
    autocmd!
    autocmd BufWritePost * echo 'Saved!'
  augroup END
]]
```

**Output**
Creates directory if needed; autocmd echoes on save.

### Buffer and Window Management
`vim.api` functions like `nvim_list_bufs`, `nvim_open_win`.

**Key Points**
- Buffers: `nvim_buf_set_lines`, `nvim_buf_attach`.
- Windows: `nvim_win_set_config`.
- [Inference]: Useful for plugins; in LazyVim, often handled by mini.nvim or similar.

**Example**
Create floating window:
```lua
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'Hello from Lua' })
vim.api.nvim_open_win(buf, true, { relative = 'editor', width = 30, height = 5, row = 10, col = 10 })
```

**Output**
Displays a floating window with text.

### Plugin and Module Loading
Use `require` for Lua modules; lazy-load for performance.

**Key Points**
- Path: `~/.config/nvim/lua/my/module.lua` as `require('my.module')`.
- Closures defer imports.
- LazyVim uses lazy.nvim for spec-based loading.

**Example**
Lazy-load:
```lua
vim.keymap.set('n', '<leader>t', function()
  local ts = require('telescope')
  ts.extensions.projects.projects({})
end)
```

### Advanced Topics
- Variables: `vim.g.mapleader = ' '`.
- Environment: `vim.env.MYVAR`.
- [Speculation]: Future APIs may expand LSP integration, but current focus is stability.

Behavior may vary with Neovim updates or plugin conflicts.

### Conclusion
Neovim's Lua API enables modular, efficient configurations, especially in LazyVim, by replacing Vimscript with Lua for options, mappings, autocmds, and commands. Focus on scoped APIs and groups for maintainability.

### Next Steps
- Explore `:help lua-guide` for in-depth docs.
- Customize LazyVim: Edit `lua/plugins/*.lua` using these APIs.
- Experiment: Build a simple plugin with `require` and autocmds.

---

