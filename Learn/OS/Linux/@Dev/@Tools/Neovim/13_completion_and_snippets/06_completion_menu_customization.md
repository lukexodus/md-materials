## Completion Menu Customization


### Overview

The completion menu in nvim-cmp displays suggestions from various sources, such as LSP, buffers, or paths. Customization options allow modifications to its appearance, behavior, and content rendering. In LazyVim, these are configured through the nvim-cmp extra, which provides defaults that can be extended in user files like `lua/plugins/cmp.lua`. Options include view types, formatting functions, window styles, ghost text, icons, kind labels, and highlight groups. Behavior may vary based on Neovim version, colorscheme, and conflicting plugins.

### View Types

The `view` table determines the menu style and layout. Supported types include custom (default floating popup), wildmenu (horizontal bottom bar, suitable for command-line), and native (experimental).

**Key Points**
- `entries.name`: Sets the menu type ("custom", "wildmenu", or "native").
- `entries.separator`: Custom separator for wildmenu (e.g., "|").
- `entries.selection_order`: "top_down" (default) or "near_cursor" (adjusts direction based on cursor position).

**Example**
```lua
-- In opts function
view = {
  entries = {
    name = "custom",
    selection_order = "near_cursor",
  },
}
```
This may open the menu above the cursor if space below is limited.

For command-line modes:
```lua
cmp.setup.cmdline("/", {
  view = {
    entries = { name = "wildmenu", separator = " | " },
  },
})
```

### Formatting Items

The `formatting` table controls how completion items appear, including fields like kind, abbreviation, and menu source. It uses a `format` function that modifies `vim_item` based on the entry.

In LazyVim defaults, it adds icons from `LazyVim.config.icons.kinds`, truncates abbreviations to 40 characters and menus to 30, appending "…" if needed.

**Key Points**
- `fields`: Array of displayed fields (default: {"kind", "abbr", "menu"}).
- `format`: Function receiving (entry, vim_item); return modified vim_item.
- Integration with plugins like lspkind for automated icons and labels.

**Example**
Using lspkind for symbols and source menus:
```lua
formatting = {
  format = require("lspkind").cmp_format({
    mode = "symbol_text",
    menu = {
      nvim_lsp = "[LSP]",
      buffer = "[Buffer]",
      path = "[Path]",
    },
  }),
}
```
This prepends symbols to kinds and appends source labels.

Manual icons without plugins:
```lua
local kind_icons = {
  Text = "",
  Method = "",
  -- Add more as needed
}

formatting = {
  format = function(entry, vim_item)
    vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
    vim_item.menu = ({
      nvim_lsp = "[LSP]",
      buffer = "[Buffer]",
    })[entry.source.name]
    return vim_item
  end,
}
```

For path sources with devicons:
```lua
formatting = {
  format = function(entry, vim_item)
    if entry.source.name == "path" then
      local icon, hl = require("nvim-web-devicons").get_icon(entry:get_completion_item().label)
      if icon then
        vim_item.kind = icon
        vim_item.kind_hl_group = hl
      end
    end
    return vim_item
  end,
}
```
Requires nvim-web-devicons plugin.

### Window Settings

The `window` table configures the floating window's appearance for completion and documentation.

In LazyVim, defaults use bordered windows, but users can override.

**Key Points**
- `completion`: Settings for the main menu window.
  - `winhighlight`: Highlight groups (e.g., "Normal:Pmenu,FloatBorder:Pmenu").
  - `col_offset`: Horizontal offset from cursor (positive right, negative left).
  - `side_padding`: Padding inside the window.
- Behavior may vary with terminal or GUI settings.

**Example**
```lua
window = {
  completion = {
    winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
    col_offset = -3,
    side_padding = 0,
  },
}
```
This shifts the menu left and removes side padding. Border color changes can be achieved by customizing Pmenu or FloatBorder highlights.

### Ghost Text

Ghost text displays faint previews inline after the cursor.

In LazyVim, it's enabled conditionally for AI completions with hl_group "CmpGhostText".

**Key Points**
- `experimental.ghost_text`: Boolean or table { hl_group = "GroupName" }.
- May impact performance or typing experience in large files.

**Example**
```lua
experimental = {
  ghost_text = {
    hl_group = "CmpGhostText",
  },
}
```
Define the highlight: `vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment" })`.

### Icons and Kinds

Icons enhance kind visibility; kinds are standard LSP CompletionItemKind values.

Customize by mapping kinds to icons (e.g., Nerd Fonts, Codicons) in the format function.

**Example**
Using Codicons (requires codicon.ttf font):
```lua
local cmp_kinds = {
  Text = " ",
  Method = " ",
  -- Add more
}

formatting = {
  fields = { "kind", "abbr" },  -- Hide menu field
  format = function(_, vim_item)
    vim_item.kind = cmp_kinds[vim_item.kind] or ""
    return vim_item
  end,
}
```
This shows only icons without text kinds.

### Highlight Groups

Define colors for menu elements using `vim.api.nvim_set_hl`.

LazyVim links CmpGhostText to Comment by default.

**Key Points**
- Groups include CmpItemAbbrMatch, CmpItemKindVariable, etc.
- Link to existing groups or set fg/bg/bold.

**Example**
VS Code Dark+ style:
```lua
vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#569CD6", bold = true })
vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#C586C0" })
-- Add for each kind
```
Apply before cmp.setup.

### Sorting and Preselect

Control item order and initial selection.

In LazyVim, uses default sorting; preselect based on auto_select.

**Key Points**
- `sorting`: Table with comparators (e.g., prioritize exact matches).
- `preselect`: cmp.PreselectMode.Item or None.

**Example**
```lua
preselect = cmp.PreselectMode.None,  -- No auto-preselect
sorting = {
  comparators = {
    cmp.config.compare.offset,
    cmp.config.compare.exact,
    -- Custom comparators
  },
}
```
[Inference: Source-specific priorities can be set by modifying comparators.]

### Item Limits

Limit displayed items globally or per source.

**Example**
Per source: `{ name = "buffer", max_item_count = 10 }` in sources.

[Unverified: Global limit via custom view or event handlers.]

### Advanced Customizations

- Custom menu via floating window for unique highlighting.
- Auto-select first item on &lt;CR&gt; by mapping.
- Visual tweaks to custom_entries_view.lua (e.g., padding, borders) via overrides.

**Example**
In LazyVim, extend opts:
```lua
-- In lua/plugins/cmp.lua
return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    opts.formatting.format = function(entry, item)
      -- Custom logic
      return item
    end
    return opts
  end,
}
```

### Practical Usage Example

Type "fun" in a Lua file; menu shows suggestions with icons and truncated labels.

Select with &lt;C-n&gt;, confirm with &lt;CR&gt;.

**Output**
Inserted: "function() end" (if snippet), with ghost text preview if enabled.

### Troubleshooting

- Menu not appearing: Check completeopt and sources.
- Border colors wrong: Customize FloatBorder hl.
- Preselect issues: Verify preselect mode.
- [Speculation: Flicker may occur with high debounce; adjust performance.]

**Conclusion**
Customizing the completion menu enhances usability by tailoring visuals and behavior to preferences, integrating seamlessly with LazyVim's defaults.

**Next Steps**
- Review nvim-cmp wiki for updates.
- Experiment with lspkind or tailwindcss-colorizer-cmp for colored previews.
- Test in a minimal config to verify changes.

---

