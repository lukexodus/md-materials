## NVIDIA-Specific Settings


### Kernel Modules & Headers

- Install the matching kernel headers (e.g., `linux-headers` for your running kernel).[1][2]
- Use the proprietary driver: `nvidia-dkms` (recommended), together with `nvidia-utils` and optionally `lib32-nvidia-utils` for 32-bit compatibility.[2][1]

### Kernel Parameters

- Add `nvidia_drm.modeset=1` to your bootloader options.  
  - For `systemd-boot`, append to `/boot/loader/entries/arch.conf`.[2]
  - For `grub`, add to `GRUB_CMDLINE_LINUX_DEFAULT=` in `/etc/default/grub`, then regenerate grub config with `grub-mkconfig -o /boot/grub/grub.cfg`.[1][2]

### Initramfs Modules

- Add the following to `MODULES` in `/etc/mkinitcpio.conf` for faster boot and better compatibility:

  ```
  MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
  ```

  Rebuild the initramfs after changes (`mkinitcpio -P`).[2]

### Environment Variables (Hyprland Config)

Add these lines to your `~/.config/hypr/hyprland.conf` for optimal NVIDIA compatibility:

```
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
```


#### Cursor Configuration

```
cursor {
  no_hardware_cursors = true
}
```
- Do not use the now-deprecated `WLR_NO_HARDWARE_CURSORS` variable.[3][4]
- If hardware cursors cause no issue, you may experiment by setting `no_hardware_cursors = false`; otherwise, keep it disabled.[4][3]

### EGL and VAAPI Packages

- Install `egl-wayland` for proper EGL/GBM support.[1]
- For hardware video acceleration, install `libva-nvidia-driver` and add:

  ```
  env = NVD_BACKEND,direct
  ```
  to your Hyprland config.[3][4]

### Fixes & Performance Tips

- Set fractional scaling (e.g., scale values `1` or `2`) for monitors in Hyprland if stutter or high usage occurs.[5]
- Disable resource-intensive effects (blur, shadow) for power saving and responsiveness.[5]
- Use tools like `gamescope` for smoother gaming or compatibility with certain configurations.[5]

***

Related topics: Troubleshooting flickering, optimizing NVIDIA for gaming, Wayland-native application acceleration.

Sources
[1] NVidia - Hyprland Wiki https://wiki.hyprland.org/0.41.0/Nvidia/
[2] Nvidia - Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Nvidia/
[3] NVidia - Hyprland Wiki https://wiki.hyprland.org/0.41.2/Nvidia/
[4] NVidia https://wiki.hyprland.org/0.45.0/Nvidia/
[5] Performance https://wiki.hypr.land/Configuring/Performance/
[6] Hyprland with NVIDIA? - Reddit https://www.reddit.com/r/hyprland/comments/1hh14d8/hyprland_with_nvidia/
[7] NVidia - Hyprland Wiki https://wiki.hypr.land/Nvidia/
[8] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[9] hyprland on nVidia: wayland window manager for gamers https://www.youtube.com/watch?v=nkxM6ijmEiQ
[10] nvidia drivers? : r/hyprland https://www.reddit.com/r/hyprland/comments/19atrnv/nvidia_drivers/
[11] [SOLVED]Nvidia GPU integrity check for Hyprland / Applications ... https://bbs.archlinux.org/viewtopic.php?id=291774
[12] Improved Hyprland performance when using old nvidia ... https://github.com/JaKooLit/Hyprland-Dots/discussions/123
[13] [GUIDE] Switching From Proprietary NVIDIA Drivers to NVK https://github.com/hyprwm/Hyprland/discussions/5633
[14] Full setup and dotfiles configuration for Hyprland on Arch linux https://github.com/Maciejonos/dotfiles
[15] Any solution for XWayland apps with Nvidia graphics on ... https://forum.endeavouros.com/t/any-solution-for-xwayland-apps-with-nvidia-graphics-on-wms-like-hyprland/53828
[16] GPU configuration with "env = WLR_DRM_DEVICES,/dev/ ... https://github.com/hyprwm/hyprland-wiki/issues/694
[17] Everything You Need To Know About Hyprland on Nvidia - YouTube https://www.youtube.com/watch?v=PMWhzfoet9Y
[18] Stutering and low fps scrolling in browsers on Wayland ... https://forums.developer.nvidia.com/t/stutering-and-low-fps-scrolling-in-browsers-on-wayland-when-gsp-firmware-is-enabled/311127
[19] Hyprland compositor and NVIDIA's kernel settings https://forum.endeavouros.com/t/hyprland-compositor-and-nvidias-kernel-settings/37797
[20] Issues with prime-run and Hyprland – NVIDIA GPU not working with ... https://forums.developer.nvidia.com/t/issues-with-prime-run-and-hyprland-nvidia-gpu-not-working-with-charger-plugged-in/340678

