## Test Navigation and Summary


### Overview

In LazyVim, test navigation and summary refer to features provided by the neotest plugin, which is integrated as an extra for running, navigating, and summarizing test results. Neotest acts as a test runner adapter, supporting various languages through adapters like neotest-python or neotest-go. Navigation involves jumping between test files, definitions, and output panels, while summary provides an overview of test statuses (pass, fail, skip) in a dedicated window. These tools streamline testing workflows by allowing quick identification of issues without leaving the editor.

To enable, use `:LazyExtras` and select `test.core` for neotest core, plus language-specific ones like `lang.python_test`. Behavior may vary by adapter and test framework (e.g., pytest for Python, go test for Go), as adapters handle parsing differently.

### Setting Up Testing Environment

1. Enable neotest in LazyVim extras via `:LazyExtras`.
   - Core: `test.core`
   - Adapters: e.g., `test.neotest-python`, `test.neotest-go`, `test.neotest-vitest` for JavaScript.
2. Install required dependencies if needed (e.g., via Mason.nvim for treesitter parsers).
3. Configure in `lua/plugins/neotest.lua` if custom settings are desired, such as output panel size or diagnostic signs.
4. Keybindings are pre-configured in LazyVim, like `<leader>tt` to run nearest test.

LazyVim auto-configures neotest with a floating summary window and output panels. [Inference]: If tests don't run, verify adapter installation and test file structure.

### Running Tests

Neotest supports running tests at various granularities: nearest, file, suite, or all. Use commands or keybindings to execute.

Keybindings:
- `<leader>tt`: Run nearest test.
- `<leader>tT`: Run all tests in file.
- `<leader>ta`: Run all tests.
- `<leader>tl`: Run last test set.
- `<leader>ts`: Toggle summary window.

During execution, a progress indicator appears, and results update in real-time. Adapters may support debugging integration with nvim-dap for stepping into failing tests.

**Key Points**
- Supports async execution to avoid blocking the editor.
- Output captured per test, including stdout/stderr.
- Filters: Run marked tests or namespaces.

**Example**

For a Python project with pytest:

1. Open a test file (e.g., `test_example.py`).
2. Place cursor on a test function.
3. Press `<leader>tt` to run it.
4. Results show inline diagnostics (e.g., green check for pass, red X for fail).

Code snippet in `test_example.py`:

```python
def test_addition():
    assert 1 + 1 == 2
```

After running, inline signs appear next to the function.

### Navigating Test Results

Navigation allows jumping to test definitions, failures, or output. Neotest uses a tree-like structure in the summary window for hierarchical browsing (e.g., files > namespaces > tests).

Actions:
- In summary window: Use `j/k` to navigate, `<CR>` to jump to test position.
- `<leader>to`: Open output for nearest test.
- `<leader>tO`: Toggle output panel.
- `<leader>tp`: Open output in preview window.
- Jump to failures: Cycle through diagnostics with `[t` and `]t` (previous/next test issue).

The summary window is navigable like a tree-sitter outline, with expand/collapse via `zo/zc`. Behavior may vary if multiple adapters are loaded.

**Key Points**
- Integrates with vim's quickfix or trouble.nvim for list-based navigation.
- Supports attaching to running tests for live output.
- Use with telescope.nvim for fuzzy searching test names.

**Example**

After running a suite:

1. Toggle summary with `<leader>ts`.
2. Navigate to a failed test with `j/k`.
3. Press `<CR>` to jump to the test in the source file.
4. Press `<leader>to` to view detailed output (e.g., assertion error trace).

**Output**

Summary window might display:

```
test_example.py
  ✓ test_addition
  ✗ test_subtraction (failed: assert 2 - 1 == 0)
```

With colors for status.

### Summarizing Test Results

The summary window provides a concise overview, updating dynamically. It shows counts (e.g., passed: 5, failed: 2) and a tree view. Additional summaries can be generated via commands or integrated with statusline plugins.

Features:
- Toggle with `<leader>ts`.
- Filter views: Show only failures with adapter-specific options.
- Watch mode: `<leader>tw` to re-run on file changes.
- Export results: Some adapters support JSON output for CI integration.

Customize summary via neotest config: `summary = { mappings = { ... } }`.

**Key Points**
- Real-time updates during long-running tests.
- Hierarchical for nested tests (e.g., describe/it in Jest).
- Integrates with notify.nvim for popup notifications on completion.

**Example**

For a Go project:

1. Run all tests with `<leader>ta`.
2. Open summary: `<leader>ts`.
3. See overview like "Passed: 10, Failed: 1, Skipped: 0".
4. Expand file nodes to view individual test statuses.

**Output**

Example summary:

```
Overall: Passed 10/11
pkg/example
  TestAddition ... ok
  TestSubtraction ... FAIL
```

### Advanced Usage and Integration

- **Debugging Tests**: Use `<leader>td` to debug nearest test, combining with nvim-dap.
- **Custom Adapters**: Add community adapters for unsupported frameworks.
- **Output Customization**: Set `output_panel = { open = "botright vsplit" }` for split views.
- **Watching Files**: Enable auto-watch for TDD workflows.
- **Multi-Language Projects**: Neotest detects adapters per buffer filetype.
- [Speculation]: Future neotest updates may enhance summary with coverage integration.

Combine with overseer.nvim (another LazyVim extra) for task-based test running.

**Next Steps**
- Experiment with a sample project in your language of choice.
- Customize mappings in `lua/config/keymaps.lua`.
- Explore adapter docs for framework-specific features.

---

