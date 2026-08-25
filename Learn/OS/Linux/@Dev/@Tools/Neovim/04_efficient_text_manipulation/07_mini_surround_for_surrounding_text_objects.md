## Mini.surround for Surrounding Text Objects


### Introduction

mini.surround is a module from the mini.nvim suite that facilitates operations on surrounding text, such as parentheses, quotes, brackets, tags, and other delimiters. It enables adding, deleting, replacing, finding, and highlighting these surroundings around text objects like words, paragraphs, or selections. In the context of LazyVim, mini.surround is available as an optional extra (enabled via `:LazyExtras` or by requiring "lazyvim.plugins.extras.coding.mini-surround" in your configuration). When enabled, it overrides the default mini.surround keybindings with a `gs` prefix to avoid conflicts with other mappings. Note that behavior may vary based on your Neovim version, additional plugins, or custom overrides.

This module treats surroundings as manipulable elements tied to text objects, allowing precise edits. For instance, it can surround a word (`iw` text object) with quotes or delete brackets around a function call. It integrates with Neovim's operator-pending mode and supports dot-repeat for actions.

### Features

mini.surround provides a range of actions focused on surroundings, emphasizing speed and flexibility. Key features include:

**Key Points**
- Supports common surroundings like balanced brackets (`()`, `[]`, `{}`), quotes, HTML/XML tags, function calls, and user-defined ones.
- Actions are dot-repeatable and respect `v:count` for repetition.
- Search methods for finding surroundings: configurable to cover the current position, next/previous occurrences, or nearest.
- Interactive mode for custom surroundings via `?`.
- Highlighting temporarily shows matched surroundings.
- Respects visual selections but does not adapt to linewise/blockwise by default (configurable).
- No built-in text objects; instead, it uses Neovim's motions and text objects (e.g., `iw` for inner word) in combination with its operators.

### Keybindings

When enabled in LazyVim, the following keybindings are set (in normal mode unless specified; also applicable in visual mode for some). These are remapped from mini.surround's defaults to start with `gs` for compatibility.

- `gsa`: Add surrounding (operator-pending; awaits motion or text object, then surrounding input) (`n`, `v`)
- `gsd`: Delete surrounding (operator-pending; awaits surrounding input) (`n`, `v`)
- `gsr`: Replace surrounding (operator-pending; awaits old then new surrounding input) (`n`, `v`)
- `gsf`: Find surrounding to the right (operator-pending; awaits surrounding input) (`n`)
- `gsF`: Find surrounding to the left (operator-pending; awaits surrounding input) (`n`)
- `gsh`: Highlight surrounding (operator-pending; awaits surrounding input) (`n`)
- `gsn`: Update `n_lines` (prompts for new line search limit) (`n`)

Suffixes for advanced searching (appended after the surrounding specifier):
- `n`: Next occurrence
- `l`: Last (previous) occurrence

Note: Without the LazyVim extra, mini.surround defaults to `sa`, `sd`, etc., without the `g` prefix. Behavior may vary if which-key.nvim is used, as it may display popups for `gs` group labeled "surround".

### Usage

To use mini.surround, enter the keybinding followed by a motion or text object (for add/delete/replace), and then specify the surrounding character. Surroundings are identified by single characters:

- Brackets: `(` for `()`, `[` for `[]`, `{` for `{}`, `<` for `<>`
- Quotes: `"` for `" "`, `'` for `' '`, ``` for `` ``
- Tags: `t` for HTML/XML tags
- Functions: `f` for function calls (e.g., name followed by balanced `()`)
- Interactive: `?` to prompt for left and right parts
- Other: Any character for symmetric surroundings (e.g., `_` for `_ _`)

Search method defaults to 'cover' (innermost covering the position), but can be configured. For finding and highlighting, the cursor moves or highlights based on the method.

**Example**  
To add parentheses around the current word:  
Press `gsaiw(`.  
This applies `(` operator to `iw` (inner word) text object, resulting in `(word)`.

**Example**  
To delete quotes around a selection:  
Visually select text with `v`, then press `gsd"`.  
This removes the surrounding quotes if they match.

**Example**  
To replace brackets with quotes:  
Press `gsr["`.  
This replaces `[` surroundings with `"` (awaits motion if not specified, but typically used after positioning).

**Example**  
To find the next function call:  
Press `gsffn`.  
This moves the cursor to the start of the next function surrounding.

**Output**  
After highlighting with `gsh(`, the matched parentheses may briefly highlight for 500ms (default duration), depending on your highlight groups and configuration.

### Advanced Usage

**Suffixes in Action**  
Append `n` or `l` after the surrounding character for non-default searches. For example, `gsd(n` deletes the next parentheses surrounding.

**Custom Surroundings**  
Configure `custom_surroundings` in opts to add new types, e.g., for LaTeX environments.

**Integration with Other Mini Modules**  
Works alongside mini.ai (for advanced text objects) if enabled, allowing surroundings on custom A/I text objects [Inference based on mini.nvim ecosystem].

**Practical Scenarios**  
**Scenario: Code Refactoring**  
In a Lua function, position cursor inside arguments and press `gsa(` to wrap them in an extra pair for grouping.

**Scenario: Markdown Editing**  
Select a phrase with `viw`, then `gsat` to surround with a bold tag `<b>phrase</b>` [Unverified for exact tag handling; tags use balanced open/close].

### Configuration

In LazyVim, configuration is set via the extra's opts table. Defaults include the remapped keys. To customize:

```lua
return {
  "echasnovski/mini.surround",
  opts = {
    highlight_duration = 1000,  -- Longer highlight
    n_lines = 50,               -- Wider search range
    search_method = 'cover_or_next',  -- Fallback to next if no cover
    respect_selection_type = true,    -- Adapt to visual type
  },
}
```

Add this to `lua/plugins/editor.lua` or similar. Note: Silent mode can suppress messages.

### Potential Issues

- Conflicts: The `gs` prefix may overlap with other plugins; remap if needed.
- Edge Cases: Unbalanced surroundings might not match as expected; use interactive `?` for complex cases.
- Performance: Large `n_lines` may slow searches in big files.

**Conclusion**  
mini.surround enhances text manipulation in LazyVim by providing intuitive operators for surroundings, making it suitable for code, markup, and prose editing. When enabled as an extra, its prefixed keybindings integrate well with LazyVim's ecosystem.

**Next Steps**  
Enable the extra and experiment with `gsa` on various text objects. Explore mini.ai for complementary text object enhancements, or review the full mini.nvim documentation for advanced customizations.

---

