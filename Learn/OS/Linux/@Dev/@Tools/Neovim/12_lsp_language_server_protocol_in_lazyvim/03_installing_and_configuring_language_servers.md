## Installing and Configuring Language Servers


### Introduction to Language Servers

Language servers implement the Language Server Protocol (LSP), providing features such as autocompletion, diagnostics, code navigation, and refactoring in Neovim. LazyVim integrates LSP support through plugins like `nvim-lspconfig` for configuration, `mason.nvim` for managing installations, and `mason-lspconfig.nvim` for bridging the two. This setup allows automatic installation and configuration of servers, with options for customization.

**Key Points**
- LSP servers run as separate processes and communicate with Neovim via standardized messages.
- LazyVim pre-configures many common settings, but users can extend or override them.
- Behavior may vary based on the specific server implementation, Neovim version, and system environment.

### Prerequisites

Before proceeding, ensure LazyVim is set up in your Neovim configuration. LazyVim uses `lazy.nvim` as its plugin manager.

**Key Points**
- Required plugins: `neovim/nvim-lspconfig`, `williamboman/mason.nvim`, `williamboman/mason-lspconfig.nvim`.
- These are typically included in LazyVim's default setup; verify by checking your `lua/plugins` directory.
- Additional tools like formatters (e.g., `stylua` for Lua) can be managed similarly.
- Node.js or other runtimes may be needed for certain servers (e.g., `tsserver` requires Node.js); install them via your system's package manager.

If these plugins are not present, add them to your configuration:

**Example**
```lua
-- In lua/plugins/lsp.lua or similar
return {
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
}
```

### Installing Language Servers

Installation is handled primarily through `mason.nvim`, which downloads and manages binaries for LSP servers, formatters, and linters. Servers can be installed automatically on demand or explicitly listed for pre-installation.

**Key Points**
- Use the `ensure_installed` option in `mason.nvim` to specify servers and tools.
- Mason supports a wide range of servers; check the Mason registry for availability.
- Installation may require internet access and can be influenced by system permissions or proxies.
- To skip Mason for a server (e.g., if installed system-wide), set `mason = false` in the server config.

**Example**
To install servers for Lua, TypeScript, and Python:

```lua
-- In lua/plugins/mason.lua or as part of LSP config
return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "lua_ls",    -- Lua LSP
      "vtsls",     -- TypeScript LSP (improved tsserver)
      "pylsp",     -- Python LSP
      "stylua",    -- Lua formatter
      "black",     -- Python formatter
    },
  },
}
```

After saving, run `:Lazy sync` to install. Verify with `:Mason` command, which opens an interface to manage installations.

**Output**
Running `:Mason` might display a list like:
- lua_ls: installed
- vtsls: installed
- pylsp: installed

Note: Actual output depends on your setup and may include version numbers or status indicators.

### Configuring LSP Servers

Configuration occurs in the `opts` table of `nvim-lspconfig`. LazyVim provides a `servers` table for per-server settings, with global overrides via `servers["*"]`. Settings include capabilities, keymaps, and features like inlay hints.

**Key Points**
- Configurations are Lua tables passed to `lspconfig[server].setup(opts)`.
- Keymaps can be global, server-specific, or conditional based on capabilities (using `has` field).
- Features like formatting, code lenses, and diagnostics can be toggled or customized.
- Changes may require restarting the LSP with `:LspRestart` for full effect; behavior can vary across servers.

**Example**
Basic global configuration:

```lua
-- In lua/plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
      },
    },
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
      severity_sort = true,
    },
  },
}
```

### Examples for Specific Languages

#### Lua
LazyVim has built-in support for `lua_ls`.

**Example**
```lua
servers = {
  lua_ls = {
    mason = true,  -- Install via Mason
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        codeLens = { enable = true },
        completion = { callSnippet = "Replace" },
        hint = { enable = true, paramType = true },
      },
    },
  },
}
```

This enables inlay hints and code lenses; test by opening a Lua file and using `K` for hover (behavior may differ if server doesn't support hints).

#### TypeScript/JavaScript
Use `vtsls` for enhanced features.

**Example**
```lua
servers = {
  vtsls = {
    keys = {
      {
        "<leader>co",
        function()
          vim.lsp.buf.code_action({
            apply = true,
            context = { only = { "source.organizeImports.ts" }, diagnostics = {} },
          })
        end,
        desc = "Organize Imports",
      },
    },
  },
}
```

In a .ts file, press `<leader>co` to organize imports; actual keymap triggering depends on buffer attachment.

#### Python
Use `pylsp` or `pyright`.

**Example**
```lua
servers = {
  pylsp = {
    settings = {
      pylsp = {
        plugins = {
          pycodestyle = { ignore = { "E501" } },  -- Ignore line length
          pyls_isort = { enabled = true },
        },
      },
    },
  },
}
```

This configures linting and sorting; diagnostics appear as virtual text, but display may vary with theme or config.

### Advanced Configuration

#### Inlay Hints and Code Lenses
Enable globally or per-server.

**Example**
```lua
opts = {
  inlay_hints = {
    enabled = true,
    exclude = { "vue" },  -- Exclude for certain filetypes
  },
  codelens = { enabled = true },
}
```

Requires server support; not all servers implement these uniformly.

#### Custom Setup Handlers
For non-standard setups.

**Example**
```lua
opts = {
  setup = {
    tsserver = function(_, opts)
      require("typescript").setup({ server = opts })
      return true  -- Skip default setup
    end,
    ["*"] = function(server, opts) end,  -- Fallback for others
  },
}
```

#### Formatting Options
```lua
format = {
  formatting_options = nil,  -- Server-specific
  timeout_ms = 2000,         -- Timeout for format requests
}
```

Formatting occurs on save via `<leader>cf`; success depends on buffer state and server responsiveness.

### Troubleshooting

Common issues include failed installations, missing features, or conflicts.

**Key Points**
- Check logs with `:LspLog` for errors.
- If a server doesn't attach, ensure it's installed and the filetype is supported.
- For capability issues, use `has` to conditionally apply keymaps.
- [Unverified] If using WSL or remote setups, path mappings may need adjustment; test thoroughly.
- Restart Neovim or use `:LspRestart` after changes.

**Example**
If diagnostics don't show, verify:
```lua
:lua print(vim.inspect(vim.diagnostic.config()))
```
This outputs current config; adjust as needed.

**Next Steps**
- Explore the Mason registry for more servers via `:Mason`.
- Integrate with other plugins like `conform.nvim` for formatting.
- Customize keymaps in `lua/config/keymaps.lua` for personal workflow.

**Conclusion**
This setup provides a flexible foundation for LSP in LazyVim, balancing automation with customization. Experiment in a test file to observe behaviors, as real-world performance can differ based on project size and server updates.

---

