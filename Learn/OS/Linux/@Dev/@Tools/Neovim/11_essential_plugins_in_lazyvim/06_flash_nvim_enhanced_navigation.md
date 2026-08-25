## Flash.nvim - Enhanced Navigation


### Overview

Flash.nvim is a Neovim plugin that enhances code navigation by integrating search labels, improved character motions, and Treesitter support. In LazyVim, it is included by default as part of the editor plugins, providing quick jumps to matches during searches or motions. This allows users to type patterns and select labels for precise movement, reducing the need for repeated key presses. It builds on Neovim's built-in search (`/` or `?`) by adding visual labels, and extends motions like `f`, `t`, `F`, `T`. Treesitter integration enables labeling of syntactic nodes for selection or operations. While highly extensible, its behavior may vary depending on Neovim version (requires >= 0.8.0 with LuaJIT), active modes, and conflicts with other plugins.

### Features

Flash.nvim offers several navigation enhancements tailored for efficient editing.

**Key Points**
- **Search Labels**: Displays labels next to search matches, allowing jumps by typing the label after a pattern.
- **Enhanced Motions**: Improves `f/t/F/T` with multi-line support, labels for ambiguous matches, and next/prev navigation via `;`/`,`.
- **Treesitter Integration**: Labels parent nodes of the cursor's Treesitter node for quick selection.
- **Jump Mode**: Standalone jumping similar to search, with customizable patterns.
- **Remote Actions**: Performs motions from a remote position, restoring the original view after operation.
- **Multi-Window Support**: Jumps across windows.
- **Search Modes**: Supports exact, regex, fuzzy, or custom matching.
- **Dot-Repeatable**: Jumps can be repeated with `.`.
- **Extensibility**: Custom actions, matchers, and highlight groups.
- Behavior may vary: Labels may not appear in excluded filetypes or non-focusable windows.

### Integration in LazyVim

In LazyVim, Flash.nvim is pre-configured and enabled by default via the `lua/lazyvim/plugins/editor.lua` file. It loads on the `VeryLazy` event, ensuring it doesn't impact initial startup significantly.

**Key Points**
- Included as `{ "folke/flash.nvim", ... }` with empty `opts = {}` , using the plugin's defaults unless overridden.
- Compatible with VS Code environments (`vscode = true`).
- To disable: Create `lua/plugins/disable.lua` with `{ "folke/flash.nvim", enabled = false }`.
- LazyVim adds a custom keymap for simulating Treesitter incremental selection.
- No additional extras are required; it's core to editor enhancements.
- [Inference]: This setup keeps navigation lightweight, but adding many custom matchers could increase overhead.

### Configuration Options

Flash.nvim's configuration is a Lua table passed to `opts`. In LazyVim, it's empty by default, but you can override it in `lua/plugins/editor.lua` or a custom file in `lua/plugins/`.

**Key Points**
- **labels**: String of characters for labels (default: `"asdfghjklqwertyuiopzxcvbnm"`).
- **search**: Controls direction, wrap, mode (e.g., `exact`, `fuzzy`), incremental, max length, and exclusions.
- **jump**: Manages jumplist addition, position (`start`, `end`, `range`), history, register, autojump.
- **label**: Configures uppercase usage, exclusion, placement (before/after), style (`overlay`, `eol`, `inline`), reuse, rainbow effects.
- **highlight**: Backdrop, matches, priority (default 5000), groups for customization.
- **modes**: Per-mode settings for search, char, treesitter, remote, etc.
- **prompt**: Floating window for input, with prefix and position.
- To customize in LazyVim: Return a table like `{ "folke/flash.nvim", opts = { labels = "abcdefghijklmnopqrstuvwxyz" } }` in `lua/plugins/flash.lua`.
- Behavior may vary: Changes to highlight priority could affect rendering in buffers with many extmarks.

### Keymaps in LazyVim

LazyVim defines specific keymaps for Flash.nvim, which can be overridden in `lua/config/keymaps.lua`.

**Key Points**
- `s` (normal, visual, operator): Triggers `require("flash").jump()` for general flashing.
- `S` (normal, operator, visual): Calls `require("flash").treesitter()` for Treesitter-based selection.
- `r` (operator): Activates `require("flash").remote()` for remote operations.
- `R` (operator, visual): Invokes `require("flash").treesitter_search()` for Treesitter search.
- `<c-s>` (command): Toggles flash search with `require("flash").toggle()`.
- `<c-space>` (normal, operator, visual): Simulates Treesitter incremental selection with custom next/prev actions (`<c-space>` for next, `<BS>` for prev).
- Use Lua functions in keymaps to preserve dot-repeat functionality.
- Behavior may vary: In operator-pending mode, these may interact differently with pending operations.

