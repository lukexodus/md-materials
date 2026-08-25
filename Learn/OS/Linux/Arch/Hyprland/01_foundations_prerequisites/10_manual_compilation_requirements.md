## Manual Compilation Requirements


Building from source requires C++26 standard support with `gcc>=15` or `clang>=19`. Install build dependencies on Arch with `yay -S ninja gcc cmake meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite libxrender libxcursor pixman wayland-protocols cairo pango libxkbcommon xcb-util-wm xorg-xwayland libinput libliftoff libdisplay-info cpio tomlplusplus hyprlang-git hyprcursor-git hyprwayland-scanner-git xcb-util-errors hyprutils-git glaze hyprgraphics-git aquamarine-git re2 hyprland-qtutils-git`.[1]

Additional hypr* dependencies not always packaged include aquamarine, hyprlang, hyprcursor, hyprutils, hyprgraphics, and hyprwayland-scanner (build-only). Clone the repository with `git clone --recursive https://github.com/hyprwm/Hyprland`, then build using CMake with `make all && sudo make install`.[1]

Sources
[1] Installation - Hyprland Wiki https://wiki.hypr.land/Getting-Started/Installation/
[2] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[3] How To Install Hyprland Arch in Simple Steps - CyberPanel https://cyberpanel.net/blog/install-hyprland-arch
[4] Nvidia | Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Nvidia/
[5] NVidia https://wiki.hypr.land/Nvidia/
[6] Wayland vs X11: Modern Display Server Architecture https://www.abhik.xyz/concepts/linux/wayland-x11
[7] Run on Intel Integrated Graphics? : r/hyprland - Reddit https://www.reddit.com/r/hyprland/comments/178jldh/run_on_intel_integrated_graphics/
[8] arch linux post install guide for hyprland : r/archlinux - Reddit https://www.reddit.com/r/archlinux/comments/1dldhmt/arch_linux_post_install_guide_for_hyprland/
[9] How to Install Arch Linux and Hyprland (Part 1 of 2) - John Ling https://www.johnling.me/blog/Arch-Linux-Guide
[10] THE FRESH ARCH LINUX HYPRLAND SETUP 2025 (Ft. END 4 ... https://www.youtube.com/watch?v=OnxU419vnts
[11] Problem with Intel/AMD hybrid GPU in Hyprland - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=289555

