# snap

Snap is a package management system developed by Canonical. Snap packages ("snaps") are self-contained, sandboxed applications that bundle their own dependencies and run across many Linux distributions.

---

## Core Concepts

- **Snap** — a self-contained application package (`.snap` file)
- **Snapd** — the background daemon that manages snaps
- **Snap Store** — the central repository at `snapcraft.io`
- **Channel** — a release track: `stable`, `candidate`, `beta`, `edge`
- **Revision** — a specific numbered version of a snap
- **Confinement** — the sandbox level: `strict`, `classic`, or `devmode`

**Confinement levels:**

- `strict` — fully sandboxed, limited system access via interfaces
- `classic` — no sandbox, full system access (like a traditional package)
- `devmode` — developer mode, sandbox violations are logged not blocked

---

## Installation & Setup

Snap is pre-installed on Ubuntu 16.04+. For other distros:

|OS|Command|
|---|---|
|Debian|`sudo apt install snapd`|
|Fedora|`sudo dnf install snapd`|
|Arch|`sudo pacman -S snapd` then `sudo systemctl enable --now snapd`|
|OpenSUSE|`sudo zypper install snapd`|
|Manjaro|`sudo pacman -S snapd`|

After installing snapd on non-Ubuntu systems, enable the socket:

```bash
sudo systemctl enable --now snapd.socket
```

For classic snap support, also create the symlink:

```bash
sudo ln -s /var/lib/snapd/snap /snap
```

---

## Basic Usage

```bash
snap find <query>           # search for snaps
snap info <name>            # detailed info about a snap
snap install <name>         # install a snap
snap remove <name>          # remove a snap
snap list                   # list installed snaps
snap refresh                # update all snaps
snap refresh <name>         # update a specific snap
```

---

## Finding & Installing

### Searching

```bash
snap find "text editor"     # search by keyword
snap find --narrow firefox  # narrow search (exact matches)
```

### Getting Info

```bash
snap info vlc               # version, channels, size, description
snap info code              # see all available channels
```

**Example output of `snap info`:**

```
name:      vlc
summary:   The ultimate media player
publisher: VideoLAN
license:   GPL-2.0+
channels:
  latest/stable:    3.0.20  2023-10-12
  latest/beta:      4.0.0   2024-01-05
  latest/edge:      4.0.0   2024-02-01
```

### Installing

```bash
snap install vlc                        # install from stable channel
snap install code --classic             # install with classic confinement
snap install vlc --channel=beta         # install from beta channel
snap install vlc --revision=3000        # install a specific revision
snap install vlc --edge                 # shorthand for edge channel
```

---

## Managing Installed Snaps

### Listing

```bash
snap list                   # all installed snaps with versions
snap list --all             # include all retained revisions
snap list vlc               # info for a specific installed snap
```

### Updating

```bash
snap refresh                # update all snaps
snap refresh vlc            # update one snap
snap refresh vlc --beta     # update and switch to beta channel
snap refresh --list         # check for available updates without applying
snap refresh --time         # show when automatic refresh is scheduled
```

### Removing

```bash
snap remove vlc             # remove snap (keeps saved data)
snap remove vlc --purge     # remove snap and all its data
snap remove vlc --revision=2980   # remove a specific revision only
```

---

## Channels & Tracks

Channels follow the format: `<track>/<risk>`

```bash
snap install vlc --channel=latest/stable    # explicit
snap install vlc --channel=latest/edge      # latest edge
snap install node --channel=20/stable       # Node.js v20 track
snap install node --channel=18/stable       # Node.js v18 track
```

**Risk levels:**

- `stable` — production-ready, fully tested
- `candidate` — release candidate, near-stable
- `beta` — feature-complete but may have bugs
- `edge` — latest commits, may be unstable

**Switching channels on an installed snap:**

```bash
snap refresh vlc --channel=latest/beta
snap refresh node --channel=20/stable
```

---

## Revisions & Rollback

Snapd keeps the previous revision after an update, allowing instant rollback.

```bash
snap list --all vlc             # see all retained revisions
snap revert vlc                 # roll back to previous revision
snap revert vlc --revision=2980 # roll back to a specific revision
```

By default snapd retains 2 revisions. Old ones are removed automatically.

---

## Services

Some snaps run background services (daemons). You can manage them directly:

