## Language-specific Extras


### Introduction

LazyVim provides optional "extras" that extend its core functionality with language-specific plugins and configurations. These extras are housed in the LazyExtras repository and focus on adding support for LSP (Language Server Protocol) servers, formatters, linters, debug adapters (DAP), treesitter parsers, and other tools tailored to particular programming languages or file types. They are not enabled by default to keep the base configuration lightweight, but can be activated easily.

Extras under the "lang" category target specific languages, enhancing features like autocompletion, diagnostics, code navigation, formatting on save, and debugging. For example, enabling an extra might install a Mason package for the LSP server and configure keymaps or autocommands accordingly. Behavior may vary based on the presence of external tools (e.g., Node.js for some servers) or Neovim version; most require Neovim 0.9+.

[Inference: As of January 2026, the list of lang extras remains stable based on available documentation, with potential minor additions in updates; always check the LazyExtras repo for the latest.]

### How to Enable Extras

Extras can be enabled in two primary ways:

1. **Interactive Selection**: Use the `:LazyExtras` command in Neovim. This opens a UI (powered by lazy.nvim) where you can browse categories, select extras (e.g., under "Lang"), and toggle them. Selected extras are saved to `~/.local/share/nvim/lazy/LazyExtras/state.json`. Restart Neovim or run `:Lazy sync` to apply changes.

2. **Declarative Configuration**: Edit `lua/config/lazy.lua` to import extras explicitly in the `specs` table. This approach is version-control friendly and allows conditional loading.

**Example** (enabling Python and Rust extras):
```lua
-- lua/config/lazy.lua (excerpt)
require("lazy").setup({
  specs = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.rust" },
    -- Other imports...
  },
  -- Rest of setup...
})
```

After editing, run `:Lazy sync` to install and load. You can override extra configurations by providing options in the import table, e.g., `{ import = "lazyvim.plugins.extras.lang.python", opts = { ... } }`.

Note: Enabling an extra may pull in dependencies via Mason.nvim, which handles tool installation. If conflicts arise (e.g., with user-defined plugins), later-loaded configs may override earlier ones.

### Available Language-specific Extras

The following is a comprehensive list of lang extras available in LazyVim. Each is named as `extras.lang.<language>` and typically includes:

- LSP server configuration (via nvim-lspconfig).
- Formatter and linter setup (via conform.nvim and nvim-lint).
- Treesitter parser installation.
- Optional DAP adapters for debugging.
- Language-specific keymaps or autocommands.

List (alphabetical order):

- **angular**: Support for Angular, including angularls LSP and related tools.
- **ansible**: Ansible playbook editing with ansible-language-server.
- **astro**: Astro framework support with astro-language-server.
- **clangd**: C/C++ with clangd LSP, including compile_commands.json handling.
- **cmake**: CMake build files with cmake-language-server.
- **dart**: Dart and Flutter with dartls.
- **deno**: Deno runtime with denols LSP.
- **docker**: Dockerfiles and Compose with dockerls and docker_compose_language_service.
- **elixir**: Elixir with elixir-ls.
- **fish**: Fish shell scripts with fish-lsp [Unverified: May require external Fish installation].
- **git**: Git-related files like .gitignore, with gitlab-lsp or similar.
- **go**: Go with gopls, gofumpt formatter, and delve DAP.
- **helm**: Helm charts with helm-ls.
- **java**: Java with jdtls, including debugging via java-debug-adapter.
- **json**: JSON with jsonls, including schema support.
- **julia**: Julia with julials.
- **kotlin**: Kotlin with kotlin-language-server.
- **latex**: LaTeX with texlab, including bibliography tools.
- **markdown**: Enhanced Markdown with marksman LSP and prettier formatting.
- **nix**: Nix with nil_ls or nixd.
- **norg**: Neorg files with neorg treesitter (no LSP).
- **nu**: Nushell scripts with nu-lsp.
- **php**: PHP with intelephense or phpactor.
- **prisma**: Prisma schema with prisma-language-server.
- **proto**: Protocol Buffers with bufls.
- **python**: Python with pyright or ruff-lsp, black/ruff formatters, and debugpy DAP.
- **python_semshi**: Alternative Python highlighting with semshi (requires python extra).
- **quarto**: Quarto documents with quarto-ls.
- **r**: R with r-languageserver.
- **ros**: ROS (Robot Operating System) with ros-lsp [Speculation: Limited adoption, may depend on ROS installation].
- **ruby**: Ruby with solargraph or ruby-lsp, and ruby-debug DAP.
- **rust**: Rust with rust-analyzer, including inlay hints.
- **scala**: Scala with metals.
- **sql**: SQL with sqlls and sql-formatter.
- **svelte**: Svelte with sveltels.
- **tailwind**: Tailwind CSS with tailwindcss-language-server.
- **terraform**: Terraform with terraformls.
- **toml**: TOML with taplo LSP.
- **typescript**: TypeScript/JavaScript with tsserver, eslint, and vtsls alternatives.
- **vue**: Vue.js with vueles or vls.
- **yaml**: YAML with yamlls, including schema validation.
- **zig**: Zig with zls.

