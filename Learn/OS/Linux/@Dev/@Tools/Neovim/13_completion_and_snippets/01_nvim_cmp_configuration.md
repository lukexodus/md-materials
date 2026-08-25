## nvim-cmp Configuration


### Overview

nvim-cmp serves as a completion engine for Neovim, offering support for Language Server Protocol (LSP) capabilities, snippet expansion, and various sources such as buffers, paths, and LSP servers. In LazyVim, it is available as an optional extra, having been replaced by blink.cmp as the default completion plugin in version 14.x. This shift aims to provide a more performant alternative, but users may opt for nvim-cmp by enabling the corresponding extra. Configuration occurs through Lua files, typically within the `lua/plugins/` directory, allowing overrides of defaults via the `opts` function.

Key features include customizable mappings, source prioritization, formatting with icons, and integration with snippet engines. Behavior can differ based on installed plugins, Neovim version, and specific environment setups.

**Key Points**
- Supports multiple sources, including nvim_lsp, buffer, path, and optional snippets.
- Provides predefined mappings that align with native Neovim behavior.
- Allows experimental features like ghost text, which may enhance user experience in certain scenarios.
- Customization focuses on extending or modifying the setup table returned by the `opts` function.

### Enabling the Extra

To utilize nvim-cmp instead of the default blink.cmp, enable the `coding.nvim-cmp` extra. This can be achieved using the `:LazyExtras` command within Neovim. Once enabled, LazyVim loads the necessary plugins and applies default configurations.

Plugins involved include:
- hrsh7th/nvim-cmp (core engine).
- hrsh7th/cmp-nvim-lsp (LSP source).
- hrsh7th/cmp-path (filesystem paths).
- hrsh7th/cmp-buffer (buffer words).
- Optional: nvim-snippets or similar for snippet support, configured automatically if installed.

After enabling, restart Neovim or run `:Lazy sync` to apply changes. Note that enabling this extra overrides the default blink.cmp setup, potentially altering completion performance depending on system resources.

### Default Settings

LazyVim provides a baseline configuration for nvim-cmp, focusing on usability and integration with other plugins. The setup includes registering LSP capabilities, setting completion options, and defining sources.

Core defaults:
- Completion options: `completeopt = "menu,menuone,noinsert"` (with `noselect` added unless auto-selection is enabled).
- Preselect mode: Set to `Item` if auto-selection is active, otherwise `None`.
- Sources: Prioritizes `lazydev` (for Lua development), `nvim_lsp`, and `path`; falls back to `buffer`.
- Formatting: Appends icons from `LazyVim.config.icons.kinds` to completion items; truncates labels if exceeding configured widths (e.g., abbreviation to 40 characters).
- Experimental: Ghost text enabled under specific conditions, using the `CmpGhostText` highlight group linked to `Comment`.

These settings may vary if conflicting plugins are present or if Neovim updates alter underlying behaviors.

### Customizing Sources

Sources determine where completion suggestions originate. LazyVim's defaults can be extended by overriding the `nvim-cmp` spec in a plugin file, such as `lua/plugins/cmp.lua`.

To add a new source, include it in the `sources` table within the `opts` function. Ensure dependencies are declared if the source requires additional plugins.

**Example**
```lua
-- lua/plugins/cmp.lua
return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
      return opts
    end,
  },
}
```

This adds emoji completions. Reload the configuration with `:Lazy sync` to apply. Results may depend on the active buffer's filetype and installed LSP servers.

### Key Mappings

Mappings control interaction with the completion menu. LazyVim uses `cmp.mapping.preset.insert` for defaults, which can be extended or replaced.

Default mappings:
- `<C-n>`: Select next item.
- `<C-p>`: Select previous item.
- `<C-Space>`: Trigger completion manually.
- `<CR>`: Confirm selection (with optional auto-select).
- `<C-b>` / `<C-f>`: Scroll documentation window.
- `<Tab>`: Handles snippet jumps or AI completions if configured.

For advanced setups, such as Supertab behavior where `<Tab>` triggers completion or navigates snippets, override the mappings table.

**Example**
```lua
-- lua/plugins/cmp.lua
return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.snippet.active({ direction = 1 }) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.snippet.active({ direction = -1 }) then
            vim.schedule(function()
              vim.snippet.jump(-1)
            end)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
      return opts
    end,
  },
}
```

This configuration enables `<Tab>` for forward navigation and `<S-Tab>` for backward, with fallbacks. Mapping behaviors can vary across terminals or if other plugins intercept keys.

### Snippet Integration

nvim-cmp supports snippet expansion from engines like nvim-snippets, luasnip, or vsnip. In LazyVim, if a compatible snippet plugin is installed, the `snippets` source is automatically added.

Defaults:
- Expansion function: Set to `LazyVim.cmp.expand`.
- Friendly snippets: Enabled by default.

To customize, adjust the `snippet` table in `opts`. For instance, integrate with luasnip by setting the expand function accordingly.

**Example**
```lua
-- lua/plugins/cmp.lua
return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "L3MON4D3/LuaSnip" },
    opts = function(_, opts)
      opts.snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      }
      return opts
    end,
  },
}
```

Snippet functionality may require additional setup in the snippet plugin itself, and expansion success can depend on the snippet format and buffer content.

### Advanced Customization

For deeper adjustments, modify window appearances, sorting comparators, or filetype-specific behaviors. Use `cmp.config.window.bordered()` for styled borders.

To enable auto-brackets for certain filetypes, populate the `auto_brackets` table in `opts`.

Experimental features like ghost text can be toggled via `experimental.ghost_text`. However, these may impact performance on lower-end systems.

Cmdline completion (e.g., for `:`, `/`) requires separate setup calls, such as `cmp.setup.cmdline`.

**Example**
```lua
-- lua/plugins/cmp.lua
return {
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "path" },
          { name = "cmdline" },
        },
      })
    end,
  },
}
```

This enables path and command completions in the command line. Outcomes may differ based on Neovim's command-line mode handling.

### Troubleshooting

Common issues include menu not appearing (check sources and triggers), mapping conflicts (review overrides), or performance lags (reduce sources or disable experiments). Consult logs with `:Lazy log` or nvim-cmp's documentation for diagnostics. Behaviors can change with updates to LazyVim or dependent plugins.

**Conclusion**
Configuring nvim-cmp in LazyVim offers flexibility for tailored completion experiences, balancing defaults with user overrides. Start with enabling the extra and build incrementally.

**Next Steps**
- Review the nvim-cmp GitHub repository for API details.
- Experiment with additional sources like cmp-git for repository-specific completions.
- Test configurations in a minimal buffer to isolate issues.

---

