## Notification System


### Overview of Noice.nvim and Nvim-Notify

Noice.nvim enhances the user interface by rerouting messages, search, and command-line outputs to customizable popups, mini-views, or notifications, reducing clutter in the command line area. It integrates with nvim-notify, which handles rendering notifications as floating windows with animations and history management. In LazyVim, these plugins are included by default to provide a modern, non-intrusive messaging experience.

**Key Points**
- Noice.nvim manages routing of vim.ui functions like vim.notify, cmdline, and messages.
- Nvim-notify provides the backend for displaying notifications with customizable styles, timeouts, and levels (info, warn, error).
- LazyVim's default setup enables noice.nvim with presets for easier configuration, such as smaller message views.
- Behavior may vary based on other plugins like lsp or telescope, which can override or integrate with these notifications.
- [Inference] Updates to these plugins post-2023 might introduce new features like better telescope integration or improved virtual text handling.

### Installation and Setup in LazyVim

LazyVim includes noice.nvim and nvim-notify as core extras, enabled via the lazyvim.config.json or init.lua. No manual installation is typically needed unless customizing beyond defaults.

**Key Points**
- Enable via require("lazyvim.config").extras.ui.noice = true; or similar in configuration.
- Dependencies: nvim-notify is required by noice.nvim; treesitter for syntax highlighting in messages.
- Custom options set in LazyVim's plugins/ui/noice.lua, such as lsp overrides or view routing.
- Check :Lazy to confirm versions; updates via :Lazy update.

**Example**
To enable noice.nvim if not already:
```lua
-- In lua/config/lazy.lua or similar
require("lazy").setup({
  -- ...
  defaults = { lazy = true },
  install = { missing = true },
  -- Add or ensure extra
  extras = { "ui.noice" },
})
```
Reload with :Lazy reload.

### Configuration Options

Noice.nvim offers extensive customization through its setup function, while nvim-notify focuses on render styles and stages.

#### Noice.nvim Configuration

**Key Points**
- cmdline: Routes command-line to popup or mini view.
- messages: Handles echo messages, searchable with / or telescope.
- lsp: Overrides progress, hover, signature to use noice views.
- views: Customizable presets like mini (borderless floating), split, or popup.
- routes: Filter and redirect messages based on patterns, e.g., skip noisy plugins.

**Example**
Custom setup in lua/plugins/ui.lua:
```lua
return {
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true, -- use classic bottom cmdline for search
        long_message_to_split = true, -- long messages to split view
      },
    },
  },
}
```

#### Nvim-Notify Configuration

**Key Points**
- levels: INFO, WARN, ERROR, DEBUG, TRACE with corresponding icons.
- timeout: Default 3000ms; set per level or global.
- render: Styles like "default", "minimal", "simple"; custom functions possible.
- stages: Animation effects like "fade_in_slide_out".
- background_colour: Matches theme or custom.

**Example**
Extend in lua/plugins/ui.lua:
```lua
return {
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 5000,
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width = function() return math.floor(vim.o.columns * 0.75) end,
      on_open = function(win) vim.api.nvim_win_set_config(win, { zindex = 100 }) end,
    },
  },
}
```

### Usage and Commands

Interact with notifications via keymaps and commands provided by these plugins.

**Key Points**
- vim.notify(msg, level, opts): Programmatic API for sending notifications.
- :Noice: View message history in a split.
- :Noice telescope: Search history with telescope.nvim.
- Dismiss: Default \<leader>sn to dismiss all, or hover and close.
- [Unverified] In LazyVim, \<leader>un may be mapped for notifications menu.

**Example**
Trigger a test notification:
:lua vim.notify("Test message", "info")
This displays a floating popup with "Test message" and info icon, fading after timeout.

**Output**
A floating window appears in the top-right (default position) with content like:
[INFO] Test message
It may animate in and out based on stages.

### Integration with Other Plugins

Noice.nvim integrates seamlessly with LSP, cmp, and telescope in LazyVim.

**Key Points**
- LSP progress: Shown as mini notifications instead of cmdline spam.
- Command-line: Popup for /, :, ?, with history and wildmenu.
- Conflicts: May need routes to filter unwanted messages from plugins like oil.nvim.
- [Speculation] Future versions might add better support for nvim-lspconfig's inlay hints.

**Example**
Route to skip annoying messages:
```lua
opts = {
  routes = {
    {
      filter = { event = "msg_show", find = "written" },
      opts = { skip = true },
    },
  },
}
```

### Troubleshooting Common Issues

Issues may arise from conflicts or misconfigurations.

**Key Points**
- No notifications: Check if noice is enabled; :checkhealth noice.
- Overlapping windows: Adjust zindex or positions in opts.
- Performance: In large message histories, searching may lag; clear with :Noice dismiss.
- Theme mismatches: Ensure notify respects colorscheme; may require manual icon setup.
- Behavior may vary with Neovim versions (e.g., 0.10+ has better popup support).

**Example**
If cmdline not showing in popup:
Ensure opts.cmdline.view = "cmdline_popup"

### Advanced Customization

For power users, extend with Lua functions or additional plugins.

**Key Points**
- Custom renderers: Define functions for nvim-notify.render.
- Hooks: on_open, on_close for notify windows.
- Presets: noice has command_palette, inc_rename for specialized views.
- Combine with fidget.nvim for alternative LSP progress if needed.

**Next Steps**
- Explore :help noice.nvim and :help notify for full docs.
- Experiment with custom routes for noisy plugins.
- Consider adding telescope extension for better history search.

**Conclusion**
The combination of noice.nvim and nvim-notify in LazyVim transforms the notification experience into a polished, distraction-free system, improving workflow by keeping the interface clean while providing accessible message history and customizable displays. With proper setup, it adapts to various editing needs, though tuning may be required for specific plugin ecosystems.

---

