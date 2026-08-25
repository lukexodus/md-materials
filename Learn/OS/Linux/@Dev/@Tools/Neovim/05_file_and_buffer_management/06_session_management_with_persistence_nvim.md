## Session Management with persistence.nvim


### Overview
persistence.nvim is a Neovim plugin designed for automated session management. It handles saving the current session state, including open buffers, window layouts, and other elements, to allow restoration later. In LazyVim, it is included as a core plugin under the util category, providing background session saving. Sessions are not automatically restored on startup; instead, users can load them manually via keymaps or dashboard integrations. This setup maintains workflow continuity, especially useful in project-based editing. Behavior may vary depending on Neovim version (requires >=0.7.2) and custom configurations.

**Key Points**
- Automatically saves sessions on Neovim exit if conditions are met.
- Stores sessions in `~/.local/state/nvim/sessions/` by default.
- Supports Git branch-specific sessions when enabled.
- Provides an API for loading, selecting, and stopping sessions.
- In LazyVim, it integrates with dashboard plugins for easy restoration.
- Does not auto-load sessions to avoid unexpected behavior; manual trigger required.

### Installation and Setup
In a standard Neovim setup, persistence.nvim can be installed via lazy.nvim. LazyVim pre-installs and configures it automatically, so no manual installation is needed unless customizing outside LazyVim. The plugin loads on the `BufReadPre` event, activating only when files are opened.

**Key Points**
- LazyVim spec: Included in `lua/lazyvim/plugins/util.lua`.
- Default loading: Event-triggered to optimize startup.
- No additional dependencies beyond Neovim 0.7.2.
- For non-LazyVim users: Add to lazy.nvim plugins table with desired opts.

**Example**
In a custom config (not required in LazyVim):
```lua
return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {
    dir = vim.fn.stdpath("state") .. "/sessions/",
    need = 1,
    branch = true,
  },
}
```

### Configuration Options
LazyVim uses the plugin's default options without overrides, but users can extend them in `lua/plugins/`. Options control session storage, saving thresholds, and branch handling.

**Key Points**
- `dir`: Path for session files (default: `~/.local/state/nvim/sessions/`).
- `need`: Minimum open file buffers to save a session (default: 1; set to 0 to always save).
- `branch`: Enable per-Git-branch sessions (default: true).
- In LazyVim: `opts = {}` (inherits defaults); customize by returning a table in your config.
- Additional options like `options` for what to save (e.g., buffers, windows) can be set, but defaults cover common needs [Inference: Based on plugin capabilities].
- Changes require restarting Neovim or sourcing the config.

**Example**
To disable branch-specific sessions in LazyVim:
1. Create or edit `lua/plugins/persistence.lua`.
2. Add:
```lua
return {
  {
    "folke/persistence.nvim",
    opts = {
      branch = false,
    },
  },
}
```

### Autosaving Sessions
Sessions save automatically on Neovim exit (e.g., `:qa`) if at least `need` file buffers are open. This captures the state without user intervention. In LazyVim, this runs in the background.

**Key Points**
- Triggered on `VimLeavePre` autocmd internally.
- Saves only if a session file doesn't exist or needs updating.
- Excludes temporary or unnamed buffers.
- Can be stopped for the current session via API.
- File naming: Based on current directory and branch if enabled (e.g., hashed path).
- Behavior may vary if other plugins modify exit hooks.

**Example**
1. Open multiple files in a project directory.
2. Edit and arrange windows.
3. Exit with `:qa`.
   
**Output**
A session file is created in the sessions directory, preserving the state for later loading.

### Loading and Restoring Sessions
Sessions load manually using the plugin's API. In LazyVim, keymaps are provided for convenience. No auto-restore occurs to prevent conflicts with fresh starts.

