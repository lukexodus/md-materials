## Telescope Live Grep and Search Features


### Introduction

Telescope.nvim is a highly extensible fuzzy finder plugin for Neovim, serving as a unified interface for searching and picking items from various sources. In LazyVim, it is enabled by default as the primary picker, leveraging ripgrep (rg) for fast text searching and fd (or find) for file discovery. Live grep refers to Telescope's dynamic searching of text patterns across files in the current working directory or specified paths, updating results in real-time as you type. General search features encompass finding files, buffers, help tags, commands, and more, with fuzzy matching powered by algorithms like fzy.

These features integrate with LazyVim's keymaps and which-key.nvim for discoverability. Prerequisites include external tools like ripgrep for grep functionality (installed via package managers) and optional git for enhanced file ignoring. Behavior may vary based on your ripgrep version, filesystem size, or custom Telescope extensions loaded in LazyVim.

### Core Components

Telescope operates through "pickers," which are modules for different data sources. For search, key pickers include:

**Key Points**
- Live grep uses ripgrep under the hood for regex-based searching, supporting flags like --hidden or --no-ignore.
- File search (find_files) uses fd by default, falling back to git ls-files in git repos for efficiency.
- Fuzzy filtering applies to results, allowing partial matches.
- Previewers show file contents or diffs in a side pane.
- Actions like opening in splits or quickfix lists are customizable.
- Themes (e.g., dropdown, ivy) alter the UI layout.
- Extensions like fzf.nvim can enhance sorting if enabled in LazyVim extras.

### Keybindings

LazyVim provides the following default keybindings for Telescope searches (normal mode unless specified). These are grouped under \<leader>f and \<leader>s for find and search, respectively.

- `<leader>/`: Live grep in current working directory (`n`)
- `<leader><space>`: Find files (includes git files if in repo) (`n`)
- `<leader>fb`: Buffers (`n`)
- `<leader>fc`: Grep string under cursor in cwd (`n`, `v`)
- `<leader>fC`: Live grep in cwd (`n`)
- `<leader>ff`: Find files (`n`)
- `<leader>fF`: Find all files (includes git-ignored) (`n`)
- `<leader>fg`: Git commits (`n`)
- `<leader>fG`: Git commits for current buffer (`n`)
- `<leader>fh`: Help tags (`n`)
- `<leader>fk`: Keymaps (`n`)
- `<leader>fM`: Man pages (`n`)
- `<leader>fr`: Resume last picker (`n`)
- `<leader>fR`: Registers (`n`)
- `<leader>fw`: Grep word under cursor (`n`, `v`)
- `<leader>fW`: Grep word under cursor (case-sensitive) (`n`, `v`)
- `<leader>sb`: Buffers (`n`)
- `<leader>sc`: Commands (`n`)
- `<leader>sC`: Command history (`n`)
- `<leader>sg`: Live grep (`n`)
- `<leader>sG`: Live grep (git root) (`n`)
- `<leader>sh`: Help tags (`n`)
- `<leader>sH`: Highlight groups (`n`)
- `<leader>sk`: Keymaps (`n`)
- `<leader>sM`: Man pages (`n`)
- `<leader>sm`: Jump to marks (`n`)
- `<leader>so`: Options (`n`)
- `<leader>sR`: Resume (`n`)
- `<leader>sw`: Grep string (`n`, `v`)
- `<leader>sW`: Grep string (case-sensitive) (`n`, `v`)
- `<leader>uC`: Colorschemes (with preview) (`n`)

Within Telescope UI:
- `<C-n>/<Down>`: Next item
- `<C-p>/<Up>`: Previous item
- `<C-c>`: Close
- `<CR>`: Select (open file)
- `<C-x>`: Open in horizontal split
- `<C-v>`: Open in vertical split
- `<C-t>`: Open in new tab
- `<C-q>`: Send to quickfix

Note: \<leader> is \<Space> by default. Some bindings like \<leader>fc use visual selection if in visual mode.

### Live Grep Usage

Live grep launches a prompt where typing filters files containing matches. It supports ripgrep syntax for patterns (e.g., regex with /flags).

**Key Points**
- Searches cwd by default; use args for paths.
- Hidden files: Add --hidden flag via config or prompt prefix.
- Git integration: Respects .gitignore unless --no-ignore.
- Case insensitivity: Default; toggle with -s for sensitive.
- Prompt prefixes: Use # for fuzzy on results, . for file filter.

**Example**  
To search for "function" in all files:  
Press \<leader>/. Type "function" – results update live. Select with \<CR> to open at match.

**Example**  
Grep under cursor: Position on "var", press \<leader>fw. Searches for "var" across files.

**Output**  
The UI shows a list like:  
filename:line  matched text  
With preview on the right showing context.

### General Search Usage

Other searches use similar interfaces but different backends.

**Key Points**
- Find files: Fuzzy name matching; previews file contents.
- Buffers: Lists open buffers with paths.
- Help: Searches Neovim :help topics.
- Git commits: Shows log with diffs in preview.
- Resumable: \<leader>fr reopens last session.

**Example**  
Find a file: Press \<leader>\<space>, type partial name (e.g., "conf" for config.lua). Fuzzy matches appear.

**Example**  
Search help: \<leader>fh, type "option" – lists relevant help pages.

### Advanced Features

- Custom args: In prompt, prefix with > for ripgrep flags (e.g., > --type=lua for Lua files) [Inference from ripgrep integration].
- Multi-select: \<Tab> to toggle selection, then action.
- Layout config: Vertical/horizontal via opts.
- Extensions: LazyVim extras like telescope-fzf-native for faster fuzzy if enabled.
- Lua API: Use require('telescope.builtin').live_grep({}) for scripting.

**Practical Scenarios**  
**Scenario: Project-Wide Refactor**  
Use \<leader>/ to find all occurrences of a variable, send to quickfix with \<C-q>, then :cdo substitute.

**Scenario: Quick Navigation**  
In a large repo, \<leader>\<space> to fuzzy find files, ignoring binaries via fd flags.

### Configuration

In LazyVim, customize via lua/plugins/telescope.lua:

```lua
return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      layout_strategy = "horizontal",
      mappings = { i = { ["<C-k>"] = "which_key" } },
    },
    pickers = {
      live_grep = { additional_args = { "--hidden" } },
    },
  },
}
```

This adds hidden file search by default [Unverified for exact opts merging].

### Potential Issues

- Performance: Large dirs may lag; limit with cwd or args.
- Missing tools: No ripgrep? Falls back to grep, slower.
- UI overlap: With other floats; adjust theme.

**Conclusion**  
Telescope's live grep and search features in LazyVim provide powerful, interactive ways to navigate codebases and documentation, enhancing workflow efficiency through fuzzy matching and previews.

**Next Steps**  
Install ripgrep if not present, enable extras like telescope-undo for history search, or explore Telescope's Lua API for custom pickers. Review :Telescope builtin for all available pickers.

---

