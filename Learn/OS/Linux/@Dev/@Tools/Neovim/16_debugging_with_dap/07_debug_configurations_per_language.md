## Debug Configurations Per Language


### Introduction

Debugging in LazyVim leverages the Debug Adapter Protocol (DAP) through plugins like nvim-dap, providing a way to set breakpoints, step through code, and inspect variables. LazyVim's extras system simplifies setup by bundling DAP support for various languages. Enabling the `extras.dap.core` package installs foundational DAP plugins and attempts to configure adapters with reasonable defaults, though behavior may vary based on your environment, installed tools, and project structure. Language-specific extras often add tailored DAP integrations, adapters, and configurations.

To use debugging, first enable the relevant extras in your `lazy.lua` file, typically under the `extras` table:

```lua
return {
  { import = "lazyvim.plugins.extras.dap.core" },
  -- Add language-specific extras as needed, e.g.,
  { import = "lazyvim.plugins.extras.lang.python" },
}
```

Mason.nvim handles adapter installations automatically in many cases. Key mappings are often provided by nvim-dap and can be customized. Common ones include:

- `<leader>db`: Toggle breakpoint
- `<leader>dc`: Continue execution
- `<leader>di`: Step into
- `<leader>do`: Step over
- `<leader>dO`: Step out
- `<leader>dr`: Restart session

These mappings may differ based on your configuration; check `:Lazy` or which-key for details.

### General DAP Setup

The `extras.dap.core` package includes:

- nvim-dap: Core DAP client.
- nvim-dap-ui: UI for sessions, breakpoints, and variables (optional, enabled if installed).
- nvim-dap-virtual-text: Inline virtual text for variables (optional).
- mason-nvim-dap.nvim: Manages adapter installations and handlers.

Configuration options in `extras.dap.core` might look like:

```lua
{
  "jay-babu/mason-nvim-dap.nvim",
  opts = {
    automatic_installation = true,
    handlers = {},  -- Custom handlers can be added here
    ensure_installed = { "codelldb", "delve", "debugpy", "js-debug-adapter" },  -- Add adapters for your languages
  },
}
```

This setup attempts to provide baseline configurations, but for full functionality, enable language extras.

**Key Points**
- Adapters are installed via Mason; ensure it's configured.
- Configurations are filetype-based and can be extended in `~/.config/nvim/lua/plugins/dap.lua`.
- Behavior may vary across systems (e.g., Windows vs. Linux/macOS) due to adapter compatibility.

### Python

The `extras.lang.python` package integrates debugging via debugpy, a Python debugger adapter.

#### Enabling and Plugins
Enable with `{ import = "lazyvim.plugins.extras.lang.python" }`. This includes:

- mfussenegger/nvim-dap-python (optional): Provides Python-specific DAP configurations.
- mason-nvim-dap.nvim (optional): Handles the python adapter, with a custom handler to integrate nvim-dap-python without conflicts.

Mason ensures debugpy is installed.

#### Configuration
A basic setup might involve creating a virtual environment for debugpy and configuring the path. In `~/.config/nvim/lua/config/options.lua`:

```lua
vim.g.python3_host_prog = "~/.virtualenvs/debugpy/bin/python"
```

Extend DAP in `~/.config/nvim/lua/plugins/debugging.lua`:

```lua
return {
  "mfussenegger/nvim-dap-python",
  config = function()
    require("dap-python").setup(vim.g.python3_host_prog)
    require("dap-python").test_runner = "pytest"  -- Or "unittest"
  end,
}
```

Configurations are dynamically set for Python files, supporting launch and attach modes.

#### Custom Key Mappings
Add language-specific mappings:

```lua
keys = {
  { "<leader>dm", function() require("dap-python").test_method() end, desc = "Debug Test Method" },
  { "<leader>dc", function() require("dap-python").test_class() end, desc = "Debug Test Class" },
  { "<leader>df", function() require("dap-python").debug_file() end, desc = "Debug Python File" },
}
```

**Example**
For a script `main.py` with a function `add(a, b)`:

1. Set a breakpoint on the function line.
2. Use `<leader>df` to start debugging the file.
3. The session may launch in the current working directory, allowing stepping and variable inspection.

**Output**
During a session, nvim-dap-ui might show variables like `a = 5, b = 3`, with execution pausing at breakpoints.

### JavaScript and TypeScript

The `extras.lang.typescript` package supports debugging for JS/TS via the vscode-js-debug adapter.

#### Enabling and Plugins
Enable with `{ import = "lazyvim.plugins.extras.lang.typescript" }`. This includes:

