## Completion Performance Tuning


### Overview of Completion System

In LazyVim, code completion is primarily managed by the nvim-cmp plugin, which integrates with various sources like LSP (Language Server Protocol), snippets (via LuaSnip), buffer words, paths, and more. This system provides intelligent suggestions during typing, but in large projects or with resource-intensive sources, it can lead to slowdowns such as lag in popup appearance, high CPU usage, or delayed typing responsiveness. Performance tuning involves adjusting configurations to balance feature richness with speed, often by optimizing debounce times, source priorities, and resource usage. Factors like Neovim version, hardware, and active plugins influence outcomes, so results may vary across setups.

### Identifying Performance Issues

Before tuning, diagnose problems using built-in tools. Neovim's `:checkhealth` command can highlight plugin-related issues, while profiling helps pinpoint bottlenecks.

Use `:CmpStatus` to view active sources and their statuses. For deeper analysis, enable logging with `vim.lsp.set_log_level("debug")` temporarily, then review logs in `~/.local/state/nvim/lsp.log`.

Profiling completion:

- Use Neovim's built-in profiler: `:profile start profile.log` followed by `:profile func *` and `:profile file *`. Trigger completions, then `:profile pause` and analyze the log.
- Alternatively, plugins like vim-plug or built-in timing commands can measure invocation times.

Common symptoms include delays over 100ms in popup rendering or high memory usage from indexing large buffers.

[Inference: Based on typical nvim-cmp behaviors; actual thresholds depend on user hardware.]

### Key Configuration Options

nvim-cmp offers several options to tune performance, configurable in LazyVim via `lua/plugins/cmp.lua` or similar.

Core options include:

- **throttle_time**: Delays source triggering to reduce frequent calls (default: 80ms).
- **complete_debounce_time**: Waits after typing before completing (default: 60ms).
- **max_item_count**: Limits suggestions shown (e.g., set to 20 for faster rendering).
- **source priorities and timeouts**: Assign priorities (higher numbers first) and timeouts per source to prevent slow ones from blocking.

LazyVim's default setup includes sources like nvim_lsp, luasnip, buffer, and path. Disable or reorder unused sources to improve speed.

**Key Points**
- Increase debounce/throttle for slower hardware to reduce CPU spikes.
- Set source-specific timeouts, e.g., 500ms for buffer source in large files.
- Use `experimental.ghost_text` sparingly, as it can add rendering overhead.

### Optimizing LSP Integration

LSP servers are a common bottleneck due to real-time analysis. In LazyVim, LSP is configured via nvim-lspconfig and Mason.nvim.

Tuning tips:

- Limit capabilities: Disable unused features like hover or signature help if not needed.
- Use `debounce_text_changes` in LSP client config (e.g., 150ms) to reduce server calls.
- For specific servers, adjust settings: In lua_ls, set `Lua.workspace.checkThirdParty = false` to skip external library checks.
- Enable lazy-loading for servers via Mason's ensure_installed, but only for active filetypes.

If using multiple servers, prioritize them in cmp setup.

Behavior may vary by server; for example, clangd for C++ might be heavier than tsserver for TypeScript.

### Managing Sources and Completions

Customize sources in cmp config to exclude slow ones.

Default LazyVim cmp setup excerpt:

```lua
local cmp = require("cmp")
cmp.setup({
  sources = {
    { name = "nvim_lsp", priority = 1000 },
    { name = "luasnip", priority = 750 },
    { name = "buffer", priority = 500, option = { get_bufnrs = function() return vim.api.nvim_list_bufs() end } },
    { name = "path", priority = 250 },
  },
  performance = {
    debounce = 60,
    throttle = 30,
    fetching_timeout = 500,
    max_view_entries = 200,
  },
})
```

To tune:

- Remove `buffer` source for very large projects or set `keyword_length = 3` to trigger only on longer words.
- Add `max_item_count = 10` per source to cap results.
- For snippets, limit LuaSnip to essential collections.

**Example**

In `lua/plugins/cmp.lua`, add optimizations:

```lua
return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    opts.performance = {
      debounce = 150,  -- Increase for less frequent triggers
      throttle = 100,
      fetching_timeout = 300,  -- Timeout slow sources faster
    }
    for _, source in ipairs(opts.sources) do
      if source.name == "buffer" then
        source.option = { keyword_length = 4 }  -- Trigger after 4 chars
      end
    end
    return opts
  end,
}
```

This may reduce popup frequency in prose-heavy files.

### Profiling and Benchmarking

To measure improvements:

1. Install plenary.nvim (often included in LazyVim).
2. Use a script to benchmark completion times:

```lua
local start = vim.loop.hrtime()
-- Trigger completion here, e.g., vim.cmd("normal i")
local elapsed = (vim.loop.hrtime() - start) / 1e6  -- ms
print("Completion time: " .. elapsed .. "ms")
```

Run before/after changes. Aim for under 100ms on average hardware.

Tools like flame graphs via `perf` on Linux can visualize CPU usage, but require external setup.

[Unverified: Benchmark thresholds are approximate; test in your environment.]

### Handling Large Projects

For monorepos or large codebases:

- Use `workspace_folders` judiciously in LSP config to limit scanning.
- Enable gitignore respect in buffer source.
- Integrate with treesitter for faster parsing, ensuring it's enabled in LazyVim.
- Consider alternative lightweight completions like copilot.vim if LSP is too heavy, but note potential privacy trade-offs.

Potential drawbacks: Over-tuning debounce may make completions feel unresponsive.

### Advanced Techniques

- **Custom Comparators**: Override sorting to prioritize faster sources.
- **Async Sources**: Ensure sources like async_path are used for non-blocking I/O.
- **Plugin Alternatives**: If nvim-cmp remains slow, explore mini.completion or noice.nvim integrations, though they may not match feature parity.

Example custom comparator in cmp config:

```lua
sorting = {
  comparators = {
    cmp.config.compare.offset,
    cmp.config.compare.exact,
    -- Add custom logic here
  },
}
```

### Common Pitfalls

- Overloading with too many sources: Start with minimal and add as needed.
- Ignoring Neovim updates: Newer versions (e.g., 0.10+) have improved LuaJIT performance.
- Plugin conflicts: Disable overlapping plugins like auto-pairs if they interfere.
- Hardware limits: On low-RAM systems, close unused buffers with `:bufdo bd`.

Behavior may vary with concurrent plugins like telescope or lualine.

**Conclusion**

Tuning completion performance in LazyVim involves iterative configuration of nvim-cmp and LSP settings, focusing on debounce, source management, and profiling to achieve responsive suggestions without sacrificing functionality.

**Next Steps**

- Review your current cmp config with `:lua print(vim.inspect(require('cmp').get_config()))`.
- Test changes in a minimal LazyVim setup to isolate issues.
- Consult nvim-cmp's documentation or community forums for language-specific optimizations.

---

