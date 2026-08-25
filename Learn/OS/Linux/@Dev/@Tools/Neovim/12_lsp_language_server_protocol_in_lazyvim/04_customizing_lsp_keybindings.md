## Customizing LSP Keybindings


### Introduction to LSP in LazyVim

LazyVim integrates Language Server Protocol (LSP) support through plugins like `neovim/nvim-lspconfig` and `williamboman/mason.nvim`. This setup enables features such as code completion, diagnostics, hover information, code actions, and more for various programming languages. LSP configurations, including keybindings, are primarily managed in the `opts` table of the `neovim/nvim-lspconfig` plugin specification, typically located in a user file like `lua/plugins/lsp.lua`. Keybindings attach to LSP servers during the `on_attach` phase and can be global (applying to all servers) or server-specific. Other LSP options, such as diagnostics display, inlay hints, code lens, and formatting, can also be adjusted in the same configuration, but this guide focuses on keybindings.

**Key Points**
- LSP keybindings are declarative and defined in arrays within the `servers` table.
- Global customizations use the special key `["*"]`.
- Behavior of keybindings depends on the active LSP server and its supported capabilities; results may vary across languages or server implementations.

### Default LSP Keybindings

LazyVim provides a set of default keybindings for common LSP actions. These are attached when an LSP server starts and can be viewed via tools like Which-Key (activated by pressing the leader key, default `<space>`) or by checking the documentation. The leader key is `<space>` by default.

The following table lists the default LSP-related keybindings:

| Keybinding | Description | Mode(s) | Required Capability (if any) |
|------------|-------------|---------|------------------------------|
| `<leader>cl` | Lsp Info | n | - |
| `gd` | Goto Definition | n | definition |
| `gr` | References | n | - |
| `gI` | Goto Implementation | n | - |
| `gy` | Goto Type Definition | n | - |
| `gD` | Goto Declaration | n | - |
| `K` | Hover | n | - |
| `gK` | Signature Help | n | signatureHelp |
| `<c-k>` | Signature Help | i | signatureHelp |
| `<leader>ca` | Code Action | n, x | codeAction |
| `<leader>cc` | Run Codelens | n, x | codeLens |
| `<leader>cC` | Refresh & Display Codelens | n | codeLens |
| `<leader>cR` | Rename File | n | workspace/didRenameFiles, workspace/willRenameFiles |
| `<leader>cr` | Rename | n | rename |
| `<leader>cA` | Source Action | n | codeAction |
| `[[` | Prev Reference | n | documentHighlight |
| `]]` | Next Reference | n | documentHighlight |
| `<a-n>` | Next Reference | n | documentHighlight |
| `<a-p>` | Prev Reference | n | documentHighlight |
| `<leader>ss` | LSP Symbols | n | - |
| `<leader>sS` | LSP Workspace Symbols | n | - |
| `gai` | Calls Incoming | n | - |
| `gao` | Calls Outgoing | n | - |
| `<leader>cF` | Format Injected Langs | n, x | - |

**Key Points**
- Modes: `n` = normal, `i` = insert, `x` = visual.
- Some keybindings, like navigation to references, rely on server support and may behave differently depending on the file type or server configuration.
- These defaults can be inspected in LazyVim's source code under `lua/lazyvim/plugins/lsp/keymaps.lua`.

### Methods to Customize Keybindings

Customization occurs by modifying the `keys` option in the LSP server configuration. Create or edit a plugin spec file (e.g., `lua/plugins/lsp.lua`) that returns a table extending `neovim/nvim-lspconfig`. Use `servers["*"]` for global changes or specify a server name (e.g., `servers.vtsls`) for targeted ones. Keymaps are arrays of tables, where each entry defines a binding. To override globals, use an `init` function to access and modify the keymap table dynamically.

Changes take effect after restarting Neovim or sourcing the config. Test bindings in a buffer with an active LSP server.

**Key Points**
- Always include a `desc` field for clarity, as it integrates with Which-Key.
- Keybindings may not activate if the server lacks the required capability or if there's a conflict with other plugins; check with `:verbose map <key>`.
- For global non-LSP keymaps, use `lua/config/keymaps.lua` instead.

### Adding New Keybindings

Add entries to the `keys` array. Each entry is a table with the key, a command (string or function), and optional fields like `desc`, `mode`, and `has` (for capability checks).

