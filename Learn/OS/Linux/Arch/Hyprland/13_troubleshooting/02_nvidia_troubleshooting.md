## NVIDIA Troubleshooting


### Common Issues

- **Blank screen, flickering, or compositor crash**: Often due to missing or incorrect kernel parameters (`nvidia_drm.modeset=1`), incomplete driver setup, or XWayland/multi-GPU conflicts. Always use `nvidia-dkms`, `nvidia-utils`, and set the right kernel options in your bootloader.[1][2]
- **Slow or stuttery performance**: Disable unnecessary compositor effects (animations, blur), update `egl-wayland`, and ensure the GBM backend is used (export `GBM_BACKEND=nvidia-drm`). Lower `max_fps` or cap it in the Hyprland config for better results.[1]
- **Cursor bugs**: If you notice cursor corruption or lag, set `cursor { no_hardware_cursors = true }` in your Hyprland config. Some setups may work with hardware cursors enabled, but this is still a frequent NVIDIA issue.[3][4]
- **Failed to start Hyprland/Wrong renderer**: Errors like “Could not load EGL device” or “Failed to authenticate GBM” usually mean the environment variables aren't set (see below), or the driver/headers are mismatched with your kernel.[5][6][3]

### Required Packages and Services

- Ensure only one version of the NVIDIA driver (`nvidia-dkms` or, if using open, `nvidia-open-dkms`) is installed.  
- Install and enable `egl-wayland`, then check for conflicts with Nouveau or AMD/Intel drivers (blacklist them if necessary).[6][5]

### Environment Variables (Add to `~/.config/hypr/hyprland.conf`)

```
env = LIBVA_DRIVER_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
```
- These must be exported before Hyprland launches for Wayland/NVIDIA compatibility.[4][3]

### Kernel Parameters

- Always add this to your kernel command line:
  ```
  nvidia_drm.modeset=1
  ```
- For GRUB, put in `/etc/default/grub` within the `GRUB_CMDLINE_LINUX_DEFAULT` line, then run `sudo grub-mkconfig -o /boot/grub/grub.cfg`.

### Fixing XWayland/Legacy App Issues

- Many X11 apps via XWayland require the above environment variables and may still fail—try launching with `__GLX_VENDOR_LIBRARY_NAME=nvidia` manually if issues persist, or check logs in `~/.local/share/hyprland/hyprland.log`.[6]

### Multi-GPU and Hybrid Setups

- Use `env = WLR_DRM_DEVICES,/dev/dri/cardX` to force a specific GPU if both NVIDIA and Intel/AMD are present. Run `ls /dev/dri/by-path/` to find the correct GPU node.[7]
- Hybrid graphics often require extra udev/kmod tweaks or kernel module ordering—review the latest recommendations from the [Hyprland wiki NVIDIA section].[8][5][6]

### Debugging & Logs

- Check `~/.local/share/hyprland/hyprland.log` and `journalctl -b` after a failed startup.
- For detailed NVIDIA diagnosis, use `nvidia-smi` and `glxinfo`, and check for driver errors or missing modules.

### Known Limitations

- No PRIME offload support for seamless hybrid GPU switching.
- Some Vulkan and older OpenGL (GLX/GLX on XWayland) apps may glitch without workarounds or new NVIDIA driver releases.[1]
- Fractional scaling is limited; use integer scaling if possible for best results.[9]

***

Related topics: Updating DKMS and kernel modules, legacy/flatpak app workarounds, performance tuning, NVIDIA driver upgrades and possible regressions.

Sources
[1] FAQ https://wiki.hypr.land/FAQ/
[2] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[3] NVidia https://wiki.hyprland.org/0.45.0/Nvidia/
[4] NVidia - Hyprland Wiki https://wiki.hyprland.org/0.41.2/Nvidia/
[5] NVidia - Hyprland Wiki https://wiki.hyprland.org/0.41.0/Nvidia/
[6] Nvidia - Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Nvidia/
[7] Multi-GPU https://wiki.hypr.land/Configuring/Multi-GPU/
[8] NVidia - Hyprland Wiki https://wiki.hypr.land/Nvidia/
[9] Performance https://wiki.hypr.land/Configuring/Performance/

