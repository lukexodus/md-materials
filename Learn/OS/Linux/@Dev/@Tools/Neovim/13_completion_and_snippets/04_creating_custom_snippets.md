## Creating Custom Snippets


### Introduction to Snippets

Snippets are predefined code templates that expand into larger code blocks when triggered, aiding in faster coding by reducing repetitive typing. In LazyVim, snippets are powered by `luasnip` for the engine and `friendly-snippets` for a collection of predefined ones across languages. Custom snippets can be added per-filetype or globally, allowing personalization for workflows. This integration works with completion plugins like `nvim-cmp` for triggering via tab or other keys.

**Key Points**
- Luasnip supports Lua-based snippet definitions, offering flexibility with dynamic content via functions.
- Snippets can include placeholders, choices, and transformations.
- Behavior during expansion may vary based on cursor position, filetype detection, and plugin interactions.
- LazyVim loads snippets lazily, which might affect initial availability in a session.

### Prerequisites

Ensure the necessary plugins are enabled in your LazyVim setup.

**Key Points**
- Core plugins: `L3MON4D3/LuaSnip` and `rafamadriz/friendly-snippets`.
- These are included by default in LazyVim; confirm in `lua/plugins/editor.lua` or similar.
- For completion integration, `hrsh7th/nvim-cmp` with `cmp_luasnip` source is required.
- No additional system dependencies are typically needed, but Lua knowledge helps for advanced snippets.

If not present, add them:

**Example**
```lua
-- In lua/plugins/snippets.lua or equivalent
return {
  { "L3MON4D3/LuaSnip" },
  { "rafamadriz/friendly-snippets" },
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "saadparwaiz1/cmp_luasnip" },
  },
}
```

Run `:Lazy sync` to install or update.

### Basic Snippet Creation

Custom snippets are defined in Lua files within a specific directory structure. LazyVim autoloads snippets from `lua/snippets/` or via plugin opts.

**Key Points**
- Define snippets using `ls.snippet` or `ls.parser.parse_snippet` for simplicity.
- Triggers can be words, regex, or conditional.
- Placeholders use `${n}` for jumps, with optional defaults or transformations.
- Filetype-specific snippets go in `lua/snippets/ft.lua` where `ft` is the filetype (e.g., `lua/snippets/lua.lua`).

**Example**
Create a basic snippet for a Lua function:

```lua
-- In lua/snippets/lua.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("fn", {
    t("function "),
    i(1, "name"),
    t("("),
    i(2, "args"),
    t({")", "\t"}),
    i(3, "-- body"),
    t({ "", "end" }),
  }),
}
```

This expands `fn` to a function template; typing `fn` followed by tab (default trigger) inserts it, with jumps via tab/shift-tab.

### Advanced Snippet Features

Enhance snippets with dynamic elements, choices, and conditions.

#### Placeholders and Choices
Use `ls.choice_node` for selections.

**Example**
```lua
-- In lua/snippets/lua.lua
local c = ls.choice_node
local f = ls.function_node

s("var", {
  t("local "),
  i(1, "name"),
  t(" = "),
  c(2, {
    i(nil, "value"),
    f(function(args) return "require('" .. args[1][1] .. "')" end, {1}),
  }),
}),
```

Expands `var` with a choice: static value or dynamic require based on variable name.

#### Regex Triggers and Conditions
For context-aware triggering.

**Example**
```lua
s({
  trig = "date",
  regTrig = true,
  condition = function() return vim.fn.getline("."):match("^%s*--") end,  -- Only in comments
}, {
  f(function() return os.date("%Y-%m-%d") end),
}),
```

Triggers on `date` only in comment lines, inserting current date; actual date uses system time, which may differ.

#### Visual Mode Snippets
Snippets that wrap selected text.

**Example**
```lua
s({
  trig = "bold",
  snippetType = "autosnippet",
}, {
  t("**"),
  ls.visual_node(),
  t("**"),
}, { condition = ls.in_visual_mode }),
```

Select text, type `bold`, and trigger to wrap in markdown bold; works in visual mode only.

### Loading and Managing Snippets

LazyVim handles loading via `luasnip.loaders.from_lua` or VSCode-style JSON from `friendly-snippets`.

**Key Points**
- For JSON snippets, place in `~/.config/nvim/snippets/` with `.json` extension, filetype as key.
- Use `require("luasnip.loaders.from_vscode").lazy_load()` for custom paths.
- To disable built-in snippets, set `opts.snippets = false` in friendly-snippets config.
- Reload with `:LuaSnipUnlinkCurrent` then re-trigger; full reload may require session restart.

**Example**
Load custom VSCode-style snippets:

```lua
-- In plugin config
require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./my-snippets" } })
```

Place JSON like:
```json
// In my-snippets/lua.json
{
  "print": {
    "prefix": "pr",
    "body": "print(\"$1\")",
    "description": "Print statement"
  }
}
```

### Integration with Completion

Snippets appear in `nvim-cmp` popup, labeled as "Snippet".

**Key Points**
- Customize completion via `cmp.setup.sources` with `name = "luasnip"`.
- Keymaps like `<Tab>` for expansion are set in LazyVim defaults.
- If conflicts occur with other sources, adjust priority in cmp config.

**Example**
```lua
-- In lua/plugins/cmp.lua
require("cmp").setup({
  sources = {
    { name = "luasnip", option = { show_autosnippets = true } },
  },
})
```

This enables autosnippets; they may trigger automatically if enabled, depending on config.

### Troubleshooting

Issues might include snippets not loading, trigger failures, or syntax errors.

**Key Points**
- Check with `:LuaSnipListAvailable` to list loaded snippets per filetype.
- Errors appear in `:messages` or via `vim.notify`.
- If a snippet doesn't expand, ensure no keymap conflicts and correct filetype.
- [Inference] For large snippet files, performance might dip during loading; split into smaller files if observed.

**Example**
To debug:
```
:LuaSnipListAvailable
```
Lists snippets; empty for a filetype indicates loading issue.

### Best Practices

- Keep snippets concise to avoid overwhelming templates.
- Use descriptive triggers to prevent accidental expansions.
- Test in a scratch buffer to observe behavior variations.
- Share snippets via git for version control.

**Next Steps**
- Explore luasnip docs for more nodes like `dynamic_node`.
- Integrate with `nvim-autopairs` for balanced pairs in snippets.
- Create filetype-specific directories for organized management.

**Conclusion**
Custom snippets in LazyVim enhance productivity through tailored templates, with luasnip providing robust features. Start with simple definitions and iterate based on usage, noting that expansion reliability can depend on setup and updates.

---

