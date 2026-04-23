# atuin

A shell history manager that replaces your shell's default history with a searchable, syncable, SQLite-backed database. Written in Rust by Ellie Huxtable.

> atuin stores history with context: exit code, working directory, hostname, session, duration. It does not just store the command string.

**Official repo:** `github.com/atuinsh/atuin`  
**Docs:** `docs.atuin.sh`

---

## Table of Contents

1. [What is atuin?](#what-is-atuin)
2. [Installation](#installation)
3. [Shell Integration](#shell-integration)
4. [Interactive Search](#interactive-search)
5. [Search Modes](#search-modes)
6. [Filtering & Querying](#filtering--querying)
7. [Sync & Accounts](#sync--accounts)
8. [Import Existing History](#import-existing-history)
9. [Stats](#stats)
10. [Managing History](#managing-history)
11. [Configuration](#configuration)
12. [Key Bindings](#key-bindings)
13. [Self-hosting the Sync Server](#self-hosting-the-sync-server)
14. [Practical Tips](#practical-tips)
15. [Quick Cheatsheet](#quick-cheatsheet)

---

## What is atuin?

atuin replaces your shell's history (the flat text file at `~/.bash_history`, `~/.zsh_history`, etc.) with a local SQLite database. Every command is stored with:

- The command string
- Exit code
- Working directory at the time
- Hostname
- Shell session ID
- Timestamp
- Duration (how long the command took)

On top of that, atuin offers optional **encrypted sync** across machines via a hosted server (atuin.sh) or a self-hosted instance.

**Key features:**

- Full-text search with fuzzy or prefix matching
- Filter by directory, host, session, exit code, time
- Sync history across machines (end-to-end encrypted)
- Cross-shell: Bash, Zsh, Fish, Nushell, Xonsh
- Does not delete your existing shell history file

---

## Installation

### macOS

```sh
brew install atuin
```

### Linux

```sh
# Recommended: install script
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# Arch Linux
sudo pacman -S atuin

# Nix
nix-env -iA nixpkgs.atuin

# Cargo
cargo install atuin
```

### Windows

```sh
# Winget
winget install atuinsh.atuin

# Scoop
scoop install atuin

# Cargo
cargo install atuin
```

> **Note:** Windows support is available but primarily targets PowerShell and the newer Windows Terminal. Some features may behave differently. Check the official docs for current Windows status.

Verify: `atuin --version`

---

## Shell Integration

After installing, add the integration to your shell config. This is what hooks atuin into `↑` (up arrow) and `ctrl+r`.

### Bash

```sh
# Add to ~/.bashrc
eval "$(atuin init bash)"
```

### Zsh

```sh
# Add to ~/.zshrc
eval "$(atuin init zsh)"
```

### Fish

```sh
# Add to ~/.config/fish/config.fish
atuin init fish | source
```

### Nushell

```sh
# Run once to generate the config snippet:
atuin init nu
# Then follow the output instructions — it writes to your env.nu / config.nu
```

### Xonsh

```sh
# Add to ~/.xonshrc
execx($(atuin init xonsh))
```

After adding the init line, restart your shell or `source` the config file.

---

## Interactive Search

The main interface. Triggered by:

- `ctrl+r` — open atuin search
- `↑` (up arrow) — also opens atuin search (replaces default history traversal)

You can configure which keys trigger atuin — see [Key Bindings](#key-bindings).

### Inside the search UI

Type to filter results. The list updates in real time.

```
> git commit                         ← your query
──────────────────────────────────────────────────
  git commit --amend --no-edit       2m ago  ~/proj
  git commit -m "fix: typo"         1h ago  ~/proj
  git commit -m "initial commit"    2d ago  ~/other
```

Each result shows:

- The command
- How long ago it was run
- The directory it was run in (if `show_preview` or `inline_height` is configured)

### Navigation inside search

| Key | Action |
|---|---|
| `↑` / `↓` | Move through results |
| `ctrl+n` / `ctrl+p` | Move down / up (vim-style) |
| `Enter` | Accept and run selected command |
| `Tab` | Accept selected command into prompt (don't run) |
| `ctrl+o` | Accept and run (same as Enter) |
| `Esc` | Cancel, return to prompt |
| `ctrl+r` | Cycle search mode (see below) |
| `ctrl+d` | Delete selected entry from history |
| `ctrl+s` | Cycle filter mode |

---

## Search Modes

atuin supports multiple matching strategies, toggled with `ctrl+r` inside the search UI or set as the default in config.

| Mode | Behavior |
|---|---|
| `prefix` | Match from the beginning of the command |
| `fulltext` | Match anywhere in the command string |
| `fuzzy` | Fuzzy match (non-contiguous characters) |
| `skim` | Uses the skim fuzzy-finder algorithm |

Set the default in `config.toml`:

```toml
search_mode = "fuzzy"
```

---

## Filtering & Querying

### Filter modes (inside search UI)

Press `ctrl+s` to cycle through:

| Filter | Behavior |
|---|---|
| `global` | All history from all hosts and directories |
| `host` | History from the current machine only |
| `session` | History from the current shell session only |
| `directory` | History from the current working directory only |

Set the default:

```toml
filter_mode = "host"
```

You can also set a different default for the up-arrow vs `ctrl+r`:

```toml
filter_mode_shell_up_key_binding = "directory"
```

This is useful: up arrow searches current directory history, `ctrl+r` searches everything.

### CLI search

Search from the command line without the interactive UI:

```sh
atuin search QUERY
atuin search "git commit"
atuin search --cwd /path/to/dir    # filter by directory
atuin search --host mymachine      # filter by hostname
atuin search --exit 0              # only successful commands
atuin search --exit 1              # only failed commands
atuin search --before "2024-01-01"
atuin search --after "2024-06-01"
atuin search --limit 50            # limit results
atuin search --offset 10           # skip first N results
atuin search -i QUERY              # open interactive UI pre-filtered
```

### Combining filters

```sh
atuin search --cwd ~/projects --exit 0 "docker"
# → successful docker commands run inside ~/projects
```

---

## Sync & Accounts

Sync is optional. History is **end-to-end encrypted** — the server never sees plaintext commands.

### Create an account (atuin.sh hosted)

```sh
atuin register -u <username> -e <email> -p <password>
```

### Log in on another machine

```sh
atuin login -u <username> -p <password>
```

### Sync manually

```sh
atuin sync
```

### Auto-sync

Enable in config:

```toml
[sync]
enabled = true

auto_sync = true
sync_frequency = "5m"    # sync every 5 minutes
```

### Log out

```sh
atuin logout
```

### Encryption key

atuin generates an encryption key stored locally at `~/.local/share/atuin/key`. **Back this up.** If you lose it, your synced history cannot be decrypted — not even by the server.

```sh
atuin key                # print your key (for backup or transfer)
```

To import your key on a new machine:

```sh
atuin key import          # prompts you to paste the key
```

---

## Import Existing History

atuin can import your existing shell history into its database.

```sh
atuin import auto         # detect shell and import automatically

atuin import bash         # import from ~/.bash_history
atuin import zsh          # import from ~/.zsh_history
atuin import zsh-hist-db  # import from zsh's extended history format
atuin import fish         # import from fish history
atuin import nu           # import from Nushell history
atuin import resh         # import from RESH
```

Import is safe — it does not delete your existing history file.

---

## Stats

atuin can show statistics about your command usage.

```sh
atuin stats               # overall stats (top commands, total count, etc.)
atuin stats git           # stats filtered to commands starting with 'git'
```

Example output:

```
Total commands:   48,301
Unique commands:  12,847

Top 10 commands:
  1  git        8,204  (16.9%)
  2  cd         5,103  (10.5%)
  3  ls         3,891   (8.0%)
  4  vim        2,744   (5.6%)
  5  cargo      1,892   (3.9%)
```

---

## Managing History

### View history (non-interactive)

```sh
atuin history list                  # list all history
atuin history list --limit 20       # last 20 entries
atuin history list --cwd .          # history from current directory
```

### Delete entries

```sh
# Inside interactive search: ctrl+d on selected entry

# From CLI — delete by ID
atuin history delete <ID>

# Delete all entries matching a command string
atuin search "some command" --delete
```

> **Note:** Deletions sync across machines on next sync.

### Count entries

```sh
atuin history count
```

---

## Configuration

The config file is at:

- **macOS / Linux:** `~/.config/atuin/config.toml`
- **Windows:** `%APPDATA%\atuin\config.toml`

Run `atuin config` to print the path on your system.

### Full annotated config

```toml
## Search behavior
search_mode = "fuzzy"
# Options: prefix | fulltext | fuzzy | skim

filter_mode = "global"
# Options: global | host | session | directory
# This is the default for ctrl+r

filter_mode_shell_up_key_binding = "directory"
# Default filter mode when using the up arrow key
# Useful: up = local context, ctrl+r = global

## UI
style = "auto"
# Options: auto | full | compact

inline_height = 20
# Number of lines for the inline search window (0 = full screen)

show_preview = true
# Show a preview of the selected command at the bottom

show_help = true
# Show key binding hints at the bottom of the search UI

max_preview_height = 4
# Max lines for the preview area

show_tabs = true
# Show filter mode and search mode tabs in the UI

## History behavior
history_filter = [
  "^secret",           # exclude commands starting with 'secret'
  "^ ",                # exclude commands starting with a space (like bash HISTIGNORE)
]
# Regex patterns — matching commands are NOT saved to atuin

cwd_filter = [
  "^/private",         # don't record history when in /private
]

exit_mode = "return-original"
# What happens when you press Esc in search:
# return-original: restore the original line
# return-query: keep what you typed in search

## Sync
[sync]
enabled = true

auto_sync = true
sync_frequency = "10m"

sync_address = "https://api.atuin.sh"
# Change this if self-hosting

## Keys
[keys]
scroll_exits = false
# If true, scrolling past the top of results exits search

[stats]
common_subcommands = ["cargo", "git", "go", "kubectl", "npm", "yarn", "pnpm"]
# Subcommands to expand in stats (e.g. 'git' shows 'git commit', 'git push', etc.)

common_prefix = ["sudo"]
# Prefixes to strip when counting commands in stats
```

### Ignoring commands

Two ways to prevent a command from being saved:

**1. Via `history_filter` in config** — regex-based, permanent:

```toml
history_filter = [
  "^secret",
  "^password",
  " --password",
]
```

**2. Via leading space** — add `history_filter = ["^ "]` and then prefix any command with a space:

```sh
 my-secret-command     # leading space → not recorded (if filter is set)
```

This mimics Bash's `HISTIGNORE` behavior.

---

## Key Bindings

### Disable up-arrow binding

If you want `ctrl+r` but not the up-arrow override:

```sh
# Bash / Zsh
eval "$(atuin init zsh --disable-up-arrow)"

# Fish
atuin init fish --disable-up-arrow | source
```

### Disable ctrl+r binding

```sh
eval "$(atuin init zsh --disable-ctrl-r)"
```

### Both disabled (manual binding only)

```sh
eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"
# Then bind manually in your shell config
```

### Zsh: custom binding example

```sh
eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"
bindkey '^r' atuin-search       # ctrl+r
bindkey '^[[A' atuin-up-search  # up arrow
```

---

## Self-hosting the Sync Server

If you do not want to use atuin.sh, you can run your own sync server.

### Docker (recommended)

```yaml
# docker-compose.yml
services:
  atuin:
    image: ghcr.io/atuinsh/atuin:latest
    command: server start
    volumes:
      - ./atuin-data:/config
    environment:
      ATUIN_HOST: "0.0.0.0"
      ATUIN_PORT: "8888"
      ATUIN_OPEN_REGISTRATION: "true"
      ATUIN_DB_URI: "sqlite:///config/atuin.db"
    ports:
      - "8888:8888"
```

```sh
docker compose up -d
```

### Point clients to your server

In `~/.config/atuin/config.toml`:

```toml
[sync]
sync_address = "https://your-server.example.com"
```

Then register normally:

```sh
atuin register -u <username> -e <email> -p <password>
```

> **Note:** Even on a self-hosted server, all history is end-to-end encrypted with your local key. The server stores only ciphertext.

---

## Practical Tips

**Search current directory only by default with up arrow:**

```toml
filter_mode_shell_up_key_binding = "directory"
```

Now pressing `↑` shows only commands you've run in the current directory — much more contextual than global history.

**Tab to edit, not run:**
Press `Tab` in search to drop the selected command into your prompt without running it. Useful for commands you want to modify before executing.

**See how long commands took:**
History entries store duration. When reviewing history, slow commands stand out. [Inference: this could help identify bottlenecks in scripts, though workflow depends on your setup.]

**Combine with zoxide:**
`atuin` (history) + `zoxide` (directory jumping) + `fd` (file finding) is a common Rust CLI stack. They do not integrate directly but complement each other — each improves a different part of the shell workflow.

**Check what atuin is recording:**

```sh
atuin history list --limit 10
```

**Audit commands recorded from a specific session:**

```sh
atuin search --session <session-id>
```

**Use `--exit 1` to find commands that failed:**

```sh
atuin search --exit 1 "docker"
# → find all failed docker commands
```

This is useful for debugging: find what you tried before it worked.

**Backup your encryption key:**

```sh
atuin key > ~/atuin-key-backup.txt
# Store this somewhere secure — without it, synced history is unrecoverable
```

---

## Quick Cheatsheet

### CLI commands

| Command | Action |
|---|---|
| `atuin search QUERY` | Non-interactive search |
| `atuin search -i QUERY` | Interactive search pre-filtered |
| `atuin history list` | List all history |
| `atuin history count` | Count total entries |
| `atuin stats` | Show usage statistics |
| `atuin sync` | Manually sync |
| `atuin import auto` | Import existing shell history |
| `atuin register` | Create account |
| `atuin login` | Log in on a new machine |
| `atuin logout` | Log out |
| `atuin key` | Print encryption key |
| `atuin config` | Print config file path |
| `atuin doctor` | Diagnose setup issues |

### Search flags

| Flag | Meaning |
|---|---|
| `--cwd PATH` | Filter by directory |
| `--host HOST` | Filter by hostname |
| `--exit CODE` | Filter by exit code |
| `--before DATE` | Before a date/time |
| `--after DATE` | After a date/time |
| `--limit N` | Limit results |
| `--delete` | Delete matching entries |

### Interactive search keys

| Key | Action |
|---|---|
| `ctrl+r` | Open search / cycle search mode |
| `ctrl+s` | Cycle filter mode |
| `↑` / `↓` | Navigate results |
| `Enter` | Run selected command |
| `Tab` | Insert into prompt (don't run) |
| `ctrl+d` | Delete selected entry |
| `Esc` | Cancel |

### Config quick reference

| Setting | Recommended value |
|---|---|
| `search_mode` | `"fuzzy"` |
| `filter_mode` | `"global"` |
| `filter_mode_shell_up_key_binding` | `"directory"` |
| `inline_height` | `20` |
| `show_preview` | `true` |
| `auto_sync` | `true` |
| `sync_frequency` | `"10m"` |

---

*Source: [atuin GitHub repository](https://github.com/atuinsh/atuin) and [docs.atuin.sh](https://docs.atuin.sh). Always check the official docs for your installed version — atuin is actively developed and options change across releases.*