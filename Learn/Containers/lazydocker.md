# lazydocker

A terminal UI for Docker and Docker Compose, written in Go by Jesse Duffield (same author as lazygit). Provides a single-pane interface for managing containers, images, volumes, networks, and services without typing raw `docker` commands repeatedly.

---

## Installation

### Arch Linux (AUR)

```bash
paru -S lazydocker
# or
yay -S lazydocker
```

### Go Install

```bash
go install github.com/jesseduffield/lazydocker@latest
```

Binary placed in `$GOPATH/bin` or `$HOME/go/bin`. Ensure that is in `$PATH`.

### Manual Binary (GitHub Releases)

```bash
curl -Lo lazydocker.tar.gz \
  "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_Linux_x86_64.tar.gz"
tar xf lazydocker.tar.gz
sudo mv lazydocker /usr/local/bin/
```

### Docker (No Local Install)

```bash
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$HOME/.config/lazydocker:/.config/jesseduffield/lazydocker" \
  lazyteam/lazydocker
```

Useful on systems where installing a binary is restricted.

---

## Launching

```bash
lazydocker
```

To scope to a specific Docker Compose project directory:

```bash
cd /path/to/compose-project && lazydocker
```

lazydocker auto-detects `docker-compose.yml` or `compose.yaml` in the working directory.

---

## Interface Layout

The UI is divided into two primary regions: the **left panel** (navigation sidebar) and the **right panel** (detail/context pane).

### Left Panel — Navigation Columns

Five tabs appear as columns in the sidebar, navigated with `[` and `]` or by clicking:

|Column|Content|
|---|---|
|`Project`|Docker Compose project overview, service list|
|`Containers`|All running and stopped containers|
|`Images`|All local images|
|`Volumes`|Named and anonymous volumes|
|`Networks`|Docker networks|

### Right Panel — Context Tabs

When an item is selected in the left panel, the right panel shows context tabs. These vary by entity type but commonly include:

- `Logs` — live-streaming stdout/stderr
- `Stats` — CPU, memory, network I/O, block I/O
- `Config` — full inspect output (JSON)
- `Top` — processes running inside the container (like `docker top`)
- `Env` — environment variables
- `Ports` — port mappings

Navigate right-panel tabs with `[` / `]` (same keys — context-sensitive to which panel has focus).

---

## Keybindings — Global

|Key|Action|
|---|---|
|`q`|Quit|
|`?`|Toggle keybinding help panel|
|`[` / `]`|Switch left-panel columns or right-panel tabs|
|`↑` / `↓` or `j` / `k`|Move selection up/down|
|`Enter`|Confirm / drill into item|
|`Esc`|Go back / close modal|
|`x`|Open command menu for selected item|
|`/`|Filter list (type to search)|
|`Ctrl+c`|Force quit|

---

## Keybindings — Containers

|Key|Action|
|---|---|
|`u`|Start container|
|`s`|Stop container|
|`r`|Restart container|
|`d`|Remove container|
|`D`|Force remove container|
|`e`|Exec into container shell (opens `sh` or `bash`)|
|`l`|View logs (focus right panel on Logs tab)|
|`b`|Open bulk actions menu|
|`t`|Show container details/top|
|`m`|View mounted volumes|
|`p`|Pause / unpause container|
|`c`|Copy container name|

The `x` key on a container opens an extended command menu with additional options not mapped to single keys.

---

## Keybindings — Images

|Key|Action|
|---|---|
|`d`|Remove image|
|`D`|Force remove image|
|`p`|Pull latest version of image|
|`c`|Copy image ID|
|`r`|Run a new container from image|

---

## Keybindings — Volumes

|Key|Action|
|---|---|
|`d`|Remove volume|
|`D`|Force remove volume|
|`c`|Copy volume name|

---

## Keybindings — Networks

|Key|Action|
|---|---|
|`d`|Remove network|
|`c`|Copy network name|

---

## Keybindings — Project / Compose

When a Compose project is detected, the `Project` column becomes active with service-level operations:

