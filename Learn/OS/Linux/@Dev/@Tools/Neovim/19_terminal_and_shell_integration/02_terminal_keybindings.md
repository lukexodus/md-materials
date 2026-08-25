## Terminal Keybindings


### Introduction

In Neovim with LazyVim, terminal integration is handled through a built-in feature called LazyTerm, which provides floating terminals without relying on external plugins like toggleterm.nvim by default. This allows opening terminals in the current working directory or project root, toggling them, and navigating between editor and terminal modes. Keybindings are predefined to streamline workflow, using leader keys and control combinations. These can be customized in configuration files.

Behavior may vary based on Neovim version, terminal emulator, and any user overrides. For example, in some terminal emulators, certain control keys like <C-/> may be intercepted or mapped differently.

**Key Points**
- LazyTerm opens a floating terminal window for quick access.
- Keybindings work in normal (n) and terminal (t) modes for seamless switching.
- No additional plugins needed in core LazyVim; toggleterm can be added via extras or custom configs if advanced features are required.
- Supports running commands, but does not include multi-terminal management by default.
- As of early 2026, no major changes reported in keybindings from 2025 documentation.

### Default Keybindings

LazyVim provides the following default keybindings for terminal operations, defined in `lua/lazyvim/config/keymaps.lua`:

- `<leader>ft`: Opens a terminal in the project root directory (normal mode).
- `<leader>fT`: Opens a terminal in the current working directory (normal mode).
- `<C-/>`: Toggles the terminal in the project root directory (normal and terminal modes).
- `<C-_>`: Alias for the above, often used due to terminal input variations (normal and terminal modes, ignored in which-key).

These invoke `LazyVim.terminal()` internally, which manages the floating terminal.

In terminal mode (buftype=terminal), standard Neovim keybindings apply:
- `<C-\><C-n>`: Exit terminal mode to normal mode.
- No default remapping of `<Esc>` to avoid conflicts with nested applications like vim or bash.

[Inference] LazyTerm likely uses Neovim's built-in :terminal command with floating window support from nui.nvim or similar, integrated in LazyVim.

### Entering and Exiting Terminal Mode

To enter terminal mode, use one of the opening keybindings. Once open, the buffer switches to terminal mode automatically.

To exit:
- Use `<C-/>` or `<C-_>` to toggle the window closed.
- Or `<C-\><C-n>` to normal mode, then close the window with `<leader>bw` or similar.

**Example**
1. Press `<leader>ft` in normal mode to open a terminal at the project root.
2. Run a command like `ls` in the terminal.
3. Press `<C-/>` to hide the terminal.
4. Press `<C-/>` again to reopen it at the same state.

**Output**
The floating terminal appears, showing the shell prompt. State persists across toggles, preserving command history and output.

### Customizing Keybindings

Customize in `lua/config/keymaps.lua` by overriding or adding mappings. Use `vim.keymap.set` for modes 'n', 't', etc.

Disable defaults by setting them to false in plugin configs if needed.

**Example**
```lua
-- In lua/config/keymaps.lua
-- Remap terminal toggle to <leader>tt
vim.keymap.set({ "n", "t" }, "<leader>tt", function()
  LazyVim.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "Toggle Terminal (Root Dir)" })

-- Add a key to run a specific command in terminal
vim.keymap.set("n", "<leader>tr", function()
  LazyVim.terminal("npm run dev")
end, { desc = "Run Dev Server" })
```

Reload with :source or restart Neovim. This adds flexibility for project-specific workflows.

Behavior may vary; custom mappings might conflict with existing ones if not del(keymap) used.

### Configuring LazyTerm

LazyTerm options can be tweaked via LazyVim's plugin system. Though not extensively documented, you can extend it by modifying the terminal function or adding plugins.

For advanced features like multiple terminals, add toggleterm.nvim:

**Example**
```lua
-- In lua/plugins/terminal.lua
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
    keys = {
      { "<leader>tg", "<cmd>lua require('toggleterm').toggle()<cr>", desc = "ToggleTerm" },
    },
  },
}
```
This integrates toggleterm alongside LazyTerm.

[Unverified] As of 2026, LazyVim may include more LazyTerm options in updates; check GitHub for latest.

### Integration with Other Features

Terminal keybindings integrate with LazyVim's which-key for discovery—press <leader>f to see terminal options.

Combine with overseer.nvim for task runners that use terminals.

For debugging, use terminals for manual commands alongside nvim-dap.

**Key Points**
- Which-key shows descriptions for <leader>f prefixed keys.
- Supports lazygit or other tools via terminal wrappers.
- In split windows, terminals can be opened, but defaults to floating.

### Troubleshooting Common Issues

- Key not working: Check conflicts with OS or terminal emulator (e.g., iTerm remaps <C-/>).
- Terminal not floating: Ensure nvim >= 0.8 and no config overrides.
- Alias <C-_> vs <C-/>: Use :verbose nmap <C-/> to inspect.
- Persistence: State may not persist if Neovim restarts.

Behavior may vary across platforms; Windows might need shell config adjustments.

### Advanced Usage

Script automated terminals with Lua APIs.

**Example**
```lua
-- Auto-open terminal on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      LazyVim.terminal()
    end
  end,
})
```

For custom shells, pass options to LazyVim.terminal(cmd, opts).

**Conclusion**
Terminal keybindings in LazyVim via LazyTerm provide efficient access to shells within the editor, supporting development workflows with minimal setup. They balance simplicity and customizability for users.

**Next Steps**
- Test default keybindings in a new LazyVim install.
- Customize mappings in your config for personal preferences.
- Explore adding toggleterm for enhanced terminal management if needed.

---