**Example**

To add a global keybinding that echoes a message:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "H", "<cmd>echo 'hello'<cr>", desc = "Say Hello" },
          },
        },
      },
    },
  },
}
```

**Output**

Pressing `H` in a buffer with LSP attached will display "hello" in the command line. Behavior may vary if `H` is already mapped elsewhere.

### Overriding Existing Keybindings

Redefine the key with a new command in the `keys` array. This replaces the default action.

**Example**

To change the hover keybinding globally:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "K", "<cmd>echo 'custom hover'<cr>", desc = "Custom Hover" },
          },
        },
      },
    },
  },
}
```

**Output**

Pressing `K` now echoes "custom hover" instead of showing LSP hover information.

### Disabling Keybindings

Set the entry to `false` in the `keys` array, or use an `init` function to remove it from the default list.

**Example**

To disable the goto definition keybinding globally using the `init` approach:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "gd", false }
    end,
  },
}
```

**Output**

`gd` no longer triggers any action in LSP-attached buffers.

Alternatively, directly in `opts`:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "gd", false },
          },
        },
      },
    },
  },
}
```

### Server-Specific Customizations

Define `keys` under a specific server name for bindings that only apply to that server.

**Example**

For the `vtsls` (TypeScript) server, add a keybinding to organize imports:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          keys = {
            {
              "<leader>co",
              function()
                vim.lsp.buf.code_action {
                  apply = true,
                  context = {
                    only = { "source.organizeImports" },
                    diagnostics = {},
                  },
                }
              end,
              desc = "Organize Imports",
            },
          },
        },
      },
    },
  },
}
```

**Output**

In TypeScript files, `<leader>co` triggers the organize imports action if supported by vtsls.

### Capability-Based Keybindings

Use the `has` field to condition a keybinding on server capabilities. If `has` is a string without `/`, it's prefixed with `textDocument/`.

**Example**

Add a code action keybinding only if the server supports it:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            {
              "<leader>ca",
              vim.lsp.buf.code_action,
              desc = "Code Action",
              mode = { "n", "x" },
              has = "codeAction",
            },
          },
        },
      },
    },
  },
}
```

**Output**

`<leader>ca` activates only for servers with `textDocument/codeAction` capability; otherwise, it's not mapped.

For multiple capabilities:

```lua
{
  "<leader>cR",
  function() require("lazyvim.util").rename_file() end,
  desc = "Rename File",
  has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
}
```

### Advanced Customization Techniques

For dynamic modifications, use an `init` function to access the default keys table:

**Example**

Disable a key and add a replacement:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- Disable existing signature help
      keys[#keys + 1] = { "<c-k>", false, mode = "i" }
      -- Add alternative
      keys[#keys + 1] = { "<c-o>K", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" }
    end,
  },
}
```

**Output**

`<c-k>` in insert mode is disabled, and `<c-o>K` provides signature help instead.

**Key Points**
- This method is useful for avoiding conflicts or integrating with other plugins.
- Indexing with `#keys + 1` appends to the table; behavior may vary if other plugins modify it first.

### Troubleshooting Common Issues

- **Keybinding not working**: Ensure the LSP server is attached (`:LspInfo`), the capability exists, and no conflicts (`:verbose map <key>`). Restart Neovim after changes.
- **Conflicts with other plugins**: LSP keymaps take precedence in attached buffers, but global keymaps in `lua/config/keymaps.lua` can override.
- **Server-specific quirks**: Some servers (e.g., lua_ls) may require additional settings in `servers.<name>.settings`.
- Note: Keybinding behavior may vary across Neovim versions, plugin updates, or system environments.

**Conclusion**

Customizing LSP keybindings in LazyVim allows tailoring your editing experience to specific workflows. By leveraging the `keys` option, you can add, override, or disable mappings globally or per-server, with conditional support via capabilities. Start with small changes in a dedicated plugin file and test in relevant file types.

**Next Steps**
- Explore LazyVim's full keymap list via `<leader>?` or the documentation.
- Add LSP servers via `opts.servers` and customize their keybindings.
- Integrate with other plugins like `nvim-cmp` for completion-related mappings.
- Refer to official Neovim LSP docs (`:help lsp`) for underlying API details.

---

