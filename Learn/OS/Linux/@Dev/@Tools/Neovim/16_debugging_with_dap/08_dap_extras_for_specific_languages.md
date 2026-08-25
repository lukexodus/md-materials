## DAP Extras for Specific Languages


### Overview of DAP Support

Debug Adapter Protocol (DAP) integration allows debugging code directly within the editor. LazyVim provides a core DAP extra along with language-specific extras that configure debug adapters for various programming languages. Enabling these extras typically involves adding them to the `LazyVim` configuration file or using the `:LazyExtras` command. Behavior may vary depending on installed plugins and system setup.

**Key Points**
- The `extras.dap.core` is often required as a base for language-specific debugging.
- Language extras may automatically install or configure adapters via Mason.
- Debugging sessions can be started with keymaps like `<leader>db` for breakpoints or `<leader>dc` for continue.

### Core DAP Extra

The `extras.dap.core` extra sets up the foundational plugins for DAP functionality. It enables `nvim-dap`, `nvim-dap-ui`, and `nvim-dap-virtual-text`, providing UI elements like variable inspection and virtual text for values during debugging.

To enable:
```lua
return { "LazyVim/LazyVim", opts = { import = "lazyvim.plugins.extras.dap.core" } }
```

**Example**
Configuring a basic debug session in `~/.config/nvim/lua/config/lazy.lua`:
```lua
require("dap").configurations.lua = {
  {
    type = "nlua",
    request = "attach",
    name = "Attach to running Neovim instance",
  }
}
```

**Output**
When starting a debug session, the DAP UI may open sidebars showing threads, scopes, and watches. Behavior may differ based on the adapter and project setup.

### Neovim Lua DAP Extra

The `extras.dap.nlua` extra configures debugging for Lua scripts within Neovim itself, using the `nlua` adapter.

To enable:
```lua
return { "LazyVim/LazyVim", opts = { import = "lazyvim.plugins.extras.dap.nlua" } }
```

It requires the `osv` tool for launching a headless Neovim instance.

**Example**
Debugging a Lua plugin:
1. Set a breakpoint with `<leader>db`.
2. Run `:lua require("osv").launch({ port = 8086 })`.
3. Start the attach configuration.

**Output**
The debugger may attach, allowing stepping through Lua code. [Inference: Attachment success may depend on port availability and Neovim version.]

### Python DAP Extra

The `extras.lang.python` extra includes support for Python debugging via `debugpy`. It configures `nvim-dap` and `mason-nvim-dap.nvim` optionally.

To enable:
```lua
return { "LazyVim/LazyVim", opts = { import = "lazyvim.plugins.extras.lang.python" } }
```

Requires `debugpy` installed, often via `pip install debugpy`.

**Example**
Debug configuration in `dap.lua`:
```lua
require('dap').adapters.python = {
  type = 'executable',
  command = 'python',
  args = { '-m', 'debugpy', 'adapter' },
}
require('dap').configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
    pythonPath = function() return '/usr/bin/python' end,
  },
}
```

**Output**
Launching may show the Python call stack in the DAP UI. Execution may pause at breakpoints, but could vary with virtual environments.

### Go DAP Extra

The `extras.lang.go` extra sets up debugging with `delve` via `nvim-dap-go`.

To enable:
```lua
return { "LazyVim/LazyVim", opts = { import = "lazyvim.plugins.extras.lang.go" } }
```

Requires `delve` installed.

**Example**
Using the pre-configured adapter:
```lua
require('dap-go').setup()
```

Start debugging with `<leader>dt` for tests.

**Output**
Debugging a Go function may display goroutines in the UI. [Unverified: Performance may differ in concurrent code.]

### Java DAP Extra

The `extras.lang.java` extra configures `nvim-jdtls` with DAP support for Java debugging.

To enable:
```lua
return { "LazyVim/LazyVim", opts = { import = "lazyvim.plugins.extras.lang.java" } }
```

Uses built-in Java debug adapter.

**Example**
Attach configuration:
```lua
require('dap').configurations.java = {
  {
    type = 'java',
    request = 'attach',
    name = 'Debug (Attach) - Remote',
    hostName = '127.0.0.1',
    port = 5005,
  },
}
```

