## Diff Viewing and Staging


### Overview of Diff Viewing

Diff viewing allows developers to inspect changes between the working directory, index, and committed versions of files. In Neovim, this is facilitated through Git integration plugins that highlight differences inline and provide navigation tools. Core functionality comes from `gitsigns.nvim`, which uses signs and virtual text to display hunk changes. This plugin is included in LazyVim by default via its extras system.

From Neovim's built-in capabilities, commands like `:diffthis` can split windows for side-by-side comparisons, but plugin-enhanced viewing offers more seamless integration. Gitsigns adds buffer-local signs for added, changed, or deleted lines, with options for previewing hunks in floating windows.

**Key Points**
- Signs appear in the sign column: '+' for added, '~' for changed, '-' for deleted lines.
- Hunks are navigable via keymaps like `]c` (next hunk) and `[c` (previous hunk).
- Previews can show full diff context without leaving the buffer.
- Behavior may vary with Git repository status, Neovim version, or conflicting plugins.

### Configuring Gitsigns for Diffs

LazyVim pre-configures gitsigns with sensible defaults, but customization is done in `lua/plugins/git.lua` or similar. Enable the plugin if not already via LazyVim extras.

**Example**
```lua
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
      numhl = false,      -- Toggle with `:Gitsigns toggle_numhl`
      linehl = false,     -- Toggle with `:Gitsigns toggle_linehl`
      word_diff = false,  -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        follow_files = true
      },
      auto_attach = true,
      attach_to_untracked = false,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      max_file_length = 40000, -- Disable if file is longer
      preview_config = {
        -- Options passed to nvim_open_win
        border = "single",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1
      },
    },
  },
}
```

This setup customizes sign appearances and enables features like blame lines. After configuration, restart Neovim or run `:Lazy sync`.

### Viewing Diffs Inline

With gitsigns, diffs are viewed directly in the buffer. Hover over a changed line to see a popup with the diff, or use commands for full previews.

Keymaps in LazyVim:
- `<leader>ghp`: Preview hunk.
- `<leader>ghs`: Stage hunk.
- `<leader>ghr`: Reset hunk.

For side-by-side diffs, use Neovim's `:Gvdiffsplit` from fugitive.vim, which opens a vertical split showing staged or committed changes.

**Example**
Open a modified file in a Git repo. Signs appear in the gutter. Press `<leader>ghp` on a hunk to see:

**Output**
A floating window might display:
```
@@ -1,3 +1,4 @@
-Original line
+Modified line
+Added line
 Unchanged line
```

Exact output depends on the hunk size and Git diff algorithm.

### Introduction to Staging

Staging involves adding changes to the Git index for the next commit. In Neovim, this can be done granularly (per hunk or line) via plugins, avoiding command-line Git. Gitsigns handles hunk-level staging, while fugitive provides buffer-wide operations.

LazyVim integrates these for a Vim-centric workflow, with keymaps for quick actions.

**Key Points**
- Staging does not commit changes; it's preparatory.
- Partial staging allows selective addition of hunks.
- Unstaging reverses staging without discarding changes.
- Operations may behave differently in merge conflicts or with submodules.

### Staging with Gitsigns

Gitsigns enables staging directly from the buffer. Select a hunk visually or with cursor position.

**Example**
- Navigate to a hunk with `]c`.
- Stage it: `<leader>ghs` (or `:Gitsigns stage_hunk`).
- For visual mode: Select lines, then `<leader>ghs`.

To stage the entire buffer: `<leader>ghS` (or `:Gitsigns stage_buffer`).

Unstage with `<leader>ghu` for hunks or `<leader>ghU` for buffer.

After staging, signs update to reflect index status.

### Using Fugitive for Advanced Staging

Fugitive.vim, often included in LazyVim setups, offers a status buffer for staging. Run `:Git` to open a summary window.

In the status buffer:
- `s` to stage file or hunk.
- `u` to unstage.
- `-` to toggle staging.

For inline patching, use `dp` in diff mode to apply changes selectively.

**Example**
```vim
:Git
```
Opens a buffer like:
```
Untracked files:
? newfile.txt

Changes to be committed:
A  stagedfile.txt

Changes not staged for commit:
M modifiedfile.txt
```

Press `s` on a line to stage. Save and quit to apply.

[Inference]: Based on plugin docs, this integrates well with gitsigns for mixed workflows.

### Integrating with LazyGit

For a TUI experience, LazyVim supports lazygit.nvim. It launches a floating terminal with LazyGit for visual staging.

Configuration:
```lua
return {
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
}
```

Run `<leader>lg` to open. In LazyGit, navigate to files, press `s` to stage hunks.

This provides a more interactive diff view with side-by-side panels.

### Diff and Staging in Merge Conflicts

During merges, diffs highlight conflicts. Gitsigns shows conflict markers, and fugitive's `:Gvdiffsplit!` opens three-way diffs.

To stage resolved conflicts: Use gitsigns hunk staging after editing.

Note: Automatic conflict resolution is not handled; manual editing is required.

[Unverified]: Some users report better conflict handling with plugins like diffview.nvim.

### Potential Issues and Troubleshooting