For detailed plugin lists per extra, refer to the corresponding Lua file in LazyExtras repo (e.g., lua/lazyextras/lang/python.lua). Some extras may require additional system dependencies (e.g., Node.js for npm-based servers).

### Common Configurations and Customizations

Each extra returns a table of plugin specs for lazy.nvim. You can inspect them with `:lua print(vim.inspect(require("lazyextras.lang.python")))` after enabling.

#### LSP Integration

Extras configure LSP servers with defaults like on_attach hooks for keymaps (e.g., gd for definition). Customize via `servers` table in lspconfig setup.

#### Formatting and Linting

Most use conform.nvim for formatting (e.g., black for Python) and nvim-lint for linting. Autoformat is enabled globally but can be toggled per buffer with `<leader>uf`.

#### Debugging

If dap.core extra is enabled, lang extras add adapters (e.g., codelldb for Rust). Launch configurations are set for common scenarios.

#### Treesitter

Extras ensure language parsers are installed via nvim-treesitter, enabling syntax highlighting and queries.

Behavior may vary if multiple extras overlap (e.g., json and yaml both handle schemas); prioritize by load order.

### Practical Examples

**Example**: Enabling and using Python extra.

Add to lazy.lua:
```lua
{ import = "lazyvim.plugins.extras.lang.python" },
```

After sync, open a .py file: LSP attaches, providing completions, diagnostics. Format with `<leader>cf`, debug with dap keymaps if dap.core enabled.

**Output**: Run `:LspInfo` to see pyright or ruff-lsp active.

**Example**: Customizing Rust extra for additional tools.

```lua
{
  import = "lazyvim.plugins.extras.lang.rust",
  opts = {
    -- Example: Add custom server settings
    servers = {
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = { command = "clippy" },
          },
        },
      },
    },
  },
}
```

This runs clippy on save for enhanced linting.

**Example**: Combining extras for web development (TypeScript + Tailwind + Vue).

```lua
{ import = "lazyvim.plugins.extras.lang.typescript" },
{ import = "lazyvim.plugins.extras.lang.tailwind" },
{ import = "lazyvim.plugins.extras.lang.vue" },
```

Provides integrated support for Vue projects with Tailwind styling.

### Troubleshooting and Best Practices

- **Installation Failures**: If Mason can't install a tool, check system deps (e.g., cargo for rust-analyzer).
- **Conflicts**: Disable autoformat globally in options.lua if it interferes, or use filetype-specific overrides in autocmds.lua.
- **Performance**: Extras add startup time; enable only needed ones.
- **Updates**: Run `:Lazy update` regularly; extras may evolve with plugin versions.

[Speculation]: By 2026, new extras for emerging languages (e.g., for AI scripting) might appear; monitor LazyVim discussions.

**Key Points**
- Extras add targeted language support without bloating the core.
- Enable via :LazyExtras or lazy.lua imports.
- Include LSP, formatting, linting, DAP, treesitter.
- Customize with opts in imports.

**Conclusion**
Language-specific extras make LazyVim adaptable to diverse development needs, providing plug-and-play enhancements for productivity.

**Next Steps**
- Run :LazyExtras to explore and enable.
- Review source in LazyExtras repo for details.
- Pair with dap.core for debugging or test.core for testing integrations.

---

