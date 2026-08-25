## Code Actions and Refactoring


### Overview

Code actions and refactoring in LazyVim leverage the built-in Language Server Protocol (LSP) support provided by Neovim, enhanced through plugins like `nvim-lspconfig` and optional extras such as `refactoring.nvim`. These features allow developers to perform quick fixes, renames, extractions, and other code modifications directly within the editor. LazyVim pre-configures many of these capabilities, making them accessible via intuitive keybindings. The availability of specific actions depends on the LSP server for the language in use, such as `vtsls` for TypeScript or `lua_ls` for Lua. Behavior may vary based on the server's capabilities, the current buffer's language, and any custom configurations.

### Understanding Code Actions

Code actions are LSP-driven operations that suggest modifications to code, such as fixing errors, optimizing imports, or applying quick fixes. In LazyVim, these are integrated seamlessly and can be triggered contextually. For instance, when the cursor is over a diagnostic error, code actions might offer resolutions like adding missing imports or suppressing warnings. Source actions are a subset focused on file-level operations, like organizing imports across the entire document.

LazyVim uses `vim.lsp.buf.code_action()` as the core function for these, with conditional keymaps that activate only if the LSP server supports the `textDocument/codeAction` capability. Additional plugins like `Snacks` may enhance related functionalities, though their exact role in code actions is tied to utility features.

### Performing Code Actions

To invoke code actions, position the cursor on the relevant code element or diagnostic. LazyVim displays a menu of available actions, from which you can select one using fuzzy finding or numbered selection. For server-specific actions, LazyVim allows custom configurations per LSP server. For example, in `vtsls`, a keymap might trigger import organization without manual context filtering.

**Key Points**
- Code actions are LSP-dependent and may not appear if the server lacks support.
- Visual mode selections can apply actions to ranges of code.
- Integration with tools like `telescope.nvim` can enhance selection interfaces [Inference based on common LazyVim setups].

**Example**
Consider a TypeScript file with unused imports. After setting up the `vtsls` server via Mason in LazyVim:

```typescript
import { unused } from 'module'; // Diagnostic: unused import

function example() {
  console.log('Hello');
}
```

Position the cursor on the import line and press &lt;leader&gt;ca. A menu appears with options like "Remove unused imports."

**Output**
After selection, the code updates to:

```typescript
function example() {
  console.log('Hello');
}
```

### Keybindings for Code Actions

LazyVim defines these keybindings under LSP configurations, applicable in normal (n) or visual (x) modes where noted. They are conditional on server capabilities.

- &lt;leader&gt;ca: Trigger code action (n, x modes; calls `vim.lsp.buf.code_action()`).
- &lt;leader&gt;cA: Trigger source action (n mode; calls `LazyVim.lsp.action.source` for file-level actions like sorting imports).

These can be customized in your `lua/config/keymaps.lua` or per-server in `lua/plugins/lsp.lua`.

### Understanding Refactoring

Refactoring involves restructuring code without changing its behavior, such as renaming symbols, extracting functions, or inlining variables. LazyVim provides basic refactoring via LSP (e.g., rename symbols) and advanced features through the optional "Refactoring" extra, which includes `refactoring.nvim`. This extra adds operations like extracting blocks to new functions or printing debug statements.

The base LSP refactoring uses capabilities like `textDocument/rename`. For file renaming, LazyVim integrates `Snacks.rename.rename_file()`, active only if the server supports `workspace/willRenameFiles` and `workspace/didRenameFiles`. The refactoring extra extends this with language-specific prompts for return types and parameters in languages like Go, Java, or C++.

To enable the refactoring extra, add it to your `lazy.lua` configuration:

```lua
return {
  -- other specs
  "LazyVim/LazyExtras",
  opts = {
    extras = {
      "editor.refactoring",
    },
  },
}
```

Behavior may vary by language and server; for example, not all servers support advanced extractions.

### Performing Refactoring

For LSP-based refactoring, use rename operations to update symbols across files. With the refactoring extra enabled, additional actions become available under the &lt;leader&gt;r prefix, allowing extractions, inlines, and debug aids. These often prompt for details like function names.

**Key Points**
- Base renaming propagates changes workspace-wide if supported.
- Refactoring extra operations work in normal and visual modes, with treesitter-based node selection.
- Custom options in the extra allow toggling prompts for types (e.g., disabled by default for Go).

**Example**
In a Lua file, to rename a variable:

```lua
local oldName = "value"
print(oldName)
```

Position cursor on `oldName` and press &lt;leader&gt;cr. Enter "newName" in the prompt.

**Output**
Updates to:

```lua
local newName = "value"
print(newName)
```

For extraction with refactoring extra: Select a block in visual mode and press &lt;leader&gt;rf. Provide a function name, and it moves the block to a new function.

**Example**
Visual select:

```lua
local a = 1
local b = 2
local sum = a + b
```

Press &lt;leader&gt;rf, name it "addNumbers".

**Output**
Becomes:

```lua
local function addNumbers()
  local a = 1
  local b = 2
  local sum = a + b
  return sum
end

local result = addNumbers()
```

### Keybindings for Refactoring

These include base LSP and extra-specific ones. The &lt;leader&gt;r prefix opens a which-key menu for refactor options when the extra is enabled.

- &lt;leader&gt;cr: Rename symbol (n mode; `vim.lsp.buf.rename()`).
- &lt;leader&gt;cR: Rename file (n mode; `Snacks.rename.rename_file()`).
- &lt;leader&gt;r: +refactor menu (n, x modes).
- &lt;leader&gt;rb: Extract block (n, x).
- &lt;leader&gt;rc: Debug cleanup (n).
- &lt;leader&gt;rf: Extract function (n, x).
- &lt;leader&gt;rF: Extract function to file (n, x).
- &lt;leader&gt;ri: Inline variable (n, x).
- &lt;leader&gt;rp: Debug print variable (n, x).
- &lt;leader&gt;rP: Debug print (n).
- &lt;leader&gt;rs: Refactor (n, x) [Possibly a general trigger].
- &lt;leader&gt;rx: Extract variable (n, x).

### Advanced Configurations and Plugins

LazyVim's LSP plugin (`nvim-lspconfig`) handles server setups via Mason, installable with &lt;leader&gt;cm. For refactoring, the extra pulls in `refactoring.nvim`, configurable with options like `prompt_func_return_type` for specific languages.

Other related plugins:
- `which-key.nvim`: Displays keymap popups for &lt;leader&gt;r.
- `telescope.nvim`: May integrate for selecting refactor targets [Unverified in latest docs].
- Custom server keymaps: Add to server configs, e.g., for `vtsls`: `{ "<leader>co", function() vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } } }) end }`.

### Integration with Other Features

Code actions and refactoring tie into diagnostics (&lt;leader&gt;xx for Trouble), codelens (&lt;leader&gt;cc), and formatting (&lt;leader&gt;cF). For Git-related actions, plugins like `gitsigns.nvim` can pipe into code action menus [From GitHub discussions].

**Conclusion**
These tools in LazyVim provide a robust foundation for code maintenance, combining LSP efficiency with plugin extensions. They can enhance productivity in various languages, though effectiveness depends on server support.

**Next Steps**
- Install a language server via Mason and test basic actions.
- Enable the refactoring extra for advanced features.
- Explore LazyVim's keymap overrides to customize bindings.
- Refer to official docs for updates, as features evolve.

---