|Key|Action|
|---|---|
|`u`|`docker compose up` (all services)|
|`s`|`docker compose stop`|
|`d`|`docker compose down`|
|`D`|`docker compose down --volumes`|
|`r`|`docker compose restart`|
|`R`|Rebuild and up (`--build`)|
|`l`|View all service logs aggregated|

Service-level granularity is available by selecting an individual service within the Project column.

---

## Log Viewing

When the Logs tab is focused on the right panel:

|Key|Action|
|---|---|
|`f`|Toggle follow mode (tail -f behavior)|
|`Ctrl+f`|Page down|
|`Ctrl+b`|Page up|
|`g`|Jump to top|
|`G`|Jump to bottom|
|`w`|Toggle line wrapping|
|`/`|Search within logs|
|`n` / `N`|Next / previous search match|

Logs are streamed live by default when follow mode is on.

---

## Stats View

The Stats tab displays real-time resource consumption for the selected container. Metrics shown:

- CPU usage (%)
- Memory usage and limit
- Network I/O (bytes in/out)
- Block I/O (disk read/write)
- PIDs count

Data refreshes on the interval set in config (`refreshRate`).

---

## Shell Exec

Pressing `e` on a container drops into an interactive shell inside the container. lazydocker attempts `bash` first, then falls back to `sh`. The shell is run via `docker exec -it <container> bash` (or `sh`) under the hood.

To exec with a custom command instead, use `x` → command menu → exec option, and type the command manually.

---

## Configuration

### Config File Location

```
~/.config/lazydocker/config.yml
```

Create it if it does not exist.

### Full Config Reference (Annotated)

```yaml
# GUI settings
gui:
  # Scroll height for mouse wheel
  scrollHeight: 2

  # Theme (default: auto-inherits terminal colors)
  theme:
    activeBorderColor:
      - green
      - bold
    inactiveBorderColor:
      - white
    selectedLineBgColor:
      - blue
    optionsTextColor:
      - blue

  # Return to top of list on focus change
  returnImmediately: false

  # Wrap long lines in log view
  wrapMainPanel: true

  # Side panel width as fraction of terminal width
  sidePanelWidth: 0.3333

  # Expanded view for selected item
  expandFocusedSidePanel: false

  # Show bottom line (key hint bar)
  showBottomLine: true

# Logs
logs:
  # Number of lines to show initially
  tail: 200

  # Time format for log timestamps
  timestamps: false

  # Since duration (e.g., "1h", "30m")
  since: ''

  # Show log prefix (container name)
  showTimestamp: false

# Command templates (override default docker commands)
commandTemplates:
  dockerCompose: docker-compose
  restartService: docker-compose restart {{ .Service.Name }}

# OS integration
os:
  # Command for opening files/URLs
  openCommand: 'xdg-open {{filename}}'

# Stats refresh rate in seconds
stats:
  graphs:
    - caption: CPU (%)
      statPath: DerivedStats.CPUPercentage
      color: blue
    - caption: Memory (%)
      statPath: DerivedStats.MemoryPercentage
      color: green

# Update check
update:
  dockerRefreshInterval: 100   # ms between docker daemon polls

# Services (Compose-specific settings)
services:
  someServiceName:
    icon: '🔧'
```

### Key Config Options Summary

|Option|Default|Effect|
|---|---|---|
|`gui.sidePanelWidth`|`0.3333`|Left panel width as fraction of terminal|
|`gui.wrapMainPanel`|`true`|Word wrap in log/detail pane|
|`logs.tail`|`200`|How many lines loaded on open|
|`logs.since`|`''`|Time filter for logs (e.g. `"1h"`)|
|`stats.graphs`|CPU + memory|Custom stat graphs in Stats tab|
|`commandTemplates.dockerCompose`|`docker-compose`|Override Compose binary (e.g. `docker compose`)|

---

## Custom Commands

lazydocker supports defining custom commands that appear in the `x` command menu.

```yaml
customCommands:
  containers:
    - name: open shell
      attach: true
      command: docker exec -it {{ .Container.ID }} /bin/bash
      subprocess: true

    - name: prune container logs
      command: truncate -s 0 $(docker inspect --format='{{{{.LogPath}}}}' {{ .Container.ID }})
      subprocess: false
```

