## Lazygit Integration and Keybindings


### Introduction

LazyGit is a terminal-based user interface for Git, offering an interactive way to manage repositories with features like staging changes, committing, branching, and resolving conflicts through a curses-style UI. In LazyVim, integration is provided via the kdheepak/lazygit.nvim plugin, which allows launching LazyGit within a floating Neovim terminal. This setup enhances Git workflows without leaving the editor, leveraging Neovim's terminal capabilities. The integration is optional and can be enabled through LazyVim's extras system or manually. Once enabled, LazyGit uses its own binary (installed separately, e.g., via Homebrew or package managers), and behavior may vary depending on system paths, Git repository status, and terminal configurations.

### Enabling Integration

To integrate LazyGit, first ensure the LazyGit binary is installed on your system. Common installation methods include:

- Homebrew (macOS): `brew install lazygit`
- Scoop (Windows): `scoop install lazygit`
- Package managers like apt, yum, or from source: Refer to the official LazyGit documentation.

In LazyVim, enable the feature by importing the extra in your `lazy.lua`:

```lua
return {
  { import = "lazyvim.plugins.extras.util.lazygit" },
}
```

This imports kdheepak/lazygit.nvim and sets up default configurations, including a keymap for opening LazyGit. Alternatively, for manual setup without the extra:

```lua
-- In lua/plugins/lazygit.lua
return {
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    },
  },
}
```

After adding, run `:Lazy sync` to install. The plugin may attempt to detect the LazyGit binary automatically, but you can specify the path if needed:

```lua
vim.g.lazygit_floating_window_use_plenary = true  -- Use plenary for floating window
vim.g.lazygit_use_custom_config_file_path = 0     -- Use default config
```

**Key Points**
- Requires LazyGit binary; integration fails without it, potentially showing errors in Neovim.
- The extra enables it lazily on command invocation to minimize startup impact.
- Compatible with other Git plugins like gitsigns.nvim for seamless workflows.

### Configuration Options

LazyVim's integration allows customization through plugin options and Neovim settings. Key options from kdheepak/lazygit.nvim include:

- `vim.g.lazygit_floating_window_winblend`: Set transparency (e.g., 0 for opaque).
- `vim.g.lazygit_floating_window_scaling_factor`: Adjust window size (e.g., 0.9 for 90% of screen).
- `vim.g.lazygit_use_neovim_remote`: Enable if using Neovim remote for nested sessions (may require additional setup).

Extend in your config:

```lua
-- In lua/plugins/lazygit.lua
return {
  "kdheepak/lazygit.nvim",
  config = function()
    vim.g.lazygit_floating_window_winblend = 10
  end,
}
```

For LazyGit's own config (e.g., themes, keybindings), edit `~/.config/lazygit/config.yml`. Example for custom theme:

```yaml
gui:
  theme:
    activeBorderColor:
      - green
      - bold
```

Behavior may vary if custom terminals or multiplexers like tmux are used, potentially affecting key propagation or window management.

### Keybindings for Launching LazyGit

LazyVim provides default keymaps via which-key.nvim for discoverability. The primary binding opens LazyGit in the current repository:

- `<leader>gg`: Open LazyGit (e.g., Space + g + g).
- `<leader>gG`: Open LazyGit with config options visible.

These are set in LazyVim's default keymaps (see lua/lazyvim/config/keymaps.lua). To customize or disable:

```lua
-- In lua/config/keymaps.lua
vim.keymap.del("n", "<leader>gg")  -- Disable default
vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "Open LazyGit" })
```

Additional commands like `:LazyGitCurrentFile` open with the current file pre-selected. Use which-key (press <leader>g) to view all Git-related mappings, which may include integrations with other plugins.

### Keybindings Within LazyGit

Once LazyGit is open, it uses its own modal keybindings, inspired by Vim motions. Navigation relies on hjkl or arrow keys, with panels for status, files, branches, commits, and stash. Global keys work across contexts; panel-specific ones depend on focus.

**Global Keybindings**
- `<esc>` or `q`: Quit or close popup.
- `<tab>`: Switch to next panel.
- `<shift-tab>`: Switch to previous panel.
- `?`: Show help with all keybindings.
- `<c-r>`: Switch to a recent repository.
- `<pgup>` / `<pgdown>`: Scroll up/down in main window.
- `[` / `]`: Previous/next tab.

**Common Panel-Specific Keybindings**
- **Files Panel**: `space` to stage file, `e` to edit, `o` to open in external editor, `d` to discard changes.
- **Commits Panel**: `c` to commit, `a` to amend, `r` to reword, `s` to squash.
- **Branches Panel**: `n` to new branch, `d` to delete, `m` to merge.
- **Status Panel**: `e` to edit config, `o` to open config file.
- **General Actions**: `p` to pull, `P` to push, `f` to fetch, `<c-l>` to view logs.

For conflicts: Use `e` to open mergetool, then arrow keys to navigate hunks, `a`/`b` to pick sides.

These can be customized in `config.yml` under `keybinding`. Behavior may vary in Neovim's terminal mode, where Neovim keys might interfere; press `i` to enter insert mode if needed.

**Example**
To commit changes:
1. Press `<leader>gg` in Neovim to open LazyGit.
2. Navigate to Files panel with `<tab>`.
3. Stage files with `space`.
4. Press `c` to commit, enter message, and confirm with `<enter>`.

**Output**
LazyGit displays a UI with sections like:
- Status: Untracked/Modified/Staged files.
- Branches: Local/Remote.
Execution shows real-time Git output in the bottom panel.

### Advanced Usage and Tips

- **Floating Window**: By default, opens in a floating window; set `vim.g.lazygit_floating_window_use_plenary = false` to use Neovim's built-in terminal.
- **Filtering**: Use `:LazyGitFilter` to open with commit log filtered.
- **Integration with Other Tools**: Combines with telescope.nvim for Git searches or gitsigns for hunk navigation.
- **Troubleshooting**: If "Edit" command fails on Windows, it may relate to cmd.exe handling; check LazyGit issues for workarounds.

[Inference]: Custom keybindings in LazyGit might override Neovim's if not properly escaped.

**Conclusion**
LazyGit integration streamlines Git operations in LazyVim, making complex tasks accessible via an intuitive UI and key-driven interface.

**Next Steps**
- Customize LazyGit's config.yml for personalized workflows.
- Explore related extras like extras.util.gitui for alternatives.
- Review LazyVim's keymaps.lua for conflicting bindings.

---

