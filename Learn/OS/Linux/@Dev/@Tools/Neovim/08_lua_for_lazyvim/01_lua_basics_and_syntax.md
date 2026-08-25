## Lua Basics and Syntax


### Introduction to Lua

Lua is a lightweight, embeddable scripting language designed for extending applications. In the context of Neovim and LazyVim, Lua serves as the primary language for configuration, plugin management, and scripting custom behaviors. Neovim embeds LuaJIT (based on Lua 5.1 with extensions), allowing direct execution of Lua code via APIs like `vim.api.nvim_eval` or through configuration files. This integration enables users to customize keymaps, options, and autocmds without external tools. Syntax is simple and readable, drawing influences from languages like Scheme and Modula, with a focus on tables as the core data structure.

Key features include:
- Dynamic typing: Variables do not require type declarations.
- Garbage collection: Automatic memory management.
- First-class functions: Functions can be stored in variables or passed as arguments.
- Behavior may vary slightly between standard Lua and LuaJIT in Neovim, particularly in performance-critical code or FFI usage.

**Key Points**
- Lua is case-sensitive.
- Comments start with `--` for single-line or `--[[` for multi-line.
- Statements end with semicolons optionally; newlines often suffice.
- No strict typing, but values have types: nil, boolean, number, string, function, userdata, thread, table.

### Variables and Data Types

Variables in Lua are global by default unless declared with `local`. Assignment uses `=`, and multiple assignments are possible, e.g., `a, b = 1, 2`.

Basic types:
- **nil**: Represents absence of value.
- **boolean**: true or false; falsy values include nil and false, others are truthy.
- **number**: Double-precision floats; integers are represented as numbers.
- **string**: Immutable sequences, delimited by single or double quotes, or [[long brackets]] for multi-line.
- **table**: Associative arrays, used for arrays, dictionaries, objects.
- **function**: Code blocks that can be called.
- **userdata** and **thread**: Advanced, often used in Neovim APIs for Vim objects or coroutines.

In Neovim, tables are extensively used for options, e.g., `vim.opt` returns a table-like interface.

**Example**
```lua
local name = "Neovim"  -- string
local version = 0.9    -- number
local enabled = true   -- boolean
local config = {}      -- empty table
config.theme = "dark"  -- adding key-value
```

**Output**
No direct output, but printing via `print(name)` would show "Neovim". In Neovim, use `vim.print` for debugging.

### Operators

Lua supports arithmetic (`+`, `-`, `*`, `/`, `%`, `^`), relational (`==`, `~=`, `<`, `>`, `<=`, `>=`), logical (`and`, `or`, `not`), and concatenation (`..`). Length operator `#` works on strings and tables (for sequential parts).

Precedence follows standard math rules, with `^` highest, then `* / %`, `+ -`, etc. Parentheses override precedence.

In Neovim configs, operators are used in expressions like keymap conditions.

**Key Points**
- No increment/decrement like `++`.
- Equality `==` checks value, not reference for tables (use deep comparison if needed).
- Behavior of `#` on tables with holes (non-sequential keys) may not count all elements.

**Example**
```lua
local a = 5 + 3 * 2  -- 11
local b = "Neo" .. "vim"  -- "Neovim"
local c = #b  -- 6
local d = (a > 10) and "high" or "low"  -- "high"
```

### Control Structures

Lua provides if-then-else, while, repeat-until, and for loops. No switch statement; use if-elseif chains.

- **if**: `if condition then ... elseif ... else ... end`
- **while**: `while condition do ... end`
- **repeat**: `repeat ... until condition`
- **for**: Numeric `for i = start, end, step do ... end` or generic `for k, v in pairs(table) do ... end`

Breaks use `break`; no continue, but goto exists (use sparingly).

In LazyVim, these control flow in setup functions or autocmds.

**Example**
```lua
local num = 5
if num > 0 then
  print("positive")
elseif num < 0 then
  print("negative")
else
  print("zero")
end

for i = 1, 3 do
  print(i)
end
```

**Output**
Assuming execution: "positive" followed by 1, 2, 3.

### Functions

Functions are defined with `function name(params) ... end` or anonymously. They can return multiple values and accept variable arguments with `...`.

Closures capture outer variables. In Neovim, functions often define callbacks for plugins.

