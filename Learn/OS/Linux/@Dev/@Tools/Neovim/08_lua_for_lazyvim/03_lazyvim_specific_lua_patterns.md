## LazyVim-Specific Lua Patterns


### Introduction to Lua Configuration

LazyVim uses Lua for all configurations, leveraging Neovim's Lua API and the lazy.nvim plugin manager. Configurations are modular, placed in directories like `lua/config/` for core settings and `lua/plugins/` for plugin specs. Common patterns include returning tables from files, using `vim.opt` for options, `vim.keymap.set` for mappings, and plugin specs as tables with keys like `opts` for options and `keys` for lazy-loaded keymaps.

These patterns promote lazy loading, where code executes only when needed, improving startup times. Behavior may vary with Neovim versions or lazy.nvim updates.

**Key Points**
- Files in `lua/` are auto-loaded if they match patterns like `config/*.lua` or `plugins/*.lua`.
- Return values from files are used directly (e.g., options table).
- Use `require` for modular imports, avoiding global pollution.

### Plugin Specification Patterns

Plugin specs define how plugins are installed and configured. In `lua/plugins/`, each file returns a table or array of tables. Lazy.nvim processes these for installation, loading, and setup.

Basic pattern: A table with repository URL as key, and options like `enabled`, `opts`, `config`.

**Example**
```lua
-- lua/plugins/example.lua
return {
  "username/repo",
  enabled = true,  -- Conditional loading
  opts = {         -- Passed to plugin's setup function
    some_option = "value",
  },
  config = function(_, opts)
    require("plugin").setup(opts)
  end,
}
```

For multiple plugins in one file:

**Example**
```lua
-- lua/plugins/multiple.lua
return {
  { "plugin1/repo", opts = {} },
  { "plugin2/repo", lazy = true, event = "VeryLazy" },  -- Load on event
}
```

**Key Points**
- `lazy = true`: Defers loading until conditions met (e.g., `event`, `cmd`, `ft` for filetypes).
- `dependencies`: Array of other plugins or specs.
- Overrides: Return `{ "existing/plugin", opts = function(_, opts) return vim.tbl_deep_extend("force", opts, { custom = true }) end }` to merge options.

### Keymap Configuration Patterns

Keymaps are set in `lua/config/keymaps.lua`, returning nothing but using `vim.keymap.set`. Patterns include descriptive options and leader-based mappings. LazyVim predefines many under `<leader>`.

Pattern for grouped keymaps with which-key.nvim integration:

**Example**
```lua
-- lua/config/keymaps.lua
local wk = require("which-key")
wk.add({
  { "<leader>c", group = "Code" },
  { "<leader>ca", "<cmd>CodeAction<CR>", desc = "Code Action" },
})
```

Direct setting:

**Example**
```lua
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open Explorer" })
```

**Key Points**
- Modes: "n" (normal), "v" (visual), "i" (insert), etc.
- Options: `{ silent = true, noremap = true, desc = "Description" }` for which-key.
- Lazy loading: In plugin specs, use `keys` array to load on key press.

### Options and Autocmd Patterns

Global options in `lua/config/options.lua` use `vim.opt`. Patterns involve setting editor behaviors.

**Example**
```lua
-- lua/config/options.lua
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
```

For autocmds (event-driven commands) in `lua/config/autocmds.lua`:

**Example**
```lua
-- lua/config/autocmds.lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
  end,
})
```

**Key Points**
- `vim.opt` is preferred over `vim.o` for type safety.
- Autocmds use `nvim_create_autocmd` with event, pattern, and callback/command.
- Groups: Use `group = vim.api.nvim_create_augroup("GroupName", { clear = true })` to manage.

### Lazy Loading and Event Patterns

LazyVim emphasizes lazy loading via events. Common events: "VeryLazy" (after startup), "BufEnter", "InsertEnter".

In plugin specs:

**Example**
```lua
-- lua/plugins/lazy-example.lua
return {
  "plugin/repo",
  event = "BufReadPre",  -- Load before reading buffer
  cmd = "PluginCommand", -- Or on command execution
  ft = "lua",            -- On filetype
}
```

For custom lazy modules:

**Example**
```lua
-- lua/lazy-module.lua
local M = {}
function M.setup() ... end
return M
```
Then require lazily: `local mod = require("lazy-module")`

**Key Points**
- Avoid immediate `require` in init files to maintain laziness.
- Use `LazyFile` event for file-related plugins [Inference from lazy.nvim docs].

### Extras and Overrides Patterns

LazyVim extras are optional plugins enabled via `:LazyExtras`. To customize, create files like `lua/plugins/extras/lang/python.lua` overriding defaults.

Pattern for enabling extras programmatically:

**Example**
```lua
-- init.lua or lua/config/lazy.lua
require("lazy").setup({
  spec = {
    { import = "lazyvim.plugins.extras.lang.python" },
  },
})
```

For overrides: Return a table merging with original.

**Example**
```lua
-- lua/plugins/extras/lang/python.lua
return {
  { "linux-cultist/venv-selector.nvim", enabled = false },  -- Disable sub-plugin
}
```

**Key Points**
- Extras are imported as modules.
- Use `enabled = false` to disable core plugins.
- Behavior may vary if extras conflict [Unverified from user reports].

### Utility Functions and Module Patterns

Common utilities: `vim.tbl_extend`, `vim.fn`, custom helpers.

Module pattern:

**Example**
```lua
-- lua/utils/example.lua
local M = {}

M.func = function(arg)
  return arg * 2
end

return M
```

Usage: `local utils = require("utils.example"); utils.func(5)`

**Key Points**
- Namespaces: Avoid globals; use modules.
- Error handling: Wrap in `pcall` for robustness.

### Practical Implementation Examples

**Scenario: Custom Plugin with Lazy Keymaps**
```lua
-- lua/plugins/custom.lua
return {
  "custom/repo",
  keys = {
    { "<leader>xx", "<cmd>CustomCmd<CR>", desc = "Custom Action" },
  },
  opts = {},
}
```

**Scenario: Conditional Options Based on Environment**
```lua
-- lua/config/options.lua
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"  -- Detect SSH
```

**Scenario: Autocmd for Buffer-Specific Settings**
```lua
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.md",
  callback = function()
    vim.opt_local.spell = true
  end,
})
```

**Output**
These patterns result in modular, performant configs. Inspect with `:Lazy` for loaded plugins.

### Common Pitfalls and Best Practices

- Avoid side effects in returned tables; use `config` functions.
- Test with `nvim --clean` to isolate.
- Update patterns with LazyVim versions; check changelog for changes [Speculation on future updates].
- Behavior may vary with plugin interactions or Neovim APIs.

**Conclusion**
LazyVim's Lua patterns focus on modularity, laziness, and extensibility, using tables, events, and APIs for efficient customization.

**Next Steps**
- Review LazyVim docs at lazyvim.org.
- Experiment in a fresh config.
- Join LazyVim Discord for community patterns.

---

