## Plugin Dependencies and Priority


### Overview of Plugin Management in LazyVim

LazyVim utilizes lazy.nvim as its plugin manager, which handles installation, loading, and configuration of plugins through a declarative specification system. Plugin dependencies refer to plugins that must be installed and loaded before another plugin can function correctly, such as requiring a library or core functionality. Priority, on the other hand, determines the order in which plugins are loaded during Neovim startup, with higher priority values loading earlier. This system allows for modular setups, conflict resolution, and optimized performance by deferring non-essential plugins. In LazyVim's default configuration, many plugins are pre-configured with dependencies and priorities, but users can override or extend them in `lua/plugins/*.lua` files.

Key elements include:
- Dependencies are specified as a table of plugin specs or strings (repo URLs).
- Priorities range from 0 to 10000, defaulting to 50; core plugins often use higher values like 1000.
- Loading behavior may vary based on Neovim version, system resources, or if 'lazy' is set to false for immediate loading.
- LazyVim's setup ensures dependencies are resolved automatically during `require("lazy").setup()`.

**Key Points**
- Dependencies prevent errors by ensuring required code is available.
- Priorities help manage init order, useful for plugins that modify global settings or keymaps.
- Circular dependencies are detected and may cause errors during setup.
- In LazyVim, extras (optional plugins) often declare dependencies on core ones.

### Specifying Dependencies

In a plugin spec (a table passed to lazy.nvim), the 'dependencies' key accepts an array of strings (GitHub repo shorthand like "user/repo") or full spec tables. When a plugin is installed, its dependencies are fetched and installed recursively. Dependencies are loaded before the main plugin, regardless of priority.

For example, a plugin might depend on 'nvim-lua/plenary.nvim' for utility functions. In LazyVim, this is common for testing or async operations.

Dependencies can also include version constraints or branches, e.g., `{ "user/repo", branch = "dev" }`.

Behavior may differ if a dependency is already installed manually or via another manager, potentially leading to version conflicts.

**Example**
In `lua/plugins/example.lua`:

```lua
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
  },
}
```

This ensures plenary.nvim and fzf-native are available before Telescope loads.

**Output**
During `:Lazy sync`, dependencies are installed if missing; no visible output unless errors occur.

### Handling Dependency Conflicts

Conflicts arise when multiple plugins depend on different versions of the same dependency. Lazy.nvim does not enforce version locking by default, so users might need to pin versions using 'version' or 'commit' in specs.

In LazyVim, the core config minimizes conflicts, but adding custom plugins requires checking compatibility. Use `:Lazy check` to verify updates and potential issues.

For optional dependencies, use 'optional = true' to avoid forcing installation if not needed.

**Key Points**
- Use 'cond' in specs to conditionally load dependencies based on environment.
- Dependencies can have their own dependencies, forming trees.
- [Inference: Deep dependency chains may increase startup time, measurable with `:Lazy profile`.]

**Example**
To handle a conflict:

```lua
return {
  {
    "some/plugin",
    dependencies = {
      { "shared/dep", version = "1.0" },  -- pin to avoid mismatch
    },
  },
}
```

### Understanding Priority

Priority controls the initialization order among plugins. Higher numbers load first (e.g., 100 for essentials). This is crucial for plugins that set global options, like colorschemes or keymap leaders, to avoid overrides.

Default priority is 50. LazyVim assigns high priorities to core plugins like lazy.nvim itself or nvim-treesitter.

For lazy-loaded plugins (event, ft, cmd triggers), priority affects order within eager-loaded groups, but actual loading defers until triggers.

Behavior may vary if 'lazy = false' is set, forcing immediate load regardless of priority.

**Key Points**
- Priorities do not affect installation order, only loading.
- Equal priorities load in spec declaration order.
- Use negative priorities sparingly, as they load last.
- In multi-plugin setups, test with `:Lazy reload` to observe order.

**Example**
In a custom spec:

```lua
return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,  -- load early for colorscheme
  },
  {
    "some/other-plugin",
    priority = 10,  -- load later
  },
}
```

This ensures the colorscheme applies before other UI plugins.

**Output**
No direct output; observe via startup time or `:Lazy` UI showing load order.

### Interaction Between Dependencies and Priority

Dependencies take precedence: A dependency loads before its parent, even if the parent's priority is higher. Within the same level, priorities sort the order.

For example, if Plugin A (priority 100) depends on Plugin B (priority 50), B loads first despite lower priority.

In LazyVim, this ensures foundational plugins like nvim-lspconfig load before dependents like mason.nvim.

Complex setups might require manual adjustment to avoid init conflicts, such as keymap overlaps.

**Example**
```lua
return {
  {
    "neovim/nvim-lspconfig",
    priority = 100,
  },
  {
    "williamboman/mason.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    priority = 50,  -- but lspconfig loads first due to dep
  },
}
```

### Best Practices for Custom Configurations

- Declare dependencies explicitly to avoid runtime errors.
- Assign high priorities (e.g., 500+) to plugins modifying core behaviors.
- Use LazyVim's extras system for pre-configured, dependency-aware plugins via `lua/config/lazy.lua`.
- Monitor with `:Lazy profile` to optimize load times.
- For large setups, group related plugins in separate files for modularity.
- Test changes with `:Lazy clean` and `:Lazy sync` to resolve issues.

[Speculation: Future lazy.nvim versions might introduce priority groups for finer control.]

**Key Points**
- Always check plugin docs for required dependencies.
- Avoid overriding LazyVim defaults unless necessary.
- Use 'opts' in specs for configuration post-dependency load.

### Troubleshooting Common Issues

- Missing dependency errors: Check specs and run `:Lazy sync`.
- Load order problems: Inspect `:Lazy` for actual sequence; adjust priorities.
- Performance dips: High-priority eager loads increase startup; prefer lazy-loading.
- Conflicts in LazyVim: Disable extras or use 'enabled = false' in overrides.
- Behavior may vary with Neovim nightly builds or plugin updates.

**Example**
To debug load order:

Execute `:lua require("lazy").load({plugins = {"plugin-name"}})` in command line to force load and observe.

### Advanced Topics

- Conditional dependencies: Use functions in 'dependencies' for dynamic lists.
- Plugin events: Tie priorities to 'event' for deferred loading.
- Integration with other managers: LazyVim discourages mixing, but possible with careful setup.
- In scripts, access lazy stats via `require("lazy").stats()` for programmatic checks.

**Conclusion**
Managing dependencies and priorities in LazyVim enables robust, performant configurations by ensuring correct order and availability of plugins.

**Next Steps**
- Review LazyVim's default plugins in `lua/lazyvim/plugins`.
- Experiment with custom specs in a minimal config.
- Consult lazy.nvim docs for full spec options.

---

