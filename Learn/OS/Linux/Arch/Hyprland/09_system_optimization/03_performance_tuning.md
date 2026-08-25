## Performance Tuning


### General Optimization Principles
- Arch Linux and Wayland compositors, like Hyprland, are designed for efficiency, but further tuning can yield smoother graphics, lower latency, and reduced resource usage.
- Focus on lean configuration, minimizing unnecessary services and background processes, and using appropriate drivers for your hardware.

### Hyprland-Specific Tweaks
- Enable hardware acceleration and ensure GPU drivers (such as Mesa for AMD/Intel or proprietary NVIDIA) are correctly installed for best rendering performance.
- Adjust Hyprland’s `animations` settings to reduce or disable animations for lower power usage and quicker response.
- Set compositor-specific options in `~/.config/hypr/hyprland.conf` like:
  - `vsync = true` or `false` depending on tearing vs. latency preference.
  - `max_fps` to cap framerate and save resources.
- For NVIDIA users, set appropriate kernel modules and environment variables (e.g., `LIBVA_DRIVER_NAME=nvidia`, `__GLX_VENDOR_LIBRARY_NAME=nvidia`).

### XDG & System Services
- Disable unnecessary systemd services at startup using `systemctl` for less memory and CPU usage (`systemctl disable SERVICE`).
- Use `tlp`, `powertop`, or similar tools to optimize laptop battery life and power management.

### Application Tuning
- Prefer Wayland-native applications, which are more efficient and integrate better with Hyprland’s IPC.
- Run background applications (like status bars, launchers, notification daemons) with minimal resource flags, e.g., Waybar with reduced update intervals (`interval`).
- Manage autostart apps to launch only essentials through `~/.config/hypr/autostart.conf`.

### Monitoring & Profiling
- Use `htop`, `glances`, or `bpytop` for real-time resource monitoring.
- Profile Hyprland itself using `hyprctl` stats (e.g., `hyprctl monitors`, `hyprctl clients`).

### Power Users: Kernel, System, and Graphics
- Experiment with kernel parameters (e.g., `ibench`, `NOHZ`, and CPU governor settings) for further tweaks.
- For advanced setups, select a lightweight kernel (e.g., `linux-zen`, `linux-lqx`) and filesystem optimizations (like disabling access time tracking with `noatime` in fstab).

### Troubleshooting Bottlenecks
- Review logs (`journalctl`, `dmesg`, `~/.local/share/hyprland/hyprland.log`) for error messages and slowdowns.
- Ensure compositor (Hyprland) is not running at too high a resolution or refresh rate for your hardware.
- If experiencing screen tearing or stuttering, review vsync and GPU driver settings.

***

Related topics: Hyprland configuration, Wayland-specific hardware acceleration, troubleshooting frame drops and input latency.

