## keymaps.lua - Custom Keybinding Definitions


### Overview

In LazyVim, the `keymaps.lua` file serves as the central location for defining custom keybindings. This file allows users to override default mappings or add new ones tailored to their workflow. LazyVim structures its configuration to load this file automatically if it exists in the `lua/config/` directory within your Neovim setup. Keybindings defined here integrate with LazyVim's plugin ecosystem, ensuring compatibility with features like which-key for discoverability.

Keybindings are set using Neovim's `vim.keymap.set` API, which provides flexibility for different modes, options, and commands. This approach supports Lua-based configurations, enabling dynamic and conditional mappings.

**Key Points**
- Custom keymaps enhance productivity by remapping commands to preferred shortcuts.
- LazyVim encourages modular configuration; `keymaps.lua` is optional but recommended for user-specific changes.
- Behavior may vary based on installed plugins or Neovim version; test mappings in your environment.

### File Location and Setup

To use `keymaps.lua`, create it in `~/.config/nvim/lua/config/keymaps.lua` (on Unix-like systems; adjust for Windows). LazyVim's starter template includes this structure, but if starting from scratch:

1. Ensure LazyVim is installed.
2. Create the `lua/config/` directory if missing.
3. Add `keymaps.lua` with your definitions.

LazyVim loads this file during initialization via its config loader. No explicit require is needed in `init.lua`.

**Example**
```lua
-- lua/config/keymaps.lua
-- This is an empty starter file; add your mappings here.
```

### Syntax for Defining Keymaps

Keymaps are defined using `vim.keymap.set(mode, lhs, rhs, opts)`, where:
- `mode`: A string or table specifying the mode (e.g., 'n' for normal, 'i' for insert).
- `lhs`: The left-hand side, or the key sequence to trigger the mapping (e.g., '\<leader>ff').
- `rhs`: The right-hand side, or the action to execute (e.g., a function, command, or string).
- `opts`: An optional table for settings like `{ desc = "Description" }` for which-key integration, `{ silent = true }` to suppress output, or `{ noremap = true }` for non-recursive mapping (default in Neovim 0.7+).

Modes include:
- 'n': Normal
- 'i': Insert
- 'v': Visual
- 'x': Visual (exclude select)
- 's': Select
- 't': Terminal
- 'c': Command-line
- 'o': Operator-pending
- '' (empty string): Applies to normal, visual, select, and operator-pending modes.

For multiple modes, use a table like `{'n', 'v'}`.

**Key Points**
- Use `<leader>` for mappings prefixed by the leader key (default: space in LazyVim).
- Escape special keys: `<CR>` for Enter, `<Esc>` for Escape, `<C-a>` for Ctrl+A.
- LazyVim predefines many `<leader>`-based mappings; check defaults via `:LazyVim keymaps` or documentation to avoid conflicts.

**Example**
```lua
-- Basic normal mode mapping
vim.keymap.set('n', '<leader>ex', vim.cmd.Ex, { desc = "Open netrw explorer" })

-- Multi-mode with options
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y', { desc = "Yank to system clipboard", silent = true })
```

### Common Use Cases

#### Overriding Default Keymaps

LazyVim's defaults can be modified by redefining them in `keymaps.lua`. For instance, change the buffer navigation keys.

**Example**
```lua
-- Override default next buffer
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { desc = "Next buffer" })
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', { desc = "Previous buffer" })
```

#### Plugin-Specific Mappings

Integrate with plugins like Telescope or LSP. LazyVim often provides hooks, but custom mappings can enhance them.

**Example**
```lua
-- Telescope find files with leader ff
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = "Find files" })
```

#### Conditional or Function-Based Mappings

Use Lua functions for complex logic, such as checking file types.

**Example**
```lua
-- Function to toggle line numbers
local function toggle_numbers()
  vim.wo.number = not vim.wo.number
  vim.wo.relativenumber = not vim.wo.relativenumber
end

vim.keymap.set('n', '<leader>tn', toggle_numbers, { desc = "Toggle line numbers" })
```

#### Leader Key Customization

If changing the leader key, set it before mappings: `vim.g.mapleader = ','` in `options.lua`, then use the new leader in `keymaps.lua`.

### Options and Best Practices

Keymap options include:
- `desc`: String for which-key popup.
- `silent`: Boolean to hide command output.
- `expr`: Boolean for RHS as an expression.
- `buffer`: Boolean or number for buffer-local mappings.
- `nowait`: Boolean to not wait for more keys.

Best practices:
- Group related mappings (e.g., all buffer-related together) with comments.
- Use which-key integration via `desc` for better UX.
- Avoid shadowing essential Vim keys unless intentional.
- Test for conflicts: Use `:verbose map <key>` to inspect existing mappings.
- Keep mappings mnemonic (e.g., `<leader>sv` for split vertical).

For large configs, consider splitting into multiple files and requiring them in `keymaps.lua`.

[Inference]: Extensive keymap sets might impact startup time slightly, depending on Neovim's LuaJIT optimizations.

### Examples of Advanced Keymaps

#### LSP Integration

Map LSP actions like hover or diagnostics.

**Example**
```lua
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "LSP Hover" })
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { desc = "Goto Definition" })
```

**Output**
Pressing `K` in normal mode over a symbol shows documentation in a floating window.

#### Terminal Mode Mappings

Escape terminal with a custom key.

**Example**
```lua
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = "Exit terminal mode" })
```

#### Visual Mode Yank and Paste

Enhance clipboard interactions.

**Example**
```lua
vim.keymap.set('v', '<leader>p', '"_dP', { desc = "Paste without yanking" })
```

### Troubleshooting Common Issues

- **Conflict Detection**: If a mapping doesn't work, run `:map <key>` to see overrides.
- **Mode-Specific Failures**: Ensure the mode matches usage; behavior may vary in different buffers.
- **Plugin Loading Order**: Keymaps defined before plugins load might be overwritten; LazyVim handles this via lazy-loading.
- **Debugging**: Add `print("Mapping triggered")` in RHS functions for verification.

If issues persist, check LazyVim's GitHub issues or discourse for similar reports.

### Integration with Other Config Files

`keymaps.lua` interacts with `options.lua` (for global settings) and plugin specs in `plugins/`. For example, disable a default plugin keymap in its spec and redefine in `keymaps.lua`.

**Example**
In `plugins/editor.lua`:
```lua
return {
  { "which-key.nvim", opts = { -- adjustments } },
}
```
Then customize in `keymaps.lua`.

**Conclusion**
Custom keybindings in `keymaps.lua` empower personalized Neovim experiences within LazyVim. Start simple, iterate based on usage, and leverage community resources for inspiration.

**Next Steps**
- Review LazyVim's default keymaps documentation.
- Experiment by adding 2-3 custom mappings and testing in a session.
- Explore which-key plugin for visual keymap trees.

---

