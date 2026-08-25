## Neogit as Alternative Interface


### Overview

Neogit is an interactive and powerful Git interface for Neovim, inspired by Magit from Emacs. It provides a modal, popup-driven UI for Git operations, making it a viable alternative to plugins like vim-fugitive or lazygit. In LazyVim, Neogit can be integrated as a replacement for the default lazygit extra (editor.lazygit), offering a more embedded Neovim experience with features like status buffers, commit graphs, and integrations with other plugins. It supports operations such as staging, committing, branching, rebasing, and merging, with auto-refresh capabilities. Recent updates as of late 2025 include basic submodule support and improved hunk navigation. Behavior may vary based on Neovim version, Git installation, and conflicting keymaps.

### Requirements

- Neovim 0.8.0 or higher (recommended for full features).
- plenary.nvim as a core dependency.
- Optional: diffview.nvim for enhanced diff views, telescope.nvim or fzf-lua for fuzzy finding in popups, nvim-treesitter for syntax highlighting in buffers.

In LazyVim, these dependencies are managed via lazy.nvim. System requirements include a working Git installation (version 2.23 or higher for full compatibility).

**Key Points**
- Ensure no conflicting Git plugins like lazygit are enabled if using Neogit exclusively.
- For optimal performance, install nvim-notify for notifications.

### Installation

In LazyVim, Neogit is not a built-in extra but can be added manually via a plugin specification file (e.g., ~/.config/nvim/lua/plugins/neogit.lua). Use :Lazy to install after adding the config. This setup allows it to serve as an alternative to the editor.lazygit extra.

**Example**
```lua
return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit cwd=%:p:h kind=split<cr>", desc = "Neogit (cwd)" },
      { "<leader>gG", "<cmd>Neogit kind=split<cr>", desc = "Neogit (Root Dir)" },
    },
    opts = {
      -- Custom options here
    },
  },
}
```

After adding, run :Lazy sync to install. If replacing lazygit, remove or disable the editor.lazygit extra via :LazyExtras. Restart Neovim for changes to take effect.

### Configuration Options

Configure Neogit with require("neogit").setup(opts). LazyVim users can extend defaults for integration.

**Key Points**
- `integrations`: Table to enable diffview, telescope, fzf_lua, etc. (e.g., { diffview = true, telescope = true }).
- `graph_style`: Set to "ascii", "unicode", or "kitty" for commit log rendering.
- `filewatcher.enabled`: Boolean to auto-refresh on Git directory changes.
- `mappings`: Customize keys for status, popups, and editors (e.g., { status = { ["q"] = "Close" } }).
- `sections`: Control visibility of sections like recent commits or unpulled changes.
- `disable_insert_on_commit`: "auto", true, or false to manage insert mode in commit editor.
- `use_default_keymaps`: Boolean to use Neogit's defaults.

**Example**
```lua
require("neogit").setup({
  integrations = {
    telescope = true,
    diffview = true,
  },
  graph_style = "unicode",
  filewatcher = {
    enabled = true,
  },
  mappings = {
    popup = {
      ["c"] = "CommitPopup",
      ["p"] = "PushPopup",
    },
  },
})
```

These options allow tailoring Neogit to LazyVim's workflow, potentially overriding defaults for better compatibility.

### Available Features

Neogit offers a comprehensive set of Git operations through its UI:

- Status buffer with sections for staged/unstaged files, stashes, branches.
- Popups for commit, branch, rebase, merge, stash, tag, push/pull, log.
- Commit graph visualization.
- Hunk staging/unstaging with line-level precision.
- Submodule support for basic operations (added December 2025).
- Event emission for hooks (e.g., post-commit actions).
- Customizable highlight groups based on colorscheme.

As an alternative, it provides a more interactive experience than fugitive's command-line focus and stays within Neovim unlike lazygit's terminal UI.

### Key Mappings

Neogit uses modal mappings in its buffers. In LazyVim, define global keys to open it, often remapping <leader>gg from lazygit.

**Key Points**
- Global: <leader>gg to open in current directory, <leader>gG for root.
- Status Buffer: j/k for navigation, s/S for stage, u/U for unstage, c for commit popup, b for branch, r for rebase, P for push, d for diff.
- Popup: ? for help, <esc> to close.
- Commit Editor: <C-c><C-c> to submit, <C-c><C-k> to abort.
- Rebase Editor: p for pick, r for reword, e for edit, s for squash.

**Example**
To customize:
```lua
opts = {
  mappings = {
    status = {
      ["<tab>"] = "Toggle",
      ["x"] = "Discard",
    },
  },
}
```

Mappings may overlap with LazyVim defaults; adjust as needed.

### Usage Workflow

1. Open Neogit with <leader>gg or :Neogit.
2. Navigate status buffer to view changes.
3. Stage files/hunks with s or line selections.
4. Open commit popup (c), edit message, submit.
5. For branches: b to create/switch/delete.
6. Rebase: r for interactive, modify commits with p/r/e.
7. Push/pull: P/l with options for remotes.
8. View logs: L for commit history with graph.
9. Close with q.

For multi-repo: Use :Neogit cwd=/path. Integrate with diffview for side-by-side diffs (d key).

**Example**
Staging and committing:
- Open :Neogit
- Move to unstaged file, press s
- Press c, write message, <C-c><C-c>

Behavior may vary in bare repos or with large histories.

### Language-Specific or Advanced Examples

Neogit is language-agnostic but shines in polyglot projects. For example, in a Lua project:

**Example**
Assume changes in init.lua:
- Open Neogit
- Stage hunk: Navigate to file, <tab> to expand, s on hunk
- Commit: c, add message "Update config", submit

For rebasing onto main:
- b to checkout main, l to pull
- Checkout feature branch
- r, select onto main, confirm

With telescope: Fuzzy search branches in popup.

### Troubleshooting

- UI not refreshing: Enable filewatcher.
- Key conflicts: Set use_default_keymaps = false and define manually.
- Missing features: Ensure dependencies installed.
- Errors on open: Verify Git repo and plenary.nvim.

Check Neogit logs with :lua require("neogit.lib.git").log().

**Conclusion**
Neogit serves as a robust alternative Git interface in LazyVim, providing Magit-inspired interactivity that enhances productivity over command-based or external tools.

**Next Steps**
- Add the plugin spec and test in a Git repo.
- Explore integrations like diffview for advanced diffs.
- Review Neogit GitHub for latest features and issues.

---

