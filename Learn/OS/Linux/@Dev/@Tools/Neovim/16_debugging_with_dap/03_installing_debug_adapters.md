## Installing Debug Adapters


### Overview of Debugging in Neovim with LazyVim

Neovim supports debugging through the Debug Adapter Protocol (DAP), which allows integration with various language-specific debuggers. LazyVim, a Neovim configuration built around lazy.nvim for plugin management, includes optional support for DAP via plugins like nvim-dap and mason-nvim-dap.nvim. This setup enables users to install and configure debug adapters for different programming languages.

Debug adapters act as intermediaries between Neovim and the actual debugger for a language. Common adapters include debugpy for Python, codelldb or cppdbg for C/C++, and js-debug for JavaScript/TypeScript. Installation typically involves using Mason, a tool for managing external binaries and LSP servers, extended by mason-nvim-dap for DAP adapters.

**Key Points**
- LazyVim's DAP integration is optional and enabled through extras.
- Adapters are installed via Mason, which handles binaries and configurations.
- Configurations for adapters and launch settings are defined in Lua files.
- Behavior may vary based on system environment, Neovim version, and installed plugins.

### Enabling DAP Support in LazyVim

To start using DAP, enable the relevant extras in your LazyVim configuration. This loads the necessary plugins automatically.

**Example**
Add the following to your `lua/config/lazy.lua` file:

```lua
return {
  -- other configurations...
  extras = {
    -- Enable core DAP support
    { import = "lazyvim.plugins.extras.dap.core" },
    -- Optionally enable language-specific extras, e.g., for Python
    { import = "lazyvim.plugins.extras.lang.python" },
  },
}
```

After saving, run `:Lazy sync` to install the plugins. This sets up nvim-dap, mason-nvim-dap.nvim, and related dependencies.

For automatic adapter installation, configure mason-nvim-dap in a plugin file like `lua/plugins/dap.lua`:

```lua
return {
  "jay-babu/mason-nvim-dap.nvim",
  opts = {
    -- Attempts to set up debuggers with reasonable defaults
    automatic_installation = true,
    -- Specify adapters to ensure are installed
    ensure_installed = { "python", "codelldb" },  -- Example for Python and C/C++
  },
}
```

**Note:** Automatic installation may not cover all edge cases; manual installation via `:Mason` is often recommended for verification.

### Using Mason to Install Debug Adapters

Mason provides a user interface for installing DAP adapters. Once DAP extras are enabled:

1. Open Mason with `:Mason`.
2. Navigate to the "DAP" section.
3. Search for and install desired adapters (e.g., debugpy, codelldb).

Adapters are installed in `~/.local/share/nvim/mason/bin/` or a similar path, depending on your setup.

For programmatic installation, use the `ensure_installed` option in mason-nvim-dap as shown above.

**Key Points**
- Mason handles dependencies like required system packages (e.g., unzip for some adapters).
- Installed adapters can be updated or uninstalled via `:Mason`.
- [Inference] On some systems, additional permissions or PATH adjustments may be needed if Mason encounters installation issues.

### Configuring Debug Adapters

After installation, configure adapters in your Neovim setup. Configurations define how Neovim connects to the debugger, including executable paths and launch parameters.

Configurations are set via `require("dap").adapters` and `require("dap").configurations`.

**Example** (For C++ using cppdbg, in `lua/plugins/dap.lua`):

```lua
return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")
    dap.adapters.cppdbg = {
      id = "cppdbg",
      type = "executable",
      command = vim.fn.stdpath("data") .. "/mason/bin/OpenDebugAD7",
    }
    dap.configurations.cpp = {
      {
        name = "Launch",
        type = "cppdbg",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtEntry = true,
      },
    }
  end,
}
```

This example prompts for the executable path when launching.

For multiple languages, extend the configurations array accordingly.

**Output** (Example of launching a debug session):
- Set breakpoints with `<leader>db`.
- Start debugging with `<leader>dc` or `:lua require("dap").continue()`.

Behavior may vary if the adapter requires additional setup, such as environment variables.

### Language-Specific Setup Examples

#### Python with debugpy

Python debugging uses nvim-dap-python, which integrates with debugpy.

1. Install debugpy via Mason or manually in a virtual environment.
2. Configure in `lua/plugins/dap-python.lua`:

```lua
return {
  "mfussenegger/nvim-dap-python",
  config = function()
    require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")  -- Path to debugpy Python
    require("dap-python").test_runner = "pytest"  -- Optional for testing
  end,
  keys = {
    { "<leader>dm", function() require("dap-python").test_method() end, desc = "Debug Method" },
    { "<leader>df", function() require("os").execute("python " .. vim.fn.expand("%")) end, desc = "Debug File" },  -- Simplified example
  },
}
```

**Example** (Debugging a Python file):
- Open a Python file, set a breakpoint.
- Press `<leader>df` to start debugging the current file.

#### C/C++ with codelldb or cppdbg

Use codelldb for LLDB-based debugging or cppdbg for VSCode-compatible.

**Example** (codelldb configuration):

```lua
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
    args = { "--port", "${port}" },
  },
}
dap.configurations.c = dap.configurations.cpp  -- Share config with C++
```

#### JavaScript/TypeScript with js-debug

Install js-debug-adapter via Mason.

**Example** (Basic config):

```lua
dap.adapters.node2 = {
  type = "executable",
  command = vim.fn.stdpath("data") .. "/mason/bin/node-debug2-adapter",
}
dap.configurations.javascript = {
  {
    type = "node2",
    request = "attach",
    name = "Attach to Node",
    port = 9229,  -- Common Node inspect port
  },
}
```

[Unverified] Some users report issues with attachment; starting the process with `--inspect` externally may help.

### Integrating DAP UI for Better Visualization

LazyVim often includes nvim-dap-ui for a graphical interface showing variables, stacks, etc.

Enable it with `{ import = "lazyvim.plugins.extras.ui.dap-ui" }` in extras.

**Example** (Auto-open UI):

```lua
return {
  "rcarriga/nvim-dap-ui",
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    dapui.setup()
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  end,
}
```

This opens the UI when a session starts.

### Keybindings in LazyVim

LazyVim provides default keybindings for DAP:

- `<leader>d` : Continue or start debugging.
- `<leader>db` : Toggle breakpoint.
- `<leader>du` : Toggle DAP UI.
- `<leader>dt` : Terminate session.

These can be customized in your plugin configs.

### Troubleshooting Common Issues

- **Adapter not found:** Ensure it's installed via `:Mason` and paths are correct in configs.
- **No configurations:** Check if language extras are imported.
- **Permission errors:** Run Neovim with sufficient privileges or check Mason logs.
- **Virtual environments (Python):** Specify the correct Python path for debugpy.
- [Speculation] Conflicts with other plugins may occur; disable extras temporarily to isolate.

Behavior may vary across operating systems (e.g., Windows may require additional setup for paths).

**Next Steps**
- Explore nvim-dap documentation for advanced features like remote debugging.
- Test with a simple project in your language of choice.
- Customize configurations for project-specific needs, such as launch.json equivalents.

---