**Key Points**
- Parameters are local by default.
- Returns: `return val1, val2`
- Varargs: Access via `local args = {...}` or `select("#", ...)`
- Recursion is supported but may lead to stack limits in deep calls.

**Example**
```lua
local function add(x, y)
  return x + y
end

local sum = add(3, 4)  -- 7

local function varargs(...)
  local count = select("#", ...)
  return count
end

print(varargs(1, "a", true))  -- 3
```

### Tables

Tables are Lua's primary data structure, acting as arrays (1-based indexing), hashes, or modules.

Creation: `{}` or `{key = value}`. Access: `t.key` or `t["key"]`. Arrays use integer keys starting from 1.

Methods like `table.insert`, `table.remove`, `table.sort` manipulate them.

In Neovim, configurations like `require("lazy").setup({ ... })` use tables heavily.

**Key Points**
- Tables are references; assigning `a = b` shares the table.
- Metatables allow OOP-like behavior with `__index`, `__add`, etc.
- Iteration: `pairs` for all keys, `ipairs` for sequential.

**Example**
```lua
local opts = {
  number = true,
  relativenumber = true,
}

opts["cursorline"] = true  -- adding

for k, v in pairs(opts) do
  print(k, v)
end
```

**Output**
Prints keys and values, order not guaranteed for non-sequential.

### Strings and Patterns

Strings support escaping `\n`, `\t`, etc. Concatenation with `..`.

Pattern matching via `string.find`, `string.match`, `string.gmatch`, `string.gsub`. Patterns use `%` for classes like `%d` (digit), `%s` (space).

No regex like PCRE; simpler captures with `()`.

In Neovim, used for option patterns or command args.

**Example**
```lua
local str = "Hello, Neovim!"
local found = string.find(str, "Neo")  -- 8, 10 (start, end)

local replaced = string.gsub(str, "Neovim", "LazyVim")  -- "Hello, LazyVim!"
```

### Modules and Require

Modules are tables returned from files. `require("module")` loads and caches.

In LazyVim, `require("lazyvim.config.options")` loads configs.

Define: In file.lua: `local M = {} ... return M`

**Example**
```lua
-- In mymodule.lua
local M = {}
function M.greet() return "Hello" end
return M

-- Usage
local mod = require("mymodule")
print(mod.greet())
```

### Error Handling

Use `pcall(function, args)` for protected calls, returning status and result/error.

Assertions with `assert(condition, message)`.

In Neovim scripts, handle API errors gracefully.

**Key Points**
- Errors propagate unless caught.
- Behavior may vary in coroutines.

**Example**
```lua
local ok, res = pcall(function() error("oops") end)
if not ok then print(res) end  -- "oops"
```

### Coroutines

Coroutines for cooperative multitasking: `coroutine.create`, `coroutine.resume`, `coroutine.yield`.

Used in Neovim for async operations via plugins.

**Example**
```lua
local co = coroutine.create(function()
  coroutine.yield(1)
  return 2
end)

print(coroutine.resume(co))  -- true, 1
print(coroutine.resume(co))  -- true, 2
```

### Metatables and OOP

Metatables define behavior for operators, indexing. Set with `setmetatable(t, mt)`.

Simulate classes: Constructor returns table with metatable.

In advanced LazyVim plugins, used for custom types.

**Example**
```lua
local mt = { __add = function(a, b) return a.val + b.val end }
local obj1 = setmetatable({val = 5}, mt)
local obj2 = setmetatable({val = 3}, mt)
print(obj1 + obj2)  -- 8
```

### Best Practices

- Use `local` for variables to avoid globals.
- Prefer `ipairs` for arrays.
- Check types with `type(value)`.
- In Neovim, use `vim.fn` for Vimscript interop.
- Debug with `vim.inspect` in LazyVim.

[Inference: Lua 5.4 features like const may not be in LuaJIT, so stick to 5.1 compat.]

**Conclusion**
Lua's syntax emphasizes simplicity, making it ideal for Neovim scripting. Mastery of tables and functions unlocks powerful customizations.

**Next Steps**
- Practice in Neovim's `:lua` command.
- Explore LazyVim's Lua configs in `~/.config/nvim/lua`.
- Read official Lua manual for depth.

---

