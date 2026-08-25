## Global Commands


### Overview of the :global Command

The `:global` command, often abbreviated as `:g`, is a built-in Ex command in Neovim that allows users to execute operations on all lines in a buffer (or specified range) that match a given pattern. It searches for matching lines and applies a sub-command to them. This is particularly useful for batch editing, such as deleting, substituting, or moving text across multiple lines. In LazyVim, which builds on Neovim's core features with plugin enhancements, the `:global` command remains unchanged in its core behavior but can interact with plugins like mini.nvim or which-key for better usability or keymapping.

Key aspects include:
- Pattern matching uses Vim's regular expression syntax.
- It can be combined with other Ex commands like `:delete`, `:substitute`, or even custom user-defined commands.
- Behavior may vary based on buffer settings, such as 'magic' option for regex interpretation, or if plugins override default search behaviors.

**Key Points**
- Syntax: `:[range]g[lobal][!]/pattern/command`
- The `!` inverts the match (operate on non-matching lines).
- Without a range, it applies to the entire buffer.
- Nested commands are possible, but complex nesting may lead to unexpected results depending on the Neovim version and configuration.

### Basic Usage

To use `:global`, specify a pattern and a command to execute on matching lines. For instance, to delete all lines containing "error":

```
:g/error/d
```

This scans the buffer and deletes matching lines. Note that undo history records this as a single operation, which may affect recovery in case of errors.

For inverting the match (delete lines not containing "error"):

```
:g!/error/d
```

Or equivalently:

```
:v/error/d
```

Where `:v` is shorthand for `:global!`.

In LazyVim, if you have plugins like flash.nvim enabled, search highlighting might persist after execution, which can be cleared with `:nohlsearch`.

**Example**
Suppose you have a buffer with the following content:

```
Line 1: info
Line 2: error
Line 3: warning
Line 4: error
```

Executing `:g/error/d` results in:

```
Line 1: info
Line 3: warning
```

**Output**
The buffer is modified in place; no separate output is generated unless the sub-command produces one (e.g., `:g/pattern/p` prints matching lines).

### Advanced Pattern Matching

Patterns in `:global` leverage Neovim's regex engine. For example:
- Use `\<word\>` for word boundaries.
- Character classes like `[a-z]` or `\d` for digits.
- Quantifiers such as `*`, `\+`, or `\{n,m\}`.

To yank all lines starting with a digit into register a:

```
:g/^\d/y A
```

This appends matching lines to register a. Behavior may differ if 'clipboard' is set to interact with system clipboard.

For multi-line patterns, use `\_.` to match any character including newlines, but `:global` operates line-wise by default.

**Example**
Buffer content:

```
apple
banana
apple pie
cherry
```

Command: `:g/apple/m$`

This moves all lines containing "apple" to the end of the buffer, resulting in:

```
banana
cherry
apple
apple pie
```

### Combining with Other Commands

`:global` can nest other Ex commands. For substitution on matching lines:

```
:g/pattern/s/old/new/g
```

This substitutes only on lines matching the outer pattern.

To execute a normal-mode command on matching lines, use `:normal`:

```
:g/pattern/normal dw
```

This deletes the first word on each matching line. Note that `:normal` executes in normal mode, so cursor position matters—`:global` positions the cursor at the start of each matching line before execution.

In LazyVim, if you have lsp or treesitter plugins, these might influence pattern matching if semantic highlighting is active, though this is not directly tied to `:global`.

**Key Points**
- Avoid recursive nesting without care, as it may cause stack overflows in extreme cases.
- Use `:{range}g` to limit scope, e.g., `10,20g/pattern/d` for lines 10-20.

### Ranges and Visual Selections

`:global` can operate on visual selections by using `:'<,'>g`, which applies to the selected lines. In visual mode, press `:` to enter this.

For example, select lines visually, then `:g/pattern/d` deletes matching lines within the selection.

**Example**
Visual selection on lines 2-4:

```
1: foo
2: bar error
3: baz
4: bar warning
5: qux
```

Command: `:'<,'>g/bar/d`

Result:

```
1: foo
3: baz
5: qux
```

### Inverting and Variants

The `:vglobal` or `:v` command is the inverse, applying to non-matching lines.

Additionally, `:g!` is synonymous with `:v`.

For counting matches without action:

```
:g/pattern/#
```

This lists matching lines with numbers.

**Key Points**
- These variants do not modify the buffer unless the sub-command does.
- Performance may degrade on very large buffers; consider using external tools like `sed` for massive files [Inference: Based on Neovim's internal processing limits].

### Integration with LazyVim Features

In LazyVim, `:global` can be enhanced via keymaps. For instance, LazyVim's default configuration includes leader key mappings for search/replace, but `:global` itself isn't remapped. You might configure custom keymaps in `lua/config/keymaps.lua` to invoke common `:global` patterns.

If using plugins like telescope.nvim, you can search buffers and then apply `:global` on results, though this requires manual integration.

Plugins like substitute.nvim in LazyVim provide alternatives for multi-file operations, but `:global` remains buffer-specific.

**Example**
To set a keymap for deleting blank lines:

In `lua/config/keymaps.lua`:

```lua
vim.keymap.set("n", "<leader>db", ":g/^$/d<CR>", { desc = "Delete blank lines" })
```

This uses `:global` under the hood.

### Common Pitfalls and Troubleshooting

- Patterns are case-sensitive unless 'ignorecase' is set.
- Escaping special characters: Use `\` for literals like `/` in patterns.
- If a sub-command fails on a line, `:global` continues to the next, but errors may appear in the message area.
- In LazyVim, if undo-tree or other history plugins are active, large `:global` operations might consume significant memory.
- Behavior may vary across Neovim versions; test in your environment.

For debugging, use `:verbose g/pattern/command` to see where the command is defined if overridden.

[Speculation: Future Neovim updates might optimize `:global` for parallel processing, but this is not current.]

### Alternatives and Extensions

- For multi-buffer operations, use `:bufdo g/pattern/command`, but this applies to all buffers.
- Plugins like vim-abolish or nvim-spectre offer advanced search/replace UIs that can mimic `:global`.
- For scripting, Lua APIs like `vim.fn.search` can replicate `:global` logic in custom functions.

In LazyVim, consider using the built-in quickfix list: `:g/pattern/#` populates quickfix for navigation.

**Next Steps**
- Experiment with simple patterns in a scratch buffer.
- Explore LazyVim's plugin docs for search enhancements.
- Customize keymaps to streamline common `:global` uses.

---

