## Managing Extra Dependencies


### Introduction

In LazyVim, the extras system relies on lazy.nvim for plugin management, where extras often introduce dependencies—either on other plugins, external tools, or even other extras. Managing these dependencies involves ensuring proper loading order, resolving conflicts, handling optional requirements, and configuring installations via tools like Mason. Dependencies can be explicit (declared in plugin specs) or implicit (arising from interactions between extras). For instance, language extras like lang.go may depend on LSP servers installed via Mason, while UI extras might rely on core plugins like nvim-treesitter. Effective management prevents issues like missing features, errors during sync, or performance degradation. Behavior may vary based on Neovim version, user configurations, or updates to LazyVim extras, as dependencies evolve with repository changes.

### Understanding Dependencies in Extras

Dependencies in the extras system fall into categories:

- **Plugin Dependencies**: Specified via the `dependencies` or `deps` field in a plugin spec table. These ensure required plugins load before or alongside the main one.
- **Extra-to-Extra Dependencies**: Some extras implicitly or explicitly require others; for example, certain dap extras depend on dap.core.
- **External Tool Dependencies**: Many extras, especially lang and lsp categories, require binaries like LSP servers, linters, or formatters, managed via Mason.nvim (bundled in LazyVim).
- **Optional Dependencies**: Marked with `optional = true`, these configure enhancements only if the dependency is installed, avoiding hard failures.

Lazy.nvim handles dependency resolution automatically during `:Lazy sync`, installing and updating as needed. However, users must address warnings about import order or conflicts manually.

**Key Points**
- Dependencies are resolved recursively; a dep's deps are also handled.
- Use `:Lazy check` to identify missing or outdated dependencies.
- In LazyVim, extras are designed to minimize conflicts, but custom combinations may require tweaks.

### Declaring Dependencies in Custom Extras

When creating or modifying extras, declare dependencies in the returned spec table. This ensures lazy.nvim loads them appropriately.

For plugin deps:
- Use `dependencies = { "plugin/repo" }` for required.
- For optional: `dependencies = { { "plugin/repo", optional = true } }`.

For extra-to-extra, import the dependent extra first in your config.

**Example**
A custom extra depending on editor.outline:
```lua
-- lua/plugins/custom/my-extra.lua
return {
  dependencies = {
    "hedyhli/outline.nvim",  -- From editor.outline
  },
  config = function()
    -- Use outline features here
  end,
}
```
Then import: `{ import = "plugins.custom.my-extra" }` in lazy.lua.

### Managing External Tool Dependencies

Extras like lang.python often require tools (e.g., pyright LSP, ruff linter) installed via Mason. LazyVim's extras automatically configure Mason to install these when enabled.

To manage:
- Use `:Mason` to view/install/update tools.
- In extras, specs may include `require("mason-lspconfig").setup_handlers()` for LSP integration.

For manual control, override in user config:
```lua
-- lua/plugins/lsp.lua
return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "additional-tool" })
    end,
  },
}
```

**Key Points**
- Mason handles LSP, DAP, linters, formatters.
- Some tools require external setup (e.g., Node.js for typescript-language-server).
- Behavior may vary if Mason's registry is outdated; run `:MasonUpdate`.

**Example**
Enabling lang.rust installs rust-analyzer via Mason automatically.

**Output**
After `:Lazy sync`, `:Mason` shows rust-analyzer as installed.

### Handling Dependency Conflicts

Conflicts arise from overlapping keymaps, options, or plugins across extras. For example, multiple formatting extras might compete for autoformatting.

Resolution strategies:
- Import order: Load conflicting extras in a specific sequence (e.g., ui.edgy before editor.outline, as warned in docs).
- Overrides: Use user plugin files to disable or remap conflicting features.
- Conditional Loading: Wrap configs in checks like `if require("lazy.core.config").plugins["conflicting-plugin"]._.loaded then ...`.
- Disable Parts: Set `enabled = false` in opts for specific components.

Use `:Lazy log` or `:Lazy debug` to trace loading issues.

**Key Points**
- Common conflicts: Keymap overlaps (e.g., \<leader>f in multiple extras).
- Test with a minimal config to isolate.

**Example**
To resolve a keymap conflict:
```lua
-- lua/plugins/editor.lua
return {
  {
    "plugin-with-conflict",
    opts = {
      keymaps = false,  -- Disable built-in keys
    },
    config = function()
      vim.keymap.set("n", "<leader>custom", "action", { desc = "Custom" })
    end,
  },
}
```

### Optional Dependencies and Enhancements

Optional deps allow extras to enhance features without requiring them. For instance, an extra might add integrations if telescope.nvim is present.

In specs: `optional = true` marks it, and configs use `pcall(require, "dep")` to check availability.

**Example**
Enhancing with an optional dep:
```lua
-- In an extra's config
local status_ok, dep = pcall(require, "optional-dep")
if status_ok then
  dep.setup({ integration = true })
end
```

### Dependency Management Tools in LazyVim

- **:Lazy sync**: Installs/updates deps.
- **:Lazy check**: Verifies deps and health.
- **:Lazy profile**: Measures load times, highlighting heavy deps.
- **lazyvim.json**: Tracks enabled extras; manage deps by enabling/disabling here.
- **Mason Integration**: For tool deps, use `:MasonInstall <tool>`.

For advanced users, fork extras and modify deps directly.

### Best Practices for Managing Dependencies

- Start with minimal extras to avoid bloat.
- Group related extras (e.g., all lang.* for a project).
- Version Pinning: Use `version = "*"` or specific tags in specs for stability.
- Testing: Use a separate Neovim config dir for experiments.
- Updates: Regularly `:Lazy update` and review changelogs for dep changes.
- [Inference: Future LazyVim versions may introduce dep graphs in UI; monitor repo.]

### Potential Issues and Troubleshooting

- Missing Deps: Errors like "module not found"; check `:Lazy log`.
- Circular Deps: Rare but cause sync failures; refactor specs.
- Performance: Too many deps slow startup; use lazy-loading strategies.
- Behavior may vary with Neovim's plugin ecosystem updates.

**Conclusion**
Managing dependencies in LazyVim's extras system ensures a stable, efficient setup by leveraging lazy.nvim's resolution and Mason's tooling, with user overrides for customization.

**Next Steps**
- Explore enabled extras' deps via `:Lazy show \<extra>`.
- Customize in lua/plugins/ for specific projects.
- Refer to LazyVim docs at lazyvim.org for extra-specific dep info.
- Contribute fixes to LazyVim GitHub if common issues arise.

---

