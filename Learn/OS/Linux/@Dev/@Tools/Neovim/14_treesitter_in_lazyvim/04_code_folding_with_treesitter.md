## Code Folding with Treesitter


### Overview

Treesitter provides syntax-aware code folding in Neovim by leveraging parsed language structures to define fold regions, such as functions, classes, or blocks. In LazyVim, this functionality integrates with the nvim-treesitter plugin, which is included by default. As of LazyVim versions from mid-2023 onward, folding relies on Neovim's built-in capabilities for Treesitter, particularly in Neovim 0.10 and later, where foldmethod is set to "expr" and foldexpr uses Treesitter queries. This approach may offer more accurate folds compared to traditional methods like indent or syntax, though results can vary by language parser quality and file complexity. For earlier Neovim versions, LazyVim may default to indent-based folding in some cases.

**Key Points**
- Treesitter folding identifies structural elements automatically, potentially reducing manual setup needs.
- Behavior depends on the installed language parsers; not all languages support folding equally.
- In LazyVim, folding is enabled out-of-the-box via the treesitter plugin configuration, but users can customize or extend it.
- [Inference]: By January 2026, with Neovim advancements, native Treesitter folding likely remains the core mechanism, with optional enhancements via plugins.

### Enabling Folding

In LazyVim, Treesitter folding is activated by default through the nvim-treesitter plugin. If not present, ensure the plugin is loaded by checking `:Lazy` or adding it explicitly in `lua/plugins/treesitter.lua`. For Neovim 0.10+, no additional steps are typically required beyond having the appropriate language parsers installed via `:TSInstall <language>`.

To explicitly enable or verify:
- Open `lua/plugins/treesitter.lua` (create if absent).
- Override the defaults to confirm folding is active.

**Example**
```lua
-- lua/plugins/treesitter.lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.folds = { enable = true }  -- Ensures folding feature is active
      return opts
    end,
  },
}
```

After saving, run `:Lazy sync` to apply. Folding behavior may differ if conflicting options like foldmethod are set elsewhere, such as in autocmds or other plugins.

### Default Configuration

LazyVim sets up folding with sensible defaults, using Treesitter for expression-based evaluation. Key options include:
- `foldmethod = "expr"`: Computes folds dynamically via foldexpr.
- `foldexpr = "nvim_treesitter#foldexpr()"`: [Unverified] This or a similar LazyVim wrapper utilizes Treesitter to determine fold levels.
- `foldlevel = 99`: Starts with all folds open; lower values close more levels initially.
- `foldenable = true`: Activates folding on buffer load, though some configurations suggest setting to false to avoid automatic closing.

These are applied globally or per-filetype via LazyVim's config loader. For Neovim versions below 0.10, LazyVim may fallback to `foldmethod = "indent"`, which does not use Treesitter and could lead to less precise folds in languages like Python or Go.

To view current settings, use `:set foldmethod?` or `:set foldexpr?` in a buffer. Results can vary based on the active filetype and whether Treesitter parsers are loaded.

### Customizing Fold Levels and Behavior

Adjust fold levels to control initial openness or depth. Set these in `lua/config/options.lua` for global application.

Common customizations:
- Start with deeper folds closed: `vim.opt.foldlevel = 0`.
- Prevent folding on open: `vim.opt.foldenable = false`.
- Set minimum lines for a fold: `vim.opt.foldminlines = 1`.

For Treesitter-specific tweaks, extend the plugin opts to influence queries or providers.

**Example**
```lua
-- lua/config/options.lua
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99  -- Keeps most folds open by default
vim.opt.foldlevelstart = 99  -- Applies on buffer open
vim.opt.foldenable = false  -- Avoids automatic folding until manual trigger
```

These changes may not apply uniformly if overridden by filetype plugins or if Treesitter fails to parse the buffer, potentially reverting to manual folds.

### Key Mappings

Neovim provides built-in mappings for folding, which work with Treesitter folds. LazyVim does not override these by default but may integrate with which-key for discoverability.

Standard mappings:
- `zc`: Close fold under cursor.
- `zo`: Open fold under cursor.
- `zM`: Close all folds.
- `zR`: Open all folds.
- `za`: Toggle fold under cursor.
- `zC`, `zO`: Recursive versions for nested folds.

To add custom mappings, define them in `lua/config/keymaps.lua`.

**Example**
```lua
-- lua/config/keymaps.lua
vim.keymap.set("n", "<leader>z", "za", { desc = "Toggle Fold" })
vim.keymap.set("n", "<leader>Z", "zR", { desc = "Open All Folds" })
```

Mapping effectiveness can depend on the cursor position and whether a valid Treesitter fold exists there.

### Integrating with nvim-ufo (Optional)

For enhanced folding features, such as virtual text indicators or LSP integration alongside Treesitter, users can add the nvim-ufo plugin. This is not included in LazyVim by default but can be enabled as an extra or manually. nvim-ufo uses providers like Treesitter for fold computation and adds a status column for fold levels.

Steps to integrate:
1. Add the plugin and dependency in `lua/plugins/editor.lua` or a dedicated file.
2. Configure providers to include Treesitter.
3. Set up keymaps for peeking or toggling.

**Example**
```lua
-- lua/plugins/folding.lua
return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "VeryLazy",
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }  -- Prioritizes Treesitter, falls back to indent
      end,
      close_fold_kinds_for_ft = { default = { "imports", "comment" } },  -- Auto-closes specific kinds
    },
    config = function(_, opts)
      require("ufo").setup(opts)
      vim.opt.foldcolumn = "1"  -- Enables fold column
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
      vim.opt.foldenable = true
    end,
    keys = {
      { "zR", function() require("ufo").openAllFolds() end, desc = "Open All Folds" },
      { "zM", function() require("ufo").closeAllFolds() end, desc = "Close All Folds" },
      { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "Open Folds Except Kinds" },
      { "zm", function() require("ufo").closeFoldsWith() end, desc = "Close Folds With" },
      { "K", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek Fold" },
    },
  },
}
```

After adding, run `:Lazy sync`. This setup may improve visual feedback but could introduce minor performance overhead in large files. Compatibility with LazyVim's defaults has been reported positively in user discussions, though behaviors like initial fold states might need tweaking.

### Troubleshooting

If folds do not appear:
- Verify Treesitter parser: `:TSInstallInfo` and ensure language is installed.
- Check settings: `:verbose set foldmethod?` to identify overrides.
- Telescope issues: [Unverified] Opening files via Telescope may delay fold application; try manual `:set foldmethod=expr`.
- Conflicts: Disable other folding plugins or autocmds temporarily.

Logs from `:messages` or nvim-treesitter diagnostics can help identify parser errors. Behaviors may vary across Neovim versions or with concurrent plugins like LSP clients.

**Conclusion**
Treesitter enables structured code folding in LazyVim, with defaults providing a solid foundation that can be customized for workflow preferences. Optional integrations like nvim-ufo offer advanced capabilities for users needing more visual or automated control.

**Next Steps**
- Explore nvim-treesitter documentation on GitHub for language-specific queries.
- Test folding in various filetypes to assess parser accuracy.
- Consider adding plugins like nvim-origami for alternative folding strategies if Treesitter falls short.

---

