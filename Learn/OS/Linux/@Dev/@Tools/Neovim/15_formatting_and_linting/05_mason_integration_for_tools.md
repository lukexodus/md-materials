## Mason Integration for Tools


### Overview

Mason.nvim is a plugin that simplifies the installation and management of external tools such as LSP servers, linters, formatters, and debuggers (DAP servers) in Neovim. In LazyVim, Mason is integrated as a core component, working alongside plugins like `mason-lspconfig.nvim`, `mason-null-ls.nvim`, and `mason-nvim-dap.nvim` to automate setup. This integration allows declarative configuration, where tools are installed on-demand or explicitly, ensuring they are available for features like code completion, formatting, and diagnostics.

Mason downloads binaries or packages from registries (e.g., GitHub releases) and places them in a standardized location, typically `~/.local/share/nvim/mason/`. It handles versioning and updates, reducing manual intervention. Note that actual behavior can vary based on system architecture, network availability, and Neovim version; for instance, some tools may require additional dependencies like Node.js or Python.

### Setting Up Mason

LazyVim includes Mason by default in its starter configuration. To customize, modify `lua/config/lazy.lua` or add a dedicated file like `lua/plugins/mason.lua`. A basic setup might look like:

```lua
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",  -- LSP for Lua
        "stylua",               -- Formatter for Lua
        "shellcheck",           -- Linter for shell scripts
      },
    },
  },
}
```

This ensures the listed tools are installed when Lazy syncs. For LSP integration, use `mason-lspconfig.nvim`:

```lua
{
  "williamboman/mason-lspconfig.nvim",
  opts = {
    ensure_installed = { "lua_ls", "rust_analyzer" },
    automatic_installation = true,
  },
}
```

Here, `ensure_installed` maps to server names, and `automatic_installation` installs servers when attaching to a buffer if not present.

**Key Points**
- Mason supports multiple registries; default is `github.com/mason-org/mason-registry`.
- Tools are executable binaries or scripts; LSP servers often need further configuration via `lspconfig`.
- Installation may fail on restricted systems (e.g., no write access); check logs with `:MasonLog`.

**Example**
To add a Python LSP and formatter:

```lua
-- In lua/plugins/mason.lua
return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "pyright", "black" })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "pyright" })
    end,
  },
}
```

Run `:Lazy sync` to install.

### Integrating with LSP

Mason pairs with `nvim-lspconfig` to bridge installed servers to Neovim's LSP client. In LazyVim, this is handled automatically for many servers. For custom servers:

```lua
{
  "neovim/nvim-lspconfig",
  dependencies = { "williamboman/mason-lspconfig.nvim" },
  config = function()
    require("mason-lspconfig").setup_handlers({
      function(server_name)
        require("lspconfig")[server_name].setup({})
      end,
      ["lua_ls"] = function()
        require("lspconfig").lua_ls.setup({ settings = { Lua = { diagnostics = { globals = { "vim" } } } } })
      end,
    })
  end,
}
```

This sets up handlers for each ensured server, with overrides for specifics like Lua.

**Key Points**
- Not all LSP servers are in Mason's registry; some require manual installation.
- Use `:LspInfo` to verify server status post-installation.
- Automatic installation can be toggled per-server or globally.

**Example**
For Rust:

After ensuring `rust_analyzer`, opening a `.rs` file attaches the server if installed, or prompts installation if `automatic_installation = true`.

### Integrating with Formatters and Linters

Use `none-ls.nvim` (formerly null-ls) with `mason-null-ls.nvim` for non-LSP tools. LazyVim often includes this:

```lua
{
  "jay-babu/mason-null-ls.nvim",
  opts = {
    ensure_installed = { "prettier", "eslint_d" },
    automatic_installation = true,
    handlers = {},
  },
}
```

This installs and registers sources for formatting/linting via `:Format` or on save.

**Key Points**
- `none-ls` acts as an LSP server for these tools.
- Conflicts may occur if multiple formatters are registered; prioritize via config.
- Performance can vary; some tools like `prettier` may be slow on large files.

**Example**
For JavaScript formatting:

With `prettier` installed, add to `none-ls` sources:

```lua
require("null-ls").setup({
  sources = {
    require("null-ls").builtins.formatting.prettier,
  },
})
```

### Integrating with Debuggers

For DAP, use `mason-nvim-dap.nvim`:

```lua
{
  "jay-babu/mason-nvim-dap.nvim",
  opts = {
    ensure_installed = { "python", "js" },
    automatic_installation = true,
    handlers = {},
  },
}
```

This installs adapters like `debugpy` for Python.

Pair with `nvim-dap`:

```lua
{
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")
    -- Configure adapters here
  end,
}
```

**Key Points**
- Adapters map to languages; not all are supported out-of-box.
- Launch configurations are separate, often in `dap.configurations`.
- Debugging sessions may require additional setup like breakpoints.

**Example**
For Node.js debugging:

Ensure `js` (which installs `js-debug-adapter`), then:

```lua
dap.adapters.node2 = {
  type = "executable",
  command = "node",
  args = { vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js" },
}
```

### Managing Tools

Commands for management:

- `:Mason`: UI for install/uninstall/update.
- `:MasonInstall <tool>`: Install specific tool.
- `:MasonUpdate`: Update registry and tools.
- `:MasonUninstall <tool>`: Remove tool.

For all tools: `:MasonInstallAll` (via config or custom command).

**Key Points**
- Versions can be pinned: `opts = { registries = { "github:mason-org/mason-registry@version" } }`.
- Offline use: Pre-install tools; no internet needed post-install.
- Custom registries: Add via `opts.registries`.

**Example**
To update all:

```
:MasonUpdate
```

Then check with `:Mason`.

**Output**
In `:Mason` UI, you'll see installed tools with versions, e.g.:

- lua-language-server: 3.7.4
- stylua: 0.20.0

### Troubleshooting

- **Installation fails**: Check `:MasonLog` for errors (e.g., missing deps like curl).
- **Tool not found**: Ensure name matches registry; search with `:Mason`.
- **Conflicts**: Disable automatic_installation if managing manually.
- Behavior may differ on platforms like Windows (path issues).

### Advanced Configuration

For conditional installation:

```lua
opts = {
  ensure_installed = vim.fn.executable("node") == 1 and { "typescript-language-server" } or {},
}
```

Integrate with user commands:

```lua
vim.api.nvim_create_user_command("MasonInstallAll", function()
  require("mason-registry"):refresh(function() require("mason-lspconfig").install_all() end)
end, {})
```

[Inference: Based on common patterns in Mason docs.]

**Conclusion**
Mason streamlines tool management in LazyVim, enabling seamless integration for LSP, formatting, linting, and debugging. By declaring tools in config, you maintain a reproducible setup, though monitoring updates and dependencies is advised for consistent behavior.

**Next Steps**
- Open `:Mason` to explore available tools.
- Add a new tool for your language and test integration.
- Review Mason's GitHub for registry details and contributions.

---

