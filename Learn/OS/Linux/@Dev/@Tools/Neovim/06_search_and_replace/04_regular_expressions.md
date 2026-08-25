## Regular Expressions


### Introduction

Regular expressions, often abbreviated as regex, serve as a powerful mechanism for pattern matching and text manipulation within Neovim. They are integral to commands like search (`/`), substitute (`:s`), and global (`:g`), allowing users to identify, replace, or operate on text that matches specific patterns. Neovim inherits its regex engine from Vim, which supports a unique flavor distinct from standards like PCRE or POSIX. This flavor emphasizes efficiency for text editing tasks but may behave differently from regex in programming languages like Python or JavaScript. Behavior can vary based on Neovim version, configuration, and enabled options such as 'magic'.

In the context of LazyVim, a Neovim distribution that bundles plugins and configurations, the core regex functionality remains unchanged from stock Neovim. However, plugins like flash.nvim (included in LazyVim) enhance search interfaces while still relying on Neovim's underlying regex patterns.

### Magic Modes

Neovim's regex interpretation depends on the "magic" level, which controls how metacharacters (like `*`, `+`, or `.`) are treated—either as literal characters or as special operators. This flexibility allows users to adjust the regex dialect for different needs.

There are four magic modes:

- **Magic (\m)**: The default mode in most commands. Metacharacters like `.`, `*`, and `[` are special, but others like `(` and `{` require a backslash to activate (e.g., `\(group\)`).
- **Nomagic (\M)**: Metacharacters must be escaped with a backslash to be special (e.g., `\.` for any character, but `.` matches a literal dot). Useful for patterns with many literals.
- **Very Magic (\v)**: All non-alphanumeric characters are treated as special without escaping (e.g., `(group)` instead of `\(group\)`). This mode aligns more closely with modern regex flavors and is often recommended for complex patterns.
- **Very Nomagic (\V)**: Similar to nomagic but even stricter; only `\` and the delimiter are special. Ideal for literal string matching with minimal escaping.

To specify a mode, prefix the pattern with the corresponding escape sequence (e.g., `/\vpattern` for very magic in search). Note that the default mode can be influenced by the 'magic' option, though it's typically enabled.

**Key Points**
- Switching modes can simplify patterns; for instance, very magic reduces backslash clutter.
- Behavior may vary if 'magic' is toggled via `:set nomagic`.

**Example**
To search for a phone number like (123) 456-7890 using very magic:
```
/\v\(\d{3}\) \d{3}-\d{4}
```
This matches exactly without extra escapes for parentheses or braces.

### Atoms and Quantifiers

Atoms are the basic building blocks of regex patterns, representing single characters or groups. Quantifiers specify how many times an atom should match.

Common atoms include:
- Literal characters (e.g., `a` matches "a").
- `.` (matches any single character except newline, unless 's' flag is used in substitute).
- `\d` (digit), `\w` (word character: alphanumeric plus underscore), `\s` (whitespace).

Quantifiers follow atoms:
- `*` (zero or more, greedy).
- `\+` (one or more, greedy; note the escape in magic mode).
- `\?` (zero or one, greedy).
- `\{n,m\}` (between n and m times; use `\v` for `{n,m}`).

Greedy quantifiers match as much as possible; to make them non-greedy, append `\=` (e.g., `.*?` becomes `.\{-}` in Neovim syntax).

**Example**
To match HTML tags (very magic mode):
```
/\v\<[^>]+>
```
Here, `\<` matches a literal `<`, `[^>]+` matches one or more non-`>` characters, and `>` matches the closing angle bracket.

**Output**
If the buffer contains `<div class="example">Text</div>`, this pattern highlights the opening and closing tags.

### Character Classes

Character classes allow matching any one of a set of characters. Enclose them in `[` and `]`.

- `[abc]` matches a, b, or c.
- `[^abc]` matches anything except a, b, or c.
- Ranges like `[a-z]` (lowercase letters) or `[0-9A-F]` (hex digits).
- Predefined classes: `\d` (digits), `\D` (non-digits), `\s` (space), `\S` (non-space), `\w` (word), `\W` (non-word).

In very magic mode, these are straightforward; in magic mode, some may need escaping.

**Key Points**
- Classes can include metacharacters literally if inside (e.g., `[.*]` matches dot or asterisk).
- Neovim supports multibyte characters, but matching may depend on 'encoding'.

**Example**
To find words starting with vowels:
```
/\v<[aeiou]\w*
```
This uses `\<` for word start (note: `\<` is a zero-width assertion for word boundary).

### Anchors and Boundaries

Anchors assert positions without consuming characters:
- `^` (start of line).
- `$` (end of line).
- `\<` (start of word).
- `\>` (end of word).
- `\b` (word boundary; equivalent to `\<` or `\>` depending on context) [Unverified: Neovim may not fully support `\b` in all modes; test in your setup].
- `\zs` (start of match), `\ze` (end of match) for capturing subsets.

These are crucial for precise matching.

**Example**
To substitute only at line start:
```
:%s/^Error/Warning/g
```
This replaces "Error" with "Warning" if it begins a line.

### Groups and Backreferences

Groups capture parts of a match for reference or replacement:
- `\(group\)` (in magic mode) or `(group)` (very magic).
- Up to 9 groups, referenced as `\1` to `\9` in patterns or replacements.

Alternation uses `\|` (or `|` in very magic).

**Example**
To swap first and last names:
```
:s/\v(\w+) (\w+)/\2 \1/
```
For "John Doe", this becomes "Doe John".

**Output**
Original: John Doe  
After: Doe John

### Searching with Regex

The forward slash `/` initiates a search with regex. Press `n` to go next, `N` to previous. Use `?` for backward search.

Options like 'hlsearch' highlight matches, 'incsearch' shows incrementally. In LazyVim, flash.nvim provides enhanced search with labels for quick jumps.

**Key Points**
- Searches wrap around the buffer unless 'wrapscan' is off.
- Behavior may vary with 'ignorecase' or 'smartcase'.

**Example**
Search for email addresses:
```
/\v[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}
```

### Substituting with Regex

The `:s` command replaces matches: `:s/pattern/replacement/flags`.

Flags include `g` (global in line), `c` (confirm), `i` (ignore case).

Range like `:%s` for whole buffer.

**Example**
Replace all occurrences of "colour" with "color":
```
:%s/\vcolou?r/color/g
```
The `?` makes "u" optional.

### Global and Visual Commands

`:g/pattern/command` executes on matching lines.
`:v/pattern/command` on non-matching.

**Example**
Delete lines containing "TODO":
```
:g/TODO/d
```

### Regex in Vimscript and Lua

In Vimscript (e.g., mappings), use `matchstr()` or `substitute()` functions.

In Lua (Neovim's API), `vim.fn.match()` or `vim.regex()` for compiled patterns.

**Example** (Lua snippet):
```lua
local re = vim.regex([[\v\d{4}]])
print(re:match_str("Year: 2023"))  -- Returns 4 (length of match)
```

### Advanced Topics

- Lookaround: Neovim supports positive lookahead `\@=` (e.g., `foo\(bar\)\@=` matches "foo" followed by "bar" without including "bar").
- Negative lookahead `\@!`.
- Multiline matching with `\_.` (any char including newline).
- Collection items like `[=a=]` for equivalence classes (locale-dependent).
- In LazyVim, plugins like nvim-surround may interact with regex for operations.

[Inference: Advanced features like lookbehind `\@<=` may have length limits; check `:help /\%@` for details.]

### Common Pitfalls

- Forgetting magic mode, leading to unexpected literal matches.
- Greedy quantifiers overmatching; use non-greedy `\{-}`.
- Encoding issues with non-ASCII; set 'fileencoding' appropriately.
- Behavior may vary across Neovim versions or with plugins overriding defaults.

**Conclusion**
Regular expressions in Neovim offer robust tools for text processing, adaptable through magic modes and integrated into core commands. Mastering them can enhance editing efficiency, though testing patterns in your specific setup is advisable due to potential variations.

**Next Steps**
- Experiment with `:help pattern` for exhaustive documentation.
- Practice in a scratch buffer using `/` and `:s`.
- Explore LazyVim's search plugins for regex enhancements.
- For complex tasks, consider Lua integrations for scripted regex operations.

---

