## nvim-lint for Linting


### Overview

nvim-lint is an asynchronous linter plugin integrated into LazyVim for running external linter tools and displaying results as Neovim diagnostics via the `vim.diagnostic` API. It serves as the default linting solution in recent LazyVim versions, replacing setups like none-ls.nvim. Linting occurs automatically on specific events, with support for a wide range of linters across languages. In core LazyVim, minimal linters are configured by default, but language-specific extras (e.g., via `LazyExtras`) populate linters for filetypes like Python (ruff) or Lua (luacheck, selene). Linters are often installed through Mason, and the setup includes debouncing to prevent excessive runs. Behavior may vary depending on installed tools, filetype associations, and whether conditions for linter activation are met.

### Understanding Linting with nvim-lint

nvim-lint executes external commands asynchronously, parses their output, and converts it into diagnostics that Neovim can display with signs, virtual text, or floating windows. It complements LSP by focusing on static analysis tools not always covered by servers. Supported linters include over 150 tools like shellcheck for shell scripts, eslint for JavaScript, markdownlint for Markdown, and cspell for spell checking. In LazyVim, it resolves linters by filetype (including compound like yaml.ghaction), falls back to global or underscore-defined linters if none match, and filters based on conditions (e.g., presence of config files). Diagnostics integrate with features like Trouble for list views or Telescope for searching.

**Key Points**
- Asynchronous execution avoids blocking the editor.
- Parsers handle various output formats (e.g., via patterns, errorformat, or SARIF).
- Global linters apply to all filetypes using "*" key; fallbacks use "_".
- Conditional enabling via functions (e.g., check for selene.toml).
- Diagnostics configurable per namespace for virtual text, signs, etc.

### Default Configuration

LazyVim configures nvim-lint in `lua/lazyvim/plugins/linting.lua` with the following structure:

```lua
return {
  {
    "mfussenegger/nvim-lint",
    event = "LazyFile",
    opts = {
      -- Event to trigger linters
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        -- Create your linters here
        fish = { "fish" },
        -- Additional defaults are added via extras
      },
      -- LazyVim extensions to override linter options or add custom linters.
      linters = {
        -- Example of using selene only when a selene.toml file is present
        -- selene = {
        --   condition = function(ctx)
        --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
      },
    },
    config = function(_, opts)
      local M = {}

      local lint = require("lint")
      for name, linter in pairs(opts.linters) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
          if type(linter.prepend_args) == "table" then
            lint.linters[name].args = lint.linters[name].args or {}
            vim.list_extend(lint.linters[name].args, linter.prepend_args)
          end
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      function M.debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      function M.lint()
        -- Use nvim-lint's logic first:
        -- * checks if linters exist for the full filetype first
        -- * otherwise will split filetype by "." and add all those linters
        -- * this differs from conform.nvim which only uses the first filetype that has a formatter
        local names = lint._resolve_linter_by_ft(vim.bo.filetype)

        -- Create a copy of the names table to avoid modifying the original.
        names = vim.list_extend({}, names)

        -- Add fallback linters.
        if #names == 0 then
          vim.list_extend(names, lint.linters_by_ft["_"] or {})
        end

        -- Add global linters.
        vim.list_extend(names, lint.linters_by_ft["*"] or {})

        -- Filter out linters that don't exist or don't match the condition.
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            LazyVim.warn("Linter not found: " .. name, { title = "nvim-lint" })
          end
          return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, names)

        -- Run linters.
        if #names > 0 then
          lint.try_lint(names)
        end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = M.debounce(100, M.lint),
      })
    end,
  },
}
```

Core defaults include fish as an example; most linters come from enabled extras (e.g., `editor.linting.eslint` adds eslint).

### Performing Linting

Linting runs automatically via autocmds on configured events with a 100ms debounce. Manually trigger with `require("lint").try_lint()` or the internal `M.lint()` function. Position the cursor in a file, make changes, and save or leave insert mode to see diagnostics. For specific linters, call `try_lint("linter_name")`.

