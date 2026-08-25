## Multiple Terminal Management


### Overview of Terminal Handling

LazyVim utilizes `snacks.nvim` for terminal management, providing a streamlined way to open, toggle, and interact with terminals within the editor. The core function is `Snacks.terminal`, which can create floating or split terminals (configured to bottom splits by default in recent LazyVim versions). This setup supports running shell commands, tools like lazygit, and custom scripts. Multiple terminals can be opened, each in its own buffer, with toggling focused on the most recent instance. Persistence across Neovim sessions is not built-in, so terminals close when exiting. Behavior may vary based on LazyVim version, user configurations, and whether extras like `ui.edgy` are enabled, which can influence window placement.

**Key Points**
- Defaults to bottom split windows in LazyVim 13.x and later, but can be customized to float.
- Integrates with Neovim's terminal mode for seamless navigation.
- Supports custom commands for specialized terminals (e.g., Python REPL, htop).
- [Inference: In 2026 versions, updates may include better multi-instance handling, but no major changes noted beyond bug fixes.]

### Enabling and Setup

`snacks.nvim` is included in LazyVim core, so no extra enabling is required for basic use. For customizations, add configurations in `~/.config/nvim/lua/plugins/snacks.lua` or override defaults in `config.lua`.

Global config example:
```lua
vim.g.snacks_animate = true  -- Enable animations if desired
```

Plugin spec for terminal module:
```lua
return {
  "folke/snacks.nvim",
  opts = {
    terminal = {
      enabled = true,
      defaults = {
        border = "rounded",
        size = { width = 0.8, height = 0.6 },
      },
    },
  },
}
```

To revert to floating instead of split (if default is split):
[Speculation: Adjust via `snacks.win` style or LazyVim opts, as users report configuration changes in forums.]

### Opening and Toggling Terminals

Use `Snacks.terminal` to open or toggle a terminal. By default, it uses the shell ($SHELL) in the current working directory.

Basic call:
```lua
Snacks.terminal()  -- Toggles the last terminal or opens a new one
```

With options:
```lua
Snacks.terminal({
  cmd = "htop",
  cwd = vim.fn.expand("~"),
  border = "single",
  size = { height = 0.4 },  -- Fractional or absolute size
})
```

Low-level open:
```lua
Snacks.terminal.open({ cmd = "python" })  -- Always creates new if specified
```

Toggling hides the visible terminal or shows the last hidden one. For multiple, repeated calls without cmd may reuse or create new based on state.

**Example**
Keymap to open a home dir terminal:
```lua
vim.keymap.set("n", "<leader>fT", function()
  Snacks.terminal(nil, { cwd = vim.fn.expand("~") })
end, { desc = "Terminal (Home Dir)" })
```

**Output**
A bottom split (or float) may appear with the shell prompt. Navigation in terminal mode uses <C-h>, <C-j>, <C-k>, <C-l> to move between windows. Closing with :q or exit may hide it for later toggle.

### Managing Multiple Terminals

Multiple terminals are supported by creating separate buffers, each named "Snacks Terminal #". Toggling applies to the last used; to access specific ones, use buffer navigation or custom naming.

- Create new: Call `Snacks.terminal.open()` with unique cmd or bufname.
- List: Use :buffers to see terminal buffers.
- Switch: Navigate via <leader>bb (buffer picker) or custom keymaps.
- Naming: Set bufname in opts for identification, e.g., { bufname = "Python REPL" }.
- Hiding/Showing: Toggle hides all visible; to show specific, use vim.api.nvim_set_current_buf(bufnr).

No built-in selector for multiples; rely on Neovim buffer management. [Unverified: Community plugins like telescope may integrate for terminal picking.]

**Example**
Opening two terminals:
```lua
-- First terminal: shell
Snacks.terminal()
-- Second: lazygit
Snacks.terminal({ cmd = "lazygit" })
```

To toggle specific (manual):
```lua
local term_bufs = vim.tbl_filter(function(buf) return vim.bo[buf].buftype == "terminal" end, vim.api.nvim_list_bufs())
-- Then set current to term_bufs[1], etc.
```

**Output**
Multiple bottom splits may stack or replace based on config; toggling one may not affect others. Behavior may vary if edgy.nvim positions them differently.

### Keymaps and Navigation

LazyVim provides defaults for ease:

- <C-/> or <C-_> (normal/terminal mode): Toggle terminal.
- <leader>ft: Open in cwd.
- <leader>fT: Open in home.

In terminal mode:
- <C-h>: Go left window.
- <C-j>: Go down.
- <C-k>: Go up.
- <C-l>: Go right.

Custom keymap example:
```lua
vim.keymap.set({ "n", "t" }, "<leader>tp", function() Snacks.terminal({ cmd = "python" }) end, { desc = "Python Terminal" })
```

**Key Points**
- Keymaps can be ignored in which-key for cleaner UI.
- Navigation keys remap to window movement, escaping insert mode if needed.

### Configurations and Customizations

Configure via opts.table in plugin spec.

Defaults:
- border: "rounded"
- size: 80% width, 60% height (for float; adjusted for split)

Override:
```lua
opts.terminal.defaults = {
  border = "double",
  size = { height = 0.3 },  -- For bottom split
  wo = { spell = false, number = false },
}
```

To force float (if LazyVim defaults to split):
[Inference: Set style or use snacks.win opts; check LazyVim source for exact.]

Disable: opts.terminal.enabled = false

### Integrations with Other Tools

- **Lazygit**: Snacks.lazygit() opens lazygit in a terminal, auto-sets colors.
- **Gitui**: Configured in extras.util.gitui, uses Snacks.terminal({ "gitui" }).
- **Other**: Extras like util.btop use similar, e.g., Snacks.terminal({ "btop" }).
- Code runners or DAP may pipe output to terminals.

**Example**
Lazygit keymap (LazyVim default in extras):
```lua
vim.keymap.set("n", "<leader>gg", Snacks.lazygit, { desc = "Lazygit (cwd)" })
```

**Output**
Opens lazygit UI in terminal split; exit hides for later toggle.

### Advanced Usage

- Custom formatter for names: Override via Lua functions.
- Events: Hook into BufEnter for terminal buffers.
- Persistence: Add autocommand to save/restore, e.g., using persistence.nvim.
- Multi-window: With edgy.nvim extra, terminals position in sidebars.

**Example**
Persistent terminal script (custom):
```lua
autocmd("VimLeavePre", {
  callback = function()
    -- Save terminal bufnrs
  end,
})
```

**Output**
May allow reopening previous terminals on startup, but requires manual implementation.

**Conclusion**
Snacks.terminal provides flexible management for multiple terminals in LazyVim, balancing simplicity with customization for development workflows.

**Next Steps**
- Add custom keymaps in `~/.config/nvim/lua/config/keymaps.lua` for specific commands.
- Enable related extras like `util.gitui` via :LazyExtras.
- Review `snacks.nvim` docs with :help snacks.terminal for API details and test in a project to note behavior differences.

---

