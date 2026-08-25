## Completion Sources


### Overview

In LazyVim, completion functionality is handled through plugins like nvim-cmp, which can be enabled as an extra. By default, LazyVim uses blink.cmp for completions, but enabling the nvim-cmp extra configures a set of sources to provide intelligent autocompletions during editing. These sources include contributions from language servers (LSP), the current buffer, file paths, and snippets via LuaSnip (when the LuaSnip extra is also enabled). The sources are prioritized and grouped in the configuration to balance relevance and performance. Note that actual behavior can vary depending on your specific Neovim version, installed plugins, and custom overrides.

The default nvim-cmp sources in LazyVim (when enabled) typically include `{ name = "nvim_lsp" }` for LSP-based suggestions, `{ name = "buffer" }` for buffer words, `{ name = "path" }` for filesystem paths, and `{ name = "luasnip" }` when LuaSnip is integrated. Additional sources like `{ name = "lazydev" }` may appear for Lua-specific completions. Enabling the LuaSnip extra modifies the nvim-cmp setup by adding the luasnip source and setting the snippet expansion function to `require("luasnip").lsp_expand(args.body)`.

To enable these, use `:LazyExtras` and select "coding.nvim-cmp" and "coding.luasnip". Customizations can be made in your `~/.config/nvim/lua/plugins/coding.lua` or similar files by extending the plugin specs.

**Key Points**
- Sources are modular and can be reordered or modified via the `opts.sources` table in the nvim-cmp configuration.
- Prioritization groups primary sources (e.g., LSP and path) before secondary ones (e.g., buffer) to reduce noise in suggestions.
- LuaSnip requires separate installation and enabling to function as a snippet source.
- Completions trigger on insert mode typing, with mappings like `<Tab>` for selection and `<CR>` for confirmation (configurable).
- Performance may differ based on buffer size, LSP server responsiveness, or system resources.

### LSP Completion Source

The LSP source, provided by `{ name = "nvim_lsp" }`, integrates with Neovim's built-in Language Server Protocol client to fetch completions from attached language servers. This source offers context-aware suggestions such as function signatures, variable names, and module imports based on the file type and server capabilities. In LazyVim, it's grouped as a primary source for quick access to semantic completions.

For instance, in a Python file with pylsp attached, typing "imp" might suggest "import" with details from the server. This source respects server-specific settings and can include documentation in the completion menu.

**Example**
To see LSP completions in action, ensure a language server is installed (e.g., via Mason in LazyVim) and attached to a buffer. In a Lua file:

1. Type `local f = func` and trigger completion (usually automatic or via `<C-x><C-o>`).
2. The menu may show "function" from the LSP source, labeled as "LSP" or with an icon.

**Output**
The completion item might display:
- Kind: Keyword
- Detail: (from LSP server)
- Documentation: Brief explanation if available.

Note: Availability depends on the LSP server's implementation; some servers may provide more comprehensive suggestions than others.

### Buffer Completion Source

The buffer source, `{ name = "buffer" }`, scans the text in the current buffer (and optionally visible buffers) to suggest words or phrases that have already appeared. This is useful for repeating identifiers or terms without retyping. In LazyVim's config, it's placed in a secondary group to avoid overwhelming the menu with less context-specific options. Options like `keyword_length` can be set to filter suggestions (e.g., minimum 3 characters).

This source is efficient for large buffers but may introduce duplicates if combined with other word-based sources. Behavior can vary if you enable multi-buffer scanning via `option.get_all_buffer_options`.

**Example**
In a buffer containing the text "local variable = 42", typing "var" elsewhere triggers the completion menu.

```lua
-- In init.lua
local variable = 42
-- Later:
local another_var = var  -- Completion suggests "variable"
```

**Output**
- Menu entry: "variable" (from buffer)
- Kind: Text
- No additional detail unless formatted.

[Inference]: In very large buffers, this source might impact performance slightly, though Neovim's indexing helps mitigate this.

### Path Completion Source

The path source, `{ name = "path" }`, provides completions for filesystem paths, making it easier to insert file or directory names. It's triggered in contexts like require statements or command-line modes. In LazyVim, it's a primary source, often used with cmdline completions for `:e` or similar.

This source resolves relative and absolute paths, respecting your current working directory. It can be configured with options like `trailing_slash` for directory handling.

**Example**
When editing a require statement in Lua:

```lua
local mod = require("path/to/mod")  -- Typing "path/" suggests directories and files
```

Or in command mode: `:e ~/.config/nvim/` – completions list subdirectories.

**Output**
- Menu shows file/directory names.
- Kind: File or Folder icon.
- Preview may show full path.

Note: This source interacts with your filesystem in real-time, so network-mounted paths might introduce latency.

### LuaSnip Completion Source

LuaSnip serves as a snippet engine and completion source via `{ name = "luasnip" }`, allowing insertion of predefined code templates (snippets). When the LuaSnip extra is enabled in LazyVim, it's added to nvim-cmp sources and configured for expansion. Snippets can come from VSCode-style files, friendly-snippets, or custom Lua definitions.

LuaSnip supports dynamic snippets with placeholders, choices, and Lua code execution. Integration includes jumping between placeholders with `<Tab>` or custom keys.

**Example**
Load a basic snippet for Lua:

```lua
-- In snippets/lua.lua
local ls = require("luasnip")
ls.add_snippets("lua", {
  ls.snippet("req", {
    ls.text_node("local "),
    ls.insert_node(1, "mod"),
    ls.text_node(" = require(\""),
    ls.insert_node(2, "module"),
    ls.text_node("\")"),
  }),
})
```

Typing "req" triggers the snippet in the completion menu.

**Output**
After expansion:
```
local mod = require("module")
```
With cursor on "mod" for editing.

Custom actions like snippet jumping are bound, e.g., `snippet_forward` checks `ls.jumpable(1)` and jumps if possible.

[Unverified]: Some users report occasional conflicts with LSP snippets; test in your setup.

**Conclusion**
These completion sources form the backbone of autocompletion in LazyVim, enhancing productivity by providing relevant suggestions from various contexts. Combining them allows for a tailored editing experience, though experimentation with priorities and filters is recommended to suit individual workflows.

**Next Steps**
- Enable the nvim-cmp and luasnip extras via `:LazyExtras`.
- Customize sources in `~/.config/nvim/lua/plugins/nvim-cmp.lua` by extending the spec, e.g., adding `{ name = "emoji" }`.
- Explore LuaSnip documentation for creating custom snippets.
- Use `:CmpStatus` to inspect active sources and debug issues.
- Consider integrating with other extras like friendly-snippets for pre-built snippet collections.

---

