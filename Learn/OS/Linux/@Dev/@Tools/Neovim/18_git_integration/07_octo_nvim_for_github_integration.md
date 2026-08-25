## Octo.nvim for GitHub Integration


### Overview of Octo.nvim

Octo.nvim is a Neovim plugin designed for interacting with GitHub repositories directly from the editor. It supports managing issues, pull requests (PRs), reviews, comments, labels, and more without leaving the terminal. As an optional extra in LazyVim, it integrates with the configuration's plugin management system, leveraging lazy.nvim for loading. This setup allows users to handle GitHub workflows efficiently, such as creating issues, reviewing code diffs, and assigning tasks.

Octo.nvim relies on the GitHub GraphQL API, requiring a personal access token for authentication. It provides a buffer-based interface where GitHub elements are treated like editable files. Behavior may vary based on API rate limits, network conditions, and Neovim versions.

**Key Points**
- Optional extra: Enabled via LazyVim's extras system.
- Core features: Issue/PR creation, editing, commenting, reviewing, and searching.
- Dependencies: Requires gh (GitHub CLI) or a token; integrates with plugins like telescope.nvim for searching.
- Limitations: Does not handle git operations like commits; focuses on GitHub API interactions.

### Enabling Octo.nvim in LazyVim

To activate Octo.nvim, import the extra in your LazyVim configuration. This automatically installs and configures the plugin.

**Example**
Add to `lua/config/lazy.lua`:

```lua
return {
  -- other configurations...
  extras = {
    { import = "lazyvim.plugins.extras.util.octo" },
  },
}
```

Run `:Lazy sync` to install. This loads pwntester/octo.nvim and sets up default keybindings and commands.

For authentication, generate a GitHub personal access token with repo, read:org, and other scopes as needed. Set it via environment variable `GITHUB_TOKEN` or using `:Octo auth login`.

**Note:** If gh CLI is installed, Octo.nvim can use it for authentication fallback.

### Configuring Octo.nvim

Customization occurs through the plugin's setup function. LazyVim provides defaults, but you can extend them in a dedicated file.

**Example** (In `lua/plugins/octo.lua`):

```lua
return {
  "pwntester/octo.nvim",
  opts = {
    default_remote = { "upstream", "origin" },  -- Order to detect base remote
    ssh_aliases = { ["github.com-work"] = "github.com" },  -- SSH aliases
    picker = "telescope",  -- Use telescope for pickers
    comment_icon = "",  -- Custom icon for comments
    mappings = {
      issue = {
        close_issue = { lhs = "<leader>ic", desc = "Close issue" },
      },
    },
  },
}
```

This example adjusts remotes, icons, and adds a custom keymap.

[Inference] Advanced users may integrate with other plugins like diffview.nvim for enhanced diff viewing.

### Core Commands and Usage

Octo.nvim uses `:Octo` as the primary command prefix. Common actions include listing, creating, and editing GitHub resources.

- `:Octo issue list`: Lists issues in the current repo.
- `:Octo pr create`: Creates a new PR from the current branch.
- `:Octo review start`: Begins a PR review.

Buffers open for editing, where you can modify titles, bodies, or add comments using markdown.

**Example** (Creating an issue):

1. Run `:Octo issue create`.
2. A new buffer opens with a template.
3. Edit the title and body.
4. Save with `<C-c><C-c>` or `:w` to submit.

**Output** (Sample issue buffer):
```
# Title: Fix bug in login flow

## Body
Describe the issue here.

## Assignees
@username

## Labels
bug, enhancement
```

After submission, Octo.nvim may display a success message in the command line.

### Managing Pull Requests

PR workflows are a key strength. You can checkout PRs, view diffs, add reviews, and approve.

- `:Octo pr checkout <number>`: Checks out the PR branch locally.
- `:Octo review thread add`: Adds a review comment to a thread.

**Example** (Reviewing a PR):

1. `:Octo pr list` to select a PR.
2. Open with `:Octo pr edit <number>`.
3. Use `<leader>rc` to add a comment.
4. Submit review with `:Octo review submit`.

Behavior may vary if the PR has conflicts or if API permissions are insufficient.

### Searching and Filtering

Integrated with telescope.nvim in LazyVim, searching is efficient.

- `:Octo search`: Opens a picker for searching issues/PRs across repos.

**Example** (Search query):
`:Octo search is:open label:bug repo:owner/repo`

Results appear in a telescope window for selection.

### Integrating with Other Plugins

Octo.nvim works well with LazyVim's ecosystem.

- With gitsigns.nvim: For inline blame and hunk navigation in PR diffs.
- With telescope.nvim: Enhanced pickers for repos, issues.
- With notify.nvim: For asynchronous notifications on actions.

**Example** (Custom integration in `lua/plugins/octo.lua`):

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "octo",
  callback = function()
    vim.keymap.set("n", "<leader>gd", ":Gitsigns diffthis<CR>", { buffer = true })
  end,
})
```

This adds a diff keymap in Octo buffers.

### Keybindings in LazyVim

LazyVim sets defaults under `<leader>g` prefix for git-related actions, extended by Octo.

- `<leader>go`: Open Octo menu (if configured).
- In Octo buffers: `<leader>ca` to add comment, `<leader>cl` to list comments.

These can be remapped in the opts.mappings table.

### Troubleshooting Common Issues

- **Authentication failures:** Verify token scopes and expiration; test with `gh auth status`.
- **Repo detection:** Ensure inside a git repo; use `:Octo repo` to switch.
- **Buffer not saving:** Use Octo's submit commands instead of plain `:w`.
- **API rate limits:** Heavy usage may trigger limits; monitor with GitHub dashboard.
- [Unverified] Conflicts with other git plugins may occur; lazy-load Octo to mitigate.
- Behavior may vary on Windows due to shell differences.

**Next Steps**
- Explore Octo's full command list with `:help octo-commands`.
- Set up webhooks or notifications for real-time updates if supported.
- Combine with project.nvim for multi-repo management.

---

