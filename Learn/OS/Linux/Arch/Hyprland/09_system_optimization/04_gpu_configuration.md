## GPU Configuration


### NVIDIA GPU Setup

- Install kernel headers (`linux-headers` or `linux-zen-headers` for non-default kernels) and NVIDIA drivers:  
  - `nvidia-dkms` (preferred proprietary) or `nvidia-open-dkms` (open source), and `nvidia-utils`  
  - For 32-bit apps: `lib32-nvidia-utils`.[1][2]
- Set kernel parameters by appending `nvidia-drm.modeset=1 nvidia_drm.fbdev=1` to the `GRUB_CMDLINE_LINUX_DEFAULT` line in `/etc/default/grub`, then regenerate your grub config with `sudo grub-mkconfig -o /boot/grub/grub.cfg`.[2]
- Install `egl-wayland` for EGL/GBM backend support.[1]
- Set environment variables in your Hyprland configuration (`~/.config/hypr/hyprland.conf`):

  ```
  env = LIBVA_DRIVER_NAME,nvidia
  env = XDG_SESSION_TYPE,wayland
  env = GBM_BACKEND,nvidia-drm
  env = __GLX_VENDOR_LIBRARY_NAME,nvidia
  ```

- Reboot, select Wayland session if using a display manager, and troubleshoot using logs if needed.[3][2][1]

### AMD/Intel GPU Setup

- For AMD: install `xf86-video-amdgpu` and `mesa` (and `vulkan-radeon` if Vulkan support is needed).[4]
- For Intel: install `xf86-video-intel` and `mesa` (and `vulkan-intel` if Vulkan support is needed).[4]
- To set a preferred GPU (e.g., iGPU), use the following in your `~/.config/hypr/hyprland.conf` (replace card1 with your preferred GPU):

  ```
  env = WLR_DRM_DEVICES,/dev/dri/card1
  ```
  Find your GPU device with `ls -l /dev/dri/by-path`.[5]

### Hybrid/Multi-GPU

- Hyprland supports specifying which GPU to use with the `WLR_DRM_DEVICES` environment variable.[6]
- Use system tools (`lspci`, `ls -l /dev/dri/by-path`) to determine GPU identifiers.[5][6]
- For laptops and hybrid systems (Intel + NVIDIA or AMD), consult power management tools and ensure GPU switching is supported by your hardware and kernel.[7][4]

### Troubleshooting & Best Practices

- Always check the [Hyprland Nvidia page](https://wiki.hypr.land/Nvidia/) for the latest GPU-specific tips and workarounds, especially for NVIDIA hardware.[8][1]
- Monitor GPU usage/output with tools like `glxinfo`, `glmark2`, and `hyprctl debug` or `hyprctl monitors`.[4]
- Pay close attention to error messages in `~/.local/share/hyprland/hyprland.log` and use `journalctl` for driver issues.[3]
- For performance issues, verify correct driver and kernel module loading, environment variables, and compositor logs.[2][1][3]

***

Related topics: Hybrid/Prime GPU switching, hardware acceleration, troubleshooting GPU errors.

Sources
[1] NVidia https://wiki.hyprland.org/0.41.0/Nvidia/
[2] NVIDIA + Wayland on Arch: A Comprehensive Setup Guide https://linuxiac.com/nvidia-with-wayland-on-arch-setup-guide/
[3] Installation https://wiki.hypr.land/Getting-Started/Installation/
[4] Problem with Intel/AMD hybrid GPU in Hyprland https://bbs.archlinux.org/viewtopic.php?id=289555
[5] ArchLinux Setup Guide For Intel MacBook Pro https://dev.to/x1unix/archlinux-setup-guide-for-intel-macbook-pro-58b8
[6] Multi-GPU https://wiki.hypr.land/Configuring/Multi-GPU/
[7] Laptop / Hybrid GPU Power Management Issue (NVIDIA ... https://github.com/basecamp/omarchy/issues/1776
[8] NVidia https://wiki.hypr.land/Nvidia/
[9] Need Help Installing Hyperland on Arch Linux with NVIDIA ... https://www.reddit.com/r/archlinux/comments/1ckmods/need_help_installing_hyperland_on_arch_linux_with/
[10] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[11] Hyprland on Arch Linux - v4. nvidia, amd and intel gpu ... https://www.youtube.com/watch?v=otda1nXJ5Dg
[12] [SOLVED]Nvidia GPU integrity check for Hyprland ... https://bbs.archlinux.org/viewtopic.php?id=291774
[13] Arch Linux Installation & Hyprland Setup Guide https://github.com/devk0n/fyrefiles/wiki/Arch-Linux-Installation-and-Hyprland-Setup-Guide
[14] Installing Hyprland Tiling Window Manager on Arch Linux ... https://www.youtube.com/watch?v=elOFuFpPSJQ
[15] Wanted some clarification regarding Hyprland (AMD or ... https://www.reddit.com/r/archlinux/comments/18129r9/wanted_some_clarification_regarding_hyprland_amd/
[16] THIS IS NEW ARCH LINUX HYPRLAND SETUP (Ft. DANK ... https://www.youtube.com/watch?v=iqYiCpDY54E
[17] Install Hyprland Arch Linux on Laptop with Nvidia RTX GPU https://www.youtube.com/watch?v=_deaeSU1WK8
[18] Please share your hardware configuration that works with ... https://github.com/prasanthrangan/hyprdots/discussions/116
[19] Master tutorial https://wiki.hypr.land/Getting-Started/Master-Tutorial/
[20] Hyprland on Arch Linux - Nvida, Amd and Intel GPU support https://www.youtube.com/watch?v=mbQd0bJQ6a8

