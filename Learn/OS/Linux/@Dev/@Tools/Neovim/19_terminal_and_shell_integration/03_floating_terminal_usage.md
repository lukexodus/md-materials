## Floating Terminal Usage


### Overview

Floating terminals in LazyVim are managed primarily through the toggleterm.nvim plugin, which is included as an extra. This feature allows opening terminal windows that float over the editor, providing a non-intrusive way to run shell commands, scripts, or tools without leaving Neovim. They can be toggled, resized, and configured for specific tasks like lazygit integration or custom commands. Multiple terminals can be maintained, each with its own state, and they support modes like insert or normal for interaction.

To enable, use `:LazyExtras` and select `terminal.toggleterm` (it may be enabled by default in some configurations). Behavior may vary based on terminal emulator, window manager, or plugin versions, as rendering and key handling can differ across systems.

### Setting Up Floating Terminals

1. Enable the toggleterm extra via `:LazyExtras` if not already active.
2. LazyVim pre-configures toggleterm with defaults: floating direction, border styles, and keybindings.
3. Customize in `lua/plugins/toggleterm.lua`: Override options like `size = 20`, `open_mapping = [[<c-\>]]`, or `direction = 'float'`.
4. For integrations, enable related extras like `util.lazygit` for git terminals.
5. Ensure your terminal supports true colors and UTF-8 for optimal display.

LazyVim sets up autocommands to handle terminal behaviors, such as entering insert mode on open.

**Key Points**
- Defaults to floating mode with curved borders.
- Supports multiple instances: General terminals and named ones (e.g., for htop).
- [Inference]: If floating doesn't work, check for conflicts with window plugins like nvim-tree.

### Opening and Toggling Terminals

Toggleterm provides commands and keybindings to open/close terminals quickly.

Keybindings (LazyVim defaults):
- `<c-\>`: Toggle the primary floating terminal.
- `<leader>ft`: Open a new floating terminal.
- `<leader>fT`: Open a new terminal in current directory.
- In terminal: `<c-\>` to toggle hide, or `Ctrl + c` to interrupt commands.

Commands:
- `:ToggleTerm direction=float`: Open a floating terminal.
- `:ToggleTerm size=40`: Specify height/width.
- `:2ToggleTerm`: Open or toggle the second terminal instance.

Terminals persist in the background when hidden, preserving command history and output.

**Key Points**
- Multiple terminals: Number them (e.g., `:3ToggleTerm`) for separate sessions.
- Direction options: 'float', 'horizontal', 'vertical', 'tab'.
- Use for quick tasks like compiling code or running tests.

**Example**

To open a floating terminal and run a command:

1. Press `<c-\>` to toggle open.
2. Enter insert mode (automatic), type `ls` and press Enter.
3. Press `<c-\>` to hide.

For a custom terminal running lazygit:

- Enable lazygit extra.
- Press `<leader>gg` to open lazygit in a floating terminal.

Code for custom config in `lua/plugins/toggleterm.lua`:

```lua
return {
  {
    "akinsho/toggleterm.nvim",
    opts = {
      float_opts = {
        border = "curved",
        width = 80,
        height = 20,
      },
    },
  },
}
```

### Interacting with Floating Terminals

Once open, interact like a standard Neovim terminal buffer.

- Modes: Insert for typing commands, normal for navigation (e.g., scroll with `j/k`).
- Copy/paste: Use Neovim registers or system clipboard.
- Resize: Drag borders if in float mode, or use `:resize +10`.
- Send commands from editor: Use `require("toggleterm").exec("command")` in Lua.

Keymappings in terminal mode:
- `<esc>`: Switch to normal mode.
- `i` or `a`: Back to insert.
- Custom: Map in config, e.g., `<c-h>` for navigation if using tmux-like splits.

Integration with other plugins: Send lines from buffers to terminal via commands like `:ToggleTermSendCurrentLine`.

Behavior may vary; for example, some shells might not handle signals properly in floats.

**Key Points**
- Autocmd sets BufEnter to start insert mode.
- Supports lazy loading for performance.
- Use for REPLs: Configure for languages like Python with `python -i`.

**Example**

Running a script:

1. Open terminal with `<leader>ft`.
2. Type `python myscript.py` and Enter.
3. Observe output in the float.
4. In normal mode, yank output with `y`.

To send from editor:

- Select a line in visual mode.
- `:ToggleTermSendVisualLines 1` (sends to terminal 1).

**Output**

Terminal might show:

```
$ ls
file1.txt  file2.py
$ 
```

With the float centered over the editor.

### Managing Multiple Terminals

Toggleterm supports numbered terminals for organization.

- Create: `:ToggleTerm 2 direction=float`.
- Toggle specific: `:2ToggleTerm`.
- Name them: `name = "myterm"` in config for persistence.
- List: No built-in list, but use buffer commands like `:ls` to see terminal buffers.
- Close all: `:ToggleTermAll`.

Useful for workflows like one terminal for building, another for logs.

**Key Points**
- Instances are global, not per-window.
- Custom terminals: Define in config with `cmd = "htop"`.
- [Unverified]: Buffer names like "#toggleterm#1" for identification.

**Example**

Setup two terminals:

1. `:1ToggleTerm` for general.
2. `:2ToggleTerm cmd="watch -n 1 ls"`.
3. Toggle between with `:1ToggleTerm` and `:2ToggleTerm`.

### Advanced Usage and Integration

- **Lazygit Integration**: `<leader>gg` opens git UI in float.
- **Custom Commands**: Define terminals for tools like ranger or btop.
- **Floating Options**: Customize `winblend`, highlights, or animations.
- **Scripting**: Use Lua API: `local Terminal = require('toggleterm.terminal').Terminal; local myterm = Terminal:new({ cmd = 'bash' }); myterm:toggle()`.
- **With DAP/Neotest**: Run debug terminals or test outputs in floats.
- [Speculation]: Future updates might add better multi-session management.

Combine with noice.nvim for enhanced popup handling.

**Next Steps**
- Experiment with custom configs in a sample setup.
- Integrate with project-specific tools like make or npm.
- Review toggleterm docs with `:help toggleterm` for more options.

---

