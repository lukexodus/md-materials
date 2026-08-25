## Go-to-Definition, References, and Symbols


### Overview

In LazyVim, navigation features like go-to-definition, finding references, and searching symbols leverage the Language Server Protocol (LSP) integration. These tools allow developers to quickly traverse codebases, understand symbol usage, and explore project structures without leaving the editor. LazyVim comes pre-configured with LSP support via plugins like `nvim-lspconfig` and `mason.nvim`, which manage server installations and configurations. This setup works across various programming languages, provided the appropriate LSP server is installed.

These features rely on the LSP server's capabilities for the specific language. For instance, in Lua, the `lua_ls` server handles these operations, while in Python, `pyright` or `pylsp` might be used. Behavior can differ based on the server, project size, and configuration; larger projects may experience slight delays in indexing.

**Key Points**
- Go-to-definition jumps to the location where a symbol (e.g., function, variable) is declared.
- References list all occurrences of a symbol across the workspace.
- Symbols include document symbols (outlines within a file) and workspace symbols (global search across files).
- Default keybindings in LazyVim make these accessible: `gd` for go-to-definition, `gr` for references, `]d`/`[d` for diagnostics navigation.
- Integration with Telescope or other fuzzy finders enhances symbol searching for a more interactive experience.

### Setting Up LSP for Navigation

To enable these features, ensure LSP servers are installed. LazyVim uses Mason for this purpose. Open the Mason interface with `:Mason` and install servers for your languages (e.g., `lua_ls` for Lua, `tsserver` for TypeScript).

In your `lazy.lua` or configuration files, LSP is typically auto-configured, but you can customize keymaps or options. For example, in `lua/config/keymaps.lua`, you might see or add:

```lua
-- LSP keymaps
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'References' })
vim.keymap.set('n', '<leader>ss', vim.lsp.buf.workspace_symbol, { desc = 'Workspace Symbols' })
vim.keymap.set('n', '<leader>sd', vim.lsp.buf.document_symbol, { desc = 'Document Symbols' })
```

Note that these may already be set in LazyVim's defaults. If a server lacks support for a feature (e.g., some lightweight servers omit workspace symbols), it may fall back to basic Vim navigation like tags.

**Example**
Consider a simple Lua project with a file `main.lua`:

```lua
local function greet(name)
    return "Hello, " .. name
end

print(greet("World"))
```

With `lua_ls` installed, placing the cursor on `greet` in `print(greet("World"))` and pressing `gd` jumps to the function definition.

### Go-to-Definition

Go-to-definition allows navigation to the source of a symbol under the cursor. This is particularly useful in large codebases or when working with libraries. In LazyVim, it's bound to `gd` by default.

The LSP client sends a request to the server, which resolves the definition location. If multiple definitions exist (e.g., overloaded functions), some servers present a list via Telescope or a floating window.

Behavior may vary: For external libraries, it might open the definition in a read-only buffer if the source is available. In languages like Go with `gopls`, it handles modules efficiently.

**Example**
In a Python file `app.py`:

```python
def add(a, b):
    return a + b

result = add(1, 2)
```

Cursor on `add` in `result = add(1, 2)`, press `gd` to jump to `def add(a, b):`. If the definition is in another file, it opens that file in a split or the current buffer, depending on your `copen` settings.

**Output**
Upon success, the cursor moves to the definition line. If no definition is found, a message like "No definition found" appears in the status line.

### Finding References

References retrieve all usages of a symbol, helping to assess impact before refactoring. In LazyVim, use `gr` to trigger `vim.lsp.buf.references()`, which populates the quickfix list or displays results in Telescope if configured.

The server scans the workspace, which can take time in very large projects. Results include file paths, line numbers, and context snippets.

To navigate results: Use `:cnext`/`:cprev` for quickfix, or Telescope's interface for searching/filtering.

**Example**
Using the earlier Lua code, cursor on `greet` in the function definition, press `gr`. It lists the usage in `print(greet("World"))`.

In a multi-file setup, say `utils.lua` defines `greet` and `main.lua` imports it:

- `utils.lua`:

```lua
local M = {}
function M.greet(name)
    return "Hello, " .. name
end
return M
```

- `main.lua`:

```lua
local utils = require('utils')
print(utils.greet("World"))
```

`gr` on `greet` shows references across files.

**Output**
A list like:

```
main.lua|4 col 7| print(utils.greet("World"))
```

Displayed in quickfix or Telescope.

### Document and Workspace Symbols

Symbols provide an outline or search for identifiers. Document symbols (`<leader>sd` or `vim.lsp.buf.document_symbol()`) show a hierarchical view of the current file, like functions, classes, variables.

Workspace symbols (`<leader>ss` or `vim.lsp.buf.workspace_symbol()`) search across the entire project, useful for jumping to distant symbols.

LazyVim often integrates this with Telescope for fuzzy searching: `:Telescope lsp_document_symbols` or `:Telescope lsp_workspace_symbols`.

**Key Points**
- Document symbols are file-local and faster.
- Workspace symbols require indexing, which servers like `lua_ls` handle automatically.
- Use queries for partial matches, e.g., typing "greet" to find `greet` function.

**Example**
In a JavaScript file with classes:

```javascript
class Animal {
    constructor(name) {
        this.name = name;
    }
    speak() {
        console.log(`${this.name} makes a noise.`);
    }
}

class Dog extends Animal {
    speak() {
        console.log(`${this.name} barks.`);
    }
}
```

`:Telescope lsp_document_symbols` shows:

- Class: Animal
  - Method: constructor
  - Method: speak
- Class: Dog
  - Method: speak

For workspace symbols, it aggregates from all files.

**Output**
A selectable list in Telescope; selecting an item jumps to its location.

### Advanced Usage and Customization

Enhance these features with plugins like `trouble.nvim` for better diagnostics/references UI, or `symbols-outline.nvim` for a sidebar view.

Customize in `lua/plugins/lsp.lua`:

```lua
return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
      },
    },
  },
}
```

For performance, limit workspace folders or use server-specific optimizations.

[Inference]: In very dynamic languages like JavaScript without types, accuracy might be lower compared to typed languages like TypeScript.

### Troubleshooting

If features don't work:
- Check `:LspInfo` for server status.
- Ensure project root is detected (e.g., via `.git` or `package.json`).
- Restart LSP with `:LspRestart`.
- Behavior may vary if the server is misconfigured or outdated; update via `:MasonUpdate`.

Common issues: No server attached (install via Mason), or incomplete indexing (wait or trigger manually).

**Next Steps**
- Explore LazyVim's LSP extras: Add `clangd` for C++ or `rust_analyzer` for Rust.
- Integrate with `nvim-treesitter` for better syntax highlighting alongside LSP.
- Test in a sample project to familiarize with keybindings.

---

