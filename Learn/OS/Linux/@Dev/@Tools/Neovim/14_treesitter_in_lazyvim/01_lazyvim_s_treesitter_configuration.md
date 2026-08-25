## LazyVim's Treesitter Configuration


### Overview

Treesitter in LazyVim provides advanced parsing for syntax highlighting, indentation, folding, and text objects, powered by the `nvim-treesitter` plugin on its main branch. This setup enables faster, more accurate code analysis across various languages. LazyVim pre-installs a set of parsers and configures features like highlighting and movement keymaps. Related plugins such as `nvim-treesitter-textobjects` extend functionality for navigating code structures. As of recent updates, `nvim-ts-autotag` for automatic tag closing and `nvim-treesitter-context` for displaying context lines are included by default. The configuration requires the `tree-sitter` CLI for parser installation, and behavior may vary based on the file type, installed parsers, and Neovim version (compatibility starts from 0.11.2 onward).

### Understanding Treesitter Features

Treesitter parses code into abstract syntax trees, enabling precise highlighting, queries for text objects, and more. In LazyVim, the core plugin `nvim-treesitter` handles parsing, while `nvim-treesitter-textobjects` adds movement and selection capabilities. Default features include:

- Syntax highlighting for supported languages.
- Indentation based on tree structure.
- Folding using tree nodes.
- Text object movements for functions, classes, and parameters.

Parsers are installed automatically if missing, using the `tree-sitter` CLI. The `ensure_installed` list covers common languages, but users can extend it. Features can be disabled per language or globally. [From official docs and source code.]

**Key Points**
- Requires `tree-sitter` CLI; install via package manager (e.g., `npm install -g tree-sitter-cli`).
- Parsers are built on demand; run `:TSUpdate` for manual updates.
- Supports queries for custom text objects, though LazyVim provides defaults.
- Behavior may differ if parsers are outdated or unavailable for a filetype.

### Default Configuration

LazyVim's Treesitter setup is defined in `lua/lazyvim/plugins/treesitter.lua`. It includes two plugin specs:

- `nvim-treesitter/nvim-treesitter`: Main parser with build function to handle updates and installations.
- `nvim-treesitter/nvim-treesitter-textobjects`: For text object movements.

Default options (`opts` table):

- `indent = { enable = true }`
- `highlight = { enable = true }`
- `folds = { enable = true }`
- `ensure_installed = { "bash", "c", "diff", "html", "javascript", "jsdoc", "json", "jsonc", "lua", "luadoc", "luap", "markdown", "markdown_inline", "printf", "python", "query", "regex", "toml", "tsx", "typescript", "vim", "vimdoc", "xml", "yaml" }`

An autocmd on `FileType` enables features conditionally based on filetype and language support. For example, highlighting starts via `vim.treesitter.start()` if enabled and queries exist.

**Example**
To view current configuration, inspect via Lua:

```lua
:lua print(vim.inspect(require('nvim-treesitter.configs').get_module('highlight')))
```

**Output**
Might show something like: `{ enable = true, disable = {} }` (exact output depends on runtime state).

### Customizing Treesitter

Customization occurs by overriding `opts` in user plugins, such as `lua/plugins/treesitter.lua`. Extend `ensure_installed` to add parsers (e.g., for Rust: `"rust"`). Disable features per language, e.g., `highlight = { disable = { "lua" } }`. For advanced queries, add custom textobject definitions.

To enable an extra like `treesitter-context` (if not default), add to `lazy.lua`:

```lua
return {
  "LazyVim/LazyExtras",
  opts = {
    extras = {
      "editor.treesitter-context",
    },
  },
}
```

For `nvim-ts-autotag`, it's configured separately but integrates with Treesitter for HTML/JSX tag handling.

**Key Points**
- Use `opts_extend = { "ensure_installed" }` to merge user additions.
- Install new parsers with `:TSInstall <lang>`.
- Custom keymaps can override defaults in `lua/config/keymaps.lua`.
- Updates may require restarting Neovim and running `:TSUpdate`.

**Example**
Add Go parser and disable indentation for it:

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "go" })
      opts.indent = { disable = { "go" } }
    end,
  },
}
```

**Output**
After reload, `:TSInstallInfo` shows "go" as installed, and Go files use alternative indentation.

### Keybindings for Treesitter

LazyVim provides buffer-local keymaps for navigation via `nvim-treesitter-textobjects`. These activate in supported filetypes.

- `]f` / `[f`: Next/previous start of function outer.
- `]F` / `[F`: Next/previous end of function outer.
- `]c` / `[c`: Next/previous start of class outer.
- `]C` / `[C`: Next/previous end of class outer.
- `]a` / `[a`: Next/previous start of parameter inner.
- `]A` / `[A`: Next/previous end of parameter inner.

Additional global keymaps:

- &lt;leader&gt;uT: Toggle Treesitter highlight.
- &lt;c-space&gt;: Initiate incremental selection (Treesitter-based).
- `S`: Flash Treesitter (search within tree nodes, via `flash.nvim`).
- `R`: Treesitter search (operator pending mode).

These may require plugins like `flash.nvim` or `mini.ai`.

### Related Plugins and Extras

- `nvim-ts-autotag`: Auto-closes tags in HTML/JSX; included by default, configurable via its opts.
- `nvim-treesitter-context`: Shows sticky context lines (e.g., function signatures); now default, with opts like max lines.
- Integrates with `mini.ai` for text objects, `flash.nvim` for searches, and LSP for enhanced diagnostics.
- Extras like `editor.treesitter-context` (if needed) add UI enhancements.

For debugging, use `:TSLog` or `:Inspect` to query tree nodes.

### Advanced Usage and Integration

Treesitter integrates with folding (`foldexpr`), indentation (`indentexpr`), and highlighting. Custom queries can be added in `queries/<lang>/` directories. For large files, performance may vary; disable features if needed. Recent migrations use the `main` branch, requiring CLI for builds. Combine with `telescope.nvim` for node searches [Inference from common setups].

**Example**
In a Lua file, use incremental selection:

Position cursor, press &lt;c-space&gt;, then press &lt;c-space&gt; again to expand to outer nodes.

**Output**
Selection grows from word to parameter, function, etc.

### Conclusion

LazyVim's Treesitter setup offers a solid, extensible foundation for code parsing, with defaults covering essentials and easy customization paths. It enhances editing across languages, though parser availability and system setup (like CLI) influence functionality.

**Next Steps**
- Install `tree-sitter` CLI and run `:TSUpdate` to ensure parsers are current.
- Add language-specific parsers via custom plugin specs.
- Explore related extras like `treesitter-context` for UI improvements.
- Check `:help nvim-treesitter` for deeper API details, as configurations may evolve.

---

