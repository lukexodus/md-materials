## Conflict Resolution


### Overview

Conflict resolution in Neovim refers primarily to handling git merge conflicts, where changes from different branches overlap and require manual intervention to reconcile. LazyVim enhances this process through its plugin ecosystem, providing visual aids, navigation tools, and integration with git commands. Core features leverage Neovim's built-in diff capabilities, while extras and additional plugins offer more advanced workflows like 3-way merges, hunk staging, and interactive TUIs.

Common scenarios include resolving conflicts during git merge, rebase, or pull operations. Neovim can be configured as git's mergetool, allowing in-editor resolution without switching tools. LazyVim's `editor` plugins, such as gitsigns.nvim (included by default), provide hunk-level insights, while extras like vcs.git (for Fugitive), util.lazygit, editor.diffview, and editor.mini-diff extend functionality.

As of 2026, popular community plugins like git-conflict.nvim integrate seamlessly with LazyVim via lazy.nvim specs. Updates in Neovim 0.10+ have improved diff handling with better Treesitter integration and performance.

**Key Points**
- Conflicts are marked by git with <<<<<<<, =======, and >>>>>>> delimiters.
- Resolution involves choosing "ours" (current branch), "theirs" (incoming), both, or neither.
- LazyVim emphasizes keyboard-driven workflows for efficiency.
- Behavior may vary based on git version, Neovim configuration, and plugin updates.

### Built-in Neovim Features

Neovim provides native tools for viewing and editing diffs, which can be used for conflict resolution without additional plugins.

- **vimdiff as Mergetool**: Configure git to use Neovim for merges by setting `mergetool` to `nvim -d`. This opens a multi-window layout showing local, base, remote, and merged files.
- **Diff Mode**: Use `:diffthis` on multiple buffers to highlight differences. Navigate with `]c` (next change) and `[c` (previous). Apply changes with `do` (diff obtain) or `dp` (diff put).
- **Folds and Navigation**: Conflicts can be folded; use `zo`/`zc` to open/close. Search for markers with `/<<<<<<<`.

To set Neovim as default mergetool:
```
[merge]
    tool = nvimdiff
[mergetool "nvimdiff"]
    cmd = nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'
```

This creates a 4-window setup for 3-way merges. Behavior may vary if window management plugins interfere.

**Example**
After a conflicted merge, run `git mergetool`. Neovim opens with splits; edit the bottom merged buffer, save, and exit to resolve.

### LazyVim's Core Support

LazyVim includes gitsigns.nvim by default, which visualizes git changes and aids in hunk-level resolution, useful for partial conflict handling.

From gitsigns:
- Highlights added, changed, and deleted lines with signs.
- Supports staging/reseting hunks, which can resolve minor conflicts by selectively applying changes.

**Keybindings** (under `<leader>gh` prefix):
- `s`: Stage hunk.
- `r`: Reset hunk.
- `S`: Stage buffer.
- `u`: Undo stage.
- `R`: Reset buffer.
- `p`: Preview hunk.
- `d`: Diff file.
- `D`: Diff against ~ (previous version).
- `]h` / `[h`: Navigate hunks.

For conflicts, use these to stage resolved hunks after manual edits. Diagnostics may show errors in conflicted files.

Behavior may vary in diff mode; gitsigns respects `vim.wo.diff`.

### Enabling Extras

LazyVim extras extend conflict resolution. Enable via `:LazyExtras` or by adding to `lua/plugins/extras.lua`.

- **vcs.git**: Adds vim-fugitive and vim-rhubarb. Fugitive provides :G commands for git operations.
  - For conflicts: :Gvdiffsplit! opens 3-way split (ours, merged, theirs).
  - Resolve by pulling changes with `do`/`dp`, then :Gwrite to stage.
  - Keybindings: `<leader>gs` for :G status, etc. [Inference based on standard Fugitive usage in LazyVim]

- **util.lazygit**: Integrates lazygit, a TUI for git.
  - Open with `<leader>gg` or `<leader>lg`.
  - Features: Stage/unstage lines/hunks, interactive rebase, commit graph.
  - For conflicts: Navigate to files panel, enter conflict mode to choose resolutions via keyboard.
  - Integrates with Neovim as editor for commits or files.

