## Language-Specific Test Adapters


### Overview of Neotest

Neotest serves as an extensible framework integrated into Neovim for managing and executing tests across various programming languages and frameworks. In the context of LazyVim, it leverages adapters to interface with specific test runners, allowing users to run, debug, and view test results directly within the editor. LazyVim incorporates Neotest through its extras system, where the core testing functionality can be enabled separately, and language-specific adapters are often included in corresponding language extras or added manually.

Neotest relies on dependencies such as nvim-nio, plenary.nvim, nvim-treesitter, and optionally FixCursorHold.nvim to handle performance issues with CursorHold events. Adapters parse test structures (typically using Treesitter queries), build commands for running tests at different levels (file, namespace, or individual test), and process results to display outputs, errors, and statuses.

As of late 2025, Neotest has seen updates including fixes for output panel handling and client discovery for files outside the current working directory, along with additions like sibling/parent navigation in the summary window.

**Key Points**
- Adapters provide language-specific support and must be installed and configured separately.
- Neotest supports features like watching tests for auto-re-runs on file changes, output panels, summary windows, diagnostic messages, and status signs.
- Integration with nvim-dap allows debugging tests where supported by the adapter.
- Custom strategies for running tests (e.g., integrated background execution or DAP) can be implemented, with the default using a floating terminal for output.

Behavior may vary based on Neovim version, plugin updates, and system environment.

### Enabling Testing Support in LazyVim

To use Neotest, enable the `test.core` extra, which sets up the base Neotest plugin with default configurations such as virtual text for status indicators and automatic opening of output on test runs. Use the `:LazyExtras` command to select and enable extras.

For language-specific support, enable the relevant `lang.*` extra (e.g., `lang.python`), which may automatically include the corresponding adapter if `test.core` is active. If not, adapters can be added manually by creating or editing configuration files in `~/.config/nvim/lua/plugins/`.

**Example**
To enable the core testing extra and a basic adapter like neotest-plenary for Lua tests:

Create or edit `~/.config/nvim/lua/plugins/test.lua` with:
```lua
return {
  {
    "nvim-neotest/neotest-plenary",
  },
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        "neotest-plenary",
      },
    },
  },
}
```

Adapters load automatically based on installed plugins. Restart Neovim or run `:Lazy sync` to apply changes.

### Available Adapters

Neotest supports a broad range of adapters for different languages and frameworks. Below is a comprehensive list based on documented adapters as of 2025. Many are community-maintained and can be installed via lazy.nvim by specifying their GitHub repository.

Use a table for clarity:

| Language/Framework | Adapter Plugin | Supported Runners/Notes |
|--------------------|----------------|-------------------------|
| Python | neotest-python | pytest, unittest; configurable runner and Python executable. Included in LazyVim's `lang.python` extra. |
| Go | neotest-golang (or neotest-go) | go test; supports DAP debugging. Included in `lang.go` extra with options like custom test args and DAP integration. |
| JavaScript/TypeScript | neotest-jest | Jest; manual addition required in LazyVim. |
| JavaScript/TypeScript | neotest-vitest | Vitest; manual addition. |
| JavaScript/TypeScript | neotest-mocha | Mocha; manual addition. |
| Ruby | neotest-rspec | RSpec; manual. |
| Ruby | neotest-minitest | Minitest; manual. |
| Dart/Flutter | neotest-dart | dart test; manual. |
| Rust | neotest-rust | cargo test (Treesitter-based); alternative LSP-based via rustaceanvim. Manual in `lang.rust` extra [Inference]. |
| Elixir | neotest-elixir | mix test; manual. |
| .NET | neotest-dotnet | dotnet test (Treesitter); or neotest-vstest. Manual. |
| Scala | neotest-scala | ScalaTest, MUnit; manual. |
| Haskell | neotest-haskell | tasty, hspec; manual. |
| Java | neotest-java | JUnit, TestNG; manual. |
| Kotlin | neotest-kotlin | JUnit; manual. |
| C++ | neotest-gtest | Google Test; manual. |
| C++ | neotest-ctest | CTest; manual (added in 2025 updates). |
| Lua | neotest-plenary | Plenary; manual addition shown earlier. |
| Lua | neotest-busted | Busted; manual. |
| PHP | neotest-phpunit | PHPUnit; manual. |
| PHP | neotest-pest | Pest; manual. |
| R | neotest-testthat | testthat; manual. |
| Deno | neotest-deno | deno test; manual. |
| Zig | neotest-zig | zig test; manual. |
| Bash | neotest-bash | BATS; manual. |
| Swift | neotest-swift-testing | swift-testing; manual (community adapter from 2024). |
| Various | neotest-vim-test | Compatible with vim-test runners; lacks advanced features like per-test output. Manual. |

Additional adapters for tools like Gradle (neotest-gradle), Bazel (neotest-bazel), Foundry (neotest-foundry), and others (e.g., neotest-bun for Bun.js, neotest-playwright) exist for specialized use cases.

