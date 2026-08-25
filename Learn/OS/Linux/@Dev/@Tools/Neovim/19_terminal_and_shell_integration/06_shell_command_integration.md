## Shell Command Integration


### Overview of Shell Commands

Shell command integration allows executing external commands from within the editor, capturing output, or interacting with the system shell. Neovim provides built-in mechanisms for this, enhanced by Lua APIs and plugins. This enables workflows like compiling code, formatting files, or querying system info without leaving the editor.

Core features include the `:!` command for one-off executions and terminal emulation for interactive sessions. In LazyVim, plugins like toggleterm.nvim extend this with floating or split terminals.

**Key Points**
- Commands run in the system's default shell (e.g., bash, zsh).
- Output can be displayed in quickfix, captured to registers, or inserted into buffers.
- Asynchronous execution via jobs prevents blocking the editor.
- Behavior may vary by operating system, shell configuration, or Neovim version (e.g., vim.system() introduced in 0.10).

### Built-in Command Execution

Neovim's ex-mode commands handle basic shell integration. Use `:!command` to run a command and display output in a pager-like view.

For filtering text: Select lines visually, then `:!sort` to sort them via the shell.

To capture output: `:r !command` reads output into the current buffer.

**Example**
To list directory contents and insert below cursor:
```
:r !ls -la
```

**Output**
The buffer might show:
```
total 8
drwxr-xr-x  2 user user 4096 Jan  4 14:30 .
drwxr-xr-x 10 user user 4096 Jan  4 14:30 ..
-rw-r--r--  1 user user    0 Jan  4 14:30 file.txt
```

For background execution, use `:silent !command &` to avoid pausing.

Note that long-running commands may block unless asynchronous APIs are used.

### Terminal Emulation

Neovim's `:terminal` opens an interactive shell in a buffer. Navigate with `<C-\><C-n>` to enter normal mode.

In LazyVim, this is accessible via keymaps or commands. Buffers are editable but treat terminal content specially.

**Example**
```
:terminal
```
Opens a shell. Run commands like `git status`, then exit with `exit`.

For splits: `:split | terminal` or `:vsplit | terminal`.

Terminals support job control, with `chansend()` for sending input programmatically.

[Inference]: Based on documentation, terminals persist job state across sessions if not closed.

### Asynchronous Execution with Lua API

Lua provides `vim.fn.system()` for synchronous calls and `vim.system()` (Neovim 0.10+) for async.

`vim.system(cmd, opts, callback)` runs commands non-blockingly, with options for stdin, env, cwd.

**Example**
```lua
-- Run 'echo hello' asynchronously
vim.system({'echo', 'hello'}, { text = true }, function(obj)
  if obj.code == 0 then
    print("Output: " .. obj.stdout)
  else
    print("Error: " .. obj.stderr)
  end
end)
```

**Output**
Prints "Output: hello\n" in the message area.

For older Neovim, use `jobstart()` with channels.

This is useful in plugins or autocmds, like auto-formatting on save.

### ToggleTerm Plugin Integration

Toggleterm.nvim, available as a LazyVim extra, manages multiple terminals with toggling, floating windows, and custom commands.

Enable in `lua/config/lazy.lua` via extras: `{ "LazyVim/LazyVim", import = "lazyvim.plugins.extras.util.toggleterm" }`.

It provides `<leader>tt` to toggle the main terminal.

**Example Configuration**
```lua
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 20,  -- Height for horizontal splits
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float",  -- 'vertical' | 'horizontal' | 'tab' | 'float'
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    },
  },
}
```

Run custom terminals: `:ToggleTerm cmd="git log" direction=vertical`.

### Sending Commands to Terminals

With toggleterm, send lines or selections to a running terminal.

Keymaps: `<leader>ts` to send selection, `<leader>tl` for current line.

**Example**
In a code buffer, select code, press `<leader>ts` to execute in the open terminal (e.g., for REPLs like Python).

