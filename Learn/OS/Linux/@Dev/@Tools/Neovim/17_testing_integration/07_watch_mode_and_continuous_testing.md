## Watch Mode and Continuous Testing


### Introduction

In the context of Neovim with LazyVim, watch mode refers to mechanisms that monitor file changes and automatically trigger actions, such as rerunning tests. Continuous testing builds on this by enabling ongoing validation of code during development, often integrating with testing frameworks. LazyVim supports this through plugins like neotest for test management and tools like overseer.nvim for task automation. These features help maintain code quality by providing immediate feedback on changes.

Behavior may vary depending on the testing adapter (e.g., for Jest, Pytest), file system watchers, and Neovim's configuration. For instance, some adapters may not support real-time watching due to language-specific limitations.

**Key Points**
- Watch mode typically uses file watchers like vim.loop or external tools to detect changes.
- Continuous testing runs subsets of tests automatically, reducing manual intervention.
- LazyVim extras like 'lazyvim.plugins.extras.test.core' include neotest and adapters.
- Integrates with version control hooks or CI/CD for broader workflows.
- Performance considerations: Watching many files can increase CPU usage in large projects.

### Installing and Configuring Relevant Plugins

LazyVim includes neotest optionally via extras. Enable it by adding to `lua/config/lazy.lua`: `{ import = "lazyvim.plugins.extras.test.core" }`. This pulls in neotest and common adapters.

For watch mode, ensure neotest is configured with watchers. Additional plugins like overseer.nvim can enhance task watching.

Install adapters via Mason, e.g., :MasonInstall neotest-python for Python.

**Example**
```lua
-- In lua/plugins/test.lua
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",  -- Adapter example
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            runner = "pytest",
            args = { "--log-cli-level", "INFO" },
          }),
        },
        watch = {
          enabled = true,
          symbol_queries = {},  -- Customize for symbols
        },
      })
    end,
  },
}
```
Reload Neovim. This enables watch mode in neotest.

For overseer, add `{ import = "lazyvim.plugins.extras.util.overseer" }`.

### Enabling Watch Mode

Watch mode in neotest monitors open test files or positions and reruns tests on save or changes. Use :Neotest watch to start.

Keymaps in LazyVim: \<leader\>tw to toggle watch on nearest test.

For broader watching, configure autocmds to trigger on BufWritePost.

**Key Points**
- Neotest's watch uses inotify or polling for changes.
- Can watch specific tests, files, or namespaces.
- Stops watching with :Neotest watch stop.
- Integrates with dap for debugging failing tests.

**Example**
1. Open a test file, e.g., test_example.py.
2. Run :Neotest summary to open the summary panel.
3. Place cursor on a test and press \<leader\>tw to watch it.
4. Alternatively, in Lua:
```lua
require("neotest").watch.toggle({ vim.fn.expand("%") })  -- Watch current file
```
5. Edit the source file; tests rerun automatically.

**Output**
The neotest summary updates with new results, showing passing/failing statuses. Output panel displays logs. Signs in the sign column may update for test outcomes.

Behavior may vary; for example, in some file systems, polling might be slower than event-based watching.

### Implementing Continuous Testing

Continuous testing extends watch mode to run tests repeatedly as code evolves. In LazyVim, combine neotest with autocmds or overseer tasks.

Set up a task in overseer to run tests on file changes, using watchers.

For neotest, use watch on the entire suite or filtered tests.

**Key Points**
- Filter tests with strategies like 'nearest' or 'failed' for efficiency.
- Use output panels for persistent logs.
- Combine with git integration to test only changed files.
- Overhead: In large suites, limit to focused tests to avoid delays.

**Example**
For overseer-based continuous testing:
```lua
-- In lua/plugins/overseer.lua
return {
  {
    "stevearc/overseer.nvim",
    config = function()
      require("overseer").setup()
      overseer.register_template({
        name = "Continuous Tests",
        builder = function()
          return {
            cmd = { "pytest" },  -- Adapt to your runner
            args = { "." },
            components = { "default", { "restart_on_save", paths = { "**.py" } } },
          }
        end,
      })
    end,
  },
}
```
Run with :OverseerRun Continuous Tests. It restarts on saves to .py files.

For neotest:
```vim
autocmd BufWritePost *.py,*.test.lua lua require('neotest').run.run({ strategy = 'integrated' })
```
This runs tests on save, simulating continuous mode.

**Output**
Tests execute in the background, with results in the neotest UI or overseer list. Notifications may appear for failures.

[Inference] In projects with many dependencies, initial runs might take longer, but subsequent watches are faster due to caching in some runners.

### Managing Watchers and Performance

To list active watchers: Use neotest's API or overseer:list.

Stop all: :Neotest watch stop_all or kill overseer tasks.

Optimize by excluding node_modules or build dirs in watch configs.

**Example**
```lua
-- Exclude patterns in neotest setup
watch = {
  filter = function(path)
    return not string.match(path, "node_modules")
  end,
}
```

### Integration with Other Tools

Pair with nvim-dap for debugging in continuous flows: Set breakpoints in failing tests.

Use telescope-neotest for searching tests to watch.

In version control, hook pre-commit to run watched tests.

**Key Points**
- UI: Neotest summary auto-refreshes in watch mode.
- Virtual text: Shows test statuses inline if enabled.
- Adapters: Some like neotest-jest support live reloading.

### Troubleshooting Common Issues

- Watcher not triggering: Check file system events; try polling mode.
- High CPU: Reduce watch scope or use debounce.
- Adapter errors: Ensure runner installed and paths correct.
- Conflicts: Multiple watchers might interfere; prioritize one.

Behavior may vary across operating systems; Linux inotify is efficient, while macOS might need adjustments.

[Unverified] As of early 2026, neotest v2+ enhances watch stability with better async handling.

### Advanced Usage

Script custom watchers with Lua APIs for conditional runs.

Integrate with tmux or terminal multiplexers for detached continuous testing.

Use neotest-consumers for custom outputs, like notifications.

**Example**
```lua
-- Custom watch with condition
local neotest = require("neotest")
neotest.watch.watch({
  filter = function(test)
    return test.status == "failed"  -- Only watch failed
  end,
})
```

**Conclusion**
Watch mode and continuous testing in Neovim via LazyVim streamline development by automating feedback loops, supporting efficient iteration on code. These tools adapt to various languages and project sizes, enhancing productivity.

**Next Steps**
- Enable the test extra and configure an adapter for your language.
- Experiment with watching a small test suite in a sample project.
- Explore overseer templates for more complex continuous tasks.

---