**Key Points**
- `require("persistence").load()`: Loads session for current directory.
- `require("persistence").load({ last = true })`: Loads the most recent session.
- `require("persistence").select()`: Prompts to choose a session (uses telescope if available).
- In dashboard integrations (e.g., dashboard-nvim extra): Buttons for restoration.
- After loading, Neovim restores buffers, windows, etc.
- May not restore all plugin states; depends on what the session captures.

**Example**
To load the last session:
1. In Normal mode, press `<leader>ql`.

**Output**
Restores the most recent session, reopening buffers and layouts.

### Keymaps in LazyVim
LazyVim defines default keymaps for session operations, prefixed with `<leader>q` (default `<leader>` is space).

**Key Points**
- `<leader>qs`: Restore session for current directory.
- `<leader>qS`: Select a session to load.
- `<leader>ql`: Restore last session.
- `<leader>qd`: Stop saving the current session.
- These are Normal mode mappings.
- Customizable by overriding in user config.
- Visible via which-key popup when pressing `<leader>q`.

**Example**
To prevent saving:
1. Press `<leader>qd`.

**Output**
Current session will not save on exit; status may show in the message area.

### Events and Hooks
The plugin fires autocmd events for customization, allowing scripts before/after save/load.

**Key Points**
- `PersistenceSavePre`: Before saving.
- `PersistenceSavePost`: After saving.
- `PersistenceLoadPre`: Before loading.
- `PersistenceLoadPost`: After loading.
- In LazyVim: No default autocmds added; users can define them.
- Useful for integrating with other plugins, e.g., saving extra state.

**Example**
To run code after loading:
```lua
vim.api.nvim_create_autocmd("PersistenceLoadPost", {
  callback = function()
    print("Session loaded!")
  end,
})
```

### Integration with Dashboard Plugins
In LazyVim, persistence integrates with starter dashboards (e.g., dashboard-nvim, alpha, mini-starter extras) via buttons or items for session restoration.

**Key Points**
- On startup, if no files are opened, dashboard shows options like "Restore Session".
- Uses `require("persistence").load()` for current or last session.
- Enhances startup flow; select via key (e.g., `s` for restore).
- Enable extras via `:LazyExtras` if not default.
- Behavior may vary if multiple dashboard plugins are active.

**Example**
In dashboard-nvim:
1. Startup shows buttons.
2. Press `s` to restore.

**Output**
Loads session, replacing dashboard with restored state.

### Manual Session Management
Beyond autosave, users can interact via Lua API or commands.

**Key Points**
- No built-in Ex commands; use Lua functions.
- List sessions: Manually via file explorer or custom scripts.
- Delete sessions: Remove files from sessions dir.
- For advanced: Wrap in functions for custom behavior.

**Example**
To select a session in Lua:
```lua
require("persistence").select()
```

**Output**
Prompts (e.g., telescope UI) to choose and load a session.

### Troubleshooting and Limitations
Common issues include sessions not saving if `need` not met or dir permissions. Not all plugin states persist (e.g., treesitter highlights may reload).

**Key Points**
- Check session dir for files.
- Debug with events or `:lua print(require("persistence").session())`.
- [Unverified]: May conflict with other session plugins; disable via LazyVim extras.
- Behavior may vary in headless or embedded Neovim.

### Customization in LazyVim
Extend via user plugins dir. For example, change dir or add hooks.

**Key Points**
- Return a table merging with defaults.
- Disable: Set `enabled = false` in spec.
- Add options like custom `need` value.

**Example**
To always save sessions:
```lua
return {
  {
    "folke/persistence.nvim",
    opts = {
      need = 0,
    },
  },
}
```

**Conclusion**
persistence.nvim simplifies session handling in LazyVim by automating saves and providing easy restoration tools, improving productivity in multi-file projects. It balances automation with control, avoiding intrusive auto-loads.

**Next Steps**
Experiment with keymaps in a project. Customize opts in your LazyVim config. Explore integrations with telescope for session selection via `:help persistence.nvim` or GitHub repo. For advanced, hook into events for plugin-specific state management.

---

