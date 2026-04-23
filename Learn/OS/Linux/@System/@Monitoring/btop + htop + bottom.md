# btop / htop / bottom 

All three are **terminal-based (TUI) system monitors**. They run inside your terminal and show live CPU, memory, disk, and process data — replacing the older `top` command with richer visuals and interactivity.

---

## Quick Summary

|Tool|Language|Best For|
|---|---|---|
|**btop**|C++|Richest visuals, GPU/temp monitoring, themes|
|**htop**|C|Mature/stable, strace/lsof integration, widely pre-installed|
|**bottom** (`btm`)|Rust|Cross-platform (incl. Windows), flexible widget layout|

---

## Installation

### btop

```bash
# Debian / Ubuntu
sudo apt install btop

# Arch / Manjaro
sudo pacman -S btop

# Fedora
sudo dnf install btop

# macOS
brew install btop

# Snap
sudo snap install btop
```

### htop

```bash
# Debian / Ubuntu
sudo apt install htop

# Arch / Manjaro
sudo pacman -S htop

# Fedora
sudo dnf install htop

# macOS
brew install htop
```

### bottom

> **Note:** The command is `btm`, not `bottom`, to avoid conflicts with other utilities.

```bash
# Cargo (Rust)
cargo install bottom

# Arch (AUR)
yay -S bottom

# macOS
brew install bottom

# Windows (Scoop)
scoop install bottom

# Windows (winget)
winget install Clement.bottom
```

---

## btop

### Launch

```bash
btop
btop --utf-force        # force UTF-8 symbols
btop --theme dracula    # load a theme by name
btop -lc                # low color mode
```

**Config:** `~/.config/btop/btop.conf`  
**Themes:** `~/.config/btop/themes/`

### Interface

- **Top row:** CPU graphs per core + aggregate
- **Middle row:** Memory/swap and network traffic
- **Bottom:** Scrollable, sortable process list

Full mouse support — click panels, scroll lists, click column headers to sort.

### Key Bindings

|Key|Action|
|---|---|
|`q` / `Esc`|Quit|
|`?`|Help overlay|
|`m`|Toggle menu|
|`1` `2` `3` `4`|Toggle CPU / Mem / Disk / Net panels|
|`p`|Toggle process panel|
|`f`|Filter / search processes (supports regex)|
|`e`|Cycle sort field|
|`r`|Reverse sort order|
|`t`|Toggle tree view|
|`k`|Kill selected process (SIGTERM)|
|`h`|Toggle detailed process view|
|`+` / `-`|Expand / collapse tree node|
|`Ctrl+R`|Reload config|

---

## htop

### Launch

```bash
htop
htop -u username              # show only one user's processes
htop -p 1234,5678             # monitor specific PIDs
htop --sort-key PERCENT_CPU   # start sorted by CPU
htop -d 5                     # set update delay (tenths of a second)
```

**Config:** `~/.config/htop/htoprc` (or legacy `~/.htoprc`)

### Interface

- **Top:** One bar per CPU core, plus memory and swap bars
- **Bottom:** Scrollable process list with a function-key menu bar

### Key Bindings

