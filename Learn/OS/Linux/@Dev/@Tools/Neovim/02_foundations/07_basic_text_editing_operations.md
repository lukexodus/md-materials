## Basic Text Editing Operations


### Modes Overview
Neovim operates in several modes, with Normal mode as the default for navigation and commands, Insert mode for adding text, Visual mode for selecting text, and Command-line mode for executing commands. Switching modes is fundamental to editing. For instance, press `i` to enter Insert mode from Normal mode, and `<Esc>` to return to Normal mode. Behavior may vary based on custom keymaps or plugins in a LazyVim setup.

**Key Points**
- Normal mode: Used for commands like delete or copy.
- Insert mode: Activated by keys like `i` (insert before cursor), `a` (append after cursor), `o` (new line below), or `O` (new line above).
- Visual mode: Started with `v` for character-wise, `V` for line-wise, or `<C-v>` for block-wise selection.
- Mode indicators appear in the status line, which may be customized in LazyVim.

**Example**
To insert "Hello" before existing text:
1. In Normal mode, position cursor.
2. Press `i`.
3. Type "Hello".
4. Press `<Esc>`.

### Navigating Text
Navigation allows precise cursor placement. Use arrow keys or Vim-style keys: `h` (left), `j` (down), `k` (up), `l` (right). For larger movements: `w` (next word), `b` (previous word), `0` (line start), `$` (line end), `gg` (file start), `G` (file end). In LazyVim, plugins like which-key may provide hints for these.

**Key Points**
- Character-level: `h`, `j`, `k`, `l`.
- Word-level: `w` (forward), `b` (backward), `e` (end of word).
- Line-level: `0` (start), `^` (first non-blank), `$` (end).
- Screen-level: `<C-u>` (up half-screen), `<C-d>` (down half-screen).
- These are core Neovim features; actual responsiveness may depend on terminal or GUI settings.

**Example**
To move to the end of the current line: In Normal mode, press `$`.

### Inserting and Appending Text
Entering Insert mode adds new content. Common entry points include `i` (before cursor), `a` (after cursor), `I` (line start), `A` (line end). Text typed in Insert mode appears directly. LazyVim may include auto-completion via plugins like nvim-cmp, which could suggest completions as you type.

**Key Points**
- `i`: Insert before current character.
- `a`: Append after current character.
- `o`: Open new line below.
- `O`: Open new line above.
- Exit with `<Esc>` or `<C-c>`.
- In some configurations, Insert mode may have additional mappings; check `:map` for details.

**Example**
To append " world" to "Hello":
1. Position cursor on "o".
2. Press `a`.
3. Type " world".
4. Press `<Esc>`.

**Output**
The line becomes "Hello world".

### Deleting Text
Deletion commands remove content. In Normal mode: `x` (delete character), `dw` (delete word), `dd` (delete line). Operators like `d` combine with motions (e.g., `d$` deletes to line end). In Insert mode, use `<Backspace>` or `<C-w>` (delete word). Deleted text goes to the default register for pasting.

**Key Points**
- Single character: `x` (forward), `X` (backward).
- Words: `dw` (to next word end), `db` (backward).
- Lines: `dd` (current), `dG` (to file end).
- In Visual mode, select then `d` to delete.
- Registers store deleted text; use `"*d` for system clipboard in some setups.
- Behavior may vary with undo levels or if plugins like vim-surround are active.

**Example**
To delete a word "test" in "This is test content":
1. Position cursor on "t".
2. Press `dw`.

**Output**
Becomes "This is content".

### Copying and Yanking Text
Yanking copies text to a register. Use `y` with motions: `yw` (yank word), `yy` (yank line). In Visual mode, select then `y`. Copied text can be pasted later. LazyVim often includes clipboard integration via plugins.

