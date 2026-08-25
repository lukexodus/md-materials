## nvim-dap Configuration


### Overview

nvim-dap is a Debug Adapter Protocol (DAP) client implementation for Neovim, allowing integration with various debuggers. In LazyVim, it is provided as an optional extra called "DAP Core," which can be enabled to set up debugging capabilities. This extra integrates nvim-dap with other plugins for enhanced functionality, such as virtual text overlays and a user interface. Language-specific debugging is often handled through additional extras, like those for C++, TypeScript, Go, and Python, which may configure adapters and launch settings. Behavior may vary based on plugin versions, Neovim build, and system environment.

**Key Points**
- DAP Core is the foundational extra for debugging.
- It supports mason.nvim for automatic debugger installation.
- Custom configurations can be added in user plugin files to override defaults.

### Enabling DAP

To enable nvim-dap, use the `:LazyExtras` command and select "dap.core" from the list. This loads the necessary plugins and default settings. For language-specific support, enable corresponding extras, such as "lang.clangd" for C++ or "lang.typescript" for JavaScript/TypeScript.

Plugins marked as optional (e.g., mason-nvim-dap.nvim) are configured only if installed. Once enabled, nvim-dap can be customized in files under `~/.config/nvim/lua/plugins/`.

### Plugins Involved

The DAP Core extra includes the following plugins:

- `mfussenegger/nvim-dap`: The core DAP client.
- `theHamsta/nvim-dap-virtual-text`: Displays virtual text for debugger information, such as variable values.
- `rcarriga/nvim-dap-ui`: Provides a graphical user interface for debugging sessions.
- `jay-babu/mason-nvim-dap.nvim` (optional): Integrates with mason.nvim for managing and installing debug adapters.

For specific languages, additional plugins may be required, such as `leoluz/nvim-dap-go` for Go or `mfussenegger/nvim-dap-python` for Python.

### Keymaps

LazyVim defines a set of keymaps for nvim-dap under the `<leader>d` prefix, using which-key.nvim for discoverability. These are available when the DAP Core extra is enabled. Here is a comprehensive list:

- `<leader>da`: Run with arguments.
- `<leader>db`: Toggle breakpoint.
- `<leader>dB`: Set conditional breakpoint.
- `<leader>dc`: Continue or start debugging.
- `<leader>dC`: Run to cursor.
- `<leader>dg`: Go to line without executing.
- `<leader>di`: Step into.
- `<leader>dj`: Move down in call stack.
- `<leader>dk`: Move up in call stack.
- `<leader>dl`: Run last debug session.
- `<leader>do`: Step out.
- `<leader>dO`: Step over.
- `<leader>dP`: Pause.
- `<leader>dr`: Toggle REPL.
- `<leader>ds`: Show active session.
- `<leader>dt`: Terminate session.
- `<leader>dw`: Show widgets.
- `<leader>de`: Evaluate expression (normal and visual modes).
- `<leader>du`: Toggle DAP UI.
- `<leader>dPc`: Debug class (language-specific, e.g., Java).
- `<leader>dPt`: Debug method (language-specific).
- `<leader>td`: Debug nearest test.

These keymaps may be extended or modified in language extras. Behavior may vary if custom keymaps are defined.

### Configuring Adapters and Debuggers

Adapters connect nvim-dap to specific debuggers. In LazyVim, mason-nvim-dap.nvim handles installation and setup when enabled. Set `automatic_installation = true` in its options to auto-install adapters.

To configure adapters, extend the `nvim-dap` plugin in a user file (e.g., `lua/plugins/dap.lua`):

**Example**
```lua
return {
  {
    "mfussenegger/nvim-dap",
    opts = function(_, opts)
      local dap = require("dap")
      -- Custom adapter example
      dap.adapters.example_adapter = {
        type = "executable",
        command = "path/to/debugger",
        args = { "--some-arg" },
      }
    end,
  },
}
```

For mason integration:

```lua
return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = { "codelldb", "js-debug-adapter" },  -- Install specific debuggers
      automatic_installation = true,
      handlers = {},
    },
  },
}
```

Adapters are often pre-configured in language extras. Always check for existing definitions to avoid conflicts.

### Language-Specific Configurations

Language extras provide tailored nvim-dap setups. Enable them via `:LazyExtras` for the respective language.

