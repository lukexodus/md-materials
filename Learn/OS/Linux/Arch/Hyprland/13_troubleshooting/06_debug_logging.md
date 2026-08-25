## Debug & Logging


### Enabling Logging

- Hyprland generates detailed logs at `~/.local/share/hyprland/hyprland.log` by default.[1][2]
- For enhanced debugging, start Hyprland with verbose output:
  ```
  Hyprland --verbose
  ```
  - Or, add `debug {
      log_level = verbose
  }` in your Hyprland config to increase detail in the log file[1][2].

### Real-Time Debug Commands

- Use `hyprctl` for live debugging:
  ```
  hyprctl monitors     # See monitor status and settings
  hyprctl clients      # List window information
  hyprctl devices      # Input device diagnostics
  hyprctl activewindow # Focused window info
  hyprctl debug        # General debug output in console
  ```
  - These commands help identify which devices, layouts, and rules are currently active.[3]

### Troubleshooting Workflow

1. **Reproduce the Error**: Trigger the misbehavior or crash.
2. **Check the Log**:  
   - Inspect `~/.local/share/hyprland/hyprland.log` for recent messages, stack traces, or errors.
3. **Check System Logs**:  
   - Use `journalctl -b` to find relevant kernel, hardware, or user service errors (e.g., segfaults, driver probes).
4. **Test in Minimal Config**:  
   - Temporarily start Hyprland with a stripped-down config to rule out syntax or rule errors.

### Crash Logs & Issue Reporting

- If Hyprland crashes, logs will typically capture the stacktrace. Post both `hyprland.log` and system logs when seeking help or reporting upstream.[2]
- Frequently include:
  - Relevant fragments from your Hyprland config.
  - Output of `hyprctl monitors`, `hyprctl devices`, and system info for better diagnostics.

### Extra Tools

- Use monitoring utilities such as `htop`, `bpytop`, or `glances` for live health and resource tracking.
- For display/input debugging, utilities like `wev`, `evtest`, and `libinput debug-events` offer per-device event feeds—useful for diagnosing multimedia, touchpad, or keyboard issues.[1][3]

***

Related topics: Issue tracking on GitHub, verbose crash logs, identifying configuration bugs, advanced diagnostics for performance and device events.

Sources
[1] FAQ https://wiki.hypr.land/FAQ/
[2] Crashes and Bugs https://wiki.hypr.land/Crashes-and-Bugs/
[3] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland


