## Pattern Searching (/, ?, *, #)


### Introduction

Pattern searching in Neovim allows users to locate and navigate to specific text patterns within buffers using commands like /, ?, *, and #. These are core Vim features inherited by Neovim, enabling forward and backward searches for strings or regular expressions. In LazyVim, these commands integrate with default options like incremental search and highlighting, and may be enhanced by plugins such as flash.nvim for visual feedback or telescope.nvim for extended searching. Searches operate on the current buffer by default, but can extend to multiple buffers via commands or plugins. Behavior may vary based on Neovim version, buffer size, or active plugins.

**Key Points**  
- / initiates forward search from the cursor.  
- ? initiates backward search from the cursor.  
- * searches forward for the word under the cursor.  
- # searches backward for the word under the cursor.  
- Supports regular expressions with configurable magic levels.  
- Results are highlighted if 'hlsearch' is enabled, which is default in LazyVim.

### Basic Search Commands

The / and ? commands open a command-line prompt at the bottom of the window for entering a search pattern. Pressing Enter executes the search, moving the cursor to the first match. Neovim supports incremental searching ('incsearch' option, enabled by default in LazyVim), showing matches as you type.

- **Forward Search (/)**: Scans from the cursor position downward. Wrapping around the file if 'wrapscan' is set (default on).  
- **Backward Search (?)**: Scans from the cursor position upward, also wrapping if applicable.  

After searching, use n to go to the next match and N to the previous, reversing direction based on the initial command. To clear highlights, use :nohlsearch or LazyVim's default mapping \<Esc> in normal mode.

**Example**  
In a buffer with text "hello world hello", place cursor at start and press /hello\<Enter>. Cursor moves to first "hello". Press n to jump to the next.

**Output**  
The screen highlights all "hello" instances, with the cursor on the matched text. Actual display depends on colorscheme and terminal.

### Word Search Commands

The * and # commands automatically search for the word or WORD under the cursor, treating it as a whole-word match by default (bounded by \< and \> in regex). This is useful for quick navigation to variable or function names.

- **Forward Word Search (*)**: Finds the next occurrence forward.  
- **Backward Word Search (#)**: Finds the previous occurrence backward.  

These respect 'ignorecase' and 'smartcase' options (enabled in LazyVim), ignoring case if all lowercase but respecting if mixed. For non-word characters, g* and g# variants search without boundaries.

**Key Points**  
- Matches exact words by default.  
- Uses current cursor position as reference.  
- Integrates with jump list (Ctrl-O/Ctrl-I to navigate history).  

**Example**  
With cursor on "function" in code, press *. Neovim jumps to the next "function", highlighting all matches.

### Search Patterns and Regular Expressions

Patterns can be simple strings or complex regex. Neovim uses Vim-compatible regex with modes like 'magic' (default), where metacharacters like . * [] need no escape for basic use. Enable 'very magic' with \v for Perl-like regex.

Common patterns:  
- . matches any character.  
- * matches zero or more of previous.  
- \s matches whitespace.  
- ^ and $ for line start/end.  

In LazyVim, search history is accessible via q/ or q? for editing past searches.

[Inference: In Neovim 0.10+, improved regex engine may handle large buffers more efficiently, though performance varies by pattern complexity.]

**Example**  
Search for lines starting with "TODO": /^TODO\<Enter>.  
For regex: /\v\d{4}-\d{2}-\d{2} to find dates like 2026-01-03.

### Navigation and Repeating Searches

After a search, n/N repeat in the respective directions. Use gn/gN for visual selections on matches. In LazyVim, flash.nvim (if enabled via extras) provides label-based jumping for search results, enhancing multi-match navigation with keys like s/S for flash search.

To search across files, integrate with :vimgrep or telescope.nvim's live_grep.

Behavior may vary if 'wrapscan' is disabled or in very large files.

**Key Points**  
- n/N for next/previous.  
- Flash integration for visual jumps in LazyVim.  
- Search history with \<Up>/\<Down> in prompt.

**Example**  
After /pattern\<Enter>, press n multiple times to cycle matches. With flash, labels appear for quick selection.

### Options Affecting Search

LazyVim sets defaults in lua/config/options.lua:  
- 'hlsearch' = true: Highlights matches.  
- 'incsearch' = true: Shows as you type.  
- 'ignorecase' = true: Case-insensitive.  
- 'smartcase' = true: Case-sensitive if uppercase present.  

Override in user config, e.g., vim.opt.hlsearch = false. These affect /, ?, *, # uniformly.

**Example**  
To toggle case sensitivity: :set noignorecase. Then searches respect case exactly.

### Enhancements in LazyVim

LazyVim includes plugins that build on core search:  
- **flash.nvim**: Adds f/F/t/T enhancements and s for multi-line searches with labels.  
- **telescope.nvim**: For fuzzy searching files or buffers with :Telescope live_grep.  
- **which-key.nvim**: Shows search-related mappings.  

Enable extras like editor.flash for advanced features via :LazyExtras.

**Key Points**  
- Core commands remain, plugins add layers.  
- No core changes to /?*# , but workflows improve.

### Customization and Keybindings

Customize via lua/config/keymaps.lua. For example, remap * to include boundaries explicitly.

Add autocmds for search events, like highlighting yanks.

In LazyVim, default \<Esc> clears hlsearch; customize with vim.opt.

**Example**  
In keymaps.lua:  
```lua
vim.keymap.set("n", "*", [[*<Cmd>lua require('flash').treesitter()<CR>]], { desc = "Flash Search" })
```  
This combines * with flash for labeled jumps, if flash is enabled.

### Troubleshooting Common Issues

- No matches: Check pattern syntax or case options.  
- Slow searches: Complex regex on large files; simplify or use :grep.  
- Highlights persist: Use :noh or remap.  
- Plugin conflicts: Disable extras to isolate.  

Run :checkhealth for option conflicts.

[Speculation: Future Neovim updates might optimize search for UTF-8, but depends on release notes.]

**Conclusion**  
Pattern searching with /, ?, *, # provides foundational navigation in Neovim, augmented in LazyVim by options and plugins for efficient text location and manipulation.

**Next Steps**  
- Experiment with regex in :help pattern.  
- Enable flash.nvim via :LazyExtras for enhanced jumping.  
- Explore telescope integrations for project-wide searches.

---

