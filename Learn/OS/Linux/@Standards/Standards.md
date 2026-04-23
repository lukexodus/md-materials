## XDG Base Directory Specification

The XDG Base Directory Specification is a standard created by freedesktop.org that defines where applications should store user-specific files on Linux and Unix-like systems. XDG stands for "X Desktop Group" (now freedesktop.org).

### Core Environment Variables

**`XDG_DATA_HOME`**

- Default: `~/.local/share`
- Purpose: User-specific data files
- Examples: Application databases, user-installed plugins

**`XDG_CONFIG_HOME`**

- Default: `~/.config`
- Purpose: User-specific configuration files
- Examples: Application settings, preferences

**`XDG_CACHE_HOME`**

- Default: `~/.cache`
- Purpose: Non-essential cached data
- Examples: Thumbnails, temporary downloads

**`XDG_STATE_HOME`**

- Default: `~/.local/state`
- Purpose: State data that should persist between restarts
- Examples: Logs, history, recent files

**`XDG_RUNTIME_DIR`**

- No default (must be set by system)
- Purpose: Runtime files (sockets, pipes)
- Requirements: Must be user-owned, mode 0700, cleared on logout

### Additional Variables

**`XDG_DATA_DIRS`**

- Default: `/usr/local/share:/usr/share`
- Purpose: Ordered list of directories to search for data files

**`XDG_CONFIG_DIRS`**

- Default: `/etc/xdg`
- Purpose: Ordered list of directories to search for configuration files

### Why XDG Matters

Before XDG, applications cluttered the home directory with dotfiles (`.applicationname`). XDG organizes files into logical categories, making backups and system management easier.

### Example Usage

A compliant application storing settings:

```
$XDG_CONFIG_HOME/myapp/settings.conf
→ ~/.config/myapp/settings.conf
```

---