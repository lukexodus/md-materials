## Spectre for Project-Wide Search and Replace


### Overview

nvim-spectre is a Neovim plugin designed to facilitate project-wide search and replace operations through a dedicated panel. It allows users to search for text patterns across multiple files and perform replacements efficiently. The plugin supports regex-based searches and integrates with external tools like ripgrep for finding matches and sed or other engines for replacements. In the context of LazyVim, which is a modular Neovim configuration, nvim-spectre can be added as an optional plugin, though recent versions (starting from LazyVim 12.x) have replaced it with grug-far.nvim for similar functionality. This content focuses on using nvim-spectre when manually integrated into LazyVim.

The plugin operates by opening a buffer where search results are displayed, allowing navigation, editing of replacement text, and execution of changes. Searches may use Vim's very magic regex mode by default, and results can be filtered by path or filetype. Behavior can vary depending on system tools availability and Neovim version, as external commands like ripgrep influence performance.

**Key Points**
- Supports multiple replace engines: sed, oxi (Rust-based), and sd.
- Requires dependencies like plenary.nvim (typically included in LazyVim) and ripgrep.
- Provides options for live updates, ignoring case, and handling hidden files.
- Integrates with quickfix lists, optionally via trouble.nvim.

### Installation

To integrate nvim-spectre into LazyVim, add it to the plugins configuration. LazyVim uses the Lazy plugin manager, so modifications occur in the `lua/plugins/` directory.

Create or edit a file like `lua/plugins/spectre.lua` with the following content:

```lua
return {
  "nvim-pack/nvim-spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("spectre").setup()
  end,
}
```

Ensure system dependencies are installed:
- ripgrep (`rg`) for searching.
- GNU sed (on macOS, install via `brew install gnu-sed`).
- Optionally, nvim-web-devicons or mini.icons for icons, and trouble.nvim for enhanced quickfix.

After adding, run `:Lazy sync` in Neovim to install. If oxi engine is desired, install it via Cargo: `cargo install --git https://github.com/noib3/nvim-oxi`. Installation success may depend on your environment, such as Rust availability for oxi.

### Configuration

Configuration is done via the `setup` function in Lua. In LazyVim, place this in the plugin spec or a separate config file.

Example configuration:

```lua
require("spectre").setup({
  live_update = true,  -- Automatically re-run search on buffer write; may impact performance on large projects.
  default = {
    find = {
      cmd = "rg",
      options = { "ignore-case" },
    },
    replace = {
      cmd = "sed",
    },
  },
  highlight = {
    ui = "String",
    search = "DiffChange",
    replace = "DiffDelete",
  },
  mapping = {
    -- Customize keymaps within the Spectre panel.
    ["toggle_line"] = {
      map = "dd",
      cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
      desc = "toggle item",
    },
    ["run_replace"] = {
      map = "<leader>R",
      cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
      desc = "replace all",
    },
  },
})
```

Options like `open_cmd` control how the panel opens (e.g., 'vnew' for a vertical split). Custom find and replace engines can be defined, with args and options tailored to tools like ag or sd. Changes to configuration take effect after reloading Neovim or sourcing the file.

[Inference]: In LazyVim setups, if trouble.nvim is enabled, setting `use_trouble_qf = true` might improve integration with LazyVim's UI components.

### Keybindings

Keybindings are user-defined and can be set globally or within the panel. In LazyVim, which uses which-key.nvim for keymap hints, add these to `lua/config/keymaps.lua` or the plugin spec.

Suggested global keybindings:

```lua
vim.keymap.set("n", "<leader>S", "<cmd>lua require('spectre').toggle()<CR>", { desc = "Toggle Spectre" })
vim.keymap.set("n", "<leader>sw", "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", { desc = "Search current word" })
vim.keymap.set("v", "<leader>sw", "<esc><cmd>lua require('spectre').open_visual()<CR>", { desc = "Search selection" })
vim.keymap.set("n", "<leader>sp", "<cmd>lua require('spectre').open_file_search({select_word=true})<CR>", { desc = "Search in current file" })
```

Within the Spectre panel (normal mode), default or custom mappings apply, such as:
- `<CR>`: Open the selected file at the match.
- `<leader>R`: Perform all replacements.
- `ti`: Toggle ignore-case option.

These can be remapped in the setup's `mapping` table. Keybindings may overlap with LazyVim defaults, so check for conflicts using which-key.

### Usage

To perform a project-wide search and replace:
1. Open the panel with `<leader>S` or `:Spectre`.
2. Enter the search pattern in the search field (top of the panel); it uses Vim regex.
3. Optionally, enter replacement text in the replace field.
4. Results appear below; navigate with j/k.
5. Toggle items with `dd` to exclude from replacement.
6. Press `<leader>R` to execute replacements.

For filtered searches, use the path field (e.g., `**/*.lua`) or options menu (`<leader>o`) to toggle features like hidden files.

**Example**

Suppose you want to replace all occurrences of "old_function" with "new_function" in Lua files.

- Open Spectre: `<leader>S`
- Search text: `old_function`
- Replace text: `new_function`
- Path: `lua/**/*.lua`
- Enable ignore-case if needed via `ti`.
- Review results, toggle any to exclude.
- Replace all: `<leader>R`

After replacement, reload affected files with `:e` if changes aren't reflected immediately, as external tools modify files on disk.

**Output**

The panel might display something like:

```
Search: old_function
Replace: new_function
Path: lua/**/*.lua

┌----------------------------------------- 
│ lua/plugin/example.lua:10: call old_function() 
│ lua/config/keymaps.lua:5: local old_function = function() 
└----------------------------------------- 
```

Behavior may vary if ripgrep isn't installed or if large projects cause delays.

### Advanced Features

- **Custom Engines**: Switch to oxi for faster replacements: `tro` in panel.
- **Quickfix Integration**: Send results to quickfix with `<leader>q`; use trouble.nvim for better UI in LazyVim.
- **Templates**: Pre-fill searches with `open_template` in setup.
- **Programmatic Opening**: Use Lua API for scripted usage, e.g., `require('spectre').open({ search_text = "pattern", cwd = vim.fn.getcwd() })`.
- **Live Update**: Toggle with `tu`; updates results on typing but may slow down on weak hardware.
- **Resume Search**: `<leader>l` to reload previous session.

For current-file only: Use `<leader>sp`.

[Unverified]: Some users report empty results if ripgrep paths are misconfigured; verify with `:checkhealth` in Neovim.

### Troubleshooting

Common issues:
- No results: Ensure ripgrep is in PATH and project is searchable.
- Replacement failures: Check sed version; use oxi as alternative.
- UI glitches: Avoid manual edits outside mappings; escape Insert mode with `<Esc>`.
- In LazyVim, if grug-far is active, disable it via extras to avoid conflicts.

Always commit changes before replacing, as undo is handled by version control, not the plugin.

**Conclusion**

nvim-spectre provides a flexible interface for project-wide edits, enhancing productivity in codebases. While LazyVim has shifted to grug-far.nvim, adding spectre manually allows continued use with custom setups.

**Next Steps**

- Explore the GitHub repo for issues and contributions.
- Test in a small project to familiarize with regex and engines.
- Consider grug-far.nvim for built-in LazyVim support if similar features suffice.

---

