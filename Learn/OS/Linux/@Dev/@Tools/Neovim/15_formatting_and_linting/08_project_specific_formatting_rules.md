## Project-Specific Formatting Rules


### Overview

In LazyVim, project-specific formatting rules are primarily managed through the conform.nvim plugin, which is enabled as an extra for code formatting. This allows customization of formatters like Prettier, Black, Stylua, or language-specific tools on a per-project basis, often via local configuration files such as `.editorconfig`, `editorconfig.lua`, or project-local Neovim configs. By default, LazyVim sets up conform.nvim to auto-format on save (toggle with `<leader>uf`), respecting global and local settings. For project isolation, tools like direnv or local vimrc files can override defaults without affecting other projects.

Conform.nvim integrates with LSP formatters via `lsp_fallback` and supports multiple formatters per filetype. Project-specific rules can be defined in a `.lazy.lua` or similar in the project root, or through environment variables. Note that actual behavior may vary based on installed formatters (via Mason or external), Neovim version, and conflicts with other plugins like null-ls or lsp-format.

To enable conform.nvim, use `:LazyExtras` and select "formatting.conform". Customizations go in `~/.config/nvim/lua/plugins/formatting.lua`. As of January 2026, conform.nvim v0.10+ includes improved async formatting and better error handling, with recent updates focusing on TypeScript and Rust support.

**Key Points**
- Uses conform.nvim for unified formatting interface.
- Supports .editorconfig for cross-editor consistency.
- Local overrides via project directories or gitignore-aware configs.
- Integrates with lazy.nvim for on-demand loading.
- Fallback to LSP if no dedicated formatter is available.

### Enabling and Basic Configuration

Start by enabling the conform extra in LazyVim. This sets up default formatters for common filetypes. For project-specific tweaks, create a `.nvim/lua/user/conform.lua` in your project root (if using local config loading) or use a global override that checks `vim.fn.getcwd()`.

**Example**
Global setup in `plugins/formatting.lua`:

```lua
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        javascript = { { "prettierd", "prettier" } },
      },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    },
  },
}
```

For project-specific, use a conditional:

```lua
opts.formatters_by_ft.javascript = vim.fn.getcwd():match("myproject") and { "eslint_d" } or { "prettier" }
```

[Inference]: This approach may require reloading Neovim when switching projects.

### Using .editorconfig for Rules

.editorconfig is a standard file for defining coding styles like indent size, charset, and trim_whitespace. Conform.nvim and many formatters (e.g., Prettier, Ruff) respect it automatically when present in the project root or ancestors.

**Example**
Create `.editorconfig` in project root:

```
root = true

[*]
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.{js,jsx,ts,tsx}]
indent_size = 4
quote_type = single

[*.py]
indent_size = 4
```

In Neovim, open a file; formatting via `<leader>cf` or on-save applies these rules.

**Output**
Formatted code matches specs, e.g., Python files use 4-space indents.

Note: Some formatters need explicit config to read .editorconfig; check docs, e.g., Prettier does by default.

### Project-Local Configurations

For advanced per-project rules, use Neovim's local config feature (via `--cmd 'set rtp+=$PWD/.nvim'` or plugins like localvimrc). In LazyVim, extend with a project-local `lua/plugins/local.lua` that overrides conform opts.

Alternatively, use direnv to set environment variables like `CONFORM_FORMATTER=black` and check them in your config.

**Example**
In project `.direnv`:

```
export NVIM_PROJECT_FORMATTER_PYTHON=black --line-length=120
```

Then in global config:

```lua
local py_formatter = os.getenv("NVIM_PROJECT_FORMATTER_PYTHON") or "black"
opts.formatters_by_ft.python = { py_formatter }
```

**Output**
Formatting uses custom args; e.g., longer lines in that project.

[Unverified]: Direnv integration may require the direnv.nvim plugin for seamless loading.

### Formatter-Specific Customizations

Different formatters support varying levels of project-specific config:

- **Stylua (Lua)**: Uses `stylua.toml` in project root for options like quote_style.
- **Black (Python)**: Reads `pyproject.toml` [tool.black] section.
- **Prettier (JS/TS/CSS)**: Looks for `.prettierrc`, `prettier.config.js`, or package.json prettier field.
- **Ruff (Python lint/format)**: Config in `pyproject.toml` [tool.ruff].
- **Clang-format (C/C++)**: Uses `.clang-format` file.

In conform.nvim, specify these with `formatters.stylua = { extra_args = { "--config-path", ".stylua.toml" } }` if not automatic.

**Example**
For Prettier project-specific:

Create `package.json`:

```json
{
  "prettier": {
    "singleQuote": true,
    "semi": false
  }
}
```

Conform uses it when formatting JS files.

**Output**
Output code has single quotes, no semicolons.

### Integrating with LSP and Fallbacks

Conform.nvim can fallback to LSP formatting if no formatter is defined, using `lsp_fallback = true`. For project-specific, attach different LSP servers or configs per project via Mason or local overrides.

**Example**
In project-local config:

```lua
require("lspconfig").pylsp.setup({
  settings = {
    pylsp = {
      plugins = {
        black = { enabled = true, line_length = 100 },
      },
    },
  },
})
```

Then set conform to prefer LSP for Python in that project.

Note: This may lead to inconsistent formatting if LSP and conform conflict; test thoroughly.

### Manual Formatting and Keymaps

LazyVim provides `<leader>cf` for formatting buffer/range. For project-specific, you can remap or add checks.

**Example**
Custom keymap:

```lua
vim.keymap.set("n", "<leader>cpf", function()
  require("conform").format({ async = true, lsp_fallback = true, formatters = { "project_specific_formatter" } })
end, { desc = "Project Format" })
```

### Troubleshooting and Best Practices

Common issues: Formatter not installed (use Mason), conflicts with autoformat, or ignored local configs. Use `:ConformInfo` to debug.

Best practices:
- Version control .editorconfig and tool configs.
- Use `format_after_save` for consistency.
- Test with `:Format` command.
- For monorepos, use directory-specific .editorconfig.

[Speculation]: Future conform versions may add native project detection.

**Conclusion**
Project-specific formatting rules in LazyVim empower tailored code styles across workspaces using conform.nvim and standard config files, promoting consistency without global changes.

**Next Steps**
- Enable conform extra and install formatters via `:Mason`.
- Add .editorconfig to a test project and format files.
- Explore conform.nvim docs for advanced formatters.
- Integrate with git hooks for pre-commit formatting.
- Customize for your languages in plugins file.

---

