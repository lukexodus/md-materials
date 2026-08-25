## Code Completion with nvim-cmp


### Overview

nvim-cmp is a Lua-based completion plugin for Neovim that serves as a versatile completion engine. It supports integration with Language Server Protocol (LSP) servers, snippet engines, and various sources like buffers and file paths. In the context of LazyVim, nvim-cmp can be enabled as an extra to provide code completion capabilities, replacing or complementing other engines like blink.cmp. It offers customizable windows, mappings, and formatting, with features such as flicker-free updates and documentation previews. Behavior may vary depending on Neovim version, installed plugins, and system environment.

As of January 2026, recent updates to nvim-cmp include improved LSP configuration handling, added options for documentation window offsets, separated icon and highlight groups for better customization, and automated release workflows.

### Enabling in LazyVim

In LazyVim, nvim-cmp is available as an optional extra rather than a default core plugin. To enable it:

1. Open the LazyVim extras menu with the command `:LazyExtras`.
2. Search for "coding.nvim-cmp" in the list.
3. Select it and press `x` to toggle it on.
4. Restart Neovim or run `:Lazy sync` to apply changes.

This extra installs and configures nvim-cmp along with dependencies like cmp-nvim-lsp, cmp-buffer, and cmp-path. If other plugins like nvim-snippets are installed, they are integrated automatically. Note that enabling this may override the default completion engine if another (e.g., blink.cmp) is active; check your LazyVim options in `lua/lazyvim/config/options.lua` for the `completion` setting.

**Key Points**
- Enables full LSP completion support.
- Integrates with snippet engines like LuaSnip or vim-vsnip.
- Adds sources for paths, buffers, and optionally snippets or git commits.
- Sets default completion options like `completeopt = "menu,menuone,noinsert"`.

### Basic Configuration

The default setup in LazyVim's nvim-cmp extra uses a configuration that mimics Neovim's native behavior while adding enhancements. The core setup is defined in a plugin spec with an `opts` function that returns a table for `cmp.setup()`. This includes global LSP capabilities registration via `cmp_nvim_lsp.default_capabilities()`.

A minimal equivalent configuration outside LazyVim might look like this Lua code:

**Example**
```lua
-- In lua/plugins/cmp.lua or similar
return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    opts = function()
      local cmp = require("cmp")
      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)  -- Assuming LuaSnip is used; adjust for other engines
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = function(_, item)
            item.kind = string.format("%s %s", "IconHere", item.kind)  -- Placeholder for icons
            return item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
      }
    end,
  },
}
```

This setup loads on `InsertEnter` event and may vary in performance based on file size or source complexity.

### Sources

Sources define where completions come from. In LazyVim's default nvim-cmp extra, common sources include:

- `nvim_lsp`: Completions from LSP servers (e.g., function signatures, variables).
- `buffer`: Words from the current buffer.
- `path`: File system paths.
- `luasnip` or similar: Snippets if a snippet engine is configured.
- Optional: `lazydev` for AI-related completions, `git` for commit messages.

To add or modify sources, extend the `sources` table in the `opts` function. For example, to add a git source for commit messages:

**Example**
```lua
sources = cmp.config.sources({
  { name = "nvim_lsp" },
  { name = "luasnip" },
}, {
  { name = "buffer" },
  { name = "path" },
  { name = "git" },  -- Requires cmp-git plugin
})
```

Filetype-specific sources can be set with `cmp.setup.filetype("gitcommit", { sources = ... })`. [Inference: Additional sources like cmp-emoji or cmp-cmdline can be added via dependencies and config extensions.]

### Keymaps

LazyVim provides preset mappings that align with common workflows. Default keymaps include:

- `<C-n>` / `<C-p>`: Select next/previous item.
- `<C-Space>`: Manually trigger completion.
- `<CR>` / `<C-y>`: Confirm selected item.
- `<S-CR>`: Confirm with replacement.
- `<C-e>` / `<C-CR>`: Abort completion.
- `<Tab>`: Jump to next snippet placeholder or accept suggestion.
- `<C-b>` / `<C-f>`: Scroll documentation window.

These are based on `cmp.mapping.preset.insert()` and can be overridden using `vim.tbl_deep_extend("force", opts.mapping, { ... })` in your custom config. Behavior may vary if conflicting keymaps from other plugins are present.

**Example**
To change navigation to `<C-j>` / `<C-k>`:

```lua
opts = function(_, opts)
  opts.mapping = vim.tbl_deep_extend("force", opts.mapping, {
    ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
  })
end
```

### Formatting and Windows

Formatting customizes how items appear in the completion menu, often including icons and truncated text. LazyVim uses icons for item kinds and limits field widths (e.g., abbreviation to 40 characters).

Windows are bordered by default for both completion and documentation. To customize:

**Example**
```lua
window = {
  completion = {
    border = "rounded",
    scrollbar = false,
  },
  documentation = {
    border = "single",
    col_offset = 2,  -- Offset for documentation window (added in late 2025 updates)
  },
}
```

Experimental ghost text shows inline previews, highlighted as comments, and is enabled conditionally in LazyVim.

### Snippet Integration

nvim-cmp supports multiple snippet engines. In LazyVim, it defaults to LuaSnip if available. The `snippet.expand` function handles expansion. For example, with LuaSnip:

**Example**
```lua
snippet = {
  expand = function(args)
    require("luasnip").lsp_expand(args.body)
  end,
}
```

Add friendly-snippets for pre-built snippets by setting `friendly_snippets = true` in opts.

### Command-Line Completion

Extend nvim-cmp to command-line modes (`:`, `/`, `?`) by adding setups:

**Example**
```lua
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
})
```

Requires cmp-cmdline dependency.

### Advanced Customization

- **Performance**: Adjust `performance = { debounce = 60, throttle = 30 }` to tune response times; higher values may reduce CPU usage but increase latency.
- **Sorting and Matching**: Customize with `sorting.comparators` or `matching` options, e.g., to prioritize exact matches.
- **Auto-Brackets**: Enable for specific filetypes to automatically close brackets on confirmation.
- **Ghost Text**: Toggle with `experimental.ghost_text = true`; may impact typing feel.

To override LazyVim defaults, create a file like `lua/plugins/cmp.lua` and extend the spec.

### Practical Usage Example

Suppose you're writing Lua code and type `requ`. nvim-cmp may suggest `require` from LSP or buffer.

**Example**
In a Lua file:
- Type `requ` → Completion menu appears with suggestions.
- Use `<C-n>` to select `require`.
- Press `<CR>` to insert.
- If a snippet, `<Tab>` jumps to placeholders.

**Output**
The inserted text might be `require("")` with cursor inside quotes, depending on snippet config.

### Troubleshooting

- If no completions appear: Check LSP server status with `:LspInfo` and ensure sources are enabled.
- Conflicts with other plugins: Disable overlapping mappings or adjust load order.
- Slow performance: Reduce sources or increase debounce; test in smaller files.
- [Unverified]: If ghost text flickers, it may relate to terminal settings or Neovim version.

**Conclusion**
nvim-cmp provides robust code completion tailored for productivity in LazyVim setups. Its flexibility allows for extensive customization while maintaining compatibility with Neovim's ecosystem.

**Next Steps**
- Explore the nvim-cmp wiki for more sources.
- Add extras like cmp-git for specialized workflows.
- Test configurations in a minimal Neovim setup to isolate issues.

---

