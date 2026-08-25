## nvim-dap-ui for Visual Debugging


### Introduction

nvim-dap-ui is a user interface plugin designed to enhance the debugging experience in Neovim by providing visual elements for interacting with the Debug Adapter Protocol (DAP) via nvim-dap. It organizes debugging information into customizable windows and layouts, allowing users to inspect variables, manage breakpoints, navigate stack frames, and more without leaving the editor. In the context of LazyVim, nvim-dap-ui integrates seamlessly as part of the DAP Core extra, which sets up a ready-to-use debugging environment. Behavior may vary depending on the specific debugger adapter, Neovim version, and system configuration.

### Installation

To use nvim-dap-ui, it must be installed alongside nvim-dap and nvim-nio. In LazyVim, the easiest way is to enable the DAP Core extra, which bundles these plugins.

#### Enabling in LazyVim
- Open the LazyExtras menu with the command `:LazyExtras`.
- Search for and enable `dap.core`.
- Alternatively, add the following to your `lua/config/lazy.lua` file before the `require("lazy").setup(...)` call:
  ```lua
  require("lazyvim.util").extras.want("dap.core")
  ```
This extra installs and configures:
- `mfussenegger/nvim-dap` for core DAP support.
- `jay-babu/mason-nvim-dap.nvim` for managing debugger adapters via Mason.
- `rcarriga/nvim-dap-ui` with `nvim-neotest/nvim-nio` for the UI.
- `theHamsta/nvim-dap-virtual-text` for inline variable display.

For standalone installation outside LazyVim extras (e.g., custom setup):
```lua
{
  "rcarriga/nvim-dap-ui",
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-neotest/nvim-nio"
  }
}
```
Use a plugin manager like lazy.nvim to load this spec. Additionally, for type checking and autocompletion, integrate with lazydev.nvim:
```lua
require("lazydev").setup({
  library = { "nvim-dap-ui" },
})
```
Default icons rely on codicons; consider using a fork like ChristianChiarulli/neovim-codicons for better terminal compatibility, and patch your font if necessary.

Language-specific debuggers are managed via Mason; ensure they are installed for your target languages (e.g., `cppdbg` for C/C++).

### Configuration

nvim-dap-ui is configured via `require("dapui").setup(opts)`, where `opts` can customize layouts, elements, and more. In LazyVim's DAP Core extra, a default configuration is provided, including event listeners for automatic UI management.

#### Default LazyVim Configuration
The extra sets up:
```lua
local dap = require("dap")
local dapui = require("dapui")
dapui.setup({})
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open({})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close({})
end
```
This automatically opens the UI when a debug session starts and closes it on termination or exit. To modify this behavior (e.g., prevent auto-closing for inspecting post-crash states), override the listeners in a custom plugin file like `lua/plugins/dap.lua`:
```lua
return {
  {
    "rcarriga/nvim-dap-ui",
    opts = function(_, opts)
      local dap = require("dap")
      dap.listeners.before.event_terminated["dapui_config"] = nil
      dap.listeners.before.event_exited["dapui_config"] = nil
    end,
  },
}
```
Note: Overriding may cause session management issues in some cases; test thoroughly.

#### Custom Options
Key configuration options include:
- `layouts`: Array of layout definitions, each with `elements` (list of element IDs) and `position` (left, right, top, bottom).
- `floating`: Settings for floating windows, like mappings and border style.
- `icons`: Custom icons for expanded/collapsed states.
- `mappings`: Per-element keybindings for actions like edit (`e`), expand (`<CR>`), open (`o`), etc.

Example custom setup:
```lua
require("dapui").setup({
  layouts = {
    {
      elements = { "scopes", "breakpoints", "stacks", "watches" },
      size = 40,
      position = "left",
    },
    {
      elements = { "repl", "console" },
      size = 0.25,
      position = "bottom",
    },
  },
  floating = { max_height = nil, max_width = nil },
})
```
Behavior of layouts may vary based on window management plugins or Neovim splits.

### Key Features

nvim-dap-ui provides a modular UI with elements that can be grouped into layouts or displayed as floating windows. It supports interactive debugging actions via mappings.

