## Operators


### Introduction to Operators
Operators in Neovim are commands that perform actions on text, typically combined with motions or text objects to specify the scope. They enable efficient editing by applying operations like deletion or copying to targeted regions. In LazyVim, these are core Neovim features, potentially enhanced by plugins like vim-surround or treesitter for better text object handling. Operators work primarily in Normal mode and can be repeated or modified with counts.

**Key Points**
- Operators include `d` (delete), `c` (change), `y` (yank/copy), `p` (paste), and others like `g~` (toggle case), `gu` (lowercase), `gU` (uppercase), `>` (indent), `<` (unindent), `=` (autoformat).
- They pair with motions (e.g., `w` for word) or text objects (e.g., `iw` for inner word).
- A count before the operator multiplies the action (e.g., `3dw` deletes three words).
- Most operators place affected text into registers for later use.
- Behavior may vary based on settings like `virtualedit` or plugins that remap keys.

### How Operators Function
An operator is entered in Normal mode, putting Neovim into "operator-pending" mode, where it awaits a motion or text object to define the range. For example, `d` followed by `w` deletes from the cursor to the end of the word. Some operators, like `p`, do not require a following motion as they act on registers directly. In Visual mode, operators apply to the selected text.

**Key Points**
- Operator-pending mode: Indicated by the cursor or status line; timeout via `timeoutlen` option.
- Self-operators: Doubling like `dd` (delete line) or `yy` (yank line) acts on the current line.
- Line-wise vs. character-wise: Depends on the motion (e.g., `d$` is character-wise, `dd` is line-wise).
- Inclusive/exclusive: Most motions are exclusive (e.g., `dw` excludes the next word's start), but this can be adjusted with `set selection=inclusive`.
- In LazyVim, which-key plugin may show pending operator hints.

**Example**
To delete to the end of the line:
1. In Normal mode, press `d`.
2. Then press `$`.

**Output**
Removes text from cursor to line end; deleted content goes to the default register.

### Delete Operator (d)
The `d` operator removes text and places it into a register. It combines with any motion or text object. For instance, `di"` deletes inside quotes. Deleted text can be pasted elsewhere.

**Key Points**
- Common uses: `dw` (delete word), `d$` (to line end), `dd` (whole line), `dG` (to file end).
- With count: `2dd` deletes two lines.
- Registers: Defaults to `"`, but specify like `"adw` for register a.
- In Visual mode: Select text, then `d` to delete.
- Does not affect the undo history separately from the operation; part of the change.
- [Inference]: In LazyVim with undo plugins, may branch undo trees.

**Example**
To delete a paragraph:
1. Position cursor in paragraph.
2. Press `dap` (if `ap` text object is available via plugins; otherwise `d}`).

**Output**
Removes the paragraph; cursor moves to the start of the deleted area.

### Change Operator (c)
The `c` operator deletes text like `d` but then enters Insert mode for replacement. Useful for modifying content inline.

**Key Points**
- Examples: `cw` (change word), `cc` (change line), `c$` (to line end).
- Deleted text goes to register.
- Exits Insert mode with `<Esc>`.
- With text objects: `ci(` changes inside parentheses.
- Line-wise changes preserve indentation in some cases.
- Behavior may differ if autoindent or plugins like auto-pairs are active.

**Example**
To change "foo" to "bar":
1. Cursor on "f".
2. Press `cw`.
3. Type "bar".
4. Press `<Esc>`.

**Output**
Replaces "foo" with "bar".

### Yank Operator (y)
The `y` operator copies text to a register without deleting it. It mirrors `d` in scoping.

**Key Points**
- Uses: `yw` (yank word), `yy` (yank line), `yG` (to file end).
- Registers: `"*yy` for primary clipboard, `"+yy` for system clipboard (if supported).
- Does not modify the buffer.
- In Visual mode: `y` yanks selection.
- Yank type (line/character) affects later pastes.

**Example**
To copy a word:
1. Cursor on word.
2. Press `yiw` (yank inner word).

### Paste Operators (p and P)
`p` and `P` insert text from a register. `p` pastes after the cursor (or below for lines), `P` before (or above).

**Key Points**
- From default register: `p` or `P`.
- Specified: `"+p` from system clipboard.
- Adjusts for line-wise/character-wise.
- With count: `3p` pastes three times.
- In Insert mode: `<C-r>"` pastes from default.
- May trigger auto-formatting if plugins are enabled.
- Behavior may vary with `paste` option or clipboard settings.

**Example**
After yanking a line with `yy`:
1. Move to target location.
2. Press `p`.

**Output**
Inserts the yanked line below the current one.

### Indent Operators (> and <)
These shift text right (`>`) or left (`<`) by `shiftwidth`. Combine with motions.

**Key Points**
- `>>` indents current line, `>G` to file end.
- In Visual mode: `>` indents selection.
- Repeat with `.` (dot command).
- Affected by `shiftwidth` and `expandtab` settings.

**Example**
To indent a block:
1. Visual line select (`V`).
2. Press `>`.

**Output**
Shifts selection right.

### Case Change Operators (g~, gu, gU)
These toggle (`g~`), lowercase (`gu`), or uppercase (`gU`) text.

**Key Points**
- `g~w` toggles word case.
- `guu` lowercases line.
- Works with motions/text objects.
- Unicode-aware in Neovim.

**Example**
To uppercase a word:
1. Press `gUiw`.

**Output**
Converts word to uppercase.

### Format Operator (=)
Auto-indents or formats text based on `equalprg` or filetype settings.

**Key Points**
- `==` formats current line.
- `=G` to file end.
- In Visual: `=` formats selection.
- Depends on `formatexpr` or external tools if set.
- [Unverified]: In LazyVim, may integrate with conform.nvim for advanced formatting.

**Example**
To format a line:
1. Press `==`.

**Output**
Adjusts indentation.

### Text Objects and Motions Integration
Operators shine when combined with text objects (e.g., `iw` inner word, `a"` around quotes) or motions (e.g., `f;` to next semicolon). LazyVim may extend these via treesitter.

**Key Points**
- Inner (i) vs. around (a): `diw` deletes word excluding surroundings, `daw` includes spaces.
- Common objects: w (word), s (sentence), p (paragraph), [, {, (, ", ', t (tag).
- Motions: f{char} (find), t{char} (till), /pattern (search).
- Custom objects possible via plugins.

**Example**
To yank inside brackets:
1. Press `yi[`.

### Registers with Operators
Operators interact with registers for storing text. Default is `"`, but 26 named (a-z), numbered (0-9), and special (*, +, .).

**Key Points**
- Specify: `"ayw` yanks to a.
- View: `:registers`.
- Black hole: `"_d` deletes without saving.
- Append: `"Ayw` appends to A.

**Example**
To delete to register b:
1. Press `"bdw`.

### Repeating Operators
Use `.` to repeat last operator-motion combo. Counts and registers persist.

**Key Points**
- Repeats entire change, including Insert mode for `c`.
- Limited by `repeat` plugin if installed.

### Advanced Usage
Operators in macros (`q`), with plugins (e.g., vim-operator-user for custom), or Ex mode (`:norm`).

**Key Points**
- Macro: Record with `qa`, use operators, `q` to stop, `@a` to play.
- Visual block: `<C-v>`, select, then operator.
- Behavior may vary across filetypes or with mappings.

**Conclusion**
Operators provide powerful, composable ways to manipulate text, forming the backbone of efficient editing. They integrate seamlessly with other features, allowing complex edits in few keystrokes.

**Next Steps**
Practice combining with motions via `:Tutor` or vimtutor. Explore plugins like vim-textobj-user for custom objects, or check `:help operator` for details. Customize via LazyVim's keymaps.

---

