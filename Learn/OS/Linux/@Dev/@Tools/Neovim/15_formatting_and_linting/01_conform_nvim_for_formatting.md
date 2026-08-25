## conform.nvim for Formatting


### Overview

conform.nvim is a lightweight yet powerful formatter plugin designed to handle code formatting in Neovim. It supports asynchronous formatting, preserves extmarks and folds by applying minimal diffs using LSP utilities, and can fix issues with LSP formatters that replace entire buffers. It enables range formatting even for tools that do not natively support it and handles injected language formatting in files like markdown. In LazyVim, conform.nvim is integrated as the core formatting solution, providing seamless setup for format-on-save and manual formatting. It requires Neovim 0.10 or later, with backward compatibility available through specific branches for older versions. As of January 2026, the latest release is v9.1.0 (August 22, 2025), which includes enhancements to formatter handling, LSP integration, and overall stability. Behavior may vary depending on the installed formatters, Neovim version, and system environment.

### Enabling in LazyVim

LazyVim includes conform.nvim as part of its core plugins for formatting, so it is enabled by default in standard installations. No additional extras are required, but users can customize it without overriding the plugin's core configuration directly to avoid breaking LazyVim's formatting logic.

To confirm or adjust:

1. Check your LazyVim configuration; conform.nvim is typically loaded via the plugins spec.
2. If starting from a minimal setup, add it manually in `lua/plugins/formatting.lua` or similar.

**Example**
```lua
-- In lua/plugins/formatting.lua
return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },  -- Lazy loading
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { { "prettierd", "prettier" } },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    },
  },
}
```

This setup ensures formatters load only when needed, integrating with LazyVim's lazy-loading mechanism.

**Key Points**
- Automatically handles format-on-save if configured.
- Supports lazy-loading to improve startup times.
- Install required formatters via Mason or system package managers (e.g., `:MasonInstall stylua`).

### Basic Configuration

Configuration is done through the `setup` function, which accepts a table defining formatters by filetype, global options, and behaviors. In LazyVim, extend the defaults by providing an `opts` table in the plugin spec.

**Key Points**
- `formatters_by_ft`: Maps filetypes to lists of formatters; runs sequentially.
- `format_on_save`: Enables automatic formatting before saving; supports timeout and LSP fallback.
- `lsp_format`: Controls LSP usage ("never", "fallback", "prefer", "first", or "last").
- `notify_on_error`: Shows notifications for errors (default: true).
- Use functions for dynamic formatters, e.g., based on file content.

**Example**
```lua
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = function(bufnr)
      if require("conform").get_formatter_info("ruff_format", bufnr).available then
        return { "ruff_format" }
      else
        return { "isort", "black" }
      end
    end,
    ["_"] = { "trim_whitespace" },  -- Fallback for all filetypes
  },
  format_after_save = { lsp_format = "fallback" },
  log_level = vim.log.levels.DEBUG,  -- For troubleshooting
})
```

This may log detailed information to a file for debugging, with paths viewable via `:ConformInfo`.

### Supported Formatters

conform.nvim includes built-in configurations for over 200 formatters across various languages and tools. These can be extended or overridden.

**Key Points**
- Built-in: stylua (Lua), black/isort/ruff_format (Python), rustfmt (Rust), prettier/prettierd (JS/TS), clang-format (C/C++), gofmt (Go), sqlfmt (SQL), yamlfmt (YAML), shfmt (Shell), taplo (TOML), and more.
- Custom formatters: Define with `command`, `args`, `range_args`, `stdin`, `condition`, etc.
- Inheritance: Create variants, e.g., `deno_fmt_markdown` inherits from `deno_fmt` with adjusted args.
- Fallbacks: Use LSP if no formatter is available via `lsp_format = "fallback"`.
- Injected formatting: For code blocks in markdown, etc., using treesitter queries.

To list all: `require("conform").list_all_formatters()`.

**Example**
Overriding a formatter:
```lua
formatters = {
  black = {
    extra_args = { "--fast" },
  },
  my_custom = {
    command = "custom_formatter",
    args = { "$FILENAME" },
    stdin = true,
  },
}
```

[Inference: Additional formatters like biome can be integrated by defining them manually or via community configs.]

### Usage and API

The API provides functions for formatting buffers, ranges, and querying formatters, modeled after `vim.lsp.buf.format()`.

**Key Points**
- `format(opts, callback)`: Main function; supports async, dry_run, range.
- Synchronous by default; set `async = true` for non-blocking.
- Range formatting: Works in visual mode or with specified lines.
- Autocmd for save: Use `BufWritePre` or built-in `format_on_save`.
- Keymaps: In LazyVim, often bound to `<leader>cf` for buffer format.
- `formatexpr()`: Set as `vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"` for `gq` operator support.

**Example**
Manual format keymap:
```lua
vim.api.nvim_set_keymap("n", "<leader>f", "", {
  callback = function()
    require("conform").format({ async = true, lsp_format = "fallback" })
  end,
  desc = "Format buffer",
})
```

For range:
```lua
require("conform").format({ range = { start = { line = 1, character = 0 }, ["end"] = { line = 10, character = 0 } } })
```

**Output**
After formatting a Python file with black, the code may have consistent spacing and sorted imports, with notifications if errors occur.

### Advanced Customization

Extend functionality with custom options, conditions, and integrations.

**Key Points**
- `stop_after_first`: Stops after the first successful formatter (useful for fallbacks like prettierd → prettier).
- Environment variables: Set via `env` in formatter config.
- Temp files: For non-stdin tools using `tempfile_suffix` or `tempfile_dir`.
- Conditions: Skip formatting based on file properties, e.g., exclude large files.
- LSP hooks: Automatically converts full replacements to diffs.
- Toggle format-on-save: Use global variables or autocmds.

**Example**
Conditional formatter:
```lua
formatters = {
  injected = { options = { ignore_errors = true } },
  stylua = {
    condition = function(_, ctx)
      return vim.fs.basename(ctx.filename) ~= "README.md"
    end,
  },
}
```

For biome integration (as seen in recent discussions):
```lua
formatters_by_ft = {
  javascript = { "biome" },
}
```
Requires biome installed and defined in formatters.

### Practical Usage Example

In a Lua file, type unformatted code and save. conform.nvim runs stylua, applying indents and styles.

**Example**
Before:
```lua
local function test()
print("hello")
end
```

After save (with format_on_save):
```lua
local function test()
  print("hello")
end
```

**Output**
The buffer updates in place, preserving cursor position.

### Troubleshooting

Use `:ConformInfo` for config details, available formatters, and log paths.

**Key Points**
- No formatting: Check if formatter is installed and available via `get_formatter_info()`.
- Timeout errors: Increase `timeout_ms`; noted in v8.0.0+ for some formatters.
- LSP conflicts: Adjust `lsp_format` order.
- Debug: Set `log_level = vim.log.levels.TRACE` and inspect logs.
- [Unverified]: If handle closing errors occur, it may relate to timeouts; check recent issues.

**Example**
```lua
:lua print(vim.inspect(require("conform").list_formatters_to_run()))
```
Lists formatters for current buffer.

**Conclusion**
conform.nvim offers efficient, customizable formatting that integrates well with LazyVim, supporting a wide range of tools and LSP fallback for reliable code maintenance.

**Next Steps**
- Review the conform.nvim README for new formatters.
- Add custom formatters like csharpier for specific languages.
- Explore community configs for advanced setups, such as auto-import integration.

---

