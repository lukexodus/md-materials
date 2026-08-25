## Treesitter Text Objects


### Overview

The nvim-treesitter-textobjects plugin extends the core nvim-treesitter functionality by providing syntax-aware text objects, movements, swaps, and LSP integrations based on Tree-sitter queries. In LazyVim, this is enabled by default as part of the treesitter plugin configuration, specifically through the `move` option, which sets up buffer-local keymaps for navigation. It requires nvim-treesitter to be installed and configured, and supports a wide range of languages including but not limited to Apex, Bash, C, C++, CSS, Go, Java, JavaScript, Lua, Python, Rust, and TypeScript.

The plugin uses query files (e.g., textobjects.scm, locals.scm) to define captures for text objects like functions, classes, parameters, and more. These can be customized or extended per language in your query directories. In LazyVim, the integration focuses on movement keymaps, but full features like select, swap, and LSP interop can be enabled via custom configurations in your plugins file.

Note that behavior may vary depending on the language parser's quality, Neovim version, and whether queries are up-to-date (use `:TSUpdate` to sync). As of January 2026, the plugin's master branch has been frozen since October 2025, with recent updates including Java return textobjects and documentation fixes.

**Key Points**
- Depends on nvim-treesitter for parsing; no standalone use.
- Supports repeatable movements with ; and , keys when configured.
- Customizable via Lua setup in nvim-treesitter.configs.
- LazyVim defaults enable movement navigation for functions, classes, and parameters.
- Enhances editing efficiency with precise, context-aware selections and jumps.

### Installation and Setup

In LazyVim, nvim-treesitter-textobjects is included as a dependency in the treesitter plugin spec. It auto-installs when treesitter is enabled (which is default in LazyVim). To ensure it's active, check your `lazy.lua` or use `:Lazy` to verify. For manual addition or customization, extend the plugin in `~/.config/nvim/lua/plugins/treesitter.lua`:

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    opts = {
      textobjects = {
        -- Your configurations here
      },
    },
  },
}
```

Run `:Lazy sync` to install. Dependencies include nvim-treesitter; optional LSP servers for interop features. Behavior may vary if using Neovim stable versus nightly, as Tree-sitter features are experimental in some releases.

**Example**
To enable all features:

```lua
opts.textobjects = {
  select = { enable = true, lookahead = true },
  swap = { enable = true },
  move = { enable = true, set_jumps = true },
  lsp_interop = { enable = true },
}
```

### Select Text Objects

The select module allows visual or operator-pending mode selections using Tree-sitter captures. It supports inner/outer variants and can include surrounding whitespace. In LazyVim, this isn't enabled by default but can be added via opts. Keymaps are user-defined, e.g., `af` for outer function.

Available captures include @function.inner/outer, @class.inner/outer, @parameter.inner/outer, @block.inner/outer, @conditional.inner/outer, @loop.inner/outer, @call.inner/outer, and more (see textobjects.scm for full list per language).

Selection modes can be set to charwise, linewise, or blockwise. Lookahead searches forward if no match under cursor.

**Key Points**
- Enable with `select.enable = true`.
- Custom keymaps via `select.keymaps` table.
- Include whitespace with a function or boolean.
- Language-specific; not all captures available in every parser.

**Example**
Configure and use for Python:

```lua
select = {
  enable = true,
  keymaps = {
    ["af"] = "@function.outer",
    ["if"] = "@function.inner",
  },
}
```

In a Python buffer: Place cursor inside a function, press `vaf` to select the outer function (including def and body).

**Output**
Visual selection highlights the function block. Operator like `daf` deletes it.

[Inference]: In languages with nested structures, outer may capture more than expected if queries overlap.

### Swap Text Objects

The swap module enables exchanging adjacent text objects, like parameters in a function call. It's not default in LazyVim but configurable. Define next/previous keymaps for specific captures.

**Key Points**
- Enable with `swap.enable = true`.
- Supports @parameter.inner, @statement.outer, etc.
- Swaps based on Tree-sitter nodes; may not handle complex syntax perfectly.

**Example**
Setup:

```lua
swap = {
  enable = true,
  swap_next = { ["<leader>a"] = "@parameter.inner" },
  swap_previous = { ["<leader>A"] = "@parameter.inner" },
}
```

In code: `func(a, b, c)` – cursor on b, press `<leader>a` to get `func(a, c, b)`.

**Output**
Text updates in place; repeatable with dot command if configured.

Note: Behavior may vary with node adjacency detection.

### Move Text Objects

The move module provides navigation to next/previous text objects, setting jumplist entries if enabled. In LazyVim, this is active by default with specific keymaps for functions, classes, and parameters.

Default LazyVim keymaps:
- `]f` / `[f`: Next/previous function start (outer).
- `]F` / `[F`: Next/previous function end (outer).
- `]c` / `[c`: Next/previous class start (outer).
- `]C` / `[C`: Next/previous class end (outer).
- `]a` / `[a`: Next/previous parameter start (inner).
- `]A` / `[A`: Next/previous parameter end (inner).

These are buffer-local and apply in normal, visual, operator modes.

**Key Points**
- Enable with `move.enable = true`, `set_jumps = true`.
- Customizable via `move.goto_next_start`, etc.
- Supports repeatable moves with ;/, integration.
- Uses locals.scm for scope increments.

**Example**
Custom addition:

```lua
move = {
  goto_next_start = { ["]m"] = "@function.outer" },
  goto_previous_start = { ["[m"] = "@function.outer" },
}
```

In a file, press `]m` to jump to next function start.

**Output**
Cursor moves to the capture's position; use `ctrl-o` to jump back if set_jumps enabled.

### LSP Interop

This feature integrates with LSP for peeking definitions in floating windows, using text objects to show surrounding code. Not default in LazyVim; enable manually.

**Key Points**
- Enable with `lsp_interop.enable = true`.
- Custom border and preview opts.
- Keymaps for peek_definition_code, e.g., `<leader>df` for function.

**Example**
Setup:

```lua
lsp_interop = {
  enable = true,
  peek_definition_code = {
    ["<leader>df"] = "@function.outer",
    ["<leader>dF"] = "@class.outer",
  },
}
```

With LSP attached, press `<leader>df` on a reference to float the defining function.

**Output**
Floating window shows code snippet; close with standard commands.

[Unverified]: May interact variably with multiple LSP servers.

### Repeatable Movements

Integrate with repeatable_move module for ;/, repetition of custom movements. In LazyVim, set up globally or per-plugin.

**Example**
```lua
local ts_repeat = require("nvim_treesitter.textobjects.repeatable_move")
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat.repeat_last_move_previous)
```

After `]m`, press ; to repeat forward.

### Custom Queries and Extensions

Define or override captures in `~/.local/share/nvim/queries/lang/textobjects.scm`. LazyVim supports auto-loading these.

**Example**
Add custom for Python loops:

```
(loop_statement) @loop.outer
```

Map in config.

**Conclusion**
nvim-treesitter-textobjects significantly improves code navigation and manipulation in LazyVim by leveraging Tree-sitter's parsing for accurate text objects across languages. While defaults cover basic movements, full customization unlocks advanced editing workflows.

**Next Steps**
- Enable additional modules in your treesitter opts.
- Update parsers with `:TSUpdate`.
- Explore language-specific queries on GitHub.
- Integrate with other plugins like nvim-treesitter-refactor for more features.
- Test in various filetypes to observe behavior variations.

---