#### C and C++

The "lang.clangd" extra configures `codelldb` for C/C++ debugging if nvim-dap is available.

- Adapter: Server type, localhost, dynamic port, using codelldb executable.
- Configurations:
  - Launch: Prompts for program path, current working directory.
  - Attach: Attaches to a selected process.

mason ensures `codelldb` is installed.

**Example** (Overriding in user config)
```lua
return {
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")
      dap.adapters.codelldb.port = 13000  -- Change port
      dap.configurations.cpp[1].name = "Custom Launch"  -- Modify config name
    end,
  },
}
```

#### JavaScript and TypeScript

The "lang.typescript" extra sets up `js-debug-adapter` for Node.js, Chrome, and Edge.

- Adapters: `pwa-node`, `pwa-chrome`, `pwa-msedge` (with aliases), server type, dynamic port.
- Configurations (for .js, .ts, .jsx, .tsx):
  - Launch file: Runs current file with source maps, excludes node_modules.
  - Attach: Attaches to a running process.

mason handles `js-debug-adapter` installation.

**Example** (Custom launch config)
```lua
return {
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")
      table.insert(dap.configurations.typescript, {
        type = "pwa-node",
        request = "launch",
        name = "Launch with tsx",
        program = "${file}",
        runtimeExecutable = "tsx",
      })
    end,
  },
}
```

#### Go

The "lang.go" extra enables DAP via `neotest-golang` with `dap_go_enabled = true`, requiring `leoluz/nvim-dap-go`. It uses `delve` as the debugger, installed via mason.

No direct `nvim-dap` opts; relies on nvim-dap-go for setup.

**Example** (Enabling in neotest)
```lua
return {
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        ["neotest-golang"] = {
          dap_go_enabled = true,
        },
      },
    },
  },
}
```

#### Python

The "lang.python" extra includes `mfussenegger/nvim-dap-python` for debugging, with mason integration. No specific opts by default; setup handled by the plugin.

**Example** (Basic setup extension)
```lua
return {
  {
    "mfussenegger/nvim-dap-python",
    opts = function()
      require("dap-python").setup("path/to/python")  -- Specify Python path if needed
    end,
  },
}
```

#### Lua

The "dap.nlua" extra provides a Lua adapter for debugging Neovim plugins/scripts.

No specific opts; defaults to plugin setup.

### Customizing Icons

Icons for DAP states can be customized in LazyVim's core options (e.g., `lua/config/options.lua` or plugin specs).

**Example**
```lua
return {
  "LazyVim/LazyVim",
  opts = {
    icons = {
      dap = {
        Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
        Breakpoint = " ",
        BreakpointCondition = " ",
        BreakpointRejected = { " ", "DiagnosticError" },
        LogPoint = ".>",
      },
    },
  },
}
```

### Overriding and Extending Configurations

To override extras, place custom plugin specs in `lua/plugins/`. Import extras correctly in `lua/config/lazy.lua` to allow merging. Avoid defining opts as functions if not needed; use tables for merging.

If changes are ignored, ensure extras are not imported in a way that overrides user configs (e.g., move imports from `plugins/extras.lua`).

For direct modification, copy the extra file (e.g., `clangd.lua`) to your plugins dir and edit it.

### Practical Examples

#### Setting Up a Basic Debug Session

1. Enable "dap.core" and a language extra (e.g., "lang.typescript").
2. Open a file, set a breakpoint with `<leader>db`.
3. Start debugging with `<leader>dc`.
4. Use `<leader>du` to toggle the UI.

**Output** (Example console during session)
```
DAP: Session started
Breakpoint hit at line 10
Variable 'x' = 42
```

#### Debugging a C++ Program

Assume a simple main.cpp.

**Example** (Launch config via prompt)
- Program: `./build/myapp`
- Args: `--input file.txt`

Behavior may vary if the debugger is not installed or if paths are incorrect.

### Conclusion

Configuring nvim-dap in LazyVim provides flexible debugging through extras and plugins. Start with DAP Core and add language support as needed. Customizations allow tailoring to specific workflows, though testing is recommended as integrations can evolve.

### Next Steps

- Explore more extras at lazyvim.org/extras for additional languages.
- Refer to nvim-dap documentation for advanced adapter options.
- Test configurations in a minimal setup to isolate issues.

---

