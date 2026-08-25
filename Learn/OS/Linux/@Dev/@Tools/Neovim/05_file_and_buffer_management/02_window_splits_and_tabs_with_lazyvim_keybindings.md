## Window Splits and Tabs with LazyVim Keybindings


### Understanding Splits and Windows

In Neovim, windows are viewports displaying buffers. Splits divide the editor into multiple windows, either horizontally or vertically, allowing simultaneous viewing and editing of different parts of files or different files. Tabs, on the other hand, are containers for layouts of windows; each tab can hold its own arrangement of splits. This distinction means tabs group window configurations, while splits manage divisions within a tab.

Core commands for splits include `:split` or `:vsplit` for horizontal and vertical divisions. For tabs: `:tabnew`, `:tabnext`, etc. LazyVim enhances these with plugins and keymaps for smoother workflows, often integrating tools like which-key for discoverability.

**Key Points**
- Windows can be navigated, resized, split, and closed independently.
- Tabs allow switching between different workspace-like setups.
- Behavior may vary with window managers or terminal emulators, especially regarding focus and resizing.

### Creating and Managing Splits

Splits are created to divide the screen. In LazyVim, default keymaps simplify this without typing full commands.

From the documentation:
- `<leader>-`: Split window below (horizontal split).
- `<leader>|`: Split window right (vertical split).

These map to `:split` and `:vsplit` under the hood.

**Example**
To create a horizontal split: Position cursor in a buffer, press `<leader>-`. This opens a new window below with the same buffer.

**Output**
The screen divides horizontally; the new window may display the current buffer or an empty one depending on options like 'splitbelow'. Navigation between splits becomes active.

### Navigating Between Windows

Navigation uses directional keys to move focus.

Keymaps:
- `<C-h>`: Go to left window.
- `<C-j>`: Go to lower window.
- `<C-k>`: Go to upper window.
- `<C-l>`: Go to right window.

These are in normal mode and may override terminal shortcuts in some setups.

**Example**
With two vertical splits, press `<C-h>` to move left.

**Output**
Focus shifts to the left window; if no window exists there, it may do nothing or wrap around based on 'winfixwidth' settings.

### Resizing Windows

Adjusting split sizes improves usability.

Keymaps:
- `<C-Up>`: Increase window height.
- `<C-Down>`: Decrease window height.
- `<C-Left>`: Decrease window width.
- `<C-Right>`: Increase window width.

These incrementally resize by a set amount, often configurable.

**Example**
In a horizontal split, press `<C-Up>` multiple times.

**Output**
The current window's height increases; total screen layout adjusts accordingly. Exact increment may depend on 'winheight' or plugin configurations.

### Closing and Deleting Windows

To manage clutter, close unnecessary windows.

Keymaps:
- `<leader>wd`: Delete window.
- `<leader>wq`: Close window (inferred from standard Vim behavior, though not explicitly listed; use `:q` or `<C-w>q` as fallback).

**Example**
Press `<leader>wd` in a split.

**Output**
The window closes, and focus moves to another; if it's the last window, the tab may close or Neovim quits if no tabs remain.

### Zooming and Special Modes for Windows

For focused work, toggle full-screen-like views.

Keymaps:
- `<leader>wm`: Toggle zoom mode (maximizes current window).
- `<leader>uZ`: Toggle zoom mode.
- `<leader>uz`: Toggle Zen mode (distraction-free, often via zen-mode.nvim plugin).

**Example**
Press `<leader>wm` to zoom in, then again to restore.

**Output**
The window expands to fill the screen temporarily; original layout restores on toggle. Plugin availability affects this.

### Tab Creation and Management

Tabs organize groups of windows.

Keymaps:
- `<leader><tab>l`: Last tab.
- `<leader><tab>o`: Close other tabs.
- `<leader><tab>f`: First tab.
- `<leader><tab><tab>`: New tab.
- `<leader><tab>d`: Close tab.

These provide quick tab switching and maintenance.

**Example**
Press `<leader><tab><tab>` to open a new tab, then `<leader><tab>l` to switch back.

**Output**
A new tab opens with a single window; switching tabs preserves window layouts per tab. Tab count shows in the tabline if enabled.

### Advanced Window Operations with Hydra Mode

For complex tasks, activate a mode showing options.

Keymap:
- `<C-w><Space>`: Window Hydra mode (via which-key).

This displays a popup with further window commands.

**Example**
Press `<C-w><Space>`, then select an option like 's' for split.

**Output**
Which-key overlay appears with bindings; selecting executes the command. Availability depends on which-key plugin configuration.

### Customization of Keybindings

In LazyVim, keymaps are defined in `~/.config/nvim/lua/config/keymaps.lua`. Override or add bindings here, e.g., remap split keys.

**Key Points**
- Use `vim.keymap.set` for custom mappings.
- Check conflicts with `:map` command.
- Plugins like smart-splits.nvim may enhance resizing if installed as extras.

[Inference]: Based on community patterns, users often add tmux-like navigation for consistency.

### Common Workflows and Tips

- Workflow: Split for side-by-side editing, tabs for project sections.
- Tip: Use `:only` or `<C-w>o` to close all but current window.
- Integration: With buffers via `<leader>bb` for switching, complementing windows.

Behavior may vary with Neovim versions or added extras in LazyVim.

**Conclusion**
LazyVim's keybindings streamline window splits and tab management, building on Neovim's core for efficient multi-view editing. Mastering these reduces reliance on mouse or menus.

**Next Steps**
- Review full keymaps with `<leader>sk` in Neovim.
- Experiment in a session with multiple files.
- Explore extras like mini.bufremove for advanced closing.

---

