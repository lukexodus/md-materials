## Installation by Distribution


### Arch Linux

Install the stable release from official repositories using `sudo pacman -S hyprland`, which is the recommended approach. For bleeding-edge features, install `hyprland-git` from the AUR with `yay -S hyprland-git`, though this requires recompiling when dependencies like `hyprutils` receive ABI-breaking updates. The `hyprland-meta-git` package automatically fetches and compiles the latest git versions of all components within the hypr* ecosystem. Chaotic AUR provides pre-built binaries for git versions, though dependency updates may still require manual recompilation.[1][2]

### NixOS

Enable Hyprland by adding `programs.hyprland.enable = true;` to your NixOS configuration. Hyprland and NixOS are the two distributions officially tested and guaranteed to work by the Hyprland developers.[1]

### Rolling Release Distributions

**Fedora:** On Fedora 40+, run `sudo dnf install hyprland` and optionally `sudo dnf install hyprland-devel` for plugin development. The solopasha/hyprland Copr repository offers faster updates and additional packages.[1]

**openSUSE:** Install via `sudo zypper in hyprland` starting with snapshot 20230411 from factory. Install `hyprland-devel` for hyprpm dependency recognition. Hyprland is not available for Leap due to outdated libraries and compilers.[1]

**Gentoo:** Available in the main tree via `emerge --ask gui-wm/hyprland`. Additional ecosystem packages like hyprlock, hypridle, and xdg-desktop-portal-hyprland are available in the GURU overlay.[1]

### Fixed Release Distributions

**Ubuntu/Debian:** Ubuntu 24.10 includes Hyprland in the universe repository, installable via `sudo add-apt-repository universe && sudo apt-get update && sudo apt-get install -y hyprland`. However, packaged versions are extremely outdated, and manually building the entire stack is strongly recommended. Building from source requires installing extensive dependencies and compiling the latest wayland, wayland-protocols, and libdisplay-info releases manually. There is no guarantee the build process will work on Ubuntu due to dependency age.[3][1]

### Distribution Support Warnings

Hyprland is extremely bleeding-edge, causing major issues on distributions like Pop!_OS and Ubuntu that use older packages. Rolling release distributions like Fedora and openSUSE generally work fine. Using distribution-packaged versions instead of manual compilation or `-git` packages is heavily recommended to avoid outdated or incompatible dependency versions.[1]

