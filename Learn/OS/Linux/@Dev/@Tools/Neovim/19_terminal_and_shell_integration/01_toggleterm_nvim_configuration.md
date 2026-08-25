## toggleterm.nvim Configuration


### Introduction

toggleterm.nvim is a Lua plugin that simplifies managing multiple terminal windows within Neovim, allowing users to toggle terminals in various orientations like horizontal, vertical, floating, or tabbed. It supports custom terminals for tools such as lazygit or htop, and includes features like shading, callbacks, and persistent states. In LazyVim, toggleterm.nvim is not included as a default extra but can be added manually through a plugin specification file, integrating with LazyVim's plugin management system. This enables seamless use alongside other LazyVim features, though users may need to define custom keymaps since no predefined ones are provided by LazyVim for this plugin. Behavior may vary depending on Neovim version, terminal emulator, and conflicting plugins.

### Installation

To integrate toggleterm.nvim into LazyVim, create a file in `lua/plugins/` (e.g., `toggleterm.lua`) and specify the plugin with desired options. This leverages lazy.nvim for loading.

#### Basic Installation in LazyVim
Add the following to `lua/plugins/toggleterm.lua`:
```lua
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
  },
}
```
This installs the latest version and applies default configurations. For more control, use `opts` to pass a table:
```lua
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      -- Custom options here
    },
  },
}
```
Run `:Lazy sync` to install. If pinning to a major version to avoid breaking changes, add `tag = "v2.*"`.

#### Dependencies and Requirements
- Requires Neovim ≥ 0.8.
- Ensure `set hidden` is enabled in your config (e.g., in `lua/config/options.lua`) to prevent terminals from being discarded when closed.
- No additional dependencies are needed, but for custom terminals, ensure the external commands (e.g., lazygit) are installed on your system.

[Inference] If using LazyVim's UI extras like edgy.nvim, test for layout compatibility as toggleterm's floating windows may interact differently.

### Configuration

Configuration is handled via `require("toggleterm").setup(opts)`, where `opts` is a table of options. In LazyVim, pass this through the `opts` key in the plugin spec, which merges with defaults.

#### Default Options
Key options include:
- `size`: Number or function (default: 20) - Sets height for horizontal or width for vertical terminals. As a function, it receives the Terminal object for dynamic sizing.
- `open_mapping`: String or table (default: nil) - Keybinding to toggle terminals, e.g., `[[<c-\>]]`. Supports counts for specific terminals.
- `on_create`, `on_open`, `on_close`, `on_stdout`, `on_stderr`, `on_exit`: Functions - Callbacks for terminal lifecycle events.
- `hide_numbers`: Boolean (default: true) - Hides line numbers in terminal buffers.
- `shade_filetypes`: Table (default: {}) - Filetypes exempt from shading; use `"none"` to disable all shading.
- `autochdir`: Boolean (default: false) - Syncs terminal cwd with Neovim's on open.
- `highlights`: Table - Custom highlight groups for the terminal.
- `shade_terminals`: Boolean (default: true) - Enables automatic darkening of terminal backgrounds.
- `shading_factor`: Number (default: -30) - Darkening percentage (negative values darken).
- `shading_ratio`: Number (default: -3) - Ratio for light/dark backgrounds.
- `start_in_insert`: Boolean (default: true) - Opens in insert mode.
- `insert_mappings`: Boolean (default: true) - Applies `open_mapping` in insert mode.
- `terminal_mappings`: Boolean (default: true) - Applies `open_mapping` in terminal mode.
- `persist_size`: Boolean (default: true) - Remembers terminal sizes.
- `persist_mode`: Boolean (default: true) - Remembers last mode (normal/insert).
- `direction`: String (default: "vertical") - Default orientation: "vertical", "horizontal", "tab", or "float".
- `close_on_exit`: Boolean (default: true) - Closes window on process exit.
- `clear_env`: Boolean (default: false) - Uses only specified env variables.
- `shell`: String or function (default: vim.o.shell) - Shell to run.
- `auto_scroll`: Boolean (default: true) - Scrolls to bottom on output.
- `float_opts`: Table - Floating window settings (border, width, height, etc.).
- `winbar`: Table (default: {enabled = false}) - Enables winbar with name formatter (requires Neovim nightly).
- `responsiveness`: Table (default: {horizontal_breakpoint = 135}) - Column breakpoint for stacking terminals.

