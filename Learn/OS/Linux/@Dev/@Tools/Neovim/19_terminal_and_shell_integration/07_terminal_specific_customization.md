## Terminal-Specific Customization


### Overview

Neovim's built-in terminal emulator allows running shell commands and external processes directly within editor buffers, providing a seamless integration for tasks like compiling code, running scripts, or interacting with version control. In LazyVim, this is enhanced through optional plugins and configurations that address terminal behavior, appearance, and keymappings. Terminal-specific customizations often focus on mode transitions, buffer management, and compatibility with terminal emulators like Alacritty, Kitty, or WezTerm.

Key features include terminal mode (prefixed with <C-\>), where insert mode is default, and normal mode for navigation. LazyVim provides defaults but allows overrides via lua configs. As of 2026, Neovim 0.11+ improvements include better job control and TUI handling, with plugins like toggleterm.nvim (included in extras) offering floating terminals.

**Key Points**
- Terminal buffers are created with :terminal or API calls; they support job stdin/stdout/stderr.
- Customizations can vary by terminal emulator; for example, enabling truecolor or undercurl requires specific terminfo settings.
- LazyVim's autocmds and keymaps handle mode switching, but behavior may vary based on host terminal capabilities and Neovim version.
- Plugins extend functionality, such as auto-insert mode or lazy-loading terminals.

[Inference] Recent updates may include better support for embedded terminals in multiplexers like tmux or Zellij.

### Enabling Terminal Features in LazyVim

By default, Neovim's terminal is available without extras, but LazyVim's `extras.util.toggleterm` adds toggleterm.nvim for managed terminals. Enable it via `:LazyExtras` or by importing in `lua/plugins/extras.lua`.

Toggleterm provides persistent terminals that can be toggled, with options for direction (float, horizontal, vertical), size, and shading.

**Example**
To enable toggleterm:
Edit `lua/plugins/extras.lua`:
```lua
return {
  { import = "lazyvim.plugins.extras.util.toggleterm" },
}
```
Run `:Lazy sync`. This sets up defaults like <leader>tt for toggling.

For basic terminal without plugins, use `:terminal` or `:vsplit | terminal`.

### Configuring Terminal Behavior

Configurations are set in `lua/config/options.lua` for global settings or plugin specs for specifics.

- **Terminal Mode Keymaps**: Remap keys for easier navigation. LazyVim defaults include <C-h> etc. for window navigation, but in terminal mode, they may need overrides.
- **Appearance**: Set `termguicolors` (enabled by default in LazyVim) for 24-bit color. Customize highlights like TermCursor.
- **Auto-Commands**: Use autocmds to enter insert mode on terminal open or hide line numbers.
- **Toggleterm Options**: Customize via opts in the plugin spec.

**Example** Basic autocmd for auto-insert:
```lua
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert!")
  end,
})
```

**Example** Customizing toggleterm:
Edit `lua/plugins/toggleterm.lua`:
```lua
return {
  {
    "akinsho/toggleterm.nvim",
    opts = {
      size = 20,
      open_mapping = [[<c-\>]],
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      direction = "float",
      float_opts = {
        border = "curved",
        winblend = 3,
      },
    },
  },
}
```

For emulator-specific tweaks:
- In Alacritty or Kitty, ensure `TERM=xterm-256color` or `kitty` for full feature support.
- For tmux integration, set `set -g allow-passthrough on` in tmux.conf to allow OSC sequences.

Behavior may vary; for instance, mouse events might not propagate correctly in some emulators without configuration.

### Keybindings for Terminals

LazyVim provides prefixes like <leader>t for testing, but for terminals, toggleterm adds its own.

Default toggleterm keymaps:
- <C-\>: Toggle terminal (configurable).
- In terminal mode: <C-\><C-n> to normal mode.
- Window navigation: <C-h>, <C-j>, <C-k>, <C-l> (may require remaps in terminal mode).

Custom keymaps can be set in `lua/config/keymaps.lua`.

**Example** Remapping in terminal mode:
```lua
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], { desc = "Move left" })
-- Similarly for j, k, l
```

### Integrating with External Tools

Terminals in Neovim can run tools like lazygit, ranger, or compilers.

- **Lazygit**: With `extras.util.lazygit`, <leader>gg opens in a toggleterm.
- **Custom Commands**: Define functions to open specific terminals.

**Example** Function for a horizontal terminal running a command:
```lua
function _G.run_in_term(cmd)
  require("toggleterm.terminal").Terminal:new({
    cmd = cmd,
    direction = "horizontal",
    on_open = function(term)
      vim.cmd("startinsert!")
    end,
  }):toggle()
end

vim.api.nvim_create_user_command("RunInTerm", function(opts)
  run_in_term(opts.args)
end, { nargs = 1 })
```

Usage: `:RunInTerm make build`

### Practical Examples

#### Basic Shell Access
1. Press <C-\> to toggle a floating terminal.
2. Run commands like `ls` or `git status`.
3. <esc> to normal mode for copying text.

**Output**
Terminal buffer shows shell prompt; output streams live.

#### Running a Script
Open a code file, then `:vsplit | terminal python script.py`.

**Example** Python script in terminal:
In one split: edit `script.py` with `print("Hello")`.
In terminal split: `python script.py`.

**Output**
`Hello` printed in terminal buffer.

#### Tmux-Like Setup
Use toggleterm for multiple terminals: <leader>tt for first, <leader>t2 for second, etc. (if configured).

Behavior may vary with multiple instances; toggleterm manages IDs.

### Troubleshooting Common Issues

- **Keymaps Not Working**: Ensure no conflicts; check `:verbose map <key>`. Terminal mode mappings require 't' mode.
- **Colors Incorrect**: Verify `termguicolors` and emulator support. Run `:set termguicolors?`.
- **Slow Performance**: For large outputs, use `hidden = true` in toggleterm or redirect to files.
- **Exit Issues**: Terminals close on job exit by default; set `close_on_exit = false`.
- [Unverified] In Neovim 0.11+, improved TUI may resolve some redraw issues in nested terminals.

Consult `:h terminal` or plugin docs.

**Conclusion**
Terminal-specific customizations in LazyVim enhance productivity by integrating shell workflows directly into the editor, with flexible options for appearance and control.

**Next Steps**
- Enable toggleterm extra and experiment with directions.
- Customize autocmds for workflow-specific behaviors.
- Explore integrations like lazygit for git tasks.
- Test with different emulators for optimal compatibility.

---

