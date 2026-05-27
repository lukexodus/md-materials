# Neovim + LazyVim (Omarchy) — Concepts & Terms Reference

> A complete map of everything you need to know, from Vim fundamentals to LazyVim configuration. Each section builds on the last.

---

## 1. Vim Modes

The most foundational concept. Neovim is _modal_ — the same keys do different things depending on the current mode.

|Mode|How to enter|What it does|
|---|---|---|
|**Normal**|`Esc` / `Ctrl-[`|Navigate, run operators. The default mode.|
|**Insert**|`i`, `a`, `o`, `I`, `A`, `O`, `s`, `c`|Type text.|
|**Visual**|`v` (char), `V` (line), `Ctrl-v` (block)|Select text visually.|
|**Visual-line**|`V`|Select whole lines.|
|**Visual-block**|`Ctrl-v`|Select a column rectangle.|
|**Command-line**|`:`|Run Ex commands (`:w`, `:q`, `:s`, etc.).|
|**Search**|`/` (forward), `?` (backward)|Live-search the buffer.|
|**Replace**|`R`|Overwrite characters like a typewriter.|
|**Operator-pending**|After `d`, `y`, `c`, etc.|Waiting for a motion or text object.|
|**Terminal**|`:terminal` then `i`|Shell inside a Neovim buffer.|

---

## 2. Motions

Motions move the cursor. They also define the _range_ when combined with operators.

### Character / word

```
h j k l       — left, down, up, right
w / b         — next/prev word start (punctuation-aware)
W / B         — next/prev WORD start (whitespace only)
e / ge        — next/prev word end
E / gE        — next/prev WORD end
```

### Line

```
0             — start of line (column 0)
^             — first non-blank character
$             — end of line
g_            — last non-blank character
%             — matching bracket / paren / brace
```

### Screen

```
H / M / L    — top / middle / bottom of screen
Ctrl-d / u   — half-page down / up
Ctrl-f / b   — full page forward / backward
zz / zt / zb — center / top / bottom current line on screen
```

### File

```
gg / G        — file start / file end
:{n}          — go to line n  (e.g. :42)
{n}G          — go to line n  (e.g. 42G)
```

### Search motions

```
f{c} / F{c}  — jump to next/prev occurrence of char c on current line
t{c} / T{c}  — jump just before/after char c
; / ,        — repeat f/t forward / backward
/{pattern}   — search forward (regex)
?{pattern}   — search backward
n / N        — next / previous search match
* / #        — search word under cursor forward / backward
```

### Jumplist

```
Ctrl-o        — jump back (older position)
Ctrl-i        — jump forward (newer position)
```

---

## 3. Operators

Operators perform an action on the text defined by the motion or text object that follows.

```
d    — delete (cut)
y    — yank (copy)
c    — change (delete + enter Insert mode)
>    — indent right
<    — indent left
=    — auto-indent / format
~    — toggle case
g~   — toggle case (motion-based)
gu   — lowercase
gU   — uppercase
!    — filter through external program
```

**Pattern:** `{operator}{motion}` — e.g. `dw` deletes a word, `y$` yanks to end of line, `c3j` changes three lines down.

**Doubling an operator acts on the current line:** `dd` deletes the line, `yy` yanks it, `cc` changes it.

---

## 4. Text Objects

Text objects describe a _semantic unit_ of text. Always used after an operator.

|Prefix|Meaning|
|---|---|
|`i`|_inner_ — excludes surrounding whitespace or delimiters|
|`a`|_around_ — includes surrounding whitespace or delimiters|

|Object|What it selects|
|---|---|
|`w`|word|
|`W`|WORD (whitespace-delimited)|
|`s`|sentence|
|`p`|paragraph|
|`(` or `)` or `b`|parentheses block|
|`[` or `]`|bracket block|
|`{` or `}` or `B`|brace block|
|`<` or `>`|angle-bracket block|
|`'`|single-quoted string|
|`"`|double-quoted string|
|`` ` ``|backtick string|
|`t`|XML/HTML tag block|

**Examples:** `diw` (delete inner word), `ca"` (change around double-quotes), `yi(` (yank inside parens), `vat` (visually select around tag).

---

## 5. Registers

Registers are named slots for storing yanked/deleted text, macros, and more.

