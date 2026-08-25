## Breakpoints and Conditional Breakpoints


### Introduction

In Neovim, particularly within the LazyVim configuration, debugging is facilitated through the nvim-dap plugin, which integrates with the Debug Adapter Protocol (DAP). This allows for setting breakpoints to pause execution at specific points in code, inspecting variables, and stepping through logic. Conditional breakpoints extend this by pausing only when certain conditions are met, reducing unnecessary stops during debugging sessions. LazyVim preconfigures nvim-dap with keymaps and UI enhancements via nvim-dap-ui, making it accessible for languages like Python, JavaScript, and others via adapters.

Behavior may vary based on the installed debug adapter, Neovim version, and project setup. For instance, adapters like debugpy for Python or vscode-js-debug for JavaScript handle breakpoints differently.

**Key Points**
- Breakpoints are visual markers in the editor that halt program execution.
- Conditional breakpoints evaluate expressions and pause only if true.
- LazyVim uses leader keys (e.g., \<leader\>d) for common debugging actions.
- Requires installing language-specific DAP adapters via Mason or manually.
- Integration with telescopes for breakpoint management in larger projects.

### Installing and Configuring DAP in LazyVim

LazyVim includes nvim-dap by default, but adapters must be set up. Use :Lazy to check plugins, and install adapters with :Mason.

For configuration, edit `lua/config/lazy.lua` or use extras. A basic setup might involve requiring 'dap' and defining adapters.

**Example**
```lua
-- In lua/plugins/dap.lua or similar
return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      dap.adapters.python = {
        type = "executable",
        command = "python",
        args = { "-m", "debugpy", "adapter" },
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function() return "/usr/bin/python" end,
        },
      }
    end,
  },
}
```
Reload Neovim after changes. This sets up Python debugging; adapt for other languages.

### Setting Basic Breakpoints

To set a breakpoint, place the cursor on a line and use the keymap \<leader\>db (toggle breakpoint). A sign (often a red dot) appears in the sign column.

Breakpoints persist across sessions if using persistent breakpoints via nvim-dap configurations.

To list all breakpoints, use \<leader\>dB or Telescope integration if enabled.

**Example**
1. Open a Python file in Neovim.
2. Navigate to a line, e.g., inside a function.
3. Press \<leader\>db to set the breakpoint.
4. Start debugging with \<leader\>dh (continue) or F5.

**Output**
The debugger pauses at the line, opening the DAP UI with variables, call stack, and consoles. Signs update dynamically.

Behavior may vary; for example, in some adapters, breakpoints on blank lines are ignored.

### Conditional Breakpoints

Conditional breakpoints pause only if an expression evaluates to true. Set them via \<leader\>dC or by editing existing breakpoints.

In nvim-dap, conditions are language-specific expressions, like `x > 5` in Python.

Hit counts can also be used, pausing after a breakpoint is hit N times.

**Key Points**
- Expressions must be valid in the debugged language's syntax.
- Supports ignore counts (hit a breakpoint N times before pausing).
- Edit conditions via the DAP REPL or UI.
- Useful for loops or frequently called functions to avoid constant pausing.

**Example**
1. Set a basic breakpoint with \<leader\>db.
2. Place cursor on it and press \<leader\>dC.
3. Enter a condition, e.g., `len(my_list) == 3` for Python.
4. Alternatively, in Lua config:
```lua
dap.set_breakpoint(nil, nil, "len(my_list) == 3")  -- Condition as third arg
```
Or interactively via vim.fn.input.

For hit count: Use `dap.set_breakpoint(nil, "10")` to pause after 10 hits.

**Output**
During debugging, execution pauses only when the condition holds. The UI shows the evaluated condition if supported by the adapter.

[Inference] In complex setups, performance may degrade with many conditions due to evaluation overhead.

### Managing Breakpoints

Use \<leader\>dB to toggle or clear all. For advanced management, integrate with telescope-dap.nvim.

Clear all with `dap.clear_breakpoints()` in the REPL.

Export/import breakpoints for sharing or version control, though not built-in—use custom scripts.

**Example**
```lua
-- In a custom keymap
vim.keymap.set("n", "<leader>dX", function()
  require("dap").clear_breakpoints()
  print("All breakpoints cleared")
end)
```

### Integration with Other Tools

LazyVim pairs DAP with nvim-dap-ui for visual panels and virtual text for inline variable display.

For testing, combine with neotest for test-specific breakpoints.

In version control, avoid committing breakpoint files unless project-specific.

**Key Points**
- UI auto-opens on debug start; customize in config.
- Virtual text shows variable values near code.
- Adapters may support log points (log messages without pausing).

### Troubleshooting Common Issues

- Breakpoint not hitting: Check adapter config, ensure program launched correctly.
- Conditions failing: Verify syntax; test in REPL.
- Signs missing: Ensure 'signs' enabled in dap config.
- Adapter errors: Install dependencies, e.g., debugpy via pip.

Behavior may vary across Neovim versions or plugin updates; check :checkhealth dap.

[Unverified] As of early 2026, nvim-dap v0.7+ improves conditional support for more languages.

### Advanced Usage

For scripted breakpoints, use `dap.listeners` to automate.

In multi-threaded apps, set thread-specific conditions.

Combine with overseer.nvim for task-based debugging.

**Example**
```lua
-- Auto-set conditional breakpoint
local dap = require("dap")
dap.listeners.after.event_initialized["my_listener"] = function()
  dap.set_breakpoint("x > 10", nil, nil, { log_message = "x exceeded 10" })
end
```

**Conclusion**
Breakpoints and conditional breakpoints in Neovim via LazyVim enhance debugging efficiency by allowing precise control over execution flow. They integrate seamlessly with the editor's ecosystem, supporting a wide range of languages.

**Next Steps**
- Install a language adapter and test a simple script.
- Explore nvim-dap documentation for adapter-specific features.
- Customize keymaps in `lua/config/keymaps.lua` for workflow optimization.

---

