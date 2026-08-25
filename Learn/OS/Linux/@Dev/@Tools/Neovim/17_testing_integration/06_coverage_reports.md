## Coverage Reports


### Introduction

Coverage reports in Neovim refer to tools and plugins that visualize test coverage data, highlighting which parts of the code are executed during tests. This aids in identifying untested code paths, improving code quality. In the context of LazyVim, while there is no dedicated extra for coverage, the `nvim-coverage` plugin can be integrated to display coverage in the sign column and provide summary pop-ups. It loads data from external test suites and supports various formats. Other plugins like `blanket.nvim` exist for specific use cases (e.g., Java), but `nvim-coverage` offers broad language support. Behavior may vary based on the test runner, report format, and Neovim configuration.

### Installation

To install `nvim-coverage`, it requires `nvim-lua/plenary.nvim` as a dependency. For XML-based formats like Cobertura, `lua-xmlreader` is optional but recommended.

#### Adding to LazyVim
Since LazyVim does not include a built-in extra for coverage, add it manually in `lua/plugins/coverage.lua` or a similar file:
```lua
return {
  {
    "andythigpen/nvim-coverage",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("coverage").setup()
    end,
  },
}
```
For optional rocks dependencies (e.g., `lua-xmlreader` for PHP):
```lua
return {
  {
    "andythigpen/nvim-coverage",
    dependencies = { "nvim-lua/plenary.nvim" },
    rocks = { "lua-xmlreader" },
    config = function()
      require("coverage").setup()
    end,
  },
}
```
After adding, run `:Lazy sync` to install. This setup enables basic functionality; advanced configs can be passed to `setup()`.

