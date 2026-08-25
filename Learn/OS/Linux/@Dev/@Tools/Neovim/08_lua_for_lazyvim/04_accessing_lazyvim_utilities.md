## Accessing LazyVim Utilities


### Overview

LazyVim includes a collection of utility functions and modules designed to simplify tasks such as plugin management, LSP interactions, formatting, root detection, and UI pickers. These utilities are primarily accessed through Lua code in configuration files, typically via `require("lazyvim.util")` or its sub-modules. The core utilities extend those from `lazy.core.util` and are dynamically loaded. Sub-modules provide specialized functionality and are loaded on demand via metatable logic. Availability and behavior can depend on the Neovim version, installed plugins, and system environment.

**Key Points**
- Utilities are modular and can be used in custom plugin specs or keymaps.
- Most functions are pure Lua and do not require additional setup beyond LazyVim.
- Sub-modules like `lsp` or `format` integrate with plugins such as `nvim-lspconfig` or `conform.nvim`.
- Dynamic loading may introduce minor performance variations on first access.

### Accessing Core Utilities

The main utilities are available after requiring the module:

```lua
local util = require("lazyvim.util")
```

This returns a table with functions and variables. Sub-modules are accessed similarly, e.g., `require("lazyvim.util.lsp")`. If a sub-module is not explicitly required, the metatable may load it automatically when referenced.

Dependencies include `lazy.core.util`, `lazy.core.config`, and others; ensure LazyVim is properly initialized.

### Core Utilities List

From the `lazyvim.util` module:

- **is_win()**: Returns a boolean indicating if the OS is Windows. No parameters.
- **get_plugin(name)**: Retrieves the plugin spec for the given name (string). Returns table or nil.
- **get_plugin_path(name, path?)**: Constructs the full path to a plugin resource. Parameters: name (string), optional path (string). Returns string or nil.
- **has(plugin)**: Checks if a plugin is registered. Parameter: plugin (string). Returns boolean.
- **has_extra(extra)**: Checks if an extra module is enabled. Parameter: extra (string). Returns boolean.
- **on_very_lazy(fn)**: Defers a function until the VeryLazy event. Parameter: fn (function).
- **extend(t, key, values)**: Extends a nested list in a table using dot-notation. Parameters: t (table), key (string), values (table). Returns extended table or nil.
- **opts(name)**: Gets options for a plugin. Parameter: name (string). Returns table.
- **deprecate(old, new, opts?)**: Issues a deprecation warning. Parameters: old (string), new (string), optional opts (table).
- **lazy_notify()**: Buffers notifications until vim.notify is ready or a timeout occurs.
- **is_loaded(name)**: Checks if a plugin is loaded. Parameter: name (string). Returns boolean.
- **on_load(name, fn)**: Runs a function when a plugin loads. Parameters: name (string), fn (function).
- **safe_keymap_set(mode, lhs, rhs, opts)**: Safer wrapper for vim.keymap.set, forcing silent and handling conflicts. Parameters: mode (string or table), lhs, rhs, optional opts (table).
- **dedup(list)**: Removes duplicates from a list while preserving order. Parameter: list (table). Returns table.
- **CREATE_UNDO**: A string constant used as an undo marker, generated via vim.api.nvim_replace_termcodes.

[Inference]: Additional fields may be inherited from lazy.core.util if not overridden.

### LSP Utilities

Accessed via `require("lazyvim.util.lsp")`. Focuses on LSP formatting and actions.

- **formatter(opts?)**: Creates a formatter config for tools like conform.nvim. Optional parameter: opts (table with filter).
- **format(opts?)**: Formats the current buffer using LSP or conform.nvim. Optional parameter: opts (table with timeout_ms, etc.). Behavior varies if conform.nvim is installed.
- **action**: A table for dynamic LSP code actions, e.g., action["source.organizeImports"](). Uses metatable for access.
- **execute(opts)**: Executes an LSP workspace command. Parameter: opts (table with command, arguments, optional open and handler). May use trouble.nvim if open is true.

Dependencies: vim.lsp, LazyVim for options merging, optionally conform.nvim and trouble.nvim.

### Picker Utilities

Accessed via `require("lazyvim.util.pick")`. Handles file and command selection, often integrating with telescope.nvim or similar.

- **picker**: Variable holding the registered picker instance (LazyPicker type).
- **register(picker)**: Registers a picker. Parameter: picker (table). Returns boolean.
- **open(command?, opts?)**: Opens the picker. Parameters: optional command (string, defaults to "files"), optional opts (table with cwd, root, etc.).
- **wrap(command?, opts?)**: Returns a function to open the picker later. Parameters same as open.
- **config_files()**: Returns a function to open a picker in the Neovim config directory.

Dependencies: LazyVim for warnings and root detection, vim for deepcopy and stdpath.

**Example**

To open a file picker:

