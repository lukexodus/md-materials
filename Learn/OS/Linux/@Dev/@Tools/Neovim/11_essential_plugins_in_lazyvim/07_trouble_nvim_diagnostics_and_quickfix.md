## Trouble.nvim - Diagnostics and Quickfix


### Introduction

Trouble.nvim is a Neovim plugin developed by folke that provides a visually appealing and configurable interface for displaying various lists, including LSP diagnostics, quickfix items, location lists, references, and more. In the context of LazyVim, it enhances the default Neovim experience by offering a tree-like view for these elements, making it easier to navigate and manage code issues or search results. The plugin supports modes for diagnostics and quickfix, allowing users to toggle windows that show errors, warnings, or build outputs in a structured format.

As of January 2026, the latest version is v3.7.1 (released February 2025), which includes a complete rewrite for improved performance, multi-window support, and tree views. LazyVim includes Trouble.nvim as part of its editor plugins, with predefined configurations and keymaps for seamless integration. Behavior may vary depending on Neovim version (requires 0.8+), installed LSP servers, or conflicting plugins.

### Integration in LazyVim

In LazyVim, Trouble.nvim is loaded via the plugin manager in `lua/lazyvim/plugins/editor.lua` or similar core files. It is not an optional extra but part of the standard setup, with defaults that can be overridden in user configurations like `lua/plugins/editor.lua`. LazyVim sets up Trouble with modes for LSP-related lists and integrates it optionally into the lualine statusline for displaying symbols.

Key integration points:
- Loaded on command "Trouble".
- Default options include custom modes, such as LSP windows positioned to the right.
- Conditional statusline component: If `vim.g.trouble_lualine` is true (default in some setups), it adds a symbols section to lualine using `trouble.statusline({ mode = "symbols", ... })`.
- LazyVim merges user opts with defaults, e.g., enabling diagnostic signs.

To customize in LazyVim, add to your plugin spec:
```lua
-- lua/plugins/editor.lua (example)
return {
  {
    "folke/trouble.nvim",
    opts = {
      use_diagnostic_signs = true,  -- Use LSP signs in the list
      modes = {
        lsp = {
          win = { position = "right" },
        },
      },
    },
  },
}
```

