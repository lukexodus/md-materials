## Neo-tree - File Explorer


### Introduction
Neo-tree is a versatile file explorer plugin for Neovim, providing a tree-like view for navigating files, directories, and other sources like buffers or git status. It replaces traditional explorers like netrw and offers features such as fuzzy finding, custom renderers, and integration with version control. In LazyVim, Neo-tree is included as a core plugin (via `lazyvim.plugins.extras.editor.neo-tree`), enabled by default for file exploration. It uses sources like "filesystem", "buffers", and "git_status" to display content in sidebars or floating windows. This guide covers setup, usage, and customization based on Neo-tree's documentation and LazyVim's implementation. Behavior may vary with Neovim versions, plugin updates, or user configurations.

### Installation and Enabling in LazyVim
LazyVim pre-installs Neo-tree via lazy.nvim. To enable or confirm:
- In `lua/plugins/editor.lua` (or a custom file), ensure `{ import = "lazyvim.plugins.extras.editor.neo-tree" }` is present.
- If disabled, add the spec to re-enable.

Neo-tree depends on `nvim-lua/plenary.nvim` and `nvim-tree/nvim-web-devicons` (for icons), which LazyVim handles.

**Key Points**
- Version: LazyVim typically pins to stable releases; check `:Lazy` for details.
- [Inference]: As of early 2026, Neo-tree v3+ is common, with improved rendering and commands.

### Basic Usage
Neo-tree opens in a sidebar by default. Key commands:
- `:Neotree` (or `:NeoTreeShow`): Toggle the tree.
- Sources: Append `filesystem`, `buffers`, `git_status`, or `document_symbols` (e.g., `:Neotree filesystem`).
- Positions: `left`, `right`, `bottom`, `top`, `float`, `current` (e.g., `:Neotree position=float`).

In LazyVim, default keymap is `<leader>e` for filesystem toggle.

Navigation:
- `h`/`l`: Collapse/expand directories.
- `<CR>`: Open file in current window.
- `v`/`s`: Split vertically/horizontally.
- `?`: Show help for mappings.

**Example**
Open filesystem: `<leader>e`
Navigate to a file, press `<CR>` to edit.

**Output**
Sidebar appears on left, showing directory tree with icons.

Behavior may vary with window sizes or multi-window setups.

### Sources and Views
Neo-tree supports multiple sources:
- **Filesystem**: Default; shows directories, with filters for hidden files.
- **Buffers**: Lists open buffers, allowing deletion or navigation.
- **Git Status**: Displays staged/unstaged changes, integrates with fugitive.
- **Document Symbols**: Outline view using LSP or Treesitter.

Switch sources with tabs or commands like `:Neotree toggle buffers`.

**Key Points**
- Custom sources possible via config.
- Renderers: Customize icons, names, highlights.
- In LazyVim, defaults to filesystem on `<leader>e`, git on `<leader>ge`.

### Key Mappings in LazyVim
LazyVim provides opinionated mappings:
- `<leader>e`: Toggle filesystem.
- `<leader>E`: Toggle filesystem at current file's dir.
- `<leader>ge`: Toggle git status.
- `<leader>be`: Toggle buffers.
- Inside Neo-tree: `A` (add file/dir), `d` (delete), `r` (rename), `y` (yank path), `H` (toggle hidden).

Full list via `?` in Neo-tree window.

**Key Points**
- Mappings are buffer-local to Neo-tree.
- Override in `opts.window.mappings` during config.

**Example**
In Neo-tree, select file, `d` to delete (with confirmation).

**Output**
File removed from disk and tree refreshes.

### Configuration Options
Configure via `opts` in plugin spec. Key sections: `filesystem`, `buffers`, `git_status`, `window`, `sources`.

**Key Points**
- `opts = { ... }` passed to `require("neo-tree").setup(opts)`.
- In LazyVim, defaults include devicons, follow current file, and filtered items.
- Use functions for dynamic opts.

**Example**
Custom config in `lua/plugins/neo-tree.lua`:
```lua
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      close_if_last_window = true,
      window = {
        position = "right",
        width = 40,
        mappings = {
          ["<space>"] = "none",  -- Disable space
          ["Y"] = function(state)  -- Custom yank relative path
            local node = state.tree:get_node()
            vim.fn.setreg("+", node.path)
          end,
        },
      },
      filesystem = {
        filtered_items = { visible = true, hide_dotfiles = false },
        follow_current_file = { enabled = true },
      },
    },
  },
}
```

**Output**
Tree opens on right, shows hidden files, follows buffer changes.

### Advanced Features
- **Fuzzy Finder**: `<C-f>` or `/` for searching.
- **Commands**: Programmatic via `require("neo-tree.command").execute({ action = "show", source = "filesystem" })`.
- **Events**: Hook into `neo_tree_buffer_enter` etc., via autocmds.
- **Components**: Customize renderers, e.g., add git icons.
- **Integration**: With which-key for descriptions, or telescope for extensions.
- [Unverified]: Recent updates may include better multi-source tabs.

Behavior may vary with dependencies like nui.nvim.

### Practical Examples in LazyVim
**Example 1: Git Workflow**
`<leader>ge` opens git status. Stage with `gu`, commit via integration.

**Output**
Tree shows modified files in colors.

**Example 2: Buffer Management**
`<leader>be`, select buffer, `bd` to delete.

**Output**
Buffer closes, tree updates.

**Example 3: Custom Command**
Mapping to open at root:
```lua
vim.keymap.set("n", "<leader>Er", function()
  require("neo-tree.command").execute({ toggle = true, dir = vim.fn.getcwd() })
end, { desc = "Neo-tree root" })
```

**Output**
Toggles tree at project root.

### Common Pitfalls and Tips
- Performance: Large dirs may lag; use `hijack_netrw_behavior = "open_default"`.
- Conflicts: With other sidebars; set `popup_border_style = "rounded"`.
- Debugging: `:Neotree diagnostics` or check logs.
- [Speculation]: Future versions might enhance LSP integration.

### Conclusion
Neo-tree enhances file exploration in LazyVim with intuitive navigation and extensibility. Leverage its sources and configs for tailored workflows.

### Next Steps
- Read docs: `:help neo-tree.txt`.
- Customize: Experiment with renderers in opts.
- Explore extras: Integrate with `lazyvim.plugins.extras.ui.mini-files` for alternatives.

---

