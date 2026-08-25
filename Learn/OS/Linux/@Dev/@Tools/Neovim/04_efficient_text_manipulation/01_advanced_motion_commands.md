## Advanced Motion Commands


### Overview of Motion Commands
Motion commands in Neovim allow navigation through text buffers with precision and efficiency. They move the cursor to specific positions and can be combined with operators (like `d` for delete or `y` for yank) to perform actions over ranges. In LazyVim, these core motions are preserved, but plugins may extend them with additional mappings or visual aids. Advanced motions go beyond basic `h/j/k/l`, enabling jumps across words, lines, paragraphs, or even based on searches and patterns. Mastering them reduces keystrokes and enhances productivity, especially in large files.

**Key Points**
- Motions are used in Normal and Visual modes; in Operator-pending mode, they define the text object for the operator.
- Counts can prefix motions (e.g., `3w` moves three words forward).
- Some motions are inclusive (include endpoint) or exclusive; this affects operations like deletion.
- Behavior may vary with settings like `virtualedit` or plugins; test in your setup.

### Word and WORD Motions
Word motions navigate by word boundaries, where words are sequences of non-blank characters. WORD motions treat punctuation as part of boundaries differently.

#### Basic Word Motions
- `w`: Move to start of next word.
- `b`: Move to start of previous word.
- `e`: Move to end of current/next word.
- `ge`: Move to end of previous word.

#### WORD Variants
- `W`, `B`, `E`, `gE`: Same as above but treat sequences including punctuation as single units (e.g., "hello-world" as one WORD).

#### Practical Usage
Useful for editing code or prose where quick word skips are needed.

**Example**
Text: "The quick brown fox jumps."
- Cursor at start: `3w` moves to "b" in "brown".
- Then `e` to end of "brown".

**Output**
Cursor positioned at 'n' in "brown".

### Line and Paragraph Motions
These handle vertical navigation and larger text blocks.

#### Line Motions
- `0`: Move to start of line (first column).
- `^`: Move to first non-blank character of line.
- `$`: Move to end of line.
- `g_`: Move to last non-blank character of line.
- `+` or `Enter`: Next line, same column (or first non-blank with `sol` option).
- `-`: Previous line, same column.

#### Paragraph and Sentence Motions
- `}`: Next paragraph (blank line separated).
- `{`: Previous paragraph.
- `)`: Next sentence (period/exclamation/question followed by space).
- `(`: Previous sentence.

#### Practical Usage
Ideal for navigating structured text like markdown or code blocks.

**Example**
In a buffer with paragraphs separated by blank lines:
- From top of first paragraph: `}` jumps to start of next.

**Output**
Cursor at beginning of second paragraph.

[Inference: In LazyVim with treesitter enabled, paragraph detection might be more semantic for certain filetypes.]

### Search-Based Motions
Motions using searches allow jumping to patterns.

#### Character Searches
- `f{char}`: Forward to next {char} on line.
- `F{char}`: Backward to previous {char}.
- `t{char}`: Forward to before next {char}.
- `T{char}`: Backward to after previous {char}.
- `;`: Repeat last f/F/t/T forward.
- `,`: Repeat backward.

#### Line Searches
- `/pattern`: Forward search to pattern, then `n`/`N` for next/prev.
- `?pattern`: Backward search.

#### Practical Usage
Efficient for in-line edits or finding specific tokens.

**Example**
Line: "Error: undefined variable 'x'."
- `f'` moves to first quote.
- `;` to next quote.

**Output**
Cursor on second quote.

### Jump Motions
These facilitate long-distance navigation.

#### Screen and File Jumps
- `H`: Top of screen (High).
- `M`: Middle of screen.
- `L`: Bottom of screen (Low).
- `gg`: First line of file.
- `G`: Last line of file (or line number with count, e.g., `42G`).
- `Ctrl-d`: Down half screen.
- `Ctrl-u`: Up half screen.
- `Ctrl-f`: Forward full screen.
- `Ctrl-b`: Backward full screen.

#### Mark Jumps
- `` `{mark}``: Jump to mark (set with `m{letter}`).
- `` `` ``: Jump to last position before jump.
- `''`: Jump to line of last jump.

#### Practical Usage
For quick file traversal or returning to positions.

**Example**
- Set mark: `ma` at cursor.
- Move elsewhere, then `` `a`` to return.

**Output**
Cursor back at marked position.

### Text Object Motions
Text objects select structural units, often used with operators.

#### Inner and Around
- `iw`: Inner word.
- `aw`: A word (includes surrounding whitespace).
- `i"`: Inner quotes.
- `a"`: Around quotes (includes quotes).
- Similar for `()`, `[]`, `{}`, `<>`, `` ` ``, `'`.
- `ip`: Inner paragraph.
- `ap`: A paragraph.

#### Practical Usage
Powerful for changes like `ciw` (change inner word).

**Example**
Text: "(hello world)"
- Cursor inside: `ci(` replaces content inside parentheses, enters Insert.

**Output**
Parentheses remain, new text inserted.

[Speculation: In LazyVim with textobjects plugin, additional objects like functions or classes may be available via treesitter.]

### Window and Buffer Motions
These navigate across windows or buffers.

#### Window Navigation
- `Ctrl-w h/j/k/l`: Move to left/down/up/right window.
- `Ctrl-w w`: Cycle windows.
- `Ctrl-w t`: Top-left window.
- `Ctrl-w b`: Bottom-right window.

#### Buffer Switching
- `:bnext` or `:bprev` (often mapped in LazyVim to `<leader>bn`, etc.).
- But motions like `]b`/`[b` with plugins.

#### Practical Usage
For multi-window workflows.

**Example**
Split window: `:vsplit`, then `Ctrl-w l` to right window.

**Output**
Cursor in new window.

### Advanced Combinations and Extensions
- Motions with operators: `d$` deletes to end of line.
- Visual mode: Start with `v`, then motion to select.
- In LazyVim, plugins like leap.nvim or flash.nvim add jump enhancements (e.g., `s` for two-char search).
- Counts and repeats: `3}` skips three paragraphs; `.` repeats last change.

**Key Points**
- Combine for efficiency: e.g., `d2w` deletes two words.
- Customize via keymaps in LazyVim config.
- Motions respect wrap settings (`wrap` option).

### Common Pitfalls and Tips
- Off-screen jumps may require `zz` to center cursor.
- In large files, use `%` for matching brackets.
- Check `:help motion` for exhaustive list.
- Behavior can differ in diff mode or with folds.

**Conclusion**
Advanced motion commands transform Neovim navigation from basic to highly efficient, allowing precise control over text. In LazyVim, they integrate seamlessly with plugins for even more power.

**Next Steps**
- Practice in a scratch buffer.
- Explore LazyVim's default keymaps with `:LazyVim`.
- Add custom motions via plugins like vim-easymotion.

---

