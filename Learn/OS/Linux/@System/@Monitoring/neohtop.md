# neohtop

---

## What It Is

**neohtop** is a cross-platform system monitor TUI (terminal UI) built with Rust and Tauri. It presents a real-time view of processes, CPU, memory, and swap — styled similarly to htop but with a more modern look.

> Note: neohtop is a relatively young project. Some details below may shift across versions. Verify against the current release if behavior differs.

---

## Installation

```bash
# Cargo (primary method)
cargo install neohtop

# Arch (AUR)
yay -S neohtop
# or
paru -S neohtop

# From releases
# https://github.com/Abdenasser/neohtop/releases
# Download binary, make executable, move to PATH
chmod +x neohtop
mv neohtop ~/.local/bin/
```

---

## Launch

```bash
neohtop
```

No flags or subcommands are documented as of the current release. It launches directly into the TUI.

---

## Interface Layout

The UI is divided into sections:

- **Top bar** — global CPU and memory/swap usage bars with percentages
- **Process table** — sortable list of running processes
- **Bottom bar** — keybinding hints

### Process Table Columns

|Column|Meaning|
|---|---|
|`PID`|Process ID|
|`Name`|Process name|
|`CPU%`|CPU usage percentage|
|`MEM%`|Memory usage percentage|
|`MEM`|Absolute memory usage|
|`Status`|Process state (running, sleeping, etc.)|
|`User`|Owning user|

---

## Keybindings

|Key|Action|
|---|---|
|`↑` / `↓`|Navigate process list|
|`k` / `j`|Navigate (vim-style)|
|`q`|Quit|
|`s`|Cycle sort column|
|`/`|Filter / search processes|
|`Esc`|Clear filter|
|`K`|Kill selected process (sends SIGKILL)|
|`F5` or `r`|Refresh / force update|

[Unverified] Some keybindings may vary by version — the bottom bar in the TUI displays current valid bindings and should be treated as the authoritative reference.

---

## Filtering

Press `/` to enter filter mode. Type any substring — the process list filters in real time to show only matching names.

Press `Esc` to clear and return to the full list.

---

## Sorting

Press `s` to cycle through sortable columns. The currently sorted column is visually highlighted. Sort order is typically descending (highest value first) — useful for immediately spotting CPU or memory hogs.

---

## Killing a Process

1. Navigate to the target process with `↑`/`↓` or `j`/`k`
2. Press `K`
3. The process receives `SIGKILL`

[Unverified] Whether a confirmation prompt appears depends on the version. Exercise caution — `SIGKILL` cannot be caught or ignored by the target process.

---

## Comparison to htop

|Feature|htop|neohtop|
|---|---|---|
|Language|C|Rust|
|Per-CPU bars|Yes|[Unverified]|
|Tree view|Yes|No (as of recent versions)|
|Mouse support|Yes|Limited|
|Custom meters|Yes|No|
|Color themes|Yes|Preset only|
|Kill signals (choice)|Yes|SIGKILL only|
|Maturity|Very stable|Early-stage|

neohtop trades htop's configurability for a cleaner out-of-the-box appearance.

---

## Tips & Gotchas

- **Requires root for some processes** — processes owned by other users may show limited info without `sudo neohtop`
- **Not a drop-in htop replacement** — lacks htop's depth of configuration, signal selection, and tree view
- **Tauri dependency** — neohtop uses Tauri internally; this brings in some system library requirements (webkit2gtk on Linux)
- **Binary size** — larger than typical TUI tools due to Tauri
- **Active development** — the project is young; feature set and keybindings may change between releases; check the GitHub repo for the changelog

---

## Quick Reference

```
neohtop              Launch
↑ / ↓  or  j / k    Navigate
/                    Filter processes
Esc                  Clear filter
s                    Cycle sort column
K                    Kill selected process
q                    Quit
```

---

## Alternatives (if neohtop doesn't fit)

|Tool|Notes|
|---|---|
|`htop`|Most featureful, very stable|
|`btop`|Modern look, highly configurable, mouse support|
|`bottom` (`btm`)|Rust-based, graphs, cross-platform|
|`gtop`|Node.js, dashboard-style|
|`procs`|Rust, enhanced `ps` replacement (not interactive)|