- mfussenegger/nvim-dap (optional): Configures adapters and filetypes.
- jay-babu/mason-nvim-dap.nvim (optional): Installs js-debug-adapter, excluding deprecated chrome adapter.

Filetypes like javascript, typescript, react variants are associated with pwa-node.

#### Configuration
Adapters use js-debug-adapter for pwa-node, pwa-chrome, pwa-msedge. A sample from the extra:

```lua
adapters = {
  ["pwa-node"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = { command = "js-debug-adapter", args = { "${port}" } },
  },
}
```

Configurations for launch/attach:

- Launch: Uses tsx or ts-node if available, with sourceMaps=true, skipFiles=["<node_internals>/**", "**/node_modules/**"].
- Attach: Picks a process to attach to.

Extend in your config:

```lua
require("mason-nvim-dap").setup({
  ensure_installed = { "js-debug-adapter" },
  handlers = {
    js = function(config)
      -- Custom adjustments if needed
      require("mason-nvim-dap").default_setup(config)
    end,
  },
})
```

#### Custom Key Mappings
No extra-specific mappings; use general DAP keys.

**Example**
For a Node.js script `app.ts`:

1. Set breakpoints.
2. Select "Launch file" configuration via `:DapContinue`.
3. The adapter may resolve source maps, pausing execution in TS files.

**Output**
Variables pane might display objects like `{ user: { name: "Alice" } }`, with stack traces showing mapped sources.

[Inference]: If tsx is not detected, fallback to node may occur, potentially affecting behavior.

### Go

The `extras.lang.go` package integrates Delve for debugging.

#### Enabling and Plugins
Enable with `{ import = "lazyvim.plugins.extras.lang.go" }`. This includes:

- mfussenegger/nvim-dap (optional): Base DAP.
- leoluz/nvim-dap-go (dependency for neotest): Go-specific adapter.
- go.nvim: Enhances Go support, including debugging.
- pappasam/nvim-jqx (optional, for JSON querying, not debug-related).

Mason installs delve.

#### Configuration
Set `dap_go_enabled = true` in neotest-golang:

```lua
{
  "nvim-neotest/neotest",
  opts = {
    adapters = {
      ["neotest-golang"] = { dap_go_enabled = true },
    },
  },
}
```

Configurations use delve for launch/attach, often set automatically.

#### Custom Key Mappings
Use general DAP; for tests, neotest integrates debugging.

**Example**
In a Go file `main.go` with `func main() { ... }`:

1. Set breakpoint in main.
2. Run `:DapContinue` and select launch config.
3. Step through, inspecting goroutines.

**Output**
DAP UI may show threads and variables like `x = 42`.

### Rust

The `extras.lang.rust` package uses codelldb for debugging.

#### Enabling and Plugins
Enable with `{ import = "lazyvim.plugins.extras.lang.rust" }`. This includes:

- mrcjkb/rustaceanvim: Rust tools, including DAP integration.
- mason.nvim (optional): Installs codelldb.

#### Configuration
Mason ensures codelldb:

```lua
ensure_installed = { "codelldb" }
```

Rust-analyzer provides debug actions.

#### Custom Key Mappings
- `<leader>dr`: RustLsp("debuggables") to list and select debug targets.

**Example**
In `main.rs`:

1. Use `<leader>dr` to select a binary target.
2. Session launches with codelldb, allowing breakpoint navigation.

**Output**
Variables like `let vec = vec![1,2,3];` shown inline or in UI.

### C and C++

The `extras.lang.clangd` package supports debugging via codelldb.

#### Enabling and Plugins
Enable with `{ import = "lazyvim.plugins.extras.lang.clangd" }`. This includes:

- mfussenegger/nvim-dap (optional): Configures codelldb adapter.
- mason.nvim (optional): Installs codelldb.

#### Configuration
Adapter setup:

```lua
adapters = {
  ["codelldb"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = { command = "codelldb", args = { "--port", "${port}" } },
  },
}
```

Configurations for c/cpp:

- Launch file: Prompts for program, cwd=${workspaceFolder}.
- Attach: Picks process via dap.utils.pick_process.

**Example**
For `main.cpp`:

1. Compile with debug flags: `g++ -g main.cpp -o main`.
2. Set breakpoint, select "Launch file", enter ./main.
3. Step through code.

**Output**
Stack frames and variables like `int i = 10;` displayed.

[Unverified]: On macOS, connection issues may arise; ensure codelldb is accessible.

**Conclusion**
LazyVim streamlines debug setups, but custom tweaks may be needed for complex projects. Test configurations in small examples first.

**Next Steps**
- Explore nvim-dap wiki for advanced features.
- Add nvim-dap-ui for better visualization.
- Customize ensure_installed for your languages.

---

