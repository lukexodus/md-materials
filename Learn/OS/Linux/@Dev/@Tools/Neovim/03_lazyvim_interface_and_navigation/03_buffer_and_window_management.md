## Buffer and Window Management


### Introduction

In Neovim, a buffer represents a file loaded into memory, allowing editing without necessarily displaying it in a window. Multiple buffers can exist simultaneously, and they persist even if not visible. A window, on the other hand, is a viewport that displays the content of a buffer. You can have multiple windows open, each showing different buffers or splits of the same buffer. Tabs in Neovim function as layouts that can contain multiple windows, providing a way to organize workspaces.

LazyVim, a Neovim configuration built on lazy.nvim for plugin management, provides default keybindings and plugins to streamline buffer and window handling. These defaults leverage plugins such as mini.bufremove for safe buffer deletion (which closes buffers without affecting windows) and which-key.nvim for displaying available keymaps in a popup. Note that behavior may vary depending on your specific Neovim version, additional plugins, or custom configurations overriding defaults.

### Buffer Basics

Buffers in LazyVim are managed with an emphasis on efficiency, allowing quick navigation, pinning, and deletion. By default, LazyVim does not automatically close buffers when windows or tabs are closed, as buffers are shared across the editor. This design helps maintain state, but users should manually manage buffers to avoid accumulation.

**Key Points**
- Buffers can be switched, deleted, or pinned without disrupting the window layout.
- Plugin integration: mini.bufremove handles deletions to keep windows intact where possible.
- Searching and selecting buffers uses telescope.nvim by default for fuzzy finding.

### Buffer Keybindings

LazyVim provides the following default keybindings for buffers (modes indicated in parentheses, where `n` is normal mode). These are facts derived from official documentation.

