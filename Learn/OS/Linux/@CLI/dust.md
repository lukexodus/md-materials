# dust

A modern replacement for `du`. Shows disk usage as a tree with a visual bar, sorted by size, with smart truncation so output always fits your terminal.

---

## Installation

|OS|Command|
|---|---|
|macOS|`brew install dust`|
|Ubuntu/Debian|`sudo apt install du-dust`|
|Fedora/RHEL|`sudo dnf install dust`|
|Arch|`sudo pacman -S dust`|
|Cargo (any)|`cargo install du-dust`|

---

## Basic Usage

```bash
dust                  # current directory
dust <path>           # specific path
dust ~                # home directory
dust /var/log         # any absolute path
dust . /tmp           # multiple paths at once
```

**Example output:**

```
  1.2G   ┌── node_modules   │████████████████████ │  62%
478M     ├── .git            │████████░░░░░░░░░░░░ │  24%
180M     ├── dist            │███░░░░░░░░░░░░░░░░░ │   9%
 55M     ├── src             │█░░░░░░░░░░░░░░░░░░░ │   3%
1.9G   ┌─┴ my-project        │████████████████████ │ 100%
```

Sizes are shown in human-readable form. The bar represents each item's proportion of the parent directory.

---

## Flags & Options

### Depth & Scope

|Flag|Action|
|---|---|
|`-d <n>`|Limit display depth to `n` levels|
|`-s`|Show only the total for each argument (like `du -s`)|
|`--files-only` / `-F`|Show files only, no directories|

```bash
dust -d 2             # show only 2 levels deep
dust -d 1 ~           # top-level summary of home dir
dust -s /var /tmp     # totals only, no tree
```

### Sorting & Filtering

|Flag|Action|
|---|---|
|`-n <n>`|Show only the top `n` entries|
|`-e <regex>`|Only show entries matching regex|
|`-v <regex>`|Exclude entries matching regex|
|`-t`|Sort by file type/extension instead of size|

```bash
dust -n 10            # top 10 largest items
dust -e "\.log$"      # only show .log files
dust -v node_modules  # exclude node_modules
dust -v "\.git|node_modules"  # exclude multiple
```

### Display Options

|Flag|Action|
|---|---|
|`-r`|Reverse order (smallest first)|
|`-c`|No colors (plain output)|
|`-b`|No bars (size column only)|
|`-f`|Count files instead of disk usage|
|`-i`|Don't show percentages|
|`-w <n>`|Set terminal width manually|
|`-x`|Stay on one filesystem (don't cross mount points)|
|`-H`|Use SI units (1000-based) instead of binary (1024-based)|

```bash
dust -r               # smallest at top
dust -b               # clean output, no bars
dust -x /             # root fs only, skip /proc /sys etc.
dust -H               # 1GB instead of 931MiB style
```

### Symlinks & Permissions

|Flag|Action|
|---|---|
|`-l`|Count hard links multiple times|
|`-p`|Show full path for each entry|
|`--skip-total`|Don't print the total line at the bottom|

---

## Practical Examples

**Find what's eating disk in your home directory, 2 levels deep:**

```bash
dust -d 2 ~
```

**Top 10 largest files/dirs in /var, excluding logs:**

```bash
dust -n 10 -v "\.log" /var
```

**Check a directory without crossing into other filesystems:**

```bash
dust -x /
```

**Quick size summary of several directories:**

```bash
dust -s ~/Downloads ~/Documents ~/Desktop
```

**Find large files only (no directory rollups):**

```bash
dust -F ~
```

**Pipe-friendly — strip color and bars for scripting:**

```bash
dust -cb /var/log
```

**See only a specific file type:**

```bash
dust -e "\.mp4$" ~/Videos
```

---

## Comparison with `du`

|Task|`du`|`dust`|
|---|---|---|
|Current directory|`du -sh *`|`dust`|
|Limit depth|`du -d 2`|`dust -d 2`|
|Top-level summary|`du -sh`|`dust -s`|
|Exclude a pattern|`--exclude`|`dust -v <regex>`|
|Human-readable|`-h`|always on|
|Sorted by size|pipe to `sort -h`|always sorted|
|Visual bar|no|always shown|
|Respects terminal width|no|yes|

`du` is POSIX-standard and available everywhere. `dust` is more ergonomic for interactive use but won't be present on remote servers unless installed.

---

## Tips

**Quickly audit a full system** — run as root with `-x` to stay on the root filesystem and avoid hanging on `/proc` or `/sys`:

```bash
sudo dust -x -d 3 /
```

**Combine `-n` and `-d`** — `-n` limits how many rows are shown, `-d` limits how deep the tree goes. Use both together to get a tight summary:

```bash
dust -d 2 -n 20 ~
```

**Regex exclusions are applied to full paths** — so `-v src` will exclude anything with `src` anywhere in the path, not just at the top level. Be specific if needed:

```bash
dust -v "/node_modules"   # more targeted than just "node_modules"
```

**Not a substitute for `ncdu`** — dust is great for quick one-shot inspection. If you want to interactively browse and delete files, `ncdu` is the better tool for that workflow.