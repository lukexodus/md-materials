## Context Awareness


### Introduction to nvim-treesitter-context

The nvim-treesitter-context plugin enhances navigation and understanding in code by displaying contextual information, such as surrounding function or class definitions, at the top of the window. It leverages Treesitter for parsing and highlighting, integrating with LazyVim's Treesitter setup to provide sticky headers that update as you scroll. This feature aids in maintaining awareness of scope without constant scrolling, particularly in large files.

**Key Points**
- Relies on `nvim-treesitter` for syntax parsing; without it, functionality is limited.
- Displays context lines in a floating or virtual text manner, configurable for appearance and behavior.
- Supports multiple languages where Treesitter queries are available.
- Behavior may vary with file size, Treesitter parser accuracy, and window dimensions.

### Prerequisites

Ensure core dependencies are in place within your LazyVim configuration.

**Key Points**
- Required: `nvim-treesitter/nvim-treesitter` for parsing.
- Optional but recommended: `nvim-treesitter/nvim-treesitter-textobjects` for enhanced selections.
- These are typically bundled in LazyVim's defaults; check `lua/plugins/treesitter.lua`.
- No external system tools needed, but a compatible Treesitter parser for the language must be installed via `:TSInstall`.

If missing, add the plugin:

**Example**
```lua
-- In lua/plugins/treesitter.lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "lua", "python", "typescript" },  -- Add languages as needed
    },
  },
  { "nvim-treesitter/nvim-treesitter-context" },
}
```

Run `:Lazy sync` to install.

### Installing nvim-treesitter-context

Installation occurs through LazyVim's plugin manager. The plugin is lightweight and loads on demand.

**Key Points**
- Add to your plugins spec; LazyVim handles dependencies.
- Post-install, Treesitter parsers may need updating with `:TSUpdate`.
- If using Mason for other tools, it's unrelated here.

**Example**
```lua
-- In lua/plugins/editor.lua or similar
return {
  "nvim-treesitter/nvim-treesitter-context",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "VeryLazy",  -- Load lazily
}
```

After syncing, verify with `:checkhealth treesitter-context`.

### Configuring the Plugin

Configuration is done via the `opts` table, allowing customization of appearance, behavior, and language-specific settings.

**Key Points**
- Default settings provide a balanced experience, but tweaks can improve visibility.
- Options include max lines to display, multiline thresholds, and separators.
- Enable/disable per-filetype or globally.
- Changes might require buffer reload with `:e` for application; effects can differ across languages due to parser variations.

**Example**
Basic setup:

```lua
-- In the plugin spec
opts = {
  enable = true,              -- Global enable
  max_lines = 5,              -- Limit context lines
  min_window_height = 15,     -- Disable if window too small
  line_numbers = true,        -- Show line numbers in context
  multiline_threshold = 20,   -- For multiline nodes
  trim_scope = "outer",       -- Trim to outer/inner scope
  mode = "cursor",            -- 'cursor' or 'topline'
  separator = "-",            -- Visual separator
  zindex = 20,                -- Float z-index
  on_attach = nil,            -- Custom attach function
}
```

For filetype-specific:

```lua
opts = {
  patterns = {
    lua = {
      "function",
      "table",
    },
    python = {
      "function_definition",
      "class_definition",
    },
  },
}
```

This specifies nodes to consider for context in Lua and Python files.

### Usage and Key Features

Once configured, the plugin activates automatically in supported buffers.

**Key Points**
- Context updates on cursor movement or scroll.
- Jump to context with default keymaps if set.
- Integrates with statusline or winbar for persistent display.
- In large nested structures, it may show multiple levels; depth depends on parser.

**Example**
In a Lua file with nested functions, scrolling down might show at the top:

```
function outer()
  function inner()
```

Use `<leader>cc` (if mapped) to toggle; actual keymaps can be customized.

To add keymaps:

```lua
-- In lua/config/keymaps.lua
vim.keymap.set("n", "<leader>cc", require("treesitter-context").toggle, { desc = "Toggle Context" })
vim.keymap.set("n", "[c", require("treesitter-context").go_to_context, { desc = "Jump to Context" })
```

Jumping navigates to the start of the displayed context; success varies with node complexity.

### Advanced Customization

#### Custom Highlighting
Link to existing highlight groups.

**Example**
```lua
vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "NONE", fg = "LightBlue" })
vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { fg = "Gray" })
vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "Gray" })
```

Apply after plugin load; colors may render differently based on theme.

#### Integration with Other Plugins
Combine with `nvim-treesitter-refactor` for navigation.

**Example**
In plugin opts, use `on_attach` callback:

```lua
opts = {
  on_attach = function(bufnr)
    local ts_context = require("treesitter-context")
    -- Additional setup
  end,
}
```

#### Disabling for Specific Cases
Use autocmds or conditions.

**Example**
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function() require("treesitter-context").disable() end,
})
```

Disables in non-code filetypes; can be re-enabled manually.

### Troubleshooting

Common problems include no context display, performance lags, or incorrect parsing.

**Key Points**
- Verify parser with `:TSInstallInfo`; install missing ones.
- Check health: `:checkhealth treesitter-context`.
- If context doesn't update, ensure no conflicting floats (e.g., from LSP).
- [Inference] In very large files, performance might degrade; consider increasing `max_lines` or disabling.
- Logs via `:messages` or debug mode.

**Example**
To debug:
```
:lua print(vim.inspect(require("treesitter-context").config))
```
Outputs current config for verification.

**Next Steps**
- Explore Treesitter queries for custom patterns in `~/.local/share/nvim/treesitter/queries/`.
- Pair with `nvim-treesitter/nvim-treesitter-refactor` for smart renames.
- Test in various languages to observe parser-specific behaviors.

**Conclusion**
nvim-treesitter-context improves code comprehension by keeping structural context visible, seamlessly fitting into LazyVim workflows. Adjust settings based on personal preferences, noting that display consistency can depend on language parsers and Neovim updates.

---

