## Which-key Integration and Discovery


### Overview

Which-key.nvim is integrated into LazyVim as a core editor plugin to facilitate the discovery and recall of keybindings. It displays a popup menu showing available keymaps as users type partial sequences, helping to explore and remember commands interactively. This integration is part of LazyVim's opinionated setup, where which-key is automatically configured with predefined groups for common prefixes like the leader key. The behavior may vary depending on Neovim version, user customizations, or updates to which-key.nvim or LazyVim.

### Role in Keymap Discovery

Which-key aids discovery by dynamically presenting keybindings based on the keys pressed. For instance, when a user starts a sequence with the leader key (default `<space>`), a popup appears listing all registered mappings that begin with that prefix, grouped logically (e.g., by functionality like "file/find" or "git"). This reduces the need to memorize keymaps, as users can pause after pressing a prefix to view options. It supports normal and visual modes by default, with potential extensions to other modes via custom configurations. The popup updates in real-time as more keys are typed, narrowing down the suggestions.

**Key Points**
- Triggers on partial key sequences, typically after a short delay.
- Groups mappings for better organization, using names defined in the configuration.
- Integrates with LazyVim's default keymaps, automatically picking up descriptions (via `desc` in keymap definitions).
- May not show all possible mappings if they lack descriptions or if configurations conflict [Inference based on discussions].

### Integration Details

In LazyVim, which-key is specified in the `lua/lazyvim/plugins/editor.lua` file (from source inspections via GitHub discussions and docs). It uses a "helix" preset, which influences the popup style and behavior, such as how groups are displayed. The configuration includes an empty `defaults` table and a detailed `spec` array that defines mode-specific groups and proxies. For example, it proxies `<c-w>` for window commands, allowing which-key to expand and show sub-options dynamically.

The full spec includes definitions like:
- Mode: `{ "n", "x" }` (normal and visual).
- Groups such as `<leader><tab>` for "tabs", `<leader>c` for "code", `<leader>d` for "debug", and many others including navigation prefixes like `[`, `]`, `g`, `gs`, `z`.
- Expand functions for dynamic content, e.g., `require("which-key.extras").expand.buf()` for buffer-related keys or `expand.win()` for windows.
- Custom descriptions, like `"gx"` as "Open with system app".

This setup ensures which-key aligns with LazyVim's keymap structure, but updates to which-key might introduce warnings about spec versions, as noted in 2024 discussions (e.g., recommending migration to newer specs).

### Usage Scenarios

Users can discover keymaps by pressing prefixes and waiting for the popup. For buffer-specific keymaps, press `<leader>?` to invoke which-key's buffer mode. In window management, pressing `<c-w>` followed by `<space>` activates a Hydra-like mode through which-key, showing window-related commands.

**Example**  
To explore leader key options:  
1. Press `<space>` (leader key).  
2. A popup appears with groups like:  
   - `f`: file/find  
   - `g`: git  
   - `s`: search  
   - And sub-groups or individual mappings with descriptions.

**Output**  
The popup might display something like (textual representation; actual UI is a floating window):  
```
<leader>   +code  
           +debug  
           +file/find  
           +git  
           ...  
```

For a sequence like `<leader>f`, it narrows to file-related mappings, e.g., `f` for find files, `r` for recent files.

Behavior may vary if the popup delay is adjusted or if plugins override mappings.

### Customization Options

Customizations can be made by editing `lua/config/keymaps.lua` for new mappings or overrides. To ensure which-key displays them, include a `desc` field in `vim.keymap.set` calls. For example, which-key automatically detects and groups these based on prefixes.

To override or remove pre-configured groups, modify the which-key spec in a custom plugin file under `lua/plugins/`, such as returning a table that adjusts `opts.spec`. Discussions from 2024 suggest using `vim.keymap.del` to remove defaults before adding new ones, or updating to newer which-key specs to avoid warnings.

For mode-specific hints (e.g., insert mode), additional configuration in the spec's `mode` array may be needed, though defaults focus on normal/visual [Unverified; based on user queries in discussions].

**Example**  
Adding a custom keymap that appears in which-key:  
In `lua/config/keymaps.lua`:  
```lua
vim.keymap.set("n", "<leader>ex", "<cmd>Explore<cr>", { desc = "Open Explorer" })
```  
This adds "ex: Open Explorer" under the leader popup.

To customize the spec globally:  
In a custom `lua/plugins/which-key.lua`:  
```lua
return {
  "folke/which-key.nvim",
  opts = {
    spec = {
      -- Add or modify groups here
      { "<leader>custom", group = "my group" },
    },
  },
}
```  
This extends the existing groups.

**Output**  
After reloading, pressing `<leader>` might show the new "custom" group in the popup.

### Potential Variations and Updates

As of early 2026, LazyVim's which-key integration remains consistent with 2024 documentation, but users should check for spec version warnings upon updates, as older configs might trigger notifications. Behavior could differ across environments, such as if other plugins like Hydra or custom leaders interfere. For the latest, refer to the official docs or GitHub repository [Speculation; no 2025-2026 changes noted in searched sources].

**Conclusion**  
Which-key's integration in LazyVim enhances keymap discovery by providing interactive popups and grouped suggestions, making it easier to navigate the editor's extensive bindings without constant reference to documentation.

**Next Steps**  
- Press `<space>` in a LazyVim session to explore the popup firsthand.  
- Add custom keymaps with descriptions to see them integrated.  
- Review the full spec in LazyVim's source for advanced overrides.  
- Monitor GitHub discussions for any evolving best practices on configuration.

---

