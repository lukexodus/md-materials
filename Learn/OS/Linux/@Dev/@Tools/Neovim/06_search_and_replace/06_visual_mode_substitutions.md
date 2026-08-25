## Visual Mode Substitutions


### Introduction
Visual mode in Neovim allows users to select portions of text and apply operations, including substitutions, to those selections. Substitutions refer to search-and-replace actions, typically using the `:s` (substitute) command. In the context of LazyVim, which is a Neovim configuration framework built on lazy.nvim, core Neovim behaviors apply, but certain keymaps and plugins may influence how substitutions are performed. This guide covers the fundamentals, techniques, and considerations for substitutions in visual mode, drawing from Neovim's official documentation and community practices.

### Types of Visual Modes
Neovim supports three visual mode variants, each affecting how text is selected and how substitutions behave:
- **Character-wise** (started with `v`): Selects individual characters.
- **Line-wise** (started with `V`): Selects entire lines.
- **Block-wise** (started with `<C-v>`): Selects rectangular blocks, useful for column-based edits.

**Key Points**
- Visual selections are highlighted based on the `'hl-Visual'` highlight group.
- The `'selection'` option (default: "inclusive") determines if the ending character is included in operations.
- Behavior may vary with options like `'virtualedit'` (e.g., set to "block" in LazyVim to allow cursor movement beyond text in block mode).

### Entering and Exiting Visual Mode
To start visual mode:
- Press `v`, `V`, or `<C-v>` in normal mode.
- Use motions (e.g., `vj` to select down a line) to extend the selection.
- Prefix with a count (e.g., `3v` ) to select based on previous or default amounts.

To adjust or exit:
- `o`: Swap cursor to the opposite end of the selection.
- `gv`: Reselect the previous visual area in the same mode.
- `<Esc>` or `<C-c>`: Exit visual mode.

In LazyVim, mouse support may be enabled if `'mouse'` includes 'v', allowing drag selections.

### Performing Basic Substitutions in Visual Mode
Once text is selected:
1. Press `:` to enter command-line mode. Neovim automatically inserts `:'<,'>` , indicating the command applies to the visual range (marks `'<` and `'>` denote start and end).
2. Enter the substitute command: `s/pattern/replacement/flags`.
   - `pattern`: The text to search for (supports regex).
   - `replacement`: The text to insert.
   - `flags`: Common ones include `g` (global, all matches per line), `c` (confirm each), `i` (ignore case).

Note: The `:` command in visual mode typically operates on whole lines within the selection, even in character-wise or block-wise modes. Partial-line substitutions require additional techniques (see below).

**Example**
Select "hello world" in character-wise mode, then:
```
:'<,'>s/hello/goodbye/g
```
This replaces "hello" with "goodbye" across the selected lines.

**Output**
Original:
```
hello world
another hello
```
After:
```
goodbye world
another goodbye
```

Behavior may vary if the selection spans partial lines or with certain plugins.

### Restricting Substitutions to the Visual Area
Standard `:s` affects entire lines. To limit to the exact visual selection:
- Use `\%V` in the pattern: This anchors the match to the visual area only.
- Example: `:'<,'>s/\%Vold/new/g` replaces "old" with "new" only within the selected text.

This is particularly useful in character-wise mode to avoid changing unselected parts of lines.

**Key Points**
- `\%V` works in patterns for `:s`, but not all commands respect it.
- For block-wise, substitutions may require refined patterns like `\zs` (start match) or `\ze` (end match) to target columns.
- [Inference]: In complex regex, test patterns iteratively, as behavior can depend on Neovim version and buffer settings.

**Example**
Visual selection: Only "foo" in "foo bar baz".
```
:'<,'>s/\%Vfoo/FOO/g
```
**Output**
```
FOO bar baz
```