**Key Points**
- **Modular Elements**: Scopes, stacks, watches, breakpoints, REPL, and console.
- **Layouts**: Customizable sidebars or trays for persistent display.
- **Floating Windows**: Temporary views for quick inspections.
- **Event Integration**: Hooks into nvim-dap events for automation.
- **Expression Evaluation**: Hover windows for evaluating code snippets.
- **Virtual Text**: Inline variable values via companion plugins.

### Elements and Widgets

Each element is a window displaying specific debug info with associated mappings (defaults: edit `e`, expand `<CR>`, open `o`, remove `d`, repl `r`, toggle `t`).

- **Scopes**: Shows variables in current scopes. Supports editing values and sending to REPL.
- **Stacks**: Displays threads and stack frames. Use `o` to jump to a frame; `<CR>` expands.
- **Watches**: Monitors user-defined expressions. Add via prompt in insert mode.
- **Breakpoints**: Lists all breakpoints with jump and toggle functionality.
- **REPL**: Interactive REPL from nvim-dap.
- **Console**: Integrated terminal for debug output.

To customize mappings per element:
```lua
element_mappings = {
  stacks = {
    open = "<CR>",
    expand = "o",
  },
}
```
This swaps defaults for easier navigation.

### Integration with nvim-dap

nvim-dap-ui relies on nvim-dap for core debugging. In LazyVim, adapters are handled via Mason, with configurations for languages like C/C++, Python, etc.

#### Adapter Setup Example (C/C++)
Install `cppdbg` via `:Mason`. Add to `lua/plugins/dap.lua`:
```lua
return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = { "cppdbg" },
    },
  },
}
```
Define configurations:
```lua
require("dap").configurations.c = {
  {
    name = "Launch file",
    type = "cppdbg",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopAtEntry = false,
  },
}
```
Similar setups apply for other languages.

### Usage

Control the UI manually:
- `require("dapui").open()`: Open all layouts.
- `require("dapui").close()`: Close all.
- `require("dapui").toggle()`: Toggle.

In LazyVim, use keymaps:
- `<leader>du`: Toggle Dap UI.
- `<leader>de`: Eval expression (normal/visual mode).
- `<leader>db`: Toggle breakpoint.
- `<leader>dc`: Run/Continue.
- `<leader>di`: Step into.
- `<leader>do`: Step over (may be `<leader>dO` in some configs).
- `<leader>dB`: Breakpoint condition.

For floating elements:
```lua
require("dapui").float_element("stacks", { width = 80, height = 20, enter = true })
```
Evaluate expressions:
```lua
require("dapui").eval("my_variable")
```
Uses cursor word if unspecified.

### Practical Examples

#### Debugging a C Program
1. Compile with debug symbols: `gcc -g main.c -o main`.
2. Set a breakpoint with `<leader>db`.
3. Start debugging with `<leader>dc`, select configuration.
4. UI opens automatically; inspect scopes, step with `<leader>di`.
5. Evaluate in watches or hover with `<leader>de`.

**Example**
Configuration for Python:
```lua
require("dap").configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    pythonPath = "/usr/bin/python",
  },
}
```
Run a script; UI shows variables and stack. Behavior may differ if virtual environments are used.

**Output**
During a session, the scopes element might display:
```
Local Scope
- var1: 42 (integer)
- str_var: "hello" (string)
```
Exact output depends on the debug adapter and program state.

### Customization

- Override icons or mappings in `setup` opts.
- Add virtual text: `require("nvim-dap-virtual-text").setup({})`.
- For stack frame switching, remap in `element_mappings` if defaults don't suit.
- [Unverified] Recent updates (post-2023) include better breakpoint handling and scope collapsing optimizations.

### Troubleshooting

- If UI closes unexpectedly on termination, check or remove event listeners.
- Ensure adapters are installed and paths are correct; errors may log in Neovim messages.
- For alignment issues, verify font and icon setup.
- Behavior may vary across debuggers; consult nvim-dap wiki for adapter-specific tips.

**Conclusion**
nvim-dap-ui transforms Neovim into a capable visual debugger, especially when integrated with LazyVim's DAP Core for streamlined setup and keymaps.

**Next Steps**
- Explore language-specific extras like `lang.python` for adapter auto-setup.
- Customize keymaps in `lua/config/keymaps.lua`.
- Refer to the nvim-dap-ui documentation for advanced layouts.

---

