## Recent Files and Project Switching


### Introduction

Recent files refer to buffers or files previously opened in a session or across sessions, allowing quick access without navigating directories. Project switching involves changing the working directory or context to different project roots, often with associated session states like open buffers or layouts. In LazyVim, these features leverage plugins such as Telescope for fuzzy finding recent files and project.nvim (or similar) for managing projects. Telescope integrates with Neovim's built-in `:oldfiles` for recent files, while project handling might use auto-detection based on git roots or configured directories.

These capabilities enhance workflow efficiency by reducing time spent on navigation. LazyVim enables persistence via plugins like mini.sessions or persisted.nvim in extras, but behavior can vary depending on enabled plugins, Neovim version, and user configurations. For instance, session data might not persist if plugins are disabled.

### Core Mechanisms

Neovim tracks recent files through the viminfo or shada file, storing up to a configurable number (default 100). LazyVim exposes this via Telescope's `oldfiles` picker, bound by default to `<leader>fr` or similar.

For projects, LazyVim can use the `project.nvim` plugin (included in extras like `lazyvim.plugins.extras.util.project`), which detects project roots based on patterns like `.git`, `package.json`, or custom markers. Switching projects changes the cwd (current working directory) and may load sessions.

Integration: Telescope unifies access, with pickers for both recent files and projects. Which-Key provides discoverability for mappings.

[Inference: This setup assumes standard LazyVim installation; custom forks might alter plugins.]

### Accessing Recent Files

By default, press `<leader>fr` to open Telescope's recent files picker. It lists files from `:oldfiles`, filtered by cwd if `cwd_only` is set.

Configuration: In `lua/plugins/telescope.lua` or equivalents, options like `extensions = { file_browser = { } }` can influence behavior.

To increase history: Set `vim.opt.history = 1000` in `lua/config/options.lua`, though shada limits apply.

Behavior note: Files from previous sessions appear if shada is enabled (`vim.opt.shada = "'100,<50,s10,h"`); outcomes may differ if shada is cleared.

**Key Points**
- Fuzzy search with Telescope for quick filtering.
- Ignores temporary or deleted files.
- Can include buffers from current session.

**Example**

1. Open Neovim in a project.
2. Edit several files.
3. Close and reopen Neovim.
4. Press space ( `<leader>` ) then `f` then `r`.
5. Telescope shows list; select with enter.

**Output**

Telescope interface:

```
Recent Files
/path/to/file1.lua
/path/to/file2.md
...
```

Selecting opens the file in a buffer.

### Managing Projects

LazyVim's project management, when enabled via extras, allows listing and switching projects. Default mapping might be `<leader>fp` for project picker.

Project detection: Scans for root markers upward from cwd. Custom projects added via `require("project_nvim").add_project("/path")`.

Switching: Selecting a project changes cwd, may telescope into files, or load sessions if configured.

For session persistence, extras like `lazyvim.plugins.extras.util.mini-sessions` store layouts.

[Unverified: Some users report inconsistencies with nested git repos; test in your setup.]

**Key Points**
- Auto-detection for common VCS like git, svn.
- Manual addition for non-standard projects.
- Integrates with Telescope for unified UI.

**Example**

Enable project extra in `lua/config/lazy.lua`:

```lua
require("lazy").setup({
  specs = {
    "LazyVim/LazyVim",
    import = "lazyvim.plugins",
    { import = "lazyvim.plugins.extras.util.project" },
  },
})
```

Then, `<leader>fp` opens project list.

Switch: Select project, cwd changes, optional session loads.

**Output**

Telescope projects:

```
Projects
~/projects/app1 (.git)
~/projects/app2 (package.json)
```

### Customizing and Extending

Customize recent files: In `lua/config/keymaps.lua`, remap or add filters, e.g.,

```lua
require("telescope").setup({
  pickers = {
    oldfiles = {
      only_cwd = true,
    },
  },
})
```

For projects: Configure detection patterns in `lua/plugins/project.lua`:

```lua
require("project_nvim").setup({
  patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "Cargo.toml" },
})
```

Add session auto-save: With mini.sessions, set `autosave = true`.

Advanced: Use `telescope-project.nvim` extension for enhanced project features.

Potential issues: Large histories may slow Telescope; limit with options. Plugin conflicts could arise if multiple session managers are active.

### Integration with Other Features

Recent files and projects tie into buffer management (`<leader>b`) and file finding (`<leader>f`). For example, switching projects might refresh buffer lists.

With LSP, project switch can reload servers for new cwd.

In multi-window setups, sessions preserve splits.

[Speculation: Upcoming Neovim features like workspace APIs might streamline this further.]

### Troubleshooting

- Missing files: Check `:oldfiles` output; ensure shada writable.
- Project not detected: Add manually or adjust patterns.
- Slow loading: Reduce history or use caching options in Telescope.
- Conflicts: Disable overlapping plugins via `:Lazy`.

Disclaimers: Persistence depends on filesystem permissions; behavior may vary across OS (e.g., Windows paths).

**Key Points**
- Regularly sync LazyVim for plugin updates.
- Backup shada/session files.

**Conclusion**

Handling recent files and project switching in LazyVim streamlines navigation across workspaces, leveraging Telescope and project plugins for intuitive access. Proper configuration can adapt these to complex development environments.

**Next Steps**

- Install relevant extras with `:LazyExtras`.
- Explore Telescope docs at github.com/nvim-telescope/telescope.nvim.
- Experiment with custom patterns in a test project.

---

