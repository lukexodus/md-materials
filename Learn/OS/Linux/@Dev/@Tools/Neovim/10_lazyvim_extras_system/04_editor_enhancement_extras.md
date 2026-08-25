## Editor Enhancement Extras


### Overview

In LazyVim, editor enhancement extras are optional modular configurations that extend core editor functionalities with additional plugins. These extras are part of LazyVim's plugin system, managed via lazy.nvim, and focus on improving editing workflows, navigation, refactoring, and visual aids. They are stored in `lua/lazyvim/plugins/extras/editor/` within the LazyVim repository. Users can enable them to add features like advanced motion, file exploration, symbol navigation, and more, without modifying core files. As of January 2026, there are several editor extras available, each targeting specific enhancements.

Enabling extras integrates their plugins and settings seamlessly, often with lazy loading to maintain performance. Behavior may vary depending on conflicting plugins, Neovim version, or system setup.

**Key Points**
- Extras are enabled via the `:LazyExtras` command or by importing them in `lua/config/lazy.lua`.
- They provide pre-configured plugin specs, keymaps, and options.
- Most extras are optional and can be combined, but check for potential overlaps (e.g., multiple file explorers).
- Updates to extras follow LazyVim releases; use `:Lazy update` to sync.

### Enabling Extras

Extras can be enabled interactively or declaratively.

#### Interactive Enabling with :LazyExtras

Run `:LazyExtras` to open a picker listing all available extras, grouped by category (e.g., editor, ui, lang). Select and toggle with `x` or space; confirm to install and configure.

This method saves selections in `lazyvim.json` for persistence across sessions.

**Example**
After enabling `extras.editor.mini-files`, restart Neovim or run `:Lazy sync` to apply changes.

#### Declarative Enabling in Configuration

For version-controlled setups, import extras in `lua/config/lazy.lua` (or a custom file required there).

**Example**
```lua
-- lua/config/lazy.lua or lua/plugins/extras.lua
return {
  { import = "lazyvim.plugins.extras.editor.mini-files" },
  { import = "lazyvim.plugins.extras.editor.leap" },
}
```
This loads the extra's plugin specs during lazy.nvim setup.

**Key Points**
- Imports must be in a table returned by a plugin file.
- Order matters for dependencies; editor extras often stand alone.
- To disable, remove the import or use `enabled = false` in the spec.

### List of Editor Extras

Below is a comprehensive list of editor enhancement extras based on the current LazyVim repository. Each includes a description, main plugins, notable features, and keybindings where applicable. Details are derived from configurations; actual behavior may vary.

#### extras.editor.aerial

Provides a code outline and symbol navigation panel, useful for browsing document structure.

Main plugins: stevearc/aerial.nvim

Notable features: Supports LSP, Treesitter, and Markdown; integrates with edgy.nvim for sidebar display. Toggle with commands like `:AerialToggle`.

**Example**
```lua
-- In extra's config
require("aerial").setup({ -- options })
```
Keybindings: Often `<leader>cs` for symbols, but customizable.

#### extras.editor.dial

Enhances increment/decrement operations for numbers, dates, booleans, and custom patterns.

Main plugins: monaqa/dial.nvim

Notable features: Extends Ctrl-A/X with dialect-specific handling (e.g., true/false toggle).

**Example**
In normal mode, Ctrl-A on "true" toggles to "false".

Keybindings: \<C-a> (increment), \<C-x> (decrement); visual mode support.

#### extras.editor.fzf

Integrates fzf-lua for fast fuzzy finding, as an alternative to Telescope.

Main plugins: ibhagwan/fzf-lua

Notable features: High-performance searching for files, buffers, grep; customizable providers.

Keybindings: Typically overrides core finders, e.g., \<leader>ff for files.

#### extras.editor.harpoon2

Enables quick navigation between marked files or locations in a project.

Main plugins: ThePrimeagen/harpoon (version 2)

Notable features: Mark files, switch via list; integrates with Telescope.

Keybindings: \<leader>h for harpoon menu, \<leader>1-9 for quick jumps.

**Example**
Mark current file with \<leader>ha, navigate with \<leader>hn (next).

#### extras.editor.illuminate

Highlights other occurrences of the word under the cursor for better context awareness.

Main plugins: RRethy/vim-illuminate

Notable features: Uses LSP or regex; configurable delay and providers.

**Key Points**
- May impact performance in large files; adjust via options.

#### extras.editor.inc-rename

Provides incremental renaming with live preview using LSP.

Main plugins: smjonas/inc-rename.nvim

Notable features: Type new name and see changes previewed.

