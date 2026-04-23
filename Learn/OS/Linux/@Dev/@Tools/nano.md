# Nano

## What is Nano?

Nano is a terminal-based text editor for Unix-like systems. It's designed to be simple and accessible, displaying keyboard shortcuts at the bottom of the screen rather than relying on modal editing or complex commands.

---

## Opening and Creating Files

```bash
nano filename.txt        # Open existing or create new file
nano +10 filename.txt    # Open at line 10
nano -l filename.txt     # Show line numbers on open
nano -B filename.txt     # Backup file before editing
```

---

## Interface Overview

When nano opens, you'll see:

- **Top bar** — editor name and filename
- **Main editing area** — your file content
- **Bottom two rows** — shortcut reference (`^` means Ctrl, `M-` means Alt)

---

## Essential Shortcuts

### File Operations

|Shortcut|Action|
|---|---|
|`Ctrl+S`|Save (modern nano)|
|`Ctrl+O`|Write/save file (classic)|
|`Ctrl+X`|Exit (prompts to save if unsaved changes)|
|`Ctrl+R`|Insert another file into current buffer|

### Navigation

|Shortcut|Action|
|---|---|
|`Ctrl+A`|Beginning of line|
|`Ctrl+E`|End of line|
|`Ctrl+Y`|Page up|
|`Ctrl+V`|Page down|
|`Ctrl+_`|Go to specific line (and column)|
|`Ctrl+←` / `Ctrl+→`|Jump word left/right|

### Search and Replace

|Shortcut|Action|
|---|---|
|`Ctrl+W`|Search (find)|
|`Ctrl+W` then `Ctrl+R`|Search and replace|
|`Alt+W`|Find next match|
|`Alt+Q`|Find previous match|

> In the search prompt, `Alt+C` toggles case sensitivity, `Alt+R` toggles regex.

### Editing

|Shortcut|Action|
|---|---|
|`Ctrl+K`|Cut current line|
|`Alt+6`|Copy current line|
|`Ctrl+U`|Paste|
|`Ctrl+Space`|Set mark (begin selection)|
|`Alt+A`|Set mark (alternative)|
|`Ctrl+\`|Search and replace (alternative)|
|`Alt+U`|Undo|
|`Alt+E`|Redo|

### Deletion

|Shortcut|Action|
|---|---|
|`Ctrl+H`|Delete character left (backspace)|
|`Ctrl+D`|Delete character right|
|`Alt+Backspace`|Delete word left|
|`Ctrl+Delete`|Delete word right|

---

## Multiple Buffers (Tabs)

```bash
nano file1.txt file2.txt     # Open multiple files
```

|Shortcut|Action|
|---|---|
|`Alt+<`|Switch to previous buffer|
|`Alt+>`|Switch to next buffer|
|`Ctrl+R`|Open additional file in new buffer|

---

## Configuration: `~/.nanorc`

Nano reads its config from `~/.nanorc` (user) or `/etc/nanorc` (system-wide).

### Common settings

```bash
set linenumbers          # Show line numbers
set autoindent           # Preserve indentation on new lines
set tabsize 4            # Tab width
set tabstospaces         # Convert tabs to spaces
set mouse                # Enable mouse support
set softwrap             # Wrap long lines visually
set nowrap               # Disable line wrapping
set casesensitive        # Search case-sensitive by default
set smooth               # Smooth scrolling (older versions)
set backup               # Auto-backup files before editing
set backupdir "~/.nano-backups"
set constantshow         # Always show cursor position
```

### Syntax highlighting

Nano ships with highlight definitions. Enable them in `~/.nanorc`:

```bash
include "/usr/share/nano/*.nanorc"
# Or specific ones:
include "/usr/share/nano/python.nanorc"
include "/usr/share/nano/sh.nanorc"
```

Custom highlight rules follow this pattern:

```bash
syntax "mytype" "\.ext$"
color green "\bkeyword\b"
color red "\"[^\"]*\""
```

---

## Useful Command-Line Flags

|Flag|Effect|
|---|---|
|`-l`|Line numbers|
|`-m`|Mouse support|
|`-i`|Auto-indent|
|`-w`|Disable line wrapping|
|`-B`|Backup before saving|
|`-E`|Convert tabs to spaces|
|`-T n`|Set tab width to n|
|`-c`|Constantly show cursor position|
|`-z`|Enable suspend (`Ctrl+Z`)|
|`--rcfile file`|Use alternate config file|

---

## Tips and Less-Known Features

**Suspend to shell** Add `set suspend` to `~/.nanorc`, then use `Ctrl+Z` to background nano and return with `fg`.

**Jump to matching bracket** `Alt+]` jumps to the matching bracket, brace, or parenthesis.

**Word count and position** `Ctrl+C` displays current cursor position and file statistics without cutting anything.

**Spell check** `Ctrl+T` runs spell check if a spell checker (`spell`, `aspell`, or `hunspell`) is installed.

**Pipe content into nano**

```bash
echo "hello" | nano -
cat file.txt | nano -
```

**Hex editing mode** `nano -H file` opens in hex mode (available in newer versions — verify your version supports it with `nano --version`).

---

## Version Notes

Nano's feature set varies by version. Features like `Ctrl+S`, undo/redo, and multiple buffers were added in versions 2.x and 3.x. If a shortcut doesn't work, check your version:

```bash
nano --version
```

---

## Quick Reference Card

```
Save        Ctrl+O / Ctrl+S     Exit         Ctrl+X
Find        Ctrl+W              Replace      Ctrl+\
Cut line    Ctrl+K              Paste        Ctrl+U
Copy line   Alt+6               Undo         Alt+U
Go to line  Ctrl+_              Mark text    Ctrl+Space
Prev buffer Alt+<               Next buffer  Alt+>
```