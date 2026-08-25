## Neotest framework


### Overview of the Neotest Framework

Neotest is an extensible plugin for Neovim that provides a unified interface for interacting with tests across various programming languages and test runners. It allows users to run, debug, and manage tests directly within the editor, supporting features such as test discovery, execution strategies, output display, and diagnostic integration. The framework relies on adapters to interface with specific test runners, enabling compatibility with diverse ecosystems.

### Integration in LazyVim

LazyVim, a modular Neovim configuration framework, includes Neotest as an optional extra under the category `test.core`. This integration simplifies setup by bundling Neotest with compatible plugins and providing default configurations tailored for LazyVim's ecosystem. When enabled, it leverages Neotest's capabilities for seamless testing workflows, often in conjunction with other tools like `nvim-dap` for debugging.

### Enabling Neotest in LazyVim

To activate Neotest in LazyVim, execute the `:LazyExtras` command within Neovim and select the `test.core` extra. This action installs and configures the necessary plugins automatically. Note that Neotest requires additional adapters for specific languages or runners to function effectively; these must be installed separately if not already present.

### Configuration Options

Configuration for Neotest in LazyVim is typically managed through Lua files, such as `~/.config/nvim/lua/plugins/test.lua`. Default settings include:

- **Adapters**: Specify a list of adapters or a table with custom options. For instance:
  ```lua
  adapters = {
    "neotest-plenary",  -- For Lua tests using Plenary
    ["neotest-golang"] = {
      go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
      dap_go_enabled = true,
    },
  }
  ```

- **Status Display**: `status.virtual_text = true` enables inline virtual text for test statuses.
- **Output Handling**: `output.open_on_run = true` automatically opens test output upon execution.
- **Quickfix Integration**: `quickfix.open` uses Trouble.nvim (if installed) or falls back to Neovim's built-in quickfix window.

These defaults can be overridden in your configuration file. Always consult the Neotest documentation for adapter-specific settings to ensure compatibility.

### Dependencies and Supported Adapters

Neotest depends on several plugins for core functionality:
- `nvim-nio` for asynchronous operations.
- `plenary.nvim` for utility functions.
- `nvim-treesitter` for parsing test structures (required by most adapters).
- Optionally, `antoinemadec/FixCursorHold.nvim` to mitigate cursor hold issues, and `nvim-dap` for debugging support.

Supported adapters cover a broad range of languages and runners, including:
- Python: `neotest-python` (for pytest and unittest).
- JavaScript/TypeScript: `neotest-jest`, `neotest-vitest`, `neotest-mocha`.
- Go: `neotest-go` or `neotest-golang`.
- Rust: `neotest-rust` or integration via `rustaceanvim`.
- Ruby: `neotest-rspec`, `neotest-minitest`.
- Others: Adapters for Elixir, Java, Kotlin, Scala, Dart, PHP, Haskell, and more.

For unsupported runners, the `neotest-vim-test` adapter can serve as a fallback. Installation of adapters follows standard plugin manager practices, such as adding them to your LazyVim configuration.

### Basic Usage

Once configured, interact with tests using Neotest's API:
- Run the nearest test: `require("neotest").run.run()`.
- Run tests in the current file: `require("neotest").run.run(vim.fn.expand("%"))`.
- Debug the nearest test (if supported): `require("neotest").run.run({ strategy = "dap" })`.
- Stop or attach to running tests: `require("neotest").run.stop()` or `require("neotest").run.attach()`.

Additional consumers enhance usability, such as the summary window for browsing test hierarchies, output panels for reviewing results, and diagnostic markers for errors. For detailed commands and key mappings, refer to `:help neotest` within Neovim.

This setup ensures a professional and efficient testing environment in LazyVim, adaptable to various development workflows. If specific language support is required, verify adapter compatibility in the Neotest repository.

---

