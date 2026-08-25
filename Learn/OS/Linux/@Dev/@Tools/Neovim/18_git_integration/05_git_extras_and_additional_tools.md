## Git Extras and Additional Tools


### Overview

LazyVim integrates Git support through core plugins like gitsigns.nvim for inline change indicators and hunk management. Extras extend this with syntax highlighting for Git files, completion in commits, diff overlays, terminal UIs, and GitHub tools. Additional tools refer to popular community plugins not bundled as extras but easily added via user configurations. These enhance workflows like branching, merging, and conflict resolution. Behavior may vary depending on Git installation, repository state, and Neovim version.

**Key Points**
- Core Git features are always available without extras.
- Extras are optional and enabled via `:LazyExtras`.
- Additional tools require manual addition in `lua/plugins/` files.
- mason.nvim can install external tools like gitui or lazygit.
- Keymaps typically use the `<leader>g` prefix for Git actions.

### Core Git Integration

LazyVim includes essential Git support in its default setup, primarily through gitsigns.nvim.

- **Plugin**: lewis6991/gitsigns.nvim
- **Features**: Displays signs for added, changed, or deleted lines since the last commit; allows staging, resetting, and previewing hunks; provides blame information and navigation.
- **Default Configuration**:
  - Signs: Customized icons like "▎" for add/change, "" for delete.
  - Staged signs enabled.
  - on_attach function sets buffer-local keymaps.
- **Keymaps**:
  - `]h`: Next hunk.
  - `[h`: Prev hunk.
  - `<leader>gs`: Stage hunk.
  - `<leader>gr`: Reset hunk.
  - `<leader>gS`: Stage buffer.
  - `<leader>gR`: Reset buffer.
  - `<leader>gu`: Undo stage hunk.
  - `<leader>gp`: Preview hunk inline.
  - `<leader>gB`: Blame show full.
  - `<leader>gb`: Blame line.
  - `<leader>gd`: Diff this.
  - `<leader>gD`: Diff this ~.
  - `ih`: Select hunk (operator mode).

**Example** (Customizing signs)
```lua
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
      },
    },
  },
}
```

### Git Extras

Extras provide specialized Git enhancements. Enable them via `:LazyExtras` and search for the name.

#### lang.git

This extra adds support for Git-related file types and completion.

- **Description**: Installs Treesitter parsers for Git configs, commits, rebases, ignores, and attributes; integrates cmp-git for completion in Git commit messages.
- **Included Plugins**:
  - nvim-treesitter/nvim-treesitter (extends ensure_installed).
  - hrsh7th/nvim-cmp (optional, adds "git" source).
- **Default Settings**:
  - Treesitter: `ensure_installed = { "git_config", "gitcommit", "git_rebase", "gitignore", "gitattributes" }`.
  - cmp-git: No specific opts; inserts "git" into cmp sources.
- **Keymaps**: None specific to this extra.
- **Configurations**: Primarily extends existing plugins; no standalone setup required.

**Example** (Extending cmp-git)
```lua
return {
  {
    "petertriho/cmp-git",
    opts = {
      filetypes = { "gitcommit", "octo" },
    },
  },
}
```

#### editor.mini-diff

This extra provides a lightweight Git diff overlay and hunk management.

- **Description**: Uses mini.diff for sign-based diff views with toggleable overlays.
- **Included Plugins**: echasnovski/mini.diff.
- **Default Settings**:
  - View style: "sign".
  - Signs: "▎" for add/change, "" for delete.
- **Keymaps**:
  - `<leader>uG`: Toggle mini.diff signs.
- **Configurations**:
  - Integrates with lualine.nvim (if enabled) to show diff summary in statusline (added, modified, removed counts).
  - Toggle uses `mini.diff.enable(0)` / `disable(0)` with a deferred redraw.

**Example** (Custom view style)
```lua
return {
  {
    "echasnovski/mini.diff",
    opts = {
      view = { style = "number" },
    },
  },
}
```

#### util.gitui

This extra integrates GitUI, a fast terminal UI for Git.

- **Description**: Installs gitui via mason.nvim and sets keymaps to launch it [Inference based on similar extras].
- **Included Plugins**: mason.nvim (extends ensure_installed with "gitui").
- **Default Settings**: `ensure_installed = { "gitui" }`.
- **Keymaps**:
  - `<leader>gg`: GitUI (root dir).
  - `<leader>gG`: GitUI (cwd).
