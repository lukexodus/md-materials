## Performance Issues


### Common Symptoms

- Laggy or stuttering animations and window movement.
- High CPU or GPU usage by Hyprland or XWayland processes.
- Input latency, screen tearing, or visible frame drops.
- Low framerate, especially with NVIDIA GPU or complex layouts.[1][2][3][4][5]

### Typical Causes & Solutions

#### 1. GPU Drivers and Configuration

- **Incorrect or missing drivers** are a major cause of poor performance, especially with NVIDIA (always use `nvidia-dkms`, set `nvidia_drm.modeset=1`, and export all environment variables as shown in NVIDIA sections).
- For **AMD/Intel**, use the latest `mesa` and avoid older Xorg-only stacks.[2][1]
- Always ensure the EGL/GBM backend is in use (`egl-wayland` installed, export `GBM_BACKEND=nvidia-drm` on NVIDIA systems).[6]

#### 2. Compositor Settings

- Unnecessary or heavy animation effects, blur, and overlays can cause lag; reduce or disable `animations`, `blur`, and lower `max_fps` in `hyprland.conf`.[5]
- Enable or disable `vsync` depending on whether you want to prioritize latency or screen tearing; sometimes switching this setting improves overall smoothness.[1][2]

#### 3. Monitor Setup & Scaling

- Running in fractional scaling mode (e.g. 1.2, 1.5 instead of 1 or 2) can cause stutter or pixelation, especially with XWayland windows and NVIDIA.[7][8]
- Disable any unused or ghost monitors in config and prefer integer scaling for smoother performance.[1]

#### 4. Resource Conflicts and Background Services

- Conflicting background services (e.g., both PulseAudio and PipeWire running) can consume unnecessary CPU and memory—stick to one audio backend.[9][10]
- Disable unneeded autostart applications, tray utilities, or heavy status bars/notifications for minimal setups.[2][1]

#### 5. XWayland-Specific Issues

- Some legacy apps under XWayland may trigger high resource usage or leaks—prefer native Wayland apps where possible, or consider sandboxing noisy apps.[5][1]

### Diagnostics

- Use `htop`, `glances`, or `bpytop` to monitor system resource usage.
- `hyprctl debug` and `hyprctl monitors` help assess compositor performance.
- Check logs in `~/.local/share/hyprland/hyprland.log` and use `journalctl -b` for driver or hardware error messages.[11][2][1]

### Advanced Tuning

- On laptops, use TLP, powertop or similar tools to ensure proper CPU frequency scaling and power management.[2]
- Kernel parameters and custom kernel versions (`linux-zen`, `linux-lqx`) may slightly improve desktop latency and responsiveness for demanding users—but keep these up-to-date and compatible with driver stacks.[1]

***

Related topics: Frame pacing, reducing compositor load, persistent hardware interrupts or faulty devices slowing the session, tuning for gaming vs. minimal setups.

Sources
[1] FAQ https://wiki.hypr.land/FAQ/
[2] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[3] [SOLVED] Frequent and Random Crashes on Hyprland ... https://bbs.archlinux.org/viewtopic.php?id=302511
[4] Performance Issues & Texture Problems Arch(hyprland) #463 https://github.com/an-anime-team/an-anime-game-launcher/issues/463
[5] Perfomance issues when using Hyprland. #2637 https://github.com/hyprwm/Hyprland/issues/2637
[6] NVidia https://wiki.hyprland.org/0.45.0/Nvidia/
[7] Blurry text when using Sway or fractional scaling on Wayland https://intellij-support.jetbrains.com/hc/en-us/articles/4403794663570-Blurry-text-when-using-Sway-or-fractional-scaling-on-Wayland
[8] Wayland/hyprland: incorrect popup scale (reopen) : JBR-8356 https://youtrack.jetbrains.com/projects/JBR/issues/JBR-8356/Wayland-hyprland-incorrect-popup-scale-reopen
[9] Resolving Audio Issues on Arch Linux with Hyprland https://dev.to/laithalenooz/resolving-audio-issues-on-arch-linux-with-hyprland-a-step-by-step-guide-2n
[10] [SOLVED] Basic audio setup help, alsa and pipewire conflicting? https://bbs.archlinux.org/viewtopic.php?id=302578
[11] Crashes and Bugs https://wiki.hypr.land/Crashes-and-Bugs/

