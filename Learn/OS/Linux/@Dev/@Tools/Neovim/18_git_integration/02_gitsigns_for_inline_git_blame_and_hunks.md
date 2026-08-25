## Gitsigns for Inline Git Blame and Hunks


### Overview of Gitsigns

Gitsigns.nvim provides Git integration for buffers, displaying signs in the sign column for changes since the last commit, and enabling interactive hunk management. It supports inline git blame, showing author and commit details as virtual text on the current line. In LazyVim, Gitsigns is enabled by default as part of the core editor plugins, unless the `extras.editor.mini-diff` extra is activated, which may disable it due to overlapping functionality. Behavior may vary based on user configurations and Neovim version (requires >= 0.9).

**Key Points**
- Displays signs for added, changed, deleted, and staged lines.
- Allows staging, resetting, and previewing hunks.
- Inline blame can be toggled and customized.
- Integrates with statusline and quickfix lists.

### Setup and Configuration

Gitsigns attaches automatically to Git-tracked buffers when loaded. In LazyVim, it's pre-configured without needing manual setup, but customizations can be added via a plugin spec.

To customize:
```lua
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add = { text = "┃" },
      change = { text = "┃" },
      delete = { text = "_" },
      -- Additional sign options...
    },
    current_line_blame = true, -- Enable inline blame by default
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- Position: 'eol', 'overlay', 'right_align'
      delay = 1000,
      ignore_whitespace = false,
    },
    current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
    word_diff = false, -- Can be toggled
  },
}
```

Place this in `~/.config/nvim/lua/plugins/gitsigns.lua`. The plugin may auto-attach to untracked files if configured, but defaults to false.

**Example**
Enabling inline blame with a custom formatter:
```lua
require("gitsigns").setup({
  current_line_blame = true,
  current_line_blame_formatter = function(blame_info)
    return string.format("%s (%s ago): %s", blame_info.author, blame_info["author_time"]:format("%R"), blame_info.summary)
  end,
})
```

**Output**
Inline text may appear at the end of the line, like "Author (2 hours ago): Commit message". Display may differ based on theme and buffer content.

### Inline Git Blame Features

Inline blame displays commit information for the current line as virtual text. It can be enabled globally or toggled per buffer.

Commands:
- `:Gitsigns toggle_current_line_blame` to toggle.
- `:Gitsigns blame_line {full=true}` for a popup with full details.

In LazyVim, default keymaps may include `<leader>tb` for toggling blame, based on common configurations.

**Key Points**
- Delay option prevents immediate display on cursor move.
- Formatter is customizable with Lua functions or strings.
- Supports focus mode for better performance.

**Example**
Toggle blame in a keymap:
```lua
vim.keymap.set("n", "<leader>gb", require("gitsigns").toggle_current_line_blame, { desc = "Toggle Git Blame" })
```

**Output**
When enabled, virtual text may show on the current line. [Inference: Performance may vary in large files, potentially causing slight delays.]

### Hunk Management and Navigation

Hunks represent changed sections. Gitsigns allows navigation, staging, resetting, and previewing.

Navigation:
- `]c` to next hunk (falls back to diff mode if in diff).
- `[c` to previous hunk.

Management:
- Stage hunk: `:Gitsigns stage_hunk`
- Reset hunk: `:Gitsigns reset_hunk`
- Preview: `:Gitsigns preview_hunk` or `:Gitsigns preview_hunk_inline`

In visual mode, operations apply to selected lines.

In LazyVim, default keymaps often include:
- `<leader>hs` for stage hunk
- `<leader>hr` for reset hunk
- `<leader>hp` for preview

**Key Points**
- Supports partial hunks in visual mode.
- Stage/reset entire buffer with `stage_buffer` / `reset_buffer`.
- Word-diff highlights intra-line changes when enabled.

**Example**
Keymaps in `on_attach`:
```lua
local gs = require("gitsigns")
vim.keymap.set("n", "]h", function() gs.nav_hunk("next") end, { desc = "Next Hunk" })
vim.keymap.set("n", "[h", function() gs.nav_hunk("prev") end, { desc = "Prev Hunk" })
vim.keymap.set({ "n", "v" }, "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk" })
```

**Output**
Navigating may jump the cursor to the next changed section, updating signs. Staging may update the sign column to reflect staged status.

### Advanced Features

- **Diff Views**: `:Gitsigns diffthis <REVISION>` opens a diff against a base.
- **Quickfix Integration**: `:Gitsigns setqflist` populates quickfix with hunks.
- **Text Objects**: Use `ih` in operator-pending mode to select a hunk.
- **Toggles**: `:Gitsigns toggle_word_diff`, `:Gitsigns toggle_signs`, etc.

Statusline integration via `b:gitsigns_status` for displaying changes.

[Unverified: In 2026 versions, statuscolumn integration may enhance sign display in custom status columns.]

**Example**
Populate quickfix with all hunks:
```lua
vim.keymap.set("n", "<leader>hq", function() require("gitsigns").setqflist("all") end, { desc = "Hunks to Quickfix" })
```

**Output**
Quickfix list may show entries like "file.lua|10| @@ -1,1 +1,1 @@ change". Navigation via `:cnext` / `:cprev`.

### Potential Conflicts and Customizations

If using `extras.editor.mini-diff`, Gitsigns may be disabled. To re-enable, remove the extra or override in config.

For large files, set `max_file_length` to avoid performance issues.

**Key Points**
- Compatible with other VCS tools like Neogit.
- Events like `User GitsignsAttach` for hooks.

**Conclusion**
Gitsigns enhances Git workflows with visual cues and interactive commands for blame and hunks, seamlessly integrated in LazyVim.

**Next Steps**
- Add custom keymaps in `~/.config/nvim/lua/config/keymaps.lua`.
- Explore `:Gitsigns` commands via `:help gitsigns`.
- Test in a Git repo to observe sign and blame behavior variations.

---

