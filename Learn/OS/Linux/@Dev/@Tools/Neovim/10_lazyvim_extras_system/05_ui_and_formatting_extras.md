## UI and Formatting Extras


### Introduction to Extras

Extras in LazyVim represent optional configurations that extend the core functionality by incorporating additional plugins and settings. These are designed to be enabled on demand, allowing users to tailor their setup without altering the default experience. UI extras focus on enhancing visual elements, such as dashboards, indentation guides, and animations, while formatting extras introduce specific formatters for code styling. As of January 2026, the listed extras reflect the current structure in the LazyVim repository, with no major additions noted in recent commits.

Extras can be enabled through the `:LazyExtras` command, which provides an interactive interface for selection, or by importing them programmatically in the configuration. Behavior may vary depending on installed plugins, Neovim version, or system settings; users should verify compatibility in their environment.

**Key Points**
- Extras are modular and do not override core configurations unless specified.
- Optional plugins within extras are configured only if already installed.
- [Inference]: Updates beyond November 2025 may introduce new extras; consult the official documentation for the latest details.

### Enabling Extras

Extras are activated via the `:LazyExtras` command, which opens a user interface for browsing and toggling available options. Alternatively, users can import extras in `lua/config/lazy.lua` by adding entries to the `imports` table.

**Example**
To enable an extra programmatically:

```lua
-- lua/config/lazy.lua
return {
  imports = {
    "lazyvim.plugins.extras.ui.alpha",
  },
}
```

This loads the specified extra during initialization.

**Key Points**
- The `:LazyExtras` method is recommended for ease of management.
- Programmatic imports allow version control of configurations.
- Changes may require restarting Neovim to take effect.

### UI Extras

UI extras provide enhancements to the visual and interactive aspects of the editor, such as startup screens, window layouts, and code visualization aids.

#### Alpha

This extra introduces a dashboard that appears on startup, featuring a custom banner and buttons for quick actions like file navigation and session management.

The primary plugin configured is `alpha-nvim`. It applies syntax highlighting to sections and integrates with core pickers.

**Key Points**
- Buttons include shortcuts for finding files, restoring sessions, and managing plugins.
- Disables the default dashboard if enabled.
- Depends on `persistence` for session features, configured only if installed.

**Example**
After enabling, the dashboard displays upon opening Neovim without a file:

- Header: ASCII logo.
- Buttons: e.g., "f" for find file.

Behavior may differ if conflicting dashboard plugins are present.

#### Dashboard-nvim

This extra adds a customizable startup dashboard with a logo, action buttons, and footer statistics on plugin loading.

The main plugin is `dashboard-nvim`, themed as "doom" with interactive center buttons.

**Key Points**
- Footer shows plugin count and startup time.
- Triggers automatically after closing the Lazy window.
- Interacts with `lualine` by preserving the statusline.

**Example**
Enable and restart; the dashboard appears with buttons like "r" for recent files.

[Unverified]: Performance impact on startup time could vary with system resources.

#### Edgy

This extra implements predefined window layouts for sidebars and panels, supporting positions like bottom, left, right, and top.

It installs `edgy.nvim` and optionally configures `telescope.nvim`, `neo-tree.nvim`, and `bufferline.nvim`.

**Key Points**
- Layouts include entries for terminals, trouble panels, and Neo-Tree sources.
- Keymaps for resizing: `<C-Left>`, `<C-Right>`, etc.
- Automatically adjusts for present plugins like `neo-tree.nvim`.

**Example**
With Neo-Tree installed, left layout includes filesystem and diagnostics panels.

Interactions may affect window management in multi-plugin setups.

#### Indent-blankline

This extra adds visual indentation guides using vertical lines to represent levels.

It configures `indent-blankline.nvim` (aliased as `ibl`), disabling conflicting features in `snacks`.

**Key Points**
- Guides use "│" for indents, limited to 3 lines for scopes.
- Excludes filetypes like help and notify.
- Toggle via `<leader>ug`.

