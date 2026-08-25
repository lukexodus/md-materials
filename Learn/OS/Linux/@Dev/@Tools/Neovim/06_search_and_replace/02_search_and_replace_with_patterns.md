## Search and Replace with Patterns


### Overview of Search Functionality
Search functionality in Neovim allows locating text using patterns, which can include regular expressions. In LazyVim, this is enhanced by plugins such as flash.nvim for improved navigation and highlighting, and telescope.nvim for fuzzy searching across files. Basic search uses forward slash (/) or question mark (?) in normal mode, with behavior potentially influenced by user configurations or plugin interactions.

**Key Points**
- Forward search: /pattern\<Enter> searches forward; ?pattern\<Enter> searches backward.
- Next/previous: n moves to next match; N to previous.
- Highlighting: Matches are highlighted if 'hlsearch' is enabled (default in LazyVim).
- Incremental search: Enabled by 'incsearch', showing matches as you type.
- Case sensitivity: Controlled by 'ignorecase' and 'smartcase' (enabled in LazyVim), ignoring case unless uppercase is used.
- Behavior may vary if plugins like noice.nvim alter command-line interactions.

**Example**
To find "function" case-insensitively:
1. Press /function\<Enter>.
2. Press n to jump to next occurrences.
Matches highlight, and the cursor moves accordingly.

### Basic Patterns and Regular Expressions
Patterns in searches can be literal or use regex syntax. Neovim supports Vim's regex dialect, with modes like magic (\m) or very magic (\v) to simplify escapes.

**Key Points**
- Literal search: /text finds "text" exactly.
- Special characters: . matches any char; * zero or more; + one or more; ? zero or one.
- Anchors: ^ start of line; $ end; \< word start; \> word end.
- Character classes: [a-z] range; [^a-z] negation; \s whitespace; \d digit.
- Magic mode: Default; escape specials with \ (e.g., /\. for literal dot).
- Very magic: Prefix with \v (e.g., /\\vfunction[0-9]+); no need to escape most specials.
- Use \M for nomagic or \V for very nomagic for literal matches.
- Patterns may behave differently in multibyte encodings or with 'fileencoding'.

**Example**
Search for variables like var1, var2:
Press /\vvar\d+\<Enter>.
This uses very magic, matching "var" followed by one or more digits.

### Enhanced Search with LazyVim Plugins
LazyVim integrates plugins that extend search capabilities, such as flash.nvim for labeled jumps and telescope.nvim for project-wide searches.

**Key Points**
- Flash search: s\<char> in normal mode for two-char search with labels; S for backward.
- Telescope: \<leader>fw for live grep; \<leader>fs for symbol search.
- Word under cursor: * searches forward; # backward; g* without word boundaries.
- In LazyVim, \<leader>/ toggles nohlsearch to clear highlights.
- Multi-file search: Uses ripgrep via telescope; requires rg installed.
- [Inference]: Flash.nvim may override some default motions in certain configurations.

**Example**
Project-wide search for "error":
Press \<space>fw, type "error", select from results.
Telescope displays matches with previews.

### Basic Replace Operations
Replace uses the :substitute command (:s), applying patterns to lines or ranges. It supports flags for global, confirm, etc.

**Key Points**
- Syntax: :[range]s/pattern/replacement/flags
- Range: % for whole file; . for current line; 1,$ same as %.
- Flags: g global (all per line); c confirm; i ignore case; I case sensitive.
- Replacement: & or \0 for whole match; \1-\9 for groups; \u upper; \l lower.
- Use \= for expressions (e.g., \=line('.') for line number).
- Undo: Changes are undoable with u; grouped if 'undolevels' allows.
- Behavior may vary with 'magic' setting or if plugins hook into ex commands.

**Example**
Replace "old" with "new" in current line:
:s/old/new/g
This changes all occurrences without confirmation.

### Advanced Replace with Patterns
Combine regex in patterns and replacements for complex edits, such as capturing groups or conditional changes.

**Key Points**
- Groups: \( \) for capture; e.g., /\\(\w+\) finds words, replace with \1.
- Lookaround: \zs start match; \ze end; \(?<=pat\) positive lookbehind; \(?<!pat\) negative.
- Branches: \| for or (in very magic: |).
- Quantifiers: \{n,m\} for range; \{-} non-greedy *.
- In LazyVim, :S from substitute.nvim (if enabled) provides preview.
- Avoid overly complex patterns to prevent performance issues on large files.

**Example**
Capitalize first letter of words:
:%s/\v<(\w)(\w*)/\u\1\l\2/g
This captures first letter (\1) and rest (\2), uppercasing \1.

### Visual Mode Search and Replace
Select text visually, then apply search/replace within the selection.

**Key Points**
- Visual search: v or V to select, / to search within (but searches whole buffer).
- Replace in visual: Select, :s/pattern/repl/ (automatically scopes to selection).
- gv reselects last visual area.
- Block visual (Ctrl-v) for column edits.
- In LazyVim, plugins like yanky.nvim may affect yank/replace interactions.

**Example**
Replace in selected lines:
1. Vjj to select three lines.
2. :s/foo/bar/g
Only affects the selection.

### Global and Multi-File Replace
For broader scopes, use :global (:g) or argdo/bufdo with patterns.

**Key Points**
- :g/pattern/command executes command on matching lines.
- :g!/pattern/ for non-matching (or :v).
- Multi-buffer: :bufdo %s/pat/repl/ge | update (e flag ignores errors).
- Quickfix: Use cdo after grep to replace in list.
- In LazyVim, \<leader>sr for Spectre (if enabled) provides UI for multi-file replace.
- Operations may prompt for unsaved changes or handle read-only buffers differently.

**Example**
Delete lines containing "debug":
:g/debug/d
This removes matching lines globally.

### Configuration and Customization
LazyVim sets defaults, but users can tweak search/replace via options or keymaps.

**Key Points**
- Options: set hlsearch, incsearch, ignorecase in lua/config/options.lua.
- Keymaps: \<leader>sn for next file in quickfix; customize in lua/config/keymaps.lua.
- Plugins: Enable extras like nvim-spectre for advanced replace UI.
- [Unverified]: Some configurations may integrate AI-assisted patterns via copilot.

**Example**
Clear highlights: Add mapping if needed:
vim.keymap.set('n', '\<leader>nh', ':nohl\<CR>', { desc = 'No Highlight' })

### Troubleshooting Common Issues
Issues may arise from pattern mismatches or plugin conflicts.

**Key Points**
- No matches: Check case, magic mode, or hidden characters.
- Slow search: Simplify patterns or use nomagic.
- Replace failures: Ensure writable buffer; check error messages.
- Behavior may vary across Neovim versions or with incompatible plugins.

### Conclusion
Search and replace with patterns provide flexible text manipulation in LazyVim, leveraging built-in features and plugins for efficiency. Mastery of regex modes and flags enables precise edits, though testing on copies is advisable for complex operations.

### Next Steps
- Practice patterns in a scratch buffer using :help pattern.
- Explore telescope extensions for advanced grepping.
- Customize options to suit workflow preferences.
- Test multi-file replaces in a small project directory.

---

