## Mason-nvim-dap Integration


### Overview

Mason-nvim-dap.nvim serves as a bridge between mason.nvim and nvim-dap, facilitating the management and configuration of debug adapters. It translates between Debug Adapter Protocol (DAP) names and Mason package names, enables automatic installation of adapters, and provides APIs for setup. This integration simplifies using DAP servers installed via Mason with nvim-dap for debugging in various languages. In LazyVim, it is commonly enabled through extras like dap.core, which configures nvim-dap along with related plugins for a streamlined debugging experience. Behavior may vary based on Neovim version, plugin updates, and system environment.

### Requirements

To use mason-nvim-dap.nvim effectively:

- Neovim version 0.7.0 or higher.
- mason.nvim for managing external tools.
- nvim-dap as the DAP client.

In LazyVim, these are typically handled through lazy.nvim plugin specifications. Additional dependencies may include language-specific plugins for enhanced configurations, such as nvim-dap-python for Python or nvim-dap-go for Go.

**Key Points**
- Ensure plugins are loaded in order: mason.nvim first, followed by mason-nvim-dap.nvim.
- For LazyVim users, enabling the dap.core extra via :LazyExtras installs and configures these components.
- System requirements may include build tools or runtimes for specific adapters (e.g., Python for debugpy).

### Installation

In LazyVim, integrate mason-nvim-dap.nvim by adding it as a dependency in your plugin configuration. Use the :LazyExtras command to enable the dap.core extra, which includes nvim-dap and mason-nvim-dap.nvim.

**Example**
```lua
return {
  {
    "mfussenegger/nvim-dap",
    recommended = true,
    desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras for some buffer local setup)",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      -- virtual text for the debugger
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
      -- mason.nvim integration
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "mason.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
          -- Makes a best effort to setup the various debuggers with
          -- reasonable debug configurations
          automatic_installation = true,
          -- You can provide additional configuration to the handlers,
          -- see mason-nvim-dap README for more information
          handlers = {},
          -- You'll need to check that you have the required things installed
          -- online, please don't ask me how to install them :)
          ensure_installed = {
            -- Update this to ensure that you have the debuggers for the langs you want
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>d", "", desc = "+debug", mode = { "n", "v" } },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },
    config = function()
      -- setup dap config here
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    -- stylua: ignore
    keys = {
      { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
    },
    opts = {},
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close({})
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close({})
      end
    end,
  },
}
```

After adding, run :Lazy to install. Restart Neovim for changes to take effect. Behavior may vary if conflicting plugins are present.

### Configuration Options

Configure mason-nvim-dap.nvim using its setup function. Key options include controlling automatic installation and custom handlers for adapters.

**Example**
```lua
require("mason-nvim-dap").setup({
  ensure_installed = { "python", "delve" },
  automatic_installation = true,
  handlers = {},
})
```

This setup installs the Python (debugpy) and Go (delve) adapters automatically and uses default handlers. For exclusion:
```lua
automatic_installation = { exclude = { "python" } }
```

**Key Points**
- `ensure_installed`: Array of DAP adapter names to install if missing.
- `automatic_installation`: Boolean or table to manage auto-install during DAP setup; may not install if dependencies are unmet.
- `handlers`: Table for custom adapter setup; an empty table enables default automatic configuration.

### Automatic Adapter Installation

Mason-nvim-dap.nvim can automatically install debug adapters via Mason when configuring nvim-dap. Use :DapInstall for manual installation or :DapUninstall to remove.

**Example**
To auto-install for Python:
```lua
require("mason-nvim-dap").setup({
  ensure_installed = { "python" },
  automatic_installation = true,
})
```
This maps "python" to the "debugpy" Mason package and installs it if not present. Check installation with :Mason.

### Custom Handlers

For advanced customization, define handlers to override default adapter configurations.

**Example**
```lua
require("mason-nvim-dap").setup({
  handlers = {
    function(config)
      -- Default fallback for unhandled adapters
      require('mason-nvim-dap').default_setup(config)
    end,
    python = function(config)
      config.adapters = {
        type = "executable",
        command = "/usr/bin/python3",
        args = { "-m", "debugpy.adapter" },
      }
      require('mason-nvim-dap').default_setup(config)
    end,
  },
})
```

This customizes the Python adapter while preserving defaults for others. Always call default_setup to maintain base functionality.

### Available Adapters

Mason-nvim-dap.nvim supports numerous adapters, mapped from DAP names to Mason packages. Common ones include:

- python → debugpy (Python debugging)
- delve → delve (Go debugging)
- codelldb → codelldb (C/C++/Rust via LLDB)
- js → js-debug (JavaScript/TypeScript)
- java → java-debug-adapter (Java, installed via LazyVim's lang.java extra)

Full mappings are available in the plugin's source files. [Unverified: Additional adapters may be added in future updates.]

### Language-Specific Examples

#### Python Debugging

Enable via ensure_installed. Add nvim-dap-python for enhanced features.

**Example**
```lua
{
  "mfussenegger/nvim-dap-python",
  dependencies = "mfussenegger/nvim-dap",
  ft = "python",
  config = function(_, opts)
    local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
    require("dap-python").setup(path)
  end,
}
```

Debug a Python file with <leader>dc to continue/launch.

#### Java Debugging

In LazyVim, enable the lang.java extra, which includes java-test and java-debug-adapter via Mason.

**Example**
Create a .vscode/launch.json for custom configs:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "java",
      "request": "launch",
      "name": "Launch with Args",
      "args": "one two three"
    }
  ]
}
```

Open a Java file and use <leader>dc to select and run the configuration. The DAP UI toggles with <leader>du.

Behavior may vary if multiple main methods exist, prompting a selection.

### Key Mappings

LazyVim's dap.core extra provides default mappings under <leader>d prefix:

- <leader>db: Toggle breakpoint
- <leader>dc: Continue/launch debugging
- <leader>di: Step into
- <leader>do: Step out
- <leader>dO: Step over
- <leader>du: Toggle DAP UI
- <leader>de: Evaluate expression

These can be customized in the plugin config. Mappings may not trigger if no active session exists.

### Debugging Workflow

1. Install adapters via Mason or automatically.
2. Set breakpoints with <leader>db.
3. Launch debugging with <leader>dc or <leader>da for arguments.
4. Use stepping commands to navigate code.
5. Inspect variables via DAP UI or REPL (<leader>dr).
6. Terminate with <leader>dt.

For language-specific workflows, refer to extras like lang.python or lang.java. Sessions may persist across files, but behavior can vary with complex projects.

**Conclusion**
This integration enhances debugging capabilities by leveraging Mason for tool management and nvim-dap for protocol handling, making it adaptable for multiple languages in LazyVim setups.

**Next Steps**
- Explore language-specific extras in LazyVim documentation.
- Test configurations in a sample project to observe behavior.
- Consult mason-nvim-dap.nvim GitHub for updates or issues.

---