### Usage Instructions

Flash.nvim integrates into common workflows for navigation.

**Key Points**
- **Basic Jump**: Press `s`, type a pattern (e.g., 1-2 chars), then a label to jump.
- **Search Enhancement**: During `/` or `?`, labels appear; toggle with `<c-s>` in command mode.
- **Character Motions**: Use `f<char>`, then `;`/` , ` for next/prev; labels show for multi-matches.
- **Treesitter**: `S` labels nodes; select with label or navigate with `;`/`,`.
- **Remote**: In operator-pending (e.g., `yr`), select label, perform action, returns to original position.
- **Treesitter Search**: `R` in operator mode labels surrounding nodes for operations like yank.
- Clear highlights: On cursor move, buffer change, or `<esc>`.
- Continue previous: `require("flash").jump({ continue = true })`.
- Behavior may vary: In multi-window setups, jumps respect window focus.

### Available Modes

Flash.nvim supports multiple modes, configurable per use case.

**Key Points**
- **search**: Enhances `/`?` with labels; incremental if `incsearch` enabled.
- **char**: For `f/t/F/T`; optional jump labels, multi-line by default.
- **treesitter**: Labels parent nodes; `pos = "range"`, autojump enabled.
- **remote**: Operator-pending remote motions; restores view.
- **treesitter_search**: Combines search and Treesitter; multi-window, inline labels.
- **diagnostic**: Customizable via actions (e.g., show diagnostics without moving).
- Override modes in opts, e.g., `modes = { search = { enabled = false } }`.
- [Unverified]: Diagnostic mode is example-based, not a built-in mode.

### Customization Examples

**Example** Custom forward-only jump in a keymap:
```lua
vim.keymap.set("n", "<leader>fj", function()
  require("flash").jump({ search = { forward = true, wrap = false, multi_window = false } })
end, { desc = "Forward Jump" })
```

**Output**: Press `<leader>fj`, type pattern, select label; jumps forward without wrapping.

**Example** Match word beginnings:
```lua
-- In lua/plugins/flash.lua
return {
  "folke/flash.nvim",
  opts = {
    search = {
      mode = function(str)
        return "\\<" .. str
      end,
    },
  },
}
```

**Output**: Jumps target word starts, e.g., "foo" matches "foobar" at beginning.

**Example** Show diagnostics on match:
```lua
vim.keymap.set("n", "<leader>fd", function()
  require("flash").jump({
    action = function(match, state)
      vim.api.nvim_win_call(match.win, function()
        vim.api.nvim_win_set_cursor(match.win, match.pos)
        vim.diagnostic.open_float()
      end)
      state:restore()
    end,
  })
end, { desc = "Flash Diagnostics" })
```

**Output**: Jumps to label and opens diagnostic float, then restores position.

### Performance Considerations

Flash.nvim is designed for efficiency, using LuaJIT and extmarks.

**Key Points**
- Labels reuse to minimize redraws.
- Excludes certain windows/filetypes to avoid unnecessary processing.
- Rainbow and backdrop highlights optional; may add overhead in large buffers.
- Prompt is minimal floating window; disabled in VS Code.
- In LazyVim, lazy-loading on `VeryLazy` defers impact.
- Monitor with `:Lazy profile`; custom actions could introduce delays.
- Behavior may vary: On slower systems, multi-window or fuzzy modes might slow responses.

### Potential Pitfalls and Troubleshooting

- **Conflicts**: May overlap with other motion plugins; disable modes if needed.
- **Labels Not Showing**: Check exclusions or toggle state.
- **Dot-Repeat Issues**: Use Lua functions in keymaps.
- **Treesitter Dependency**: Requires nvim-treesitter; install parsers with `:TSInstall`.
- [Inference]: In high-extmark scenarios, highlights might flicker.

### Conclusion

Flash.nvim significantly improves navigation in LazyVim by adding intuitive labels and Treesitter awareness, making code movement faster and more precise.

### Next Steps

- Test default keymaps like `s` in a buffer.
- Customize opts in `lua/plugins/` and reload with `:Lazy sync`.
- Explore extensions in the Flash.nvim README for advanced setups.

---

