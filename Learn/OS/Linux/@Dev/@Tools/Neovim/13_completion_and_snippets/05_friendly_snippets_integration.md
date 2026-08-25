## Friendly-Snippets Integration


### Overview of Friendly-Snippets

Friendly-snippets provides a large collection of pre-defined code snippets for numerous programming languages and frameworks, designed to work with snippet engines like LuaSnip. In LazyVim, it integrates with the `LuaSnip` plugin, which is enabled by default through the `nvim-cmp` completion setup. This allows users to expand snippets during code completion, boosting productivity by inserting boilerplate code, function templates, or common patterns. Friendly-snippets supports over 100 filetypes, including Lua, Python, JavaScript, HTML, and more. The snippets are loaded lazily when a compatible buffer is opened, minimizing performance impact.

**Key Points**
- Friendly-snippets is optional but loaded by default in LazyVim via `LuaSnip`'s configuration.
- It complements `nvim-cmp` for tab-completion and snippet expansion.
- Snippets can include placeholders, choices, and dynamic Lua code for advanced behavior.
- Behavior may vary based on the active completion sources and user mappings; test in specific filetypes.

### Default Setup in LazyVim

LazyVim configures `LuaSnip` to load snippets from Friendly-snippets automatically. This is handled in the `plugins/coding.lua` file, where `LuaSnip` is set up with `lazy_load` for Friendly-snippets. No manual installation is required, as it's included in the starter configuration. To verify, check for the presence of snippets by typing a trigger (e.g., "fn" in a Lua file) and seeing if completion suggests a function snippet.

The default keybindings for snippet navigation and expansion are integrated with `nvim-cmp`:
- `<Tab>` or `<C-k>` to expand or jump forward.
- `<S-Tab>` or `<C-j>` to jump backward.
- `<C-l>` for choice selection in snippets with options.

**Key Points**
- Snippets are filetype-specific and loaded on demand.
- If not appearing, ensure `LuaSnip` and `friendly-snippets` are installed via `:Lazy sync`.
- Completion behavior depends on the `nvim-cmp` setup; conflicts with other mappings may occur.

### Enabling or Disabling Friendly-Snippets

To explicitly control Friendly-snippets, modify the `LuaSnip` options in a user file like `lua/plugins/coding.lua`. By default, it's enabled, but you can disable it by setting `lazy_load` to false or excluding it.

**Example**

To disable Friendly-snippets globally:

```lua
return {
  {
    "L3MON4D3/LuaSnip",
    opts = function(_, opts)
      opts.snippet_dirs = {}  -- Clear default dirs if needed
      require("luasnip.loaders.from_vscode").lazy_load = function() end  -- Override lazy_load
    end,
  },
}
```

**Output**

Snippets from Friendly-snippets will no longer load, falling back to any custom snippets.

To enable it (if somehow disabled):

```lua
return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
```

**Key Points**
- Changes require restarting Neovim or `:LuaSnipReload`.
- Disabling may reduce startup time but limits snippet availability.

### Adding Custom Snippets

Extend Friendly-snippets by adding your own. Custom snippets can be in VSCode format (JSON) or LuaSnip's Lua format. Place them in `~/.config/nvim/snippets/` or specify via `snippet_dirs`.

**Example**

Create a Lua file for custom snippets, e.g., `lua/snippets/lua.lua`:

```lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("lua", {
  s("hello", {
    t('print("Hello, '), i(1, "world"), t('!")'),
  }),
})
```

Then, in `lua/plugins/coding.lua`:

```lua
return {
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })
    end,
  },
}
```

**Output**

In a Lua file, typing "hello" and expanding will insert `print("Hello, world!")` with "world" as an editable placeholder.

For VSCode-style JSON snippets, place in `snippets/package.json` or filetype-specific JSON files, and load via `lazy_load({paths = "path/to/snippets"})`.

**Key Points**
- Lua snippets offer more flexibility with dynamic content.
- Custom snippets override Friendly-snippets if triggers conflict.
- Use `:LuaSnipListAvailable` to list loaded snippets.

### Integrating with Specific Filetypes

Load snippets only for certain filetypes by specifying in `lazy_load`.

**Example**

Load Friendly-snippets only for Lua and Python:

```lua
return {
  {
    "L3MON4D3/LuaSnip",
    opts = function()
      require("luasnip.loaders.from_vscode").lazy_load({ include = { "lua", "python" } })
    end,
  },
}
```

**Output**

Snippets available in `.lua` and `.py` files, but not others.

Exclude filetypes:

```lua
require("luasnip.loaders.from_vscode").lazy_load({ exclude = { "markdown" } })
```

### Customizing Snippet Behavior

Adjust expansion keys or add features like history tracking in `LuaSnip` opts.

**Example**

Enable snippet history and change jump keys in `lua/plugins/coding.lua`:

```lua
return {
  {
    "L3MON4D3/LuaSnip",
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if require("luasnip").expand_or_jumpable() then
            require("luasnip").expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
}
```

**Output**

`<Tab>` expands or jumps in snippets; history allows returning to previous states.

**Key Points**
- Integrate with `nvim-cmp` mappings for seamless experience.
- Behavior may vary with other completion plugins like copilot.vim.

### Extending with Other Snippet Sources

Combine Friendly-snippets with sources like `honza/vim-snippets` or custom repositories.

**Example**

Add another snippet collection:

```lua
return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "honza/vim-snippets" },
    opts = function()
      require("luasnip.loaders.from_snipmate").lazy_load({ paths = vim.fn.stdpath("data") .. "/lazy/vim-snippets/snippets" })
      require("luasnip.loaders.from_vscode").lazy_load()  -- Keep Friendly-snippets
    end,
  },
}
```

**Output**

Snippets from both collections available, with potential overlaps resolved by load order.

### Troubleshooting Integration Issues

- **Snippets not loading**: Check `:LuaSnipInfo`, ensure dependencies installed, and filetype detected correctly.
- **Expansion failures**: Verify mappings with `:map <Tab>`, or conflicts via `:verbose imap <Tab>`.
- **Performance**: Lazy loading minimizes issues, but large custom sets may slow completion; profile with `:Lazy profile`.
- **Compatibility**: Works with LSP sources in `nvim-cmp`, but test with specific languages.
- Note: Snippet availability and expansion may vary across Neovim versions or plugin updates.

**Conclusion**

Integrating Friendly-snippets in LazyVim enhances code completion with ready-made templates, easily customizable for personal workflows. Start by exploring defaults, then add customs or adjust behaviors to fit your needs.

**Next Steps**
- Browse available snippets with `:Telescope luasnip`.
- Create filetype-specific customs for frequent languages.
- Combine with AI completion like Copilot for hybrid snippet generation.
- Refer to LuaSnip docs (`:help luasnip.txt`) for advanced features.

---

