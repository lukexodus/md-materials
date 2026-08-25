## Parser Installation and Management


### Overview

Parsers in this context refer to Tree-sitter parsers, which provide advanced syntax highlighting, code folding, indentation, and other text object functionalities through the `nvim-treesitter` plugin. LazyVim includes `nvim-treesitter` as a core plugin, managed via Lazy.nvim, allowing for declarative installation and management of language-specific parsers. These parsers are compiled from grammars and queried for features like highlighting.

Tree-sitter operates by parsing code into abstract syntax trees (ASTs), enabling more accurate and efficient handling compared to regex-based methods. Behavior can differ based on Neovim version (e.g., 0.9+ has better integration), the specific parser version, and system dependencies like a C compiler for building parsers.

### Enabling Tree-sitter

LazyVim pre-configures `nvim-treesitter` in its defaults, but you can customize it in `lua/config/lazy.lua`. Ensure the plugin is loaded:

```lua
require("lazy").setup({
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc" },  -- Minimal set; add more as needed
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
})
```

This setup installs specified parsers on first load or via `:Lazy sync`. The `build` step updates parsers automatically.

**Key Points**
- Requires a C compiler (e.g., gcc or clang) and git for fetching grammars.
- Parsers are stored in `~/.local/share/nvim/site/pack/lazy/opt/nvim-treesitter/parser/`.
- Auto-installation can be enabled with `auto_install = true` in config, but it may prompt for each new filetype.

### Installing Parsers

Use the `:TSInstall` command for specific languages. For example, to install the Python parser:

```
:TSInstall python
```

For multiple:

```
:TSInstall javascript typescript
```

In configuration, expand `ensure_installed` for automatic handling:

```lua
ensure_installed = {
  "bash", "c", "css", "dockerfile", "go", "html", "java", "javascript",
  "json", "lua", "markdown", "python", "rust", "toml", "tsx", "typescript",
  "vim", "vimdoc", "yaml",
},
```

LazyVim will install these during sync. For all available parsers:

```
:TSInstall all
```

This may take time and space; selective installation is recommended. Installation fetches grammars from GitHub and compiles them locally, which might fail if network or build tools are unavailable.

**Example**
To add support for a new language like Elixir in your config:

```lua
-- In lua/plugins/treesitter.lua or similar
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "elixir" })
    end,
  },
}
```

Then run `:Lazy sync` to install.

**Output**
After installation, check with `:TSInstallInfo`:

```
Parser        Language     Health  Size    Updated
python        python       ok      123kB   2023-10-01
```

Health indicates if the parser built correctly.

### Updating Parsers

Updates ensure compatibility with new language features or Neovim changes. Use:

```
:TSUpdate
```

Or for specific:

```
:TSUpdate lua
```

In LazyVim, the `build = ":TSUpdate"` in plugin spec runs this on updates. Manually trigger via `:Lazy update`. Parsers update from their upstream repositories, so behavior may change post-update; review changelogs if issues arise [Inference: Based on common Tree-sitter practices].

**Key Points**
- Updates can introduce breaking changes in queries (e.g., highlighting rules).
- Schedule updates periodically, as automatic ones might not catch all.
- If using `auto_install = true`, new parsers update implicitly.

### Uninstalling Parsers

To remove a parser:

```
:TSUninstall python
```

Or multiple:

```
:TSUninstall javascript typescript
```

Remove from `ensure_installed` in config to prevent re-installation. For all:

```
:TSUninstall all
```

This deletes the compiled parser files but keeps the plugin intact.

**Example**
If switching projects, clean up unused parsers:

```
:TSUninstall go java
```

Then verify with `:TSInstallInfo` to confirm removal.

### Configuring Parsers

Customization happens in the `nvim-treesitter.configs.setup` call. Enable features per-language:

```lua
highlight = {
  enable = true,
  disable = { "lua" },  -- Disable for specific languages if performance issues
},
indent = { enable = true },
incremental_selection = {
  enable = true,
  keymaps = {
    init_selection = "<C-space>",
    node_incremental = "<C-space>",
    scope_incremental = false,
    node_decremental = "<bs>",
  },
},
```

For queries (e.g., custom highlights), place files in `queries/lang/` under your config directory. Tree-sitter also supports modules like `nvim-treesitter-textobjects` for enhanced navigation.

**Key Points**
- Performance: In large files, disable features with `disable = function(lang, buf) return vim.api.nvim_buf_line_count(buf) > 5000 end`.
- Dependencies: Some parsers require others (e.g., tsx needs typescript).
- Testing: Use `:Inspect` to view node under cursor for debugging.

**Example**
For better Markdown support, add:

```lua
-- In config
require("nvim-treesitter.configs").setup({
  -- ...
  ensure_installed = { "markdown", "markdown_inline" },
})
```

This enables inline parsing for elements like links.

### Troubleshooting

- **Installation failures**: Check logs with `:checkhealth nvim-treesitter`. Ensure git and compiler are installed.
- **No highlighting**: Confirm parser with `:TSInstallInfo`; restart Neovim.
- **Conflicts**: With other plugins like polyglot, disable overlapping features.
- Behavior may vary on non-Unix systems (e.g., Windows may need MSVC).

### Advanced Management

For automation, use autocmds:

```lua
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
    if lang and not pcall(vim.treesitter.start) then
      vim.cmd("TSInstall " .. lang)
    end
  end,
})
```

This installs on-demand [Speculation: May require `auto_install = true` for seamless use]. Integrate with `mason.nvim` for related tools, though parsers are separate.

Integrate with playground for query testing: Add `nvim-treesitter/playground` plugin.

**Conclusion**
Effective parser management enhances editing efficiency by providing robust syntax features. Start with essentials, expand as needed, and monitor updates to maintain compatibility, keeping in mind potential variations in setup.

**Next Steps**
- Run `:TSInstallInfo` to audit current parsers.
- Explore `nvim-treesitter-textobjects` for advanced selections.
- Review Tree-sitter docs for custom queries.

---