- **editor.diffview**: Adds diffview.nvim for tab-based diff interfaces.
  - :DiffviewOpen for current diffs; :DiffviewFileHistory for commits.
  - Merge mode: Opens 3/4-way views for conflicts, with hunk application tools.
  - Keybindings: `co` (choose ours), `ct` (theirs), navigation with `]c`/[`c`.
  - Close with :tabclose after resolution.

- **editor.mini-diff**: Adds mini.diff for overlay diffs.
  - Shows git status in sign column.
  - Commands like :MiniDiffToggle for enabling.
  - Helps visualize conflicts but less focused on resolution compared to others.

**Example** Enabling vcs.git and util.lazygit:
Edit `lua/plugins/extras.lua`:
```lua
return {
  { import = "lazyvim.plugins.extras.vcs.git" },
  { import = "lazyvim.plugins.extras.util.lazygit" },
}
```
Run `:Lazy sync`.

### Additional Plugins

For specialized conflict handling, add community plugins via lazy.nvim.

#### git-conflict.nvim
This plugin highlights and manages conflicts directly in buffers.

- Features: Syntax highlighting for ours/theirs sections, quickfix list integration, autocommands for detection.
- Setup: Add to plugins spec and call setup().
- Keybindings (buffer-local): `co` (ours), `ct` (theirs), `cb` (both), `c0` (none), `]x`/[`x` (navigate).
- Commands: GitConflictChooseOurs, GitConflictListQf.

**Example** Installation:
```lua
return {
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = function()
      require("git-conflict").setup({
        default_mappings = true,
      })
    end,
  },
}
```

Other plugins: conflict-marker.vim (older alternative), or integrate with neogit for full git UI.

[Unverified] Recent updates (2025+) may include better Treesitter support in git-conflict.nvim.

### Configuring Git Integration

- Set Neovim as editor: `git config --global core.editor nvim`.
- For lazygit: Ensure it's installed system-wide; LazyVim handles Neovim integration.
- Custom keymaps: Override in `lua/config/keymaps.lua`, e.g., `vim.keymap.set('n', '<leader>gc', '<Plug>(git-conflict-ours)')`.
- Diagnostics: Disable in conflicted buffers via git-conflict config to avoid noise.

Behavior may vary with large files or complex merges.

### Practical Examples

#### Using Fugitive (vcs.git extra)
1. Trigger conflict with `git merge branch`.
2. Open conflicted file.
3. Run `:Gvdiffsplit!` for 3-way view.
4. Use `]c`/[`c` to jump, `do` to get from other window.
5. `:Gwrite` to save, `:G commit`.

**Output**
Windows show //2 (ours), merged, //3 (theirs). Resolved file lacks markers.

#### Using git-conflict.nvim
Open conflicted file; highlights appear.
- `]x` to next conflict.
- `co` to choose ours.
- Save and `git add`.

**Example** Conflicted file:
```
<<<<<<< HEAD
local a = 1
=======
local a = 2
>>>>>>> branch
```
After `co`: `local a = 1`

#### Using Lazygit
`<leader>gg` to open.
- Go to Files panel, find conflicted file.
- Enter to view, space to stage lines.
- Resolve via built-in editor (Neovim).

#### Using Diffview
`:DiffviewOpen` during merge.
- Cycle tabs for views.
- Apply hunks, save merged.

### Troubleshooting Common Issues

- **No highlights**: Ensure gitsigns or git-conflict attached; check `:checkhealth`.
- **Mergetool fails**: Verify git config; test with `git mergetool --tool-help`.
- **Keymap conflicts**: LazyVim prefixes help; remap if overlapping.
- **Performance**: For large repos, disable features like diagnostics.
- [Speculation] If using Neovim 0.11+, new diff algorithms may alter hunk detection.

Consult :h diff or plugin docs for details.

**Conclusion**
Conflict resolution in LazyVim combines Neovim's robust diff tools with plugins for efficient, in-editor workflows, reducing context switches during git operations.

**Next Steps**
- Enable relevant extras and test with a sample repo.
- Explore Fugitive's full :G commands for advanced git.
- Add git-conflict.nvim for streamlined marker handling.
- Review git docs for best practices in merge strategies.

---