- `<S-h>`: Previous buffer (`n`)
- `[b`: Previous buffer (`n`)
- `]b`: Next buffer (`n`)
- `<leader>bb`: Switch to other buffer (cycles between the two most recent) (`n`)
- `<leader>`\`: Switch to other buffer (alternative to `<leader>bb`) (`n`)
- `<leader>bd`: Delete current buffer (uses mini.bufremove) (`n`)
- `<leader>bo`: Delete other buffers (closes all except the current one) (`n`)
- `<leader>bD`: Delete buffer and its window (`n`)
- `<leader>bl`: Delete buffers to the left (in bufferline order, if applicable) (`n`)
- `<leader>bp`: Toggle pin on current buffer (`n`)
- `<leader>bP`: Delete non-pinned buffers (`n`)
- `<leader>br`: Delete buffers to the right (in bufferline order, if applicable) (`n`)
- `[B`: Move current buffer to previous position in buffer list (`n`)
- `]B`: Move current buffer to next position in buffer list (`n`)
- `<S-l>`: Next buffer (`n`)
- `<leader>fb`: Open buffer picker (fuzzy search with telescope) (`n`)
- `<leader>fB`: Open buffer picker for all buffers, including hidden ones (`n`)

Note: `<leader>` is `<Space>` by default in LazyVim. Behavior of deletions may vary if mini.bufremove is disabled or if the buffer is the last one in a window.

**Example**  
Suppose you have three open buffers: file1.lua, file2.md, and file3.txt. To cycle to the previous buffer:  
Press `<S-h>` or `[b`.  
This switches the current window's view to the prior buffer in the list.

**Example**  
To delete the current buffer without closing the window:  
Press `<leader>bd`.  
The window will then display another open buffer, if available.

### Window Basics

Windows allow splitting the screen to view multiple buffers simultaneously. LazyVim retains Neovim's core window commands while adding conveniences like resizing and zooming. Standard Vim motions like `<C-w>` prefixes are preserved, enhanced by which-key.nvim for discoverability.

**Key Points**
- Windows can be split horizontally or vertically.
- Resizing uses arrow keys with Control.
- Zoom mode maximizes the current window temporarily.

### Window Keybindings

The following are default keybindings for windows (normal mode unless specified).

- `<C-h>`: Go to left window (`n`)
- `<C-j>`: Go to lower window (`n`)
- `<C-k>`: Go to upper window (`n`)
- `<C-l>`: Go to right window (`n`)
- `<C-Up>`: Increase window height (`n`)
- `<C-Down>`: Decrease window height (`n`)
- `<C-Left>`: Decrease window width (`n`)
- `<C-Right>`: Increase window width (`n`)
- `<leader>-`: Split window below (horizontal split) (`n`)
- `<leader>|`: Split window right (vertical split) (`n`)
- `<leader>wd`: Delete current window (`n`)
- `<leader>wm`: Toggle zoom mode (maximize/restore window) (`n`)
- `<leader>uZ`: Toggle zoom mode (alternative) (`n`)
- `<C-w><Space>`: Enter Window Hydra mode (shows which-key popup for more window commands) (`n`)

Behavior may vary in terminal windows or with certain plugins affecting focus.

**Example**  
To create a vertical split showing the same buffer:  
Press `<leader>|`.  
This opens a new window to the right, displaying the current buffer. Navigate between them with `<C-h>` or `<C-l>`.

**Example**  
To resize a window taller:  
Press `<C-Up>` repeatedly.  
This adjusts the current window's height incrementally.

### Tab Management

Tabs in Neovim (and LazyVim) are akin to pages, each containing its own window layout. They are useful for grouping related work. LazyVim adds tab-specific keybindings under `<leader><Tab>`.

**Key Points**
- Tabs do not close buffers; they manage window arrangements.
- Useful for separating projects or workflows.

### Tab Keybindings

Default keybindings for tabs (normal mode).

- `<leader><Tab>l`: Switch to last tab (`n`)
- `<leader><Tab>o`: Close other tabs (`n`)
- `<leader><Tab>f`: Switch to first tab (`n`)
- `<leader><Tab><Tab>`: Create new tab (`n`)
- `<leader><Tab>]`: Next tab (`n`)
- `<leader><Tab>d`: Close current tab (`n`)
- `<leader><Tab>[`: Previous tab (`n`)

**Example**  
To open a new tab with the current window layout:  
Press `<leader><Tab><Tab>`.  
This creates a blank tab; you can then open buffers as needed.

**Example**  
To cycle to the next tab:  
Press `<leader><Tab>]`.  
This switches the entire view to the next tab's layout.

### Practical Scenarios

**Scenario: Multi-File Editing**  
Open multiple files as buffers using `:e file1` and `:e file2`. Use `<leader>fb` to fuzzy-search and switch. Pin important ones with `<leader>bp` to protect them from bulk deletions like `<leader>bP`.

**Scenario: Split-Screen Debugging**  
Split vertically with `<leader>|`, navigate with `<C-h/j/k/l>`, and zoom with `<leader>wm` for focused editing. Close the split with `<leader>wd` when done.

**Output**  
In a session with splits, pressing `<C-w><Space>` might display a which-key popup showing options like `h/j/k/l` for movement, `s/v` for splits, etc. Actual output depends on your setup.

### Advanced Tips

- Integrate with bufferline.nvim (enabled by default) for visual tabs above the editor, showing buffer names.
- For customizations, edit `lua/config/keymaps.lua` in your LazyVim config to override defaults [Inference based on general Neovim practices].
- If buffers accumulate, use `<leader>bo` sparingly, as it closes all others, potentially losing unsaved changes (Neovim prompts for saves).

Note: Some keybindings like `]b` or `<S-l>` may lack descriptions in docs but function as next/previous buffer [Unverified in edge cases].

**Conclusion**  
LazyVim's defaults offer a robust system for managing buffers and windows, balancing Neovim's flexibility with user-friendly keybindings. This setup can improve productivity for most users, though experimentation with which-key popups is recommended to discover full capabilities.

**Next Steps**  
Explore LazyVim's configuration files to tweak keymaps. Consider adding plugins like trouble.nvim for enhanced diagnostics in splits, or review the full keymaps documentation for overlaps with other features.

---

