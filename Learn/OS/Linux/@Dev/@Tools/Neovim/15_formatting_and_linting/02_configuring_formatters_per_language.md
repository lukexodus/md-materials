## Configuring Formatters Per Language


### Overview

LazyVim handles code formatting through the `conform.nvim` plugin, which serves as the default formatter since the 10.x release. This setup allows for per-language configuration, enabling users to specify formatters tailored to specific filetypes. Conform.nvim supports multiple formatters, distinguishing between primary (one active at a time, such as conform, none-ls, or LSP) and secondary (multiple, like eslint for targeted fixes). LazyVim automatically selects the primary formatter based on available sources and priorities, falling back to LSP if needed.

Formatting can be triggered manually with `<leader>cf` (format buffer) or `<leader>cF` (format injected languages), and auto-formatting on save is enabled by default. Behavior may vary depending on the installed formatters, project structure, and whether tools like Mason have installed the required binaries (e.g., stylua for Lua).

Users can disable auto-formatting globally with `vim.g.autoformat = false` in `init.lua` or per-buffer with `vim.b.autoformat = false`. For diagnostics, use `:LazyFormatInfo` to view active formatters for the current buffer.

**Key Points**
- Per-language setup via `formatters_by_ft` table.
- Custom formatter options in `formatters` table.
- Supports cloud-based or local formatters, with conditions for activation (e.g., presence of config files).
- Integration with `nvim-cmp` and LSP for seamless workflow.
- Prior to 10.x, none-ls.nvim was default; now opt-in via `lsp.none-ls` extra.

### Installing and Enabling Formatters

Formatters are managed via Mason or external package managers. For example, install stylua for Lua with `:MasonInstall stylua`. LazyVim's formatting plugin is enabled by default, but you can customize it in `lua/plugins/formatting.lua`.

To add or modify, create or edit `lua/plugins/formatting.lua`:

```lua
return {
  {
    "stevearc/conform.nvim",
    opts = {
      -- Your custom options here
    },
  },
}
```

Avoid overriding `plugin.config` directly, as it may disrupt LazyVim's integration.

### Per-Language Configuration

The core of per-language setup is the `formatters_by_ft` table, which maps filetypes to lists of formatter names. LazyVim provides minimal defaults, allowing users to extend them. When multiple formatters are listed for a filetype, conform.nvim applies them in sequence.

Default `formatters_by_ft` from LazyVim:

```lua
formatters_by_ft = {
  lua = { "stylua" },
  fish = { "fish_indent" },
  sh = { "shfmt" },
}
```

To configure for additional languages, merge your settings:

```lua
opts = {
  formatters_by_ft = {
    python = { "black", "isort" },
    javascript = { "prettierd", "eslint_d" },
    json = { "jq" },
    markdown = { "markdownlint" },
    ["_"] = { "trim_whitespace" }, -- Applies to all filetypes
  },
}
```

Here, for Python, `black` formats code style, and `isort` sorts imports. Behavior may differ if formatters conflict; test in small files.

**Example**
For a Python project, add to `lua/plugins/formatting.lua`:

```lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      vim.list_extend(opts.formatters_by_ft.python or {}, { "black" })
      return opts
    end,
  },
}
```

Install `black` via pip or Mason if available. Open a `.py` file, save, and observe formatting.

### Customizing Formatter Options

The `formatters` table allows overriding or defining options for each formatter, merged with builtins. This includes extra args, conditions, or environment variables.

Example from defaults:

```lua
formatters = {
  injected = { options = { ignore_errors = true } },
}
```

Custom examples:

- Conditional activation for `dprint` (e.g., only if `dprint.json` exists):

```lua
dprint = {
  condition = function(ctx)
    return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
  end,
},
```

- Extra args for `shfmt`:

```lua
shfmt = {
  prepend_args = { "-i", "2", "-ci" },
},
```

- For `prettier`, specify config file priority:

```lua
prettier = {
  extra_args = { "--config-precedence", "prefer-file" },
},
```

These options ensure formatters respect project-specific styles. If a conditioner fails, the formatter skips without error.

**Example**
To customize `black` for Python with line length:

```lua
formatters = {
  black = {
    prepend_args = { "--line-length", "88" },
  },
},
```

Apply by restarting Neovim or sourcing the config.

**Output**
After formatting a Python file with long lines, they wrap to 88 characters, visible in the buffer.

### Advanced Formatting Options

Global format options are set in `default_format_opts`:

```lua
default_format_opts = {
  timeout_ms = 3000,
  async = false,
  quiet = false,
  lsp_format = "fallback",
},
```

Adjust `timeout_ms` for large files. For async formatting, set `async = true`, but note potential UI glitches.

Integrate secondary formatters like `eslint` for linting-fixes:

```lua
formatters_by_ft = {
  javascript = { { "prettierd", "prettier" }, "eslint_d" },
},
```

Here, prettier handles style, eslint fixes issues. LazyVim prioritizes conform as primary.

For multiple primaries, use `:LazyFormatInfo` to inspect and switch if needed via custom keymaps.

[Inference]: With evolving Neovim APIs, async options might improve stability in future releases.

### Integrating with Other Plugins

Combine with `nvim-lint` for linting or `none-ls.nvim` (via extra) for additional sources. For LSP fallback, ensure servers like `lua_ls` have formatting capabilities enabled.

Example: In `lua/plugins/lsp.lua`, disable LSP formatting to rely solely on conform:

```lua
servers = {
  lua_ls = {
    settings = {
      Lua = {
        format = { enable = false },
      },
    },
  },
},
```

This avoids duplicate formatting.

### Troubleshooting

If formatting fails:
- Check `:LazyFormatInfo` for active formatters.
- Verify installation with `:Mason`.
- Inspect logs with `:ConformInfo`.
- Common issues: Missing binaries, timeouts on large files, or conflicts with auto-save plugins.
- Behavior may vary across OS; ensure PATH includes formatter executables.

For reverted changes post-save, disable autoformat temporarily.

**Conclusion**
Configuring formatters per language in LazyVim offers flexibility for multilingual projects, enhancing code consistency.

**Next Steps**
- Enable `lsp.none-ls` extra for legacy support.
- Explore conform.nvim docs for advanced formatters.
- Test configurations in a sample multi-language repo.

---

