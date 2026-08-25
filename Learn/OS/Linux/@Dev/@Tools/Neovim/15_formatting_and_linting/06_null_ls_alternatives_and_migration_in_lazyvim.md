## Null-ls Alternatives and Migration in LazyVim


### Introduction

Null-ls.nvim was a popular Neovim plugin that allowed integration of non-LSP tools for diagnostics, formatting, code actions, and more by acting as an LSP server using Lua. It was archived in 2023, prompting the community to develop alternatives. The primary options include none-ls.nvim, a direct community fork, and a modular approach using conform.nvim for formatting combined with nvim-lint for diagnostics. In LazyVim, the default setup has evolved to use conform.nvim and nvim-lint as core components for formatting and linting, respectively, while none-ls is available as an optional extra for additional features like code actions. This shift provides better separation of concerns and potentially improved performance, though actual results may vary depending on configuration and tools used.

**Key Points**
- Null-ls archiving led to forks and new plugins; migration is recommended for ongoing support.
- None-ls maintains compatibility with null-ls configurations.
- Conform.nvim handles formatting asynchronously with fallback options.
- Nvim-lint focuses on diagnostics, triggered on events like buffer writes.
- LazyVim's migration emphasizes updating the config and disabling outdated plugins.

### Alternatives to Null-ls

#### None-ls.nvim
None-ls.nvim is a reloaded version of null-ls, maintained by the community to continue its functionality without changes to the API or behavior. It supports injecting LSP features like diagnostics, formatting, code actions, hover, and completions via Lua, using built-in sources or custom ones.

**Key Points**
- Direct drop-in replacement for null-ls.
- Tested against stable Neovim versions; supports HEAD on a best-effort basis.
- Includes helpers for CLI tools and LSP format conversion.
- Performance typically faster than alternatives due to pure Lua implementation, though this may vary.

**Example**
To install and configure in a custom plugin file (e.g., `lua/plugins/none-ls.lua`):

```lua
return {
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.diagnostics.eslint,
        },
      })
    end,
  },
}
```

This sets up basic formatting for Lua and diagnostics for JavaScript.

#### Conform.nvim for Formatting
Conform.nvim is a lightweight formatter plugin that calculates minimal diffs and applies them using Neovim's builtin LSP format utilities. It's the default in LazyVim for handling formatting across filetypes.

**Key Points**
- Supports multiple formatters per filetype, with options for sequential execution or fallbacks.
- Configurable via `formatters_by_ft` and custom formatter options.
- Integrates with LazyVim's `<leader>cf` for manual formatting and autoformatting on save (toggle with `<leader>uf`).
- Behavior may differ if multiple formatters are available or if tools like Prettier are installed.

**Example**
Extend LazyVim's default in `lua/plugins/formatting.lua`:

```lua
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { { "prettierd", "prettier" } },
      },
    },
  },
}
```

Here, double brackets mean try `prettierd` first, fallback to `prettier`.

**Output**
Formatting a Lua file might result in adjusted indentation and spacing, with no visible output unless errors occur (shown via diagnostics).

#### Nvim-lint for Diagnostics
Nvim-lint runs linters asynchronously and reports results as LSP diagnostics. It's LazyVim's default for linting, triggered on specific events.

**Key Points**
- Configured via `linters_by_ft` for filetype-specific linters.
- Supports conditional linters based on file presence (e.g., config files).
- Events include buffer write, read, and insert leave.
- Use `*` for all filetypes or `_` for unspecified ones.
- Diagnostics appear in the sign column; toggle with `<leader>uL`.

**Example**
Customize in `lua/plugins/linting.lua`:

```lua
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = { "vale" },
        dockerfile = { "hadolint" },
      },
    },
  },
}
```

This adds linting for Markdown and Dockerfiles.

**Output**
Linting might display warnings like "Unused variable" in the diagnostic popup on hover.

#### Other Alternatives
- Efm-langserver: An external LSP server for non-LSP tools; more complex setup but flexible.
- Formatter.nvim: Focused on formatting, but less feature-rich than conform.
- These are less common in LazyVim due to built-in support for conform and nvim-lint.

### Migration Process in LazyVim

LazyVim initially used null-ls, switched to none-ls in 2023, and later migrated core functionality to conform.nvim and nvim-lint, with none-ls as an optional extra. To migrate from null-ls or none-ls:

1. Update LazyVim to the latest version via `:Lazy sync`.
2. Disable none-ls if enabled:
   ```lua
   -- lua/plugins/disabled.lua
   return {
     { "nvimtools/none-ls.nvim", enabled = false },
   }
   ```
3. Remove any null-ls/none-ls references in your config to avoid errors.
4. Configure conform.nvim and nvim-lint as needed for your linters/formatters.
5. Test with `:Lazy check` and verify in files.

**Key Points**
- Old null-ls links auto-migrate to none-ls during updates.
- None-ls extra can be enabled via `:LazyExtras` for legacy code actions.
- Potential issues: Lingering configs may cause errors; linters like vale need reconfiguration.
- Keymaps like `<leader>uL` (toggle linting) work seamlessly post-migration.
- [Inference]: Migration is straightforward for most users, but complex setups may require manual porting of sources.

**Example**
For a TypeScript project previously using null-ls for ESLint:

- Disable none-ls as above.
- Add to `lua/plugins/linting.lua`:
  ```lua
  return {
    {
      "mfussenegger/nvim-lint",
      opts = {
        linters_by_ft = {
          typescript = { "eslint_d" },
        },
      },
    },
  }
  ```

**Next Steps**
- Review your config for null-ls remnants using `:Lazy log`.
- Enable the none-ls extra if code actions are missing.

### Customizing After Migration

Post-migration, extend defaults in dedicated files under `lua/plugins/`.

**Example**
Combine with Mason for tool installation:

```lua
-- lua/plugins/mason.lua
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "stylua", "eslint_d", "prettier" },
    },
  },
}
```

This ensures tools are available via Mason.

### Conclusion

Migrating from null-ls in LazyVim involves adopting none-ls for direct compatibility or conform.nvim + nvim-lint for a modular approach, aligning with current defaults. This can enhance maintainability, though thorough testing is advised as tool availability and config nuances may affect outcomes.

**Next Steps**
- Consult LazyVim docs for specific extras.
- Join Neovim communities for troubleshooting custom migrations [Unverified, based on common practices].

---

