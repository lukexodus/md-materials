# Yazi: A Comprehensive Guide

Yazi (meaning "duck" in Chinese) is a terminal file manager written in Rust, designed for speed, asynchronous I/O, and a rich plugin/theme ecosystem. It runs in the terminal, uses a Miller columns layout (like Ranger), and supports previewing images, videos, PDFs, archives, and more via third-party tools.

---

## Installation

### Package Managers

**macOS (Homebrew):**

```bash
brew install yazi ffmpegthumbnailer unar jq poppler fd ripgrep fzf zoxide imagemagick
```

**Arch Linux (pacman):**

```bash
sudo pacman -S yazi ffmpegthumbnailer unarchiver jq poppler fd ripgrep fzf zoxide
```

**Cargo (from source):**

```bash
cargo install --locked yazi-fm yazi-cli
```

**Nix:**

```nix
environment.systemPackages = [ pkgs.yazi ];
```

Check the [official installation docs](https://yazi-rs.github.io/docs/installation) for your specific platform, as package availability changes.

### Optional Dependencies

These extend yazi's preview and integration capabilities:

|Tool|Purpose|
|---|---|
|`ffmpegthumbnailer`|Video thumbnails|
|`poppler`|PDF previews|
|`fd`|File searching|
|`ripgrep`|Content searching|
|`fzf`|Fuzzy finding|
|`zoxide`|Smart directory jumping|
|`imagemagick`|Image previewing (fallback)|
|`unar` / `7z`|Archive previewing|
|`jq`|JSON previews|
|`nerd-fonts`|Icons in the UI|

---

## Starting Yazi

```bash
yazi
```

To change your shell's working directory when you exit yazi (the `cd` on quit feature), add a wrapper function to your shell config:

**Bash/Zsh:**

```bash
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
```

**Fish:**

```fish
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- $tmp); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- $cwd
    end
    rm -f -- $tmp
end
```

After this, use `y` instead of `yazi` to get the directory-change behavior on exit.

---

## Interface Layout

Yazi uses a three-pane Miller columns layout by default:

```
[ Parent directory ] [ Current directory ] [ Preview ]
```

The left pane shows the parent of the current directory, the middle pane is where you navigate, and the right pane previews the selected file or subdirectory. You can configure how many columns are shown and their proportions.

---

## Navigation

### Basic Movement

|Key|Action|
|---|---|
|`h`|Go to parent directory|
|`l`|Enter directory / open file|
|`j`|Move cursor down|
|`k`|Move cursor up|
|`J`|Move down 5 items|
|`K`|Move up 5 items|
|`g g`|Jump to top|
|`G`|Jump to bottom|
|`<Enter>`|Open selected file with default opener|

### Jumping and Searching

|Key|Action|
|---|---|
|`/`|Search file names (forward)|
|`?`|Search file names (backward)|
|`n`|Next search match|
|`N`|Previous search match|
|`f`|Filter files in current directory|
|`z`|Jump with zoxide (requires zoxide)|
|`Z`|Jump with fzf (requires fzf)|

### Tab and History

|Key|Action|
|---|---|
|`t`|Create new tab|
|`1`–`9`|Switch to tab by number|
|`[`|Switch to previous tab|
|`]`|Switch to next tab|
|`{`|Swap current tab with previous|
|`}`|Swap current tab with next|
|`<Ctrl-c>`|Close current tab|
|`<Alt-1>` – `<Alt-9>`|Create tab at specific position|

---

## Selection

|Key|Action|
|---|---|
|`<Space>`|Toggle selection on current item, move down|
|`v`|Enter visual selection mode|
|`V`|Enter visual selection (unselect mode)|
|`<Ctrl-a>`|Select all items|
|`<Ctrl-r>`|Invert selection|
|`<Esc>`|Clear selection / exit mode|

---

## File Operations

### Copy, Cut, Paste

|Key|Action|
|---|---|
|`y`|Yank (copy) selected files|
|`x`|Cut selected files|
|`p`|Paste into current directory|
|`P`|Paste and overwrite existing files|
|`Y`|Cancel yank|
|`X`|Cancel cut|

### Create, Rename, Delete

|Key|Action|
|---|---|
|`a`|Create a new file (append `/` to create directory)|
|`r`|Rename selected file|
|`d`|Send to trash|
|`D`|Delete permanently|
|`;`|Run a shell command|
|`!`|Run a shell command (stay in yazi after)|

### Sorting

Press `o` then a secondary key:

|Keys|Sort By|
|---|---|
|`o m`|Modified time|
|`o b`|Birth/creation time|
|`o e`|File extension|
|`o a`|Alphabetical|
|`o n`|Natural sort (numbers in names)|
|`o s`|File size|
|`o r`|Reverse current sort|

---

## Previews

Yazi's preview system is plugin-based. Built-in support (with the required tools installed) includes images, video thumbnails, PDFs, archives, JSON, and syntax-highlighted code.

### Image Protocol Support

Yazi supports multiple terminal image protocols:

- **Kitty graphics protocol** (kitty terminal)
- **iTerm2 inline images** (iTerm2, WezTerm)
- **Sixel** (various terminals)
- **Überzug++** (as a fallback for X11/Wayland)

The correct protocol is detected automatically based on the `$TERM` and `$TERM_PROGRAM` environment variables.

### Toggling and Sizing

|Key|Action|
|---|---|
|`~`|Toggle preview|
|`_`|Toggle preview (alternative)|
|`<Alt-j>`|Increase preview size|
|`<Alt-k>`|Decrease preview size|

---

## Searching

### Find (in current directory)

`f` opens a filter prompt. Type to narrow down visible files. Press `<Esc>` to clear.

### Search (fd / ripgrep integration)

|Key|Action|
|---|---|
|`s`|Search file names with fd|
|`S`|Search file contents with ripgrep|
|`<Ctrl-s>`|Cancel current search|

Results open in a virtual folder you can navigate like a regular directory.

---

## Configuration

Yazi stores its configuration in `~/.config/yazi/` (or `$XDG_CONFIG_HOME/yazi/`).

### Configuration Files

|File|Purpose|
|---|---|
|`yazi.toml`|General behavior and layout|
|`keymap.toml`|Keybindings|
|`theme.toml`|Colors and icons|

### yazi.toml Structure

```toml
[manager]
ratio = [1, 3, 4]           # Column width ratios (parent:current:preview)
sort_by = "alphabetical"    # Default sort
sort_sensitive = false      # Case-sensitive sort
sort_reverse = false
sort_dir_first = true       # Directories before files
linemode = "none"           # "none" | "size" | "permissions" | "mtime" | "user" | "group"
show_hidden = false
show_symlink = true

[preview]
tab_size = 2
max_width = 600
max_height = 900
cache_dir = ""              # Defaults to system cache

[opener]
# Define custom openers (see Openers section)

[open]
# File association rules

[tasks]
micro_workers = 10
macro_workers = 5
bizarre_retry = 3
image_alloc = 536870912     # 512MB image allocation

[log]
enabled = false
```

### keymap.toml

Override or add keybindings:

```toml
[manager]
keymap = [
    { on = ["g", "h"], run = "cd ~", desc = "Go to home" },
    { on = ["<Ctrl-e>"], run = "scroll 1", desc = "Scroll preview down" },
    { on = ["<Ctrl-y>"], run = "scroll -1", desc = "Scroll preview up" },
]
```

Each entry takes:

- `on`: key or sequence (string or array)
- `run`: the command to execute
- `desc`: description shown in `~` help

### Showing Hidden Files

Toggle with `<.>` (period key) while running, or set in config:

```toml
[manager]
show_hidden = true
```

---

## Openers and File Associations

Yazi lets you define "openers" and associate them with file types.

### Defining Openers

In `yazi.toml`:

```toml
[opener]
edit = [
    { run = 'nvim "$@"', block = true },
]
view_image = [
    { run = 'feh "$@"' },
]
play_video = [
    { run = 'mpv "$@"' },
]
```

- `block = true` means yazi waits for the program to exit (use for terminal apps like editors)
- `orphan = true` detaches the process (for GUI apps)

### File Associations

```toml
[open]
rules = [
    { mime = "text/*", use = "edit" },
    { mime = "image/*", use = "view_image" },
    { mime = "video/*", use = "play_video" },
    { name = "*.pdf", use = "open_pdf" },
]
```

Rules match on `mime` (MIME type glob) or `name` (filename glob). First match wins.

---

## Plugins

Yazi has a plugin system written in Lua. Plugins can extend previews, add new commands, change UI elements, and more.

### Installing Plugins

Yazi includes a built-in package manager (`ya pack`) as of recent versions. [Unverified — check current docs, as the CLI interface may have changed.]

```bash
ya pack -a username/plugin-name
```

To install manually, clone or copy the plugin into `~/.config/yazi/plugins/`.

### Plugin Directory Structure

```
~/.config/yazi/
└── plugins/
    └── my-plugin.yazi/
        ├── init.lua
        └── main.lua
```

### Writing a Basic Plugin

Plugins export a `setup` function and optionally a `fetch`, `peek`, or `seek` function for previewers:

```lua
-- ~/.config/yazi/plugins/hello.yazi/init.lua
return {
  setup = function(state, opts)
    -- called once on startup
  end,
}
```

For a custom previewer:

```lua
return {
  peek = function(job)
    local child = Command("cat")
      :args({ tostring(job.file.url) })
      :stdout(Command.PIPED)
      :spawn()
    -- render output...
  end,
}
```

### Notable Community Plugins

[Unverified — plugin availability and names change; check the official awesome-yazi list for current state.]

Some categories of plugins that exist in the community:

- **Previewers** for additional file types (e.g., Office documents, ePub)
- **Git integration** showing file status in the file list
- **Bookmarks** for saving and jumping to directories
- **Archive operations** for creating archives from selection

---

## Themes

Themes are configured in `~/.config/yazi/theme.toml`.

### Basic Color Configuration

```toml
[manager]
cwd = { fg = "cyan" }

[status]
separator_open  = ""
separator_close = ""

[filetype]
rules = [
    { mime = "image/*", fg = "yellow" },
    { mime = "video/*", fg = "magenta" },
    { mime = "audio/*", fg = "red" },
    { mime = "application/zip", fg = "green" },
    { name = "*.md", fg = "cyan" },
]
```

Colors can be named (`"red"`, `"cyan"`) or hex (`"#FF5555"`).

### Using a Community Theme

Community themes typically provide a full `theme.toml`. Copy it to `~/.config/yazi/theme.toml` or use `ya pack` if the theme is packaged.

### Icons

Icon display requires a Nerd Font installed and your terminal configured to use it. In `theme.toml`:

```toml
[icon]
rules = [
    { name = "*.rs", text = "" },
    { name = "*.py", text = "" },
    { name = "*.js", text = "" },
    { mime = "image/*", text = "" },
    { mime = "video/*", text = "" },
    { mime = "inode/directory", text = "" },
]
```

---

## Shell Integration

### Change Directory on Exit

See the wrapper function in the Starting Yazi section above (`y` function). This is the standard approach and is documented officially.

### Environment Variables

|Variable|Effect|
|---|---|
|`YAZI_CONFIG_HOME`|Override config directory|
|`YAZI_FILE_ONE`|Path to `file(1)` binary for MIME detection|
|`NO_COLOR`|Disable color output|

### Passing Arguments

```bash
yazi /path/to/dir          # Open at a specific directory
yazi --chooser-file=/tmp/f # File chooser mode (output selected path)
yazi --cwd-file=/tmp/cwd   # Write CWD on exit to this file
```

---

## Tasks and Background Operations

Yazi processes file operations (copy, move, delete) as background tasks. You can monitor them:

|Key|Action|
|---|---|
|`w`|Open task manager|
|In task manager: `<Esc>`|Close task manager|
|In task manager: `x`|Cancel selected task|

Large transfers or bulk operations run without blocking navigation.

---

## Command Line (`ya` CLI)

`ya` is the companion CLI binary installed alongside `yazi`:

```bash
ya pub          # Publish an event to running yazi instances
ya pack         # Plugin/theme package manager
ya doc          # Show documentation
```

The `ya pub` command is used to emit custom events from external scripts, which running yazi instances can subscribe to via plugins.

---

## Useful Recipes

### Open a File Manager at the Current Git Root

```bash
function yr() {
    y "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
}
```

### Use yazi as a File Chooser (from another app)

```bash
yazi --chooser-file=/tmp/chosen
cat /tmp/chosen
```

This opens yazi in chooser mode; pressing `<Enter>` on a file writes its path to the specified file and exits.

### Bulk Rename with an Editor

Yazi does not have a built-in bulk rename command as of the time of writing, but community plugins exist for this. [Unverified — check current plugin ecosystem.]

A common workaround:

1. Select files with `<Space>` or `<Ctrl-a>`
2. Press `;` to open a shell
3. Use a rename tool like `vidir` (from `moreutils`) or `mmv`

---

## Comparison with Similar Tools

|Feature|Yazi|Ranger|lf|Nnn|
|---|---|---|---|---|
|Language|Rust|Python|Go|C|
|Async I/O|Yes|No|Partial|No|
|Image preview|Multiple protocols|Überzug|Überzug|Via plugins|
|Plugin language|Lua|Python|Shell|Shell/Go|
|Startup speed|Fast|Slower|Fast|Very fast|
|Config complexity|Moderate|Moderate|Simple|Minimal|

[Inference: this table reflects general architectural differences; specific behavior in your environment depends on your configuration and terminal.]

---

## Troubleshooting

### Images Not Showing

- Verify your terminal supports an image protocol (kitty, iTerm2, WezTerm, or a Sixel-capable terminal)
- Check that the relevant tool is installed (`ffmpegthumbnailer` for video, etc.)
- Try running `yazi` with `YAZI_LOG=debug yazi 2>/tmp/yazi.log` and inspect the log

### Slow Startup or Preview

- The first run generates preview caches; subsequent runs are faster
- Reduce `max_width`/`max_height` in `[preview]` for large images
- Reduce `macro_workers` and `micro_workers` if the system is I/O constrained

### Icons Not Displaying

- Confirm a Nerd Font is installed
- Confirm your terminal is using the Nerd Font
- Confirm `$TERM` is set correctly

### Config Not Loading

- Default config path is `~/.config/yazi/`; override with `YAZI_CONFIG_HOME`
- Syntax errors in TOML will silently fall back to defaults in some versions — validate your TOML with a linter

---

## Further Resources

- Official documentation: https://yazi-rs.github.io/docs/
- GitHub repository: https://github.com/sxyazi/yazi
- Awesome Yazi (community plugins/themes): https://github.com/yazi-rs/awesome-yazi

[Unverified: URLs are accurate as of the knowledge cutoff but may change.]