## Incremental Selection


### Overview

Incremental selection in Neovim leverages Tree-sitter to expand or shrink text selections based on syntactic structures, such as functions, classes, or blocks. In LazyVim, this feature is integrated through the nvim-treesitter-incremental-selection plugin, which is enabled by default in the treesitter extras. It allows starting a selection on a node and incrementally broadening it to parent nodes or narrowing to child nodes using keymaps. This enhances code navigation and editing efficiency by aligning selections with language grammar.

**Key Points**
- Relies on Tree-sitter parsers for accurate syntax-aware selections.
- Default keymaps include \<c-space\> to init/increment, \<c-s\> to decrement (scope), and \<c-h\> to decrement (node).
- Works in visual mode, supporting both characterwise and blockwise selections.

### Installation and Setup

In LazyVim, incremental selection is part of the treesitter plugin configuration. It requires nvim-treesitter and nvim-treesitter-incremental-selection as dependencies. Setup involves calling require("nvim-treesitter.configs").setup() with incremental_selection options. LazyVim handles this automatically unless overridden.

**Example**
```lua
-- In lua/plugins/treesitter.lua or similar
return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    opts = {
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<c-space>",
          node_incremental = "<c-space>",
          scope_incremental = "<c-s>",
          node_decremental = "<c-h>",
        },
      },
    },
  },
}
```
This enables the feature with default keymaps. Availability depends on the Tree-sitter parser for the filetype being installed and active.

### Using Incremental Selection

Start by placing the cursor on a syntax node (e.g., a variable) and pressing the init_selection keymap to select the initial node. Subsequent presses of node_incremental expand to enclosing nodes. Use scope_incremental for broader scopes like function bodies, and node_decremental to shrink back. This operates in normal or visual mode.

**Key Points**
- Selections follow the Tree-sitter query hierarchy, starting from leaves to roots.
- Compatible with other textobjects for yanking, deleting, etc.
- In multi-line structures, it may select across lines based on grammar.

**Example**
Consider this Lua code:
```lua
local function example()
  local var = "value"
  print(var)
end
```
1. Cursor on "value", press \<c-space\>: selects "value".
2. Press \<c-space\> again: selects '"value"'.
3. Again: selects 'local var = "value"'.
4. Use \<c-h\> to decrement back.

Actual selection boundaries may vary depending on the parser's node definitions and Neovim version.

### Configuration Options

Customize keymaps or disable per-filetype via the incremental_selection table in treesitter opts. Additional modules like init_selection = "gnn" can alter starting behavior. Integrate with textobjects for extended functionality.

**Key Points**
- keymaps table allows remapping for user preference.
- disable = { "filetype" } to exclude specific languages.
- lookahead = true can influence parsing behavior in some setups.

**Example**
```lua
opts = {
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",  -- Map to Treesitter's gnn for initial node
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
}
```
This uses alternative mappings. Keymap conflicts with other plugins could alter expected behavior.

### Integration with Other Features

Incremental selection pairs with Treesitter textobjects for operations like "vaf" (visual around function). In LazyVim, it enhances navigation alongside plugins like flash.nvim or hop.nvim. For LSP, it can aid in selecting symbols for renaming or actions.

**Example**
After incremental selection, use "d" to delete the selected node, or integrate with keymaps:
```lua
-- In custom keymaps
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
```
Select incrementally, then \<leader\>y to yank. Compatibility may depend on visual mode types.

### Advanced Usage

For complex grammars, custom queries can extend selection nodes via Treesitter's query system. Use require("nvim-treesitter.incremental_selection").init_selection() programmatically in scripts. In large files, performance might be affected by parser complexity.

[Inference]: Advanced customizations could involve overriding module functions, potentially impacting stability.

**Example**
To add a custom scope:
```lua
-- Experimental; requires understanding Treesitter queries
local ts = require("nvim-treesitter incremental_selection")
-- Custom logic here, but not standard in LazyVim
```

### Potential Variations and Disclaimers

Behavior may vary across Tree-sitter parser versions, language support, or Neovim builds. For unsupported languages, selections fall back to basic Vim motions. Test in your environment, as updates to nvim-treesitter could introduce changes.

**Conclusion**
Incremental selection streamlines syntax-based editing, making it a valuable tool for structured code manipulation.

**Next Steps**
- Install additional Tree-sitter parsers via :TSInstall.
- Combine with textobjects-repeat for repeated actions.
- Explore Treesitter playground (:TSPlayground) to visualize nodes.

---

