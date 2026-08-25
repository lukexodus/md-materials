## Telescope - Fuzzy Finder and Picker


### Overview

Telescope.nvim is a highly extensible fuzzy finder plugin for Neovim that provides a unified interface for searching and picking items from various sources, such as files, buffers, commands, and more. It leverages fuzzy matching algorithms to filter results interactively as the user types. In LazyVim, Telescope is included as a core plugin, pre-configured with dependencies like plenary.nvim and optional extensions for enhanced functionality. It acts as both a fuzzy finder (for quick searches) and a picker (for selecting items from lists), integrating seamlessly with Neovim's ecosystem. Telescope's design emphasizes modularity, allowing users to create custom pickers or extend existing ones via Lua APIs.

Key features include:
- Multi-select capabilities for batch operations.
- Previewers for files, help tags, and other items.
- Customizable sorters, including fuzzy matching with fzf or native implementations.
- Integration with LSP, treesitter, and other plugins for advanced searches.
- Behavior may vary based on installed extensions or Neovim version, such as preview rendering with certain filetypes.

**Key Points**
- Telescope uses a popup window for interactions, powered by nui.nvim or similar in some setups.
- It supports themes for layout customization, like dropdown or ivy styles.
- Performance depends on buffer size and sorter choice; large repositories may benefit from fzf-native extension.

### Installation and Setup in LazyVim

In LazyVim, Telescope is enabled by default via the core plugins configuration. The setup is handled in `lua/lazyvim/plugins/editor.lua`, where it's specified with dependencies and basic config. Users can disable or customize it by overriding in `lua/plugins/editor.lua` or similar files.

To install extensions, add them as separate specs in plugin files. For example, telescope-fzf-native.nvim improves sorting speed.

If not using LazyVim, install via lazy.nvim with:

```lua
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
}
```

LazyVim pre-loads it on events like BufReadPost for efficiency.

**Key Points**
- Check installation with `:Lazy` to see status.
- Update with `:Lazy update`.
- [Inference: In Neovim 0.10+, Telescope may leverage new floating window features for better rendering.]

**Example**
To add an extension in LazyVim's custom plugins:

```lua
-- lua/plugins/telescope.lua
return {
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },
}
```

### Basic Usage

Invoke Telescope with `:Telescope <builtin>` or via keymaps. In LazyVim, default leader keymaps like `<leader>sf` for find_files make it accessible.

Fuzzy matching filters results in real-time. Navigation uses \<C-n>/\<C-p> or arrow keys; \<CR> selects.

Multi-selection with \<Tab>; actions like delete on selected items.

**Example**
To find files: `:Telescope find_files`

In a project directory, typing "conf" might show "config.lua", "init.lua", etc.

**Output**
A floating window with filtered list; selections open in buffers or execute actions.

### Built-in Pickers

Telescope provides numerous built-ins for common tasks:

- `find_files`: Searches files using fd or find.
- `live_grep`: Greps through files with ripgrep.
- `buffers`: Lists open buffers.
- `oldfiles`: Recent files.
- `commands`: Neovim commands.
- `help_tags`: Vim help.
- `lsp_references`: LSP symbols.

Each picker has options like theme="ivy" or hidden=true.

In LazyVim, some are mapped: `<leader>sb` for buffers.

**Key Points**
- Pickers can chain actions, e.g., grep then open in quickfix.
- Previews show content; disable with preview=false.
- Behavior may differ if ripgrep/fd not installed system-wide.

**Example**
```vim
:Telescope live_grep
```

Type pattern; results update live.

### Extensions and Integrations

Extensions expand functionality. Popular ones:

- `fzf`: Faster fuzzy with native C.
- `ui-select`: Replaces vim.ui.select.
- `file_browser`: File management.
- `undo`: Visual undo tree.
- LazyVim includes some like notify for notifications.

Load with `require("telescope").load_extension("name")`.

Integrates with LSP via `lsp_dynamic_workspace_symbols`, or git via `git_files`.

**Example**
After loading fzf:

```lua
require("telescope").setup({
  defaults = {
    sorter = require("telescope.sorters").get_fzf_sorter(),
  },
})
```

**Key Points**
- Extensions may require builds (e.g., make).
- Check compatibility; some need specific Neovim versions.

### Configuration Options

Configure via `require("telescope").setup({ ... })`. Sections: defaults, pickers, extensions.

Defaults include mappings, layout_config (width, height), file_ignore_patterns.

In LazyVim, defaults are set; override in `opts` key of spec.

**Example**
```lua
require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
      },
    },
    layout_strategy = "horizontal",
    layout_config = { height = 0.9, width = 0.9 },
  },
  pickers = {
    find_files = {
      theme = "dropdown",
      hidden = true,
    },
  },
})
```

**Key Points**
- Mappings in insert (i) or normal (n) mode.
- vimgrep_arguments for customizing grep.
- [Unverified: Some configs may impact startup time in large sessions.]

### Custom Pickers and Actions

Create custom pickers with `require("telescope.pickers").new(opts, { finder = ..., sorter = ..., })`.

Finders from `telescope.finders.new_table({ results = {} })`.

Actions via `telescope.actions` module, like `file_edit`.

In LazyVim, use for bespoke workflows.

**Example**
Simple custom picker:

```lua
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local function custom_picker(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Custom",
    finder = finders.new_table({
      results = { "item1", "item2" },
    }),
    sorter = conf.generic_sorter(opts),
  }):find()
end

custom_picker()
```

### Keymaps and Workflow Integration

LazyVim maps:
- `<leader>sf`: find_files
- `<leader>sg`: live_grep
- `<leader>/`: grep_string (current word)

Customize in `lua/config/keymaps.lua`.

Use in autocmds or commands for automation.

**Key Points**
- Which-key integration shows labels.
- Multi-session support via resume (`:Telescope resume`).

**Example**
Map custom:

```lua
vim.keymap.set("n", "<leader>sc", ":Telescope commands<CR>", { desc = "Commands" })
```

### Troubleshooting and Performance

- Slow searches: Install fzf-native or limit cwd.
- No results: Check dependencies, tools like rg/fd.
- Errors: `:checkhealth telescope` for diagnostics.
- In LazyVim, conflicts rare but check plugin overrides.

Behavior may vary with system (e.g., Windows paths).

[Speculation: Future versions might add AI-assisted filtering.]

**Conclusion**
Telescope enhances Neovim's navigation and search, making it a staple in LazyVim for efficient workflows.

**Next Steps**
- Explore built-ins with `:Telescope builtin`.
- Install extensions via LazyVim extras.
- Customize setup for personal projects.

---