- No signs: Ensure inside Git repo; run `:Gitsigns attach`.
- Keymap conflicts: Check LazyVim's which-key for overlaps.
- Performance: Large diffs may slow buffers; adjust `update_debounce`.
- Version mismatches: Behavior may differ post-Neovim 0.10 updates.

Debug with `:Gitsigns debug_messages`.

**Next Steps**
- Install diffview.nvim for historical diff browsing.
- Experiment in a test repo: Modify files, view diffs, stage selectively.
- Explore telescope integration for Git file picking.

**Conclusion**
Diff viewing and staging in LazyVim leverage plugins like gitsigns and fugitive for efficient Git workflows directly in the editor. These tools provide inline visuals and granular control, enhancing productivity, though outcomes can vary with setup and repository complexity.

---

### Overview of Commit and Push Workflows in Neovim

Neovim provides robust support for Git version control operations, including committing and pushing changes, through integrated plugins and scripting capabilities. This allows developers to maintain an efficient workflow without leaving the editor. Common approaches include using plugins such as vim-fugitive for comprehensive Git management, nvim-gpush for streamlined committing and pushing, and custom automation scripts for handling operations on file events. These methods are particularly effective in configurations like LazyVim, where plugins can be enabled via extras.

### Using vim-fugitive for Commit and Push

vim-fugitive, developed by Tim Pope, is a premier Git wrapper plugin that integrates seamlessly with Neovim, enabling operations like staging, committing, and pushing directly in the editor. It is installed via package managers such as lazy.nvim or Vim's built-in support, for example:

```bash
mkdir -p ~/.vim/pack/tpope/start
cd ~/.vim/pack/tpope/start
git clone https://tpope.io/vim/fugitive.git
vim -u NONE -c "helptags fugitive/doc" -c q
```

Once installed, follow these steps for a typical commit and push workflow:

1. **Check Status**: Execute `:G` or `:Git` to open the summary window, displaying unstaged, staged, and untracked files, as well as unpushed commits. This is equivalent to `git status`. Press `g?` for a list of available mappings.

2. **Stage Changes**: In the summary window, navigate to an unstaged file using Vim motions. Press `s` to stage the file (equivalent to `git add <file>`). For partial staging, press `>` to open an inline diff, select hunks with visual mode, and press `s` to stage them. Alternatively, use `dv` for a vertical diff split to edit and stage changes interactively.

3. **Commit Changes**: With changes staged, press `cc` in the summary window to open a commit message buffer (equivalent to `git commit`). Enter the message, save, and quit with `:wq`. For amendments, use `ca` to modify the last commit.

4. **Push Changes**: Execute `:G push` or `:Git push` to upload commits to the remote repository. For asynchronous execution, use `:Git! push`. If setting up a remote, run `:G remote add origin <remote-url>` first, followed by `:G push -u origin <branch>` to establish upstream tracking.

This workflow supports advanced features such as rebasing and conflict resolution, accessible via mappings in the summary window. Consult `:help fugitive` for complete documentation.

### Using nvim-gpush for Quick Commit and Push

nvim-gpush is a specialized plugin designed to commit and push changes efficiently from Neovim, reducing context switches. It is powered by an underlying tool and is ideal for simple repositories.

Installation via lazy.nvim involves adding the following to your configuration:

```lua
{
  "rmassaroni/nvim-gpush",
  lazy = false,
  config = function()
    require("nvim-gpush").setup({
      default_branch = "main",
      default_commit_message = "unnamed commit",
      -- Additional options as needed
    })
  end
}
```

Usage steps:

1. **Prepare Changes**: Edit and save files as usual.

2. **Commit and Push**: Run `:Gpush` to commit all changes and push to the default branch. Provide optional arguments, such as `:Gpush "fix bug" main` for a custom message and branch.

3. **Alternative Commands**: Use `:Gw` to save, commit, and push; `:Gwq` to do the same and quit all buffers; or `:Gp` as a shortcut for `:Gpush`.

Key features include file-type-specific commit messages and configurable defaults. This plugin is suitable for workflows prioritizing speed over granular control.

### Automation with Scripts

For automated workflows, such as committing on save, incorporate Vimscript functions into your Neovim configuration (e.g., `init.vim` or Lua equivalents). An example script for a specific directory like `~/project/` includes:

- **Pull on Read**: Define a function to run `git pull` and trigger it with `autocmd BufReadPre ~/project/** lua GitPull()`.

- **Commit and Push on Write**: Create a function using Neovim's job API:

```lua
function GitCommitAndPush()
  local cmd = 'git commit -am "Autocommit on save" && git push'
  vim.fn.jobstart(cmd, {
    on_exit = function(job_id, code, event)
      if code == 0 then
        print("Commit and push successful")
      else
        print("Commit and push failed")
      end
    end
  })
end
```

Trigger with `autocmd BufWritePost ~/project/** lua GitCommitAndPush()`. Adjust paths, messages, and branches as required. This approach is useful for personal projects but should be used cautiously in collaborative environments to avoid unintended pushes.

### Recommendations

In LazyVim, enable Git-related extras via `:LazyExtras` (e.g., `editor.fugitive`) for pre-configured setups. Combine with plugins like vim-gitgutter for real-time change indicators. Always verify repository status before pushing to prevent conflicts. These workflows enhance productivity by keeping Git operations within Neovim, tailored to professional development needs.

---

