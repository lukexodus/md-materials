## Format-on-Save Setup


### Overview of Formatting System

In LazyVim, formatting is managed primarily through the conform.nvim plugin, which handles code formatting using various formatters like Prettier, Black, or LSP-based ones. Format-on-save refers to automatically applying these formatters when saving a buffer, ensuring consistent code style without manual intervention. This feature is enabled by default in LazyVim for many filetypes, but can be customized or disabled per buffer, project, or globally. It integrates with LSP for language-specific formatting and can fall back to other tools. Performance impacts, such as slight save delays, may occur in large files, and behavior can vary based on installed formatters and Neovim version.

### Installation and Setup

LazyVim includes conform.nvim as a core plugin, so no additional installation is typically needed. If starting from a minimal setup, ensure it's included via lazy.nvim.

To confirm or add in `lua/plugins/conform.lua`:

```lua
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    -- Default options here
  },
}
```

Run `:Lazy sync` to install if missing. For formatters, LazyVim uses mason.nvim to manage tools like stylua for Lua or prettier for web languages. Install them via `:Mason` or auto-install in conform opts.

[Inference: Based on standard LazyVim configurations as of 2026; check `:Lazy` for your setup.]

### Key Features

- **Automatic Formatting**: Triggers on `:w` or BufWritePre autocmd.
- **Formatter Selection**: Prioritizes LSP if available, then external tools.
- **Fallbacks**: If a formatter fails, it can skip or try alternatives.
- **Partial Formatting**: Supports range formatting for selected text.
- **Notifications**: Uses mini.notify or similar for success/failure messages.

**Key Points**
- Supports asynchronous formatting to minimize UI blocking.
- Integrates with git for respecting .gitignore in project-wide ops.
- Can be toggled per buffer with `vim.b.autoformat = false`.

### Configuration Options

Conform.nvim's options are set in the plugin spec. LazyVim provides defaults, but overrides go in `lua/plugins/conform.lua`.

Key options:

- `format_on_save`: Enables the feature with timeout and LSP fallback.
- `formatters_by_ft`: Maps filetypes to formatters.
- `format_after_save`: Alternative for post-save formatting.

Example default-like config:

```lua
opts = {
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    javascript = { { "prettierd", "prettier" } },
    -- Add more as needed
  },
}
```

Increase `timeout_ms` for complex formatters to avoid skips. Set `lsp_fallback = false` to rely only on specified tools.

Behavior may vary if formatters are not installed or if LSP conflicts arise.

### Usage and Keybindings

With setup complete, format-on-save activates automatically on save. Manual formatting uses `<leader>cf` (format buffer) or `<leader>cF` (format range in visual mode) by default in LazyVim.

To toggle globally: Set `vim.g.autoformat = false` in `lua/config/options.lua`.

Per buffer: `:lua vim.b.autoformat = false`.

Check status with `:ConformInfo`.

**Example**

For a Python file:

1. Install black via Mason: `:MasonInstall black`.
2. Edit a messy file:

```python
def func():
  print("hello")
x=1
```

3. Save (:w) – it formats to:

```python
def func():
    print("hello")

x = 1
```

If timeout occurs, a notification may appear, and the file saves unformatted.

### Integrating with LSP and Other Plugins

Conform.nvim complements LSP formatting (e.g., from lua_ls or pyright). Set `lsp_fallback = true` to use LSP when no formatter is specified.

For null-ls/none-ls users (older setups), migrate to conform for better performance.

Combine with treesitter for accurate parsing or auto-save plugins for seamless workflows.

Potential issues: LSP might override if not configured properly; use `formatters_by_ft` to prioritize.

[Unverified: Integration may change with plugin updates; test configurations.]

### Troubleshooting Common Issues

- **Formatting not triggering**: Check `vim.g.autoformat` and ensure formatters are installed. Run `:ConformInfo`.
- **Timeouts**: Increase `timeout_ms` or use faster formatters like prettierd.
- **Inconsistent styles**: Configure formatter options in `formatters` table, e.g., for stylua: `{ extra_args = { "--indent-width", "2" } }`.
- **Errors on save**: Inspect logs with `:messages` or set `log_level = vim.log.levels.DEBUG`.
- **Disabled in some files**: Git submodules or large files may skip; adjust thresholds.

Behavior may differ across filetypes or with version mismatches.

### Advanced Customization

For project-specific setups, use direnv or local .nvim.lua files to override opts.

Example: Async formatting hook:

```lua
opts = {
  format_after_save = function(bufnr)
    -- Custom logic here
  end,
}
```

Add custom formatters:

```lua
formatters = {
  my_formatter = {
    command = "custom-tool",
    args = { "--stdin" },
  },
}
```

Bind to autocmds for specific events.

**Example**

Project-local disable in .nvim.lua:

```lua
vim.g.autoformat = false
```

### Best Practices

- Install only necessary formatters via Mason to reduce overhead.
- Use LSP fallback for unconfigured languages.
- Test in small files before large projects to catch config issues.
- Combine with linting (e.g., via nvim-lint) for comprehensive checks on save.

**Conclusion**

Format-on-save in LazyVim streamlines code maintenance by automating style enforcement through conform.nvim, with flexible options for various workflows.

**Next Steps**

- Review conform.nvim docs on GitHub for advanced formatters.
- Experiment with toggles in a sample project.
- Explore LazyVim extras for related plugins like editorconfig integration.

---