### Block-Wise Substitutions
In block mode (`<C-v>`), selections form rectangles. Substitutions behave differently:
- Operators like `c` (change) or `s` (substitute) replace the entire block with the same input text across lines.
- `r{char}`: Replaces every character in the block with `{char}`.
- `I` or `A`: Insert/append text to each line in the block (Neovim pads shorter lines with spaces if needed).
- For `:s`, use column-specific regex (e.g., `ba\zer` to match "baz" starting after "ba").

Note: Not all operators restrict to the block; some fall back to line-wise.

**Example**
Block selection over "1" in:
```
a1b
c1d
e1f
```
Then `:'<,'>s/\%V1/2/g`
**Output**
```
a2b
c2d
e2f
```

**Key Points**
- Use plugins like vis.vim (not included in LazyVim) for true block-restricted `:s` via `B s/...`.
- In LazyVim, block mode is enhanced by options like `virtualedit = "block"`.

### Advanced Substitution Techniques
- **Repeating**: Use `.` to repeat the last substitution on a similar-sized selection.
- **Mappings**: Create custom mappings for chained substitutions, e.g., in visual mode:
  ```
  vim.api.nvim_set_keymap("v", "<Leader>q", ":<C-u>'<,'>s/^/> /<CR>:'<,'>s/$/ /<CR>", { noremap = true })
  ```
  This quotes the selection, but note the `<C-u>` to clear auto-inserted range.
- **Search and Replace Workflow**: Visual select, `*` to search, then `cgn` to change next match (repeat with `.`).
- **External Filters**: Use `!` operator in visual mode to pipe selection through commands like `sed`.
- [Unverified]: Community plugins like vim-subversive orabolish.vim can enhance substitutions, but check LazyVim compatibility.

Behavior may vary with Neovim updates or buffer filetypes.

### LazyVim-Specific Considerations
LazyVim modifies some defaults:
- Keymap `<leader>sr`: Opens a search-and-replace interface (in normal and visual modes), powered by plugins like nvim-spectre or similar.
- `s` and `S` are remapped (e.g., to leap.nvim for motion). Use `r` for single-character replace, `c` for change, or `cc` for line substitute.
- Plugins: LazyVim includes mini.nvim (for operators like multiply/replace) and flash.nvim, which may alter visual workflows. No direct substitution plugins noted, but editor extras can be enabled.
- Options: `wildmode` and others influence command-line completion during `:s`.

**Key Points**
- In visual mode, `<leader>sr` prompts for pattern/replacement, applying to the selection.
- LazyVim's keymaps.lua auto-loads; customize via `~/.config/nvim/lua/config/keymaps.lua`.

### Practical Examples in LazyVim
**Example 1: Simple Replace**
1. Enter visual mode (`v`), select text.
2. Press `<leader>sr`, input pattern "error", replacement "fixed".
**Output**
Applies to selection; confirm if `c` flag used.

**Example 2: Block Replace with Regex**
Block-select columns, then `:'<,'>s/\%V[0-9]/X/g` to replace digits with "X".

**Example 3: Chained Substitutions**
Mapping example for quoting:
- Select lines, run custom `<Leader>q` as above.
**Output**
Transforms selection into quoted block.

### Common Pitfalls and Tips
- Whole-line behavior: Always test `:s` on small selections.
- Encoding/regex issues: Use `\c` for case-insensitive if needed.
- Performance: Large selections may slow down; use narrowed ranges.
- [Speculation]: In future Neovim versions, visual restrictions might improve without `\%V`.

### Conclusion
Visual mode substitutions in Neovim (and LazyVim) provide powerful text manipulation, from basic replaces to column-specific edits. Start with core commands and explore LazyVim's keymaps for efficiency. Practice in a scratch buffer to observe behaviors, as they can depend on configuration.

### Next Steps
- Read Neovim help: `:help visual.txt` and `:help substitute`.
- Customize LazyVim: Add plugins like svermeulen/vim-subversive for advanced substitutes.
- Experiment: Try combining with macros (`q`) for repeated visual edits.

---