### Template Variables

|Variable|Resolves To|
|---|---|
|`{{ .Container.ID }}`|Container ID|
|`{{ .Container.Name }}`|Container name|
|`{{ .Container.ImageID }}`|Image ID|
|`{{ .Service.Name }}`|Compose service name|
|`{{ .Image.ID }}`|Image ID (image context)|
|`{{ .Volume.Name }}`|Volume name (volume context)|

`subprocess: true` runs the command in a subshell attached to the terminal (required for interactive commands). `attach: true` keeps focus after execution.

---

## Docker Compose Integration

lazydocker detects Compose files automatically if launched from a project directory. Compose-aware features:

- Groups containers by service in the Project column
- Maps keybindings to `docker compose` verbs (up, down, restart, build)
- Displays service dependency order [Unverified — exact ordering display behavior not confirmed across all versions]
- Supports both `docker-compose` (v1) and `docker compose` (v2 plugin) via `commandTemplates.dockerCompose`

To use the v2 plugin syntax:

```yaml
commandTemplates:
  dockerCompose: docker compose
```

---

## Filtering and Search

Press `/` in any left-panel column to enter filter mode. Type a substring; the list narrows in real time. Press `Esc` to clear the filter.

Within log view, `/` opens a log-specific search. `n` and `N` cycle through matches.

---

## Mouse Support

lazydocker supports mouse interaction in terminals that pass mouse events. Clicking an item in the left panel selects it. Scrolling the mouse wheel moves through lists. Mouse support is terminal-dependent and may not function in all environments. [Unverified — behavior varies by terminal emulator and PTY configuration]

---

## Useful Workflows

### Prune All Stopped Containers

Select any container → `x` → look for prune or use a custom command. Alternatively, lazydocker does not expose `docker system prune` directly by default — add it as a custom command:

```yaml
customCommands:
  containers:
    - name: system prune
      command: docker system prune -f
      subprocess: false
```

### Tail Logs Across All Compose Services

Navigate to the `Project` column → select the project root → focus right panel → Logs tab. All service logs aggregate here when `logs.tail` is set adequately.

### Quickly Exec Into a Failing Container

`Containers` column → select container → `e`. If the container is stopped, start it first with `u`, then exec.

### Rebuild a Single Compose Service

`Project` column → select the service → `x` → rebuild, or bind a custom command to `docker compose up --build {{ .Service.Name }}`.

---

## Differences from docker CLI

|Task|docker CLI|lazydocker|
|---|---|---|
|View logs|`docker logs -f <id>`|Select container → Logs tab|
|Exec shell|`docker exec -it <id> bash`|Select container → `e`|
|Resource stats|`docker stats`|Select container → Stats tab|
|Compose up|`docker compose up -d`|Project column → `u`|
|Remove image|`docker rmi <id>`|Images column → `d`|
|Inspect container|`docker inspect <id>`|Select container → Config tab|

---

## Troubleshooting

### Permission Denied on Docker Socket

```
Error response from daemon: Got permission denied while trying to connect to the Docker daemon socket
```

Add your user to the `docker` group:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Or prefix with `sudo` (not recommended for daily use).

### lazydocker Shows No Containers

Confirm Docker daemon is running:

```bash
systemctl status docker
# or
sudo systemctl start docker
```

Check socket exists at `/var/run/docker.sock`.

### Compose Project Not Detected

Ensure `docker-compose.yml` or `compose.yaml` exists in the current directory when launching. The file must be named exactly — lazydocker does not recurse parent directories. [Unverified — recursive detection behavior may vary by version]

### Config Changes Not Applied

lazydocker reads config at startup only. Restart after editing `~/.config/lazydocker/config.yml`.

---

## Version and Update

```bash
lazydocker --version
```

lazydocker does not auto-update. Update via whatever installation method was used (AUR: `paru -Syu lazydocker`; Go: re-run `go install`; manual: re-download binary).