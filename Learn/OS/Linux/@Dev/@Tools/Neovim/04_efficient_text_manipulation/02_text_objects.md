## Text Objects


### Fundamental Concepts

Text objects in Neovim form a core part of its editing grammar, allowing operators (like d for delete, c for change, y for yank) to act on specific regions of text. They come in two variants: 'i' for inside (excluding delimiters) and 'a' for around (including delimiters). LazyVim inherits these from Neovim and enhances them via the mini.ai plugin, which is included by default. This plugin extends standard objects and adds new ones, such as for arguments, functions, and custom delimiters. Behavior may vary based on Neovim version, plugin configurations, or user overrides in LazyVim setups.

**Key Points**
- Text objects are used in operator-pending mode (e.g., diw deletes inside a word).
- Standard objects include words, sentences, paragraphs, quotes, brackets.
- mini.ai enhances these with next/last navigation, interactive selection, and additional types.
- Mappings are in visual, operator-pending, and normal modes.
- Visual mode allows selecting text objects directly (e.g., viw).

### Standard Text Objects

These are built into Neovim and available in LazyVim without plugins. They cover common text structures.

#### Word and WORD Objects
- iw: Inside a word (sequence of non-blank characters, excluding punctuation).
- aw: Around a word (includes surrounding whitespace).
- iW: Inside a WORD (sequence of non-blank characters).
- aW: Around a WORD (includes surrounding whitespace).

**Example**
In the text: "Hello, world!"
- Place cursor on "world", press diw: Deletes "world", resulting in "Hello, !".
- yaw: Yanks "world!" including the space before (if applicable).

#### Sentence and Paragraph Objects
- is: Inside a sentence (text ending with . ! ? followed by space or newline).
- as: Around a sentence (includes trailing whitespace).
- ip: Inside a paragraph (blank-line separated block).
- ap: Around a paragraph (includes surrounding blank lines).

**Example**
In a paragraph: "This is sentence one. This is two."
- cis: Changes inside the current sentence.

#### Quote and Bracket Objects
- i", i', i`: Inside quotes (double, single, backtick).
- a", a', a`: Around quotes (includes the quotes).
- i(, i), i[, i], i{, i}, i<, i>: Inside brackets (parentheses, squares, curlies, angles).
- a(, a), a[, a], a{, a}, a<, a>: Around brackets (includes the brackets).
- it: Inside a tag (HTML/XML, between <tag> and </tag>).
- at: Around a tag (includes the tags).

**Example**
In: "print('hello')"
- ci': Changes 'hello' to new text, keeping quotes.
- da(: Deletes print('hello') including parentheses.

#### Additional Standard Objects
- ib, ab: Aliases for i(, a(.
- iB, aB: Aliases for i{, a{.

**Key Points**
- Brackets can be balanced or unbalanced depending on context.
- Quotes handle escaped characters in some cases.
- Behavior may vary with syntax highlighting or filetypes.

### Enhanced Text Objects via mini.ai

LazyVim includes mini.ai, which extends standard text objects and adds new ones. It supports next/last variants (e.g., an for around next) and interactive mode for ambiguous selections. These enhancements apply to both standard and new objects.

#### Enhanced Built-in Objects
mini.ai improves standard ones like a(, a), a', etc., by adding support for whitespace variations, aliases, and better searching.

**Key Points**
- Enhances iw, aw, i", a{, etc., with optional next/last (e.g., in for inside next).
- Search scope limited to visible lines by default (configurable to n_lines=50).
- Supports v:count for repeating (e.g., d2iw deletes two inner words).
- Dot-repeat compatible for operations.

**Example**
In code with multiple words: "var x = 1; var y = 2;"
- din: Deletes inside the next word (e.g., "y").

#### New Text Objects Added by mini.ai
- Balanced brackets/quotes with aliases (e.g., a%, i% for custom).
- Function call: af/if (around/inside function, including name and args).
- Argument: aa/ia (around/inside argument, handles separators like commas).
- Tag: at/it (enhanced for better HTML/XML support).
- User-prompted: a?/i? (interactively define via input).
- Punctuation-based: a*/i* (around/inside asterisks), a_/i_ (underscores), etc.
- Whitespace: a\<space>/i\<space>.
- Digits: a0/i0 to a9/i9 (around/inside numbers).
- Custom via config: Treesitter-based (e.g., for classes, conditionals).

**Key Points**
- aa/ia for arguments in function calls (e.g., select arg in foo(bar, baz)).
- af/if for entire function calls.
- a=/i= for around/inside equals sign (customizable for any char).
- For non-Latin characters, falls back to standard if not defined.
- Interactive: a? prompts for custom pattern.

**Example**
In: "func(arg1, arg2)"
- cia: Changes "arg1" (inside argument).
- daa: Deletes "arg1," including comma.
- dif: Deletes inside the function call: "arg1, arg2".

#### Next and Last Functionality
- an/in: Around/inside next occurrence.
- al/il: Around/inside last (previous) occurrence.

**Key Points**
- Overrides some LSP mappings in Neovim 0.12+; can be remapped.
- Search methods: cover_or_next (tries to cover cursor, else next).
- Configurable via MiniAi.config.search_method.

**Example**
In repeated structures: "item1 item2 item3"
- With cursor on item1, yan: Yanks around next (item2 including space).

#### Motion Commands
- g[: Move to left edge of around text object.
- g]: Move to right edge.

**Example**
- g]a: Jumps to the end of the around word.

#### Interactive and Custom Modes
For ambiguity, mini.ai shows a menu for selection (unless silent=true).

**Key Points**
- Custom objects via Lua: patterns, functions, or Treesitter queries.
- Example config: Add text object for Python classes using Treesitter.

**Example**
- Press a?: Enter a pattern like \d+ for digits, then selects around matching number.

### Usage in Operators and Modes

Text objects integrate with operators and visual selections.

**Key Points**
- Operator + text object: e.g., yiw (yank inner word).
- Visual: viw selects inner word, then operate.
- Consecutive in visual: After viw, can press iw again for inner-inner.
- mini.ai supports this chaining.

**Example**
- vi"d: Visual select inside quotes, then delete.

### Configuration and Customization in LazyVim

LazyVim sets up mini.ai with defaults, but users can override in config/lua/plugins/editor.lua or similar.

**Key Points**
- Disable: Set { "echasnovski/mini.ai", enabled = false } in LazyVim extras.
- Customize: require('mini.ai').setup({ custom_textobjects = { x = { ... } } }).
- Treesitter integration: Use MiniAi.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }).

**Example**
Add a custom object for conditionals:
custom_textobjects = { c = MiniAi.gen_spec.treesitter({ a = '@conditional.outer', i = '@conditional.inner' }) }
Then dic: Delete inside conditional.

### Potential Variations and Caveats

These descriptions are based on Neovim 0.10+ and mini.ai as of 2025 documentation. Actual behavior may vary with updates, disabled plugins, or conflicting mappings. [Unverified: In some filetypes, syntax may affect matching.] Check :help motion.txt for core docs and :Lazy for plugin status.

**Conclusion**
Text objects, enhanced by mini.ai in LazyVim, provide powerful ways to manipulate structured text efficiently, combining standard Vim capabilities with advanced selections for arguments, functions, and custom patterns.

**Next Steps**
- Practice with :Tutor or sample files to test iw, aa, etc.
- Explore mini.ai config for Treesitter-based objects if using language extras.
- Use \<leader>? (if which-key enabled) to view related mappings.

---