**Example**
In a code buffer, vertical lines appear at indent levels; toggle to disable.

Scope display may vary with Treesitter parsing accuracy.

#### Mini-animate

This extra animates actions like scrolling, cursor movement, and resizing.

It configures `mini.animate`, disabling mouse scroll animations and certain filetypes.

**Key Points**
- Linear timing: 150ms for scroll, 50ms for resize.
- Toggle via `<leader>ua`.
- Disables `snacks` scroll when active.

**Example**
Scroll with `<C-d>`; animation smooths the motion unless mouse-initiated.

Animation performance may depend on terminal capabilities.

#### Mini-indentscope

This extra provides active indent guides with animation for code navigation.

It configures `mini.indentscope`, using "│" as the symbol and disabling `snacks` indent scope.

**Key Points**
- Treats symbol as border.
- Optionally disables scopes in `indent-blankline.nvim`.
- Enhances readability in nested code.

**Example**
Cursor on a line highlights the indent scope; moves with navigation.

[Inference]: May interact with other highlight plugins, potentially requiring adjustments.

#### Mini-starter

This extra replaces the default dashboard with a starter screen featuring aligned actions and a logo.

It configures `mini.starter`, with sections for file operations and plugin management.

**Key Points**
- Bullet points and center alignment for aesthetics.
- Executes single actions automatically.
- Integrates with `persistence` for sessions.

**Example**
Startup shows logo and actions; select "c" for config files.

Replaces alpha if enabled, altering startup flow.

#### Smear-cursor

This extra disables cursor animation from `mini.animate` for a minimal cursor experience.

It configures `mini.animate` with cursor enable set to false.

**Key Points**
- Sets cursor color to "none".
- Hides target hack enabled.
- Suitable for users preferring static cursors.

**Example**
With `mini.animate` installed, cursor movements lack animation after enabling.

Depends on `mini.animate` presence.

#### Treesitter-context

This extra displays context from preceding code lines above the cursor.

It configures `nvim-treesitter-context`, showing up to 3 lines.

**Key Points**
- Toggle via `<leader>ut`.
- Improves awareness in nested structures.
- Uses Treesitter for parsing.

**Example**
In a function, shows parent context; toggle to hide.

Accuracy depends on Treesitter grammar quality.

### Formatting Extras

Formatting extras extend code styling options by adding specific formatters integrated with core tools like `conform.nvim`.

#### Biome

This extra incorporates Biome for formatting, supporting languages like JavaScript.

It configures `conform.nvim` and `none-ls.nvim` optionally, ensuring Biome installation.

**Key Points**
- Requires cwd for execution.
- Conditional on config file if set.
- Avoids Prettier conflicts via global option.

**Example**
In a JS file, format with `<leader>cf`; applies Biome rules if config present.

May require Biome binary installation externally.

#### Black

This extra adds Black for Python formatting.

It configures `conform.nvim` and `none-ls.nvim` for Python files.

**Key Points**
- Ensures Black installation.
- Focuses on Python-specific styling.
- Integrates with formatting commands.

**Example**
Format a Python buffer; enforces Black's style.

Behavior assumes Python environment setup.

#### Prettier

This extra integrates Prettier for web languages formatting.

It configures `conform.nvim` and `none-ls.nvim`, with conditional config checks.

**Key Points**
- Parser-based activation.
- Global flag for config requirement.
- Broad filetype support.

**Example**
In HTML/JS, formatting applies Prettier; skips without config if flagged.

[Unverified]: May conflict with other formatters if not managed.

**Next Steps**
- Use `:LazyExtras` to explore and enable desired options.
- Review plugin documentation for advanced customizations.
- Test in a project to observe interactions.

**Conclusion**
UI and formatting extras in LazyVim offer targeted enhancements to visual and code maintenance aspects, promoting a customizable editor experience. Users should consider potential plugin interactions and environmental factors when implementing these features.

---