|Key|Action|
|---|---|
|`F1` / `h`|Help|
|`F2`|Setup screen (columns, colors, meters)|
|`F3` / `/`|Search by process name|
|`F4` / `\`|Filter process list|
|`F5`|Toggle tree view|
|`F6`|Choose sort column|
|`F7` / `]`|Increase priority (lower nice value)|
|`F8` / `[`|Decrease priority (raise nice value)|
|`F9` / `k`|Kill — opens signal selector|
|`F10` / `q`|Quit|
|`Space`|Tag / untag a process|
|`U`|Untag all|
|`u`|Filter by user|
|`s`|Attach strace to selected process|
|`l`|Show open files via lsof|
|`H`|Toggle user threads|
|`K`|Toggle kernel threads|

### Useful Setup Options (F2)

- **Columns:** Add `IO_READ_RATE`, `IO_WRITE_RATE`, `STARTTIME`, `COMM` for richer rows
- **Meters:** Rearrange or add CPU average, memory, load average bars at the top
- **Colors:** Choose from several built-in color schemes

---

## bottom (btm)

### Launch

```bash
btm
btm --basic         # simpler layout, good for small terminals / SSH
btm --battery       # add battery widget
btm --celsius       # temperature in Celsius
btm --fahrenheit    # temperature in Fahrenheit
btm -c path/to/config.toml
```

**Config:** `~/.config/bottom/bottom.toml`

### Interface

bottom uses a **widget-focus model** — keybinds apply to whichever widget is currently focused. Default widgets: CPU graph, memory graph, network graph, disk I/O, temperatures, process list.

### Key Bindings

|Key|Action|
|---|---|
|`q` / `Ctrl+C`|Quit|
|`?`|Help overlay|
|`Tab` / `Shift+Tab`|Next / previous widget|
|`e`|Expand focused widget to full screen|
|`f`|Freeze / unfreeze display|
|`Ctrl+R`|Reset zoom|
|`+` / `-`|Zoom time axis in/out (graph widgets)|
|`/` _(process widget)_|Search processes|
|`s` _(process widget)_|Open sort menu|
|`dd`|Kill selected process (SIGKILL)|
|`F9`|Send signal to process|
|Arrow keys|Navigate within focused widget|

### Custom Layouts

bottom supports a `[[row]]` / `[[col]]` layout syntax in its TOML config, letting you define exactly which widgets appear and their proportions. See the official docs for the full schema.

---

## Feature Comparison

|Feature|btop|htop|bottom|
|---|---|---|---|
|Mouse support|Full|Partial|Partial|
|CPU graphs (per-core)|Yes|No (bars)|Yes|
|Network graphs|Yes|No|Yes|
|Disk I/O graphs|Yes|No|Yes|
|Temperature monitoring|Yes|No|Yes|
|GPU monitoring|Yes (with drivers)|No|No|
|Process tree|Yes|Yes|No|
|strace integration|No|Yes|No|
|lsof integration|No|Yes|No|
|Signal selector|Yes|Yes|Yes|
|Nice / renice|Via signal|Yes (F7/F8)|No|
|Custom themes|Yes (files)|Built-in colors|Via config|
|Custom widget layout|Panel toggles|Meter order|Full TOML|
|Battery widget|No|No|Yes|
|Windows support|No|No|Yes|
|Freeze display|No|No|Yes|
|Scroll graph history|Yes|No|Yes|

> **[Inference]** Feature availability may vary by version and OS. Verify with `--help` or the tool's GitHub README for your specific installed version.

---

## Practical Tips

**Which should you use?**

- Use **htop** for strace/lsof integration, or if it's already available on a system.
- Use **btop** for the richest visuals, GPU monitoring, and themes.
- Use **bottom** for Windows/macOS, or if you want a fully configurable widget layout.

**Run as root for full visibility:**

```bash
sudo htop
sudo btop
sudo btm
```

Without root, processes owned by other users or system services may be hidden or un-signalable.

**Kill processes safely:** Always try SIGTERM (15) first — it requests a graceful exit. Only use SIGKILL (9) if SIGTERM does nothing after a few seconds. SIGKILL cannot be caught or ignored, but may leave resources uncleaned.

**Alias tip** — replace `top` with your preferred monitor:

```bash
# Add to ~/.bashrc or ~/.zshrc
alias top='btop'
```

**btop GPU monitoring** _(Linux):_ Requires `nvidia-smi` for NVIDIA cards. AMD support varies by version. [Unverified across all distro/driver combinations — confirm with your version's changelog.]

**bottom `--basic` mode:** Switches to a simpler layout useful for very small terminals or low-bandwidth SSH sessions.

---

> **[Unverified]** Some details here (e.g. GPU support, specific column names, default key bindings) may differ across distro-packaged versions vs. compiled-from-source. When in doubt, run `btop --help`, `htop --help`, or `btm --help` to confirm available flags on your system.