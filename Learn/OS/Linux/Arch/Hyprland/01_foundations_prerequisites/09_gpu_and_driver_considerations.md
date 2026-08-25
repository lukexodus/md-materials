## GPU and Driver Considerations


### NVIDIA Proprietary Drivers

There is no official Hyprland support for Nvidia hardware, though many users succeed by following specific configuration steps. Three driver setups exist: entirely proprietary drivers, proprietary drivers with open source kernel modules, and Nouveau open source drivers.[4][5]

**Driver Installation (Arch Linux):** Install `nvidia-dkms` for entirely proprietary drivers or `nvidia-open-dkms` for open source kernel modules. DKMS packages require corresponding kernel headers packages (e.g., `linux-zen-headers` for the Zen kernel). Also install `nvidia-utils` (and `lib32-nvidia-utils` for 32-bit compatibility) and `egl-wayland` for Wayland protocol compatibility.[5]

**Kernel Module Configuration:** Enable modeset by creating `/etc/modprobe.d/nvidia.conf` with `options nvidia_drm modeset=1`. This is already configured on Arch Linux and NixOS by default. Enable early KMS by adding `nvidia nvidia_modeset nvidia_uvm nvidia_drm` to the `MODULES` array in `/etc/mkinitcpio.conf`, then rebuild initramfs with `sudo mkinitcpio -P`. On hybrid graphics systems with Intel iGPU and Nvidia dGPU, load the `i915` module before Nvidia modules to prevent Electron/Chromium app stalls.[5]

**Environment Variables:** Add to Hyprland config:
```
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
```


### NVIDIA Architecture-Specific Requirements

**50xx Series (5090, 5080, etc.):** Open source kernel modules are **required** when using proprietary Nvidia drivers.[5]

**Turing and Ampere (16xx, 20xx+):** Open source kernel modules are recommended by Nvidia, though users should try both proprietary and open drivers if supported.[4][5]

**Older Cards:** If proprietary driver setups fail, Nouveau drivers may work properly and are likely necessary for legacy hardware.[4][5]

### NVIDIA Known Issues

**Electron/CEF Flickering:** Apps flicker when running in XWayland without the syncobj protocol. Enable native Wayland with `env = ELECTRON_OZONE_PLATFORM_HINT,auto` in Hyprland config, or launch apps with `--enable-features=UseOzonePlatform --ozone-platform=wayland`. Add `--enable-features=WaylandLinuxDrmSyncobj` to enable explicit sync support available in Electron 35/Chromium 134+.[5]

**Multi-GPU Issues:** Nvidia lacks important Multi-GPU features, causing broken or slow setups. Try changing primary GPU with `AQ_DRM_DEVICES` environment variable or set `AQ_FORCE_LINEAR_BLIT=0` to avoid forcing linear modifiers on Multi-GPU buffers. This may slow rendering on secondary monitors but enables functionality.[5]

**XWayland Game Flickering:** Due to lack of implicit synchronization in the driver. Install `xorg-xwayland` version 24.1+, `wayland-protocols` version 1.34+, and Nvidia driver 555+ for explicit sync support. For unsupported GPUs, install 535xx series drivers from AUR packages.[5]

**Suspend/Resume:** Enable `nvidia-suspend.service`, `nvidia-hibernate.service`, and `nvidia-resume.service`, then add `nvidia.NVreg_PreserveVideoMemoryAllocations=1` to kernel parameters. On NixOS, set `hardware.nvidia.powerManagement.enable = true;`. These are already configured on Arch Linux and NixOS.[5]

### AMD and Intel GPUs

AMD and Intel GPUs generally work better with Hyprland due to superior open source driver support. Install the appropriate drivers through distribution package managers—on Arch, this includes `mesa` for OpenGL drivers and `vulkan-radeon` for AMD or `vulkan-intel` for Intel Vulkan support.[2][6]

**Hybrid Graphics:** On laptops with Intel iGPU and AMD dGPU, configure which GPU Hyprland uses via the `WLR_DRM_DEVICES` environment variable. Set `env = WLR_DRM_DEVICES,/dev/dri/card2` in Hyprland config, adjusting the card number to target the desired GPU. The dGPU is typically gpu0/card0 by default. Using `/dev/dri/by-path/` identifiers does not work.[7]

