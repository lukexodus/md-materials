# flatpak

---

## What It Is

**Flatpak** is a universal Linux packaging system that runs applications in sandboxed containers, independent of the host distribution. Apps ship with their own dependencies (runtimes), so the same package runs on Fedora, Ubuntu, Arch, Debian, etc.

**Flathub** is the main public repository of Flatpak apps — most installs come from there.

---

## Installation

```bash
# Fedora (pre-installed)
# already available

# Debian/Ubuntu
sudo apt install flatpak

# Arch
sudo pacman -S flatpak

# After installing, add Flathub remote:
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Reboot or re-login after first install (needed for portal/env integration)
```

---

## Core Concepts

|Term|Meaning|
|---|---|
|**Remote**|A repository of Flatpak apps (like Flathub)|
|**Runtime**|Shared base libraries an app depends on (e.g. GNOME 46, KDE 6)|
|**Extension**|Optional add-ons to runtimes or apps (codecs, locale data)|
|**Ref**|Full identifier: `app/com.example.App/x86_64/stable`|
|**Sandbox**|Isolated environment the app runs in|
|**Portal**|Controlled bridge between sandbox and host (file picker, etc.)|
|**Override**|User or system permission changes applied on top of defaults|

App IDs follow reverse-DNS style: `com.spotify.Client`, `org.gimp.GIMP`, `io.github.something`

---

## Installing & Removing Apps

```bash
# Search
flatpak search spotify

# Install from Flathub
flatpak install flathub com.spotify.Client

# Install without confirming prompts
flatpak install -y flathub com.spotify.Client

# Install for current user only (no root)
flatpak install --user flathub com.spotify.Client

# Remove
flatpak uninstall com.spotify.Client

# Remove + leftover data
flatpak uninstall --delete-data com.spotify.Client

# Remove unused runtimes and extensions
flatpak uninstall --unused
```

---

## Running Apps

```bash
# Standard launch
flatpak run com.spotify.Client

# Pass arguments to the app
flatpak run com.spotify.Client --arg

# Override environment variable for this run
flatpak run --env=FOO=bar com.spotify.Client

# Run a specific older commit (pinned version)
flatpak run --commit=<hash> com.spotify.Client

# Open a shell inside the sandbox
flatpak run --command=sh com.spotify.Client
```

---

## Listing & Info

```bash
# List installed apps
flatpak list

# Apps only (no runtimes)
flatpak list --app

# Runtimes only
flatpak list --runtime

# Detailed info about an installed app
flatpak info com.spotify.Client

# Show all available versions/branches of an app
flatpak remote-info --log flathub com.spotify.Client

# Show what permissions an app has declared
flatpak info --show-permissions com.spotify.Client
```

---

## Updating

```bash
# Update all installed apps and runtimes
flatpak update

# Update a specific app
flatpak update com.spotify.Client

# Update without prompts
flatpak update -y

# Check what would be updated (dry run)
flatpak update --no-deploy
```

---

## Remotes (Repositories)

```bash
# List configured remotes
flatpak remotes

# Add a remote
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Add user-scoped remote
flatpak remote-add --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Remove a remote
flatpak remote-delete flathub

# List apps available in a remote
flatpak remote-ls flathub

# List only apps (not runtimes) in a remote
flatpak remote-ls --app flathub
```

---

## Permissions & Sandboxing

Flatpak apps declare permissions in their manifest. You can inspect and override them.

### View Permissions

```bash
flatpak info --show-permissions com.spotify.Client

# Or use the ref format
flatpak permissions
```

### Override Permissions (flatpak override)

```bash
# Grant filesystem access
flatpak override --filesystem=home com.spotify.Client
flatpak override --filesystem=/mnt/music com.spotify.Client

# Revoke filesystem access
flatpak override --nofilesystem=home com.spotify.Client

# Grant device access
flatpak override --device=all com.spotify.Client

# Allow talking to a specific D-Bus name
flatpak override --talk-name=org.freedesktop.Notifications com.spotify.Client

# Per-user override (no root)
flatpak override --user --filesystem=home com.spotify.Client

# Reset all overrides for an app
flatpak override --reset com.spotify.Client

# Show current overrides
flatpak override --show com.spotify.Client
```

### Common Permission Tokens

|Token|Meaning|
|---|---|
|`--filesystem=home`|Full home directory access|
|`--filesystem=host`|Full host filesystem access|
|`--filesystem=/path`|Specific path|
|`--filesystem=xdg-documents`|XDG Documents folder|
|`--device=dri`|GPU access|
|`--device=all`|All devices|
|`--share=network`|Network access|
|`--share=ipc`|Shared memory IPC|
|`--socket=wayland`|Wayland display|
|`--socket=x11`|X11 display|
|`--socket=pulseaudio`|Audio|

---

## Sandboxed Shell & Debugging

```bash
# Enter the app sandbox interactively
flatpak run --command=bash com.spotify.Client

# Run with extra sandbox permissions for debugging
flatpak run --devel com.spotify.Client

# See what the app is doing (filesystem calls, etc.)
flatpak run --log-session-bus com.spotify.Client
flatpak run --log-system-bus com.spotify.Client

# Show sandbox info
flatpak run --command=flatpak-info com.spotify.Client
```

---

## Data & Config Locations

Flatpak apps store data in predictable XDG locations on the host:

```
~/.var/app/<app-id>/config/     # config files
~/.var/app/<app-id>/data/       # app data
~/.var/app/<app-id>/cache/      # cache

# Example for GIMP:
~/.var/app/org.gimp.GIMP/config/
```

System-wide installations live under:

```
/var/lib/flatpak/
```

User installations:

```
~/.local/share/flatpak/
```

---

## System vs User Scope

Most commands accept `--system` (default, requires root for install) or `--user` (no root, installs to home):

```bash
flatpak install --user flathub org.gimp.GIMP
flatpak update --user
flatpak list --user
```

User-scope installs are isolated from system-scope installs — both can coexist.

---

## Flatpak + Flatseal

**Flatseal** is a GUI app for managing Flatpak permissions without using the CLI:

```bash
flatpak install flathub com.github.tchx84.Flatseal
```

It's the recommended way to manage permissions for non-CLI users.

---

## Tips & Gotchas

- **First launch can be slow** — runtimes download on first use; subsequent launches are fast
- **App IDs are case-sensitive** — `com.spotify.Client` not `com.Spotify.client`
- **`--unused` cleanup is important** — runtimes accumulate across updates; run periodically to reclaim space
- **Theming doesn't apply automatically** — GTK/Qt themes on the host don't propagate into the sandbox by default; some apps support `org.gtk.Gtk3theme` extension
- **Wayland vs X11** — apps may default to X11 via XWayland; check `--socket=wayland` permission and `WAYLAND_DISPLAY` env if native Wayland matters to you
- **Portals handle file dialogs** — the file picker inside a Flatpak app goes through `xdg-desktop-portal`, not direct filesystem access; if the file picker is broken, `xdg-desktop-portal` is likely misconfigured
- **`flatpak override` is persistent** — it writes to a config file and applies every run until reset

---

## Quick Reference

```
flatpak search <name>                     Find an app
flatpak install flathub <id>              Install
flatpak uninstall <id>                    Remove
flatpak uninstall --unused                Clean up runtimes
flatpak update                            Update everything
flatpak list --app                        Show installed apps
flatpak info <id>                         App details
flatpak run <id>                          Launch app
flatpak override --filesystem=home <id>   Grant home access
flatpak override --reset <id>             Reset permissions
flatpak run --command=bash <id>           Shell in sandbox
```