**Output**
Attaching to a running JVM may allow inspecting variables. Behavior may change with different JDK versions.

### TypeScript/JavaScript DAP Extra

The `extras.lang.typescript` extra enables debugging with `js-debug-adapter`.

To enable:
```lua
return { "LazyVim/LazyVim", opts = { import = "lazyvim.plugins.extras.lang.typescript" } }
```

Requires `js-debug-adapter` via Mason.

**Example**
Node.js debug config:
```lua
require('dap').adapters['pwa-node'] = {
  type = 'server',
  host = 'localhost',
  port = '${port}',
  executable = { command = 'js-debug-adapter', args = { '${port}' } },
}
```

**Output**
Debugging a TS file may transpile and pause execution. [Inference: Browser debugging via pwa-chrome may require additional setup.]

### Rust DAP Extra

The `extras.lang.rust` extra uses `codelldb` for debugging.

To enable:
```lua
return { "LazyVim/LazyVim", opts = { import = "lazyvim.plugins.extras.lang.rust" } }
```

Installs `codelldb` via Mason.

**Example**
Keymap `<leader>dr` lists debuggables.

Config:
```lua
require('dap').adapters.codelldb = { type = 'server', port = '${port}', executable = { command = 'codelldb', args = { '--port', '${port}' } } }
```

**Output**
Debugging Rust code may show low-level details like registers.

### C/C++ DAP Extra

The `extras.lang.clangd` extra configures `codelldb` for C/C++ debugging.

To enable:
```lua
return { "LazyVim/LazyVim", opts = { import = "lazyvim.plugins.extras.lang.clangd" } }
```

**Example**
Launch config:
```lua
require('dap').configurations.cpp = {
  {
    name = 'Launch',
    type = 'codelldb',
    request = 'launch',
    program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}
```

**Output**
May pause at C++ breakpoints, displaying stack frames.

### .NET DAP Extra

The `extras.lang.dotnet` extra sets up `netcoredbg` for .NET debugging.

To enable:
```lua
return { "LazyVim/LazyVim", opts = { import = "lazyvim.plugins.extras.lang.dotnet" } }
```

**Example**
Config:
```lua
require('dap').adapters.netcoredbg = {
  type = 'executable',
  command = 'netcoredbg',
  args = {'--interpreter=vscode'}
}
```

**Output**
Launching a .NET app may show assembly details.

### PHP DAP Extra

The `extras.lang.php` extra uses `php-debug-adapter`.

To enable:
```lua
return { "LazyVim/LazyVim", opts = { import = "lazyvim.plugins.extras.lang.php" } }
```

**Example**
Adapter:
```lua
require('dap').adapters.php = {
  type = 'executable',
  command = 'php-debug-adapter',
}
```

**Output**
Debugging PHP scripts may integrate with web servers.

### Dart DAP Extra

The `extras.lang.dart` extra provides debugging through `dartls`.

To enable:
```lua
return { "LazyVim/LazyVim", opts = { import = "lazyvim.plugins.extras.lang.dart" } }
```

[Inference: May use Flutter debug adapter for mobile apps.]

**Example**
Basic setup relies on `dartls` for debug commands.

**Output**
Flutter apps may run in debug mode with hot reload.

### Other Languages with Potential DAP Support

For languages like Ruby (`extras.lang.ruby`), Kotlin (`extras.lang.kotlin`), and Elixir (`extras.lang.elixir`), DAP support may be available through community adapters or manual configuration. [Speculation: Check specific extra docs for updates, as of 2026 configurations could have evolved.]

**Key Points**
- Not all lang extras include built-in DAP; some require manual adapter setup.
- Always install required binaries (e.g., via Mason or system package managers).

**Conclusion**
LazyVim's DAP extras provide robust debugging for many languages, enhancing development workflows. Start with `dap.core` and add language extras as needed.

**Next Steps**
- Run `:LazyExtras` to browse and enable extras interactively.
- Customize configurations in `~/.config/nvim/lua/plugins/dap.lua` for project-specific needs.
- Test debugging in a sample project to observe behavior variations.

---