```lua
local pick = require("lazyvim.util.pick")
pick.open("files", { cwd = vim.fn.getcwd() })
```

This may display a UI for file selection, depending on the registered picker (e.g., telescope).

### Format Utilities

Accessed via `require("lazyvim.util.format")`. Manages buffer formatting.

- **formatters**: Array of registered LazyFormatter objects.
- **register(formatter)**: Adds and sorts a formatter by priority. Parameter: formatter (table).
- **formatexpr()**: Returns a formatexpr function, preferring conform.nvim if available.
- **resolve(buf?)**: Resolves active formatters for a buffer. Optional parameter: buf (number). Returns table array.
- **info(buf?)**: Displays formatter info. Optional parameter: buf (number).
- **enabled(buf?)**: Checks if autoformat is enabled. Optional parameter: buf (number). Returns boolean.
- **toggle(buf?)**: Toggles autoformat. Optional parameter: buf (boolean for buffer-local).
- **enable(enable?, buf?)**: Sets autoformat state. Parameters: optional enable (boolean), optional buf (boolean).
- **format(opts?)**: Runs formatting. Optional parameter: opts (table with force, buf).
- **health()**: Checks for configuration issues, e.g., none-ls.nvim presence.
- **setup()**: Initializes autocmds and commands for formatting.
- **snacks_toggle(buf?)**: Creates a toggle for UI plugins like Snacks. Optional parameter: buf (boolean).

Dependencies: LazyVim, vim.api, optionally conform.nvim.

**Example**

To manually format a buffer:

```lua
local format = require("lazyvim.util.format")
format.format({ force = true })
```

**Output**

If successful, the buffer contents are formatted in place. If no formatters are active, a warning may appear via LazyVim.warn.

### Root Detection Utilities

Accessed via `require("lazyvim.util.root")`. Detects project roots.

- **spec**: Default root specs array, e.g., { "lsp", { ".git", "lua" }, "cwd" }.
- **detectors**: Table of detector functions: cwd(), lsp(buf), pattern(buf, patterns).
- **bufpath(buf)**: Gets buffer's real path. Parameter: buf (number).
- **cwd()**: Gets current working directory's real path.
- **realpath(path)**: Resolves path. Optional parameter: path (string).
- **resolve(spec)**: Resolves spec to a detector function. Parameter: spec (table or string or function).
- **detect(opts?)**: Detects roots. Optional parameter: opts (table with buf, spec, all).
- **info()**: Displays detected roots info.

Dependencies: vim.uv, vim.lsp, LazyVim.norm and info.

**Example**

To get the project root:

```lua
local root = require("lazyvim.util.root")
local roots = root.detect()
print(roots[1].paths[1])  -- Prints the detected root path
```

### Plugin Utilities

Accessed via `require("lazyvim.util.plugin")`. Handles plugin config migrations.

- **deprecated_extras**: Table mapping deprecated extras to warnings.
- **renamed_extras**: Table for renamed extras.
- **deprecated_modules**: Empty table for deprecated modules.
- **renames**: Table for renamed plugin repos.
- **save_core()**: Saves core imports if not in UI.
- **setup()**: Initializes handling for imports, renames, LazyFile.
- **extra_idx(name)**: Finds index of an extra. Parameter: name (string).
- **lazy_file()**: Adds LazyFile event support.
- **fix_imports()**: Handles deprecated/renamed extras in imports.
- **fix_renames()**: Handles plugin renames.

Dependencies: lazy.core.config, LazyVim for warnings and injections.

### Other Sub-modules

LazyVim includes additional sub-modules loaded dynamically:
- **treesitter**: Likely for Tree-sitter operations.
- **terminal**: For terminal management.
- **extras**: For extra plugin handling.
- **inject**: For argument injection.
- **news**: For news or changelog.
- **json**: For JSON utilities.
- **lualine**: For statusline integration.
- **mini**: For mini.nvim wrappers.
- **cmp**: For completion utilities.

[Unverified]: Exact functions in these may vary; refer to source for details.

Access them similarly, e.g., `require("lazyvim.util.treesitter")`.

### Usage in Configuration

Utilities are commonly used in `lua/plugins/*.lua` or `lua/config/*.lua`. For example, check plugin presence before adding keymaps:

```lua
local util = require("lazyvim.util")
if util.has("telescope.nvim") then
  -- Add telescope-specific config
end
```

Behavior may differ if plugins are lazy-loaded.

### Troubleshooting

- If a utility returns unexpected results, check dependencies with `:Lazy check`.
- Warnings may appear for deprecated items; update configs accordingly.
- For root detection issues, customize `vim.g.root_spec`.

**Conclusion**

These utilities enhance LazyVim's extensibility, allowing fine-tuned configurations without redundant code.

**Next Steps**

- Review the LazyVim GitHub source for updates.
- Experiment in a config file with require statements.
- Integrate with custom plugins for advanced setups.

---