Keybindings: \<leader>cr for rename.

**Example**
`:IncRename old_name` previews changes as you type.

#### extras.editor.leap

Offers label-based motion for faster cursor jumping within visible text.

Main plugins: ggandor/leap.nvim

Notable features: Two-char search with labels; multi-window support.

Keybindings: s (forward), S (backward) for leaps.

#### extras.editor.mini-diff

Visualizes git diffs and hunks in the sign column.

Main plugins: echasnovski/mini.diff

Notable features: Stage hunks, compare buffers; lightweight alternative to git plugins.

Keybindings: ]h/[h for hunk navigation.

#### extras.editor.mini-files

A minimal file explorer in a buffer, with preview and editing capabilities.

Main plugins: echasnovski/mini.files

Notable features: Column view, git integration; can replace netrw.

Keybindings: \<leader>fm (current file dir), \<leader>fM (cwd).

**Example**
Open with `require("mini.files").open()`, navigate like vim buffer.

#### extras.editor.mini-move

Allows moving selections or lines with alt keys.

Main plugins: echasnovski/mini.move

Notable features: Visual and normal mode moving up/down/left/right.

Keybindings: Alt-hjkl in visual mode.

#### extras.editor.navic

Displays breadcrumbs of current context (e.g., function > class) in winbar.

Main plugins: SmiteshP/nvim-navic

Notable features: LSP-based; customizable icons.

**Key Points**
- Requires winbar enabled; integrates with lualine.

#### extras.editor.neo-tree

Configures Neo-tree as a file explorer sidebar.

Main plugins: nvim-neo-tree/neo-tree.nvim

Notable features: Git status, diagnostics; alternative to nvim-tree.

Keybindings: \<leader>e for toggle.

#### extras.editor.outline

Provides a sidebar outline for symbols using outline.nvim.

Main plugins: hedy/outline.nvim

Notable features: Treesitter/LSP support; foldable tree.

Keybindings: \<leader>co for open.

#### extras.editor.overseer

Manages tasks and run configurations, like makeprg but advanced.

Main plugins: stevearc/overseer.nvim

Notable features: Task templates, output parsing.

Keybindings: \<leader>ot for toggle.

#### extras.editor.refactoring

Adds refactoring operations like extract variable/block.

Main plugins: ThePrimeagen/refactoring.nvim

Notable features: Language-specific refactors via Treesitter.

Keybindings: \<leader>rr for select refactor.

**Example**
In visual mode, \<leader>re extracts to function.

#### extras.editor.snacks_explorer

[Speculation]: Likely a new or custom explorer using snacks.nvim, providing buffer-based file navigation.

Main plugins: folke/snacks.nvim (inferred)

Notable features: Possibly integrated picker/explorer hybrid.

#### extras.editor.snacks_picker

[Speculation]: Configures snacks.nvim for advanced picking/selection.

Main plugins: folke/snacks.nvim

Notable features: Customizable pickers, potentially replacing Telescope in some workflows.

Keybindings: Overrides core pickers like \<leader>/ for grep.

#### extras.editor.telescope

Enhances or extends Telescope with additional modules.

Main plugins: nvim-telescope/telescope.nvim (extensions)

Notable features: Undo tree, advanced pickers.

**Key Points**
- Builds on core Telescope; adds extras like telescope-undo.

### Customization and Overrides

Extras can be customized by overriding their specs in user plugin files (e.g., `lua/plugins/editor.lua`).

**Example**
```lua
-- lua/plugins/editor.lua
return {
  {
    "stevearc/aerial.nvim",
    opts = { -- custom options }
  },
}
```
This merges with the extra's config.

For conflicts, disable parts with `enabled = false`.

[Inference]: Combining multiple explorers (e.g., mini-files and neo-tree) may require manual keymap adjustments to avoid overlaps.

### Troubleshooting

- **Not Loading**: Ensure import path is correct; check `:Lazy log`.
- **Conflicts**: Use `:verbose map <key>` to detect overlapping keymaps.
- **Performance**: Monitor with `:Lazy profile`; disable unused extras.
- If an extra doesn't behave as expected, verify plugin versions in `lazy-lock.json`.

**Conclusion**
Editor enhancement extras in LazyVim offer flexible ways to augment the editing experience, from motion improvements to refactoring tools. Select based on workflow needs to keep the setup lightweight.

**Next Steps**
- Run `:LazyExtras` to explore and enable.
- Review individual extra docs on lazyvim.github.io/extras/editor/* for detailed configs.
- Experiment by enabling 1-2 extras and testing in a project.

---

