## Lazygit Terminal Integration


### Introduction

LazyGit provides a terminal-based Git interface that runs within Neovim's embedded terminal when integrated via the kdheepak/lazygit.nvim plugin. This allows users to manage Git operations interactively without exiting the editor, utilizing Neovim's terminal buffers for input and output. The integration typically launches LazyGit in a floating window, leveraging either Neovim's native terminal or plenary.nvim for enhanced window management. This setup supports vim-like keybindings inside the terminal, enabling seamless navigation and commands. Behavior may vary based on Neovim version, terminal emulator settings, and system environment, such as color schemes or key passthrough in nested terminals.

### Enabling Terminal Integration

To enable, import the extra in `lazy.lua`:

```lua
return {
  { import = "lazyvim.plugins.extras.util.lazygit" },
}
```

This installs kdheepak/lazygit.nvim, which depends on plenary.nvim for floating terminals. Ensure the LazyGit binary is installed system-wide, as the plugin executes it in the terminal. Manual setup alternative:

```lua
-- In lua/plugins/lazygit.lua
return {
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "LazyGit",
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" } },
  },
}
```

The plugin detects the binary path automatically, but specify if needed:

```lua
vim.g.lazygit_path = "/usr/local/bin/lazygit"  -- Adjust to your path
```

**Key Points**
- Requires plenary.nvim for floating windows; without it, falls back to split or tab.
- Terminal mode starts in normal mode; press `i` for insert if direct input is needed.
- Supports Neovim's terminal API for buffer management, allowing commands like `:terminal lazygit` manually.

### Configuration for Terminal Behavior

Customize terminal aspects via global variables in `lazygit.nvim` options. Key settings include:

- `vim.g.lazygit_floating_window_use_plenary`: Defaults to true; uses plenary for floating windows, which may provide smoother resizing and positioning.
- `vim.g.lazygit_floating_window_winblend`: Sets transparency (0-100); e.g., 0 for fully opaque.
- `vim.g.lazygit_floating_window_scaling_factor`: Fraction of screen size (e.g., 0.9 for 90%).
- `vim.g.lazygit_use_neovim_remote`: Enable for nested Neovim sessions (requires neovim-remote installed).

Example configuration extension:

```lua
-- In lua/plugins/lazygit.lua
return {
  "kdheepak/lazygit.nvim",
  config = function()
    vim.g.lazygit_floating_window_use_plenary = true
    vim.g.lazygit_floating_window_scaling_factor = 0.95
    vim.g.lazygit_floating_window_corner_chars = { "╭", "╮", "╰", "╯" }  -- Custom borders
  end,
}
```

For LazyGit's internal terminal config, edit `~/.config/lazygit/config.yml`:

```yaml
os:
  openCommand: 'nvim {{filename}}'  -- Open files in Neovim
gui:
  nerdFontsVersion: "3"  -- For icon support in terminal
```

Behavior may vary in terminals without truecolor support, potentially leading to color mismatches.

[Inference]: If using tmux or screen, keybindings might require passthrough configurations to avoid conflicts.

### Keybindings in Terminal Mode

When LazyGit launches, Neovim enters terminal mode with LazyGit's UI. Neovim's terminal keymaps apply, but LazyGit overrides with its own. Exit with `q` or `<esc>` in LazyGit, returning to Neovim normal mode.

Neovim terminal navigation:
- `<C-\><C-n>`: Escape to normal mode from terminal insert.
- `:q` or `:bd!`: Force close terminal buffer.

LazyGit internal keys (vim-inspired):
- `h/j/k/l`: Navigate panels and lists.
- `<space>`: Stage/unstage in files panel.
- `c`: Commit staged changes.
- `P`: Push to remote.
- `?`: Help overlay with all keys.

Customize LazyGit keys in `config.yml`:

```yaml
keybinding:
  universal:
    quit: 'q'
    return: '<esc>'
  files:
    toggleStaged: '<space>'
```

To remap Neovim's launch key:

```lua
vim.keymap.set("n", "<leader>gt", "<cmd>LazyGit<cr>", { desc = "LazyGit Terminal" })
```

**Example**
Launch LazyGit: Press `<leader>gg`. In the terminal:
1. Use `j/k` to select a modified file.
2. Press `<space>` to stage.
3. Tab to commits panel, press `c` to commit.
4. Enter message in the editor popup (uses Neovim).
5. Press `P` to push.

**Output**
Terminal displays panels like:
- Left: Branch tree.
- Center: Staged/unstaged files.
- Bottom: Command log, e.g., "git commit -m 'Fix bug'".

### Advanced Terminal Features

- **Nested Editing**: Press `e` in files panel to open in Neovim split; saves propagate back.
- **Custom Commands**: Run arbitrary Git via `<c-e>` for command palette.
- **Filtering and Searching**: `/` to search in panels; integrates with terminal search.
- **Multi-Repo**: `<c-r>` switches repos; terminal refreshes accordingly.
- **Integration with Other Terminals**: Use `:LazyGit` in a split via `:split | terminal lazygit`, bypassing floating.

For debugging terminal issues, check `:messages` or LazyGit logs.

[Unverified]: On Windows, some ANSI sequences might not render correctly without compatible terminals like Windows Terminal.

### Troubleshooting Common Issues

- **Binary Not Found**: Ensure `lazygit` is in PATH; test with `:terminal lazygit`.
- **Key Conflicts**: If keys don't respond, check Neovim's `tnoremap` for overrides.
- **Window Sizing**: Adjust scaling if UI clips; behavior may vary on multi-monitor setups.
- **Performance**: Large repos may slow terminal rendering; use LazyGit's paging.

**Conclusion**
Terminal integration of LazyGit enhances Git management by embedding a powerful UI directly in Neovim, reducing context switches.

**Next Steps**
- Experiment with custom `config.yml` for tailored terminal UX.
- Combine with toggleterm.nvim for advanced terminal workflows.
- Review kdheepak/lazygit.nvim docs for updates.

---