**Key Points**
- Automatic on write, read, or insert leave.
- Resolves linters hierarchically: exact filetype, split filetypes, fallbacks, globals.
- Warnings if linter not found.
- View running linters with `require("lint").get_running()`.

**Example**
In a Markdown file (assuming markdownlint installed via Mason):

```markdown
# Title
This is a long line that exceeds the typical length limit set by markdownlint, triggering a warning.
```

Save the file (`:w`).

**Output**
A diagnostic warning appears (e.g., virtual text: "Line is too long [MD013]"), visible via <leader>cd or Trouble.

### Keybindings Related to Linting

Linting is primarily automatic, with no default manual lint keybinding in LazyVim. Diagnostics from linting use LSP-related keys:

- <leader>cd: Line Diagnostics (n)
- ]d / [d: Next/Prev Diagnostic (n)
- ]e / [e: Next/Prev Error (n)
- ]w / [w: Next/Prev Warning (n)
- <leader>xx: Diagnostics (Trouble) (n)
- <leader>xX: Buffer Diagnostics (Trouble) (n)
- <leader>ud: Toggle Diagnostics (n)
- <leader>sd: Diagnostics (Telescope) (n)
- <leader>sD: Buffer Diagnostics (Telescope) (n)

Related LSP keys that may interact (e.g., for fixes from linters if applicable):

- <leader>ca: Code Action (n, x)
- <leader>cA: Source Action (n)

**Example**
To add a manual lint key: In `lua/config/keymaps.lua`:

```lua
vim.keymap.set("n", "<leader>cl", function() require("lint").try_lint() end, { desc = "Trigger Linting" })
```

Press <leader>cl in a buffer to run linters.

### Customizing nvim-lint

Extend in `lua/plugins/linting.lua` by overriding `opts`. Add linters to `linters_by_ft`, modify existing via `linters` (e.g., add args or conditions). For custom linters, define full specs with cmd, args, stdin, parser.

**Key Points**
- Install linters via <leader>cm (Mason) or system package managers.
- Wrap linters for post-processing (e.g., change severity).
- Disable auto-lint by removing events or autocmd.
- Per-linter diagnostic config via namespaces.

**Example**
Custom Markdown setup:

```lua
return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = vim.tbl_extend("force", opts.linters_by_ft or {}, {
        markdown = { "markdownlint" },
        ["*"] = { "cspell" }, -- Global spell check
      })
      opts.linters = vim.tbl_extend("force", opts.linters or {}, {
        markdownlint = {
          args = { "--disable", "MD013" }, -- Ignore line length
        },
      })
    end,
  },
}
```

**Output**
On save in Markdown, ignores long lines but checks spelling globally.

### Advanced Configurations and Plugins

- **Custom Parser**: Use `require("lint.parser").from_pattern(pattern, groups, severity_map)`.
- **Extras**: Enable like `linting.eslint` for JavaScript-specific setup.
- **Integration**: Works with conform.nvim (formatting), nvim-lspconfig (combined diagnostics), Trouble (lists), which-key (menus).
- Debug: Inspect `lint.linters` or use `:lua print(vim.inspect(require("lint").linters_by_ft))`.
- [Inference]: For large projects, adjust debounce or events to optimize performance.

### Integration with Other Features

Linting diagnostics merge with LSP ones, accessible via shared keys. Ties into code actions if linters provide fixes. Language extras (e.g., lang/python) add linters like ruff. Mason handles installation; Telescope/Trouble for navigation.

**Conclusion**
nvim-lint offers efficient, extensible linting in LazyVim, automating checks with minimal overhead and seamless diagnostic integration.

**Next Steps**
- Enable relevant extras in lazy.lua for language linters.
- Install tools with Mason (<leader>cm).
- Add custom linters or keybindings as needed.
- Review nvim-lint README for full linter list and parsers.

---

