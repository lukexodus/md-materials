## Mini.ai for Enhanced Text Objects


### Overview
Mini.ai is a module from the mini.nvim library that extends Neovim's built-in text objects, particularly the 'a' (around) and 'i' (inside) operators. It introduces customizable text objects using Lua patterns or functions, supports features like dot-repeat, v:count, various search methods, and consecutive applications in Visual mode. In LazyVim, mini.ai is included as part of the default mini.nvim integration, providing enhanced text manipulation for common syntax elements like brackets, quotes, functions, arguments, and tags. It also allows Treesitter-based custom objects. Behavior may vary depending on Neovim version (recommended 0.12+ for full compatibility), active plugins, and configuration overrides.

### Features
Mini.ai builds on Neovim's core text objects by adding flexibility and additional built-ins.

**Key Points**
- Customizable via Lua patterns, functions, or Treesitter queries.
- Supports dot-repeat for repeatable actions.
- Handles v:count for selecting multiple occurrences (e.g., 2di( to delete inside two nested parentheses).
- Configurable search methods: 'cover', 'cover_or_next', 'cover_or_prev', 'next', 'previous', 'nearest'.
- Consecutive application: Update selections in Visual mode without exiting.
- Aliases for common objects (e.g., a) as alias for a().
- Motions to jump to text object edges (g[ and g]).
- Built-in generators for tweaking objects (MiniAi.gen_spec).
- Integration with Treesitter for semantic text objects.

### Installation in LazyVim
LazyVim includes mini.nvim by default, with mini.ai enabled automatically in the starter template via lua/plugins/mini.lua or similar. No additional installation is typically needed unless disabled.

#### Enabling or Customizing
If mini.ai is not active (e.g., due to overrides), add or modify in lua/plugins/mini.lua:

**Example**
```lua
return {
  "echasnovski/mini.nvim",
  config = function()
    require("mini.ai").setup()  -- Enables mini.ai with defaults
  end,
}
```
Run :Lazy sync to apply. For standalone use (not recommended in LazyVim), specify 'echasnovski/mini.ai'. On Windows, if path length errors occur during sync, run git config --system core.longpaths true and retry.[Inference: Based on common Git issues reported in plugin docs.]

### Configuration Options
Configure via require('mini.ai').setup(opts), where opts overrides defaults. In LazyVim, place this in the mini.nvim spec or lua/config/autocmds.lua for global setup.

**Key Points**
- **custom_textobjects**: Table to define new objects or disable built-ins (set to false).
- **mappings**: Customize prefixes (e.g., around = 'a', around_next = 'an').
- **n_lines**: Search range (default 50 lines; increase for large files, but may impact performance).
- **search_method**: Default 'cover_or_next'; adjust for workflow (e.g., 'nearest' for quick jumps).
- **silent**: Set to true to suppress messages (default false).

**Example**
Custom config in lua/plugins/mini.lua:
```lua
return {
  "echasnovski/mini.nvim",
  config = function()
    require("mini.ai").setup({
      n_lines = 100,
      search_method = "nearest",
      custom_textobjects = {
        o = require("mini.ai").gen_spec.treesitter({ a = "@block.outer", i = "@block.inner" }),
      },
    })
  end,
}
```
This adds a custom 'o' object for code blocks via Treesitter. Reload Neovim or source the file for changes; behavior may vary if Treesitter parsers are not installed.

### Supported Text Objects
Mini.ai provides built-in objects, falling back to Neovim's defaults for unsupported cases like non-Latin text.

**Key Points**
- Balanced brackets: a(/i( (parentheses), with aliases like a)/i).
- Balanced quotes: a"/i", a'/i'.
- Whitespace: a\<Space>/i\<Space>.
- Function call: af/if.
- Argument: aa/ia (within calls).
- Tag: at/it (HTML/XML).
- User prompt: a?/i? (interactive).
- Punctuation/digits: a\<digit>/a\<letter>, etc.
- Custom: Via patterns or Treesitter.

Use with operators like d (delete), c (change), v (visual).

### Usage and Keymaps
Mini.ai uses standard operator-pending mode. Default mappings override some Neovim builtins (e.g., LSP in 0.12+); remap if needed.

**Key Points**
- Core: aX/iX where X is the object key (e.g., di" deletes inside quotes).
- Next/Last: anX/inX/alX/ilX for sequential navigation.
- Edge jumps: g[/g] to move cursor to left/right edge.
- In Visual mode: Press aX/iX to refine selection.
- With count: 3yan( yanks around three next parentheses.

In LazyVim, these integrate with other mini modules like mini.surround.

**Example**
Delete around a function call:
In normal mode, position cursor inside the call and press daf.
**Output** (assuming code: print(foo(bar())) ):
Removes "foo(bar())", leaving "print()". Actual result depends on cursor position and search method.

**Example**
Visual select inside quotes, then next:
Press vi", then in Visual mode press in" to select next quotes. Useful for chained edits.

### Custom Text Objects
Extend with custom_textobjects table. Use patterns for simple cases, functions for complex, or gen_spec.treesitter for semantic.

**Example**
Markdown emphasis:
```lua
custom_textobjects = {
  m = { pattern = { '%*%*().-()%*%*', '%_().-()_%' } },  -- For **bold** or _italic_
}
```
Then vim to select inside emphasis. [Unverified: Pattern may need tweaking for edge cases like nested.]

**Example**
Treesitter-based class:
```lua
custom_textobjects = {
  c = require("mini.ai").gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
}
```
Requires nvim-treesitter installed (default in LazyVim). Use dac to delete around a class.

### Integration with Treesitter
Use MiniAi.gen_spec.treesitter({ a = query, i = query }) for semantic objects. Queries reference Treesitter node types.

**Key Points**
- Enables objects like @function.outer, @loop.inner.
- Combine with nvim-treesitter-textobjects for more.
- Install parsers via :TSInstall (e.g., for lua).

**Example**
Loop object:
```lua
custom_textobjects = {
  l = require("mini.ai").gen_spec.treesitter({ a = "@loop.outer", i = "@loop.inner" }),
}
```
Then cil changes inside a loop. Behavior may vary by language parser quality.

### Troubleshooting Common Issues
Based on plugin docs and common reports.

**Key Points**
- **Overrides LSP mappings**: In Neovim 0.12+, remap LSP (e.g., in keymaps.lua: vim.keymap.set('x', 'il', '\<cmd>lua vim.lsp.buf.range_formatting()\<cr>')).
- **No text object found**: Check search_method; increase n_lines. Ensure cursor is in valid position.
- **Performance lag**: Reduce n_lines or use 'nearest' method for large buffers.
- **Windows errors**: Address Git path issues as noted.
- **Conflicts**: If other textobject plugins (e.g., targets.vim) are active, disable one.
Run :lua require('mini.ai').setup() manually to test.

**Conclusion**
Mini.ai enhances text object functionality in LazyVim by providing extensible, feature-rich alternatives to Neovim builtins, suitable for precise editing in code and markup. With customization options, it adapts to various workflows, though actual effectiveness may depend on configuration and file complexity.

**Next Steps**
- Experiment with built-in objects in a sample file.
- Add custom objects for your languages via Treesitter.
- Explore other mini modules like mini.surround for complementary features.
- Check mini.nvim GitHub for updates (main branch for latest).

---