For integration with testing plugins, ensure `nvim-neotest/neotest` (from LazyVim's `test.core` extra) is enabled, as it can run tests with coverage enabled.

### Configuration

Configure via `require("coverage").setup(opts)`, where `opts` customizes signs, highlights, and behavior. In LazyVim, place this in the plugin spec's `config` function.

#### Basic Setup
```lua
require("coverage").setup({
  auto_reload = true,  -- Automatically reload coverage on file changes
  commands = true,     -- Enable :Coverage commands
})
```
This enables auto-reloading and Vim commands like `:CoverageLoad`.

#### Highlight and Sign Customization
Customize visuals for better theme integration:
```lua
require("coverage").setup({
  highlights = {
    covered = { fg = "#C3E88D" },    -- Green for covered lines
    uncovered = { fg = "#F07178" },  -- Red for uncovered
    partial = { fg = "#FF9E64" },     -- Orange for partial branches
  },
  signs = {
    covered = { hl = "CoverageCovered", text = "▎" },
    uncovered = { hl = "CoverageUncovered", text = "▎" },
    partial = { hl = "CoveragePartial", text = "▎" },
  },
})
```
These use Nerd Font-compatible symbols; adjust based on your font.

#### Summary Window Options
Tune the pop-up report:
```lua
require("coverage").setup({
  summary = {
    width_percentage = 0.7,
    height_percentage = 0.5,
    borders = "rounded",
    min_coverage = 80.0,  -- Highlight files below this threshold
  },
})
```
Behavior of the summary may vary with window management plugins.

#### Language-Specific Overrides
For per-language tweaks, use the `lang` table:
```lua
require("coverage").setup({
  lang = {
    python = {
      coverage_file = ".coverage",  -- Custom file path
      coverage_command = "coverage json -o -",
    },
  },
})
```
Consult the plugin docs for supported languages.

### Key Features

`nvim-coverage` focuses on visualization rather than test execution, loading reports from tools like `coverage.py` or `jest`.

**Key Points**
- Sign column indicators for covered, uncovered, and partial lines.
- Pop-up summary with per-file and total stats (lines, statements, branches).
- Auto-reload on report changes for dynamic workflows.
- Caching of coverage data to avoid repeated parsing.
- Extensibility for new languages via custom modules.
- Integration hooks for test runners like neotest.

The sign column displays coverage signs next to line numbers.



 The summary pop-up provides an overview.




### Supported Languages and Formats

The plugin supports multiple formats, with varying branch coverage.

| Language       | Format      | Branch Coverage | Example Tool       |
|----------------|-------------|-----------------|--------------------|
| Python        | JSON       | Supported      | coverage.py       |
| JavaScript/TS | lcov       | Supported      | Jest              |
| Go            | coverprofile| Not supported  | go test           |
| Ruby          | JSON       | Not supported  | SimpleCov         |
| Rust          | JSON       | Not supported  | grcov             |
| C/C++         | lcov       | Not supported  | gcov/lcov         |
| PHP           | Cobertura  | Not supported  | PHPUnit           |
| Lua           | lcov       | Not supported  | luacov            |
| Others        | lcov/JSON  | Varies         | Various           |

[Unverified] Support for additional formats may have been added in updates post-2023.

### Usage

Generate a report externally, then load it in Neovim.

#### Commands
- `:Coverage` or `:CoverageLoad`: Load the report.
- `:CoverageShow`: Display signs.
- `:CoverageHide`: Hide signs.
- `:CoverageToggle`: Toggle signs.
- `:CoverageClear`: Clear cache.
- `:CoverageSummary`: Open pop-up report.

In LazyVim, map these to keybindings in `lua/config/keymaps.lua`, e.g.:
```lua
vim.keymap.set("n", "<leader>tc", "<cmd>CoverageToggle<cr>", { desc = "Toggle Coverage" })
vim.keymap.set("n", "<leader>ts", "<cmd>CoverageSummary<cr>", { desc = "Coverage Summary" })
```

#### Workflow Example
1. Run tests with coverage (e.g., `coverage run -m pytest` for Python).
2. Load with `:Coverage`.
3. View signs and summary.

Behavior may vary if the report file changes during a session; use auto_reload to mitigate.

### Integration with Neotest

Pair with LazyVim's `test.core` extra (neotest) for seamless test running with coverage.

#### Setup Integration
Add a neotest adapter that supports coverage, e.g., `nvim-neotest/neotest-python`:
```lua
return {
  {
    "nvim-neotest/neotest-python",
    dependencies = { "nvim-neotest/neotest" },
    opts = {
      args = { "--cov" },  -- Enable coverage in pytest
    },
  },
}
```
After running tests via neotest (`<leader>tt`), load coverage with `:Coverage`.

### Practical Examples

#### Python Coverage
Generate report:
```bash
coverage run -m pytest
coverage json
```
In Neovim:
- Open a Python file.
- `:CoverageLoad`
- Signs appear; `:CoverageSummary` shows stats.

**Example**
Configuration for auto-load in Python files:
```lua
require("coverage").setup({
  lang = {
    python = {
      coverage_file = "coverage.json",
    },
  },
})
```
**Output**
Summary might display:
```
Total: 85% (lines: 170/200, branches: 50/60)
file1.py: 90%
file2.py: 75% (below threshold)
```
Exact output depends on the report data.

#### JavaScript with Jest
Run `jest --coverage`, generating `lcov.info`. Configure:
```lua
require("coverage").setup({
  lang = {
    javascript = {
      coverage_file = "coverage/lcov.info",
    },
  },
})
```
Load and view as above.

### Customization

Extend for new languages by creating `lua/coverage/languages/custom.lua` with load, sign_list, and summary functions. For sign priority, adjust in `signs` opts.

### Troubleshooting

- If signs don't appear, check report path and format compatibility.
- For large reports, parsing may slow; clear cache with `:CoverageClear`.
- Conflicts with other sign plugins: Adjust sign priorities in Neovim options.
- [Inference] If using Treesitter, ensure highlight groups don't override coverage ones.
- Errors may log in Neovim messages; verify dependencies are installed.

**Conclusion**
Integrating coverage reports via `nvim-coverage` enhances testing workflows in LazyVim by providing visual feedback on code quality.

**Next Steps**
- Enable `test.core` extra for neotest integration.
- Explore language-specific neotest adapters.
- Customize keymaps and add auto-commands for workflow automation.

---

