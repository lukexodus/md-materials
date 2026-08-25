## Watch Expressions and REPL


### Overview

In the context of debugging within Neovim using LazyVim, watch expressions and the REPL (Read-Eval-Print Loop) are key features provided by the nvim-dap-ui plugin, which integrates with nvim-dap (Debug Adapter Protocol). Watch expressions allow you to monitor the values of specific variables or expressions in real-time as your program executes, updating dynamically with changes in the program's state. The REPL serves as an interactive console for evaluating expressions, commands, or code snippets within the current debugging context, enabling quick testing and inspection during a debug session.

These tools enhance productivity by providing visual and interactive ways to inspect program behavior without constantly stepping through code. Behavior may vary based on the debug adapter (e.g., for Python, Go, or other languages) and system configuration, as different adapters may support expressions differently.

### Setting Up Debugging Environment

To use watch expressions and the REPL, ensure the debugging extras are enabled in LazyVim. This typically involves the following steps:

1. Install LazyVim if not already set up (it comes pre-configured with nvim-dap and nvim-dap-ui as optional extras).
2. Enable the relevant extras via the `:LazyExtras` command:
   - Select `dap.core` for core debugging support.
   - Select `ui.dap-ui` for the UI components, including watches and REPL.
   - Optionally, enable language-specific extras like `lang.python_debug` for Python debugging.
3. Install a debug adapter for your language (e.g., via Mason.nvim, which LazyVim integrates with automatic installation enabled by default).
4. Configure launch settings in `~/.config/nvim/lua/config/lazy.lua` or via adapter-specific files if needed.

Once set up, start a debug session with keybindings like `<leader>dc` (Continue) or `<leader>da` (Run with Args). The UI can be toggled with `<leader>du`.

**Key Points**
- Prerequisites: nvim-dap and nvim-dap-ui must be loaded; LazyVim handles this via extras.
- Automatic installation of adapters is enabled, but manual configuration may be required for complex setups.
- [Inference]: If the UI doesn't appear, check for conflicts with other plugins or ensure the debug session is active.

### Using Watch Expressions

Watch expressions are managed in the "Watches" element of nvim-dap-ui (Element ID: `watches`). This panel displays a list of user-defined expressions evaluated in the context of the current stack frame. Values update automatically as the program steps or hits breakpoints.

To interact:
- Open the DAP UI with `<leader>du`.
- In the Watches panel, enter insert mode to add a new expression (a prompt appears at the bottom).
- Press Enter to submit the expression.
- Expressions can be simple variables (e.g., `my_var`) or complex (e.g., `my_list[0] + 5`).
- The panel supports hierarchical display for complex types (e.g., objects or arrays).

Actions available in the Watches panel:
- Expand/Collapse: Toggle children of an expression.
- Edit: Modify the expression or set a child variable's value.
- Remove: Delete the expression.
- Send to REPL: Evaluate the expression in the REPL.

Default keymappings (configurable via nvim-dap-ui options):
- `e`: Edit expression or value.
- `<CR>` or left mouse click: Expand/collapse.
- `d`: Remove.
- `r`: Send to REPL.

LazyVim provides additional keybindings:
- `<leader>de`: Evaluate an expression (in normal or visual mode), which can be used to quickly add or test watches.

Behavior may vary; for instance, some adapters might not support editing values or complex expressions.

**Key Points**
- Expressions are evaluated per frame, so switching stacks updates values.
- Supports dynamic updates during stepping (e.g., via `<leader>dO` for Step Over).
- Use for monitoring loop counters, function returns, or conditional logic.

**Example**

Assume you're debugging a Python script with a list manipulation function using the debugpy adapter.

1. Set a breakpoint with `<leader>db`.
2. Start debugging with `<leader>dc`.
3. Open UI with `<leader>du`.
4. In Watches panel, enter insert mode and type `my_list.length` (assuming Python len(my_list); correct syntax per language).
5. Submit with Enter. The value (e.g., 5) appears and updates if the list changes.
6. Select the expression and press `e` to edit it to `sum(my_list)`.
7. Press `r` to send it to the REPL for further interaction.

**Output**

The Watches panel might display:

```
my_list.length = 5
sum(my_list) = 15
```

With expandable children if `my_list` is inspected.

### Using the REPL

The REPL (Element ID: `repl`) is an interactive console provided by nvim-dap, embedded in nvim-dap-ui. It allows evaluating expressions, executing debugger commands, or testing code in the current debug context. It's useful for ad-hoc queries without altering source code.

To use:
- Toggle the REPL with `<leader>dr`.
- Or open via DAP UI (`<leader>du`) and navigate to the REPL panel.
- Type expressions directly (e.g., `print(my_var)` in supported languages).
- Send items from other panels (e.g., variables from Scopes or expressions from Watches) using the `r` key.
- The REPL can float with `require("dapui").float_element("repl")` in Lua config.

Keymappings (shared with other elements):
- `e`: Edit values if applicable.
- `<CR>` or left click: Expand results.
- `o`: Jump to locations (e.g., if output references code).
- `d`: Remove items.
- `t`: Toggle states.

In LazyVim, additional REPL-related keys:
- `<leader>r`: Open REPL for package (language-specific).
- `<leader>R`: Open REPL for buffer.
- [Unverified]: Completion in REPL may require extra setup, as discussions suggest it's not enabled by default but can be configured.

Behavior may vary by adapter; for example, Rust via codelldb supports native expressions with `?/nat <expr>`.

**Key Points**
- Interactive: Immediate feedback on evaluations.
- Integration: Receives input from watches, scopes, or stack frames.
- Use cases: Test hypotheses, inspect hidden state, or run one-off commands.

**Example**

Continuing the Python debugging scenario:

1. During a paused session, toggle REPL with `<leader>dr`.
2. Type `my_var * 2` and press Enter; output shows the result (e.g., 10).
3. From Watches, select `sum(my_list)` and press `r` to send it; REPL evaluates and displays.
4. If output is a location, press `o` to jump to the code.

**Output**

REPL might show:

```
> my_var * 2
10
> sum(my_list)
15
```

### Advanced Usage and Integration

- **Combining Watches and REPL**: Use watches for persistent monitoring and REPL for ephemeral tests. Send watches to REPL for deeper inspection.
- **Floating Windows**: Open watches or REPL as floats for quick access without full UI: `require("dapui").float_element("watches", {width=50, height=20})`.
- **Customization**: In LazyVim, override configs in `lua/plugins/dap.lua`, e.g., change layouts or add autocompletion to REPL via plugins like cmp-dap.
- **Language-Specific Notes**: For Rust, use native expressions; for Python, leverage debugpy's full eval support. [Speculation]: Future updates might add built-in REPL completion.
- **Widgets**: Use `<leader>dw` for additional DAP widgets, which can complement watches.
- **Evaluation Shortcut**: `<leader>de` in visual mode selects code to eval directly, potentially adding to watches.

Integrate with other DAP features like breakpoints (`<leader>dB` for conditional) for targeted watching.

**Next Steps**
- Explore language-specific DAP adapters in LazyVim extras.
- Customize keymaps in `lua/config/keymaps.lua` for personalized workflow.
- Test in a sample project to observe adapter-specific behaviors.

---