|Register|Purpose|
|---|---|
|`"` (unnamed)|Default — last `d`, `c`, `s`, `x`, or `y`|
|`0`|Last explicit yank (`y` only)|
|`1`–`9`|History of deletes (1 = most recent)|
|`a`–`z`|Named — use deliberately: `"ayy` yanks into `a`|
|`A`–`Z`|Appends to the corresponding lowercase register|
|`+`|System clipboard|
|`*`|Primary selection (X11 / Wayland middle-click)|
|`%`|Current filename|
|`#`|Alternate filename|
|`/`|Last search pattern|
|`:`|Last command-line command|
|`=`|Expression register — evaluates Lua/Vim expressions|
|`_`|Black hole — discards text|

**Usage:** `"ayw` yanks a word into register `a`. `"ap` pastes it. In Insert mode, `Ctrl-r a` inserts the contents of register `a`.

---

## 6. The Dot Command and Counts

- **`.`** repeats the last change (the last thing done in Insert or Normal mode that modified text).
- **Count prefix** multiplies a motion or operator: `3w` moves three words, `5dd` deletes five lines, `2yy` yanks two lines.

The dot command is the single highest-leverage habit in Vim. Build changes that are repeatable.

---

## 7. Marks

Marks are bookmarks inside files.

```
m{a-z}   — set local mark (within the file)
m{A-Z}   — set global mark (works across files)
`{mark}  — jump to exact position of mark
'{mark}  — jump to first non-blank of mark's line
``       — jump back to position before last jump
''       — jump back to line before last jump
```

Useful built-in marks: `` `[ `` / `` `] `` (start/end of last change or yank), `` `< `` / `` `> `` (start/end of last visual selection).

---

## 8. Macros

Macros record a sequence of keystrokes into a register and replay it.

```
q{a-z}   — start recording into register {a-z}
q        — stop recording
@{a-z}   — play macro in register {a-z}
@@       — replay the last-run macro
{n}@{a}  — play macro n times
```

Tip: edit a macro by yanking its register (`"ap`), fixing the text, then yanking it back (`"ayy` / `0"ay$`).

---

## 9. Ex Commands (Command-line mode)

These are the `:` commands inherited from `ex` / `vi`.

```
:w           — write (save)
:q           — quit
:wq / :x     — write and quit
:q!          — quit without saving
:e {file}    — open/edit a file
:bn / :bp    — next / previous buffer
:bd          — close (delete) buffer
:split / :vsplit  — horizontal / vertical split
:tabnew      — new tab
:so %        — source current file (reload config)
:set {opt}   — set an option
:lua {code}  — run Lua
:!{cmd}      — run a shell command
```

### Substitute (find & replace)

```
:s/foo/bar/         — replace first match on current line
:s/foo/bar/g        — replace all on current line
:%s/foo/bar/g       — replace all in file
:%s/foo/bar/gc      — replace all with confirmation
:'<,'>s/foo/bar/g   — replace in visual selection
```

### Ranges

```
:5,10 cmd    — lines 5–10
:%  cmd      — whole file
:'<,'> cmd   — visual selection
:.  cmd      — current line
:$ cmd       — last line
```

---

## 10. Windows, Tabs, and Buffers

These are three distinct concepts that are often confused.

- **Buffer** — a file loaded into memory. May or may not be visible.
- **Window** — a viewport displaying a buffer. Multiple windows can show the same buffer.
- **Tab page** — a named layout of windows. Like a workspace.

```
Ctrl-w s      — horizontal split
Ctrl-w v      — vertical split
Ctrl-w h/j/k/l — move between windows
Ctrl-w H/J/K/L — move window to edge
Ctrl-w =      — equalize window sizes
Ctrl-w q      — close window
Ctrl-w o      — close all other windows
Ctrl-w T      — move window to a new tab
```

---

## 11. Neovim Specifics (beyond Vim)

### Configuration

- **`init.lua`** — Neovim's Lua-based config file (at `~/.config/nvim/init.lua`). Replaces `init.vim`.
- **`vim.opt`** — Lua table for setting options: `vim.opt.number = true`.
- **`vim.keymap.set`** — sets keymaps in Lua: `vim.keymap.set('n', '<leader>w', ':w<CR>')`.
- **`vim.api`** — low-level Neovim API for buffers, windows, UI.
- **`vim.fn`** — calls Vimscript functions from Lua: `vim.fn.expand('%')`.
- **`vim.cmd`** — runs Ex commands from Lua: `vim.cmd('colorscheme habamax')`.
- **`vim.g`** — global variables: `vim.g.mapleader = ' '`.
- **`vim.b` / `vim.w`** — buffer-local / window-local variables.
- **`vim.env`** — environment variables.

### LSP (Language Server Protocol)

The protocol that gives Neovim IDE-like features by communicating with external language servers.

- **Language server** — an external process for a language (e.g. `pyright` for Python, `typescript-language-server` for JS/TS, `lua-language-server` for Lua).
- **`vim.lsp`** — built-in LSP client.
- **Diagnostics** — errors, warnings, hints shown inline from the LSP.
- **Hover** — shows docs/type info for the symbol under cursor.
- **Go to definition** — jump to where a symbol is defined.
- **Go to references** — find all usages.
- **Signature help** — shows function parameter hints while typing.
- **Code actions** — context-aware fixes offered by the LSP (e.g. "import missing module").
- **Rename** — language-aware rename across all usages.
- **Format** — LSP-powered code formatting (or via `conform.nvim`).
- **mason.nvim** — tool that installs/manages language servers, linters, formatters inside Neovim.

### Tree-sitter

A fast, incremental parser that gives Neovim accurate syntax understanding (beyond regex-based highlighting).

- **Parser** — a Tree-sitter grammar for a specific language.
- **Syntax highlighting** — accurate, scope-aware coloring using Tree-sitter.
- **Incremental selection** — expand/shrink selections by syntactic scope (`gnn`, `grn`, `grc`).
- **Text objects (TS-based)** — `nvim-treesitter-textobjects` provides `@function.inner`, `@class.outer`, etc.
- **Folding** — collapse/expand code by syntactic scope.
- **Indent** — Tree-sitter-powered indentation rules.

### Other Neovim concepts

- **Floating window** — a window that overlays the editor (used for hover docs, pickers, etc.).
- **Virtual text** — text rendered inline in a buffer that isn't part of the file (used for diagnostics, git blame, etc.).
- **Extmarks** — markers attached to buffer positions, used for decorations and overlays.
- **Autocmds** — autocommands: code that runs when an event fires (`BufEnter`, `BufWritePost`, `LspAttach`, etc.).
- **Filetype** — the type of a buffer (e.g. `python`, `lua`, `markdown`). Drives highlighting, LSP, and plugin behavior.
- **Namespace** — a scoped ID for extmarks and virtual text, preventing collisions between plugins.

---

## 12. Plugin Manager — lazy.nvim

`lazy.nvim` is the plugin manager LazyVim is built on. It handles installation, loading, and updating.

### Plugin spec fields

A plugin is declared as a Lua table with these keys:

|Key|Purpose|
|---|---|
|`"owner/repo"`|GitHub shorthand (first positional arg)|
|`opts = {}`|Table passed to `plugin.setup()` — the main way to configure plugins|
|`config = fn`|Function called after plugin loads; use instead of `opts` for complex setup|
|`dependencies = {}`|Other plugins that must load first|
|`event = "..."`|Lazy-load on a Neovim event (e.g. `"BufEnter"`, `"VeryLazy"`)|
|`ft = "..."`|Lazy-load only for a specific filetype|
|`cmd = "..."`|Lazy-load when a command is first used|
|`keys = {}`|Lazy-load on keypress + declare keymaps|
|`enabled = bool`|Disable a plugin entirely|
|`priority = n`|Load order (higher = earlier; use for colorschemes)|
|`build = "..."`|Shell command or Lua function to run on install/update|
|`lazy = true/false`|Force lazy or eager loading|
|`import = "..."`|Import a module of plugin specs|

### lazy.nvim commands

```
:Lazy           — open the Lazy UI
:Lazy sync      — install + update + clean
:Lazy update    — update all plugins
:Lazy install   — install missing
:Lazy clean     — remove unused
:Lazy profile   — show startup timing
```

---

## 13. LazyVim

LazyVim is a _distribution_ — a pre-configured Neovim setup built on `lazy.nvim`. It provides sane defaults, a structured config layout, and an "extras" system for optional features.

### Key directories (`~/.config/nvim/`)

```
init.lua                  — entry point (bootstraps lazy.nvim + LazyVim)
lua/
  config/
    autocmds.lua          — your custom autocommands
    keymaps.lua           — your custom keymaps
    lazy.lua              — lazy.nvim setup + LazyVim import
    options.lua           — your custom vim options
  plugins/                — your plugin overrides / additions
    example.lua           — any .lua file here is auto-loaded
```

### LazyVim Extras

Extras are optional feature bundles you can toggle. Enable them in `lua/config/lazy.lua`:

```lua
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.editor.telescope" },
    -- etc.
  },
})
```

Or via `:LazyExtras` — a UI for toggling extras interactively.

### Overriding plugin defaults

To customize a LazyVim-included plugin, add a file in `lua/plugins/` with the same plugin name. Your `opts` are deep-merged:

```lua
-- lua/plugins/gitsigns.lua
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = { add = { text = "+" } },
  },
}
```

---

## 14. LazyVim Default Keymaps

LazyVim uses **`<Space>`** as the `<leader>` key by default. Many keymaps follow the `<leader>` prefix.

### General

```
<leader>w        — save file
<leader>q        — quit
<leader>bd       — close buffer
<leader>|        — split window right
<leader>-        — split window below
```

### File finding (Telescope / fzf-lua)

```
<leader><space>  — find files
<leader>ff       — find files
<leader>fg       — live grep
<leader>fb       — find buffers
<leader>fr       — recent files
<leader>ss       — search in document (symbols)
```

### Code / LSP

```
gd               — go to definition
gr               — go to references
gI               — go to implementation
gy               — go to type definition
K                — hover docs
gK               — signature help
<leader>ca       — code action
<leader>cr       — rename symbol
<leader>cf       — format file
<leader>cd       — show diagnostic (line)
]d / [d          — next / prev diagnostic
```

### Git (gitsigns / lazygit)

```
<leader>gg       — open lazygit
<leader>gd       — diff file
<leader>gb       — git blame line
]h / [h          — next / prev hunk
<leader>ghs      — stage hunk
<leader>ghr      — reset hunk
```

### UI toggles

```
<leader>uf       — toggle autoformat
<leader>us       — toggle spelling
<leader>uw       — toggle word wrap
<leader>ul       — toggle line numbers
<leader>ud       — toggle diagnostics
<leader>uc       — toggle conceallevel
<leader>uT       — toggle treesitter
```

### Buffers / tabs

```
<S-h> / <S-l>   — prev / next buffer
[b / ]b          — prev / next buffer
<leader>bb       — switch to other buffer
<leader>,        — switch buffer (picker)
```

### Windows

```
<C-h/j/k/l>     — move between windows (works with tmux if configured)
<C-Up/Down>      — resize window vertically
<C-Left/Right>   — resize window horizontally
```

---

## 15. Key Plugins in the Default LazyVim Stack

|Plugin|Purpose|
|---|---|
|`telescope.nvim` or `fzf-lua`|Fuzzy finder for files, grep, symbols, buffers|
|`neo-tree.nvim`|File explorer tree|
|`nvim-treesitter`|Syntax parsing and highlighting|
|`nvim-lspconfig`|Configures built-in LSP client|
|`mason.nvim`|Installs language servers, linters, formatters|
|`mason-lspconfig.nvim`|Bridges mason + lspconfig|
|`nvim-cmp` or `blink.cmp`|Autocompletion engine|
|`LuaSnip`|Snippet engine|
|`conform.nvim`|Formatting (runs formatters like `prettier`, `black`, `stylua`)|
|`nvim-lint`|Linting (runs linters asynchronously)|
|`gitsigns.nvim`|Git change indicators in the gutter|
|`lazygit.nvim`|Full lazygit TUI inside Neovim|
|`which-key.nvim`|Shows available keymaps as you type a prefix|
|`mini.nvim`|Suite of small utilities (pairs, surround, statusline, etc.)|
|`flash.nvim`|Fast motions: search-jump, treesitter selection|
|`trouble.nvim`|Diagnostics list panel|
|`noice.nvim`|Replaces cmdline, messages, LSP progress UI|
|`nvim-notify`|Notification popups|
|`lualine.nvim`|Status line|
|`bufferline.nvim`|Tab/buffer line at the top|
|`todo-comments.nvim`|Highlights and searches `TODO:`, `FIXME:`, etc.|

---

## 16. Completion & Snippets

### How completion works

1. A **completion source** provides candidates (LSP, buffer words, paths, snippets).
2. The **completion engine** (`nvim-cmp` or `blink.cmp`) aggregates and displays them.
3. A **snippet engine** (`LuaSnip`) expands snippet items and lets you jump between placeholders.

### Completion keymaps (default)

```
Ctrl-space       — trigger completion manually
Ctrl-n / Ctrl-p  — next / prev item
Ctrl-y           — confirm selection
Ctrl-e           — abort completion
Tab / Shift-Tab  — next / prev item or expand snippet
Ctrl-l           — jump to next snippet placeholder
Ctrl-h           — jump to previous placeholder
```

---

## 17. Which-key

`which-key.nvim` shows a popup of available keymaps whenever you pause after typing a prefix like `<leader>`. It's your interactive cheatsheet — you don't need to memorize every keymap up front.

---

## 18. flash.nvim

Flash replaces or enhances `f/t/s` motions with a jump-label system. Type a pattern, letters appear over matches, type a label to jump instantly.

```
s        — flash search (forward+backward labels)
S        — flash treesitter (select by syntax scope)
r        — remote flash (use in operator-pending mode)
R        — treesitter search
Ctrl-s   — toggle flash in search (/ mode)
```

---

## 19. Telescope / fzf-lua

Fuzzy finders with a three-pane UI: list on the left, preview on the right, input at the bottom.

### Inside a picker

```
Ctrl-n / Ctrl-p  — move down / up
Ctrl-x           — open in horizontal split
Ctrl-v           — open in vertical split
Ctrl-t           — open in new tab
Ctrl-q           — send matches to quickfix list
Esc              — close
```

---

## 20. The Quickfix and Location Lists

- **Quickfix list** — a global list of file:line:col entries (e.g. grep results, diagnostics). Open with `:copen`, navigate with `:cn` / `:cp`.
- **Location list** — same concept but per-window. Open with `:lopen`, navigate with `:ln` / `:lp`.
- `trouble.nvim` provides a better UI for both.

---

## 21. Folding

Folds collapse sections of a buffer.

```
zc      — close fold under cursor
zo      — open fold under cursor
za      — toggle fold under cursor
zR      — open all folds
zM      — close all folds
zj / zk — move to next / prev fold
```

LazyVim uses `nvim-ufo` (optional) for better fold display. The `foldmethod` option controls how folds are determined (`treesitter`, `indent`, `syntax`, `manual`, `marker`, `expr`).

---

## 22. Options (vim.opt)

Key options to know:

```lua
vim.opt.number         = true   -- line numbers
vim.opt.relativenumber = true   -- relative line numbers
vim.opt.expandtab      = true   -- spaces instead of tabs
vim.opt.shiftwidth     = 2      -- indent size
vim.opt.tabstop        = 2      -- tab display width
vim.opt.wrap           = false  -- no line wrapping
vim.opt.ignorecase     = true   -- case-insensitive search
vim.opt.smartcase      = true   -- override if uppercase typed
vim.opt.hlsearch       = true   -- highlight matches
vim.opt.incsearch      = true   -- live search preview
vim.opt.clipboard      = "unnamedplus"  -- use system clipboard
vim.opt.signcolumn     = "yes"  -- always show gutter
vim.opt.updatetime     = 200    -- faster CursorHold events
vim.opt.scrolloff      = 8      -- keep 8 lines above/below cursor
vim.opt.splitright     = true   -- vsplit opens right
vim.opt.splitbelow     = true   -- split opens below
vim.opt.undofile       = true   -- persistent undo
```

---

## 23. Autocommands

Autocommands run Lua/Vimscript when events occur.

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.lua",
  callback = function() vim.lsp.buf.format() end,
})
```

Common events: `BufEnter`, `BufWritePre`, `BufWritePost`, `BufReadPost`, `FileType`, `InsertEnter`, `InsertLeave`, `LspAttach`, `VimResized`, `TextChanged`.

---

## 24. Omarchy-specific Notes

[Omarchy](https://omarchy.com/) is DHH's opinionated Linux desktop configuration. Its Neovim setup:

- Uses **LazyVim** as the base with minimal overrides.
- Config lives at `~/.config/nvim/` — you can customize it by adding files to `lua/plugins/` and `lua/config/`.
- Relies on **mason.nvim** to automatically install language servers; you don't install them manually.
- **`<Space>`** is the leader key — start there when learning keymaps (`:WhichKey` or just pause after `<Space>`).
- Ships with Ruby, JavaScript/TypeScript, and other language extras enabled.
- Uses `lazygit` as the primary git interface (`<leader>gg`).
- Theming uses a dark colorscheme matched to the rest of the Omarchy desktop.

To update Omarchy's Neovim plugins: open Neovim and run `:Lazy sync`.

---

## 25. Mental Model: How it all fits together

```
Your keypress
  → which-key shows available options (if you pause)
  → lazy.nvim loads the plugin for that feature (if not already loaded)
    → nvim-treesitter parses the buffer for syntax context
    → LSP server (managed by mason) provides language intelligence
      → nvim-cmp / blink.cmp surfaces completions
      → conform.nvim / nvim-lint formats and lints on save
    → Telescope / fzf-lua opens a picker if you're navigating
    → gitsigns shows what changed, lazygit manages commits
  → noice / nvim-notify shows feedback
```

---

## Quick-start sequence

1. Open Neovim: `nvim`
2. Press `<Space>` and pause — which-key shows what's available.
3. `<Space><Space>` — find a file.
4. `K` over any symbol — hover docs from LSP.
5. `gd` — go to definition.
6. `<Space>gg` — open lazygit.
7. `:Lazy` — see installed plugins.
8. `:LazyExtras` — toggle optional language packs.