**Key Points**
- `y`: Yank operator.
- Examples: `yw` (word), `y$` (to line end), `yy` (line).
- Registers: Default is `"`, system clipboard may be `"+` or `"*`.
- Does not modify the buffer until pasted.
- If using clipboard, ensure `set clipboard=unnamedplus` or similar in config.

**Example**
To copy a line:
1. Position cursor on the line.
2. Press `yy`.

### Pasting Text
Pasting inserts yanked or deleted text. Use `p` (after cursor), `P` (before cursor). For block paste, use Visual block mode. If text is in clipboard, `"+p` accesses it.

**Key Points**
- `p`: Paste after cursor.
- `P`: Paste before cursor.
- In Insert mode: `<C-r>"` pastes from default register.
- Handles line-wise or character-wise based on yank type.
- May shift indentation; use `]p` for adjusted paste in some contexts.
- Plugin interactions, like auto-formatting, could alter results.

**Example**
After yanking "Hello" with `yy`, to paste below:
1. Move to desired line.
2. Press `o` (new line).
3. Press `<Esc>` then `p`.

**Output**
Inserts "Hello" on the new line.

### Undoing and Redoing Changes
Neovim tracks changes for reversal. `u` undoes last change, `<C-r>` redoes. Multiple `u` undoes steps. Undo history persists across sessions if configured.

**Key Points**
- `u`: Undo last change.
- `<C-r>`: Redo undone change.
- `:undo` or `:redo` in Command mode.
- Branching undo with `g-` (older), `g+` (newer) [Inference: Common in Neovim configs].
- Undo levels set by `undolevels` option; default allows many steps.
- File writes may create undo points; behavior depends on `undofile` setting.

**Example**
After deleting a line with `dd`, to undo:
1. Press `u`.

**Output**
Restores the deleted line.

### Searching Text
Search finds patterns. `/` starts forward search, `?` backward. Enter pattern then `<Enter>`. `n` next match, `N` previous. Highlighting shows matches.

**Key Points**
- `/pattern<Enter>`: Forward search.
- `?pattern<Enter>`: Backward.
- `*`: Search word under cursor forward.
- `#`: Backward.
- `:noh` clears highlights.
- Case sensitivity: Smartcase if configured.
- Regex support; escape special chars with `\`.

**Example**
To find "error":
1. Press `/`.
2. Type "error".
3. Press `<Enter>`.
4. Press `n` for next.

### Replacing Text
Replacement substitutes text. In Normal: `r` (single char), `cw` (change word). For global: `:s/old/new/g` on line, `:%s/old/new/g` whole file. Visual mode: Select then `:s`.

**Key Points**
- Single: `r<char>` replaces char.
- Word: `cw` deletes word, enters Insert.
- Line: `cc` changes line.
- Command: `:s/pattern/replacement/flags`.
- Flags: `g` (global), `c` (confirm), `i` (ignore case).
- Interactive replace with `c` flag prompts per match.
- May interact with plugins like substitute.nvim if installed.

**Example**
To replace "foo" with "bar" in line:
1. Press `:`.
2. Type `s/foo/bar/g`.
3. Press `<Enter>`.

**Output**
All "foo" become "bar" in the line.

### Saving and Quitting
To persist changes: `:w` (write), `:q` (quit), `:wq` (write and quit), `:q!` (quit without save). `ZZ` saves and quits in Normal.

**Key Points**
- `:w filename`: Save as.
- `:q!`: Discard changes.
- Autosave may be enabled via plugins.
- Session management with `:mksession` if needed.
- File permissions or locks may affect saving.

**Example**
To save and exit:
1. Press `:`.
2. Type `wq`.
3. Press `<Enter>`.

**Conclusion**
These operations form the core of text editing, enabling efficient manipulation. Mastery comes from practice, and LazyVim's plugins may enhance them without altering basics.

**Next Steps**
Explore advanced topics like macros (`q` to record), registers (`:registers`), or plugin-specific features via `:help`. Customize keymaps in your config.lua for personalization.

---

