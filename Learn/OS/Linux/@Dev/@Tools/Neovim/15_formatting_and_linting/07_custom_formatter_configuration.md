## Custom Formatter Configuration


### Overview

LazyVim employs conform.nvim as its primary formatting plugin, which manages code formatting across various filetypes using external tools like Prettier, Black, or Stylua. Custom configuration allows users to override defaults, add new formatters, or adjust behaviors such as autoformatting triggers. This setup integrates with LazyVim's plugin system, where modifications occur via Lua files in the `lua/plugins/` directory. Conform.nvim supports multiple formatters per filetype, with fallback mechanisms, and can incorporate LSP formatters if specified. Behaviors may differ based on installed tools, Neovim version, and conflicting plugins.

**Key Points**
- Conform.nvim is enabled by default in LazyVim for consistent formatting.
- Configuration focuses on the `formatters_by_ft` table for filetype associations and the `formatters` table for tool-specific options.
- Autoformatting occurs on save by default, but can be toggled or customized.
- External dependencies, such as npm packages or Python executables, must be installed separately for formatters to function.

### Enabling Custom Formatters

If conform.nvim is not already active (though it is by default), ensure it loads via LazyVim's extras or by adding it explicitly. For custom setups, create or edit `lua/plugins/formatting.lua` to override the plugin spec.

To add a new formatter, declare it in the dependencies if needed, then extend the `opts` table.

**Example**
```lua
-- lua/plugins/formatting.lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        lua = { "stylua" },
        python = { "black" },
        javascript = { "prettier" },
      })
      return opts
    end,
  },
}
```

After saving, run `:Lazy sync` to apply changes. Formatter availability depends on whether the tool is installed in the system path; for instance, `stylua` requires Cargo installation.

### Default Settings

LazyVim provides baseline configurations for conform.nvim, including:
- Formatters by filetype: Predefined for common languages, e.g., Lua with Stylua, JSON with jq.
- Format on save: Enabled with a 500ms timeout, falling back to LSP if the primary formatter fails.
- Log level: Set to WARN for minimal output.
- Notification: Uses vim.notify for success or error messages.

These defaults can be inspected via `:lua print(vim.inspect(require("conform").formatters_by_ft))`. Actual behavior may vary if user overrides or additional plugins like null-ls are present.

### Adding and Configuring Formatters

To introduce a custom formatter, define it in the `formatters` table with command-line arguments or extra options. Conform.nvim supports both built-in and user-defined formatters.

For example, to configure Black for Python with specific line length:

**Example**
```lua
-- lua/plugins/formatting.lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        black = {
          extra_args = { "--line-length", "88" },
        },
      })
      opts.formatters_by_ft.python = { "black" }
      return opts
    end,
  },
}
```

This applies the custom arguments during formatting. Results can differ based on the Black version installed, and errors may occur if the executable is not found.

For multiple formatters per filetype, list them in order of preference; conform.nvim attempts them sequentially.

**Example**
```lua
-- lua/plugins/formatting.lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft.javascript = { "prettierd", "prettier", "eslint_d" }
      return opts
    end,
  },
}
```

Here, `prettierd` is tried first, falling back if unavailable. Performance may impact large files if multiple attempts are needed.

### Integrating LSP Formatters

Conform.nvim can defer to LSP servers for formatting by using the "lsp_fallback" option or specifying "lsp" as a formatter.

To enable LSP fallback globally:

**Example**
```lua
-- lua/plugins/formatting.lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      }
      return opts
    end,
  },
}
```

This uses conform formatters first, then LSP if none apply. LSP availability depends on the active server for the buffer's filetype.

### Customizing Autoformatting

Autoformatting is triggered on BufWritePre by default. To disable it or add conditions, override the event handlers or set `format_on_save = false`.

For manual formatting, use the `<leader>cf` keymap provided by LazyVim, or define custom ones.

To disable autoformatting:

**Example**
```lua
-- lua/plugins/formatting.lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.format_on_save = false
      return opts
    end,
  },
}
```

Users can then format manually with `:Format` or keymaps. This change may not affect existing autocmds unless the plugin is reloaded.

### Advanced Options

For more control, adjust global options like `format_after_save` for post-save actions or define custom formatters with functions.

To create a custom formatter that runs a shell command:

**Example**
```lua
-- lua/plugins/formatting.lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters.custom_formatter = {
        command = "some-command",
        args = { "--stdin" },
        stdin = true,
      }
      opts.formatters_by_ft["*"] = { "custom_formatter" }  -- Applies to all filetypes
      return opts
    end,
  },
}
```

This assumes `some-command` is executable. Functionality may vary across operating systems due to shell differences.

### Troubleshooting

If formatting fails:
- Check logs with `:ConformInfo`.
- Verify tool installation, e.g., `which black` in the terminal.
- Conflicts with other plugins: Disable temporarily to isolate.
- [Inference]: In cases of partial formatting, buffer size or timeouts might be factors; increase `timeout_ms` if needed.

Errors can arise from misconfigured paths or unsupported filetypes.

**Conclusion**
Custom formatter configuration in LazyVim via conform.nvim enables tailored code styling, with overrides facilitating integration of preferred tools and behaviors.

**Next Steps**
- Consult conform.nvim documentation on GitHub for advanced formatter definitions.
- Install required external tools using package managers like npm or pip.
- Test configurations on sample files to verify expected outcomes.

---