```bash
snap services                       # list all snap services
snap services <name>                # services for a specific snap
snap start <name>.<service>         # start a service
snap stop <name>.<service>          # stop a service
snap restart <name>.<service>       # restart a service
snap enable <name>.<service>        # enable on boot
snap disable <name>.<service>       # disable on boot
snap logs <name>.<service>          # view service logs
snap logs -f <name>.<service>       # follow logs
```

---

## Interfaces & Permissions

Interfaces are the mechanism by which snaps access system resources. Strict snaps must be explicitly granted access.

```bash
snap interfaces                     # list all interfaces
snap connections <name>             # show connections for a snap
snap connect <name>:<plug> <name>:<slot>   # grant a permission
snap disconnect <name>:<plug>              # revoke a permission
```

**Common interfaces:**

```bash
snap connect vlc:camera             # allow camera access
snap connect chromium:cups-control  # allow printer access
snap connect <name>:home            # allow access to home directory
snap connect <name>:removable-media # allow access to /media, /mnt
```

**Example — granting removable media access:**

```bash
snap connect vlc:removable-media
```

Without this, a strict snap cannot see files on USB drives or mounted volumes.

---

## Snap Data & Directories

Each snap has isolated data directories:

|Path|Purpose|
|---|---|
|`/snap/<name>/current/`|Snap application files (read-only)|
|`/var/snap/<name>/current/`|System data (writable)|
|`/var/snap/<name>/common/`|Persistent data across revisions|
|`~/snap/<name>/current/`|User data (writable)|
|`~/snap/<name>/common/`|Persistent user data across revisions|

`common/` is not revision-specific — data here persists across updates and rollbacks. `current/` is symlinked to the active revision and changes on update.

---

## Automatic Refresh

Snapd automatically refreshes snaps. By default it checks 4 times a day.

```bash
snap refresh --time                         # show next scheduled refresh
snap set system refresh.timer=fri,23:00     # refresh only on Fridays at 11pm
snap set system refresh.timer=00:00-04:59   # refresh only between midnight and 5am
snap set system refresh.hold=48h            # hold all refreshes for 48 hours
snap get system refresh.timer               # check current setting
```

**Hold a specific snap from updating:**

```bash
snap refresh --hold vlc                     # hold indefinitely
snap refresh --hold=72h vlc                 # hold for 72 hours
```

---

## Aliases

Snaps can expose command aliases:

```bash
snap aliases                        # list all aliases
snap alias <snap>.<cmd> <alias>     # create a manual alias
snap unalias <alias>                # remove an alias
```

---

## Snap Store & Account

```bash
snap login                          # log in to Snap Store account
snap logout                         # log out
snap whoami                         # show current logged-in account
snap buy <name>                     # purchase a paid snap
```

---

## Practical Examples

**Install and pin a specific Node.js version:**

```bash
snap install node --classic --channel=20/stable
```

**Check what a snap is allowed to access:**

```bash
snap connections chromium
```

**Prevent a snap from auto-updating while testing:**

```bash
snap refresh --hold=168h myapp      # hold for 1 week
```

**Clean up old revisions to free disk space:**

```bash
snap list --all | awk '/disabled/{print $1, $3}' | \
  while read name rev; do snap remove "$name" --revision="$rev"; done
```

**See logs for a snap service:**

```bash
snap logs -f nextcloud.apache
```

---

## Comparison with Other Package Managers

|Feature|snap|flatpak|apt/dnf|
|---|---|---|---|
|Self-contained|Yes|Yes|No|
|Sandboxed|Yes (strict)|Yes|No|
|Cross-distro|Yes|Yes|No|
|System daemons|Yes|No|Yes|
|Auto-updates|Yes|Optional|Manual|
|Offline install|Limited|Limited|Yes|
|Store|Snap Store (centralized)|Flathub + others|Distro repos|

---

## Tips

**Snaps start slower than native packages** — because the snap is mounted as a squashfs filesystem on first launch. Subsequent starts are faster. This is a known tradeoff.

**`classic` confinement snaps are not sandboxed** — treat them with the same trust as a traditional package. Most developer tools (VS Code, Go, Node) require classic.

**Free up disk space** — snapd keeps old revisions on disk. The cleanup one-liner in the examples above removes all disabled revisions.

**`/snap/bin` must be in your PATH** — on non-Ubuntu systems this sometimes isn't added automatically. Add it to your shell config if snap-installed commands aren't found:

```bash
export PATH="$PATH:/snap/bin"
```

**Interfaces are not always auto-connected** — if a snap can't access something it should, check `snap connections <name>` and manually connect the relevant interface.