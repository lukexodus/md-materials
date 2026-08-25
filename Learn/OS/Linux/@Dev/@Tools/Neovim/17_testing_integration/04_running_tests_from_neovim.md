## Running Tests from Neovim


### Overview

Neotest is an extensible framework for interacting with tests within Neovim, allowing users to run, debug, and manage tests from various languages and frameworks. In LazyVim, it is integrated through the test.core extra, which configures neotest along with common adapters and keymaps for a streamlined experience. This setup relies on language-specific adapters to parse and execute tests, and it can integrate with nvim-dap for debugging. Behavior may vary depending on the Neovim version (stable vs. nightly), installed adapters, project structure, and test runner configurations.

### Requirements

- Neovim 0.7.0 or higher.
- nvim-treesitter for parsing test files (often required, especially in stable Neovim versions).
- Language-specific test runners (e.g., pytest for Python, go test for Go).
- For debugging: nvim-dap and mason-nvim-dap.nvim (enabled via dap.core extra).

In LazyVim, dependencies like nvim-nio, plenary.nvim, and FixCursorHold.nvim are handled automatically when enabling the extra.

**Key Points**
- Ensure treesitter parsers are installed for the languages in use (e.g., :TSInstall python).
- System dependencies may include build tools or virtual environments for certain adapters.

### Installation

Enable the test.core extra in LazyVim using the :LazyExtras command, which installs neotest and its dependencies. For language support, enable corresponding extras like lang.python or lang.go.

To customize, create or edit ~/.config/nvim/lua/plugins/test.lua with additional configurations.

**Example**
```lua
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-treesitter/nvim-treesitter",  -- Often needed to avoid "no tests found" errors
    },
    opts = {
      adapters = {
        "neotest-python",
        "neotest-go",
      },
      status = { virtual_text = true },
      output = { open_on_run = true },
    },
  },
}
```

After adding, run :Lazy to sync plugins. Restart Neovim for changes to apply. If issues occur, such as "no tests found," verify treesitter installation and adapter configurations.

### Configuration Options

Neotest is configured via require("neotest").setup(opts), with LazyVim providing defaults like virtual text status and output opening on run. Customizations include adapter setups and consumer behaviors.

**Key Points**
- `adapters`: List of adapter names or tables with configs; LazyVim loads them automatically.
- `status`: Controls virtual text or signs for test results.
- `output`: Manages output window behavior.
- `quickfix`: Integrates with trouble.nvim if available for displaying diagnostics.
- For debugging, enable dap in adapter options where supported (e.g., neotest-python { dap = { justMyCode = false } }).

**Example**
```lua
require("neotest").setup({
  adapters = {
    require("neotest-python")({
      runner = "pytest",  -- Specify if default detection fails
      dap = { justMyCode = false },
    }),
    require("neotest-go")({
      args = { "-v", "-race" },
    }),
  },
  consumers = {
    -- Custom consumers for output, summary, etc.
  },
})
```

Behavior may vary if adapters lack support for certain features, like dap.

### Available Adapters

LazyVim's test.core extra includes support for common adapters, which must be installed separately or via language extras. Examples:

- neotest-python: For pytest and unittest.
- neotest-go: For Go tests.
- neotest-plenary: For Lua tests using plenary.
- neotest-jest, neotest-vitest: For JavaScript/TypeScript.
- neotest-rust: For Rust.
- neotest-vim-test: Fallback for unsupported runners.

For others, install via lazy.nvim specs and add to opts.adapters. Full list available in neotest documentation. [Unverified: New adapters may be available post-2025.]

### Key Mappings

LazyVim provides default keymaps under the <leader>t prefix for neotest operations. These can be overridden in your config.

**Key Points**
- <leader>tt: Run tests in current file.
- <leader>tT: Run all tests in directory.
- <leader>tr: Run nearest test.
- <leader>tl: Run last test.
- <leader>ts: Toggle summary panel.
- <leader>to: Show output for nearest test.
- <leader>tO: Toggle output panel.
- <leader>tS: Stop running tests.
- <leader>tw: Watch for changes and re-run.
- <leader>td: Debug nearest test (requires dap.core).
- <leader>tD: Debug current file.

Mappings may not trigger if no tests are detected or no active session exists.

### Workflow

1. Open a test file and ensure the adapter is configured.
2. Use <leader>ts to open the summary panel, which displays the test tree.
3. Run tests with <leader>tr (nearest), <leader>tt (file), or <leader>tT (all).
4. View results inline via virtual text or in the summary/output panels.
5. If a test fails, output opens automatically; inspect errors with <leader>to.
6. For continuous testing, use <leader>tw to watch files.
7. Stop runs with <leader>tS.

Diagnostics appear as virtual text, and quickfix integrates with trouble.nvim if installed. Behavior may vary with large test suites, potentially causing performance impacts.

### Debugging Tests

Integrate with nvim-dap by enabling the dap.core extra and configuring adapters to support dap strategy. Set breakpoints with <leader>db, then debug tests using <leader>td.

**Example**
For Go:
```lua
adapters = {
  ["neotest-go"] = {
    dap_go_enabled = true,
  },
}
```
Run <leader>td to debug the nearest test, entering a DAP session for stepping, inspecting variables, and stack navigation.

For Python, enable dap in the adapter config. This requires the debug adapter (e.g., debugpy) installed via Mason.

**Key Points**
- Not all adapters support debugging; check documentation.
- Use strategy = "dap" in run calls for custom scripts.

### Language-Specific Examples

#### Python

Enable lang.python and test.core extras. Add neotest-python dependency if needed.

**Example**
In plugins/test.lua:
```lua
{
  "nvim-neotest/neotest-python",
  opts = {
    runner = "pytest",
  },
}
```

Run tests with <leader>tt. If "no tests found," ensure treesitter-python is installed and files match patterns (e.g., test_*.py).

#### Go

Enable lang.go extra.

**Example**
```lua
adapters = {
  "neotest-go",
}
```

Use <leader>tr to run nearest test. For debugging, add dap_go_enabled = true.

#### JavaScript (Jest/Vitest)

Enable lang.typescript or similar.

**Example**
Adapters: "neotest-jest" or "neotest-vitest".

Run with standard mappings. Configure jestConfigFile if non-standard.

### Troubleshooting

- "No tests found": Verify treesitter, adapter config, and file patterns.
- Output not opening: Check opts.output.open_on_run.
- Debugging fails: Ensure DAP adapter installed and strategy supported.

Consult neotest logs with :lua require("neotest").diagnostic() for issues.

**Conclusion**
This setup provides a powerful testing environment in LazyVim, combining neotest's flexibility with DAP for debugging, adaptable to multiple languages.

**Next Steps**
- Enable language extras and test in a sample project.
- Explore neotest consumers like summary and output for advanced usage.
- Refer to neotest GitHub for adapter-specific docs and updates.

---

