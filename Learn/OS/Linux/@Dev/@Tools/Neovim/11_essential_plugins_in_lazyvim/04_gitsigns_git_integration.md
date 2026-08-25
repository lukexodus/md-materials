## Gitsigns - Git Integration


### Overview

Gitsigns.nvim provides Git integration for Neovim buffers, focusing on displaying change indicators (signs) in the sign column, hunk management, blame information, and diff views. It supports features like staging hunks, previewing changes, navigating between hunks, and displaying blame as virtual text. The plugin is lightweight and relies on external tools like Git for operations, integrating with other plugins like vim-fugitive for enhanced functionality. In LazyVim, which emphasizes modular configurations, Gitsigns is not included by default in recent versions (post-2024 updates), where similar features may be handled by alternatives like mini.diff from the mini.nvim suite. However, Gitsigns can be manually integrated as a custom plugin. Behavior can vary based on Neovim version (requires ≥0.9.0), Git version, and buffer size, with potential performance impacts on large files.

**Key Points**
- Displays signs for added, changed, deleted, staged, and untracked lines.
- Supports partial hunk operations in visual mode.
- Includes blame for lines or entire buffers, with optional virtual text.
- Allows changing the base revision for comparisons.
- Populates quickfix or location lists with hunks for navigation.
- Provides text objects for selecting hunks.
- Exposes variables for statusline integration.
- Latest version as of March 2025 is v1.0.2, with ongoing maintenance.

[Inference]: Based on LazyVim release notes, mini.diff offers comparable features with additional overlays, suggesting it as a potential replacement in core extras.

### Installation

Gitsigns can be installed via Lazy.nvim, the plugin manager used in LazyVim. Add a specification file, such as `lua/plugins/gitsigns.lua`, with the following:

```lua
return {
  "lewis6991/gitsigns.nvim",
  event = "VeryLazy",
  config = true,  -- Automatically calls setup with defaults
}
```

Run `:Lazy sync` to install. No additional system dependencies are required beyond a recent Git installation. If using vim-fugitive or trouble.nvim, Gitsigns detects and integrates with them automatically. Installation may vary if conflicting plugins are present, such as other sign providers.

### Configuration

Configuration is handled through `require("gitsigns").setup(opts)`, where `opts` is a table. In LazyVim, place this in the plugin spec's `opts` field or a separate `config` function for overrides.

Default and key options include:

- `signs`: Table defining highlight groups and text for signs (e.g., `add = { text = "▎" }`).
- `signs_staged`: Separate signs for staged changes; defaults to mirroring `signs`.
- `signs_staged_enable`: Boolean to enable staged signs (true).
- `signcolumn`: Boolean to show the sign column (true).
- `numhl`: Boolean for line number highlighting (false).
- `linehl`: Boolean for full line highlighting (false).
- `word_diff`: Boolean for intra-line word differences (false).
- `current_line_blame`: Boolean to enable virtual text blame on current line (false).
- `current_line_blame_opts`: Table for blame display options, like delay (100ms) and position ("eol").
- `max_file_length`: Number to disable for files over this length (40000 lines).
- `preview_config`: Table for popup window borders and styles.

Full example configuration:

```lua
require("gitsigns").setup({
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "" },
    topdelete = { text = "" },
    changedelete = { text = "▎" },
    untracked = { text = "▎" },
  },
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol",
    delay = 1000,
    ignore_whitespace = false,
  },
  sign_priority = 6,
  update_debounce = 100,
  max_file_length = 40000,
})
```

Options can be adjusted post-setup using commands like `:Gitsigns toggle_current_line_blame`. Changes may not apply immediately to open buffers without reloading.

### Keybindings

Gitsigns does not set keybindings by default but provides an `on_attach` callback in setup for buffer-local mappings. In LazyVim, which uses which-key.nvim for hints, add these in the setup or `lua/config/keymaps.lua`.

Recommended mappings via `on_attach`:

```lua
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Navigation
    map("n", "]h", function() gs.nav_hunk("next") end, { desc = "Next Hunk" })
    map("n", "[h", function() gs.nav_hunk("prev") end, { desc = "Prev Hunk" })

    -- Actions
    map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk" })
    map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk" })
    map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage Hunk" })
    map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset Hunk" })
    map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage Buffer" })
    map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset Buffer" })
    map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview Hunk" })
    map("n", "<leader>hi", gs.preview_hunk_inline, { desc = "Preview Hunk Inline" })
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, { desc = "Blame Line" })
    map("n", "<leader>hd", gs.diffthis, { desc = "Diff This" })
    map("n", "<leader>hD", function() gs.diffthis("~") end, { desc = "Diff This ~" })

    -- Toggles
    map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle Blame" })
    map("n", "<leader>tw", gs.toggle_word_diff, { desc = "Toggle Word Diff" })

    -- Text object
    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "GitSigns Select Hunk" })
  end,
})
```

These can be customized to avoid conflicts with LazyVim defaults like `<leader>g` prefixes for Git.

### Usage

To use Gitsigns:
1. Open a file in a Git repository; signs appear automatically if `auto_attach` is true.
2. Navigate hunks with `]h` / `[h`.
3. Stage a hunk under cursor with `<leader>hs`.
4. Preview changes with `<leader>hp` (popup) or `<leader>hi` (inline).
5. View blame with `<leader>hb` or toggle virtual text blame.
6. Diff the buffer with `<leader>hd`.
7. Populate quickfix with hunks: `:Gitsigns setqflist`.

For revision views: `:Gitsigns show <REVISION>` to edit at a specific commit.

If integrated with trouble.nvim, quickfix opens in Trouble UI.

**Example**

To stage and preview a hunk:
- Position cursor on a changed line.
- Press `<leader>hp` to see popup diff.
- Press `<leader>hs` to stage.

For blame:
- Toggle `<leader>tb`; virtual text shows commit info at line end.

**Output**

Signs might appear as:
- Green `▎` for added lines.
- Blue `▎` for changed.
- Red `` for deleted.

Blame virtual text example: "Author (commit message, time ago)"

Displays may differ based on colorscheme and config.

### Advanced Features

- **Base Changing**: `:Gitsigns change_base <REVISION>` to compare against a branch or commit.
- **Diff Views**: `:Gitsigns diffthis <REVISION>` opens a split diff.
- **Quickfix Integration**: `:Gitsigns setqflist all` for repo-wide hunks.
- **Fugitive Integration**: Automatically sets base in fugitive buffers.
- **Trouble.nvim**: Uses Trouble for lists if present (configurable).
- **Statusline**: Use `b:gitsigns_status` for custom status (e.g., "+1 ~2 -3").

[Unverified]: Performance on very large repositories may require increasing `update_debounce`.

### Troubleshooting

- No signs: Ensure file is tracked; check `:Gitsigns` for errors.
- Blame delays: Adjust `current_line_blame_opts.delay`.
- Conflicts with other sign plugins: Increase `sign_priority`.
- Use `:lua require("gitsigns").toggle_signs()` to test visibility.

Commit changes before operations, as some modify files directly.

**Conclusion**

Gitsigns enhances Git workflows with visual cues and quick actions, making it suitable for version control in code editing. While LazyVim may favor mini.diff in recent updates, adding Gitsigns provides specialized features for users preferring its interface.

**Next Steps**

- Review the plugin's GitHub for issues and contributions.
- Test in a Git repo to customize mappings.
- Explore mini.diff as an alternative if using LazyVim extras.

---