This supports lazygit integration: Toggleterm launches lazygit in a float.

For other plugins, like overseer.nvim (task runner), shell commands are defined in tasks.

### Capturing and Processing Output

To process shell output in Lua: Use `vim.system()` and parse stdout.

For quickfix integration: `:cexpr system('grep pattern files')` populates quickfix with results.

**Example**
```lua
-- Grep and open quickfix
local output = vim.fn.system('grep -n "TODO" *.lua')
vim.fn.setqflist({}, 'r', { title = 'TODOs', lines = vim.split(output, '\n') })
vim.cmd('copen')
```

This lists matches in quickfix for navigation.

[Unverified]: Some shells may require escaping special characters in commands.

### Advanced Workflows

Integrate with LSP: Formatters like black use shell commands via null-ls or conform.nvim.

In LazyVim, conform.nvim handles this: Define shell-based formatters in config.

For testing: Run shell tests via `:make` or plugins like vim-test, which execute commands and parse output.

Security note: Avoid untrusted input in system calls to prevent injection.

[Speculation]: Future plugins may enhance AI-assisted command generation.

### Potential Issues and Troubleshooting

- Blocking: Use async methods for long commands.
- Encoding: Output may garble with mismatched locales; set `encoding=utf-8`.
- Permissions: Commands failing due to perms show in stderr.
- Plugin conflicts: Multiple terminal managers may overlap keymaps.

Check `:messages` or plugin logs for errors.

**Next Steps**
- Add toggleterm to your LazyVim setup and test with a REPL.
- Explore overseer.nvim for task management.
- Customize keymaps for frequent commands.

**Conclusion**
Shell command integration in LazyVim combines Neovim's core features with plugins for flexible execution and interaction. This supports diverse workflows, from quick queries to complex builds, though effectiveness depends on configuration and environment specifics.

---

### Overview of REPL Workflows in Neovim

The Read-Eval-Print Loop (REPL) constitutes an interactive programming environment that facilitates immediate code execution, evaluation, and feedback, thereby enhancing development productivity through iterative experimentation. In Neovim, REPL integration enables developers to dispatch code segments from the editor to an external or embedded interpreter without disrupting the workflow. This integration is particularly advantageous for data science, scripting, and debugging across multiple languages. Neovim accomplishes this via specialized plugins that manage REPL sessions, often utilizing terminal buffers or splits for interaction. The following delineates key plugins and language-specific configurations, predicated on prevalent implementations.

### Principal Plugins for REPL Management

Several plugins furnish robust REPL capabilities in Neovim, each with distinct emphases on flexibility, language support, and user interface. These are amenable to integration within configurations such as LazyVim via the `:LazyExtras` command or direct specification in `lua/plugins.lua`.

#### iron.nvim
This plugin furnishes an interactive REPL interface, permitting code transmission from the active buffer to a designated interpreter while preserving focus. It accommodates static and dynamic REPL definitions, with optional integration to Debug Adapter Protocol (DAP) sessions.

- **Supported Languages and REPLs**: Shell (e.g., zsh), Python (python3, ipython), Haskell (via cabal or ghci), and custom configurations for others.
- **Installation**: Incorporate via lazy.nvim:
  ```lua
  { "Vigemus/iron.nvim", config = function() require("iron.core").setup({ ... }) end }
  ```
- **Configuration Options**: Define REPLs in `config.repl_definition` (e.g., command arrays, formatters for bracketed pasting); customize window openings (splits or floats); establish keymaps for actions such as sending motions or files.
- **Usage**: Initiate with `:IronRepl` or keymaps (e.g., `<space>sc` for sending motions). For Python, transmit a selection and observe output in the REPL split.

#### yarepl.nvim
This versatile plugin administers multiple REPL sessions concurrently, supporting diverse sending paradigms and cross-language workflows, inclusive of AI integrations.