For LazyVim, if an adapter isn't bundled in a language extra, install it by adding the plugin spec and referencing it in Neotest's `opts.adapters`.

### Configuring Adapters

Configuration occurs in the `opts.adapters` table within the Neotest plugin spec. Adapters can be listed as strings (for defaults) or tables for custom options.

**Example** for Python (bundled in `lang.python`):
```lua
{
  "nvim-neotest/neotest",
  opts = {
    adapters = {
      ["neotest-python"] = {
        runner = "pytest",  -- or "unittest"
        python = ".venv/bin/python",  -- Use virtual env
        args = { "--log-cli-level", "DEBUG" },  -- Extra pytest args
      },
    },
  },
}
```

**Example** for Go (bundled in `lang.go`):
```lua
{
  "nvim-neotest/neotest",
  opts = {
    adapters = {
      ["neotest-golang"] = {
        go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
        dap_go_enabled = true,  -- Requires nvim-dap-go
      },
    },
  },
}
```

**Example** for JavaScript with Jest (manual addition):
First, add the adapter plugin:
```lua
{
  "nvim-neotest/neotest-jest",
},
```
Then configure:
```lua
{
  "nvim-neotest/neotest",
  opts = {
    adapters = {
      ["neotest-jest"] = {
        jestCommand = "npm test --",
        jestConfigFile = "jest.config.js",
        cwd = function(path)
          return vim.fn.getcwd()
        end,
      },
    },
  },
}
```

For debugging, ensure nvim-dap is installed and the adapter supports it (e.g., pass `strategy = "dap"` to run commands).

Behavior may vary if dependencies like Treesitter parsers are not installed for the language.

### Keybindings for Testing

LazyVim provides predefined keymaps under the `<leader>t` prefix for Neotest operations. These can be customized in your config.

**Key Points**
- All mappings assume `<leader>` is space (default in LazyVim).
- Mappings interact with nearest tests, files, or the entire suite.

Common keymaps:
- `<leader>tt`: Run tests in current file.
- `<leader>tT`: Run all test files.
- `<leader>tr`: Run nearest test.
- `<leader>tl`: Run last test.
- `<leader>ts`: Toggle summary window.
- `<leader>to`: Show output for nearest test.
- `<leader>tO`: Toggle output panel.
- `<leader>tS`: Stop running tests.
- `<leader>tw`: Toggle watch mode.
- `<leader>ta`: Attach to running test.
- `<leader>td`: Debug nearest test (requires DAP support).

### Practical Examples

#### Running Python Tests
Assume `lang.python` and `test.core` extras enabled.

1. Open a Python file with tests (e.g., using pytest).
2. Press `<leader>tr` to run the nearest test.
3. View results in the summary window (`<leader>ts`) or output (`<leader>to`).

**Example** test file (`test_example.py`):
```python
def test_addition():
    assert 1 + 1 == 2
```

**Output**
Test results appear as virtual text next to test functions, with signs for pass/fail. Output panel shows detailed logs if errors occur.

#### Debugging Go Tests
With `lang.go` extra and DAP enabled.

1. Place cursor near a test function.
2. Press `<leader>td` to debug.

**Example** Go test:
```go
func TestAddition(t *testing.T) {
    if 1 + 1 != 2 {
        t.Error("Addition failed")
    }
}
```

Behavior may vary if go-delve is not installed for DAP.

#### Setting Up Jest for TypeScript
Manually add as shown in configuration section.

1. Run `:Lazy sync`.
2. In a .ts file with Jest tests, use `<leader>tt` to run the file.

**Example** Jest test:
```typescript
test('addition', () => {
  expect(1 + 1).toBe(2);
});
```

### Troubleshooting Common Issues

- **No tests found**: Ensure Treesitter parser for the language is installed (`:TSInstall <lang>`). Check adapter configuration and file paths. [Unverified] Some users report issues with Go tests if not using the latest neotest-golang.
- **Adapter not loading**: Verify the plugin is installed and referenced in `opts.adapters`. Run `:checkhealth neotest`.
- **Output not showing**: Toggle panels or check if Trouble.nvim is interfering (used by default for quickfix).
- **Debugging failures**: Confirm nvim-dap and language-specific debug adapters (e.g., js-debug-adapter for JS) are set up.
- For recent issues (2025), updates fixed client discovery outside cwd; update plugins if encountering related errors.

Consult Neotest docs (`:h neotest`) or adapter repositories for detailed debugging.

**Conclusion**
Language-specific test adapters extend Neotest's capabilities in LazyVim, enabling seamless testing workflows tailored to your projects. By enabling extras and configuring adapters, you can integrate testing directly into your editing experience.

**Next Steps**
- Explore additional adapters from the Neotest README on GitHub.
- Customize keymaps or add watchers for CI-like feedback.
- Test with nvim-dap for full debug integration in supported languages.

---

