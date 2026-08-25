## Which-Key - Keybinding Discovery


### Overview of Which-Key

Which-Key is a plugin that displays a popup showing available keybindings when a prefix key is pressed and held, aiding in discovery and navigation of commands. In LazyVim, it's included by default as "folke/which-key.nvim" to enhance usability, especially for complex keymaps under leaders like `<leader>` or `<c-w>`. It integrates with Neovim's API to register and categorize keymaps, showing descriptions from the `desc` option in `vim.keymap.set`. Behavior may vary with Neovim versions (e.g., better support in 0.8+) or if disabled in custom configs.

**Key Points**
- Triggers after a delay (default 500ms) on incomplete key sequences.
- Groups keymaps logically (e.g., "code", "search") for better organization.
- Supports modes like normal, visual, insert.
- LazyVim pre-registers many groups for its defaults.

### Installation and Enabling in LazyVim

Which-Key is pre-installed in LazyVim via lazy.nvim. To confirm or customize, check `lua/plugins/which-key.lua` or the core spec. If removed, add back in `lua/plugins/editor.lua`.

**Example**
```lua
-- lua/plugins/editor.lua
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",  -- Load after startup
    opts = {
      preset = "helix",  -- Layout style: classic, modern, helix
      delay = 500,       -- Milliseconds before popup
      win = {
        border = "single",  -- Popup border style
        padding = { 1, 2 }, -- Top/bottom, left/right
      },
    },
  },
}
```

To disable: Set `enabled = false` in the spec. Note that disabling may reduce discoverability of LazyVim's extensive keymaps [Inference from user feedback].

### Configuring Key Groups and Registrations

Which-Key uses `require("which-key").add` to register mappings and groups. In LazyVim, this is done automatically for defaults, but custom groups can be added in `lua/config/keymaps.lua`.

Pattern for registering:

**Example**
```lua
-- lua/config/keymaps.lua
local wk = require("which-key")
wk.add({
  { "<leader>g", group = "Git" },  -- Group name
  { "<leader>gs", "<cmd>Git status<CR>", desc = "Git Status" },
  { "<leader>gc", "<cmd>Git commit<CR>", desc = "Git Commit" },
  mode = { "n", "v" },  -- Apply to modes
})
```

This creates a "Git" group under `<leader>g`, showing subgroups or commands on press.

**Key Points**
- `group`: Defines a named category.
- `desc`: Provides the description shown in popup.
- `icon`: Optional Nerd Font icon for visual cues.
- `proxy`: For aliasing prefixes.
- Registrations can be buffer-local with `buffer = bufnr`.

### Customizing Popup Appearance and Behavior

Options in `opts` table control visuals and triggers. LazyVim defaults to a modern look, but overrides are possible.

**Example**
```lua
-- In plugin spec opts
opts = {
  icons = {
    breadcrumb = "»",  -- Separator
    separator = "➜",   -- Key to desc
    group = "+",       -- Group indicator
  },
  filter = { "<CR>", "<Tab>" },  -- Ignore certain keys
  triggers = {
    { "<auto>", mode = "nxsot" },  -- Auto for normal, visual, etc.
    { "<leader>", mode = { "n", "v" } },
  },
}
```

**Key Points**
- `triggers`: Defines when to show (e.g., after `<leader>`).
- `layout`: Controls alignment, spacing.
- `sort`: Function to order keys (e.g., by key, desc).
- Appearance may vary with colorscheme; link highlights like `WhichKey` to customize.

### Integration with Other Plugins

Which-Key works with LazyVim's ecosystem, enhancing plugins like Telescope, LSP, or flash.nvim by showing their keymaps.

For example, LSP keymaps under `<leader>c` (code) are grouped as "Code" with subgroups like "action", "rename".

To integrate custom plugins:

**Example**
In plugin config:
```lua
config = function()
  require("which-key").add({
    { "<leader>t", group = "Test" },
    { "<leader>tt", "<cmd>TestRun<CR>", desc = "Run Tests" },
  })
end
```

**Key Points**
- Automatic for plugins using `desc` in keymaps.
- Manual registration needed for older plugins.
- Conflicts rare, but overlapping prefixes may hide keys [Unverified from potential issues].

### Discovering Keybindings Practically

To explore:
- Press `<leader>` and wait: Popup shows groups like "b" (buffer), "s" (search).
- Press `<c-w>` for window commands.
- Use `:WhichKey` command to show specific prefix, e.g., `:WhichKey <leader>`.

**Example**
In normal mode:
1. Press `<leader>s` – shows search subgroups like "g" (grep), "b" (buffer).
2. Press `g` – executes live grep if bound.

**Output**
Popup example (text representation):
```
s (Search)
  / Grep (Root Dir)
  <space> Find Files (Root Dir)
  b Buffers
  ...
```

### Advanced Features and Operators

Supports operator-pending mode for motions and custom operators.

**Example**
For visual mode selections:
```lua
wk.add({
  { "g", group = "Goto", mode = "v" },
  { "gc", "<cmd>Comment<CR>", desc = "Comment", mode = "v" },
})
```

Also, `require("which-key").show({ keys = "<leader>", loop = true })` for programmatic display.

**Key Points**
- `operators`: Define custom like `gc` for commenting.
- `plugins`: Enable integrations like spelling, marks.
- Behavior in terminal or insert modes may differ.

### Troubleshooting Common Issues

- Popup not showing: Check `delay` too high or triggers misconfigured.
- Missing desc: Ensure keymaps have `desc` option.
- Overlaps: Use `cond` in specs to conditional load.
- Performance: Minimal impact, but in large configs, delay may feel longer [Speculation based on reports].

### Practical Examples

**Scenario: Adding a New Group for Debugging**
```lua
wk.add({
  { "<leader>d", group = "Debug" },
  { "<leader>db", "<cmd>DapBreakpoint<CR>", desc = "Breakpoint" },
})
```

**Scenario: Custom Triggers**
```lua
opts.triggers = { "<leader>", "<c-w>", "z" }  -- Add z for folds
```

**Scenario: Buffer-Local Registrations**
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function(ev)
    wk.add({
      { "<localleader>r", "<cmd>Reload<CR>", desc = "Reload Lua", buffer = ev.buf },
    })
  end,
})
```

**Output**
Enhances discovery without memorizing keys.

**Conclusion**
Which-Key in LazyVim simplifies keybinding discovery through interactive popups, making complex setups accessible with minimal configuration.

**Next Steps**
- Consult `:help which-key.nvim` for full options.
- Experiment by adding custom groups in keymaps.lua.
- Review LazyVim's default registrations in its source.

---