- **Supported Languages and REPLs**: Python (ipython, python), R (radian, R), Bash, Zsh, and AI tools (Aider, OpenAI Codex); extensible to others via custom metadata.
- **Installation**: Via lazy.nvim:
  ```lua
  { "milanglacier/yarepl.nvim", config = true }
  ```
- **Configuration Options**: Specify REPL metadata (commands, formatters); adjust buffer behaviors (e.g., `buflisted`, `wincmd` for splits); enable project-level overrides and tmux persistence.
- **Usage**: Commence with `:REPLStart` (e.g., `:REPLStart ipython`); transmit visuals via `<Plug>(REPLSendVisual)`. For R, attach a buffer and dispatch code blocks.

#### nvim-repl
This plugin facilitates the creation and management of interactive REPLs, with inherent support for numerous interpreters and seamless AI incorporation.

- **Supported Languages and REPLs**: Bash, IPython (Python), Node (JavaScript), R, Sh, Utop (OCaml), Zsh, Aider (AI), and Neovim's internal Lua.
- **Installation**: Via lazy.nvim:
  ```lua
  { "pappasam/nvim-repl", config = function() require("nvim-repl").setup({ ... }) end }
  ```
- **Configuration Options**: Define filetype-specific commands; establish defaults (e.g., bash); customize window openings and keybindings for transmissions.
- **Usage**: Invoke with `:Repl` or equivalents; for JavaScript, configure `deno repl` and transmit lines via keymaps.

#### pyrola.nvim
Oriented toward data science, this plugin leverages Jupyter kernels for multi-language REPLs, featuring variable inspection and image previews.

- **Supported Languages and REPLs**: Python, R, C++ (via kernels like ipykernel, IRkernel, xcpp); extensible to any Jupyter-supported language.
- **Installation**: Prerequisites include Python/Jupyter setups; then via lazy.nvim:
  ```lua
  { "matarina/pyrola.nvim", dependencies = { "nvim-treesitter/nvim-treesitter" }, build = ":UpdateRemotePlugins", config = function() require("pyrola").setup({ ... }) end }
  ```
- **Configuration Options**: Map filetypes to kernels; adjust splits (orientation, ratio); define keys for transmissions and inspections.
- **Usage**: Initialize with `:Pyrola init`; transmit blocks with `<CR>` or visuals with `<leader>vs`. For C++, inspect variables post-execution.

### Language-Specific REPL Workflows

#### Python
Employ ipython for enriched features. With iron.nvim or yarepl.nvim, configure `command = {"ipython"}` and transmit code via keymaps. Pyrola furnishes Jupyter-based execution with image support. Workflow: Edit code, select, send, and review outputs in the REPL buffer.

#### R
Utilize radian or base R. Iron.nvim and yarepl.nvim support dispatching to radian for enhanced completion. In pyrola, map to IRkernel for notebook-like interactions. Workflow: Attach buffer, send selections, inspect environments.

#### Julia
Configure iron.nvim with `julia` command or employ the tunnell plugin alongside tmux for seamless integration. Workflow: Launch REPL in a split, transmit functions or selections for evaluation.

#### JavaScript/TypeScript
Adopt node or deno REPL via nvim-repl or iron.nvim (e.g., `command = {"node"}`). Workflow: Send modules or expressions, leveraging Neovim's terminal for outputs.

#### Lua
Neovim's embedded Lua supports REPL-like via `:lua` commands. For fuller sessions, use iron.nvim with luajit or nvim-repl's internal nvim REPL. Workflow: Execute snippets directly or in a dedicated buffer.

#### C++
Pyrola supports xcpp kernels; alternatively, lila.nvim provides live REPL. Workflow: Compile and evaluate blocks, with outputs including images if applicable.

#### Haskell
Define ghci or cabal REPL in iron.nvim (dynamic commands for project files). Workflow: Send definitions to the interpreter for type checking and execution.

These workflows can be tailored further through Neovim's autocmds or additional plugins like nvim-treesitter for semantic selections. For specialized requirements, consult plugin documentation to ensure compatibility with your environment.

---

