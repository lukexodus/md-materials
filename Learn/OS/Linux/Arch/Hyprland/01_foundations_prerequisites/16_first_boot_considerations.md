## First Boot Considerations


### Initial Configuration

On first launch, Hyprland generates an example configuration at `~/.config/hypr/hyprland.conf` if none exists. The default config provides basic functionality with the dwindle tiling layout and standard keybinds.[7][1]

### Default Terminal

Install `kitty` terminal emulator before first launch, as it's the default terminal configured in Hyprland. Kitty is available in most distribution repositories and can be installed with `sudo pacman -S kitty` on Arch.[1]

### Virtual Machine Setup

If running Hyprland in a VM, enable 3D acceleration in your virtio or virt-manager configuration—Hyprland will not work without it. GPU passthrough is an alternative option for better performance. Note that 3D acceleration in VMs may be significantly slower than native hardware.[1]

### Login Loop Troubleshooting

If the display manager returns to the login screen after attempting to log in, check installation logs in your distribution's Hyprland install-logs directory. Common causes include improperly installed packages or missing 3D acceleration in VMs. Manually launch Hyprland from a TTY using Ctrl+Alt+F2 or F3 to diagnose issues—if the `Hyprland` command is not found, packages weren't installed correctly.[6]

