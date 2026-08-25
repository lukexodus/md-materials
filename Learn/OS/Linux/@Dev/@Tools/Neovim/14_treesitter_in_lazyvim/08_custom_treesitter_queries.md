## Custom Treesitter Queries


### Overview of Treesitter in LazyVim

Treesitter is a parsing library integrated into Neovim for syntax highlighting, code folding, indentation, and other features via incremental parsing of code into abstract syntax trees (ASTs). In LazyVim, Treesitter support comes through the `nvim-treesitter/nvim-treesitter` plugin, which is enabled by default. This plugin manages parser installations for various languages and applies queries for highlighting, injections (embedding one language in another), folds, and more. Queries are written in a custom s-expression-based language and stored in files like `queries/<filetype>/highlights.scm`. LazyVim extends the default Treesitter config in `lua/lazyvim/plugins/editor.lua`, allowing auto-installation of parsers and basic query setups. Custom queries can override or extend these for tailored behavior, such as improved highlighting in specific languages.

**Key Points**
- Treesitter parsers are language-specific and compiled from grammars.
- Queries define how to capture nodes in the AST for actions like highlighting.
- Behavior may vary based on Neovim version, parser updates, or conflicting plugins; test in relevant filetypes.

### Default Treesitter Configuration

LazyVim installs essential parsers (e.g., lua, vim, vimdoc, query) on startup and enables auto-installation for others via `ensure_installed`. Highlighting is activated globally, with options for additional indent and folding modules. Default queries are pulled from the Treesitter repository or plugin bundles.

The config can be inspected or extended in a user file like `lua/plugins/treesitter.lua`:

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = { "bash", "c", "html", "javascript", "json", "lua", "luadoc", "luap", "markdown", "markdown_inline", "python", "query", "regex", "tsx", "typescript", "vim", "vimdoc", "yaml" },
    },
  },
}
```

**Key Points**
- `ensure_installed` lists parsers to auto-install; add more as needed.
- Modules like `incremental_selection` or `textobjects` can be enabled separately.
- Default queries may not cover all edge cases in niche languages.

### Understanding Treesitter Query Syntax

Queries use s-expressions to match AST nodes. Basic structure: `(node-type (child) @capture-name)` where `@capture-name` tags nodes for actions like highlighting. Predicates like `#eq?` or `#match?` add conditions. Groups of queries are concatenated in files.

Common files:
- `highlights.scm`: For syntax highlighting.
- `injections.scm`: For language injections (e.g., SQL in strings).
- `folds.scm`: For code folding.
- `indents.scm`: For indentation rules.
- `locals.scm`: For scope definitions.

**Key Points**
- Queries are evaluated top-down; order matters for overrides.
- Use `:Inspect` or `:InspectTree` commands to view the AST and test matches.
- Syntax is case-sensitive; refer to Treesitter docs for details.

### Creating Custom Queries

Custom queries extend or override defaults. Place them in `after/queries/<filetype>/<query-type>.scm` in your config directory (e.g., `~/.config/nvim/after/queries/lua/highlights.scm`). Neovim loads these automatically, merging with built-ins. For LazyVim, ensure the Treesitter plugin is configured to include them.

To force loading, use the `config` function:

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
      -- Additional setup if needed
    end,
  },
}
```

**Key Points**
- File naming must match: `<filetype>` is the Neovim filetype, `<query-type>` is like `highlights`.
- Custom queries append to defaults unless using `; extends` at the top to replace.
- Changes may require `:TSUpdate` or restart for effect.

### Custom Highlighting Queries

Highlighting assigns Vim highlight groups to captured nodes.

**Example**

For improved Lua highlighting, create `after/queries/lua/highlights.scm`:

```
; extends

((function_definition
  name: (identifier) @function.definition)
 (#set! conceal "ƒ"))

(string_content) @string.content
```

This conceals function names (if conceal enabled) and captures string content.

**Output**

In a Lua file, function definitions may appear concealed as "ƒ", and strings get custom highlighting if linked to a group. Actual visibility depends on colorscheme and `conceallevel`.

### Custom Injection Queries

Injections embed parsers in nodes, like code blocks in Markdown.

**Example**

For injecting Lua in Markdown code blocks, in `after/queries/markdown/injections.scm`:

```
((code_fence_content) @lua
 (#match? @lua "^lua"))
```

**Output**

Lua code in ```lua

### Custom Folding Queries

Folds define regions for collapsing code.

**Example**

For Lua functions, in `after/queries/lua/folds.scm`:

```
(function_definition) @fold
```

**Output**

Functions become foldable with `zc`/`zo`. Folding level and persistence depend on `foldmethod=syntax` and other settings.

### Custom Indentation Queries

Indents guide auto-indentation.

**Example**

For Lua tables, in `after/queries/lua/indents.scm`:

```
(table_constructor) @indent
```

**Output**

Entering a table may auto-indent children. Results can differ based on existing rules.

### Testing and Debugging Queries

Use built-in commands:
- `:Inspect`: Show captures at cursor.
- `:InspectTree`: Display full parse tree.
- `:EditQuery`: Open a buffer to edit the current query.

For live testing, install `nvim-treesitter/playground` (add to plugins) for a query editor.

**Key Points**
- Errors in queries log to `:messages`; invalid s-expressions may silently fail.
- Parser updates via `:TSUpdate` can affect query compatibility.
- [Inference]: Complex queries might impact performance on large files, though typically minimal.

### Advanced Query Features

- **Captures**: Multiple `@capture` for groups, e.g., `@keyword` for hl-group linking.
- **Predicates**: `#not-eq?`, `#any-of?` for conditions.
- **Quantifiers**: `*`, `+`, `?` for repetition.
- **Anonymous nodes**: Like `("," @punctuation)`.

**Example**

Conditional highlight in Lua:

```
((identifier) @variable.parameter
 (#eq? @variable.parameter "self"))
```

**Output**

"self" highlights as a parameter. May not apply if overridden elsewhere.

### Integrating with Other Plugins

Treesitter queries power plugins like `nvim-treesitter-textobjects` for motions (e.g., `vaf` for functions).

**Example**

Enable in config:

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      textobjects = {
        select = {
          enable = true,
          keymaps = {
            ["af"] = "@function.outer",
          },
        },
      },
    },
  },
}
```

Requires matching queries in `queries/<filetype>/textobjects.scm`.

**Key Points**
- Custom queries can define new captures for textobjects.
- Compatibility with LSP or other syntax plugins may require adjustments.

### Troubleshooting Common Issues

- **No highlighting**: Ensure parser installed (`:TSInstall <lang>`), highlight enabled, no colorscheme conflicts.
- **Query not loading**: Check path, use `:lua print(vim.treesitter.query.list_files("lua", "highlights"))`.
- **Parse errors**: Validate s-expressions; use playground for debugging.
- Note: Query behavior may vary across Treesitter versions or grammar changes.

**Conclusion**

Custom Treesitter queries in LazyVim provide fine-grained control over syntax features, enabling personalized highlighting, injections, and more. Begin with simple extensions to default queries and use debugging tools to refine them.

**Next Steps**
- Install additional parsers with `ensure_installed`.
- Explore `nvim-treesitter/playground` for interactive query development.
- Integrate with `treesitter-context` for context-aware displays.
- Consult Treesitter query docs (`:help treesitter-query`) for syntax details.

---

