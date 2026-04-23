# systemd-analyze plot

---

## What It Is

**`systemd-analyze plot`** generates an SVG diagram of the systemd boot process, showing which units started, in what order, how long each took, and where parallelization occurred. It is part of `systemd-analyze`, the tool for inspecting and debugging systemd boot performance.

---

## Basic Usage

```bash
# Print SVG to stdout
systemd-analyze plot

# Save to file (typical usage)
systemd-analyze plot > boot.svg

# Open directly in a browser
systemd-analyze plot > /tmp/boot.svg && xdg-open /tmp/boot.svg
```

The output is a standard SVG file — viewable in any browser, image viewer with SVG support, or Inkscape.

---

## What the Plot Shows

- **Horizontal axis** — time elapsed since firmware/boot start (seconds)
- **Each row** — one systemd unit (service, mount, socket, target, etc.)
- **Bar length** — time the unit spent in each phase
- **Color coding** — different phases of unit startup

### Bar Colors (typical)

|Color|Phase|
|---|---|
|Red / pink|Time spent in kernel before userspace|
|Dark gray|Initializing / queued|
|Light gray|Unit dependencies not yet met|
|Green|Activating (actually starting)|
|Dark green|Active|
|Blue|Deactivating|

Exact colors may vary slightly by systemd version.

---

## Useful Companion Commands

`systemd-analyze plot` is most useful alongside other `systemd-analyze` subcommands:

```bash
# Total boot time summary
systemd-analyze

# Per-unit time breakdown, sorted by time
systemd-analyze blame

# Critical path through the boot (chain of slowest deps)
systemd-analyze critical-chain

# Critical chain for a specific unit
systemd-analyze critical-chain postgresql.service

# Verify unit file correctness
systemd-analyze verify nginx.service

# Dump the full dependency graph as a dot file
systemd-analyze dot | dot -Tsvg > deps.svg
```

`blame` tells you what was slow; `critical-chain` tells you what was on the longest dependency path; `plot` shows the full picture visually.

---

## Flags

```bash
--system              # analyze system manager (default)
--user                # analyze user systemd instance (~/.config/systemd/user/)
--global              # analyze global user config

--host=user@host      # analyze remote host over SSH
--machine=name        # analyze a systemd-nspawn container

--no-pager            # don't pipe through pager (less relevant for plot)
--order               # in dot output: show only ordering deps
--require             # in dot output: show only require deps
```

### User instance example

```bash
systemd-analyze --user plot > user-boot.svg
```

Shows the startup graph for your user session units, not the system boot.

---

## Remote & Container Analysis

```bash
# Analyze boot on a remote machine
systemd-analyze --host=alice@server.example.com plot > remote-boot.svg

# Analyze a systemd-nspawn container
systemd-analyze --machine=mycontainer plot > container-boot.svg
```

Requires systemd on the remote side and appropriate SSH/machinectl access.

---

## Reading the Plot Effectively

### What to look for

**Long bars in the activating phase (green)** — the unit itself is slow to start. Investigate that service.

**Long gray bars before activation** — the unit waited a long time for dependencies. Check what it depends on via:

```bash
systemd-analyze critical-chain <unit>
```

**Sequential chains** — units starting one after another with no overlap. May indicate unnecessary `After=` or `Requires=` relationships.

**Wide parallelization** — many units starting simultaneously. Generally good; indicates well-structured dependencies.

### Finding the bottleneck

1. Look for the unit whose right edge is furthest right (last to finish)
2. Check if it has a long activation bar (slow itself) or long wait bar (blocked on deps)
3. Cross-reference with `systemd-analyze blame` for absolute times
4. Use `systemd-analyze critical-chain <unit>` to trace the dependency chain

---

## Saving & Viewing Options

```bash
# Save SVG
systemd-analyze plot > boot.svg

# Convert to PNG (requires ImageMagick or rsvg-convert)
rsvg-convert boot.svg > boot.png
convert boot.svg boot.png              # ImageMagick

# Convert to PDF
rsvg-convert -f pdf boot.svg > boot.pdf

# Open in browser (Linux)
xdg-open boot.svg

# Open in browser (macOS)
open boot.svg

# View in terminal (if you have a Sixel-capable terminal + rsvg)
rsvg-convert boot.svg | img2sixel
```

---

## Automation & CI

```bash
# Save a boot plot on every boot (via a oneshot service)
# /etc/systemd/system/save-boot-plot.service

[Unit]
Description=Save boot performance plot
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'systemd-analyze plot > /var/log/boot-plot-$(date +%%Y%%m%%d-%%H%%M%%S).svg'

[Install]
WantedBy=multi-user.target
```

Useful for tracking boot time regressions across system changes.

---

## Tips & Gotchas

- **Output can be very wide** — boots with many units produce wide SVGs; zoom out in the browser or use `Ctrl+-`
- **Requires a completed boot** — run after the system has fully reached its target; running during boot gives partial data
- **Times include firmware** — the leftmost section of the plot covers UEFI/BIOS and kernel init time before systemd starts
- **`systemd-analyze blame` is not the same as the critical path** — a unit can take a long time but not be on the critical path if it ran in parallel with slower units
- **User instance (`--user`) plots are separate** — the system plot does not include user session units
- **SVG may not render in all image viewers** — use a browser if your viewer shows a blank or broken image
- **systemd version affects output** — older versions produce simpler plots; some color coding and phases were added in newer releases

---

## Quick Reference

```bash
systemd-analyze plot > boot.svg          Save plot
xdg-open boot.svg                        Open in browser
systemd-analyze blame                    Per-unit times
systemd-analyze critical-chain           Longest dep chain
systemd-analyze critical-chain <unit>    Chain for specific unit
systemd-analyze --user plot > user.svg   User session plot
systemd-analyze --host=user@host plot    Remote host plot
rsvg-convert boot.svg > boot.png         Convert to PNG
```