This overrides defaults; run `:Lazy sync` to apply. [Inference: Based on LazyVim's plugin merging, user opts take precedence, but complex tables like modes may require full replacement.]

### Features for Diagnostics

Trouble.nvim's diagnostics mode aggregates LSP diagnostics across the workspace or current buffer, displaying them in a filterable list. Each item includes:
- Severity icon (e.g., error, warning) colored via highlight groups like DiagnosticError.
- File path, line/column position.
- Source (e.g., LSP server name).
- Message, supporting multiline when enabled.

Features include:
- Filtering: By severity (cycle with 's' key), buffer (toggle with 'gb'), or custom filters like {buf=0} for current buffer.
- Sorting: Configurable sorters for priority ordering.
- Navigation: Jump to items with \<cr>, preview with 'p', or delete with 'dd'.
- Auto-refresh: Updates the list on diagnostic changes if auto_refresh=true.
- Tree view: Hierarchical display if diagnostics are grouped (e.g., by file).

Commands like `Trouble diagnostics toggle` open/close the window. In LazyVim, this is bound to \<leader>xx by default.

Behavior may vary with LSP server responsiveness or if diagnostics are hidden via Neovim APIs.

### Features for Quickfix and Loclist

For quickfix (global) and loclist (window-local), Trouble.nvim replaces Neovim's built-in :copen/:lopen with a more user-friendly interface. It shows:
- Item text or error message.
- File, line/column.
- Any additional columns from the quickfix source (e.g., grep results).

Key features:
- Toggle with `Trouble qflist toggle` or `Trouble loclist toggle`.
- Deletion: Remove items with 'd' in visual mode or 'dd' on lines.
- Folding: Collapse/expand groups using zo/zc/za, with indent guides.
- Integration with external tools: Displays results from Telescope or grep directly.
- Multi-window: Open separate Trouble windows for quickfix and diagnostics simultaneously.

In LazyVim, quickfix is bound to \<leader>xQ and loclist to \<leader>xL. This mode supports the same preview, jump, and filter options as diagnostics.

[Unverified: In v3+, quickfix items may include custom icons if sourced from LSP or plugins like null-ls.]

### Configuration Options

Trouble.nvim's setup is done via `require("trouble").setup(opts)`, with LazyVim providing some defaults. Key options relevant to diagnostics and quickfix:

- `auto_refresh = true`: List updates on changes.
- `focus = false`: Doesn't steal focus on toggle.
- `win = { position = "bottom", size = 10 }`: Default window layout (bottom split).
- `modes = { diagnostics = { ... }, qflist = { ... } }`: Per-mode settings, e.g., filters or window positions.
- `keys`: Custom keymaps, e.g., { ["\<cr>"] = "jump" }.
- `icons`: Customize severity/kind icons, using Nerd Fonts.
- `throttle`: Debounce timings for performance (e.g., refresh=20ms).

Full default opts include multiline=true for messages and max_items=200 to limit large lists.

In LazyVim, extend via opts merging:
```lua
opts = {
  auto_preview = true,  -- Preview on hover
  modes = {
    diagnostics = {
      filter = { severity = vim.diagnostic.severity.ERROR },  -- Show only errors
    },
  },
}
```

Highlight groups like TroubleText or TroubleIndent can be customized in colorscheme files.

### Commands and Keymaps

#### Commands
- `Trouble [mode] [action] [options]`: E.g., `Trouble diagnostics toggle filter.buf=0` for buffer diagnostics.
- Modes: diagnostics, qflist, loclist.
- Actions: toggle, open, close, refresh.
- Options: focus=true, win.position=right, filter.severity=1 (error).

#### Keymaps (LazyVim Defaults)
- \<leader>xx: Toggle workspace diagnostics.
- \<leader>xX: Toggle buffer diagnostics.
- \<leader>xQ: Toggle quickfix.
- \<leader>xL: Toggle loclist.

In-window keymaps (defaults):
- \<cr>: Jump to item.
- o: Jump and close.
- }} / [[ : Next/prev item.
- s: Cycle severity filter (diagnostics).
- gb: Toggle buffer filter.
- ? : Help.
- q: Close.

Customize by overriding keys in opts.

### Practical Examples

**Example**: Toggling diagnostics for the current buffer.

Run `:Trouble diagnostics toggle filter.buf=0` or use \<leader>xX. This opens a bottom window listing issues, with previews on hover if enabled.

**Output**: A list like:
- [E] file.lua:10:1 - lua_ls: Undefined variable
- [W] file.lua:15:5 - lua_ls: Unused function

Navigate with j/k, jump with \<cr>.

**Example**: Custom quickfix for grep results.

After `:vimgrep pattern **/*.lua`, run `:Trouble qflist toggle`. Filter with custom commands or keys.

```lua
-- In config: Add to autocmds.lua for auto-open on quickfix population
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  callback = function()
    vim.cmd("Trouble qflist open")
  end,
})
```

This may open Trouble automatically after searches; disable if performance impacts large results.

**Example**: Statusline integration in LazyVim.

If enabled, lualine shows symbols like "Class: MyClass" from Trouble's symbols mode.

```lua
-- Enable in options.lua
vim.g.trouble_lualine = true
```

**Output**: In statusline: {kind_icon}SymbolName

### Advanced Usage

- Multi-window: `Trouble diagnostics open` and `Trouble qflist open` side-by-side.
- API: Use Lua like `require("trouble").toggle("diagnostics")` in scripts.
- Filters/Sorters: Define custom functions, e.g., sort by severity then line.
- Preview: Set to float with `preview.type = "float"`.

[Speculation: Future updates may add AI-assisted filtering; monitor releases.]

**Key Points**
- Enhances diagnostics and quickfix with tree views and filters.
- Integrated in LazyVim with \<leader>x* keymaps.
- Configurable via opts, with defaults for performance.
- Supports previews, jumps, and deletions.

**Conclusion**
Trouble.nvim transforms Neovim's list management into an efficient tool for handling diagnostics and quickfix in LazyVim, reducing workflow friction through customizable UIs.

**Next Steps**
- Install or update via :Lazy sync.
- Explore full modes with :Trouble help.
- Customize filters for specific workflows in opts.

---