#### LazyVim-Specific Configuration
In `lua/plugins/toggleterm.lua`:
```lua
return {
  {
    "akinsho/toggleterm.nvim",
    opts = {
      open_mapping = [[<c-\>]],
      direction = "float",
      float_opts = {
        border = "curved",
        width = 120,
        height = 30,
      },
    },
  },
}
```
This sets a keymap and customizes the floating terminal. Behavior may vary if keymaps conflict with LazyVim defaults; override in `lua/config/keymaps.lua` if needed.

### Key Features

toggleterm.nvim enhances terminal management with modular and extensible tools.

**Key Points**
- Supports multiple orientations with limited multi-window for float/tab.
- Persistent state for size, mode, and directory.
- Command execution via `TermExec` without focusing the terminal.
- Custom shading and highlights for better visibility.
- Callbacks for integrating with other plugins or workflows.
- Winbar integration for naming and navigation (experimental).
- Sending lines/selections from buffers to terminals.
- Custom terminal instances for specific tools.

### Usage

Use commands or Lua API for interaction. Keymaps are auto-set if `open_mapping` is defined.

#### Commands
- `:ToggleTerm` - Toggles the last or specified (with count) terminal.
- `:ToggleTermToggleAll` - Toggles all open terminals.
- `:TermExec cmd="command" [dir=~/path] [go_back=0]` - Runs a command in a terminal.
- `:ToggleTermSendCurrentLine [ID]` - Sends current line to terminal.
- `:ToggleTermSendVisualLines [ID]` - Sends visual lines.
- `:ToggleTermSendVisualSelection [ID]` - Sends visual selection.
- `:TermSelect` - Selects a terminal interactively.
- `:ToggleTermSetName` - Sets a display name.

#### Keymaps in LazyVim
Define in the plugin opts or separately:
```lua
-- In lua/config/keymaps.lua
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Toggle Terminal" })
```
For terminal mode escapes:
```lua
-- In a custom autocmd
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*toggleterm#*",
  callback = function()
    local opts = { buffer = 0 }
    vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
  end,
})
```
Behavior may vary in terminal mode if `persist_mode` is enabled.

### Practical Examples

#### Custom Floating Terminal for Lazygit
```lua
-- In lua/plugins/toggleterm.lua or a separate file
local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({
  cmd = "lazygit",
  hidden = true,
  direction = "float",
  float_opts = { border = "double" },
  on_open = function(t)
    vim.cmd("startinsert!")
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = t.bufnr, noremap = true, silent = true })
  end,
})

function _G._lazygit_toggle()
  lazygit:toggle()
end

vim.keymap.set("n", "<leader>lg", "<cmd>lua _lazygit_toggle()<CR>", { desc = "LazyGit" })
```
This creates a hidden terminal toggled via `<leader>lg>`.

**Example**
Sending lines:
```lua
-- In lua/config/keymaps.lua
vim.keymap.set("v", "<leader>ts", function()
  require("toggleterm").send_lines_to_terminal("visual_lines", true, { args = vim.v.count })
end, { desc = "Send to Terminal" })
```

**Output**
When toggling, a terminal window appears with the specified orientation and shading. Exact appearance depends on theme and config.

### Customization

- Override highlights in `opts.highlights` for theme matching.
- Use `dir = "git_dir"` for git root detection.
- For REPLs, set `trim = false` when sending lines.
- Extend with callbacks, e.g., for logging output.
- [Unverified] Recent versions may include improved responsiveness for wide monitors.

### Troubleshooting

- If `:ToggleTerm` is not recognized, verify the plugin file is in `lua/plugins/` and run `:Lazy sync`.
- Keymap conflicts: Check with `:Lazy log` or which-key.
- Shading issues: Disable with `shade_terminals = false`.
- For terminal mode navigation, add custom mappings as shown.
- Behavior may vary in WSL or remote sessions; test cwd syncing.

**Conclusion**
toggleterm.nvim provides flexible terminal management in LazyVim, suitable for workflows involving multiple shells or integrated tools.

**Next Steps**
- Add custom keymaps in `lua/config/keymaps.lua`.
- Explore integrations with tools like lazygit or ranger.
- Refer to the plugin README for advanced callbacks and API.

---