- **Configurations**: Launches via terminal integration; deletes conflicting lazygit keymaps if present.

**Example** (Launching GitUI)
Use `<leader>gg` in a Git repo to open the UI.

#### util.lazygit [Unverified]

This extra integrates LazyGit, a terminal-based Git UI.

- **Description**: Installs lazygit via mason.nvim and provides keymaps for quick access [Unverified; based on common LazyVim setups and mentions in documentation].
- **Included Plugins**: kdheepak/lazygit.nvim, mason.nvim.
- **Default Settings**: Ensures lazygit installation; configures floating window.
- **Keymaps**:
  - `<leader>gg`: LazyGit (root dir).
  - `<leader>gG`: LazyGit (cwd).
  - `<leader>gf`: LazyGit file history.
  - `<leader>gL`: LazyGit log.
- **Configurations**: Uses toggleterm or similar for floating terminal; auto-installs if missing.

**Example** (Custom config)
```lua
return {
  {
    "kdheepak/lazygit.nvim",
    opts = {
      floating_window_winblend = 0,
    },
  },
}
```

#### util.octo

This extra adds GitHub issue and PR management.

- **Description**: Uses octo.nvim for editing issues, PRs, and reviews directly in Neovim.
- **Included Plugins**: pwntester/octo.nvim.
- **Default Settings**:
  - Enable builtin: true.
  - Default to projects v2: true.
  - Default merge method: "squash".
  - Picker: Dynamically set to telescope, fzf-lua, or snacks based on enabled extras.
- **Keymaps**: None specific; uses :Octo commands.
- **Configurations**:
  - Registers Treesitter markdown for "octo" filetype.
  - Autocmd to preserve octo windows in sessions by clearing buftype on exit.
  - Requires a picker extra; errors if none found.

**Example** (Using Octo)
`:Octo pr list` to view pull requests.

### Additional Tools

These are community plugins not part of LazyVim extras but frequently added for advanced Git workflows.

#### vim-fugitive

- **Plugin**: tpope/vim-fugitive
- **Features**: Comprehensive Git wrapper with :Git, :Gstatus, :Gcommit, :Gblame, etc.; inline diff and merge tools.
- **How to Add**:
  **Example**
  ```lua
  return {
    "tpope/vim-fugitive",
    cmd = { "G", "Git" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" },
    },
  }
  ```

#### neogit

- **Plugin**: NeogitOrg/neogit
- **Features**: Interactive Git UI inspired by Emacs' Magit; status, commit, rebase, etc.
- **How to Add** [Inference; common setup]:
  **Example**
  ```lua
  return {
    "NeogitOrg/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
    },
  }
  ```

#### diffview.nvim

- **Plugin**: sindrets/diffview.nvim
- **Features**: Side-by-side diff views for files, commits, and merges.
- **How to Add**:
  **Example**
  ```lua
  return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff View" },
    },
  }
  ```

#### Other Tools

- akinsho/git-conflict.nvim: Highlights and resolves merge conflicts.
- ThePrimeagen/git-worktree.nvim: Manages Git worktrees.
- rhysd/committia.vim: Enhanced commit message editing.

**Example** (Adding git-conflict)
```lua
return {
  "akinsho/git-conflict.nvim",
  version = "*",
  config = true,
}
```

### Customizing Git Configurations

Place overrides in `lua/plugins/git.lua` or similar. Use opts functions to extend defaults.

**Example** (Disabling gitsigns auto-attach)
```lua
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    attach_to_untracked = false,
  },
}
```

### Practical Examples

#### Staging Hunks with gitsigns

Open a modified file, navigate with `]h`/`[h`, stage with `<leader>gs`.

**Output** (Sign column example)
```
+ Added line
~ Changed line
```

#### Using Octo for GitHub

Enable util.octo, then `:Octo issue create` to make an issue.

#### Adding and Using Fugitive

Add the plugin, then `<leader>gs` for :Git status; use `s` to stage, `cc` to commit.

### Conclusion

LazyVim's Git extras provide robust version control integration, from basic signs to full UIs. Additional tools allow further customization for complex workflows. Test configurations in small projects as integrations may evolve.

### Next Steps

- Run `:LazyExtras` to enable and explore extras.
- Visit plugin repositories (e.g., gitsigns on GitHub) for advanced options.
- Integrate with test or dap extras for Git-aware debugging.

---

