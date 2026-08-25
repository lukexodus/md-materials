## Neo-Tree File Explorer Basics and Keybindings


### Overview of Neo-Tree
Neo-tree serves as a versatile file explorer plugin for Neovim, enabling users to browse the filesystem, manage buffers, and view git status in a tree-like structure. In LazyVim, it is available as an optional extra rather than the default explorer. It supports various display modes, such as sidebar or floating windows, and integrates with Neovim's ecosystem for file operations. Behavior may vary based on user configuration and Neovim version.

**Key Points**
- Supports multiple sources: filesystem, buffers, and git_status.
- Allows customization of appearance, sorting, and filtering.
- Integrates with system clipboard for copy/paste operations.
- Uses libuv for file watching to detect changes dynamically.

### Enabling Neo-Tree in LazyVim
To use Neo-tree in LazyVim, enable the extra via the `:LazyExtras` command. This loads the plugin with pre-configured settings tailored for LazyVim. Once enabled, Neo-tree can be invoked through commands or keybindings.

**Example**
To enable manually in your configuration (lua/plugins/editor.lua):
```lua
return {
  { "nvim-neo-tree/neo-tree.nvim", enabled = true },
}
```
After enabling, restart Neovim or run `:Lazy sync`.

### Opening and Closing Neo-Tree
Neo-tree can be opened using Neovim commands. In LazyVim with the extra enabled, it typically integrates with leader keybindings for convenience. The window can be positioned as a sidebar (left/right), floating, or replacing the current window.

**Key Points**
- Default command: `:Neotree` opens the filesystem source.
- Reveal current file: `:Neotree reveal` focuses on the active file.
- Specific sources: `:Neotree buffers` or `:Neotree git_status`.
- Close: Use `q` within the Neo-tree buffer or `:Neotree close`.

**Example**
Open filesystem explorer on the right: `:Neotree filesystem reveal right`.
This command may display the tree with the current file highlighted, depending on the directory structure.

### Navigation in Neo-Tree
Navigation involves moving through the tree using cursor keys or mouse. Directories expand/collapse, and filters can narrow results. The tree updates based on file system changes if watching is enabled.

**Key Points**
- Use `j`/`k` or arrow keys to move up/down.
- `<space>` toggles node expansion.
- `/` activates fuzzy finder for files; `D` for directories.
- `f` applies a filter; `<C-x>` clears it.
- `.` sets the current directory as root.
- Behavior may differ if custom mappings are applied.

**Example**
To navigate to a subdirectory:
1. Use `j`/`k` to highlight a directory.
2. Press `<space>` or `<cr>` to expand it.
3. Press `<bs>` to go up one level.

### File and Directory Operations
Neo-tree supports creating, deleting, renaming, and moving files/directories directly from the explorer. Operations prompt for confirmation where appropriate.

**Key Points**
- `a` adds a file or directory (supports brace expansion like `file{1,2}.txt`).
- `A` adds a directory.
- `d` deletes the selected item.
- `r` renames; `b` renames basename only.
- `y` copies to clipboard; `x` cuts; `p` pastes.
- `c` copies with destination prompt; `m` moves.
- Operations may trigger Neovim events, potentially affecting other plugins.

**Example**
Create a new file:
1. Highlight a directory.
2. Press `a`.
3. Enter `newfile.txt` and confirm.
The file appears in the tree and can be opened immediately.

### Keybindings in Neo-Tree Buffer
Keybindings are buffer-local and can be viewed by pressing `?` in the Neo-tree window. LazyVim's extra modifies some defaults for consistency.

**Key Points**
- In LazyVim: `l` opens/files; `h` closes node; `<space>` is unbound; `Y` copies path to clipboard; `O` opens with system app; `P` toggles preview.
- General defaults: `<cr>` opens; `S` opens in split; `s` vertical split; `t` new tab; `w` with window-picker.
- `z` closes all nodes; `C` closes current node.
- `R` refreshes; `H` toggles hidden files.
- `<` / `>` switches sources.
- `i` shows file details; `o` opens order-by menu.
- `[g` / `]g` navigates git-modified files.
- Bindings may vary if overridden in user config.

**Example**
To open a file in a vertical split:
1. Highlight the file.
2. Press `s`.
The file loads in a new split, keeping the explorer open.

### Integration with LazyVim Keybindings
When the neo-tree extra is enabled in LazyVim, it ties into the leader key system (default `<space>`). Specific global keybindings for opening may need manual setup if not automatic.

**Key Points**
- Common mapping: `<leader>e` to toggle Neo-tree (root dir); `<leader>E` for cwd. [Inference: Based on similar configurations in distributions.]
- `<leader>fe` / `<leader>fE` for explorer variants.
- These align with LazyVim's which-key integration for discoverability.
- Use `:LazyExtras` to confirm enabled state.

**Example**
Assuming `<leader>e` is mapped:
Press `<space>e` to open Neo-tree.
If not mapped, add in lua/config/keymaps.lua:
```lua
vim.keymap.set("n", "<leader>e", "<Cmd>Neotree toggle<CR>", { desc = "Toggle Explorer" })
```

### Advanced Features
Neo-tree offers filtering, sorting, and previewing. It can watch for changes and integrate with git for status icons.

**Key Points**
- Fuzzy finding: `/` for files, combines with sorters.
- Sorting: `o` menu, then `oc` (created), `od` (diagnostics), etc.
- Preview: `P` toggles (non-floating in LazyVim).
- Git symbols: Unstaged `󰄱`, staged `󰱒` (LazyVim config).
- Expander icons: `` collapsed, `` expanded.

**Example**
Filter for Lua files:
1. Press `f`.
2. Enter `*.lua`.
The tree updates to show matching files.

**Output**
A filtered tree might display:
- lua/
  - config.lua
  - plugins.lua

### Troubleshooting Common Issues
If Neo-tree does not behave as expected, check configurations or conflicts.

**Key Points**
- If not opening: Verify enabled in `:LazyExtras`.
- Hidden files: Toggle with `H`.
- Performance: Use libuv watcher; may vary on large directories.
- [Unverified]: Some users report integration issues with other tree plugins; disable conflicts.

### Conclusion
Neo-tree provides a robust file exploration experience in LazyVim when enabled as an extra, with intuitive navigation and operations. Its keybindings facilitate efficient workflow, though customizations can enhance usability further.

### Next Steps
- Explore the full help: Press `?` in Neo-tree.
- Customize: Edit opts in lua/plugins/editor/neo-tree.lua.
- Integrate: Add git or buffer sources for broader use.
- Test: Open a project and practice operations.

---

