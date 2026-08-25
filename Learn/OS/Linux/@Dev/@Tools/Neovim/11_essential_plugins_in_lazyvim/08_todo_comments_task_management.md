## Todo-comments - Task Management


### Overview

todo-comments.nvim is a Lua plugin that highlights and manages special comments in code, such as TODO, FIX, NOTE, and custom keywords. It aids task management by making these annotations visually prominent, searchable, and navigable. In LazyVim, it is included by default in the core editor plugins, integrating with features like Telescope for quick searches and Trouble for diagnostic lists. This setup allows developers to track tasks, bugs, and reminders directly in source files without external tools. The plugin uses Treesitter for parsing and supports multiline comments, virtual text, and sign column indicators.

**Key Points**
- Highlights keywords with configurable colors and icons.
- Provides commands and keymaps for jumping between comments.
- Integrates with LSP diagnostics and quickfix lists for broader task workflows.
- Behavior may vary based on filetypes, Treesitter parsers, or conflicting highlight groups.

### Setup and Installation

In LazyVim, todo-comments is pre-configured and enabled automatically via the `lua/lazyvim/plugins/editor.lua` spec. No manual installation is required if using the standard LazyVim setup. For custom installations, add it via lazy.nvim specs.

If starting from a minimal config, include it as:

**Example**
```lua
-- In lua/plugins/editor.lua
return {
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { -- configuration options }
  },
}
```

LazyVim's default opts enable common keywords and integrate with which-key for discoverability.

To disable or modify, override in a user plugin file:

**Example**
```lua
-- lua/plugins/editor.lua
return {
  { "folke/todo-comments.nvim", enabled = false },
}
```

### Configuration Options

Configuration is done via a Lua table passed to `require("todo-comments").setup(opts)`. LazyVim provides sensible defaults, but users can extend them in `lua/config/options.lua` or plugin specs.

Key options include:
- `keywords`: Table defining keywords, their colors, icons, and alt aliases (e.g., { TODO = { icon = " ", color = "info" } }).
- `signs`: Boolean to show icons in the sign column.
- `highlight`: Table for highlight mode (e.g., "fg" for foreground, "bg" for background).
- `search`: Settings for regex patterns, including multiline support.
- `gui_style`: Customize bold, italic, etc., for GUI clients.
- `merge_keywords`: Boolean to merge user keywords with defaults.

**Example**
```lua
-- Custom keywords in opts
opts = {
  keywords = {
    FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "ISSUE" } },
    TODO = { icon = " ", color = "info" },
    HACK = { icon = " ", color = "warning" },
    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
    PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE" } },
    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
    TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
  },
  highlight = {
    multiline = true,
    pattern = [[.*<(KEYWORDS)\s*:]],
  },
}
```

**Key Points**
- Colors link to highlight groups like Comment, Error, etc.; customize via `hi` commands.
- Regex patterns allow flexible matching, e.g., for tags like @username.
- Changes require reloading or restarting Neovim; test in a buffer with `:TodoQuickFix`.

### Usage

#### Adding Comments

Simply write comments in code with defined keywords followed by a colon, e.g., `TODO: Implement feature`. The plugin automatically highlights them upon buffer load or save.

For multiline:

**Example**
```lua
-- TODO: This is a multiline
-- todo comment example.
```

#### Searching and Navigating

Use built-in commands:
- `:TodoQuickFix`: Populates quickfix with all todos.
- `:TodoLocList`: Local list for current buffer.
- `:TodoTelescope`: Fuzzy search via Telescope.
- `:TodoTrouble`: Displays in Trouble.nvim panel.

Navigation keymaps (default in LazyVim):
- `]t`: Next todo comment.
- `[t`: Previous todo comment.

**Example**
In a buffer, press `]t` to jump to the next TODO; the sign column shows icons for quick scanning.

**Output**
Quickfix list might show:
```
file.lua|10 col 1| TODO: Fix this bug
```

#### Integration with Task Management Workflows

todo-comments enhances task management by treating code comments as lightweight issues. Combine with:
- Git: Track todos in commits or blame.
- LSP: Export to diagnostics for IDE-like features.
- External Tools: Parse quickfix output for scripts integrating with tools like GitHub Issues.

For advanced workflows, use Telescope to filter by keyword, e.g., only TODOs.

[Inference]: In large projects, combining with project.nvim or overseer.nvim could link todos to runnable tasks, though not natively supported.

**Example**
```vim
:TodoTelescope keywords=TODO,FIX
```
Opens Telescope with filtered results.

### Keybindings in LazyVim

LazyVim maps todo-comments actions under `<leader>st` (search todo) and integrates with which-key.

Default mappings:
- `<leader>st`: `:TodoTelescope` - Search all todos.
- `<leader>sT`: `:TodoTelescope keywords=TODO` - Search only TODOs.
- `]t` / `[t`: Navigate next/prev.

Customize in `lua/config/keymaps.lua`:

**Example**
```lua
vim.keymap.set("n", "<leader>xt", "<cmd>TodoTrouble<cr>", { desc = "Todo (Trouble)" })
vim.keymap.set("n", "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX<cr>", { desc = "Todo/Fix/Fixme (Trouble)" })
```

### Advanced Features

#### Custom Keywords and Patterns

Define project-specific keywords, e.g., for Agile: `STORY:`, `EPIC:`.

**Example**
```lua
keywords = {
  STORY = { icon = "📖", color = "info" },
},
search = {
  pattern = [[\b(KEYWORDS):]],
},
```

#### Virtual Text and Signs

Enable `virtual_text = true` for inline previews of comment text next to lines.

#### Ignoring Files or Patterns

Use `ignored_paths` or Treesitter queries to exclude directories like `node_modules`.

#### Highlighting in Non-Code Files

Works in Markdown, text files; adjust patterns for non-comment syntax.

### Troubleshooting

- **No Highlights**: Ensure Treesitter parser for filetype is installed; run `:TSInstall <lang>`.
- **Conflicts**: Other plugins like hlsearch may override groups; adjust priorities.
- **Performance**: In very large files, disable multiline for faster parsing.
- **Missing Commands**: Verify plugin loaded with `:Lazy show todo-comments.nvim`.
- Behavior may vary in terminal vs. GUI due to color support.

If issues, check console with `:messages` or plugin's GitHub issues.

**Conclusion**
todo-comments.nvim transforms simple comments into an effective task management system within LazyVim, promoting in-code documentation and quick navigation. It's lightweight yet extensible for various workflows.

**Next Steps**
- Add custom keywords to your config and test in a sample file.
- Integrate with Trouble or Telescope for enhanced searching.
- Explore the plugin's README on GitHub for more patterns and integrations.

---

