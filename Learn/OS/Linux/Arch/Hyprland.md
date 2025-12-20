## Comprehensive Hyprland Learning Syllabus

### Fundamentals

**Wayland Architecture**[1][2]

**Hyprland Overview**[2][1]

**Installation & Setup**[3][4][2]

**First Boot & Login Methods**[2]

### Core Configuration

**Configuration File Structure**[3][2]

**General Settings**[2][3]

**Input Devices**[3][2]

**Display & Monitors**[2][3]

**Decorations & Visual Effects**[3][2]

**Animations**[2][3]

**Cursor Configuration**[2]

### Window Management

**Dynamic Tiling Fundamentals**[1][2]

**Dwindle Layout**[3]

**Master Layout**[3]

**Window Rules**[2][3]

**Workspace Management**[3][2]

**Tabbed & Grouped Windows**[2]

### Keybindings & Control

**Keyboard Bindings**[3][2]

**Mouse Bindings**[2][3]

**Gestures & Touchpad**[2]

**Media Keys**[2]

**Dispatchers & Commands**[2]

### System Integration

**Environment Variables**[2]

**Autostart Configuration**[2]

**Session Management**[2]

**Display Managers**[2]

**Universal Wayland Session Manager**[2]

### Hypr Ecosystem

**Hyprpaper (Wallpapers)**[5][2]

**Hyprlock (Screen Locking)**[2]

**Hypridle (Idle Management)**[2]

**Hyprpicker (Color Picker)**[2]

**Hyprcursor (Cursor Themes)**[2]

**Hyprsunset (Blue Light Filter)**[5][2]

**Hyprpolkitagent (Authentication)**[3][2]

### External Tools Integration

**Status Bars (Waybar)**[3][2]

**Application Launchers (Wofi/Rofi)**[3][2]

**Terminal Emulators**[4][3]

**File Managers**[3][2]

**Notification Daemons (Mako)**[2]

**Clipboard Management**[2]

**Screenshot Tools**[5][3]

**Screen Recording**[3]

### Advanced Configuration

**Hyprctl & IPC**[2]

**Scripting & Automation**[2]

**Dynamic Configuration Changes**[2]

**Multi-Monitor Setups**[2]

**Workspace Rules & Behaviors**[3]

### System Optimization

**Power Management**[2]

**DPMS Control**[2]

**Performance Tuning**[2]

**GPU Configuration**[2]

**NVIDIA-Specific Settings**[2]

### Desktop Portal Integration

**XDG Desktop Portal Hyprland**[2]

**Screen Sharing**[2]

**File Pickers**[2]

**Global Shortcuts**[2]

### Appearance Customization

**GTK Theming**[4][3]

**Qt Configuration**[3]

**Icon Themes**[3]

**Font Configuration**[3]

**Color Schemes**[3]

### Hardware Configuration

**Keyboard Layout & Variants**[2]

**Typematic Delay & Rate**[2]

**Keyboard Backlight**[2]

**Screen Brightness**[2]

**Audio Control**[2]

**Touchpad Configuration**[2]

**Device Enable/Disable**[2]

### Troubleshooting

**Common Issues**[1][2]

**NVIDIA Troubleshooting**[2]

**JetBrains Applications**[2]

**XWayland Compatibility**[2]

**Performance Issues**[2]

**Debug & Logging**[2]

Sources
[1] Hyprland Wiki https://wiki.hypr.land
[2] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[3] Hyprland - Archcraft Wiki https://wiki.archcraft.io/docs/wayland-compositors/hyprland/
[4] Tutorial Fedora 43 - Install Hyprland from scratch https://discussion.fedoraproject.org/t/tutorial-fedora-43-install-hyprland-from-scratch/168386
[5] Getting Started With Hyprland https://itsfoss.com/hyprland/
[6] Hyprland Guide for beginners - Reddit https://www.reddit.com/r/hyprland/comments/1hxjq57/hyprland_guide_for_beginners/
[7] Hyprland: getting started (part 1) - Lorenzo Bettini https://www.lorenzobettini.it/2023/07/hyprland-getting-started-part-1/
[8] Hyprland – An independent, dynamic tiling Wayland compositor https://news.ycombinator.com/item?id=44854508
[9] gaurav23b/simple-hyprland https://github.com/gaurav23b/simple-hyprland
[10] I am a beginner linux and absolutely love how hyprland ... https://www.reddit.com/r/unixporn/comments/186vszt/i_am_a_beginner_linux_and_absolutely_love_how/

# Syllabus for Learning and Mastering Hyprland

## Module 1: Foundations & Prerequisites
•	Understanding the Wayland protocol: what it replaces and how.  ￼
•	What a compositor/window-manager does, difference versus X11.  ￼
•	Installing Hyprland: distribution differences, GPU/driver concerns (e.g., NVIDIA caveats)  ￼
•	Basic filesystem and config file locations (e.g., ~/.config/hypr/hyprland.conf)  ￼
•	Terminology: tiling vs floating windows, dynamic workspaces, layouts.

## Module 2: Core Configuration Basics
•	Editing hyprland.conf: syntax, includes, structure.  ￼
•	Input devices configuration: keyboards, mice, touchpads, keybindings.  ￼
•	Monitor/output configuration: resolution, refresh, multi-monitor handling.
•	Workspace and layout basics: switching workspaces, default layouts, floating/tiled rules.
•	Window rules: pinning, ignoring, special workspaces, scratchpads.

## Module 3: Intermediate Customisation & Usage
•	Advanced keybindings: chaining commands, launching applications, system controls.
•	Layouts and tiling behaviour: dynamic tiling, master layouts, swapping windows, layout plugins.
•	Animations & appearance: rounded corners, blur, shadows, bezier curves.  ￼
•	IPC and scripting: controlling Hyprland via socket/IPC, integrating with external scripts/applications.
•	Managing floating vs tiling windows, special cases (dialogs, full-screen, games).
•	External tools: status bar, launcher, notification daemon configuration.

## Module 4: Theming, “Ricing” & Aesthetic Workflow
•	Theme concepts: wallpapers, colorschemes, icon sets, consistency across apps.
•	Compositor visual effects: transitions, blur, shadows, animations tuning.
•	Using community configs for inspiration, but adapting for maintainability.  ￼
•	Performance considerations: avoiding over-decoration/spillover, balancing form & function.
•	Accessibility and ergonomics: keybinding ergonomics, readability, font scaling, HiDPI support.

## Module 5: Advanced Features & Plugins
•	Plugin system of Hyprland: available plugins, how to install/use them.  ￼
•	Custom layouts: writing or configuring new layouts beyond defaults.
•	Trackpad gestures, device-specific settings: e.g., per-device scroll factor, hide cursor.  ￼
•	Window groups/tabbed windows: how to group windows, switch between groups.
•	Advanced window rules: conditional behaviours (on monitor, workspace, application).
•	Gaming and multi-monitor workflows: handling VRR, fullscreen behaviour, input latencies.  ￼

## Module 6: Troubleshooting, Performance & Maintenance
•	Logging, debug modes, identifying startup failures (e.g., Hyprland won’t start).  ￼
•	Performance tuning: compositor overhead, GPU driver issues, Wayland vs X11 quirks.
•	Upgrading Hyprland, migration of config changes across versions.
•	Backup strategies: versioning configs, modular config includes for maintainability.
•	Security considerations: Wayland vs X11 in terms of isolation.  ￼

## Module 7: Integration & Ecosystem
•	Integrating Hyprland into your full desktop workflow: terminal emulator, file manager, launcher, notification system.
•	Using Hyprland in different distributions: Arch, NixOS, etc.  ￼
•	Automation: startup scripts, session management, managing profiles for laptops vs desktops.
•	Community involvement: reading release notes (e.g., hyprland 0.51), contributing or customizing further.  ￼

## Module 8: Custom Development & Extending Hyprland
•	Basics of C++ codebase (Hyprland is written in C++).  ￼
•	Writing Hyprland plugins: API, conventions, examples.
•	Contributing to Hyprland or its ecosystem: GitHub workflow, issue filing, feature proposals.
•	Creating your own layouts or tools integrated with Hyprland IPC.
•	Future-proofing: tracking Wayland compositor ecosystem, staying ahead of upcoming features.

**Conclusion**
This syllabus gives a modular roadmap from foundational understanding through intermediate usage to advanced customisation and development of Hyprland. You can tailor the pace and depth per module depending on your existing Linux/desktop-environment experience.

# Foundations & Prerequisites

## Wayland Protocol Architecture

Wayland is a communication protocol specifying how a display server (compositor) communicates with its client applications, replacing the X Window System (X11) that has existed since 1984. The protocol consists of a two-layer architecture: a low-level wire protocol handling inter-process communication via Unix domain sockets, and a high-level asynchronous object-oriented protocol managing window system features.[1][2]

### Client-Server Model

The protocol follows a client-server model where graphical applications are clients requesting display of pixel buffers, and the compositor is the server controlling buffer display. Unlike X11 where the X server sits between applications and hardware as a middleman, Wayland's compositor *is* the display server, directly managing windows and communicating with clients through a lean protocol. This eliminates an entire layer of inter-process communication present in X11's architecture.[2][1]

### Protocol Implementation

The protocol is described as asynchronous and object-oriented, where compositor services are presented as objects with interfaces containing methods (requests) and events. Clients invoke requests on objects to request services, while the compositor sends events back to clients either as responses or asynchronously based on internal state changes. The reference implementation splits into `libwayland-client` for clients and `libwayland-server` for compositors.[1]

The high-level protocol layer is automatically generated from XML descriptions, allowing flexible and extensible protocol development. Compositors can define custom interfaces beyond the core protocol to extend functionality.[1]

## What Wayland Replaces

### X Window System (X11)

Wayland replaces X11, a network-transparent windowing system dating from 1984 that uses a client-server model where the X server runs on the user's computer accepting requests from client programs. X11 handles window management, compositing, and input as separate components, with the X server acting as a go-between for users and applications.[3][2]

### Architectural Differences

**X11 Architecture:** Applications render to X pixmaps via GLX/EGL, the X server copies pixmaps to the compositor's texture, the compositor applies effects, then presents the final composite to screen—resulting in 4 steps with 2-3 memory copies per frame.[2]

**Wayland Architecture:** Applications render directly to DMA-BUF via EGL, the compositor textures from the buffer directly as a GL texture, then presents the composite in one pass—resulting in 3 steps with zero copies.[2]

### Security Model

X11 provides no application isolation, allowing any client to access the entire display server and inject input or read content from other applications globally. Wayland enforces strict separation where each client runs in a sandboxed environment with isolated access, preventing applications from accessing other clients' windows or input without explicit permission.[4][2]

## Direct Rendering Model

### Buffer Management

Wayland does not include a rendering API but follows a direct rendering model where clients render window contents to buffers shareable with the compositor. Clients can use rendering libraries like Cairo, OpenGL, or Vulkan, or rely on widget libraries like Qt or GTK.[1]

Rendered contents are stored in `wl_buffer` objects with implementation-dependent internal types, requiring only that content data be shareable between client and compositor. Software renderers can use shared memory via `wl_shm` and `wl_shm_pool` interfaces, though this requires the compositor to copy data to the GPU.[1]

### GPU-Accelerated Rendering

The preferred method involves clients rendering directly into video memory buffers using GPU-accelerated APIs like OpenGL, OpenGL ES, or Vulkan. Client and compositor share GPU-space buffers using special handlers, allowing zero-copy buffer sharing that eliminates the extra data copy present in X11's architecture.[2][1]

When rendering completes, clients bind the buffer object to a surface object and send a commit request, transferring buffer control to the compositor. Clients can either wait for the compositor to release the buffer via an event or use multiple buffers for double/triple buffering.[1]

## Performance Improvements

Wayland's architecture delivers measurable performance advantages over X11: input latency reduces from 30-50ms to 15-25ms through direct routing, frame latency decreases from 2-3 frames to 1 frame, and GPU memory copies drop from 2-3 per frame to zero. Wayland provides tear-free rendering by default, lower CPU usage through event-driven design versus polling, and superior HiDPI scaling with per-output configuration.[2]

## Hyprland Implementation

Hyprland is now a fully independent implementation of the Wayland protocol, having moved away from wlroots in July 2024. All protocol implementations are integrated into Hyprland itself and written in C++ to reduce memory issues compared to wlroots implementations. The backend rendering uses aquamarine, a library providing abstraction over low-level backend operations (KMS/DRM/libinput) that allows running on either a Wayland compositor window or DRM session.[5]

Sources
[1] Wayland (protocol) https://en.wikipedia.org/wiki/Wayland_(protocol)
[2] Wayland vs X11: Modern Display Server Architecture https://www.abhik.xyz/concepts/linux/wayland-x11
[3] X Window System protocols and architecture https://en.wikipedia.org/wiki/X_Window_System_protocols_and_architecture
[4] How secure is Wayland? - Tencent Cloud https://www.tencentcloud.com/techpedia/103343
[5] Hyprland is now fully independent! https://hypr.land/news/independentHyprland/
[6] Can someone give me simple explanation of what ... https://www.reddit.com/r/linux/comments/tkt1h/can_someone_give_me_simple_explanation_of_what/
[7] The Wayland Protocol https://wayland.freedesktop.org/docs/html
[8] [Wayland] Technical overview of the input methods support https://youtrack.jetbrains.com/articles/JBR-A-32/Wayland-Technical-overview-of-the-input-methods-support
[9] Why Wayland: A Brief History of Display Protocols https://blog.gistre.epita.fr/posts/david.horozian-2023-01-29-why-wayland/
[10] mikeroyal/Wayland-Guide https://github.com/mikeroyal/Wayland-Guide
[11] What is the main difference between X11 and Wayland? https://www.reddit.com/r/linux/comments/1b4xso9/explain_to_me_like_im_5_what_is_the_main/
[12] Swaywm vs Hyprland. Which one should I use? https://www.reddit.com/r/linuxquestions/comments/1ck11ud/wayland_compositor_swaywm_vs_hyprland_which_one/
[13] X Window System protocols and architecture https://dlab.epfl.ch/wikispeedia/wpcd/wp/x/X_Window_System_protocols_and_architecture.htm
[14] X Window System Protocol https://www.x.org/releases/X11R7.7/doc/xproto/x11protocol.html
[15] What Is X11? | Baeldung on Linux https://www.baeldung.com/linux/x11
[16] Wayland Architecture https://wayland.freedesktop.org/architecture.html
[17] X Window System https://en.wikipedia.org/wiki/X_Window_System
[18] X11 Vs Wayland : r/linux - Reddit https://www.reddit.com/r/linux/comments/174uxzz/x11_vs_wayland/

## Compositor/Window Manager Functions

### Unified Role in Wayland

A Wayland compositor combines the display server, window manager, and compositing functionality into a single process. Display servers using the Wayland protocol are called compositors because they additionally perform the task of a compositing window manager. Starting a Wayland session amounts to starting a compositor, which handles all graphics server operations, window management, and visual compositing in one unified process.[2][3][5]

### Core Compositor Responsibilities

**Window Management:** Compositors control window placement, sizing, focus management, workspace organization, and tiling/stacking behavior. In Wayland, window management is a shared responsibility between compositor and client, meaning each compositor defines its own window management behavior rather than plugging into a separate window manager.[5][6]

**Rendering and Compositing:** Compositors render graphical elements including windows and visual effects like shadows, transparency, animations, and rounded corners. They perform off-screen rendering where windows are drawn to buffers before display, reducing screen tearing and ensuring smooth performance.[3][6]

**Display Server Functions:** The compositor manages communication with client applications through the Wayland protocol, handling requests from clients to draw buffers on screen and sending events like mouse clicks and key-presses back to clients. It controls buffer display, directly manages hardware through kernel display drivers (DRM) and libinput, and coordinates GPU-accelerated rendering.[3][5]

### Input and Hardware Management

Compositors handle all input device management including keyboards, mice, touchpads, and touchscreens through libinput. They manage display configuration, output routing, and direct interaction with graphics hardware without intermediate layers.[5]

## Differences from X11 Architecture

### Separation vs. Integration

**X11 Model:** X Window System separates the display server (X.org), window manager, and compositor into distinct components. The X server runs as a central process accepting requests from client programs, while window managers are separate programs that plug into X.org to control window placement, decorations, and behavior. Modern X11 compositors like Picom are standalone processes that instruct X.org to render application graphics to off-screen buffers, then perform compositing operations before presenting to screen.[6][10][5]

**Wayland Model:** All functionality merges into the compositor, eliminating the separate display server and window manager layers. This means implementing different window management behavior requires building an entirely new compositor rather than swapping window managers.[3][5]

### Protocol Complexity

X11 protocols contain extensive legacy functionality and support for features rarely used in modern applications, requiring X.org to implement comprehensive capabilities spanning decades of development. Wayland protocols have a dramatically reduced feature set with simpler specifications, allowing compositors to implement only essential modern functionality. Client requests in Wayland are far fewer than in X11, shifting complexity from the compositor to client applications.[5]

### Implementation Flexibility

X11 provides a standard X server (X.org) that works with various interchangeable window managers like i3, Openbox, or dwm. Window managers can be started, stopped, and replaced without restarting the entire display server.[5]

Wayland has no single "Wayland server"—each compositor is a complete, standalone implementation. Notable compositors include Mutter (GNOME), KWin (KDE), Sway (i3-like tiling), and Hyprland (dynamic tiling with animations). Libraries like wlroots provide frameworks to ease compositor development by handling fundamental compositor needs, though major compositors like Mutter implement everything independently.[7][3][5]

### Driver and Hardware Handling

X.org must implement or support extensive legacy drivers for various hardware configurations, maintaining backward compatibility across diverse systems. Wayland compositors typically support only the kernel's Direct Rendering Manager (DRM) and libinput, significantly reducing driver complexity. This simplifies compositor implementation but means hardware support varies between compositors.[5]

### Client Responsibilities

In X11, clients rely heavily on the X server and window manager for rendering surfaces, window decorations, and many graphical operations. In Wayland, clients must handle more functionality themselves, including rendering window contents, potentially drawing their own decorations if the compositor doesn't provide them, and managing additional graphical responsibilities previously handled by X.org. This makes Wayland compositors simpler by making Wayland clients more complex.[5]

### Window Decorations

X11 window managers typically handle all window decorations (title bars, borders, close buttons) uniformly across applications. Wayland makes compositor decorations optional—the client can request the compositor to handle decorations, but if the compositor refuses, the client must draw its own decorations. This requires applications to implement fallback decoration rendering.[5]

Sources
[1] With rise of wayland, are simpler window managers dying? - Reddit https://www.reddit.com/r/linux/comments/wy6c9r/with_rise_of_wayland_are_simpler_window_managers/
[2] Wayland - ArchWiki https://wiki.archlinux.org/title/Wayland
[3] Wayland (protocol) - Wikipedia https://en.wikipedia.org/wiki/Wayland_(protocol)
[4] Best Wayland Compositors For Window Manager Users - YouTube https://www.youtube.com/watch?v=59dxV-5-8s4
[5] Wayland from the ground up - Kevin Boone https://kevinboone.me/wayland_ground_up.html
[6] Beyond the Basics: In-Depth Look at Linux Display Servers, Window ... https://dev.to/sandheep_kumarpatro_1c48/beyond-the-basics-in-depth-look-at-linux-display-servers-window-managers-and-compositors-40bk
[7] Thoughts on writing a wayland window manager with wlroots https://inclem.net/2021/04/17/wayland/writing_a_wayland_compositor_with_wlroots/
[8] rcalixte/awesome-wayland: A curated list of Wayland resources https://github.com/rcalixte/awesome-wayland
[9] Recommended WM's? - All WMs - EndeavourOS Forum https://forum.endeavouros.com/t/recommended-wms/65323
[10] X Window System protocols and architecture https://en.wikipedia.org/wiki/X_Window_System_protocols_and_architecture

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

## Configuration File Locations

### Primary Configuration File

The main configuration file is located at `~/.config/hypr/hyprland.conf`. When launching Hyprland for the first time, it automatically generates an example config if none exists. The default system-wide template is stored at `/usr/share/hypr/hyprland.conf`. You can specify an alternative configuration file when launching Hyprland using the `--config` or `-c` flag.[1][2][3]

### Configuration Directory Structure

The `~/.config/hypr/` directory serves as the primary location for all Hyprland-related configuration. This directory typically contains:[3][4]

**Core Files:**
- `hyprland.conf` - Main configuration file[2][3]
- `hyprlock.conf` - Screen lock configuration[4]
- `hypridle.conf` - Idle daemon configuration[4]

**Subdirectories:**
- `scripts/` - Custom shell scripts for automation (wallpaper rotation, sunset modes, fixes)[4]
- `sources_example/` or similar - Modular configuration splits when using multi-file setups[4]

### Modular Configuration Structure

Rather than maintaining a single monolithic configuration file, you can split configurations into multiple files and include them using the `source` directive. The syntax is `source = ~/.config/hypr/filename.conf`. This approach creates a more maintainable structure where specific aspects are isolated.[5][6][3]

**Common Modular Splits:**
- `keybindings.conf` - All keyboard shortcuts and binds[5][4]
- `monitors.conf` - Display configuration[5][4]
- `autostart.conf` - Applications launched at startup[5][4]
- `aesthetics.conf` - Visual settings like animations, decorations, borders[5]
- `environment.conf` - Environment variables[5]
- `input.conf` - Keyboard, mouse, touchpad settings[5]
- `rules.conf` or `windowrules.conf` - Window and workspace rules[4][5]
- `variables.conf` - General variables and settings[5]

**Example:**
```
source = ~/.config/hypr/keybindings.conf
source = ~/.config/hypr/monitors.conf
source = ~/.config/hypr/autostart.conf
```


### Related Application Configurations

Additional Wayland and Hyprland ecosystem applications store their configs within `~/.config/` as separate directories:[4]

**Status Bars and Panels:**
- `~/.config/waybar/` - Waybar status bar configuration, styles, and scripts[4]
- `~/.config/eww/` - ElKowars wacky widgets configuration

**Application Launchers:**
- `~/.config/wofi/` - Wofi launcher configuration and styling[4]
- `~/.config/rofi/` - Rofi launcher configuration

**Notification Daemons:**
- `~/.config/mako/config` - Mako notification daemon configuration[3]
- `~/.config/mako/icons/` - PNG format icons for notifications[3]
- `~/.config/swaync/` - SwayNC notification center configuration[4]

**Terminal Emulators:**
- `~/.config/kitty/` - Kitty terminal configuration (default terminal)[4]
- `~/.config/alacritty/` - Alacritty terminal configuration

**Other Tools:**
- `~/.config/xdg-desktop-portal/` - Portal configuration for desktop integration[4]
- `~/.config/electron-flags.conf` - Global Electron app Wayland flags[1]

### Configuration Reload Behavior

Hyprland automatically reloads the configuration the moment you save `hyprland.conf`. You can manually trigger a reload using `hyprctl reload`. Some settings, particularly input device settings, may require restarting your Hyprland session to take effect. Settings can be changed temporarily on-the-fly using `hyprctl` commands, but these changes are not persistent and will be lost on reload.[2][3]

### Global vs User Configuration

Hyprland uses a user-specific configuration model where `~/.config/hypr/hyprland.conf` is the active configuration. Unlike some systems, there is no official global configuration directory like `/etc/xdg/hypr` that applies system-wide defaults. Distribution-specific configurations may place additional files in `/usr/share/` locations, but these are templates rather than active configs.[7][8][2][3]

Sources
[1] Master tutorial https://wiki.hypr.land/Getting-Started/Master-Tutorial/
[2] Configuring - Hyprland Wiki https://wiki.hyprland.org/0.41.2/Configuring/Configuring-Hyprland/
[3] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[4] Firstp1ck/Hyprland-Simple-Setup - GitHub https://github.com/Firstp1ck/Hyprland_simple-minimal_Setup
[5] A Noobs Guide to Hyprland | EP:2 - Configuration Structure https://www.youtube.com/watch?v=zUajubDOGTg
[6] How to easy source multi config files - hyprland https://www.reddit.com/r/hyprland/comments/1ahng0o/how_to_easy_source_multi_config_files/
[7] global config file? · Issue #1040 · hyprwm/Hyprland https://github.com/hyprwm/Hyprland/issues/1040
[8] Configuration Files Garuda Hyprland https://forum.garudalinux.org/t/configuration-files-garuda-hyprland/37672
[9] first time user dealing with config file : r/hyprland https://www.reddit.com/r/hyprland/comments/1cwmwdj/first_time_user_dealing_with_config_file/
[10] Configuring Hyprland https://wiki.hyprland.org/0.41.0/Configuring/Configuring-Hyprland/

## Tiling vs Floating Windows

### Tiling Windows

Tiling windows automatically arrange themselves to fill available screen space without overlapping, dividing the display into non-overlapping sections. When you open a new window in tiling mode, Hyprland automatically resizes and repositions existing windows to accommodate it, maintaining full screen coverage. This approach maximizes visibility and accessibility by ensuring every window is fully visible simultaneously.[8]

Tiling is Hyprland's primary mode of operation—the compositor is fundamentally designed as a tiling window manager. Tiled windows remain in the background layer relative to floating windows, meaning floating windows always display above tiled ones.[1][6][7]

### Floating Windows

Floating windows behave like traditional desktop windows, allowing free positioning anywhere on screen with arbitrary sizes. They can overlap each other and tiled windows, functioning independently without automatic arrangement. Floating windows always render above tiled windows by default. You cannot position a floating window behind a tiled window—this is an architectural limitation.[5][6][7][9][1]

Users can toggle individual windows between tiling and floating modes using the `togglefloating` dispatcher bound to a keybind. Window rules can force specific applications to always open as floating using `windowrulev2 = float, class:(app_name)`.[6][7][5]

While Hyprland supports floating windows well, they function as an additional feature rather than the core emphasis. Some users configure all windows to float by default through window rules, though this approach contradicts the compositor's primary design philosophy.[1][5]

### Dynamic vs Static Behavior

**Dynamic Tiling:** Hyprland implements dynamic tiling, meaning windows automatically resize based on how many windows occupy a workspace and the configured layout algorithm. When you add or remove windows, the compositor recalculates tile dimensions and repositions windows without manual intervention. This behavior adapts to configuration settings you define or sensible defaults that suit most workflows.[8]

**Manual Floating:** Floating windows require manual positioning and resizing—they do not automatically adjust when other windows open or close. Users control size and position explicitly through mouse dragging or dispatcher commands.[1]

## Dynamic Workspaces

Hyprland implements virtual desktops called workspaces that organize windows into separate logical screens. Workspaces are dynamic by default, meaning they are created automatically when you navigate to them or assign a window to them. Empty workspaces automatically disappear when you switch away from them, maintaining a minimal workspace count.[11][8]

You can make workspaces persistent (always present even when empty) through configuration using the `workspace` keyword with the `persistent:true` option. This prevents automatic workspace cleanup and maintains fixed workspace numbers.[1]

Workspaces can contain any combination of tiled and floating windows. Each workspace maintains its own window arrangement independent of other workspaces, allowing different organizational schemes per workspace.[8][1]

## Layouts

Hyprland provides two built-in layout algorithms that determine how tiled windows arrange themselves:

### Dwindle Layout (Default)

The dwindle layout is the default tiling algorithm in Hyprland. It implements a binary space partitioning approach where each new window splits the available space of the previously focused window. The first window occupies the full workspace, the second window splits it horizontally or vertically (alternating by default), and subsequent windows continue subdividing the focused tile. This creates a hierarchical tree structure of nested splits.[11]

### Master Layout

The master layout designates one or more windows as "master" windows that occupy a fixed portion of the screen (left side by default), while remaining windows tile in the remaining space. The master area takes priority, and auxiliary windows arrange themselves in the non-master region. This layout suits workflows where one primary application (editor, browser) deserves maximum space while secondary tools occupy smaller tiles.[10]

You can switch between layouts per-workspace using the `layoutmsg` dispatcher or set a default layout globally in your configuration. Layout-specific settings control split ratios, master window counts, and tiling orientations.[11]

Third-party plugins like `hy3` provide alternative layout algorithms beyond the built-in options, offering additional tiling behaviors like manual tree-based layouts.[1]

Sources
[1] Do you use Hyprland in tiled mode or windowed mode? https://www.reddit.com/r/hyprland/comments/1jeqc7x/do_you_use_hyprland_in_tiled_mode_or_windowed_mode/
[2] Window Rules https://wiki.hyprland.org/0.45.0/Configuring/Window-Rules/
[3] Floating windows extend beyond reserved area #11987 https://github.com/hyprwm/Hyprland/discussions/11987
[4] Is there any benefit in tiling only WMs vs using tiling let's ... https://news.ycombinator.com/item?id=39804683
[5] Hyprland with all windows floating… - Fedora Discussion https://discussion.fedoraproject.org/t/hyprland-with-all-windows-floating/83797
[6] How can you toggle "always on top" for multiple floating ... https://github.com/hyprwm/Hyprland/discussions/11511
[7] Allow floating windows under tiled windows · Issue #2683 https://github.com/hyprwm/Hyprland/issues/2683
[8] An Introduction To Hyprland ... https://www.youtube.com/watch?v=mmRKWgiPulg
[9] Dispatchers https://wiki.hyprland.org/0.41.0/Configuring/Dispatchers/
[10] Master Layout https://wiki.hypr.land/Configuring/Master-Layout/
[11] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland

## Launch Methods

### TTY Launch (Recommended)

The standard method is launching Hyprland directly from a TTY by typing `Hyprland` after logging in. After booting, log into your user account at the console and execute the command. This approach is officially supported and avoids the overhead of running a graphical login manager.[1][2][3][4][5]

**Important:** Never launch Hyprland with root permissions—do not use `sudo`. You can view launch flags with `Hyprland -h`, including options to set custom config paths.[5][1]

### Automatic TTY Launch

You can configure automatic Hyprland launch on TTY1 login by adding to your shell profile:[2][4]

**Bash (`~/.bash_profile`):**
```bash
[[ "$(tty)" == /dev/tty1 ]] && Hyprland
```


**Zsh (`~/.zprofile`):**
```bash
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec Hyprland
fi
```


This launches Hyprland automatically when logging into TTY1 without requiring manual execution. Users can automatically login using xinit-style methods adapted from the Arch Wiki.[4][2]

### Display Manager Support

Login managers are not officially supported, but several work with varying compatibility:[1]

**SDDM (Recommended):** Works flawlessly with Hyprland. Install SDDM version 0.20.0 or later, or use `sddm-git` from AUR to prevent bug 1476 causing 90-second shutdowns. Enable with `sudo systemctl enable sddm.service`. SDDM provides extensive theming options like the Sugar-Candy theme available via `yay -S sddm-theme-sugar-candy`.[1][5][3][1]

**GDM:** Works but crashes Hyprland on the first launch. Some users report GDM causing persistent issues, making it less reliable than SDDM.[3][1]

**greetd:** Works flawlessly, especially with ReGreet frontend. Greetd is a minimal Wayland-native greeter often used with autologin configurations. Configure autologin in greetd's config file to skip the login screen entirely.[3][1][2]

**ly:** Works flawlessly. Ly is a TUI (text-based) login manager that's lightweight and simple. Configure keyring unlocking in ly's config if needed.[1][3]

**lemurs:** A lightweight, simple option that's easy to configure and solves common keyring and compatibility issues.[3]

### Session Selection

When using a display manager, select "Hyprland" from the session menu at login. Avoid selecting "Hyprland-uwsm-managed" unless specifically using uwsm. If Hyprland doesn't appear in the session list, the installation may be incomplete—check install logs and rerun the installation script.[6]

## First Boot Considerations

### Initial Configuration

On first launch, Hyprland generates an example configuration at `~/.config/hypr/hyprland.conf` if none exists. The default config provides basic functionality with the dwindle tiling layout and standard keybinds.[7][1]

### Default Terminal

Install `kitty` terminal emulator before first launch, as it's the default terminal configured in Hyprland. Kitty is available in most distribution repositories and can be installed with `sudo pacman -S kitty` on Arch.[1]

### Virtual Machine Setup

If running Hyprland in a VM, enable 3D acceleration in your virtio or virt-manager configuration—Hyprland will not work without it. GPU passthrough is an alternative option for better performance. Note that 3D acceleration in VMs may be significantly slower than native hardware.[1]

### Login Loop Troubleshooting

If the display manager returns to the login screen after attempting to log in, check installation logs in your distribution's Hyprland install-logs directory. Common causes include improperly installed packages or missing 3D acceleration in VMs. Manually launch Hyprland from a TTY using Ctrl+Alt+F2 or F3 to diagnose issues—if the `Hyprland` command is not found, packages weren't installed correctly.[6]

## Keyring and Session Management

### Gnome Keyring Unlocking

When using TTY launch without a display manager, manually configure keyring unlocking by editing `/etc/pam.d/login`:[7]

```
auth optional pam_gnome_keyring.so
session optional pam_gnome_keyring.so auto_start
```


Add to `~/.profile`:
```bash
if [ -n "$DESKTOP_SESSION" ];then
  eval $(gnome-keyring-daemon --start --components=secrets)
  export SSH_AUTH_SOCK
fi
```


Add to Hyprland config:
```
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
```


### Alternative: Hyprlock as Login Screen

Some users configure greetd with autologin and launch `hyprlock` via `exec-once` in Hyprland config, effectively using hyprlock as a pseudo-login manager. This method works for basic use cases but does not replace proper display manager functionality and has security implications—there's a timeframe where Hyprland accepts input before hyprlock activates.[8][2]

Sources
[1] Master tutorial https://wiki.hypr.land/Getting-Started/Master-Tutorial/
[2] Proper way to launch Hyprland - Reddit https://www.reddit.com/r/hyprland/comments/1e5qgoj/proper_way_to_launch_hyprland/
[3] Which loginmanager to use? : r/hyprland https://www.reddit.com/r/hyprland/comments/14voff7/which_loginmanager_to_use/
[4] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[5] Master tutorial - Hyprland Wiki https://wiki.hyprland.org/0.41.0/Getting-Started/Master-Tutorial/
[6] FAQ_Login_Managers · JaKooLit/Hyprland-Dots Wiki https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ_Login_Managers
[7] Configuring - Hyprland Wiki https://wiki.hyprland.org/0.41.2/Configuring/Configuring-Hyprland/
[8] Documentation on "How can I use Hyprlock as a login ... https://github.com/hyprwm/hyprlock/issues/564
[9] Set Display Manager on Startup (Hyprland) : r/archlinux https://www.reddit.com/r/archlinux/comments/1dxnr7a/set_display_manager_on_startup_hyprland/
[10] How to enable login screen and start hyperland after login https://discourse.nixos.org/t/how-to-enable-login-screen-and-start-hyperland-after-login/37775
[11] A Noobs Guide to Hyprland | Customizing SDDM Display ... https://www.youtube.com/watch?v=9RLl9VyeTBo

# Core Configuration

## Configuration File Organization

### Syntax Basics

Configuration follows a simple key-value syntax where each line consists of a command followed by a value. The syntax is `COMMAND=VALUE`, with trailing spaces allowed before and after both command and value. Comments begin with `#`, and escaping a literal `#` character requires `##`, which renders as a single `#` in the final config.[1][2]

### Sections and Grouping

Configuration uses grouped sections enclosed in braces for organizing related settings. Start a section with `name {` and end with `}`, with each brace on separate lines. Common section types include named monitor definitions, animations, and layout-specific configurations.[2][1]

**Common Sections:**
- `general { }` - Core Hyprland behavior settings[3][1]
- `input { }` - Keyboard, mouse, and touchpad configuration[3][1]
- `device { }` - Per-device input customization[1][3]
- `decoration { }` - Visual styling including borders, shadows, rounding[3][1]
- `animations { }` - Animation curves and speed definitions[1][3]
- `dwindle { }` - Dwindle layout-specific settings[3][1]
- `master { }` - Master layout-specific settings[1][3]
- `group { }` - Window group styling and behavior[4]

### Variables and Environment

Variables define toggleable and numerical options controlling Hyprland's behavior. These are top-level assignments without section enclosure, configurable through the `general`, `input`, `decoration`, and other section variables.[3][1]

Environment variables can be set directly in the config using the `env` keyword with different syntax than standard Unix shell exports. Example:[1]
```
env = LIBVA_DRIVER_NAME,nvidia
env = QT_QPA_PLATFORMTHEME,qt5ct
```


### Keybinds

Keybinds are defined with the `bind` or `binde` keywords (deprecated `bindsym`) specifying modifier keys, physical key, and dispatcher action. Format: `bind = MOD, KEY, dispatcher, args`. Modifiers include Super (Windows key), Alt, Shift, Control, and custom modifiers. Multiple modifiers separate with `+` (e.g., `SUPER+SHIFT`).[10][8]

### Window Rules

Window rules conditionally apply settings to specific windows based on matching criteria. The syntax `windowrulev2 = RULE, CONDITION` matches against window properties like class, title, workspace, or floating state. Multiple conditions combine with commas to further narrow matching.[5][2]

**Matching Fields:**
- `class:[RegEx]` - Match window class (case-sensitive)[5]
- `title:[RegEx]` - Match window title[5]
- `workspace:[w]` - Match workspace ID or name[5]
- `floating:[0/1]` - Match floating/tiled state[5]
- `focus:[0/1]` - Match currently focused window[5]
- `initialClass` / `initialTitle` - Match at window creation[5]

As of Hyprland v0.46.0, RegEx patterns must fully match window values—partial matches require explicit wildcard patterns like `.*pattern.*`. Window rules evaluate top-to-bottom, so ordering matters.[5]

### Keywords and Special Directives

Special keywords beyond variables handle complex configuration:[2]

- `monitor` - Physical display configuration[2][1]
- `workspace` - Workspace layout and properties[2]
- `exec-once` - Commands run once per session[1][2]
- `exec` - Commands run on each config reload[2][1]
- `source` - Include external config files[6][2]
- `bezier` - Define custom animation curves[2]
- `animation` - Configure animation behavior[2]

### Configuration Reloading

The config automatically reloads when saved to `~/.config/hypr/hyprland.conf`. Manual reload via `hyprctl reload` achieves the same effect. Some settings—particularly input device configuration—require restarting the Hyprland session to take effect. Settings changed with `hyprctl` commands apply immediately but do not persist across reloads.[1][2]

### Error Handling

The line `autogenerated=1` appears in auto-generated configs and displays a yellow warning. Removing this line eliminates the warning. Plugin users can wrap problematic sections with `# hyprlang noerror true` and `# hyprlang noerror false` to suppress errors from missing options before plugins load.[2]

### Modular Configuration Example

A typical modular structure sources separate files for organization:
```
source = ~/.config/hypr/environment.conf
source = ~/.config/hypr/monitors.conf
source = ~/.config/hypr/keybindings.conf
source = ~/.config/hypr/input.conf
source = ~/.config/hypr/windowrules.conf
source = ~/.config/hypr/aesthetics.conf
source = ~/.config/hypr/autostart.conf
```


Each file follows the same syntax rules and can contain complete sections or individual directives. This approach keeps the main config file simple while maintaining organized, maintainable settings across focused files.[7][1][2]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Configuring Hyprland https://wiki.hyprland.org/0.41.0/Configuring/Configuring-Hyprland/
[3] Variables https://wiki.hypr.land/Configuring/Variables/
[4] Dispatchers https://wiki.hyprland.org/0.41.0/Configuring/Dispatchers/
[5] Window Rules https://wiki.hypr.land/Configuring/Window-Rules/
[6] How to easy source multi config files - hyprland https://www.reddit.com/r/hyprland/comments/1ahng0o/how_to_easy_source_multi_config_files/
[7] Hyprland https://wiki.archcraft.io/docs/wayland-compositors/hyprland/
[8] Update on my Hyprland Config UI: Keybinds, comments ... https://www.reddit.com/r/hyprland/comments/1ok5rj0/update_on_my_hyprland_config_ui_keybinds_comments/
[9] HyprlandConfig in hyprparser - Rust https://docs.rs/hyprparser/latest/hyprparser/struct.HyprlandConfig.html
[10] Configuring https://wiki.hypr.land/Configuring/
[11] Window Rules not working as expected after updating ... https://github.com/hyprwm/Hyprland/issues/8831
[12] NVidia https://wiki.hypr.land/Nvidia/

## General Settings

The `general` section contains the foundational behavior and visual appearance settings for Hyprland. This section is wrapped in braces and controls window sizing, gaps, borders, colors, and the default tiling layout.[1][2]

### Window Borders and Sizing

**border_size** sets the thickness of window borders in logical pixels, with a default of 1. Set to 0 to disable borders entirely. **no_border_on_floating** disables borders specifically for floating windows while preserving them on tiled windows, defaulting to false.[2]

**resize_on_border** enables resizing windows by clicking and dragging on borders and gaps when set to true. This allows direct border manipulation instead of requiring a modifier key plus mouse drag. **extend_border_grab_area** expands the clickable resize area around borders by the specified number of logical pixels (default 15), making resizing easier on smaller borders. **hover_icon_on_border** displays a cursor resize icon when hovering over resizable borders, only active when `resize_on_border` is enabled.[2]

**resize_corner** forces floating windows to resize from a specific corner (1=top-left, 2=top-right, 3=bottom-right, 4=bottom-left, 0=disabled). This prevents corner-dependent resizing conflicts.[1][2]

### Gaps and Workspace Spacing

**gaps_in** controls the spacing between adjacent tiled windows, defaulting to 5 pixels. Supports CSS-style specifications with four values for top, right, bottom, and left individually (e.g., `5,10,15,20`).[2]

**gaps_out** controls the spacing between windows and monitor edges, defaulting to 20 pixels. Also supports CSS-style gap specifications. **float_gaps** controls gaps for floating windows independently, defaulting to 0 (use standard gaps), and can be set to -1 to inherit from gaps_in and gaps_out. **gaps_workspaces** adds additional gaps between virtual workspaces, stacking with gaps_out.[2]

### Border Colors

**col.active_border** sets the border color for the currently focused window, supporting gradient definitions, defaulting to white (0xffffffff). **col.inactive_border** sets the border color for non-focused windows, defaulting to dark gray (0xff444444).[2]

**col.nogroup_border** and **col.nogroup_border_active** control border colors for windows that cannot be added to groups, with distinct colors for inactive and active states. Colors accept multiple formats: rgba (e.g., `rgba(b3ff1aee)`), rgb (e.g., `rgb(b3ff1a)`), or legacy ARGB (e.g., `0xeeb3ff1a`).[2]

### Layout Configuration

**layout** selects the default tiling algorithm for the workspace, accepting either `dwindle` (default) or `master`. This determines how new windows automatically partition available screen space.[2]

### Focus and Navigation

**no_focus_fallback** prevents focus from shifting to the next available window when moving in a direction with no window present, defaulting to false. When true, focus remains unchanged if the direction is empty.[2]

### Advanced Window Behavior

**allow_tearing** enables screen tearing when set to true, reducing latency for fast-moving content in supported scenarios. This is a master switch—individual per-application tearings are controlled separately.[2]

**snap** is a subcategory controlling floating window snapping behavior. **enabled** toggles snapping functionality. **window_gap** sets the minimum pixel distance between windows before snapping engages (default 10). **monitor_gap** sets minimum distance between a window and monitor edges before snapping (default 10). **border_overlap** makes windows snap such that only one border's worth of space separates them when true. **respect_gaps** honors gaps_in when snapping if enabled.[2]

### Example Configuration

A basic general section setup:
```
general {
  border_size = 2
  gaps_in = 5
  gaps_out = 10
  col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
  col.inactive_border = rgba(595959aa)
  layout = dwindle
  resize_on_border = true
  extend_border_grab_area = 15
  
  snap {
    enabled = true
    window_gap = 10
    monitor_gap = 10
  }
}
```

Sources
[1] Customizing Hyprland to Your Liking - It's FOSS https://itsfoss.com/configuring-hyprland/
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/
[3] Configuring - Hyprland Wiki https://wiki.hypr.land/Configuring/
[4] Configuring - Hyprland Wiki https://wiki.hyprland.org/0.41.0/Configuring/Configuring-Hyprland/
[5] Configuring Hyprland - GitHub https://github.com/hyprwm/Hyprland/wiki/Configuring-Hyprland/4366ee62f37b7be41b372a69408f55dc4cd7d7b7
[6] Help I really like Hyprland, but the general documentation and ... https://www.reddit.com/r/hyprland/comments/15cl3pc/help_i_really_like_hyprland_but_the_general/
[7] Hyprland windows gaps - Issues & Assistance - CachyOS Forum https://discuss.cachyos.org/t/hyprland-windows-gaps/8533
[8] [Feature Request]: Setting on Hyprland.conf to change mouse speed https://github.com/prasanthrangan/hyprdots/issues/907
[9] Variables - Hyprland Wiki https://wiki.hyprland.org/0.45.0/Configuring/Variables/
[10] Basic Config · hyprwm/Hyprland Wiki - GitHub https://github.com/hyprwm/Hyprland/wiki/Basic-Config/b1bd6a563aa109de0918b1573e3e8a52d4413990

## Input Devices

The `input` section contains keyboard and mouse configuration settings controlling how input devices behave. This section manages keyboard layout, repeat rates, mouse sensitivity, and device-specific behavior.[1]

### Keyboard Configuration

**kb_layout** sets the keyboard layout using XKB codes, defaulting to US (`us`). Common values include `us`, `de`, `fr`, `gb`, `jp`. **kb_variant** specifies layout variants like `dvorak`, `colemak`, `qwerty` for layouts supporting variants, defaulting to empty (standard variant).[1]

**kb_model** sets the keyboard model according to XKB specifications, defaulting to empty. **kb_options** applies XKB options like `grp:shifts_toggle` for layout switching, defaulting to empty. **kb_rules** specifies XKB rules files, defaulting to empty.[1]

You can use `localectl list-x11-keymap-variants` and `localectl list-x11-keymap-layouts` to discover available options on your system.[1]

**kb_file** accepts a custom XKB file path, allowing complete custom keyboard definitions when set. **numlock_by_default** enables Numlock on startup when set to true, defaulting to false.[1]

**repeat_rate** controls how many times per second a held-down key repeats, defaulting to 25 repeats per second. **repeat_delay** sets the delay before repetition begins in milliseconds, defaulting to 600ms.[1]

### Mouse and Cursor Sensitivity

**sensitivity** sets mouse input sensitivity as a float between -1.0 and 1.0 (default 0.0). Positive values increase speed, negative values decrease it, and 0.0 uses the default system setting.[1]

**accel_profile** selects the cursor acceleration profile from `adaptive` (default curves with acceleration), `flat` (linear 1:1 movement), or `custom` (user-defined via `scroll_points`). Leave empty to use libinput's default profile. **force_no_accel** bypasses acceleration entirely when true, providing raw cursor input but risking desynchronization.[1]

**left_handed** swaps right and left mouse buttons when true, defaulting to false.[1]

### Scrolling Configuration

**scroll_method** determines how scrolling is interpreted, accepting `2fg` (two-finger touchpad scroll), `edge` (edge scrolling), `on_button_down` (button-initiated scrolling), or `no_scroll` (disabled). **scroll_button** sets which mouse button triggers scrolling (0 for default). **scroll_button_lock** prevents holding the button—pressing toggles scroll mode instead.[1]

**scroll_factor** multiplies scroll movement, defaulting to 1.0. **natural_scroll** inverts scrolling direction when true, making content move with your fingers rather than scrolling a scrollbar.[1]

### Focus and Warping

**follow_mouse** controls cursor focus behavior: 0 (cursor doesn't focus windows), 1 (cursor always focuses window under it, default), 2 (clicking focuses, cursor movement doesn't), 3 (complete separation between cursor and keyboard focus).[1]

**follow_mouse_threshold** sets minimum mouse movement in pixels before focusing, only working with `follow_mouse=1`, defaulting to 0. **focus_on_close** determines focus when a window closes: 0 (shift to next window), 1 (focus window under cursor).[1]

**mouse_refocus** prevents focus-switching unless the cursor crosses a window boundary when `follow_mouse=1`, defaulting to true. **float_switch_override_focus** changes focus behavior when switching between tiling and floating: 0 (no change), 1 (follow cursor, default), 2 (follow cursor on all floating switches).[1]

**resolve_binds_by_sym** determines keybind resolution with multiple keyboard layouts: false (always use first layout), true (keybinds use current layout symbols).[1]

### Advanced Cursor Control

**off_window_axis_events** handles scroll events at window edges: 0 (ignore), 1 (send out-of-bound coordinates), 2 (fake coordinates to closest inside point), 3 (warp cursor inside).[1]

**emulate_discrete_scroll** emulates discrete scrolling from high-resolution events: 0 (disable), 1 (only non-standard), 2 (force all). **rotation** rotates input device orientation in degrees (0-359), defaulting to 0.[1]

### Touchpad-Specific Settings

The `input:touchpad` subcategory controls touchpad behavior separately from mice. **disable_while_typing** disables the touchpad while typing to prevent accidental input, defaulting to true. **natural_scroll** inverts touchpad scrolling when true.[1]

**tap-to-click** enables tap-based button emulation: 1 finger = left-click, 2 fingers = right-click, 3 fingers = middle-click, defaulting to true. **clickfinger_behavior** enables the same multi-finger mapping as tap-to-click but for physical clicks.[1]

**middle_button_emulation** interprets simultaneous left and right clicks as middle-click when true. **drag_lock** prevents item drops when lifting fingers: 0 (disabled), 1 (timeout-based), 2 (sticky mode).[1]

**tap-and-drag** enables dragging by tapping and holding without re-tapping, defaulting to true. **tap_button_map** selects tap-to-button mapping: `lrm` (left, right, middle), `lmr` (left, middle, right).[1]

**flip_x** and **flip_y** invert horizontal and vertical touchpad movement respectively, both defaulting to false. **scroll_factor** multiplies touchpad scroll movement separately from mice. **drag_3fg** enables three-finger drag: 0 (disabled), 1 (three fingers), 2 (four fingers).[1]

### Per-Device Configuration

The `device` keyword allows per-device overrides targeting specific input devices by name. Use `hyprctl devices` to list connected devices, then create device sections:[1]
```
device:name {
  sensitivity = 0.5
  accel_profile = flat
}
```


Settings in `device` sections override global `input` settings for matching devices.[1]

### Touch Devices

The `input:touchdevice` subcategory configures touchscreen-specific behavior. **output** binds touch input to a specific monitor (e.g., for dual-monitor tablet users), defaulting to auto-detection. **transform** rotates touch input like monitors, with -1 meaning unset (uses monitor rotation). **enabled** toggles touch input when false.[1]

### Tablet Configuration

The `input:tablet` subcategory handles graphics tablet input. **output** binds the tablet to a specific monitor or `current` for active monitor. **relative_input** switches between absolute positioning and relative cursor movement.[1]

**region_size** and **region_position** define a mapped input area on the tablet that corresponds to the output screen. **active_area_size** and **active_area_position** specify the tablet's physical active area dimensions in millimeters. **left_handed** rotates the tablet 180 degrees for left-handed use.[1]

Sources
[1] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Display & Monitors

Monitor configuration uses the `monitor` keyword with the basic syntax `monitor = name, resolution, position, scale`. List available monitors using `hyprctl monitors all` to get exact names and capabilities. The position is calculated in pixels from the virtual layout's top-left corner.[1]

### Resolution and Refresh Rate

Resolution follows the format `WIDTHxHEIGHT@REFRESH`, where refresh rate in Hz is optional. A common configuration:[1]
```
monitor = DP-1, 1920x1080@144, 0x0, 1
```


This creates a 1920x1080 display at 144Hz positioned at (0,0) with 1x scale. Special resolution keywords include `preferred` (display's default resolution and refresh), `highres` (highest supported resolution), `highrr` (highest supported refresh rate), and `maxwidth` (widest supported resolution).[2][1]

### Display Positioning

Position coordinates define the monitor's location within Hyprland's virtual layout, calculated from the top-left corner. For two monitors side-by-side:[1]
```
monitor = DP-1, 1920x1080, 0x0, 1
monitor = DP-2, 1920x1080, 1920x0, 1
```


This places DP-1 on the left and DP-2 on the right. Hyprland uses an inverse Y coordinate system where negative Y places monitors higher and positive Y places them lower.[1]

For vertical stacking:
```
monitor = DP-1, 1920x1080, 0x0, 1
monitor = DP-2, 1920x1080, 0x1080, 1
```


Position calculations account for scaled resolutions—a 4K monitor with scale 2 has effective positioning at half its resolution. No monitors can overlap; overlapping configurations generate warnings.[1]

### Auto-Positioning

Special position values automate layout:[1]

**Basic Auto:** `auto` lets Hyprland decide, defaulting to placing each new monitor to the right of existing ones. **Directional Auto:** `auto-right`, `auto-left`, `auto-up`, `auto-down` position monitors in specified directions from existing ones. **Center-based Auto:** `auto-center-right`, `auto-center-left`, `auto-center-up`, `auto-center-down` position from each monitor's center rather than its corner.[1]

Quick multi-monitor catch-all:
```
monitor = , preferred, auto, 1
```


This configures any unspecified monitor with its preferred resolution, auto-positioned, at 1x scale.[1]

### Scaling (DPI)

Scale is a multiplier determining logical vs physical resolution. Scale 1 shows pixels 1:1, scale 1.5 creates a 50% DPI scaling for HiDPI displays, and scale 2 creates 100% scaling. Auto-scaling uses `auto` as the scale value, letting Hyprland determine appropriate scaling based on PPI.[1]

Scaling affects positioning calculations—a scaled monitor's position uses its effective dimensions.[1]

### Rotation and Mirroring

Add `, transform, X` to rotate monitors, where X is:[1]

- `0` - Normal (no rotation)
- `1` - 90 degrees
- `2` - 180 degrees
- `3` - 270 degrees
- `4` - Flipped
- `5` - Flipped + 90 degrees
- `6` - Flipped + 180 degrees
- `7` - Flipped + 270 degrees

[1]

Mirror displays with `, mirror, MONITOR_NAME`. Note that mirroring does not re-render content for the mirrored resolution—a 1080p screen mirrored to 4K remains 1080p. Aspect ratio mismatches cause stretching/squishing.[1]

### Advanced Display Features

**10-bit Support:** Add `, bitdepth, 10` to enable 10-bit color depth. Colors defined in Hyprland (borders, etc.) do not support 10-bit. Some applications cannot capture with 10-bit enabled.[1]

**Color Management:** Use `, cm, X` to set color management presets. Options include `srgb` (default), `dcip3`, `dp3`, `adobe`, `wide` (BT2020), `edid` (from display EDID), and `hdr` (experimental, requires wide color gamut). For HDR, use `, sdrbrightness, B, sdrsaturation, S` to adjust SDR brightness and saturation (default 1.0).[1]

**VRR (Variable Refresh Rate):** Add `, vrr, X` where X is a mode from the variables page.[1]

### Disabling Monitors

Disable monitors with `monitor = name, disable`. This removes the monitor from layout, moving all windows and workspaces to remaining displays. To power-off a monitor without disabling it, use the `dpms` dispatcher.[1]

### Monitor Description Matching

Use monitor descriptions for device-agnostic configuration. Get descriptions from `hyprctl monitors` output, removing the port name:[1]
```
monitor = desc:Chimei Innolux Corporation 0x150C, preferred, auto, 1.5
```


This configuration applies to any monitor with that description regardless of connection port.[1]

### Custom Reserved Area

Add workspace gaps without tiling windows by using:[1]
```
monitor = name, addreserved, TOP, BOTTOM, LEFT, RIGHT
```


Where TOP, BOTTOM, LEFT, RIGHT are pixel values. This stacks with existing reserved areas like bars.[1]

### Alternative Monitor v2 Syntax

Verbose syntax using `monitorv2` blocks provides equivalent configuration:[1]
```
monitorv2 {
  output = DP-1
  mode = 1920x1080@144
  position = 0x0
  scale = 1
  transform = 2
}
```

Sources
[1] Monitors https://wiki.hypr.land/Configuring/Monitors/
[2] I need help with Refresh rate · hyprwm Hyprland https://github.com/hyprwm/Hyprland/discussions/3706
[3] Refresh rate : r/hyprland https://www.reddit.com/r/hyprland/comments/17577rf/refresh_rate/
[4] Monitors https://wiki.hyprland.org/0.46.0/Configuring/Monitors/
[5] A Noobs Guide to Hyprland | EP:3 - Monitor Setup https://www.youtube.com/watch?v=FSL8uPPC8V8
[6] Hyprland workspace configuration - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=298652
[7] My scaling changes to 1.5 anytime I update hyprland.conf https://www.reddit.com/r/hyprland/comments/1ebe6hp/my_scaling_changes_to_15_anytime_i_update/
[8] Resolution and refresh rate for a headless output #5415 https://github.com/hyprwm/Hyprland/issues/5415
[9] Monitors - Hyprland Wiki https://wiki.hyprland.org/0.41.2/Configuring/Monitors/
[10] erans/hyprmon: TUI monitor configuration tool for Hyprland ... https://github.com/erans/hyprmon

## Decorations & Visual Effects

The `decoration` section controls window styling, visual effects, and blur behavior. This section defines how windows appear on screen including borders, shadows, transparency, and background blur effects.[1]

### Rounding and Corners

**rounding** sets the corner radius in logical pixels, defaulting to 0 (sharp corners). Values define the curvature applied to all window corners. **rounding_power** adjusts the curve formula for rounding: 1.0 creates triangular corners, 2.0 produces perfect circles, 4.0 creates squircles, and values up to 10.0 provide increasingly smooth curves (default 2.0).[1]

### Opacity and Transparency

**active_opacity** sets the opacity of the currently focused window between 0.0 (fully transparent) and 1.0 (fully opaque), defaulting to 1.0. **inactive_opacity** applies to unfocused windows, also defaulting to 1.0. **fullscreen_opacity** controls opacity for fullscreen windows specifically, defaulting to 1.0.[1]

Setting opacity below 1.0 makes windows semi-transparent, allowing content behind them to show through. This is purely visual—transparent windows remain fully interactive.[1]

### Dimming and Darkening

**dim_modal** enables darkening of parent windows when their child modal dialogs are open, defaulting to true. This effect dims everything behind the modal, directing focus to the dialog.[1]

**dim_inactive** darkens inactive (unfocused) windows when enabled, defaulting to false. **dim_strength** controls how much inactive windows are dimmed between 0.0 (no dimming) and 1.0 (maximum darkness), defaulting to 0.5.[1]

**dim_special** controls dimming when a special workspace is active, darkening the background workspace (default 0.2). **dim_around** sets dimming for windows with the `dimaround` rule (default 0.4).[1]

### Border and Window Styling

**border_part_of_window** determines whether window borders count toward window dimensions when set to true, defaulting to true. When true, borders are included in resize operations and geometry calculations.[1]

### Blur Effects

The `blur` subcategory controls Kawase window background blur, the blurred area visible behind semi-transparent windows.[1]

**enabled** toggles blur functionality (default true). **size** sets the blur distance/radius in pixels (default 8). **passes** specifies how many times the blur algorithm repeats—higher values produce stronger blur but consume more GPU (default 1). Most configurations require at least 2-3 passes for noticeable blur with larger sizes.[1]

**ignore_opacity** makes blur ignore window opacity when true, always applying full blur strength regardless of transparency (default true). **new_optimizations** enables performance improvements, strongly recommended to keep enabled (default true).[1]

**xray** when enabled, makes floating windows ignore tiled windows when calculating blur, reducing blur calculation overhead (only works with new_optimizations).[1]

**Blur Appearance:** **noise** adds visible grain (0.0-1.0, default 0.0117). **contrast** modulates blur contrast (0.0-2.0, default 0.8916). **brightness** modulates blur brightness (0.0-2.0, default 0.8172). **vibrancy** increases color saturation of blurred areas (0.0-1.0, default 0.1696). **vibrancy_darkness** strengthens vibrancy effect on dark areas (0.0-1.0, default 0.0).[1]

**Special Blur Settings:** **special** blurs behind special workspaces when enabled, though this is computationally expensive (default false). **popups** blurs right-click menus and similar popups (default false). **popups_ignorealpha** prevents blurring very transparent popups below the specified threshold (0.0-1.0, default 0.2). **input_methods** blurs input method (IME) overlays (default false).[1]

### Shadows

The `shadow` subcategory controls drop shadows rendered around windows.[1]

**enabled** toggles shadow rendering (default true). **range** sets shadow size/spread distance in logical pixels (default 4). **render_power** controls falloff sharpness: values 1-4 where higher values create faster falloff (default 3). **sharp** when enabled, creates infinitely sharp shadow falloff instantly (default false).[1]

**ignore_window** when true, renders shadows only around windows, not behind them (default true). **color** sets the shadow color using rgba format, with alpha controlling shadow opacity (default 0xee1a1a1a, dark with moderate opacity). **color_inactive** sets distinct shadow color for unfocused windows when specified.[1]

**offset** positions the shadow with a vec2 (x y) offset from the window, allowing directional shadow displacement (default ). **scale** multiplies shadow size between 0.0 and 1.0 (default 1.0).[1]

### Screen Shader

**screen_shader** accepts a path to a custom fragment shader applied to the final rendered frame. This allows post-processing effects like color grading, vignetting, or distortion applied to the entire screen. See the Hyprland examples directory for shader template usage.[1]

### Example Configuration

```
decoration {
  rounding = 10
  rounding_power = 2.0
  active_opacity = 1.0
  inactive_opacity = 0.9
  
  dim_inactive = true
  dim_strength = 0.3
  
  blur {
    enabled = true
    size = 8
    passes = 2
    noise = 0.01
    contrast = 0.8916
    brightness = 0.8172
    vibrancy = 0.1696
  }
  
  shadow {
    enabled = true
    range = 4
    render_power = 3
    color = rgba(1a1a1aee)
    offset = [0, 0]
  }
}
```

Sources
[1] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Animations

The `animations` section controls all transition effects when windows open, close, move, fade, or switch workspaces. Animations are hierarchical—unset animations inherit properties from their parent in the animation tree.[1]

### Animation Syntax

Animations follow the syntax `animation = NAME, ONOFF, SPEED, CURVE [,STYLE]`. **ONOFF** is 0 (disabled) or 1 (enabled)—when disabled, further arguments can be omitted. **SPEED** measures duration in ds (deciseconds, where 1ds = 100ms), so a speed of 8 equals 800ms. **CURVE** is the bezier curve name controlling easing behavior. **STYLE** is optional and specifies the animation type (e.g., `slide`, `popin`, `fade`).[1]

### Bezier Curves

Custom bezier curves define animation acceleration and deceleration using the syntax `bezier = NAME, X0, Y0, X1, Y1`. The four values define two control points for a cubic bezier curve, controlling how the animation progresses from 0 to 1. Design curves visually at cssportal.com or use pre-made easing functions from easings.net.[1]

**Example curves:**
```
bezier = default, 0.25, 0.1, 0.25, 1
bezier = overshoot, 0.05, 0.9, 0.1, 1.1
bezier = smoothOut, 0.36, 0, 0.66, -0.56
bezier = smoothIn, 0.25, 1, 0.5, 1
```


An overshoot curve with Y values exceeding 1.0 creates bouncy animations where the target "overshoots" before settling, producing spring-like effects.[2][1]

### Animation Tree

Hyprland organizes animations hierarchically under `global`:[1]

**Windows:**
- `windows` - General window open/close animations
- `windowsIn` - Specifically window opening
- `windowsOut` - Specifically window closing
- `windowsMove` - Movement, dragging, resizing animations

[1]

**Fading:**
- `fade`, `fadeIn`, `fadeOut`, `fadeSwitch`, `fadeShadow`, `fadeDim`, `fadeLayers`, `fadeLayersIn`, `fadeLayersOut` - Various fade transitions[1]

**Workspaces:**
- `workspaces`, `workspacesIn`, `workspacesOut` - Workspace switching animations
- `specialWorkspace`, `specialWorkspaceIn`, `specialWorkspaceOut` - Special workspace animations

[1]

**Other:**
- `border` - Border color transitions
- `borderangle` - Animated gradient angle rotation (uses `loop` style for continuous rotation)[1]
- `layers` - UI element animations like status bars
- `zoomFactor` - Screen zoom animations
- `monitorAdded` - Animation when a monitor connects

[1]

### Window Animation Styles

**slide** creates directional sliding entrance/exit, optionally specifying `top`, `bottom`, `left`, or `right` direction (e.g., `slide left`). **popin** scales from a percentage (e.g., `popin 80%` animates from 80% to 100% size). **gnomed** adds a macOS-style animation effect.[1]

### Workspace Animation Styles

**slide** horizontally slides between workspaces. **slidevert** vertically slides (useful with vertical workspace layouts). **fade** fades between workspaces instead of sliding. **slidefade** combines sliding and fading effects, optionally specifying movement percentage (e.g., `slidefade 20%`). **slidefadevert** is vertical variant of slidefade.[1]

### Performance Considerations

The `borderangle` animation with `loop` style requires constant rendering at screen refresh rate (e.g., 60fps), stressing CPU/GPU and impacting battery life. This occurs even when animations are disabled or borders aren't visible.[1]

### Example Configuration

```
animations {
  enabled = true
  
  bezier = myBezier, 0.05, 0.9, 0.1, 1.05
  bezier = overshot, 0.05, 0.9, 0.1, 1.1
  bezier = smoothOut, 0.36, 0, 0.66, -0.56
  
  animation = windows, 1, 7, myBezier
  animation = windowsIn, 1, 7, myBezier, popin 80%
  animation = windowsOut, 1, 7, smoothOut, popin 80%
  animation = windowsMove, 1, 7, default
  animation = fade, 1, 7, default
  animation = border, 1, 10, default
  animation = borderangle, 1, 8, default
  
  animation = workspaces, 1, 6, overshot, slide
  animation = specialWorkspace, 1, 6, overshot, slide
}
```

Sources
[1] Animations - Hyprland Wiki https://wiki.hypr.land/Configuring/Animations/
[2] hyprland animations curves - Reddit https://www.reddit.com/r/hyprland/comments/1e3hoe6/hyprland_animations_curves/
[3] How To Customize Animations in Hyprland - YouTube https://www.youtube.com/watch?v=YetfV4MaBT8
[4] hyprwm/Hyprland - GitHub https://github.com/hyprwm/Hyprland
[5] https://raw.githubusercontent.com/miklevin/MikeLev... https://raw.githubusercontent.com/miklevin/MikeLev.in/main/_posts/2024-12-23-nixos-wayland-hyprland.md
[6] Hyprland | Phundrak's Dotfiles https://config.phundrak.com/hyprland
[7] feat(hyprland): add bezier curves & tweak animations - rosa.radicle.xyz https://app.radicle.xyz/nodes/git.jappie.dev/rad:z4HEZGDPknT12W4fuXc6wM3HtYTf2/commits/6f1e752ce67b4710685301a79ea8fcd67d3c67c4
[8] How to achieve seamless linear borderangle loop? - Hyprland Forum https://forum.hypr.land/t/how-to-achieve-seamless-linear-borderangle-loop/1046
[9] Hyprland Config - YouTube https://www.youtube.com/watch?v=cWXQ2x0p6hQ
[10] "Hyprland Configuration Guide" makalesinin özeti — YaÖzet - Yandex https://yandex.com.tr/yaozet/programming/hyprland-configuration-guide-id4-wdgpljg0

## Cursor Configuration

Hyprland supports two cursor systems: the newer **hyprcursor** format and the legacy **XCursor** format. Hyprcursor is the recommended native Wayland cursor system with advantages over XCursor, though not all applications support it yet.[1][2]

### Hyprcursor Configuration

Hyprcursor themes are placed in `~/.local/share/icons` or `~/.icons` (user-installed themes should not use system-wide `/usr/share/icons` due to permission issues).[2][1]

Set the hypercursor theme and size using environment variables in `hyprland.conf`:[1][2]
```
env = HYPRCURSOR_THEME,MyCursor
env = HYPRCURSOR_SIZE,24
```


Alternatively, use the `hyprctl setcursor` command to change cursors at runtime without restarting. Cursor sizes should follow power-of-two scaling (12, 24, 48, etc.) to avoid scaling artifacts.[3][1][2]

### Hypercursor Limitations

Although Qt, Chromium, Electron, and Hyprland ecosystem applications support server-side hypercursors, some applications like GTK do not and fall back to XCursor. This means different cursor systems may appear in different applications.[1][2]

### XCursor Fallback Configuration

For applications not supporting hypercursor, configure XCursor theme and size:[2][1]
```
env = XCURSOR_THEME,YourTheme
env = XCURSOR_SIZE,24
```


For GTK applications specifically, also run:[1][2]
```
gsettings set org.gnome.desktop.interface cursor-theme 'ThemeName'
gsettings set org.gnome.desktop.interface cursor-size 24
```


If `gsettings` schemas are unavailable (e.g., NixOS), use `dconf` instead:[1]
```
dconf write /org/gnome/desktop/interface/cursor-theme \"'ThemeName'\"
dconf write /org/gnome/desktop/interface/cursor-size 24
```


### Multi-Framework Configuration

For comprehensive cursor consistency across all application frameworks, configure all relevant config files:[4]

**~/.config/hyprland.conf:**
```
env = XCURSOR_THEME,ThemeName
env = XCURSOR_SIZE,24
env = HYPRCURSOR_THEME,ThemeName
env = HYPRCURSOR_SIZE,24
```


**~/.config/gtk-3.0/settings.ini and ~/.config/gtk-4.0/settings.ini:**
```
gtk-cursor-theme-name=ThemeName
gtk-cursor-theme-size=24
```


**~/.Xresources and ~/.Xdefaults:**
```
Xcursor.theme: ThemeName
Xcursor.size: 24
```


**Qt5/Qt6 Configuration:** Use `qt5ct` and `qt6ct` GUI tools or set `QT_QPA_PLATFORMTHEME=qt5ct` or `qt6ct` environment variables to configure cursor themes.[4]

**~/.config/xsettingsd/xsettingsd.conf:** Useful for non-GTK/XWayland applications:[4]
```
Gtk/CursorThemeName "ThemeName"
Gtk/CursorThemeSize 24
```


**~/.icons/default/index.theme:**
```
[Icon Theme]
Inherits=ThemeName
```


### HiDPI Scaling Considerations

On HiDPI displays with fractional scaling (e.g., 1.5x), account for the scale factor when setting XCursor size—multiply the desired size by the scale factor (e.g., 30 × 1.5 = 45 for xsettingsd). Hyprcursor handles scaling automatically, so hypercursor sizes should not be multiplied.[5][4]

### Flatpak Applications

For Flatpak applications, override filesystem access and place themes in both user and system directories:[2][1]
```
flatpak override --filesystem=~/.themes:ro --filesystem=~/.icons:ro --user
```


Copy cursor themes to both `~/.icons` and `/usr/share/icons` for Flatpak accessibility.[1]

### No Hypercursor Fallback

If no hypercursor themes are installed, Hyprland automatically falls back to XCursor and uses `XCURSOR_THEME` and `XCURSOR_SIZE` environment variables.[2][1]

Sources
[1] hyprcursor https://wiki.hypr.land/Hypr-Ecosystem/hyprcursor/
[2] Hyprcursor https://wiki.hypr.land/hyprland-wiki/pages/Hypr-Ecosystem/hyprcursor/
[3] How to change mouse cursor #624 https://github.com/HyDE-Project/HyDE/discussions/624
[4] Inconsistent cursor themes on GTK apps / Applications & ... https://bbs.archlinux.org/viewtopic.php?id=292763
[5] Cursor size with HiDPi · Issue #2448 · hyprwm/Hyprland https://github.com/hyprwm/Hyprland/issues/2448
[6] Cursor size smaller on desktop than everywhere else https://www.reddit.com/r/hyprland/comments/1dgmg4w/cursor_size_smaller_on_desktop_than_everywhere/
[7] Variables https://wiki.hyprland.org/0.46.0/Configuring/Variables/
[8] ArcoLinux : 3253 Hyprland - change the cursor size https://www.youtube.com/watch?v=tn0AH9_gjeE
[9] Cursor size in wayland/sway - Help https://discourse.nixos.org/t/cursor-size-in-wayland-sway/25112


# Window Management

## Dynamic Tiling Fundamentals

Dynamic tiling in Hyprland automatically arranges windows based on preset algorithms rather than requiring manual configuration. When new windows open or existing ones close, the compositor recalculates dimensions and repositions all affected windows to maintain full screen coverage.[1][2][3]

### Binary Space Partitioning (Dwindle)

Dwindle is the default layout implementing binary space partitioning (BSP), where every window belongs to a binary tree structure. Each node represents either a window or a container of two child nodes. New windows recursively subdivide the currently focused window's space, creating nested splits.[4][5]

**Dynamic Splitting:** Splits adjust based on the parent container's width-to-height ratio. If width exceeds height (landscape), new windows split side-by-side horizontally; if height exceeds width (portrait), they split vertically top-and-bottom. This ratio-based behavior means split orientation changes automatically when resizing containers, adapting to display geometry.[4]

**Permanent vs Dynamic Splits:** By default, splits recalculate dynamically as containers are resized or windows close. Enable `preserve_split` in the dwindle section to make splits permanent—once a side-by-side or top-bottom split exists, it remains that way regardless of subsequent resizing.[4]

### Controlling Split Direction

**force_split** controls where new windows appear relative to the focused window:[4]
- `0` (default) - Split direction follows mouse position: cursor on right/bottom creates right/bottom splits, cursor on left/top creates left/top splits[4]
- `1` - Always split left (horizontal) or top (vertical), new windows always appear on the left or above[4]
- `2` - Always split right or bottom, new windows always appear on the right or below[4]

**smart_split** provides precise directional control by dividing the focused window into four triangles. The cursor's triangle determines split direction—cursor in top-left triangle creates top/left split, top-right creates top/right split, etc.. Smart_split automatically enables `preserve_split`.[4]

**preselect** provides one-time direction overrides using the `layoutmsg preselect l/r/u/d` dispatcher, affecting only the next window opened. Enabling `permanent_direction_override` makes preselect persist until explicitly changed.[4]

### Window Grouping

Windows can form **groups** (similar to i3wm's tabbed containers) that occupy a single tile but cycle through members. Create groups with `togglegroup` dispatcher, cycle through members with `changegroupactive f/b` (forward/backward).[5][4]

When creating a group, the focused window and all its recursive children form the group; the group's border colors are configurable with `col.group_border` (inactive) and `col.group_border_active` (active). Closing windows within groups is allowed; if a closure causes the original parent to be removed, the group breaks back into dwindle form.[5][4]

### Pseudotiling

Enable `pseudotile = true` in the dwindle section to activate pseudotiling, where tiled windows retain their floating size but participate in tiling layout. A 500x300px window remains that size while fitting into the tiling tree rather than expanding to fill its tile. This combines tiling organization with floating window dimensions.[4]

### Advanced Dwindle Options

**smart_resizing** (default true) determines resize direction based on mouse position—cursor nearest to which corner controls resize direction. When false, resize direction is based on tiling position within the split.[4]

**split_width_multiplier** scales automatic splits for wide monitors where window width exceeds height even after multiple splits, allowing finer-grained split ratios (default 1.0).[4]

**use_active_for_splits** determines whether splits use the active window or mouse position (default true, uses active window).[4]

**default_split_ratio** sets the initial split ratio: 1.0 = 50/50 split, values 0.1-1.9 allow unequal splits.[4]

**split_bias** determines which window receives the split ratio when opening new windows: 0 = directional window (top/left), 1 = current focused window.[4]

**single_window_aspect_ratio** adds padding around solitary windows to maintain specified aspect ratios (e.g., `4 3` for 4:3 on 16:9 display). **single_window_aspect_ratio_tolerance** prevents padding if it's smaller than the specified tolerance fraction (default 0.1).[4]

### Layout Message Dispatchers

**togglesplit** swaps split orientation (horizontal ↔ vertical) when `preserve_split` is enabled, only functioning on the active window.[4]

**swapsplit** exchanges the two halves of the current window's split.[4]

**movetoroot** relocates the active window to the workspace tree root, maximizing it within its current subtree by default; adding `unstable` swaps it with the other subtree instead.[4]

Sources
[1] Hyprland – An independent, dynamic tiling Wayland ... https://news.ycombinator.com/item?id=44854508
[2] I switched to Hyprland https://uncomfyhalomacro.pl/blog/9/
[3] Hyprland https://wiki.archcraft.io/docs/wayland-compositors/hyprland/
[4] Dwindle Layout https://wiki.hypr.land/Configuring/Dwindle-Layout/
[5] Dwindle Layout · hyprwm/Hyprland Wiki https://github.com/hyprwm/Hyprland/wiki/Dwindle-Layout/1f579b1a40c45d1b4d46542f93329cc58d857d4c
[6] Changing layout dynamically with a keybind? Pseudo tiling ... https://www.reddit.com/r/hyprland/comments/1ggy9kf/changing_layout_dynamically_with_a_keybind_pseudo/
[7] Window Rules https://wiki.hyprland.org/0.45.0/Configuring/Window-Rules/
[8] Master Layout https://wiki.hyprland.org/0.46.0/Configuring/Master-Layout/
[9] Reviewing & Customizing Hyprland Window Manager Live! https://www.youtube.com/watch?v=S_zT92xS3jY
[10] spikespaz-contrib/hyprland https://github.com/spikespaz/hyprland

## Dwindle Layout

### Overview

The dwindle layout in Hyprland is a dynamic, tiling window arrangement that recursively splits the screen into smaller sections as new windows are opened, following a binary tree model. It is designed to optimize screen space and maintain an organized, efficient environment, making it popular among tiling window manager users and especially those familiar with layouts like i3 or Sway but seeking Hyprland’s enhanced features.

### How Dwindle Layout Works

- **Binary Tree Splitting:** Each new window splits the current “active” window area either vertically or horizontally, alternating directions for each subsequent split.
- **Responsive Resizing:** Resizing one window can propagate size changes to others, similar to a tree of splits, maintaining balance and screen efficiency.
- **Floating and Tiling:** Windows can be set to float or tile dynamically; the dwindle layout only manages tiled windows.
- **Customizable Behavior:** Splitting style (vertical/horizontal), gap size, margins, and specific rules for applications can be configured to suit workflow needs.

### Configuration Example

Typical configuration options for the dwindle layout in Hyprland are set in the `~/.config/hypr/hyprland.conf` file:

```ini
# Activate dwindle by default
general {
    layout = dwindle
}

# Dwindle-specific configurations
dwindle {
    pseudotile = true           # Allows floating windows to tile if possible
    preserve_split = true       # Preserves splits after closing a window
    force_split = 0             # 0: alternate, 1: vertical, 2: horizontal
    use_active_split = true     # Split based on currently active container
    smart_resizing = true       # Intelligent resizing for complex trees
}
```
- `pseudotile = true`: Allows windows that do not fully support tiling to still fit within the dwindle layout.
- `preserve_split = true`: Prevents the tree from recombining split areas when a window closes, keeping layout structure predictable.
- `force_split`: Controls split direction (0 for alternating, 1 for vertical only, 2 for horizontal only).
- `smart_resizing`: Enhanced resizing behavior for more complex arrangements.

### Key Features and Benefits

- **Space Efficiency:** Maximizes usable screen area by eliminating gaps and overlaps between windows.
- **Structured Organization:** Maintains a logical grouping, making multitasking easier and more visually intuitive.
- **Dynamic:** Adapts as windows are added or removed; supports cycling to other layouts or floating as needed.
- **Powerful Customization:** Granular control over window behavior, layout rules, and aesthetics through Hyprland’s config file.

### Example: Workflow

**Example:**  
If you open three terminal windows in dwindle layout, the screen will be split first vertically, then the next window will split one of those areas horizontally, resulting in a balanced stacked arrangement. Additional windows continue to split the available space recursively, in either direction, creating a visually distinct and optimally spaced environment.

### Output

- Activate the layout:  
  `hyprctl dispatch layoutmsg dwindle`  
- Open new windows to see them tile in the recursive dwindle pattern.

**Key Points**  
- Binary tree split tiling
- Efficient space usage  
- Highly customizable
- Configuration via `hyprland.conf`

Sources


## Master Layout

The master layout designates one or more windows as "master" occupying a fixed area (left side by default) while remaining windows tile in the slave area. This layout suits workflows prioritizing one primary application (editor, browser) with secondary tools arranged nearby.[1]

### Master Area Configuration

**mfact** sets the master area size as a percentage of screen space, defaulting to 0.55 (55% master, 45% slave). Values range from 0.0 to 1.0; setting `mfact = 0.70` allocates 70% to master and 30% to slave.[1]

**allow_small_split** enables horizontally splitting the master area to accommodate multiple master windows when true (default false). With this disabled, adding additional masters still works but they stack vertically.[1]

**orientation** determines master area placement: `left` (default, master left/slaves right), `right`, `top`, `bottom`, or `center`. Center orientation alternates slave windows left and right around the centered master, creating a symmetric layout.[1]

### Window Hierarchy

**new_status** determines where new windows appear: `slave` (default, added to slave stack), `master` (becomes new master), or `inherit` (inherits focused window's status).[1]

**new_on_top** places newly opened windows at the top of the slave stack when true, or at the bottom when false (default false).[1]

**new_on_active** controls placement relative to focused windows: `before` (above focused), `after` (below focused), or `none` (use new_on_top).[1]

### Advanced Options

**smart_resizing** determines resize direction based on mouse position when true (default true), using tiling position when false.[1]

**drop_at_cursor** places drag-dropped windows at cursor position when true; when false, drops follow new_on_top stacking rules (default true).[1]

**always_keep_position** maintains master window position even with zero slave windows when true (default false).[1]

**special_scale_factor** scales special workspace windows between 0.0 and 1.0 (default 1.0).[1]

**inherit_fullscreen** propagates fullscreen status when cycling or swapping windows (e.g., monocle-style fullscreen persistence) when true (default true).[1]

**center_master_fallback** defines fallback orientation when center master has fewer slaves than `slave_count_for_center_master`: `left`, `right`, `top`, or `bottom` (default left).[1]

**slave_count_for_center_master** specifies minimum slave windows before centering master (default 2); setting to 0 always centers.[1]

### Layout Message Dispatchers

**swapwithmaster** exchanges focused window with master; if already master, swaps with first slave. Optional params: `master` (focus new master), `child` (focus new child), `auto` (preserve focus), or add `ignoremaster` to skip if master already focused.[1]

**focusmaster** focuses the master window with params `master` (stay on master), `auto` (default; focus first slave if already on master), or `previous` (remember previous window).[1]

**cyclenext/cycleprev** moves focus through windows; optional `loop` (default, wrap around) or `noloop` (stop at edges).[1]

**swapnext/swapprev** exchange focused window with next/previous; optional `loop` (default) or `noloop`.[1]

**addmaster/removemaster** adds or removes windows from the master area.[1]

**orientationleft/right/top/bottom/center** sets workspace master area orientation. **orientationnext/prev** cycles through orientations clockwise or counter-clockwise. **orientationcycle** cycles through specific orientations: `layoutmsg, orientationcycle left top right`.[1]

**mfact** adjusts master area size: relative delta (e.g., `-0.05` or `+0.05`) or `exact` with precise value (e.g., `mfact exact 0.65`).[1]

**rollnext/rollprev** rotates the next/previous window to master position while keeping focus on master.[1]

### Workspace-Specific Configuration

Apply master layout settings per-workspace using workspace rules:[1]

```
workspace = 1, layoutopt:orientation:left
workspace = 2, layoutopt:orientation:top
workspace = 3, layoutopt:orientation:center
```


### Example Master Configuration

```
master {
  mfact = 0.55
  allow_small_split = false
  new_status = slave
  new_on_top = false
  new_on_active = none
  orientation = left
  smart_resizing = true
  drop_at_cursor = true
  always_keep_position = false
  inherit_fullscreen = true
  center_master_fallback = left
  slave_count_for_center_master = 2
}
```

Sources
[1] Master Layout https://wiki.hypr.land/Configuring/Master-Layout/

## Window Rules 

### Syntax and Matching

The `windowrulev2` system provides **conditional configuration** applying specific settings to windows matching defined criteria. Rules use regex pattern matching against window properties, evaluated in order from top to bottom. Hyprland v0.46.0 onwards requires full regex matches—partial matches need explicit wildcard patterns like `.*pattern.*`.[1]

The syntax is `windowrulev2 = RULE, CONDITION [, CONDITION ...]`. Multiple conditions combine with commas, all requiring matches for the rule to apply.[1]

### Matching Criteria

**class:[RegEx]** matches window class (case-sensitive), obtained from application metadata[1]. Example: `class:firefox` or `class:(firefox|chromium)`[1].

**initialClass:[RegEx]** matches class at window creation, useful for applications that change their class dynamically.[1]

**title:[RegEx]** matches window title strings. Example: `title:.*Mozilla Firefox.*`.[1]

**initialTitle:[RegEx]** matches title at window creation.[1]

**xwayland** matches only XWayland windows (0 or 1).[1]

**floating:[0/1]** matches window floating state: 0 = tiled, 1 = floating.[1]

**focus:[0/1]** matches currently focused window: 0 = unfocused, 1 = focused.[1]

**workspace:[w]** matches specific workspace by ID or name; `workspace:[^special]` uses regex to exclude special workspaces. **workspacetext:[RegEx]** matches workspace name text.[1]

**fullscreen** matches fullscreen state (can be 0, 1, or 2 for fullscreen modes).[1]

**fullscreenmode** matches fullscreen mode specifically.[1]

**pinned** matches pinned windows.[1]

**modal** matches modal dialogs.[1]

**nofocus** ignores certain application windows when focusing.[1]

**type:[type]** matches window type: `normal`, `dialog`, `splash`, `notification`, `toolbar`.[1]

### Applied Rules

**float** makes matching windows floating. **tile** forces tiling (overrides float). **fullscreen** maximizes windows within their workspace. **fakefullscreen** simulates fullscreen without changing actual state.[1]

**pin** pins windows to all workspaces. **unpin** removes pin status.[1]

**nomaxsize** removes window size restrictions, allowing oversizing beyond screen boundaries. **maxsize W H** restricts window maximum size to W×H pixels. **minsize W H** enforces minimum window size.[1]

**size W H** sets exact window dimensions; useful for screenshots or specific workflows. **move X Y** positions floating windows at absolute screen coordinates; relative coordinates use `+X` or `-X`.[1]

**rounding [0/1]** disables window rounding when 0. **noblur** disables background blur for the window. **noshadow** removes window shadow.[1]

**noborder** removes window borders. **nodefaultsize** prevents automatic sizing from `initialSize` rules.[1]

**animation [NAME] [ONOFF] [SPEED] [CURVE] [STYLE]** applies custom animations; see animation syntax documentation. **noanim** disables animations.[1]

**opaque** makes transparent windows opaque. **forceinput** allows input to pass through certain visual areas (debugging tool).[1]

**center** centers floating windows on screen. **xray [0/1]** applies blur xray effect (see decoration blur settings).[1]

**dimaround** dims background using `dim_around` opacity. **dimmer [OPACITY]** dims window to specified opacity while leaving others normal.[1]

**focusonactivate** focuses window when activated by another client. **keepaspectratio** maintains window aspect ratio during resizing.[1]

**nearestneighbor** disables interpolation during window scaling (for pixel-perfect games).[1]

**group [SET]** assigns window to group when opening; use `SET` keywords like `new` (create new group), `current` (join active group), or group name.[1]

**stayfocused** keeps window focused despite focus-stealing attempts. **nofullscreenrequest** ignores fullscreen requests. **noinitialcursor** ignores cursor hint at window creation.[1]

**immediate** prevents window from requesting immediate focus after opening. **idleinhibit [RULE]** prevents idle state; options: `none`, `always`, `focus` (only when focused).[1]

**workspace [w/name]** moves window to specific workspace: `workspace 2`, `workspace name:myworkspace`, `workspace 1 silent` (silent prevents switching to workspace).[1]

**suppressevent [FLAGS]** suppresses certain events; flags: `maximize`, `activate`.[1]

**initialSize [WIDTH] [HEIGHT]** sets initial window size (Xwayland only). **initialPosition [X] [Y]** sets initial position.[1]

**opaque** forces complete opacity (ignores alpha). **isrendering** marks window as rendering constantly (disables idle detection).[1]

### Special Workspace Rules

**move [x, y]** moves windows within special workspaces. **special:name [w]** creates/targets named special workspaces. Special workspaces are hidden by default, accessed with `togglespecialworkspace`.[1]

### Example Window Rules

```
windowrulev2 = float, class:pavucontrol
windowrulev2 = float, class:nm-connection-editor
windowrulev2 = float, title:^(Open|Save) File

windowrulev2 = fullscreen, class:mpv
windowrulev2 = fullscreen, title:.*YouTube.*

windowrulev2 = move 100 100, class:alacritty
windowrulev2 = size 800 600, class:Thunar

windowrulev2 = workspace 2, class:firefox
windowrulev2 = workspace name:code, class:(code|codium)

windowrulev2 = tile, class:VLC
windowrulev2 = nofullscreenrequest, class:mpv

windowrulev2 = noinitialcursor, class:firefox
windowrulev2 = idleinhibit focus, class:mpv
```

Sources
[1] Window Rules https://wiki.hypr.land/Configuring/Window-Rules/

## Workspace Management

Workspaces are virtual desktops organizing windows into logical groups independent of physical monitors. Each workspace maintains its own window arrangement, tiling layout, and focus state.[1][2]

### Workspace Creation and Navigation

Hyprland uses dynamic workspaces by default—workspaces are created automatically when first accessed. Empty workspaces disappear automatically when abandoned, maintaining a clean workspace list. Make workspaces persistent using `workspace = ID, persistent:true` in the configuration to prevent automatic cleanup.[2][1]

Access workspaces through numbered IDs (1-10) or custom names using `workspace = name:NAME`. Switch workspaces using dispatchers like `workspace 1`, `workspace name:myspace`, or cycle with `workspace +1/-1`.[1][2]

### Monitor-Workspace Binding

By default, workspaces are global—switching workspaces affects all monitors. Bind workspaces to specific monitors so switching only affects the active monitor:[1]

```
workspace = 1, monitor:DP-1
workspace = 2, monitor:DP-1
workspace = 3, monitor:DP-2
```


This configuration confines workspaces 1-2 to monitor DP-1 and workspace 3 to DP-2. When no binding exists, workspaces appear on the currently active monitor.[1]

### Named Workspaces

Create workspaces with descriptive names instead of numbers:[1]

```
workspace = name:code, monitor:DP-1
workspace = name:browser, monitor:DP-1
workspace = name:media, monitor:DP-2
```


Switch to named workspaces with `workspace name:code`. Mix numbered and named workspaces in the same session.[1]

### Layout Configuration Per-Workspace

Set default layout per-workspace using `layoutopt` rules:[2][1]

```
workspace = 1, layoutopt:dwindle:pseudotile:true
workspace = 2, layoutopt:master:orientation:top
```


This applies dwindle layout with pseudotiling on workspace 1 and master layout with top orientation on workspace 2.[1]

### Special Workspaces

Special workspaces are hidden overlay spaces accessed via `togglespecialworkspace` dispatcher, useful for scratchpad-like workflows. Move windows to special workspaces using `movetoworkspace special` or `movetoworkspace special:name`.[1]

Create named special workspaces:
```
bind = SUPER, S, togglespecialworkspace, magic
```


This creates and toggles a special workspace named "magic".[1]

### Workspace Rules

Apply window rules based on workspace:[3]

```
windowrulev2 = float, workspace:special
windowrulev2 = tile, workspace:1
windowrulev2 = float, workspace:name:floating
```


These rules float all windows in special workspaces, tile workspace 1, and float workspace "floating".[3]

### Gap Configuration Per-Workspace

Control workspace-specific gaps using `addreserved` monitor rules:[4]

```
monitor = DP-1, 1920x1080, 0x0, 1, addreserved, 50, 0, 0, 0
```


This adds 50 pixels top margin on DP-1 for panels or status bars.[4]

### Workspace Swallowing

Configure workspace behavior when windows change states using `nofocus`, `workspace`, and related window rules. When a window opens and swallows its parent, move it explicitly with `workspace rules`.[3]

### Dispatcher Commands

**workspace [ID/name]** switches to workspace by ID or name. **workspace [+/-]N** cycles forward/backward N workspaces. **movetoworkspace [ID/name]** moves focused window to workspace. **movetoworkspacesilent** moves without switching to the destination workspace.[1]

**renameworkspace [ID/name] [NEWNAME]** renames workspace at runtime. **focusworkspaceoncurrentmonitor [ID/name]** switches to workspace only on active monitor (respects monitor bindings).[1]

**movecurrentworkspacetomonitor [direction]** relocates active workspace to adjacent monitor specified by direction (l/r/u/d). **swapactiveworkspaces [MONITOR1] [MONITOR2]** exchanges workspaces between monitors.[1]

### Example Workspace Configuration

```
workspace = 1, monitor:DP-1, layoutopt:dwindle:pseudotile:false
workspace = 2, monitor:DP-1, layoutopt:master:orientation:left
workspace = 3, monitor:DP-2, layoutopt:dwindle:pseudotile:true

workspace = name:mail, monitor:DP-1, persistent:true
workspace = name:media, monitor:DP-2, persistent:true

workspace = special:scratchpad, on-created-empty:foot

bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER+SHIFT, 1, movetoworkspace, 1
bind = SUPER+SHIFT, 2, movetoworkspace, 2
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Hyprland workspace configuration - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=298652
[3] Window Rules https://wiki.hypr.land/Configuring/Window-Rules/
[4] Monitors https://wiki.hypr.land/Configuring/Monitors/

## Tabbed and Grouped Windows

Tabbed and grouped windows organize multiple windows into single tiles, cycling through them without occupying additional space. Groups create container-like structures where windows share one tile while remaining independently manageable.[1]

### Creating Groups

Use the `togglegroup` dispatcher to create or join groups. The focused window and all its recursive children form a new group on first activation. Pressing `togglegroup` again while in a group removes the focused window from the group.[1]

```
bind = SUPER, G, togglegroup
```


### Cycling Through Group Members

Navigate between grouped windows using `changegroupactive` dispatcher with `f` (forward) or `b` (backward) direction:[1]

```
bind = SUPER, Tab, changegroupactive, f
bind = SUPER+SHIFT, Tab, changegroupactive, b
```


Pressing these keybinds cycles focus through group members while maintaining the group's tile position.[1]

### Group Styling

Group border colors match individual window borders initially but can be customized via `col.group_border` (unfocused) and `col.group_border_active` (focused) in the `general` section:[1]

```
general {
  col.group_border = 0xff89b482
  col.group_border_active = 0xffa6e3a1
}
```


### Group Behavior with Window Operations

When creating a group, Hyprland organizes the focused window's subtree—the focused window and all its children become the group. Closing windows within groups is permitted; if a closure removes the original parent, the group breaks back into dwindle form and expands the remaining children.[1]

Groups respect dwindle tiling rules—if you remove a group's parent through closure, child windows resume independent tiles. Moving windows in/out of groups uses standard focus and movement dispatchers.[1]

### Window Rule Integration

Apply window rules to group-specific behavior:[2]

```
windowrulev2 = group new, class:alacritty
```


This automatically places new alacritty windows in a fresh group.[2]

### Group Limitations

Groups do not support nesting—a group cannot contain another group. Attempting to create a group containing windows already in a group will fail. Groups are workspace-specific; switching workspaces breaks group organization temporarily until returning to the original workspace.[1]

### Alternative: Tabbed Mode (Plugin)

Third-party plugins like `hy3` provide tabbed window management with visual tabs, offering an alternative to group cycling. While not built-in, hy3 provides traditional tab bar interfaces similar to i3-gaps with plugins.[1]

### Pseudo-Tabbed Workflow

Create a pseudo-tabbed effect by grouping related windows and using workspace isolation. Dedicate workspaces to application families (e.g., workspace "browsers" groups Firefox and Chrome, workspace "terminals" groups shell windows), then use `workspace` dispatchers to switch between entire groups.[3][1]

```
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, name:browsers
bind = SUPER, 3, workspace, name:terminals

windowrulev2 = workspace name:browsers, class:(firefox|chromium)
windowrulev2 = workspace name:terminals, class:(alacritty|kitty)
```


This configuration automatically routes applications to designated workspaces, effectively creating workspace-level tabbing.[3]

### Group Dispatcher Summary

**togglegroup** creates a new group with the focused window and its children, or removes focused window from existing group.[1]

**changegroupactive [f/b]** cycles focus through group members forward or backward.[1]

**movewindowtogroupid [GROUP_ID]** moves focused window to a specific group (requires group ID from debugging).[1]

Sources
[1] Dwindle Layout https://wiki.hypr.land/Configuring/Dwindle-Layout/
[2] Window Rules https://wiki.hypr.land/Configuring/Window-Rules/
[3] Hyprland workspace configuration - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=298652

# Keybindings and Control

## Keyboard Bindings

### Keybinding Syntax

Keybindings are defined in `hyprland.conf` (commonly split into a separate `keybindings.conf` file) using the format:
```
bind = MODS, KEY, dispatcher, params
```
Modifers include `SUPER` (Windows/Command key), `SHIFT`, `CTRL`, `ALT`, and combinations thereof (e.g., `SUPERSHIFT`, `SUPERALT`). The key can be any valid key name, mouse button (e.g., `mouse:272` for left mouse), or event such as `mouse_up`. Dispatcher chooses the action, with optional parameters.[1][6][7][8]

### Examples of Basic Bindings

- Launch terminal: `bind = SUPER, RETURN, exec, kitty`
- Close window: `bind = SUPER, Q, killactive`
- Toggle floating mode: `bind = SUPER, SPACE, togglefloating`
- Focus next window: `bind = SUPER, Tab, cyclenext`
- Move window to workspace 2: `bind = SUPER+SHIFT, 2, movetoworkspace, 2`
- Switch to workspace 2: `bind = SUPER, 2, workspace, 2`
- Launch file manager: `bind = SUPER, E, exec, thunar`
- Toggle fullscreen: `bind = SUPER, F, fullscreen`

### Advanced Modifiers and Formats

- Mouse buttons: `bind = SUPER, mouse:272, exec, appname`
- Mouse wheel: `bind = SUPER, mouse_down, workspace, e-1` (with configurable scroll delay)
- Lock events: `bindl = , switch:[switch name], exec, swaylock`
- Only modifiers: `bindr = SUPERALT, Alt_L, exec, amongus`
- Multiple actions for one key: Assign multiple binds for a single key combination; actions execute top to bottom.[6][1]

### Keybinding Flags

- `l` (locked): Dispatcher only runs when Hyprland is locked.[6]
- `r` (release): Runs on key release rather than press.

### Global Keybinds

Global keybinds pass shortcuts or mouse events directly to applications (OBS, Discord, Firefox) using `pass` or `sendshortcut`. Example:[1][6]
```
bind = SUPER, F10, pass, class:^(com\\.obsproject\\.Studio)$
```
For push-to-talk: 
```
bind=, mouse:276, pass, class:^(TeamSpeak 3)$
```
For custom shortcuts:
```
bind = SUPER, F10, sendshortcut, SUPER, F4, class:^(com\\.obsproject\\.Studio)$
```

### DBus/XDG Desktop Portal Shortcuts

Some apps register shortcuts in the GlobalShortcuts portal. List them with `hyprctl globalshortcuts`, and bind using the `global` dispatcher:
```
bind = SUPERSHIFT, A, global, coolApp:myToggle
```
Works only with XDG Desktop Portal.[1][6]

### Default and Customization

Default Hyprland keybinds include launching the terminal, toggling floating windows, moving focus, launching the app launcher (rofi/wofi), closing windows, workspace switching, toggling groups, and toggling fullscreen.[4][7]

Mod key is typically set to SUPER, but can be changed in the config. Keybinds for workspace assignment, application launch, layout cycling, and advanced behaviors are highly customizable and can be split into modular configuration files as needed.[5][7][8]

### Keybinds Section Example

```
# Terminal
bind = SUPER, RETURN, exec, kitty

# Window control
bind = SUPER, Q, killactive
bind = SUPER, SPACE, togglefloating
bind = SUPER, F, fullscreen

# Workspace
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER+SHIFT, 2, movetoworkspace, 2

# App Launcher
bind = SUPER, D, exec, rofi -show drun

# Grouping
bind = SUPER, G, togglegroup
bind = SUPER, Tab, changegroupactive, f

# Multimedia
bind = SUPER, P, exec, playerctl play-pause

# Monitor and system
bind = SUPER, L, exec, swaylock

# Global shortcut
bind = SUPER, F10, pass, class:^(com\\.obsproject\\.Studio)$
```

Sources
[1] Binds https://wiki.hypr.land/Configuring/Binds/
[2] Keybind List : r/hyprland https://www.reddit.com/r/hyprland/comments/1d0hkyq/keybind_list/
[3] A Noobs Guide to Hyprland | EP:4 - Configuring Keybinds https://www.youtube.com/watch?v=j6Kmru4ldh4
[4] Hyprland Cheatsheet https://wiki.garudalinux.org/en/hyprland-cheatsheet
[5] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[6] Binds | Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Configuring/Binds/
[7] Keybinds · JaKooLit/Hyprland-Dots Wiki https://github.com/JaKooLit/Hyprland-Dots/wiki/Keybinds
[8] Hyprland https://wiki.cachyos.org/configuration/desktop_environments/hyprland/
[9] Configuring Hyprland https://wiki.hyprland.org/0.41.2/Configuring/Configuring-Hyprland/

## Mouse Bindings

### Mouse Button Syntax

Mouse bindings follow the same format as keyboard bindings but use mouse button identifiers instead of key names. The syntax is:[1][2]
```
bind = MODS, mouse:BUTTONCODE, dispatcher, params
```

Common mouse button codes:[2][1]
- `mouse:272` - Left mouse button
- `mouse:273` - Right mouse button
- `mouse:274` - Middle mouse button
- `mouse:275` - Side button (back)
- `mouse:276` - Side button (forward)

### Mouse Movement and Scrolling

**Mouse wheel scrolling** uses `mouse_up` and `mouse_down` instead of button codes, with configurable scroll sensitivity:[1][2]
```
bind = SUPER, mouse_down, workspace, e-1
bind = SUPER, mouse_up, workspace, e+1
```

These keybinds cycle workspaces on scroll; `e-1` goes to previous workspace, `e+1` goes to next. **Scroll delay** controls repeat speed between scroll events using `scroll_event_delay` in the `input` section (default 300ms).[2][1]

**Mouse move events** capture cursor movement for custom workflows:
```
bind = SUPER, mouse_move, exec, notify-send "Mouse moved"
```
Though rarely used, this enables mouse tracking for specialized applications.[1]

### Common Mouse Binding Examples

**Window operations:**
```
bind = SUPER, mouse:272, movewindow
bind = SUPER, mouse:273, resizewindow
bind = mouse:274, cyclenext
```

The first focuses and drags windows, the second resizes, the third cycles through windows on middle-click.[2][1]

**Workspace switching:**
```
bind = SUPER, mouse_down, workspace, e-1
bind = SUPER, mouse_up, workspace, e+1
```

These provide quick workspace navigation without keyboard input.[1][2]

**Application launching:**
```
bind = SUPER, mouse:276, exec, rofi -show drun
bind = , mouse:275, exec, pavucontrol
```

The first launches the app menu on forward button with Super held, the second opens audio control on back button alone.[1]

**Window state toggling:**
```
bind = SUPER+SHIFT, mouse:272, togglefloating
bind = SUPER+SHIFT, mouse:273, fullscreen
```

These toggle floating mode and fullscreen on modifier+click combinations.[2][1]

### Mouse Modifiers

Mouse bindings support all keyboard modifiers: `SUPER`, `SHIFT`, `CTRL`, `ALT`, and combinations like `SUPERSHIFT` or `CTRLALT`. Modifiers work identically to keyboard bindings—the mouse action triggers only when the specified modifier keys are held.[2][1]

### Global Mouse Shortcuts

Use `pass` or `sendshortcut` with mouse buttons for application-specific shortcuts:
```
bind = SUPER, mouse:272, pass, class:^(com\\.obsproject\\.Studio)$
bind = SUPER, mouse:273, sendshortcut, SUPER, F4, class:^(OBS)$
```

The first passes mouse clicks directly to OBS without Hyprland interception, the second sends a keyboard shortcut to OBS on right-click.[1][2]

### Advanced Mouse Binding Patterns

**Context-based actions** use multiple bindings for the same button with different modifiers:
```
bind = , mouse:272, cyclenext
bind = SUPER, mouse:272, movewindow
bind = SUPER+SHIFT, mouse:272, resizewindow
bind = ALT, mouse:272, exec, rofi -show window
```

Bare mouse:272 cycles windows, Super+click moves, Super+Shift+click resizes, Alt+click opens window switcher.[2][1]

**Mouse button chording** (sequential presses) is not directly supported in Hyprland; use single-button or modifier combinations for reliable binding.[1]

**Scroll momentum** applies acceleration to wheel scrolling, making rapid scrolls trigger multiple events faster than individual spins—control with scroll_event_delay in the input section.[1]

### Mouse Binding Flags

Mouse bindings support the same flags as keyboard bindings:[1]
- `l` (locked) - Only triggers when Hyprland is locked
- `r` (release) - Triggers on button release instead of press
- `e` - Exact match (rarely used with mouse)

Example locked binding:
```
bindl = , mouse:272, exec, swaylock
```

### Example Comprehensive Mouse Configuration

```
# Window management
bind = SUPER, mouse:272, movewindow
bind = SUPER+SHIFT, mouse:272, resizewindow
bind = SUPER, mouse:273, cyclenext
bind = , mouse:274, cyclenext

# Workspace navigation
bind = SUPER, mouse_down, workspace, e-1
bind = SUPER, mouse_up, workspace, e+1

# Window state
bind = SUPER+SHIFT, mouse:275, togglefloating
bind = SUPER+SHIFT, mouse:276, fullscreen

# Application shortcuts
bind = ALT, mouse:272, exec, rofi -show drun
bind = SUPER, mouse:274, exec, pavucontrol

# Global shortcuts for OBS
bind = SUPER, mouse:276, pass, class:^(com\\.obsproject\\.Studio)$
```

Sources
[1] Binds https://wiki.hypr.land/Configuring/Binds/
[2] Binds | Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Configuring/Binds/
[3] Keybinds · JaKooLit/Hyprland-Dots Wiki https://github.com/JaKooLit/Hyprland-Dots/wiki/Keybinds

## Gestures & Touchpad

### Touchpad Gestures Configuration

Hyprland supports gesture-based input through the `gestures` section, enabling multi-finger swipes and taps for navigation and window control. Gestures work on touchpads and touchscreens, providing alternative input methods to keyboard and mouse.[1]

### Swipe Gestures

**Workspace swiping** cycles between workspaces using horizontal swipes. Configure with:[1]
```
gestures {
  workspace_swipe = true
  workspace_swipe_fingers = 3
  workspace_swipe_distance = 300
  workspace_swipe_invert = false
  workspace_swipe_min_speed_to_force = 30
  workspace_swipe_cancel_ratio = 0.5
}
```


**workspace_swipe** enables/disables the feature (default false). **workspace_swipe_fingers** sets the required number of fingers (typically 3 or 4, default 3). **workspace_swipe_distance** is the minimum swipe distance in pixels before triggering workspace change (default 300). **workspace_swipe_invert** reverses swipe direction when true (default false).[1]

**workspace_swipe_min_speed_to_force** sets minimum swipe speed (pixels/ms) to bypass the cancel ratio check, forcing workspace switch even if incomplete (default 30). **workspace_swipe_cancel_ratio** determines the swipe completion threshold—swipes below this ratio (0.0-1.0) cancel and return to original workspace (default 0.5 = 50%).[1]

**workspace_swipe_create_new** creates new workspaces when swiping beyond the final workspace instead of wrapping around (default true).[1]

### Tap Gestures

Touchpad tap-to-click converts finger taps into button clicks:[1]
```
input {
  touchpad {
    tap-to-click = true
    tap_button_map = lrm
    clickfinger_behavior = true
    drag-lock = false
  }
}
```


**tap-to-click** enables tapping as left-click (default true). **tap_button_map** maps multi-finger taps: `lrm` = left/right/middle, `lmr` = left/middle/right (default lrm). **clickfinger_behavior** maps multi-finger physical clicks instead of taps (default false).[1]

### Drag and Drag-Lock

**tap-and-drag** enables dragging by tapping and holding without re-tapping (default true). **drag-lock** prevents dropping items on finger lift: 0 (disabled), 1 (timeout-based), 2 (sticky mode) (default 0).[1]

**drag_3fg** enables three-finger drag for special operations: 0 (disabled), 1 (three fingers), 2 (four fingers) (default 0). This allows alternative drag triggering without tap-and-drag.[1]

### Multi-Finger Scroll

**natural_scroll** inverts scroll direction for touchpads (default false). **scroll_factor** multiplies scroll speed (default 1.0). **middle_button_emulation** interprets simultaneous left+right click as middle-click (default false).[1]

### Edge Scrolling

**scroll_method** determines scrolling interpretation:[1]
- `2fg` - Two-finger scrolling (default for modern touchpads)
- `edge` - Edge scrolling (legacy touchpads)
- `on_button_down` - Button-initiated scrolling
- `no_scroll` - Scrolling disabled

[1]

### Touchscreen-Specific Configuration

The `input:touchdevice` subcategory configures touchscreen input separately from touchpads:[1]
```
input:touchdevice {
  output = DP-1
  transform = -1
  enabled = true
}
```


**output** binds touch input to a specific monitor (default auto-detection). **transform** rotates touch input like monitor rotation, with -1 meaning use monitor's rotation value (default -1). **enabled** toggles touchscreen input (default true).[1]

### Gesture Dispatcher Integration

While Hyprland doesn't provide explicit gesture dispatchers, gestures trigger standard dispatchers through touchpad events. Combine gesture configuration with keyboard bindings for comprehensive gesture support. For example, `workspace_swipe = true` directly triggers `workspace` dispatchers based on swipe direction.[1]

### Advanced Gesture Workflows

**Pinch-to-zoom** simulation combines `scroll_factor` with gesture detection—pinch gestures are interpreted as scroll events on modern touchpads, allowing zoom functionality in compatible applications.[1]

**Window resize on touchscreen** maps touch drag to window resize using `movewindow` or `resizewindow` dispatchers triggered by pointer events.[1]

### Example Comprehensive Touchpad Configuration

```
gestures {
  workspace_swipe = true
  workspace_swipe_fingers = 3
  workspace_swipe_distance = 300
  workspace_swipe_invert = false
  workspace_swipe_min_speed_to_force = 30
  workspace_swipe_cancel_ratio = 0.5
  workspace_swipe_create_new = true
}

input:touchpad {
  disable_while_typing = true
  natural_scroll = false
  tap-to-click = true
  tap_button_map = lrm
  clickfinger_behavior = false
  middle_button_emulation = false
  drag_lock = 0
  tap-and-drag = true
  drag_3fg = 0
  scroll_factor = 1.0
  scroll_method = 2fg
}

input:touchdevice {
  output = DP-1
  transform = -1
  enabled = true
}
```

Sources
[1] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Media Keys

### Media Key Codes

Media keys are special function keys for volume, brightness, media playback, and system controls. Hyprland recognizes these keys through XF86 keycodes, allowing direct binding without additional configuration.[1][2]

Common media key codes:[2][1]
- `XF86AudioRaiseVolume` - Volume up
- `XF86AudioLowerVolume` - Volume down
- `XF86AudioMute` - Mute/unmute
- `XF86AudioMicMute` - Microphone mute toggle
- `XF86AudioPlay` - Play/pause
- `XF86AudioNext` - Next track
- `XF86AudioPrev` - Previous track
- `XF86MonBrightnessUp` - Brightness increase
- `XF86MonBrightnessDown` - Brightness decrease
- `XF86Sleep` - Sleep/suspend
- `XF86PowerOff` - Power off
- `XF86WLAN` - Toggle WiFi
- `XF86Bluetooth` - Toggle Bluetooth
- `XF86Calculator` - Launch calculator
- `XF86Mail` - Launch mail client
- `XF86Messenger` - Launch messenger
- `XF86WebCam` - Toggle webcam

[3][4][1][2]

### Volume Control

Bind media keys to volume commands using `amixer`, `pactl`, or `wpctl` (PipeWire):[1][2][3]

**Using pactl (PulseAudio):**
```
bind = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
bind = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
bind = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
bind = , XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle
```


**Using wpctl (PipeWire):**
```
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
```


**Using amixer (ALSA):**
```
bind = , XF86AudioRaiseVolume, exec, amixer set Master 5%+
bind = , XF86AudioLowerVolume, exec, amixer set Master 5%-
bind = , XF86AudioMute, exec, amixer set Master toggle
```


### Brightness Control

Adjust display brightness using `brightnessctl` or `xbacklight`:[2][3][1]

**Using brightnessctl:**
```
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
```


**Using xbacklight:**
```
bind = , XF86MonBrightnessUp, exec, xbacklight -inc 5
bind = , XF86MonBrightnessDown, exec, xbacklight -dec 5
```


### Media Playback Control

Control music players and media applications using `playerctl`:[3][1][2]
```
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous
```


Playerctl works with MPRIS-compatible players including Spotify, VLC, mpv, and many others.[1][2]

### Keyboard Backlight

Control keyboard backlighting with `brightnessctl`:[2][1]
```
bind = , XF86KbdBrightnessUp, exec, brightnessctl -d kbd_backlight set +10%
bind = , XF86KbdBrightnessDown, exec, brightnessctl -d kbd_backlight set 10%-
```


### System Control Keys

Bind sleep and power management keys:[1][2]
```
bind = , XF86Sleep, exec, systemctl suspend
bind = , XF86PowerOff, exec, systemctl poweroff
bind = , XF86ScreenSaver, exec, swaylock
```


### WiFi and Bluetooth

Toggle wireless interfaces using `nmcli` or `rfkill`:[2][1]

**Using rfkill:**
```
bind = , XF86WLAN, exec, rfkill toggle wifi
bind = , XF86Bluetooth, exec, rfkill toggle bluetooth
```


**Using nmcli:**
```
bind = , XF86WLAN, exec, nmcli radio wifi off
bind = , XF86Bluetooth, exec, nmcli radio bluetooth off
```


### Application Launchers

Launch applications directly from media keys:[3][1][2]
```
bind = , XF86Calculator, exec, gnome-calculator
bind = , XF86Mail, exec, thunderbird
bind = , XF86WebCam, exec, mpv av://v4l2:/dev/video0
```


### Notification Integration

Display on-screen notifications for media key actions using `notify-send`:[3][1][2]
```
bind = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5% && notify-send "Volume" "$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)%"
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5% && notify-send "Brightness" "$(brightnessctl get | awk '{print int($1/$2*100)}')%"
```


### Example Comprehensive Media Key Configuration

```
# Volume
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Brightness
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
bind = , XF86KbdBrightnessUp, exec, brightnessctl -d kbd_backlight set +10%
bind = , XF86KbdBrightnessDown, exec, brightnessctl -d kbd_backlight set 10%-

# Media playback
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# System
bind = , XF86Sleep, exec, systemctl suspend
bind = , XF86ScreenSaver, exec, swaylock

# Wireless
bind = , XF86WLAN, exec, rfkill toggle wifi
bind = , XF86Bluetooth, exec, rfkill toggle bluetooth

# Applications
bind = , XF86Calculator, exec, gnome-calculator
bind = , XF86Mail, exec, thunderbird
```

Sources
[1] Binds https://wiki.hypr.land/Configuring/Binds/
[2] Binds | Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Configuring/Binds/
[3] Keybinds · JaKooLit/Hyprland-Dots Wiki https://github.com/JaKooLit/Hyprland-Dots/wiki/Keybinds
[4] Hyprland https://wiki.cachyos.org/configuration/desktop_environments/hyprland/

## Dispatchers & Commands

Dispatchers are actions executed by keybinds, executed through `hyprctl dispatch`, or triggered by other events. They control window behavior, workspace navigation, layout switching, and system integration.[1][2]

### Window Management Dispatchers

**killactive** closes the currently focused window without saving. **closewindow [PID]** closes a specific window by process ID. **togglefloating** switches the focused window between tiling and floating modes. **togglefloating passive** toggles floating without changing focus direction.[2]

**togglesticky** makes floating windows sticky, displaying them on all workspaces. **togglesplit** swaps window split orientation (horizontal/vertical) when `preserve_split` is enabled. **movecursor [X] [Y]** moves the cursor to absolute screen coordinates.[2]

**centerwindow [MODE]** centers floating windows: `0` (default, both axes), `1` (horizontal only), `2` (vertical only).[2]

### Focus and Navigation

**movefocus [DIRECTION]** moves focus in specified direction: `l` (left), `r` (right), `u` (up), `d` (down). **focuswindow [WINDOW_ID]** focuses a specific window by ID. **focusmonitor [DIRECTION/MONITOR]** switches focus to adjacent or named monitor. **cyclenext** focuses the next window in tiling order. **cycleprev** focuses the previous window.[2]

**focuscurrentorlast** focuses most recently active window if current is unfocused, or current window if already focused.[2]

### Window Movement and Resizing

**movewindow [DIRECTION]** moves tiled windows within their container or relocates floating windows. **resizewindow [DIRECTION] [AMOUNT]** resizes floating windows; amount can be absolute pixels or percentage (e.g., `10%`). **swapwindow [DIRECTION/WINDOW_ID]** exchanges positions with adjacent or specified windows.[2]

**swapactive [DIRECTION]** swaps focused window with neighbor without moving focus. **movetoworkspace [WORKSPACE/DIRECTION]** relocates focused window to target workspace. **movetoworkspacesilent** moves window without switching to destination workspace.[2]

**pin** makes windows visible on all workspaces. **unpin** removes pin status.[2]

### Fullscreen and Maximize

**fullscreen [0/1/2/3]** toggles fullscreen modes: `0` (toggle), `1` (fullscreen), `2` (fullscreen without panels), `3` (maximized in-place). **fakefullscreen [0/1]** simulates fullscreen without actual state change.[2]

### Workspace Dispatchers

**workspace [ID/NAME/DIRECTION]** switches to workspace by ID, name, or directional offset (`+1`, `-1`). **workspaceopt [OPTION] [VALUE]** modifies workspace options at runtime. **renameworkspace [ID/NAME] [NEWNAME]** renames workspace. **focusworkspaceoncurrentmonitor [ID/NAME]** switches workspace only on active monitor, respecting bindings.[2]

**movecurrentworkspacetomonitor [DIRECTION/MONITOR]** relocates active workspace to adjacent or named monitor. **swapactiveworkspaces [MONITOR1] [MONITOR2]** exchanges workspaces between monitors.[2]

### Layout and Tiling

**togglesplit** swaps split orientation (dwindle only). **layoutmsg [MESSAGE] [PARAMS]** sends layout-specific messages. Available messages depend on layout: dwindle supports `preselect`, `togglesplit`, `swapsplit`, `movetoroot`; master supports `swapwithmaster`, `focusmaster`, `cyclenext`, `addmaster`, `removemaster`, `orientationleft/right/top/bottom`.[3][4][2]

**togglegroup** creates groups or removes focused window from group. **changegroupactive [f/b]** cycles group members forward or backward. **movewindowtogroupid [ID]** moves window to specific group.[3]

### Input and Binding

**pass [WINDOW_CLASS_REGEX]** sends key/mouse events directly to specified applications without Hyprland processing. **sendshortcut [MOD] [KEY] [WINDOW_CLASS_REGEX]** sends keyboard shortcut to application.[1][2]

### Submap and Mode Switching

**submap enter [NAME]** activates a keybind submap (custom input mode). **submap leave** exits current submap. Submaps allow context-specific keybinds; for example, entering resize mode with unique bindings. **keybind submap** syntax: `bind = MOD, KEY, submap, enter resizeMode` then define bindings within that context.[2]

### Animation and Effects

**ani [ANIMATION_NAME] [SPEED] [CURVE]** animates window properties. **toggleopaque** toggles window opacity between normal and fully opaque.[2]

### Executing External Commands

**exec [COMMAND]** runs shell commands; useful for launching applications, scripts, or system utilities. **execshellcmd [COMMAND]** executes commands with shell expansion. **execonce [COMMAND]** executes command only once per session.[2]

### System Control

**exit** closes Hyprland session. **reload** reloads configuration and restarts compositor. **dpms [on/off/toggle]** controls monitor power state.[2]

### Debugging and Information

**hyprctl** commands query and modify Hyprland state at runtime without reloading config. Examples: `hyprctl dispatch workspace 1`, `hyprctl monitors`, `hyprctl clients`, `hyprctl keyword general:gaps_in 10`.[2]

### Dispatcher Execution Methods

Execute dispatchers through keybinds in config:
```
bind = SUPER, Q, killactive
bind = SUPER, F, fullscreen, 1
```


Execute at runtime via `hyprctl dispatch`:
```bash
hyprctl dispatch workspace 2
hyprctl dispatch movewindow l
hyprctl dispatch exec kitty
```


Execute via shell scripts in `exec-once` or `exec`:
```
exec-once = hyprctl dispatch workspace 1
exec = hyprctl keyword general:gaps_in 15
```


### Example Dispatcher Configuration

```
# Window management
bind = SUPER, Q, killactive
bind = SUPER, SPACE, togglefloating
bind = SUPER, P, pin
bind = SUPER, F, fullscreen, 1

# Focus
bind = SUPER, Left, movefocus, l
bind = SUPER, Right, movefocus, r
bind = SUPER, Up, movefocus, u
bind = SUPER, Down, movefocus, d

# Window movement
bind = SUPER+SHIFT, Left, swapwindow, l
bind = SUPER+SHIFT, Right, swapwindow, r
bind = SUPER+SHIFT, H, resizewindow, l 30
bind = SUPER+SHIFT, L, resizewindow, r 30

# Workspace
bind = SUPER, 1, workspace, 1
bind = SUPER+SHIFT, 1, movetoworkspace, 1
bind = SUPER, Tab, workspace, +1

# Layout
bind = SUPER, E, togglesplit
bind = SUPER, G, togglegroup
bind = SUPER, M, layoutmsg, swapwithmaster

# Applications
bind = SUPER, RETURN, exec, kitty
bind = SUPER, D, exec, rofi -show drun

# System
bind = SUPER, L, exec, swaylock
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
```

Sources
[1] Binds https://wiki.hypr.land/Configuring/Binds/
[2] Dispatchers https://wiki.hyprland.org/0.41.0/Configuring/Dispatchers/
[3] Dwindle Layout https://wiki.hypr.land/Configuring/Dwindle-Layout/
[4] Master Layout https://wiki.hypr.land/Configuring/Master-Layout/
[5] Binds | Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Configuring/Binds/


# System Integration


## Environment Variables

Environment variables in Hyprland configure system-level behavior, application compatibility, and Wayland protocol settings. They are set in `hyprland.conf` using the `env` keyword and persist throughout the Hyprland session.[1]

### Setting Environment Variables

The syntax is `env = VARIABLE_NAME,value`. Unlike standard shell syntax, Hyprland uses commas instead of equals signs to separate variable and value. Values can contain spaces without quoting:[1]
```
env = QT_QPA_PLATFORMTHEME,qt5ct
env = LIBVA_DRIVER_NAME,nvidia
env = GDK_SCALE,1.5
```


### Wayland and Display Protocol

**WAYLAND_DISPLAY** sets the Wayland socket path (automatically set by Hyprland, typically `wayland-0`). **DISPLAY** specifies X11 display for XWayland compatibility (automatically configured).[1]

**XDG_CURRENT_DESKTOP** identifies the running desktop environment; set to `Hyprland` for compatibility:[1]
```
env = XDG_CURRENT_DESKTOP,Hyprland
```


**XDG_SESSION_TYPE** specifies session type; set to `wayland` for Wayland-native behavior:[1]
```
env = XDG_SESSION_TYPE,wayland
```


### NVIDIA GPU Configuration

**LIBVA_DRIVER_NAME** sets video acceleration driver for NVIDIA (required for hardware video decoding):[2][1]
```
env = LIBVA_DRIVER_NAME,nvidia
```


**__GLX_VENDOR_LIBRARY_NAME** configures OpenGL vendor library for NVIDIA:[2]
```
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
```


**ELECTRON_OZONE_PLATFORM_HINT** enables Wayland support in Electron applications (Firefox, Chromium, VS Code):[2][1]
```
env = ELECTRON_OZONE_PLATFORM_HINT,auto
```


**AQ_DRM_DEVICES** specifies primary GPU for multi-GPU systems (NVIDIA-specific, rarely needed):[2]
```
env = AQ_DRM_DEVICES,/dev/dri/card0
```


**AQ_FORCE_LINEAR_BLIT** disables linear modifier forcing on multi-GPU buffers when set to 0 (NVIDIA-specific, may reduce performance on secondary monitors):[2]
```
env = AQ_FORCE_LINEAR_BLIT,0
```


### Cursor Configuration

**XCURSOR_THEME** sets XCursor theme name for applications not supporting hyprcursor:[3][4]
```
env = XCURSOR_THEME,Adwaita
```


**XCURSOR_SIZE** sets XCursor size in pixels (multiply by HiDPI scale factor for scaled displays):[4][3]
```
env = XCURSOR_SIZE,24
```


**HYPRCURSOR_THEME** sets hyprcursor theme (native Wayland cursor):[3]
```
env = HYPRCURSOR_THEME,Bibata-Modern-Classic
```


**HYPRCURSOR_SIZE** sets hyprcursor size (does not multiply by scale factor):[3]
```
env = HYPRCURSOR_SIZE,24
```


### Qt and GTK Configuration

**QT_QPA_PLATFORMTHEME** configures Qt5/Qt6 platform theme for consistent styling:[1]
```
env = QT_QPA_PLATFORMTHEME,qt5ct
```


**QT_SCALE_FACTOR** sets Qt application scaling for HiDPI (alternative to monitor scaling):[1]
```
env = QT_SCALE_FACTOR,1.5
```


**GDK_SCALE** sets GTK application scaling (integer values only, 1 or 2 typically):[1]
```
env = GDK_SCALE,2
```


**GTK_USE_PORTAL** enables XDG Desktop Portal for GTK file dialogs and other services:[1]
```
env = GTK_USE_PORTAL,1
```


### Locale and Language

**LANG** sets system language and locale:[1]
```
env = LANG,en_US.UTF-8
```


**LC_ALL** overrides all locale settings (rarely needed):[1]
```
env = LC_ALL,en_US.UTF-8
```


### Input Method (IME)

**XMODIFIERS** configures X11 input method for legacy applications:[1]
```
env = XMODIFIERS,@im=fcitx
```


**GTK_IM_MODULE** sets GTK input method engine:[1]
```
env = GTK_IM_MODULE,fcitx
```


**QT_IM_MODULE** sets Qt input method engine:[1]
```
env = QT_IM_MODULE,fcitx
```


### Application-Specific Variables

**ELECTRON_ENABLE_FEATURES** enables experimental Electron features (Wayland, etc.):[1]
```
env = ELECTRON_ENABLE_FEATURES,WaylandWindowDecorations
```


**CLUTTER_BACKEND** forces Clutter (used by some applications) to use Wayland instead of X11:[1]
```
env = CLUTTER_BACKEND,wayland
```


**SDL_VIDEODRIVER** configures SDL applications (games, some tools) to use Wayland:[1]
```
env = SDL_VIDEODRIVER,wayland
```


**JAVA_TOOL_OPTIONS** configures Java application scaling and Wayland support:[1]
```
env = JAVA_TOOL_OPTIONS,-Dswing.defaultlaf=javax.swing.plaf.gtk.GTKLookAndFeel
```


### Debugging and Development

**HYPRLAND_DEBUG** enables debug logging (rarely needed for end users):[1]
```
env = HYPRLAND_DEBUG,1
```


**VK_INSTANCE_LAYERS** enables Vulkan validation layers for debugging (development only):[1]
```
env = VK_INSTANCE_LAYERS,VK_LAYER_KHRONOS_validation
```


### GPU Driver Selection

**WLR_DRM_DEVICES** manually selects GPU devices on multi-GPU systems:[5][6]
```
env = WLR_DRM_DEVICES,/dev/dri/card1
```


This forces Hyprland to use card1 instead of auto-detection, useful for hybrid Intel/AMD or Intel/NVIDIA systems.[5]

### Example Comprehensive Environment Configuration

```
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = WAYLAND_DISPLAY,wayland-0

# Qt and GTK
env = QT_QPA_PLATFORMTHEME,qt5ct
env = QT_SCALE_FACTOR,1.5
env = GDK_SCALE,1
env = GTK_USE_PORTAL,1

# Cursor
env = XCURSOR_THEME,Adwaita
env = XCURSOR_SIZE,24
env = HYPRCURSOR_THEME,Bibata-Modern-Classic
env = HYPRCURSOR_SIZE,24

# Input method
env = XMODIFIERS,@im=fcitx
env = GTK_IM_MODULE,fcitx
env = QT_IM_MODULE,fcitx

# Application compatibility
env = ELECTRON_OZONE_PLATFORM_HINT,auto
env = SDL_VIDEODRIVER,wayland
env = CLUTTER_BACKEND,wayland

# NVIDIA-specific (if applicable)
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia

# Locale
env = LANG,en_US.UTF-8
```

Sources
[1] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/
[2] NVidia https://wiki.hypr.land/Nvidia/
[3] hyprcursor https://wiki.hypr.land/Hypr-Ecosystem/hyprcursor/
[4] Inconsistent cursor themes on GTK apps / Applications & ... https://bbs.archlinux.org/viewtopic.php?id=292763
[5] Run on Intel Integrated Graphics? : r/hyprland - Reddit https://www.reddit.com/r/hyprland/comments/178jldh/run_on_intel_integrated_graphics/
[6] Problem with Intel/AMD hybrid GPU in Hyprland - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=289555
[7] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland

## Autostart Configuration

Autostart configuration executes commands automatically when Hyprland launches, useful for starting applications, services, daemons, and system initialization tasks. Hyprland provides two execution keywords: `exec-once` for one-time startup and `exec` for reload-time execution.[1][2]

### exec-once Keyword

**exec-once** runs commands only once per Hyprland session, regardless of configuration reloads. Use this for applications that should start once and continue running, services that error on restart, or system initialization tasks:[2][1]
```
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = dunst
exec-once = hyprpaper
exec-once = waybar
```


The first example starts the KDE authentication agent (essential for password prompts), the second initializes D-Bus for application compatibility, the third starts a notification daemon, the fourth launches a wallpaper manager, and the fifth starts a status bar.[1]

### exec Keyword

**exec** runs commands every time the configuration reloads, whether on startup or manual reload via `hyprctl reload`. Use this sparingly for commands that tolerate repeated execution or must rerun after config changes:[2][1]
```
exec = hyprctl setcursor Bibata-Modern-Classic 24
exec = pkill waybar; waybar
```


The first resets the cursor theme on reload, the second kills and restarts waybar to apply any changed configuration.[1]

### Application Launching

Start desktop applications with `exec-once`:[1]
```
exec-once = firefox
exec-once = spotify
exec-once = discord
exec-once = slack
exec-once = element-desktop
```


These applications start automatically on session launch. Delay startup with `sleep` if other services must initialize first:[1]
```
exec-once = sleep 2 && discord
```


### System Services and Daemons

Initialize critical system services on startup:[2][1]
```
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user start graphical-session-pre.target graphical-session.target graphical-session.target
```


These start polkit agents (required for privilege elevation), update D-Bus environment, and initialize systemd user session targets.[2][1]

### Notification Daemon

Start notification daemons for desktop notifications:[1]
```
exec-once = mako
exec-once = dunst
exec-once = swaync
```


Only one notification daemon should run; choose based on preferred configuration and features.[2][1]

### Wallpaper and Desktop

Set wallpapers and desktop backgrounds:[2][1]
```
exec-once = hyprpaper
exec-once = swaybg -i ~/Pictures/wallpaper.png
exec-once = mpvpaper --auto-pause eDP-1 ~/Videos/wallpaper.mp4
```


Hyprpaper manages multiple wallpapers and scaling; swaybg is simpler for single images; mpvpaper enables animated wallpapers.[1]

### Status Bar and System Tray

Initialize UI elements:[1]
```
exec-once = waybar
exec-once = polybar main
exec-once = eww daemon && eww open bar
```


Waybar is Wayland-native and Hyprland-compatible; polybar requires workarounds; eww (ElKowars wacky widgets) is minimal and highly configurable.[1]

### Clipboard Manager

Start clipboard managers for history and synchronization:[2][1]
```
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
exec-once = clipse
```


The first two start cliphist with text and image history; clipse provides a simpler alternative.[1]

### Input Method (IME)

Initialize input method engines for non-Latin languages:[2][1]
```
exec-once = fcitx5 -d
exec-once = ibus daemon --xim
```


Fcitx5 is modern and recommended; ibus is a legacy alternative.[1]

### XDG Desktop Portal

Start desktop portal for file dialogs and system integration:[2][1]
```
exec-once = /usr/libexec/xdg-desktop-portal-wlr
exec-once = /usr/libexec/xdg-desktop-portal-hyprland
exec-once = /usr/libexec/xdg-desktop-portal-gnome
```


Hyprland has a dedicated portal (`xdg-desktop-portal-hyprland`); wlr and gnome portals are alternatives.[1]

### Screen Locking and Idle Management

Configure lock screens and idle behavior:[2][1]
```
exec-once = swayidle -w before-sleep 'swaylock -f'
exec-once = hypridle
```


Swayidle locks the screen before system sleep; hypridle is Hyprland-specific and offers more features.[1]

### Custom Scripts

Execute custom initialization scripts:[2][1]
```
exec-once = ~/.config/hypr/scripts/startup.sh
exec-once = bash ~/.config/hypr/scripts/monitor-setup.sh
```


Place scripts in `~/.config/hypr/scripts/` and ensure they're executable (`chmod +x script.sh`).[1]

### Conditional Execution

Use shell conditionals for platform-specific or hardware-specific startup:[2][1]
```
exec-once = [[ $(hostname) == "laptop" ]] && hyprctl keyword input:touchpad:disable_while_typing true
exec-once = [[ -f /usr/bin/nvidia-smi ]] && echo "NVIDIA GPU detected"
```


### Error Handling and Logging

Redirect output to logs for debugging failed autostart commands:[2][1]
```
exec-once = waybar > ~/.config/hypr/logs/waybar.log 2>&1
exec-once = dunst > ~/.config/hypr/logs/dunst.log 2>&1 &
```


The `&` background operator prevents blocking Hyprland startup if a command hangs.[1]

### Example Comprehensive Autostart Configuration

```
# Authentication and D-Bus
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Wallpaper
exec-once = hyprpaper

# Notification daemon
exec-once = dunst

# Status bar
exec-once = waybar

# Clipboard manager
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store

# Input method
exec-once = fcitx5 -d

# XDG Desktop Portal
exec-once = /usr/libexec/xdg-desktop-portal-hyprland

# Idle and lock
exec-once = hypridle

# Applications
exec-once = discord
exec-once = spotify
exec-once = firefox

# Custom scripts
exec-once = ~/.config/hypr/scripts/startup.sh
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/
[3] Variables https://wiki.hyprland.org/0.46.0/Configuring/Variables/

## Session Management

Session management controls Hyprland's startup, shutdown, idle behavior, screen locking, and systemd integration. Proper configuration ensures applications save state, system suspends correctly, and security measures activate when idle.[1][2]

### systemd User Session Integration

Initialize systemd user session targets for proper system integration:[2][1]
```
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user start graphical-session-pre.target graphical-session.target graphical-session.target
```


These commands import environment variables into systemd, enabling user services to access Wayland and desktop information, then start graphical session targets that activate user-level services.[1][2]

### D-Bus and XDG Integration

Update D-Bus environment for application compatibility:[2][1]
```
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
```


This ensures D-Bus services receive correct environment variables, enabling applications like password managers, VPNs, and system daemons to function properly.[1][2]

### Screen Locking and Idle Management

**Hypridle** is the Hyprland-native idle daemon, offering deep integration and performance advantages:[2][1]
```
exec-once = hypridle
```


Configure hypridle with `~/.config/hypridle/hypridle.conf` to define idle timeouts and actions:
```
general {
  lock_cmd = hyprlock
  unlock_cmd = notify-send "Unlock!"
  before_sleep_cmd = notify-send "Before sleep"
  after_sleep_cmd = notify-send "After sleep"
  ignore_systemd_inhibit = false
}

listener {
  timeout = 300
  on-timeout = notify-send "Idle for 5 minutes"
}

listener {
  timeout = 600
  on-timeout = hyprlock
}

listener {
  timeout = 900
  on-timeout = systemctl suspend
}
```


This configuration locks the screen after 10 minutes of inactivity and suspends after 15 minutes.[1]

**Swayidle** is an alternative lightweight idle daemon:[2][1]
```
exec-once = swayidle -w before-sleep 'swaylock -f'
```


This locks the screen before system sleep but provides fewer idle timeout options than hypridle.[1]

### Screen Locking

**Hyprlock** is Hyprland's native lock screen with GPU-accelerated rendering:[2][1]
```
exec-once = hypridle
```


Configure `~/.config/hypr/hyprlock.conf`:
```
background {
  monitor =
  path = ~/Pictures/wallpaper.png
  blur_passes = 3
  blur_size = 8
}

input-field {
  monitor =
  size = 200, 50
  outline_thickness = 3
  dots_size = 0.2
  dots_spacing = 0.2
  outer_color = rgb(151515)
  inner_color = rgb(222222)
  font_color = rgb(10, 10, 10)
  fade_on_empty = false
  font_family = JetBrains Mono
  placeholder = <span foreground="##ffffff">🔒 Enter password</span>
  hide_input = false
  check_color = rgb(204, 136, 34)
  fail_color = rgb(204, 34, 34)
  fail_text = <i>$ATTEMPTS failed</i>
  capslock_color = -1
  numlock_color = -1
  bothlock_color = -1
  invert_numlock = false
  swap_layout_key = Tab
}

label {
  monitor =
  text = $TIME
  text_align = center
  color = rgba(200, 200, 200, 1.0)
  font_size = 55
  font_family = JetBrains Mono
  position = 0, 200
  halign = center
  valign = center
}
```


**Swaylock** is a lightweight alternative lock screen:[1]
```
bind = SUPER, L, exec, swaylock -f -c 000000
```


### Session Save/Restore

Some applications support automatic session saving through XDG session management. Enable session save on exit and restore on startup:[1]
```
bind = SUPER+SHIFT, E, exec, hyprctl dispatch exit 0
```


Applications with session support (GNOME applications, some KDE apps) automatically restore state.[1]

### Power Management

Bind power management commands to keybinds and autostart:[2][1]
```
bind = SUPER, P, exec, systemctl poweroff
bind = SUPER, S, exec, systemctl suspend
bind = SUPER+SHIFT, S, exec, systemctl hibernate
```


Configure sleep and suspend behavior in `/etc/systemd/sleep.conf` for pre-sleep hooks.[1]

### systemd Power Button Handling

Disable Hyprland's default power button handling and let systemd manage it:[2][1]
```
# Remove or comment out power button dispatcher
# bind = , XF86PowerOff, exec, systemctl poweroff
```


Systemd automatically handles power button, sleep button, and lid switch events according to `/etc/systemd/logind.conf`.[2][1]

### Multi-Monitor Session Persistence

Preserve monitor configuration across sessions using `hyprctl monitors all` output:[1]
```
monitor = DP-1, 3440x1440@144, 0x0, 1
monitor = DP-2, 2560x1440@60, 3440x0, 1
```


Hyprland automatically applies monitor configuration on startup if saved in `hyprland.conf`.[1]

### Workspace Persistence

Configure persistent workspaces to maintain layout across sessions:[1]
```
workspace = 1, persistent:true
workspace = 2, persistent:true
workspace = name:code, persistent:true
workspace = name:mail, persistent:true
```


Persistent workspaces remain in the workspace list even when empty, enabling consistent workflow organization.[1]

### systemd User Services for Hyprland

Create custom systemd user services for Hyprland-specific tasks. Example `~/.config/systemd/user/hyprland-startup.service`:[2][1]
```
[Unit]
Description=Hyprland Startup
After=graphical-session-pre.target
PartOf=graphical-session.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=%h/.config/hypr/scripts/startup.sh
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=graphical-session.target
```


Enable with `systemctl --user enable hyprland-startup.service`.[1]

### Example Comprehensive Session Configuration

```
# D-Bus and systemd
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user start graphical-session-pre.target graphical-session.target

# Authentication and portals
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = /usr/libexec/xdg-desktop-portal-hyprland

# Idle and lock
exec-once = hypridle

# UI elements
exec-once = waybar
exec-once = dunst

# Power management
bind = SUPER, P, exec, systemctl poweroff
bind = SUPER, S, exec, systemctl suspend
bind = SUPER, L, exec, hyprlock

# Workspace persistence
workspace = 1, persistent:true
workspace = 2, persistent:true
workspace = name:code, persistent:true
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/
[3] Variables https://wiki.hyprland.org/0.46.0/Configuring/Variables/

## Display Managers

Display managers provide graphical login screens and session selection for Hyprland. While TTY-based launch is recommended, several display managers offer Hyprland-compatible configurations with varying levels of compatibility and reliability.[1][2][3]

### SDDM (Simple Desktop Display Manager)

**SDDM** is the most reliable display manager for Hyprland, offering excellent compatibility and extensive customization. Install on Arch Linux with `sudo pacman -S sddm` or use `sddm-git` from AUR for latest features.[4][5][1]

**Important:** Install SDDM version 0.20.0 or later to avoid bug 1476 causing 90-second shutdowns on exit. Verify version with `sddm --version`.[5][1]

Enable SDDM with `sudo systemctl enable sddm.service`. Configure SDDM theme in `/etc/sddm.conf.d/kde_settings.conf` under `[general]` section:[2][5]
```
[general]
Session=hyprland
Theme=sugar-candy
```


Install additional themes with `yay -S sddm-theme-sugar-candy` or other theme packages. SDDM automatically detects Hyprland and displays it in the session menu once installed.[3][5]

### GDM (GNOME Display Manager)

**GDM** works but exhibits reliability issues specific to Hyprland. GDM crashes on first Hyprland launch, requiring manual intervention or restarting. Some users report persistent issues making GDM unsuitable for production use.[1][4]

Install with `sudo pacman -S gdm` and enable with `sudo systemctl enable gdm.service`. GDM requires no additional Hyprland configuration but may not reliably boot into Hyprland.[4][1]

### greetd with ReGreet

**greetd** is a minimal Wayland-native greeter offering excellent Hyprland integration. Install with `sudo pacman -S greetd greetd-regreet`.[6][1][4]

Configure `/etc/greetd/config.toml`:[6]
```toml
[default_session]
session = hyprland

[terminal]
vt = 2

[default_session_script]
command = "hyprland"
```


For autologin (skip login screen), configure:[6]
```toml
[default_session]
session = greetd
```


greetd can autologin automatically, bypassing the login screen entirely while maintaining systemd integration.[4][6]

### ly (TUI Login Manager)

**ly** is a lightweight text-based login manager offering simplicity and reliability. Install with `sudo pacman -S ly` or from AUR.[1][4]

Enable with `sudo systemctl enable ly.service` and configure `/etc/ly/config.ini` for keyring and display settings. ly works flawlessly with Hyprland and resolves common keyring and compatibility issues.[4]

### lemurs

**lemurs** is a minimal, user-friendly login manager written in Rust. Install from AUR with `yay -S lemurs-git`. lemurs solves common keyring unlocking and compatibility issues while maintaining simplicity.[4]

### Session Selection

When using a display manager, select "Hyprland" from the session menu at login. The exact menu location varies by display manager but typically appears as a dropdown or separate window.[3]

If Hyprland doesn't appear in the session list, the installation is incomplete. Verify by checking install logs and re-running the installation script.[3]

### Hyprland Session Files

Display managers locate sessions through XDG session desktop files. Hyprland installs session files at:[3]
- `/usr/share/wayland-sessions/hyprland.desktop`
- `/usr/share/xsessions/hyprland.desktop` (legacy X11 compatibility)

If these files are missing, reinstall Hyprland completely.[3]

### Virtual Machine Setup

Running Hyprland through a display manager in a VM requires 3D acceleration enabled. Configure VirtualBox or KVM with 3D support before launching. Without 3D acceleration, Hyprland fails to start regardless of display manager.[1][3]

### Display Manager Troubleshooting

**Login loop:** The display manager returns to the login screen after attempting to log in. Check Hyprland installation logs in the display manager's log directory. Common causes: missing Hyprland packages, 3D acceleration disabled in VMs, or incomplete installation.[3]

**Session not appearing:** Hyprland not listed in session menu means session files are missing or corrupted. Reinstall Hyprland and verify session files exist.[3]

**Keyboard/mouse not working:** Some display managers require additional input configuration. ly and lemurs have built-in configuration options; greetd requires manual configuration.[4]

**Hang on logout:** SDDM versions before 0.20.0 hang for 90 seconds on exit due to bug 1476. Update to the latest version.[5][1]

### TTY Launch Alternative

Avoid display managers entirely by launching from TTY:[1][6]

Add to `~/.bash_profile` or `~/.zprofile`:
```bash
[[ "$(tty)" == /dev/tty1 ]] && Hyprland
```


Log into TTY1 and Hyprland launches automatically. This eliminates display manager complications and provides the most reliable Hyprland session.[7][1][6]

### Comparison Table

| Display Manager | Compatibility | Complexity | Reliability | Recommended |
|---|---|---|---|---|
| SDDM | Excellent | Medium | Excellent | ✓ Yes |
| GDM | Fair | Low | Poor | No |
| greetd | Excellent | Low | Excellent | ✓ Yes |
| ly | Excellent | Low | Excellent | ✓ Yes |
| lemurs | Excellent | Low | Excellent | ✓

Sources
[1] Master tutorial https://wiki.hypr.land/Getting-Started/Master-Tutorial/
[2] Set Display Manager on Startup (Hyprland) : r/archlinux https://www.reddit.com/r/archlinux/comments/1dxnr7a/set_display_manager_on_startup_hyprland/
[3] FAQ_Login_Managers · JaKooLit/Hyprland-Dots Wiki https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ_Login_Managers
[4] Which loginmanager to use? : r/hyprland https://www.reddit.com/r/hyprland/comments/14voff7/which_loginmanager_to_use/
[5] A Noobs Guide to Hyprland | Customizing SDDM Display ... https://www.youtube.com/watch?v=9RLl9VyeTBo
[6] Proper way to launch Hyprland - Reddit https://www.reddit.com/r/hyprland/comments/1e5qgoj/proper_way_to_launch_hyprland/
[7] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland

## Universal Wayland Session Manager

UWSM (Universal Wayland Session Manager) provides standardized systemd integration for Wayland compositors, including Hyprland. It manages environment variables, D-Bus, systemd user sessions, and application lifecycle consistently across different Wayland implementations.[1][2]

### UWSM Purpose and Benefits

**Standardization:** UWSM eliminates compositor-specific session management hacks by providing a unified interface. Applications receive consistent environment variables regardless of which Wayland compositor runs.[1]

**systemd Integration:** UWSM properly starts systemd user targets (`graphical-session-pre.target`, `graphical-session.target`) ensuring user services activate correctly. This enables password managers, system daemons, and background services to function reliably.[1]

**D-Bus and Environment:** UWSM updates D-Bus with correct environment variables, enabling inter-process communication for applications requiring it. It imports `DISPLAY`, `WAYLAND_DISPLAY`, `XDG_CURRENT_DESKTOP`, and other critical variables into systemd.[1]

### Installation

Install UWSM on Arch Linux with `sudo pacman -S uwsm` or from AUR with `yay -S uwsm-git` for latest features. Other distributions may have UWSM in official repos or AUR.[1]

### Launching with UWSM

Launch Hyprland through UWSM instead of directly:[1]
```bash
uwsm start hyprland
```


This command starts Hyprland under UWSM management with all environment and session setup handled automatically.[1]

### Display Manager Integration

Configure display managers to launch Hyprland through UWSM. Modify the Hyprland session file at `/usr/share/wayland-sessions/hyprland.desktop` or create a custom version in `~/.local/share/wayland-sessions/`:[1]

```ini
[Desktop Entry]
Name=Hyprland (UWSM)
Comment=Hyprland using Universal Wayland Session Manager
Exec=uwsm start hyprland
Type=Application
```


When this session is selected in a display manager, UWSM launches Hyprland with proper setup.[1]

### TTY Launch with UWSM

Launch from TTY through UWSM by adding to shell profile:[1]
```bash
[[ "$(tty)" == /dev/tty1 ]] && uwsm start hyprland
```


This provides TTY-based launch with UWSM benefits.[1]

### Hyprland Configuration with UWSM

When using UWSM, the Hyprland config no longer needs D-Bus initialization commands since UWSM handles them. Remove or comment out these lines from `hyprland.conf`:[1]
```
# No longer needed with UWSM
# exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
# exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
```


Keep authentication agent startup but UWSM simplifies everything else:[1]
```
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = waybar
exec-once = dunst
```


### UWSM Commands

**Check UWSM status:** `uwsm check` displays current Wayland session status.[1]

**List available compositors:** `uwsm query compositors` shows which compositors UWSM can manage.[1]

**Stop session:** `uwsm stop` cleanly stops the current UWSM-managed session.[1]

**Restart:** `uwsm restart` restarts the compositor (similar to `hyprctl reload` but via systemd).[1]

### Application Integration

Applications automatically receive correct environment variables from UWSM, eliminating the need for manual environment configuration in `hyprland.conf`. Wayland-native applications recognize `WAYLAND_DISPLAY` and `XDG_CURRENT_DESKTOP` automatically.[1]

### Service Management

UWSM manages systemd user services through the graphical session target. Custom user services can depend on `graphical-session.target` and start automatically when UWSM launches a session.[1]

Create `~/.config/systemd/user/my-service.service`:[1]
```ini
[Unit]
Description=My Custom Service
PartOf=graphical-session.target
After=graphical-session-pre.target

[Service]
Type=simple
ExecStart=/usr/bin/my-service
Restart=on-failure

[Install]
WantedBy=graphical-session.target
```


Enable with `systemctl --user enable my-service.service` and it starts automatically with the UWSM session.[1]

### Comparison: UWSM vs Manual Setup

**Manual D-Bus setup:**
```
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user start graphical-session-pre.target graphical-session.target
```


**With UWSM:**
All handled automatically; just launch `uwsm start hyprland`[1]

### When to Use UWSM

**Use UWSM if:**
- Running multiple Wayland compositors and need consistent setup[1]
- Using systemd user services requiring proper session integration[1]
- Requiring portability across different Wayland environments[1]
- Preferring standardized Wayland session management[1]

**Manual setup is acceptable if:**
- Using only Hyprland on a single system[1]
- Preferring simpler configuration without additional tooling[1]
- Running in minimal environments where UWSM adds unnecessary complexity[1]

### Example UWSM-Based Hyprland Configuration

```
# Authentication (still needed with UWSM)
exec-once = /usr/lib/polkit-kde-authentication-agent-1

# XDG Desktop Portal
exec-once = /usr/libexec/xdg-desktop-portal-hyprland

# UI and applications (UWSM handles D-Bus)
exec-once = waybar
exec-once = dunst
exec-once = hypridle

# Desktop services
exec-once = /usr/libexec/xdg-desktop-portal-hyprland

# No D-Bus initialization needed; UWSM handles it
```


Launch with `uwsm start hyprland` or configure display manager to use the UWSM-aware session file.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

# Hypr Ecosystem

## Hyprpaper (Wallpapers)

Hyprpaper is Hyprland's native wallpaper manager providing efficient, GPU-accelerated wallpaper rendering with multi-monitor support, animated wallpapers, and dynamic configuration. It integrates seamlessly with Hyprland and avoids the overhead of separate wallpaper daemons.[1][2]

### Installation and Startup

Install Hyprpaper on Arch Linux with `sudo pacman -S hyprpaper`. Start automatically on Hyprland launch by adding to `hyprland.conf`:[1]
```
exec-once = hyprpaper
```


### Configuration File

Hyprpaper uses `~/.config/hypr/hyprpaper.conf` for configuration. Create this file if it doesn't exist.[1]

### Basic Wallpaper Setup

Set wallpapers per-monitor using the `preload` directive to cache images and `wallpaper` to assign:[2][1]
```
preload = ~/Pictures/wallpaper1.png
preload = ~/Pictures/wallpaper2.png
preload = ~/Pictures/wallpaper3.png

wallpaper = DP-1,~/Pictures/wallpaper1.png
wallpaper = HDMI-1,~/Pictures/wallpaper2.png
wallpaper = eDP-1,~/Pictures/wallpaper3.png
```


Preload loads images into memory and GPU for instant switching; wallpaper assignments apply specific images to monitors identified by their port names.[1][2]

### Dynamic Wallpaper Switching

Change wallpapers at runtime using `hyprctl hyprpaper switchwall`:[2][1]
```bash
hyprctl hyprpaper switchwall
```


This cycles through preloaded wallpapers. Create keybinds for easy wallpaper rotation:[2][1]
```
bind = SUPER, W, exec, hyprctl hyprpaper switchwall
```


### Sorting and Layout

**Sorting behavior:** Hyprpaper sorts wallpapers alphabetically when using `switchwall`. Name wallpapers numerically (01.png, 02.png, etc.) for predictable cycling order.[1]

**Monitor assignment:** Specify wallpapers for all connected monitors; omitted monitors use the previous wallpaper. Use monitor descriptions for device-agnostic configuration:[1]
```
wallpaper = desc:Chimei Innolux Corporation 0x150C,~/Pictures/wallpaper.png
```


### Animated Wallpapers

Hyprpaper supports animated GIFs and video files:[1]
```
preload = ~/Pictures/animated.gif
wallpaper = DP-1,~/Pictures/animated.gif
```


For video wallpapers, ensure the file format is supported (typically MP4 or WebM).[1]

### Wallpaper Scaling and Positioning

Hyprpaper automatically scales wallpapers to fill monitor resolution. Wallpapers stretch or shrink to match aspect ratio; no explicit scaling configuration exists.[1]

### Memory and Performance

**Preload optimization:** Preload images only if they'll be used; unnecessary preloads consume VRAM. Typical wallpapers use 10-50MB VRAM depending on resolution.[1]

**Format recommendations:** Use PNG for lossless quality and smaller file sizes than JPEG; JPEG acceptable for photographs. Avoid very large resolutions; 2560x1440 or 3840x2160 are typical limits.[1]

### Hyprpaper Commands

**Query current wallpaper:** `hyprctl hyprpaper listcurpaper` displays currently assigned wallpapers.[1]

**List preloaded:** `hyprctl hyprpaper listloaded` shows cached wallpapers.[1]

**Switch wallpaper:** `hyprctl hyprpaper switchwall` cycles to next wallpaper.[1]

**Set specific wallpaper:** `hyprctl hyprpaper wallpaper DP-1,~/Pictures/specific.png` assigns to specific monitor.[1]

### Alternative: swaybg

**swaybg** is a simpler lightweight alternative for static wallpapers:[1]
```
exec-once = swaybg -i ~/Pictures/wallpaper.png
```


Swaybg supports only static images and single wallpaper (same for all monitors), but uses less overhead than Hyprpaper. Good for minimal setups.[1]

### Alternative: mpvpaper

**mpvpaper** enables animated and video wallpapers using mpv player:[1]
```
exec-once = mpvpaper --auto-pause -z zoom eDP-1 ~/Videos/wallpaper.mp4
```


Mpvpaper supports any format mpv handles (MP4, WebM, GIF, etc.) but uses more CPU/GPU than Hyprpaper.[1]

### Wallpaper Collections and Themes

Organize wallpapers in subdirectories:[1]
```
~/Pictures/wallpapers/
  ├── dark/
  ├── light/
  └── animated/
```


Switch themes by changing preload directives or creating multiple configuration files.[1]

### Dynamic Wallpaper Switching Scripts

Create scripts for themed wallpaper switching:[1]

**`~/.config/hypr/scripts/wallpaper-dark.sh`:**
```bash
#!/bin/bash
hyprctl hyprpaper preload ~/Pictures/wallpapers/dark/1.png
hyprctl hyprpaper preload ~/Pictures/wallpapers/dark/2.png
hyprctl hyprpaper wallpaper DP-1,~/Pictures/wallpapers/dark/1.png
hyprctl hyprpaper wallpaper HDMI-1,~/Pictures/wallpapers/dark/2.png
```


Bind to keybinds:[1]
```
bind = SUPER, D, exec, ~/.config/hypr/scripts/wallpaper-dark.sh
bind = SUPER, L, exec, ~/.config/hypr/scripts/wallpaper-light.sh
```


### Example Hyprpaper Configuration

```
# Preload wallpapers
preload = ~/Pictures/wallpapers/01.png
preload = ~/Pictures/wallpapers/02.png
preload = ~/Pictures/wallpapers/03.png
preload = ~/Pictures/wallpapers/animated.gif

# Assign to monitors
wallpaper = DP-1,~/Pictures/wallpapers/01.png
wallpaper = HDMI-1,~/Pictures/wallpapers/02.png
wallpaper = eDP-1,~/Pictures/wallpapers/animated.gif

# ipc = off   # Disable IPC for security (optional)
```


Add to `hyprland.conf`:
```
exec-once = hyprpaper

bind = SUPER, W, exec, hyprctl hyprpaper switchwall
bind = SUPER+SHIFT, W, exec, ~/.config/hypr/scripts/wallpaper-random.sh
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Hyprlock (Screen Locking)

Hyprlock is Hyprland's native GPU-accelerated screen lock providing visual customization, secure input handling, and tight compositor integration. It replaces traditional X11 lockers with modern Wayland-native functionality.[1][2]

### Installation and Setup

Install Hyprlock on Arch Linux with `sudo pacman -S hyprlock`. Configure with `~/.config/hypr/hyprlock.conf` and start automatically with idle management:[1]
```
exec-once = hypridle
```


Hypridle triggers Hyprlock after idle timeout. Bind manual locking to keybinds:[1]
```
bind = SUPER, L, exec, hyprlock
```


### Configuration Structure

Hyprlock configuration uses nested blocks for layout components:[1]
```
general {
  # General settings
}

background {
  # Wallpaper/background
}

input-field {
  # Password input
}

label {
  # Text labels (time, date, etc.)
}

image {
  # Images and decorations
}
```


### General Settings

```
general {
  no_fade_in = false
  grace = 0
  disable_loading_bar = false
  immediate_render = false
  ignore_empty_input = false
  pam_module = login
  enable_notifications = false
}
```


**no_fade_in** disables fade animation on lock screen appearance (default false). **grace** sets unlock grace period in seconds—lock screen doesn't display if unlocked within grace period (default 0). **disable_loading_bar** hides the loading indicator (default false). **immediate_render** forces immediate rendering without fade effects (default false). **ignore_empty_input** prevents unlock on empty password (default false). **pam_module** sets PAM module for authentication (default "login"). **enable_notifications** shows notifications on lock screen (default false).[1]

### Background Configuration

```
background {
  monitor =
  path = ~/Pictures/wallpaper.png
  blur_passes = 3
  blur_size = 8
  vibrancy = 0.1696
  vibrancy_darkness = 0.0
}
```


**monitor** targets specific monitor; empty applies to all (default empty). **path** specifies background image file. **blur_passes** controls blur strength; higher values increase effect (default 3). **blur_size** sets blur radius in pixels (default 8). **vibrancy** increases color saturation (0.0-1.0, default 0.1696). **vibrancy_darkness** strengthens vibrancy on dark areas (default 0.0).[1]

### Password Input Field

```
input-field {
  monitor =
  size = 200, 50
  outline_thickness = 3
  dots_size = 0.2
  dots_spacing = 0.2
  outer_color = rgb(151515)
  inner_color = rgb(222222)
  font_color = rgb(10, 10, 10)
  fade_on_empty = true
  font_family = JetBrains Mono
  placeholder = <span foreground="##ffffff">🔒 Enter password</span>
  hide_input = false
  check_color = rgb(204, 136, 34)
  fail_color = rgb(204, 34, 34)
  fail_text = <i>$ATTEMPTS failed</i>
  capslock_color = -1
  numlock_color = -1
  bothlock_color = -1
  invert_numlock = false
  swap_layout_key = Tab
  position = 0, -20
  halign = center
  valign = center
}
```


**monitor** targets specific monitor (default empty for all). **size** sets input field dimensions as `WIDTH, HEIGHT`. **outline_thickness** controls border thickness in pixels (default 3). **dots_size** sets password dot size (default 0.2, range 0.0-1.0). **dots_spacing** controls spacing between dots (default 0.2). **outer_color** and **inner_color** set field colors. **font_color** sets text color (default black). **fade_on_empty** fades field when empty (default true). **font_family** specifies font (must be installed). **placeholder** sets prompt text; supports Pango markup. **hide_input** masks password characters (default false, shows dots).[1]

**check_color** highlights field on successful authentication (default green). **fail_color** highlights field on failed attempt (default red). **fail_text** displays after failed unlock; `$ATTEMPTS` shows attempt count (default empty). **capslock_color**, **numlock_color**, **bothlock_color** highlight field when those keys are active; -1 disables (default -1). **invert_numlock** reverses numlock indicator (default false). **swap_layout_key** specifies key for layout switching, typically `Tab` or `Alt_L` (default Tab).[1]

**position** and **halign/valign** control field placement; see label positioning section.[1]

### Text Labels

```
label {
  monitor =
  text = $TIME
  text_align = center
  color = rgba(200, 200, 200, 1.0)
  font_size = 55
  font_family = JetBrains Mono
  position = 0, 200
  halign = center
  valign = center
}
```


**text** content with variable support: `$TIME`, `$DATE`, `$USER`, `$SESSION`. **text_align** controls text alignment: `left`, `center` (default), `right`. **color** sets RGBA text color. **font_size** and **font_family** control typography. **position** sets X,Y offset in pixels; negative values offset from edges. **halign** (horizontal align): `left`, `center` (default), `right`. **valign** (vertical align): `top`, `center`, `bottom` (default).[1]

### Image Elements

```
image {
  monitor =
  path = ~/Pictures/icon.png
  size = 100
  rounding = 10
  border_size = 3
  border_color = rgb(100, 100, 100)
  rotate = 0
  reload_time = 10
  reload_cmd =
  position = 0, -100
  halign = center
  valign = center
}
```


**path** specifies image file. **size** sets image dimensions in pixels (square). **rounding** applies corner radius (default 0). **border_size** and **border_color** add border. **rotate** rotates image in degrees (default 0). **reload_time** reloads image every N seconds (useful for animations). **reload_cmd** executes command before reload (optional).[1]

### Positioning System

Position coordinates use pixel-based layout:[1]
- **Positive X/Y:** Offset from top-left corner
- **Negative X/Y:** Offset from bottom-right corner
- **halign:** Adjusts horizontal alignment (left/center/right)
- **valign:** Adjusts vertical alignment (top/center/bottom)

Example: `position = 0, -100` with `valign = bottom` places element 100 pixels from bottom, centered horizontally.[1]

### Variable Substitution in Labels

**$TIME** displays current time (format configurable with strftime). **$DATE** displays current date. **$USER** displays login username. **$SESSION** displays session name.[1]

### Example Comprehensive Hyprlock Configuration

```
general {
  no_fade_in = false
  grace = 0
  disable_loading_bar = false
  immediate_render = false
  ignore_empty_input = false
  pam_module = login
  enable_notifications = true
}

background {
  monitor =
  path = ~/Pictures/lockscreen.png
  blur_passes = 3
  blur_size = 8
  vibrancy = 0.1696
  vibrancy_darkness = 0.0
}

input-field {
  monitor =
  size = 200, 50
  outline_thickness = 3
  dots_size = 0.2
  dots_spacing = 0.2
  outer_color = rgb(151515)
  inner_color = rgb(222222)
  font_color = rgb(255, 255, 255)
  fade_on_empty = true
  font_family = JetBrains Mono
  placeholder = <span foreground="##ffffff">🔒 Enter password</span>
  hide_input = false
  check_color = rgb(204, 136, 34)
  fail_color = rgb(204, 34, 34)
  fail_text = <i>$ATTEMPTS failed</i>
  capslock_color = -1
  numlock_color = -1
  bothlock_color = -1
  invert_numlock = false
  swap_layout_key = Tab
  position = 0, -20
  halign = center
  valign = center
}

label {
  monitor =
  text = $TIME
  text_align = center
  color = rgba(200, 200, 200, 1.0)
  font_size = 55
  font_family = JetBrains Mono
  position = 0, 200
  halign = center
  valign = center
}

label {
  monitor =
  text = Locked
  text_align = center
  color = rgba(200, 200, 200, 0.7)
  font_size = 20
  font_family = JetBrains Mono
  position = 0, 100
  halign = center
  valign = center
}

image {
  monitor =
  path = ~/Pictures/lock-icon.png
  size = 80
  rounding = 10
  position = 0, -150
  halign = center
  valign = center
}
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Hypridle (Idle Management)

Hypridle is Hyprland's native idle daemon monitoring user inactivity and triggering actions like screen locking, display blanking, and system suspension. It replaces external idle managers with tight compositor integration for efficient resource usage.[1][2]

### Installation and Setup

Install Hypridle on Arch Linux with `sudo pacman -S hypridle`. Start automatically on Hyprland launch by adding to `hyprland.conf`:[1]
```
exec-once = hypridle
```


### Configuration File

Hypridle uses `~/.config/hypridle/hypridle.conf` for configuration. Create this file if it doesn't exist.[1]

### General Settings

```
general {
  lock_cmd = hyprlock
  unlock_cmd = notify-send "Unlocked"
  before_sleep_cmd = notify-send "Going to sleep"
  after_sleep_cmd = notify-send "Waking up"
  ignore_systemd_inhibit = false
}
```


**lock_cmd** specifies the command to run when locking (typically `hyprlock`). **unlock_cmd** runs after unlock (optional, useful for notifications). **before_sleep_cmd** runs before system sleep via systemd suspend/hibernate. **after_sleep_cmd** runs after system wakes up. **ignore_systemd_inhibit** when true, ignores systemd sleep inhibitors (applications preventing sleep), defaulting to false (respects inhibitors).[1]

### Idle Listeners

Define timeout-based actions with `listener` blocks:[1]

```
listener {
  timeout = 300
  on-timeout = notify-send "Idle for 5 minutes"
  on-resume = notify-send "User active"
}

listener {
  timeout = 600
  on-timeout = hyprlock
}

listener {
  timeout = 900
  on-timeout = systemctl suspend
}
```


**timeout** is inactivity duration in seconds before triggering (300 = 5 minutes). **on-timeout** command runs after timeout expires. **on-resume** (optional) runs when user becomes active again after idle.[1]

### Lock Screen Actions

Lock the screen after inactivity:[1]
```
listener {
  timeout = 600
  on-timeout = hyprlock
}
```


This locks after 10 minutes of inactivity.[1]

### Display Blanking

Turn off displays using DPMS (Display Power Management Signaling):[2][1]
```
listener {
  timeout = 600
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on
}
```


**dpms off** disables displays (saves power). **dpms on** re-enables displays when activity resumes. This activates before locking for efficiency.[1]

### System Suspension and Hibernation

Suspend the system after extended inactivity:[1]
```
listener {
  timeout = 1200
  on-timeout = systemctl suspend
}

listener {
  timeout = 1800
  on-timeout = systemctl hibernate
}
```


The first suspends after 20 minutes, the second hibernates after 30 minutes. Adjust timeouts based on power management preferences.[1]

### Notifications and Warnings

Provide user warnings before major actions:[1]
```
listener {
  timeout = 540
  on-timeout = notify-send --urgency=critical "Lock screen in 60 seconds"
}

listener {
  timeout = 600
  on-timeout = hyprlock
}

listener {
  timeout = 840
  on-timeout = notify-send --urgency=critical "System suspending in 60 seconds"
}

listener {
  timeout = 900
  on-timeout = systemctl suspend
}
```


These warn at 9 and 14 minutes before locking and suspending at 10 and 15 minutes respectively.[1]

### Inhibiting Sleep for Specific Applications

Applications can request sleep inhibition via systemd; Hypridle respects these by default. Video players and other long-running tasks automatically prevent sleep.[1]

Override inhibition with `ignore_systemd_inhibit = true` to force sleep regardless:[1]
```
general {
  ignore_systemd_inhibit = true
}
```


### Resume Commands

Execute commands when user becomes active:[1]
```
listener {
  timeout = 600
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on && notify-send "Screen reactivated"
}
```


### Multi-Command Actions

Execute multiple commands by chaining with `&&` or using scripts:[1]
```
listener {
  timeout = 600
  on-timeout = hyprctl dispatch dpms off && notify-send "Entering sleep mode"
}
```


Or reference shell scripts:[1]
```
listener {
  timeout = 600
  on-timeout = ~/.config/hypridle/scripts/sleep.sh
}
```


### Debugging and Logging

Check Hypridle status with `systemctl --user status hypridle`. View logs with `journalctl --user -u hypridle -f`.[1]

Enable verbose logging by modifying the configuration or restarting with debug flags (if supported).[1]

### Integration with Hyprlock and Display Management

Typical workflow combines multiple actions:[1]
```
listener {
  timeout = 120
  on-timeout = notify-send "Idle warning"
  on-resume = notify-send "Activity detected"
}

listener {
  timeout = 300
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on
}

listener {
  timeout = 600
  on-timeout = hyprlock
}

listener {
  timeout = 1200
  on-timeout = systemctl suspend
}
```


This provides warnings, dims displays after 5 minutes, locks after 10 minutes, and suspends after 20 minutes.[1]

### Example Comprehensive Hypridle Configuration

```
general {
  lock_cmd = hyprlock
  unlock_cmd = notify-send "Unlocked successfully"
  before_sleep_cmd = notify-send "Suspending..."
  after_sleep_cmd = notify-send "Resuming..."
  ignore_systemd_inhibit = false
}

# Warning notification
listener {
  timeout = 540
  on-timeout = notify-send --urgency=critical --expire-time=60000 "Locking screen in 60 seconds"
}

# Lock screen
listener {
  timeout = 600
  on-timeout = hyprlock
}

# Display off (before suspension warning)
listener {
  timeout = 840
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on
}

# Suspension warning
listener {
  timeout = 840
  on-timeout = notify-send --urgency=critical "System suspending in 60 seconds"
}

# System suspend
listener {
  timeout = 900
  on-timeout = systemctl suspend
}

# System hibernate (optional)
listener {
  timeout = 1800
  on-timeout = systemctl hibernate
}
```


Add to `hyprland.conf`:
```
exec-once = hypridle
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Hyprpicker (Color Picker)

Hyprpicker is Hyprland's native GPU-accelerated color picker utility for quickly grabbing colors from the screen. It operates as a standalone command-line tool with minimal dependencies and no external configuration required.[1][3][4]

### Installation

Install Hyprpicker on Arch Linux with `sudo pacman -S hyprpicker`. The application is available in most distribution repositories and can be built from source if needed.[4][5]

### Basic Usage

Launch Hyprpicker by executing the command:[4]
```bash
hyprpicker
```


When launched, the screen freezes displaying a magnified view of your cursor area. Click on the desired color and it outputs to stdout. The tool closes automatically after picking.[1][4]

### Output Formats

Specify output format with the `-f` or `--format` flag:[1]

**Hexadecimal (default):**
```bash
hyprpicker -f hex
```


Outputs: `#a1b2c3`[1]

**RGB:**
```bash
hyprpicker -f rgb
```


Outputs: `rgb(161, 178, 195)`[1]

**HSL:**
```bash
hyprpicker -f hsl
```


Outputs: `hsl(210, 9%, 70%)`[1]

**HSV:**
```bash
hyprpicker -f hsv
```


Outputs: `hsv(210, 9%, 76%)`[1]

**CMYK:**
```bash
hyprpicker -f cmyk
```


Outputs: `cmyk(18, 9, 0, 24)`[1]

### Automatic Clipboard Copy

Automatically copy the picked color to clipboard with the `-a` or `--autocopy` flag (requires `wl-clipboard`):[1]
```bash
hyprpicker -a
```


Combine with format flag:[1]
```bash
hyprpicker -a -f hex
```


### Visual Options

**Disable zoom lens:** Remove the magnified display area with `-z` or `--no-zoom`:[1]
```bash
hyprpicker -z
```


**Render inactive displays:** Freeze all displays including secondary monitors with `-r` or `--render-inactive`:[1]
```bash
hyprpicker -r
```


**Disable hex preview:** Remove the live hex code display with `-d` or `--disable-hex-preview`:[1]
```bash
hyprpicker -d
```


**Lowercase hex:** Output hexadecimal in lowercase with `-l` or `--lowercase-hex`:[1]
```bash
hyprpicker -l
```


Outputs: `#a1b2c3` instead of `#A1B2C3`[1]

**Disable colored output:** Remove fancy colored terminal output with `-n` or `--no-fancy`:[1]
```bash
hyprpicker -n
```


### Quiet Mode

Suppress informational logs while preserving errors with `-q` or `--quiet`:[1]
```bash
hyprpicker -q
```


### Keybind Integration

Bind Hyprpicker to keybinds for quick access:[5]
```
bind = SUPER, P, exec, hyprpicker -a -f hex
```


This launches the picker with automatic clipboard copy in hexadecimal format.[5]

### Shell Script Integration

Capture color output in shell scripts:[1]
```bash
#!/bin/bash
COLOR=$(hyprpicker -a -f hex)
echo "Picked color: $COLOR"
notify-send "Color picked" "$COLOR"
```


This picks a color, copies it, and sends a notification.[1]

### Waybar Integration

Display recently picked colors in Waybar status bar. Create a Waybar module that calls Hyprpicker and maintains color history.[2]

### Advanced: Fuzzel-based Color Picker

Enhance Hyprpicker with a Fuzzel-based GUI wrapper maintaining color history and keyboard navigation. Scripts like `fuzzel-hyprpicker.sh` provide persistent history and easy color selection.[6]

### Limitations and Notes

**Display freeze:** Hyprpicker freezes displays while picking color to provide accurate sampling. This is expected behavior and necessary for reliable color detection.[4][1]

**No GUI:** Hyprpicker is CLI-only; third-party GUIs like Fuzzel wrappers are needed for traditional point-and-click interfaces.[3][6]

**Wayland requirement:** Works exclusively on Wayland; X11 is not supported.[4][1]

### Example Comprehensive Usage

**Complex script with multiple formats:**
```bash
#!/bin/bash
echo "Pick a color..."
HEX=$(hyprpicker -f hex)
RGB=$(hyprpicker -f rgb)
HSL=$(hyprpicker -f hsl)

echo "Hex: $HEX"
echo "RGB: $RGB"
echo "HSL: $HSL"

echo "$HEX" | wl-copy
notify-send "Color Picker" "Hex color copied: $HEX"
```


**Keybind with notifications:**
```
bind = SUPER, C, exec, hyprpicker -a -f hex && notify-send "Color copied to clipboard"
```


**Format cycling:**
```
bind = SUPER, C, exec, hyprpicker -a -f hex
bind = SUPER+SHIFT, C, exec, hyprpicker -a -f rgb
bind = ALT, C, exec, hyprpicker -a -f hsl
```

Sources
[1] hyprpicker https://wiki.hypr.land/Hypr-Ecosystem/hyprpicker/
[2] Sip color picker for Hyprland https://www.reddit.com/r/hyprland/comments/1iziy03/sip_color_picker_for_hyprland/
[3] Color pickers https://wiki.hypr.land/Useful-Utilities/Color-Pickers/
[4] hyprwm/hyprpicker: A wlroots-compatible Wayland color ... https://github.com/hyprwm/hyprpicker
[5] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[6] Fuzzel Colour Picker https://wimpysworld.com/posts/fuzzel-hyprpicker/
[7] 3217 Hyprland - hyprpicker - look up colors and change them https://www.youtube.com/watch?v=U3VwvbM8SEA
[8] Here's How You Can Customize Linux Desktop ... https://itsfoss.com/hyprland-halloween-customization/
[9] x11/hyprpicker: Color picker and magnifier for Wayland https://www.freshports.org/x11/hyprpicker
[10] hyprpicker/README.md at v0.4.0 https://code.hyprland.org/hyprwm/hyprpicker/src/tag/v0.4.0/README.md?display=source

## Hyprcursor (Cursor Themes)

Hyprcursor is Hyprland's native cursor theme system providing GPU-accelerated cursor rendering with superior Wayland support compared to legacy XCursor. It enables fast cursor switching, animations, and consistent rendering across applications.[1][2]

### Architecture and Advantages

Hyprcursor is Wayland-native, avoiding X11 compatibility layers and providing **server-side cursor rendering** directly by the compositor. This contrasts with XCursor where applications render cursors independently, causing inconsistency and lag. Hyprcursor themes load into GPU memory, enabling instant switching without reloading.[2][1]

### Installation and Theme Directories

Install cursor themes in user directories to avoid permission issues:[1][2]
```
~/.local/share/icons/
~/.icons/
```


Do not use `/usr/share/icons` for user-installed themes—system-wide themes should be installed by package managers.[1][2]

### Setting Hyprcursor Theme and Size

Configure in `hyprland.conf` using environment variables:[2][1]
```
env = HYPRCURSOR_THEME,Bibata-Modern-Classic
env = HYPRCURSOR_SIZE,24
```


**HYPRCURSOR_THEME** specifies the theme name (directory name in `~/.local/share/icons/`). **HYPRCURSOR_SIZE** sets cursor size in pixels; use power-of-two values (12, 24, 48, etc.) to avoid scaling artifacts. Hyprcursor automatically scales by compositor zoom factor.[2][1]

### Runtime Cursor Switching

Change cursors without restarting using `hyprctl setcursor`:[1][2]
```bash
hyprctl setcursor Bibata-Modern-Classic 24
```


This immediately applies the new theme and size to all windows.[1][2]

### Available Hyprcursor Themes

Popular hypercursor themes include:[2][1]
- **Bibata-Modern-Classic** - Modern, smooth cursors
- **Bibata-Original-Classic** - Original Bibata design
- **Pointer-Catppuccin** - Catppuccin color scheme
- **macOS** - macOS-style cursors
- **Adwaita** - GNOME Adwaita theme
- **Breeze** - KDE Breeze theme

[1][2]

Install themes with package managers or manually extract to `~/.local/share/icons/`.[2][1]

### Application Support for Hyprcursor

**Full Support:**
- Qt5, Qt6 applications
- Chromium, Electron
- Hyprland ecosystem (waybar, wofi, etc.)
- Most Wayland-native applications

[1][2]

**Limited/No Support:**
- GTK applications (fall back to XCursor)
- Some legacy X11 applications under XWayland

[2][1]

### XCursor Fallback Configuration

For applications not supporting hypercursor, configure XCursor as fallback:[3][1]
```
env = XCURSOR_THEME,Adwaita
env = XCURSOR_SIZE,24
```


GTK applications specifically require additional configuration:[3][1]
```
gsettings set org.gnome.desktop.interface cursor-theme 'ThemeName'
gsettings set org.gnome.desktop.interface cursor-size 24
```


If `gsettings` is unavailable (NixOS, minimal systems), use `dconf`:[1]
```bash
dconf write /org/gnome/desktop/interface/cursor-theme \"'ThemeName'\"
dconf write /org/gnome/desktop/interface/cursor-size 24
```


### Multi-Framework Cursor Configuration

For comprehensive cursor consistency across all applications:[3]

**~/.config/hyprland.conf:**
```
env = XCURSOR_THEME,ThemeName
env = XCURSOR_SIZE,24
env = HYPRCURSOR_THEME,ThemeName
env = HYPRCURSOR_SIZE,24
```


**~/.config/gtk-3.0/settings.ini and ~/.config/gtk-4.0/settings.ini:**
```
gtk-cursor-theme-name=ThemeName
gtk-cursor-theme-size=24
```


**~/.icons/default/index.theme:**
```
[Icon Theme]
Inherits=ThemeName
```


**Qt5/Qt6:** Use `qt5ct` and `qt6ct` GUI tools or set environment variables:[3]
```
env = QT_QPA_PLATFORMTHEME,qt5ct
```


**~/.config/xsettingsd/xsettingsd.conf:**
```
Gtk/CursorThemeName "ThemeName"
Gtk/CursorThemeSize 24
```


### HiDPI Scaling Considerations

On HiDPI displays with fractional scaling (e.g., 1.5x):[4][3]

**Hypercursor:** Set size without multiplying by scale (hypercursor handles scaling automatically):[4][1]
```
env = HYPRCURSOR_SIZE,24
```


**XCursor:** Multiply size by scale factor for displays other than hypercursor users:[4][3]
```
env = XCURSOR_SIZE,36  # 24 × 1.5 for 1.5x scaling
```


### Flatpak Application Support

Flatpak applications require additional filesystem permissions to access cursor themes:[1]
```bash
flatpak override --filesystem=~/.icons:ro --filesystem=~/.local/share/icons:ro --user
```


Copy cursor themes to both locations:[1]
```bash
cp -r ~/.icons/ThemeName ~/.local/share/icons/
```


### Creating Custom Hypercursor Themes

Hypercursor themes are directory-based with specific structure. Modify existing themes by copying and customizing cursor files in the theme directory.[2][1]

Documentation available at official Hypercursor repositories for theme development.[1]

### Cursor Animation

Some hypercursor themes support animated cursors for loading, waiting, and other states. Animation occurs at the compositor level without application overhead.[2][1]

### Example Comprehensive Cursor Configuration

```
# Hypercursor (primary)
env = HYPRCURSOR_THEME,Bibata-Modern-Classic
env = HYPRCURSOR_SIZE,24

# XCursor fallback
env = XCURSOR_THEME,Adwaita
env = XCURSOR_SIZE,24

# Qt configuration
env = QT_QPA_PLATFORMTHEME,qt5ct

# Runtime switching keybind
bind = SUPER+SHIFT, C, exec, hyprctl setcursor Bibata-Modern-Classic 24 && notify-send "Cursor theme changed"
```


### Troubleshooting

**Cursor not changing:** Verify theme name matches directory in `~/.local/share/icons/`; check with `ls ~/.local/share/icons/`. Restart Hyprland if environment variables changed in config.[1]

**GTK applications show XCursor:** GTK falls back to XCursor; ensure GTK cursor settings match hypercursor configuration. Use `gsettings` or `dconf` to configure GTK specifically.[3][1]

**Permission denied:** Ensure icons directory is readable: `chmod 755 ~/.local/share/icons/ThemeName`.[1]

**Flatpak cursors missing:** Add filesystem permissions and copy themes to both standard and Flatpak directories.[1]

Sources
[1] hyprcursor https://wiki.hypr.land/Hypr-Ecosystem/hyprcursor/
[2] Hyprcursor https://wiki.hypr.land/hyprland-wiki/pages/Hypr-Ecosystem/hyprcursor/
[3] Inconsistent cursor themes on GTK apps / Applications & ... https://bbs.archlinux.org/viewtopic.php?id=292763
[4] Cursor size with HiDPi · Issue #2448 · hyprwm/Hyprland https://github.com/hyprwm/Hyprland/issues/2448

## Hyprsunset (Blue Light Filter)

Hyprsunset is Hyprland's native blue light filter daemon providing automatic color temperature adjustment based on time of day or manual control. It reduces eye strain during evening use by shifting display colors toward warmer tones.[1][2]

### Installation and Startup

Install Hyprsunset on Arch Linux with `sudo pacman -S hyprsunset`. Start automatically on Hyprland launch by adding to `hyprland.conf`:[1]
```
exec-once = hyprsunset
```


### Configuration File

Hyprsunset uses `~/.config/hyprsunset/hyprsunset.conf` for configuration, though it can operate with sensible defaults without explicit configuration.[2][1]

### Basic Configuration

Create `~/.config/hyprsunset/hyprsunset.conf` with time-based temperature settings:[1]
```
general {
  temp_day = 6500
  temp_night = 3500
  sunrise = 6:00
  sunset = 18:00
}
```


**temp_day** sets daytime color temperature in Kelvin (default 6500K, neutral white). **temp_night** sets nighttime temperature (default 3500K, warm orange). **sunrise** specifies sunrise time for temperature transition (default 6:00 AM). **sunset** specifies sunset time (default 6:00 PM).[1]

### Temperature Adjustment

Adjust temperature manually at runtime using keybinds with the `hyprsunset-util` command:[1]
```
bind = , XF86MonBrightnessUp, exec, hyprsunset-util -t +100
bind = , XF86MonBrightnessDown, exec, hyprsunset-util -t -100
```


This increases/decreases color temperature by 100K on media keys.[1]

### Toggle and Reset

Enable/disable the filter with keybinds:[1]
```
bind = SUPER, B, exec, hyprsunset-util -t 6500  # Reset to day temperature
bind = SUPER+SHIFT, B, exec, hyprsunset-util -t 3500  # Force night temperature
```


Toggle between enabled/disabled states:[1]
```
bind = SUPER, N, exec, hyprsunset-util -toggle
```


### Specific Temperature Setting

Set exact temperature:[1]
```
bind = , XF86Sleep, exec, hyprsunset-util -t 2700
```


This sets an extremely warm tone (2700K) useful for very late-night use.[1]

### Geolocation-Based Sunrise/Sunset

Hyprsunset can determine sunrise/sunset times based on geographic location. Configure in hyprsunset.conf:[1]
```
general {
  latitude = 40.7128
  longitude = -74.0060
}
```


This automatically calculates sunrise/sunset for New York City coordinates. Locate your coordinates using online tools or `curl -s "https://ipinfo.io/loc"`.[1]

### Per-Monitor Configuration

Apply different temperatures to multiple monitors:[1]
```
monitor {
  name = DP-1
  temp_day = 6500
  temp_night = 3500
}

monitor {
  name = HDMI-1
  temp_day = 5500
  temp_night = 2700
}
```


### Transition Speed

Configure smooth temperature transitions with `transition_speed`:[1]
```
general {
  transition_speed = 2
}
```


Higher values transition faster; lower values provide gradual changes.[1]

### Disabling Hyprsunset

Temporarily disable without stopping the daemon:[1]
```
hyprsunset-util -off
hyprsunset-util -on
```


Permanently disable by removing `exec-once = hyprsunset` from `hyprland.conf` and restarting.[1]

### Integration with Other Tools

Combine with other Hyprland utilities for comprehensive eye care:[1]
```
# Autostart everything
exec-once = hypridle
exec-once = hyprsunset
exec-once = dunst  # Notifications

# Keybinds
bind = SUPER, B, exec, hyprsunset-util -t 3500  # Enable night mode
bind = SUPER+SHIFT, B, exec, hyprsunset-util -t 6500  # Enable day mode
bind = ALT, B, exec, hyprsunset-util -toggle  # Toggle
```


### Typical Temperature Values

**6500K (Day):** Neutral white, full brightness, suitable for daytime use[1]
**5500K (Afternoon):** Slightly warmer, transitional temperature[1]
**4000K (Evening):** Warm, reducing eye strain[1]
**3500K (Night):** Orange-warm, significant blue light reduction[1]
**2700K (Late Night):** Very warm, maximum eye comfort[1]

### Troubleshooting

**Filter not applying:** Verify Hyprsunset is running with `systemctl --user status hyprsunset` or `pgrep hyprsunset`. Check configuration syntax in hyprsunset.conf.[1]

**Temperature not changing at scheduled times:** Verify system time is correct with `date`. Ensure sunrise/sunset times match your timezone.[1]

**Monitor-specific temperatures not working:** Verify monitor names match output from `hyprctl monitors`. Use exact names including port identifiers.[1]

**Hyprsunset conflicts with other tools:** Disable other color temperature tools (f.lux, Redshift) to avoid conflicts.[1]

### Example Comprehensive Hyprsunset Configuration

```
general {
  temp_day = 6500
  temp_night = 3500
  sunrise = 6:00
  sunset = 18:00
  transition_speed = 2
  latitude = 40.7128
  longitude = -74.0060
}

monitor {
  name = DP-1
  temp_day = 6500
  temp_night = 3500
}

monitor {
  name = HDMI-1
  temp_day = 5500
  temp_night = 2700
}
```


Add to `hyprland.conf`:
```
exec-once = hyprsunset

# Temperature adjustment keybinds
bind = , XF86MonBrightnessUp, exec, hyprsunset-util -t +100
bind = , XF86MonBrightnessDown, exec, hyprsunset-util -t -100

# Manual mode keybinds
bind = SUPER, B, exec, hyprsunset-util -t 6500
bind = SUPER+SHIFT, B, exec, hyprsunset-util -t 3500
bind = ALT, B, exec, hyprsunset-util -toggle
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Hyprpolkitagent (Authentication)

Hyprpolkitagent is Hyprland's native polkit authentication agent providing graphical password prompts for privileged operations. It replaces generic polkit agents with a compositor-integrated solution supporting Wayland natively.[1][2]

### Purpose and Function

Polkit (PolicyKit) is a system authorization framework allowing users to perform privileged actions without root login. When an application requests elevated privileges (e.g., mounting drives, installing packages, changing system settings), polkit requires authentication through an agent. Hyprpolkitagent provides the Hyprland-specific authentication UI.[2][1]

### Installation

Install on Arch Linux with `sudo pacman -S hyprpolkitagent-hyprland`. The package provides both the agent and integration with Hyprland.[1]

### Automatic Startup

Start the agent automatically on Hyprland launch by adding to `hyprland.conf`:[1]
```
exec-once = /usr/lib/hyprpolkitagent-hyprland
```


The absolute path ensures reliable execution; verify the correct path with `which hyprpolkitagent-hyprland` or `find /usr -name hyprpolkitagent-hyprland`.[1]

### Alternative Polkit Agents

If Hyprpolkitagent is unavailable or incompatible, alternatives provide authentication:[2][1]

**KDE Polkit Agent:**
```
exec-once = /usr/lib/polkit-kde-authentication-agent-1
```


Works well with Hyprland and displays authentication prompts as native GUI windows.[1]

**GNOME Polkit Agent:**
```
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
```


Compatible but may not integrate as smoothly with Hyprland.[1]

**Plain Polkit Agent (minimal):**
```
exec-once = lxpolkit
```


Lightweight alternative; may not provide visual feedback.[1]

### Configuration

Hyprpolkitagent typically requires no additional configuration beyond startup. It automatically handles authentication prompts based on system polkit rules.[2][1]

System polkit policies reside in:[1]
- `/usr/share/polkit-1/actions/` - System policies
- `~/.local/share/polkit-1/actions/` - User policies (rarely needed)

Modify policies to change authentication requirements for specific actions.[1]

### Visual Customization

Hyprpolkitagent respects Hyprland theming and desktop environment settings. Authentication prompts appear as native Wayland windows matching the compositor's decoration style.[1]

Customize appearance through environment variables or configuration if the agent supports them (check documentation).[1]

### Usage Examples

**Mounting drives:**
```bash
udisksctl mount -b /dev/sdX1
```


Polkit prompts for password via Hyprpolkitagent.[1]

**Installing packages:**
```bash
sudo pacman -S package
```


Traditional sudo (doesn't use polkit); Hyprpolkitagent not required.[1]

**System settings requiring elevated privileges:**
Opening system settings that require authorization triggers Hyprpolkitagent.[1]

**Flatpak authorization:**
Some Flatpak applications require polkit authentication for system access.[1]

### Troubleshooting

**Authentication prompts not appearing:** Verify Hyprpolkitagent is running:[1]
```bash
pgrep -a hyprpolkitagent
```


If not running, check `hyprland.conf` for correct exec-once line and restart Hyprland.[1]

**Wrong password accepted:** Polkit agent issue; verify system authentication works with `su` or `sudo`.[1]

**Agent crashes on authentication:** Use alternative polkit agent (KDE or GNOME).[1]

**Missing authentication prompts in Flatpak apps:** Ensure Flatpak has access to `DBUS_SYSTEM_BUS_ADDRESS` environment variable. Set in `hyprland.conf`:[1]
```
env = DBUS_SYSTEM_BUS_ADDRESS,unix:path=/run/dbus/system_bus_socket
```


### Example Session Configuration

Comprehensive authentication setup for Hyprland:[1]

```
# D-Bus environment (required for polkit)
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# D-Bus system bus address (for Flatpak)
env = DBUS_SYSTEM_BUS_ADDRESS,unix:path=/run/dbus/system_bus_socket

# Polkit authentication agent
exec-once = /usr/lib/hyprpolkitagent-hyprland

# Or use KDE alternative if Hyprpolkitagent unavailable
# exec-once = /usr/lib/polkit-kde-authentication-agent-1
```


### Integration with systemd User Services

Polkit can trigger systemd user services requiring authentication. Example service requesting elevated privileges:[1]

**~/.config/systemd/user/backup.service:**
```
[Unit]
Description=System Backup
RequiresMountsFor=/backup

[Service]
Type=oneshot
ExecStart=/usr/bin/rsync -av / /backup
PolicyPolicyKit=yes
```


Hyprpolkitagent prompts for password when service is started.[1]

### Security Considerations

**Timeout:** Authentication prompts timeout after period of inactivity to prevent locked screens.[1]

**Session security:** Hyprpolkitagent operates within the user's Wayland session; compromised user account bypasses authentication.[1]

**Privilege escalation:** Polkit prevents privilege escalation; Hyprpolkitagent merely provides UI for authentication.[1]

### Example Comprehensive Configuration

```
# Authentication and D-Bus
exec-once = dbus-update-activation-environment --systemd DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = /usr/lib/hyprpolkitagent-hyprland

# D-Bus environment for system operations
env = DBUS_SYSTEM_BUS_ADDRESS,unix:path=/run/dbus/system_bus_socket

# Alternative agent (if Hyprpolkitagent unavailable)
# exec-once = /usr/lib/polkit-kde-authentication-agent-1
```


Hyprpolkitagent handles all privileged operations transparently once running.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/


# External Tools Integration

## Status Bars (Waybar)

Waybar is the primary Wayland-native status bar for Hyprland, providing system information, application launchers, workspace indicators, and customizable modules. It replaces X11-based status bars with modern Wayland support and deep Hyprland integration.[1][2]

### Installation

Install Waybar on Arch Linux with `sudo pacman -S waybar`. Start automatically on Hyprland launch:[1]
```
exec-once = waybar
```


### Configuration Files

Waybar uses two configuration files in `~/.config/waybar/`:[1]

**config** - Layout and module definitions[1]
**style.css** - Styling and appearance[1]

Create these files with custom configurations.[1]

### Basic Configuration Structure

**~/.config/waybar/config:**
```json
{
  "layer": "top",
  "position": "top",
  "height": 30,
  "modules-left": ["hyprland/workspaces", "hyprland/window"],
  "modules-center": ["clock"],
  "modules-right": ["pulseaudio", "network", "battery"],
  "hyprland/workspaces": {
    "format": "{name}",
    "on-click": "activate"
  },
  "clock": {
    "format": "{:%H:%M}",
    "timezone": "America/New_York"
  },
  "pulseaudio": {
    "format": "🔊 {volume}%",
    "on-click": "pavucontrol"
  }
}
```


**layer** sets stacking order (`top`, `overlay`, `bottom`); `top` places waybar above windows. **position** places bar at screen edge: `top`, `bottom`, `left`, `right` (default `top`). **height** sets bar height in pixels. **modules-left/center/right** define module placement.[1]

### Essential Modules

**hyprland/workspaces** - Workspace indicator and switcher:[1]
```json
"hyprland/workspaces": {
  "format": "{name}",
  "on-click": "activate",
  "sort-by-number": true,
  "active-only": false
}
```


**hyprland/window** - Current focused window title:[1]
```json
"hyprland/window": {
  "format": "{}",
  "max-length": 50
}
```


**clock** - Date and time display:[1]
```json
"clock": {
  "format": "{:%A, %B %d   %H:%M}",
  "timezone": "UTC"
}
```


**pulseaudio** - Volume control:[1]
```json
"pulseaudio": {
  "format": "🔊 {volume}%",
  "format-muted": "🔇 Muted",
  "on-click": "pavucontrol",
  "on-scroll-up": "pactl set-sink-volume @DEFAULT_SINK@ +5%",
  "on-scroll-down": "pactl set-sink-volume @DEFAULT_SINK@ -5%"
}
```


**network** - Network status:[1]
```json
"network": {
  "format-wifi": "📶 {essid}",
  "format-ethernet": "🌐 Ethernet",
  "format-disconnected": "❌ Disconnected"
}
```


**battery** - Battery status:[1]
```json
"battery": {
  "format": "🔋 {capacity}%",
  "states": {
    "warning": 30,
    "critical": 15
  }
}
```


**backlight** - Display brightness:[1]
```json
"backlight": {
  "format": "☀️ {percent}%",
  "on-scroll-up": "brightnessctl set +5%",
  "on-scroll-down": "brightnessctl set 5%-"
}
```


**tray** - System tray:[1]
```json
"tray": {
  "icon-size": 21,
  "spacing": 10
}
```


### Styling with CSS

**~/.config/waybar/style.css:**
```css
* {
  font-family: monospace;
  font-size: 12px;
  color: #ffffff;
}

window {
  background-color: #1e1e2e;
  border-bottom: 3px solid #45475a;
}

#workspaces button {
  padding: 0 5px;
  background-color: #313244;
  border-radius: 5px;
  margin: 0 3px;
}

#workspaces button.active {
  background-color: #89b4fa;
  color: #000000;
}

#window {
  padding: 0 10px;
  margin-left: 10px;
}

#clock {
  padding: 0 10px;
}

#pulseaudio {
  padding: 0 10px;
  color: #89dceb;
}

#network {
  padding: 0 10px;
  color: #a6e3a1;
}

#battery {
  padding: 0 10px;
  color: #f38ba8;
}
```


### Advanced Module: Custom Scripts

Execute custom scripts as waybar modules:[1]
```json
"custom/weather": {
  "exec": "~/.config/waybar/scripts/weather.sh",
  "interval": 300,
  "format": "🌤️ {}"
}
```


Create `~/.config/waybar/scripts/weather.sh`:[1]
```bash
#!/bin/bash
curl -s "https://wttr.in/?format=3" | cut -d' ' -f1-2
```


### Hyprland Integration

Waybar natively supports Hyprland-specific modules:[1]

**Workspace management:**
```json
"hyprland/workspaces": {
  "format": "{name}",
  "on-click": "activate",
  "persistent-workspaces": {
    "DP-1": [1, 2, 3],
    "HDMI-1": [4, 5, 6]
  }
}
```


This creates persistent workspace configuration per monitor.[1]

### Reload and Update

Restart Waybar after config changes:[1]
```
bind = SUPER+SHIFT, W, exec, killall waybar; waybar
```


Or reload during session:[1]
```bash
killall -SIGUSR2 waybar
```


### Alternative Status Bars

**Eww (ElKowars wacky widgets):**
```
exec-once = eww daemon && eww open bar
```


Highly customizable, minimal overhead; steeper learning curve.[1]

**Polybar:**
```
exec-once = polybar main
```


X11-centric; works under XWayland but not ideal.[1]

**Yambar:**
```
exec-once = yambar
```


Lightweight alternative; limited Hyprland integration.[1]

### Example Comprehensive Waybar Configuration

```json
{
  "layer": "top",
  "position": "top",
  "height": 30,
  "modules-left": ["hyprland/workspaces", "hyprland/window"],
  "modules-center": ["clock"],
  "modules-right": ["pulseaudio", "backlight", "network", "battery", "tray"],
  
  "hyprland/workspaces": {
    "format": "{name}",
    "on-click": "activate",
    "sort-by-number": true
  },
  
  "hyprland/window": {
    "format": "{}",
    "max-length": 50
  },
  
  "clock": {
    "format": "{:%A, %B %d   %H:%M}",
    "timezone": "UTC"
  },
  
  "pulseaudio": {
    "format": "🔊 {volume}%",
    "format-muted": "🔇",
    "on-click": "pavucontrol",
    "on-scroll-up": "pactl set-sink-volume @DEFAULT_SINK@ +5%",
    "on-scroll-down": "pactl set-sink-volume @DEFAULT_SINK@ -5%"
  },
  
  "backlight": {
    "format": "☀️ {percent}%",
    "on-scroll-up": "brightnessctl set +5%",
    "on-scroll-down": "brightnessctl set 5%-"
  },
  
  "network": {
    "format-wifi": "📶 {essid}",
    "format-ethernet": "🌐",
    "format-disconnected": "❌"
  },
  
  "battery": {
    "format": "🔋 {capacity}%",
    "states": {
      "warning": 30,
      "critical": 15
    }
  },
  
  "tray": {
    "icon-size": 21,
    "spacing": 10
  }
}
```


Add corresponding CSS styling in `~/.config/waybar/style.css`.[1]

Add to `hyprland.conf`:
```
exec-once = waybar
bind = SUPER+SHIFT, W, exec, killall waybar; waybar
```

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Application Launchers (Wofi/Rofi)

Application launchers provide quick access to installed programs through keyboard shortcuts and search interfaces. Wofi is Wayland-native and recommended for Hyprland, while Rofi works through XWayland compatibility.[1][2]

### Wofi (Wayland-Native)

**Wofi** is the recommended launcher for Hyprland, built specifically for Wayland with full compatibility. Install on Arch Linux with `sudo pacman -S wofi`.[2][1]

Launch with keybind in `hyprland.conf`:[1]
```
bind = SUPER, D, exec, wofi --show drun
```


This opens the app launcher showing installed applications.[1]

### Wofi Configuration

Create `~/.config/wofi/config` for customization:[1]
```
width=600
height=600
location=top_left
show=drun
allow_images=true
image_size=32
insensitive=true
```


**width/height** - Window dimensions in pixels. **location** - Window position: `top_left`, `top_center`, `top_right`, `center`, `bottom_left`, etc.. **show** - Mode: `drun` (applications), `run` (commands). **allow_images** - Display application icons (default true). **image_size** - Icon size in pixels. **insensitive** - Case-insensitive search (default false).[1]

### Wofi Styling

Create `~/.config/wofi/style.css`:[1]
```css
window {
  background-color: #1e1e2e;
  border: 2px solid #45475a;
  border-radius: 8px;
}

#input {
  background-color: #313244;
  color: #cdd6f4;
  padding: 10px;
  border-radius: 4px;
}

#entry {
  padding: 5px;
}

#entry:selected {
  background-color: #89b4fa;
  color: #000000;
}
```


### Rofi (X11-Based Alternative)

**Rofi** works with Hyprland through XWayland but is not native Wayland. Install with `sudo pacman -S rofi`.[2][1]

Launch with keybind:[1]
```
bind = SUPER, D, exec, rofi -show drun -theme ~/.config/rofi/theme.rasi
```


### Rofi Configuration

Create `~/.config/rofi/config.rasi`:[1]
```
configuration {
  modes: "drun,run,window";
  font: "monospace 12";
  width: 50%;
  lines: 15;
  columns: 1;
  location: center;
  window-format: "{w}   {c}   {t}";
  matching: "fuzzy";
}

@theme "~/.config/rofi/theme.rasi"
```


### Rofi Theming

Create `~/.config/rofi/theme.rasi`:[1]
```
* {
  bg0: #1e1e2e;
  fg0: #cdd6f4;
  accent: #89b4fa;
}

window {
  background-color: @bg0;
  border: 2px solid @accent;
  border-radius: 8px;
}

mainbox {
  children: [inputbar, listview];
}

inputbar {
  background-color: #313244;
  padding: 10px;
  children: [entry];
}

entry {
  text-color: @fg0;
  placeholder: "Search applications...";
}

listview {
  lines: 12;
  columns: 1;
}

element {
  padding: 8px;
}

element selected {
  background-color: @accent;
  text-color: @bg0;
  border-radius: 4px;
}
```


### Launcher Modes

**drun** - Launch desktop applications from `.desktop` files:[1]
```
bind = SUPER, D, exec, wofi --show drun
```


**run** - Execute arbitrary shell commands:[1]
```
bind = SUPER+SHIFT, D, exec, wofi --show run
```


**window** (Rofi only) - Switch between open windows:[1]
```
bind = ALT, Tab, exec, rofi -show window
```


### Window Switcher with Wofi

Use `wmctrl` with Wofi for window switching:[1]
```bash
wofi --show window
```


Not native; requires additional setup.[1]

### Custom Launchers

Create custom launcher scripts for specific workflows:[1]

**~/.config/wofi/scripts/launcher.sh:**
```bash
#!/bin/bash
CHOICE=$(cat << EOF | wofi --dmenu --prompt "Launch"
Firefox
Discord
Code
Terminal
EOF
)

case $CHOICE in
  Firefox) firefox ;;
  Discord) discord ;;
  Code) code ;;
  Terminal) kitty ;;
esac
```


Bind to keybind:[1]
```
bind = SUPER, D, exec, ~/.config/wofi/scripts/launcher.sh
```


### Quick Search Integration

Combine launcher with web searches:[1]
```bash
wofi --show drun --lines 5 | xargs -I {} bash -c "
  if [[ '{}' == *'search'* ]]; then
    firefox 'https://google.com/search?q=$(echo {} | sed s/search//)' &
  else
    {} &
  fi
"
```


### Comparison: Wofi vs Rofi

| Feature | Wofi | Rofi |
|---|---|---|
| Wayland Native | ✓ Yes | ✗ XWayland |
| Hyprland Optimized | ✓ Yes | ~ Works |
| Performance | Excellent | Good |
| Configuration | Simple | Complex |
| Theming | CSS | .rasi files |
| Window Switching | Plugin | Built-in |
| Customization | Good | Excellent |

[2][1]

### Example Comprehensive Launcher Setup

Add to `hyprland.conf`:
```
# Application launcher
bind = SUPER, D, exec, wofi --show drun
bind = SUPER+SHIFT, D, exec, wofi --show run

# Alternative: Rofi
# bind = SUPER, D, exec, rofi -show drun
# bind = SUPER+SHIFT, D, exec, rofi -show run

# Window switcher
bind = ALT, Tab, exec, wofi --show window
```


Create `~/.config/wofi/config`:
```
width=600
height=600
location=top_center
show=drun
allow_images=true
image_size=32
insensitive=true
filter_rate=100
accept_submission=true
hide_search=false
parse_search=false
```


Create `~/.config/wofi/style.css`:
```css
window {
  background-color: #1e1e2e;
  border: 2px solid #89b4fa;
  border-radius: 8px;
  font-family: monospace;
  font-size: 14px;
}

#input {
  background-color: #313244;
  color: #cdd6f4;
  padding: 10px;
  border-radius: 4px;
  margin: 5px;
}

#entry {
  padding: 8px;
  color: #cdd6f4;
}

#entry:selected {
  background-color: #89b4fa;
  color: #1e1e2e;
  border-radius: 4px;
}
```


Wofi is recommended as the primary launcher for Hyprland due to native Wayland support and seamless integration.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Terminal Emulators

Terminal emulators provide text-based interfaces for shell commands, development, and system administration within Hyprland. Several Wayland-native options offer excellent integration, though X11-based alternatives work through XWayland.[1][2]

### Kitty (Recommended for Hyprland)

**Kitty** is the default terminal in Hyprland, GPU-accelerated with native Wayland support. Install on Arch Linux with `sudo pacman -S kitty`.[2][1]

Launch with keybind:[1]
```
bind = SUPER, RETURN, exec, kitty
```


Configure in `~/.config/kitty/kitty.conf`:[1]
```
font_family monospace
font_size 12
background #1e1e2e
foreground #cdd6f4
cursor #f5e0dc
selection_background #45475a
```


**font_family** - Monospace font (requires installation). **font_size** - Text size in pixels. **background/foreground** - Colors in hex format. **cursor** - Cursor color.[1]

### Alacritty (GPU-Accelerated)

**Alacritty** is a fast, GPU-accelerated terminal with excellent Wayland support. Install with `sudo pacman -S alacritty`.[1]

Launch with keybind:[1]
```
bind = SUPER, T, exec, alacritty
```


Configure in `~/.config/alacritty/alacritty.toml`:[1]
```toml
[window]
opacity = 0.9
padding = { x = 10, y = 10 }

[font]
normal = { family = "Monospace", style = "Regular" }
size = 12

[colors.primary]
background = "#1e1e2e"
foreground = "#cdd6f4"
```


### Foot (Lightweight)

**Foot** is a minimal, fast terminal designed for Wayland. Install with `sudo pacman -S foot`.[1]

Launch with keybind:[1]
```
bind = SUPER, T, exec, foot
```


Configure in `~/.config/foot/foot.ini`:[1]
```
[main]
font=monospace:size=12
pad=10x10

[colors]
background=1e1e2e
foreground=cdd6f4
```


### Wezterm (Feature-Rich)

**Wezterm** is a feature-rich terminal with Lua scripting and GPU rendering. Install with `sudo pacman -S wezterm`.[1]

Configure in `~/.config/wezterm/wezterm.lua`:[1]
```lua
local config = wezterm.config_builder()

config.font = wezterm.font("Monospace")
config.font_size = 12.0
config.color_scheme = "Catppuccin Mocha"

config.window_padding = {
  left = "10pt",
  right = "10pt",
  top = "10pt",
  bottom = "10pt",
}

return config
```


### Ghostty (Modern Alternative)

**Ghostty** is a modern terminal emulator with extensive customization. Install from AUR with `yay -S ghostty-bin`.[1]

Configure in `~/.config/ghostty/config`:[1]
```
font-family = monospace
font-size = 12
background = #1e1e2e
foreground = #cdd6f4
```


### Comparison of Terminals

| Terminal | Native Wayland | GPU Accelerated | Configuration | Speed | Hyprland Fit |
|---|---|---|---|---|---|
| Kitty | ✓ Yes | ✓ Yes | Simple | Excellent | ✓ Excellent |
| Alacritty | ✓ Yes | ✓ Yes | TOML | Excellent | ✓ Excellent |
| Foot | ✓ Yes | ✗ No | INI | Good | ✓ Good |
| Wezterm | ✓ Yes | ✓ Yes | Lua | Good | ~ Decent |
| Ghostty | ✓ Yes | ✓ Yes | Custom | Excellent | ✓ Excellent |
| GNOME Terminal | ~ XWayland | ✗ No | GUI | Adequate | ~ Works |
| Xterm | ✗ X11 only | ✗ No | Resources | Slow | ✗ Poor |

[2][1]

### Transparency and Opacity

Most terminals support transparency:[1]

**Kitty:**
```
background_opacity 0.9
```


**Alacritty:**
```toml
[window]
opacity = 0.9
```


**Foot:**
```
alpha=0.9
```


### Font Configuration

Install preferred monospace fonts:[1]
```bash
sudo pacman -S ttf-fira-code ttf-jetbrains-mono ttf-hack noto-fonts
```


Common choices: Fira Code, JetBrains Mono, Hack, Noto Mono.[1]

### Shell Integration

Configure Hyprland to use specific shells within terminals:[1]

**Use Zsh in Kitty:**
```
bind = SUPER, RETURN, exec, kitty -- zsh
```


**Use Fish in Alacritty:**
```
bind = SUPER, T, exec, alacritty -- fish
```


### Terminal Scrollback and History

Configure scrollback buffer for terminal history:[1]

**Kitty:**
```
scrollback_lines 2000
```


**Alacritty:**
```toml
[scrolling]
lines = 2000
```


### Color Schemes

Popular color schemes for terminals:[1]
- **Catppuccin** - Modern, pleasant pastel colors
- **Dracula** - Dark, saturated colors
- **Nord** - Arctic, bluish palette
- **Solarized** - Optimized contrast
- **Gruvbox** - Retro groove colors

Most terminals include theme support; download schemes from community repositories.[1]

### Example Comprehensive Terminal Configuration

Add to `hyprland.conf`:
```
# Primary terminal (Kitty)
bind = SUPER, RETURN, exec, kitty

# Alternative terminals
bind = SUPER+SHIFT, T, exec, alacritty
bind = SUPER+ALT, T, exec, foot

# Terminal with specific shell
bind = SUPER+CTRL, RETURN, exec, kitty -- fish
```


Create `~/.config/kitty/kitty.conf`:
```
font_family JetBrains Mono
font_size 12
background_opacity 0.95
enable_audio_bell no

# Colors (Catppuccin Mocha)
background #1e1e2e
foreground #cdd6f4
selection_background #45475a
cursor #f5e0dc

# Keyboard shortcuts
map ctrl+c copy_to_clipboard
map ctrl+v paste_from_clipboard
```


Kitty is recommended as the primary terminal for Hyprland due to native Wayland support, excellent performance, and tight compositor integration.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## File Managers

File managers provide graphical interfaces for browsing, organizing, and manipulating files within Hyprland. Wayland-native options offer seamless integration, while X11-based managers work through XWayland compatibility.[1][2]

### Thunar (Lightweight GTK)

**Thunar** is a lightweight, feature-rich file manager with minimal dependencies. Install on Arch Linux with `sudo pacman -S thunar`.[1]

Launch with keybind:[1]
```
bind = SUPER, E, exec, thunar
```


Configure in `~/.config/Thunar/thunarrc`:[1]
```ini
[View]
ShowHidden=TRUE
SortFoldersFist=TRUE
DateStyle=ISO
ListViewZoom=THUNAR_ZOOM_LEVEL_100
```


### Nautilus (GNOME Files)

**Nautilus** is the GNOME file manager with modern design and search integration. Install with `sudo pacman -S nautilus`.[1]

Launch with keybind:[1]
```
bind = SUPER, E, exec, nautilus --new-window
```


Modern but heavier than Thunar; includes features like tagging and network browsing.[1]

### Dolphin (KDE Plasma)

**Dolphin** is the KDE file manager with dual-pane support and extensive customization. Install with `sudo pacman -S dolphin`.[1]

Launch with keybind:[1]
```
bind = SUPER, E, exec, dolphin
```


Feature-rich but requires KDE/Qt dependencies.[1]

### PCManFM-Qt (Lightweight)

**PCManFM-Qt** is a minimal file manager using Qt framework. Install with `sudo pacman -S pcmanfm-qt`.[1]

Launch with keybind:[1]
```
bind = SUPER, E, exec, pcmanfm-qt
```


Lightweight alternative to Dolphin with basic functionality.[1]

### Spacefm (Advanced)

**Spacefm** is an advanced, highly customizable file manager with scripting support. Install from AUR with `yay -S spacefm`.[1]

Launch with keybind:[1]
```
bind = SUPER, E, exec, spacefm
```


### Ranger (Terminal-Based)

**Ranger** is a terminal-based file manager for command-line workflows. Install with `sudo pacman -S ranger`.[1]

Launch in terminal:[1]
```
bind = SUPER, E, exec, kitty ranger
```


Keyboard-driven, efficient for developers.[1]

### Nnn (Minimal Terminal)

**Nnn** is an extremely minimal terminal file manager emphasizing speed. Install with `sudo pacman -S nnn`.[1]

Launch in terminal:[1]
```
bind = SUPER, E, exec, foot nnn
```


Lightweight, fast, minimal dependencies.[1]

### File Manager Features Comparison

| Manager | Type | GTK/Qt | Dual-Pane | Tagging | Network | Speed |
|---|---|---|---|---|---|---|
| Thunar | GUI | GTK | ✗ No | ~ Basic | ~ Yes | Excellent |
| Nautilus | GUI | GTK | ✗ No | ✓ Yes | ✓ Yes | Good |
| Dolphin | GUI | Qt | ✓ Yes | ✓ Yes | ✓ Yes | Good |
| PCManFM-Qt | GUI | Qt | ~ Basic | ✗ No | ~ Basic | Excellent |
| Spacefm | GUI | GTK | ✓ Yes | ✓ Yes | ✓ Yes | Good |
| Ranger | TUI | N/A | ✓ Yes | ~ Basic | ✗ No | Excellent |
| Nnn | TUI | N/A | ✓ Yes | ✗ No | ✗ No | Excellent |

[2][1]

### Archiving and Compression

GUI file managers integrate with archive handlers:[1]

Install archive utilities:[1]
```bash
sudo pacman -S xarchiver bzip2 gzip p7zip unrar
```


File managers automatically handle extraction and compression through context menus.[1]

### Custom Actions and Scripts

Create custom context menu actions in Thunar:[1]

**~/.local/share/Thunar/sendto/custom-action.desktop:**
```ini
[Desktop Entry]
Type=Action
Name=Open Terminal Here
Icon=utilities-terminal
Exec=kitty --working-directory %f
MimeTypes=inode/directory;
```


### Thumbnail Support

Enable thumbnail generation for images:[1]

**Thunar:**
```ini
[View]
ShowThumbnails=TRUE
ThumbnailSize=THUNAR_THUMBNAIL_SIZE_128
```


### Trash and Safety

Configure trash functionality instead of permanent deletion:[1]

Most GUI file managers support trash by default; terminal managers require `trash-cli`:[1]
```bash
sudo pacman -S trash-cli
```


Use `trash-put filename` instead of `rm filename`.[1]

### Bookmarks and Quick Access

Create bookmarks for frequently accessed directories:[1]

Most GUI managers support dragging directories to a sidebar. Create manual bookmarks:[1]
```bash
# Thunar
mkdir -p ~/.config/Thunar
echo /home/user/Projects > ~/.config/Thunar/bookmarks
```


### Remote/Network Access

Access remote servers through file managers:[1]

**Via SSH/SFTP:**
Most managers support `sftp://user@host/path` URIs.[1]

**Manual mounting:**
```bash
sudo pacman -S gvfs
# Enables automatic mounting in GUI file managers
```


### Integration with Hyprland

**Preview pane in Ranger:**
Configure image preview in terminal:[1]
```bash
ranger --confdir ~/.config/ranger
```


**File manager as dialog:**
Use file managers for open/save dialogs via XDG Desktop Portal:[1]
```
exec-once = /usr/libexec/xdg-desktop-portal-hyprland
```


### Example Comprehensive File Manager Configuration

Add to `hyprland.conf`:
```
# Primary file manager (Thunar)
bind = SUPER, E, exec, thunar

# Alternative file managers
bind = SUPER+SHIFT, E, exec, nautilus --new-window
bind = SUPER+ALT, E, exec, dolphin

# Terminal file managers
bind = SUPER+CTRL, E, exec, kitty ranger
bind = SUPER+CTRL+ALT, E, exec, foot nnn

# XDG Desktop Portal for file dialogs
exec-once = /usr/libexec/xdg-desktop-portal-hyprland
```


Configure Thunar in `~/.config/Thunar/thunarrc`:
```ini
[View]
ShowHidden=TRUE
SortFoldersFist=TRUE
DateStyle=ISO
ListViewZoom=THUNAR_ZOOM_LEVEL_100

[Misc]
UseTabbed=TRUE
MiscConfirmClose=TRUE
MiscShowAboutDialogs=TRUE
```


Thunar is recommended for Hyprland as a lightweight, feature-complete GUI file manager requiring minimal dependencies.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Notification Daemons (Mako)

Notification daemons display system notifications for events, application alerts, and user feedback within Hyprland. Mako is the recommended Wayland-native notification daemon offering deep integration and minimal overhead.[1][2]

### Mako (Recommended)

**Mako** is a lightweight notification daemon designed specifically for Wayland compositors. Install on Arch Linux with `sudo pacman -S mako`.[2][1]

Start automatically on Hyprland launch:[1]
```
exec-once = mako
```


### Configuration File

Mako uses `~/.config/mako/config` for customization:[1]
```
# Global settings
width=300
height=100
margin=10
padding=10
border-size=2
border-color=#89b4fa
background-color=#1e1e2e
text-color=#cdd6f4
font=monospace 11

# Urgency levels
[urgency=low]
border-color=#a6e3a1
timeout=2000

[urgency=normal]
border-color=#89b4fa
timeout=4000

[urgency=critical]
border-color=#f38ba8
timeout=0
```


**width/height** - Notification dimensions in pixels. **margin** - Space around notifications. **padding** - Internal spacing. **border-size/color** - Border styling. **background-color/text-color** - Colors. **font** - Font family and size.[1]

### Urgency Levels

Configure different behaviors based on notification importance:[1]

**Low urgency (2 second timeout):**
```
[urgency=low]
border-color=#a6e3a1
background-color=#31323400
timeout=2000
```


**Normal urgency (4 second timeout):**
```
[urgency=normal]
border-color=#89b4fa
background-color=#1e1e2e
timeout=4000
```


**Critical urgency (persistent):**
```
[urgency=critical]
border-color=#f38ba8
background-color=#1e1e2e
timeout=0
```


Timeout 0 means notifications persist until manually closed.[1]

### Notification Positioning

**anchor** positions notifications on screen:[1]
```
anchor=top-right
```


Options: `top-left`, `top-center`, `top-right`, `center`, `bottom-left`, `bottom-center`, `bottom-right`.[1]

### Actions and Interactive Elements

Enable action buttons on notifications:[1]
```
[urgency=critical]
actions=true
action-icons=true
```


Applications can define clickable buttons on notifications.[1]

### Icon Support

Display notification icons with icon theme support:[1]

Create `~/.config/mako/icons/` directory for custom icons:[1]
```bash
mkdir -p ~/.config/mako/icons
```


Configure icon theme in `~/.config/mako/config`:[1]
```
icon-path=/usr/share/icons/hicolor
max-icon-size=64
```


### Notification History

View notification history with keybinds:[1]
```
makoctl history pop
```


Bind to retrieve last notification:[1]
```
bind = SUPER, N, exec, makoctl history pop
```


### Dismissing Notifications

Manually close all notifications:[1]
```bash
makoctl dismiss -a
```


Bind for quick dismissal:[1]
```
bind = SUPER+SHIFT, N, exec, makoctl dismiss -a
```


### Testing Notifications

Send test notifications to verify configuration:[1]
```bash
notify-send "Test Notification" "This is a test"
notify-send -u critical "Critical Alert" "Urgent notification"
```


### Alternative Notification Daemons

**Dunst** - Lightweight X11-based daemon (works via XWayland):[1]
```
exec-once = dunst
```


Configure in `~/.config/dunst/dunstrc`.[1]

**SwayNC** - Notification center for Wayland:[1]
```
exec-once = swaync
```


Modern alternative with notification center UI.[1]

### Notification Volume Control

Set notification volume with media keys:[1]
```
bind = , XF86AudioRaiseVolume, exec, notify-send "Volume" "$(pactl get-sink-volume @DEFAULT_SINK@)"
```


### Notification Filtering

Filter notifications by application using `makoctl`:[1]
```bash
# Disable notifications from specific app
makoctl invoke
```


### Integration with Scripts

Send notifications from shell scripts:[1]
```bash
#!/bin/bash
BACKUP_STATUS=$(rsync -avz /source /dest 2>&1)
if [ $? -eq 0 ]; then
  notify-send -u normal "Backup Complete" "Files synchronized successfully"
else
  notify-send -u critical "Backup Failed" "$BACKUP_STATUS"
fi
```


### Example Comprehensive Mako Configuration

Create `~/.config/mako/config`:
```
# Global settings
anchor=top-right
width=300
height=100
margin=10
padding=10
border-size=2
border-radius=8
background-color=#1e1e2e
text-color=#cdd6f4
font=monospace 11
icon-path=/usr/share/icons/hicolor
max-icon-size=64

# Default behavior
progress-color=over #89b4fa
default-timeout=4000

# Low urgency
[urgency=low]
border-color=#a6e3a1
background-color=#1e1e2e
timeout=2000

# Normal urgency
[urgency=normal]
border-color=#89b4fa
background-color=#1e1e2e
timeout=4000

# Critical urgency
[urgency=critical]
border-color=#f38ba8
background-color=#1e1e2e
timeout=0
```


Add to `hyprland.conf`:
```
# Notification daemon
exec-once = mako

# Keybinds
bind = SUPER, N, exec, makoctl history pop
bind = SUPER+SHIFT, N, exec, makoctl dismiss -a
```


Mako is recommended as the primary notification daemon for Hyprland due to native Wayland support, minimal resource usage, and seamless integration.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Clipboard Management

Clipboard management on Wayland requires specialized tools to handle text, images, and clipboard history since Wayland's security model isolates clipboard access. Hyprland supports multiple clipboard solutions for different workflows.[1][2]

### Wl-Clipboard (Core Utility)

**wl-clipboard** is the fundamental clipboard utility for Wayland, providing command-line access to clipboard functions. Install on Arch Linux with `sudo pacman -S wl-clipboard`.[2][1]

Copy to clipboard:[1]
```bash
echo "text" | wl-copy
```


Paste from clipboard:[1]
```bash
wl-paste
```


### Clipboard History with Cliphist

**Cliphist** maintains clipboard history for both text and images. Install with `sudo pacman -S cliphist`.[2][1]

Start clipboard history daemon on Hyprland launch:[1]
```
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
```


The first watches text clipboard changes, the second watches image clipboard changes.[1]

### Accessing Clipboard History

Display history with Rofi/Wofi menu:[1]
```bash
cliphist list | rofi -dmenu | cliphist decode | wl-copy
cliphist list | wofi --dmenu | cliphist decode | wl-copy
```


Bind to keybinds:[1]
```
bind = SUPER, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy
```


This opens a menu showing previous clipboard entries.[1]

### Clearing Clipboard History

Delete all clipboard history:[1]
```bash
cliphist wipe
```


Delete specific entry by selecting in menu:[1]
```bash
cliphist list | wofi --dmenu | cliphist delete
```


### Alternative: Clipse (TUI)

**Clipse** is a terminal-based clipboard manager with simpler functionality. Install from AUR with `yay -S clipse`.[1]

Start daemon:[1]
```
exec-once = clipse
```


Access history in terminal:[1]
```bash
clipse
```


### Clipboard for X11 Applications (XWayland)

Wayland clipboard does not automatically sync with X11 clipboard; XWayland applications require bridge utilities.[1]

Install `xclip` or `xsel` for X11 clipboard access:[1]
```bash
sudo pacman -S xclip xsel
```


XWayland applications can use these utilities directly.[1]

### Integrating wl-clipboard with Shell

Add shell aliases for convenience:[1]
```bash
# ~/.bashrc or ~/.zshrc
alias pbcopy='wl-copy'
alias pbpaste='wl-paste'
```


Enables macOS-style clipboard commands.[1]

### Primary and Clipboard Selections

Wayland supports primary selection (middle-click paste) and clipboard selection:[1]

Copy to primary selection:[1]
```bash
echo "text" | wl-copy -p
```


Paste from primary selection:[1]
```bash
wl-paste -p
```


### Clipboard with Images

Handle image clipboard operations:[1]

Copy image to clipboard:[1]
```bash
wl-copy < image.png
```


Paste image from clipboard:[1]
```bash
wl-paste > image.png
```


View clipboard image types:[1]
```bash
wl-paste --list-types
```


### Script Integration

Use clipboard in shell scripts:[1]
```bash
#!/bin/bash
# Get current date and copy to clipboard
DATE=$(date "+%Y-%m-%d %H:%M:%S")
echo "$DATE" | wl-copy
notify-send "Clipboard" "Date copied: $DATE"
```


Bind to keybinds:[1]
```
bind = SUPER, C, exec, ~/.config/hypr/scripts/clipboard-date.sh
```


### QR Code Clipboard

Generate QR code from clipboard content:[1]
```bash
#!/bin/bash
CONTENT=$(wl-paste)
echo "$CONTENT" | qrencode -o - | wl-copy
notify-send "QR Code" "Generated from clipboard"
```


### Password Manager Integration

Access passwords through clipboard managers like `pass`:[1]
```bash
# Copy password to clipboard with timeout
pass show -c "password/path"
```


Integrate with launcher:[1]
```
bind = SUPER+CTRL, P, exec, pass show -c $(pass ls -1 | wofi --dmenu)
```


### Clipboard Monitoring for Security

Monitor clipboard activity for debugging or security:[1]
```bash
#!/bin/bash
while true; do
  CURRENT=$(wl-paste)
  echo "Clipboard: $CURRENT" >> ~/.local/share/clipboard.log
  sleep 5
done
```


### Example Comprehensive Clipboard Configuration

Add to `hyprland.conf`:
```
# Clipboard history daemon
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store

# Keybinds
bind = SUPER, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy
bind = SUPER+SHIFT, V, exec, cliphist list | wofi --dmenu | cliphist delete
bind = SUPER+CTRL, V, exec, cliphist wipe && notify-send "Clipboard cleared"

# Copy utilities
bind = SUPER, C, exec, date "+%Y-%m-%d %H:%M:%S" | wl-copy && notify-send "Date copied"
bind = SUPER+SHIFT, C, exec, pass show -c $(pass ls -1 | wofi --dmenu)
```


Create `~/.config/hypr/scripts/clipboard-menu.sh`:
```bash
#!/bin/bash
case $1 in
  show)
    cliphist list | wofi --dmenu | cliphist decode | wl-copy
    ;;
  delete)
    cliphist list | wofi --dmenu | cliphist delete
    ;;
  clear)
    cliphist wipe
    notify-send "Clipboard history cleared"
    ;;
esac
```


Cliphist with Wofi provides the most comprehensive Wayland-native clipboard management for Hyprland.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Screenshot Tools

Screenshot and screen recording tools capture display content for sharing, documentation, or recording purposes within Hyprland. Wayland-native options provide seamless compositor integration without X11 compatibility issues.[1][2]

### Grim (Screenshot Utility)

**Grim** is a simple, fast screenshot tool designed for Wayland. Install on Arch Linux with `sudo pacman -S grim`.[2][1]

Capture entire screen:[1]
```bash
grim screenshot.png
```


Capture specific region:[1]
```bash
grim -g "0,0 640x480" screenshot.png
```


Capture specific output/monitor:[1]
```bash
grim -o DP-1 screenshot.png
```


### Slurp (Interactive Selection)

**Slurp** provides interactive region selection for screenshots. Install with `sudo pacman -S slurp`.[2][1]

Select region and capture:[1]
```bash
grim -g "$(slurp)" screenshot.png
```


This opens an interactive selection interface; drag to define capture area.[1]

### Integration: Grim + Slurp + Clipboard

Capture to clipboard directly:[1]
```bash
grim - | wl-copy
```


Capture region to clipboard:[1]
```bash
grim -g "$(slurp)" - | wl-copy
```


### Keybinds for Screenshots

Bind screenshot functions to keybinds in `hyprland.conf`:[1]
```
# Full screenshot to file
bind = , Print, exec, grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png

# Region screenshot to file
bind = SHIFT, Print, exec, grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png

# Full screenshot to clipboard
bind = SUPER, Print, exec, grim - | wl-copy

# Region screenshot to clipboard
bind = SUPER+SHIFT, Print, exec, grim -g "$(slurp)" - | wl-copy
```


### Notification Integration

Notify user after capture:[1]
```bash
grim ~/Pictures/screenshot.png && notify-send "Screenshot saved"
```


Copy to clipboard with notification:[1]
```bash
grim - | wl-copy && notify-send "Screenshot copied to clipboard"
```


### Swappy (Screenshot Editor)

**Swappy** provides screenshot annotation and editing. Install with `sudo pacman -S swappy`.[2][1]

Capture and edit:[1]
```bash
grim - | swappy -f -
```


Draw on screenshots, add text, shapes before saving.[1]

Bind to keybinds:[1]
```
bind = SUPER+SHIFT, S, exec, grim - | swappy -f -
```


### Flameshot (Advanced Screenshots)

**Flameshot** provides GUI-based screenshots with extensive editing. Install with `sudo pacman -S flameshot`.[1]

Launch with keybind:[1]
```
bind = , Print, exec, flameshot gui
```


Flameshot opens interactive selection with annotation tools.[1]

### Screen Recording with Wf-Recorder

**Wf-Recorder** captures screen video for Wayland. Install with `sudo pacman -S wf-recorder`.[2][1]

Record entire screen:[1]
```bash
wf-recorder -o output.mp4
```


Record specific region:[1]
```bash
wf-recorder -g "$(slurp)" -o output.mp4
```


Start recording with keybind:[1]
```
bind = SUPER, R, exec, wf-recorder -o ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4
```


Stop recording (requires separate daemon or keybind to pkill):[1]
```bash
pkill -INT wf-recorder
```


### Screen Recording with OBS Studio

**OBS Studio** provides professional recording with Wayland support via PipeWire. Install with `sudo pacman -S obs-studio`.[1]

Configure PipeWire source:[1]
1. Launch OBS
2. Source → Add → PipeWire Audio/Video Source
3. Configure scene and recording settings

Record with OBS keybind or launcher:[1]
```
bind = SUPER+SHIFT, R, exec, obs --multiprofile=streaming --collection=startup
```


### Screenshot Directory Organization

Create organized screenshot storage:[1]
```bash
mkdir -p ~/Pictures/Screenshots
```


Update capture paths in keybinds:[1]
```
bind = , Print, exec, grim ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png
```


### Automatic Screenshot Naming

Generate descriptive filenames:[1]
```bash
#!/bin/bash
SCREENSHOT_DIR=~/Pictures/Screenshots
FILENAME="$SCREENSHOT_DIR/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
grim -g "$(slurp)" "$FILENAME"
notify-send "Screenshot" "Saved to ${FILENAME##*/}"
```


Save as script and bind to keybinds:[1]
```
bind = SUPER+SHIFT, S, exec, ~/.config/hypr/scripts/screenshot.sh
```


### PipeWire Audio with Recordings

Capture system audio during recording:[1]

**Wf-Recorder with audio:**
```bash
wf-recorder --audio=alsa_output.pci-0000_00_1f.3.analog-stereo -o output.mp4
```


List available audio sources:[1]
```bash
pactl list sources
```


### Example Comprehensive Screenshot Configuration

Add to `hyprland.conf`:
```
# Full screenshot to file
bind = , Print, exec, grim ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send "Screenshot saved"

# Region screenshot to file
bind = SHIFT, Print, exec, grim -g "$(slurp)" ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send "Screenshot saved"

# Full screenshot to clipboard
bind = SUPER, Print, exec, grim - | wl-copy && notify-send "Screenshot copied to clipboard"

# Region screenshot to clipboard
bind = SUPER+SHIFT, Print, exec, grim -g "$(slurp)" - | wl-copy && notify-send "Screenshot copied to clipboard"

# Screenshot with editing (Swappy)
bind = SUPER+CTRL, Print, exec, grim - | swappy -f -

# Screen recording
bind = SUPER, R, exec, wf-recorder -o ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4 && notify-send "Recording started"
bind = SUPER+SHIFT, R, exec, pkill -INT wf-recorder && notify-send "Recording stopped"
```


Create `~/.config/hypr/scripts/screenshot.sh`:
```bash
#!/bin/bash
SCREENSHOT_DIR=~/Pictures/Screenshots
mkdir -p "$SCREENSHOT_DIR"

case $1 in
  full)
    grim "$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
    ;;
  region)
    grim -g "$(slurp)" "$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
    ;;
  clipboard)
    grim - | wl-copy
    ;;
  edit)
    grim - | swappy -f -
    ;;
esac

notify-send "Screenshot" "Saved successfully"
```


Grim and Slurp provide the most efficient Wayland-native screenshot solution for Hyprland with minimal overhead.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Screen Recording

Screen recording captures display content and audio for documentation, tutorials, and content creation on Hyprland. Wayland-native solutions offer compositor-level integration without X11 dependency issues.[1][2]

### Wf-Recorder (Lightweight)

**Wf-Recorder** is a minimal screen recorder designed specifically for Wayland. Install on Arch Linux with `sudo pacman -S wf-recorder`.[2][1]

Record entire screen:[1]
```bash
wf-recorder -o output.mp4
```


Stop recording by pressing Ctrl+C or sending SIGINT.[1]

Record specific region:[1]
```bash
wf-recorder -g "$(slurp)" -o output.mp4
```


Record specific monitor:[1]
```bash
wf-recorder -o DP-1 -o output.mp4
```


### Wf-Recorder with Audio

Capture system audio during recording:[1]

List available audio sources:[1]
```bash
pactl list sources
```


Record with audio:[1]
```bash
wf-recorder --audio=alsa_output.pci-0000_00_1f.3.analog-stereo -o output.mp4
```


Record microphone only:[1]
```bash
wf-recorder --audio=alsa_input.usb-0c0ef00d_USB_Microphone-00.mono-fallback -o output.mp4
```


### Wf-Recorder Codec Options

Change video codec and quality:[1]
```bash
wf-recorder -c h264 -o output.mp4  # H.264 codec
wf-recorder -c vp9 -o output.webm  # VP9 codec (WebM)
```


Adjust bitrate for file size/quality:[1]
```bash
wf-recorder -b 5000k -o output.mp4  # 5000 kbps
wf-recorder -b 10000k -o output.mp4  # 10000 kbps (higher quality)
```


### Keybinds for Recording

Start/stop recording with keybinds:[1]
```
bind = SUPER, R, exec, wf-recorder -o ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4 & echo $! > /tmp/wf-recorder.pid && notify-send "Recording started"

bind = SUPER+SHIFT, R, exec, kill $(cat /tmp/wf-recorder.pid) && notify-send "Recording stopped"
```


### OBS Studio (Professional)

**OBS Studio** provides professional-grade recording with extensive features. Install with `sudo pacman -S obs-studio`.[2][1]

Configure Wayland video source via PipeWire:[1]
1. Launch OBS Studio
2. Settings → Output → Recording
3. Source → Add → PipeWire Audio/Video Source
4. Select monitor and audio source

Record with OBS keybind:[1]
```
bind = SUPER+SHIFT, R, exec, obs --profile=streaming --scene=recording --startrecording
```


### SimpleScreenRecorder (GUI)

**SimpleScreenRecorder** provides graphical recording interface. Install with `sudo pacman -S simplescreenrecorder`.[1]

Launch with keybind:[1]
```
bind = SUPER, R, exec, simplescreenrecorder
```


Select recording region, audio sources, and codec through GUI.[1]

### Screencast Recording with ffmpeg

**ffmpeg** records screen directly from PipeWire:[1]
```bash
ffmpeg -f pipewire -i default -f pulse -i default output.mp4
```


Record with audio and video:[1]
```bash
ffmpeg -f pipewire -framerate 30 -i default -f pulse -i default -c:v h264 -c:a aac output.mp4
```


### Recording Scripts

Create comprehensive recording script:[1]

**~/.config/hypr/scripts/record.sh:**
```bash
#!/bin/bash
RECORDING_DIR=~/Videos
mkdir -p "$RECORDING_DIR"
FILENAME="$RECORDING_DIR/recording-$(date +%Y-%m-%d_%H-%M-%S).mp4"

case $1 in
  start-full)
    wf-recorder -o "$FILENAME" > /tmp/wf-recorder.pid 2>&1 &
    echo $! > /tmp/wf-recorder.pid
    notify-send "Recording" "Full screen recording started"
    ;;
  start-region)
    wf-recorder -g "$(slurp)" -o "$FILENAME" > /tmp/wf-recorder.pid 2>&1 &
    echo $! > /tmp/wf-recorder.pid
    notify-send "Recording" "Region recording started"
    ;;
  start-audio)
    AUDIO=$(pactl list sources | grep -m1 "Name:" | cut -d' ' -f2)
    wf-recorder --audio="$AUDIO" -o "$FILENAME" > /tmp/wf-recorder.pid 2>&1 &
    echo $! > /tmp/wf-recorder.pid
    notify-send "Recording" "Recording with audio started"
    ;;
  stop)
    if [ -f /tmp/wf-recorder.pid ]; then
      kill $(cat /tmp/wf-recorder.pid) 2>/dev/null
      rm /tmp/wf-recorder.pid
      notify-send "Recording" "Recording stopped"
    fi
    ;;
esac
```


Make executable:[1]
```bash
chmod +x ~/.config/hypr/scripts/record.sh
```


### Video Post-Processing

Trim recordings:[1]
```bash
ffmpeg -i input.mp4 -ss 00:00:10 -to 00:01:30 -c copy output.mp4
```


Compress for sharing:[1]
```bash
ffmpeg -i input.mp4 -c:v libx264 -crf 28 output.mp4
```


Convert to WebM:[1]
```bash
ffmpeg -i input.mp4 -c:v libvpx-vp9 -c:a libopus output.webm
```


### Recording Notifications

Show recording status with notifications:[1]
```bash
# During recording
notify-send -t 0 "Recording" "Recording in progress... $(date +%H:%M:%S)"
```


Display recording time periodically:[1]
```bash
while pgrep wf-recorder > /dev/null; do
  DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1:noprint_wrappers=1 /tmp/current-recording.mp4 2>/dev/null || echo "0")
  notify-send -r 9999 "Recording" "Duration: $(date -d@${DURATION%.*} -u +%H:%M:%S)"
  sleep 5
done
```


### Streaming Integration

Stream to platforms like Twitch while recording:[1]

**OBS Studio configuration:**
1. Settings → Stream
2. Service: Twitch
3. Server: Auto
4. Stream Key: From Twitch dashboard

Start streaming and recording simultaneously.[1]

### Example Comprehensive Recording Configuration

Add to `hyprland.conf`:
```
# Simple recording scripts
bind = SUPER, R, exec, ~/.config/hypr/scripts/record.sh start-full
bind = SUPER+SHIFT, R, exec, ~/.config/hypr/scripts/record.sh stop
bind = SUPER+ALT, R, exec, ~/.config/hypr/scripts/record.sh start-region
bind = SUPER+CTRL, R, exec, ~/.config/hypr/scripts/record.sh start-audio

# Direct wf-recorder
bind = SUPER+SHIFT, Print, exec, wf-recorder -g "$(slurp)" -o ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4 & notify-send "Recording region"

# Launch OBS
bind = SUPER+CTRL+R, exec, obs --profile=streaming --startrecording
```


Create `~/.config/hypr/scripts/record.sh` as shown above.[1]

### Best Practices

**File formats:** Use MP4 for compatibility, WebM for web, MOV for editing.[1]

**Codecs:** H.264 for general use, VP9 for web, ProRes for professional editing.[1]

**Audio:** Always record system audio if demonstrating software; use separate microphone for voice-over.[1]

**Storage:** Recordings consume significant disk space; use external drives for large projects.[1]

**Quality vs Size:** Higher bitrate increases file size exponentially; 5000-8000 kbps provides good quality for tutorials.[1]

Wf-recorder provides the most efficient Wayland-native recording for Hyprland with minimal resource overhead.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

# Advanced Configuration

## Hyprctl & IPC

Hyprctl is the command-line interface for interacting with Hyprland, enabling runtime configuration changes, querying compositor state, and triggering dispatchers without reloading the entire session. IPC (Inter-Process Communication) provides programmatic access to Hyprland's state and events.[1][2]

### Hyprctl Basic Usage

Query Hyprland state with `hyprctl`:[1]
```bash
hyprctl monitors        # List connected monitors and their properties
hyprctl clients         # List open windows with details
hyprctl workspaces      # List workspaces and their status
hyprctl dispatch        # Execute dispatchers
hyprctl keyword         # Modify config variables at runtime
```


### Querying Monitors

Display connected monitors with configuration:[1]
```bash
hyprctl monitors
```


Output example:[1]
```
Monitor DP-1 (ID 0)
	1920x1080@144.00 at 0x0
	Description: Dell Inc. DELL S2721DGF
	Active workspace: 1
	Special workspace: (empty)
```


Query specific monitor properties:[1]
```bash
hyprctl monitors all     # Includes disabled monitors
hyprctl monitors -j      # JSON output for scripting
```


### Querying Windows and Clients

List all open windows:[1]
```bash
hyprctl clients
```


Output shows window ID, class, title, and properties.[1]

Get focused window information:[1]
```bash
hyprctl activewindow
```


Query specific client:[1]
```bash
hyprctl clients | grep -A 5 "class: Firefox"
```


### Querying Workspaces

List all workspaces:[1]
```bash
hyprctl workspaces
```


Output includes workspace ID, name, and monitor assignment.[1]

Get active workspace:[1]
```bash
hyprctl activeworkspace
```


### Dispatchers via Hyprctl

Execute window management commands:[1]
```bash
hyprctl dispatch workspace 1      # Switch to workspace 1
hyprctl dispatch movewindow u     # Move window up
hyprctl dispatch togglefloating   # Toggle floating mode
hyprctl dispatch killactive       # Close focused window
```


### Runtime Configuration Changes

Modify variables without reloading config:[1]
```bash
hyprctl keyword general:gaps_in 10
hyprctl keyword general:gaps_out 20
hyprctl keyword decoration:rounding 15
hyprctl keyword input:kb_layout us
```


Changes persist until next reload or config modification.[1]

### JSON Output for Scripting

Query state in JSON format for programmatic access:[1]
```bash
hyprctl monitors -j | jq '.[] | {name: .name, width: .width, height: .height}'
hyprctl workspaces -j | jq '.[] | {id: .id, name: .name, windows: .windows}'
hyprctl clients -j | jq '.[] | {title: .title, class: .class, workspace: .workspace}'
```


### IPC Socket Location

Hyprland creates an IPC socket at:[1]
```
$XDG_RUNTIME_DIR/hyprland/$HYPRLAND_INSTANCE_SIGNATURE
```


Default: `/run/user/1000/hyprland/instance1`.[1]

### Socket-Based IPC Communication

Send commands directly to IPC socket:[1]
```bash
echo "dispatch workspace 2" | socat - UNIX-CONNECT:$XDG_RUNTIME_DIR/hyprland/$HYPRLAND_INSTANCE_SIGNATURE
```


Use `socat` for raw socket communication.[1]

### Scripting with Hyprctl

Create scripts using hyprctl output:[1]

**~/.config/hypr/scripts/window-counter.sh:**
```bash
#!/bin/bash
TOTAL=$(hyprctl clients -j | jq 'length')
echo "Open windows: $TOTAL"
```


Make executable and bind to keybind:[1]
```
bind = SUPER, W, exec, ~/.config/hypr/scripts/window-counter.sh
```


### Monitor-Based Workspace Switching

Script workspace navigation per monitor:[1]
```bash
#!/bin/bash
MONITOR=$(hyprctl activemonitor -j | jq -r '.name')
echo "Active monitor: $MONITOR"
# Implement monitor-specific workspace logic
```


### Conditional Dispatchers

Execute dispatcher based on window properties:[1]
```bash
#!/bin/bash
FOCUSED=$(hyprctl activewindow -j | jq -r '.class')
if [[ $FOCUSED == "firefox" ]]; then
  hyprctl dispatch movetoworkspace 2
else
  hyprctl dispatch movetoworkspace 1
fi
```


### Cursor Position and Pointer

Query mouse cursor position:[1]
```bash
hyprctl cursorpos
```


Output: `1920, 1080`.[1]

### Hyprctl Batch Operations

Execute multiple commands:[1]
```bash
hyprctl dispatch workspace 1
hyprctl dispatch movewindow l
hyprctl dispatch resizewindow exact 800 600
```


Or combine in single call:[1]
```bash
hyprctl --batch "dispatch workspace 1 ; dispatch movewindow l ; dispatch resizewindow exact 800 600"
```


### Event Monitoring with Socat

Monitor Hyprland events in real-time:[1]
```bash
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hyprland/$HYPRLAND_INSTANCE_SIGNATURE
```


Events stream when windows open/close, focus changes, etc..[1]

### Examples: Practical Scripts

**Window Counter Notification:**
```bash
#!/bin/bash
COUNT=$(hyprctl clients -j | jq 'length')
notify-send "Windows" "Currently open: $COUNT"
```


Bind to keybind:[1]
```
bind = SUPER, I, exec, ~/.config/hypr/scripts/window-count.sh
```


**Workspace Info Display:**
```bash
#!/bin/bash
WORKSPACE=$(hyprctl activeworkspace -j | jq '.id')
WINDOWS=$(hyprctl clients -j | jq "map(select(.workspace.id == $WORKSPACE)) | length")
notify-send "Workspace $WORKSPACE" "Contains $WINDOWS windows"
```


**Focus Automation:**
```bash
#!/bin/bash
# Switch to workspace with Firefox if open
WORKSPACE=$(hyprctl clients -j | jq -r '.[] | select(.class == "firefox") | .workspace.id' | head -1)
if [ -n "$WORKSPACE" ]; then
  hyprctl dispatch workspace $WORKSPACE
else
  notify-send "Firefox" "Not running"
fi
```


### Hyprctl Help and Documentation

View all available commands:[1]
```bash
hyprctl help
hyprctl help dispatchers
hyprctl help keywords
```


List all available keywords and dispatchers.[1]

### Example Comprehensive Hyprctl Configuration

Add to `hyprland.conf`:
```
# Keybinds using hyprctl scripts
bind = SUPER, I, exec, ~/.config/hypr/scripts/window-info.sh
bind = SUPER+SHIFT, I, exec, ~/.config/hypr/scripts/workspace-info.sh
bind = ALT, Tab, exec, ~/.config/hypr/scripts/smart-focus.sh

# Runtime config changes
bind = SUPER+CTRL, G, exec, hyprctl keyword general:gaps_in 5 && notify-send "Gaps set to 5"
bind = SUPER+CTRL+SHIFT, G, exec, hyprctl keyword general:gaps_in 0 && notify-send "Gaps disabled"

# Monitor info
bind = SUPER, M, exec, hyprctl monitors | wofi --dmenu --prompt "Monitors"
```


Create `~/.config/hypr/scripts/window-info.sh`:
```bash
#!/bin/bash
hyprctl clients -j | jq -r '.[] | "\(.title) (\(.class))"' | wofi --dmenu --prompt "Windows"
```


Hyprctl enables powerful automation and runtime customization without reloading Hyprland, making it essential for advanced workflows.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Scripting & Automation

Scripting enables advanced automation workflows combining Hyprland features, system utilities, and custom logic for complex tasks. Shell scripts, Lua, and Python provide flexible automation options.[1][2]

### Shell Scripts Fundamentals

Create shell scripts for Hyprland automation in `~/.config/hypr/scripts/`:[1]

**~/.config/hypr/scripts/example.sh:**
```bash
#!/bin/bash
# Example automation script

# Get active workspace
WORKSPACE=$(hyprctl activeworkspace -j | jq '.id')

# Count windows on workspace
WINDOW_COUNT=$(hyprctl clients -j | jq "map(select(.workspace.id == $WORKSPACE)) | length")

# Notify user
notify-send "Workspace $WORKSPACE" "Contains $WINDOW_COUNT windows"
```


Make executable:[1]
```bash
chmod +x ~/.config/hypr/scripts/example.sh
```


### Script Binding to Keybinds

Execute scripts from keybinds:[1]
```
bind = SUPER, E, exec, ~/.config/hypr/scripts/example.sh
```


### Workspace Automation

Auto-organize applications to specific workspaces:[1]

**~/.config/hypr/scripts/organize-workspace.sh:**
```bash
#!/bin/bash
# Move applications to designated workspaces

case $1 in
  "web")
    hyprctl dispatch workspace name:web
    ;;
  "code")
    hyprctl dispatch workspace name:code
    ;;
  "media")
    hyprctl dispatch workspace name:media
    ;;
esac
```


Bind to keybinds:[1]
```
bind = SUPER, 1, exec, ~/.config/hypr/scripts/organize-workspace.sh web
bind = SUPER, 2, exec, ~/.config/hypr/scripts/organize-workspace.sh code
bind = SUPER, 3, exec, ~/.config/hypr/scripts/organize-workspace.sh media
```


### Window Layout Automation

Automatically tile windows in specific layouts:[1]

**~/.config/hypr/scripts/auto-layout.sh:**
```bash
#!/bin/bash
# Arrange windows in custom layout

FOCUSED=$(hyprctl activewindow -j | jq -r '.address')

# Cascade windows
OFFSET=20
WINDOWS=$(hyprctl clients -j | jq -r '.[] | .address')

for WINDOW in $WINDOWS; do
  hyprctl dispatch movewindowpixel $OFFSET $OFFSET address:$WINDOW
  OFFSET=$((OFFSET + 20))
done
```


### Monitor-Based Workspace Switching

Script intelligent workspace navigation across monitors:[1]

**~/.config/hypr/scripts/focus-next-monitor.sh:**
```bash
#!/bin/bash
# Cycle focus to next monitor

CURRENT_MONITOR=$(hyprctl activemonitor -j | jq -r '.name')
MONITORS=$(hyprctl monitors -j | jq -r '.[].name')

# Find next monitor
NEXT=0
for MONITOR in $MONITORS; do
  if [ "$MONITOR" = "$CURRENT_MONITOR" ]; then
    NEXT=1
    continue
  fi
  if [ $NEXT -eq 1 ]; then
    hyprctl dispatch focusmonitor $MONITOR
    return 0
  fi
done

# Wrap to first monitor
FIRST=$(echo "$MONITORS" | head -1)
hyprctl dispatch focusmonitor $FIRST
```


### Conditional Window Operations

Execute different actions based on window properties:[1]

**~/.config/hypr/scripts/smart-move.sh:**
```bash
#!/bin/bash
# Move window intelligently based on class

FOCUSED_CLASS=$(hyprctl activewindow -j | jq -r '.class')

case $FOCUSED_CLASS in
  "firefox"|"chromium")
    hyprctl dispatch movetoworkspace 1
    ;;
  "code"|"nvim")
    hyprctl dispatch movetoworkspace 2
    ;;
  "discord"|"slack")
    hyprctl dispatch movetoworkspace 3
    ;;
  *)
    hyprctl dispatch movetoworkspace 4
    ;;
esac
```


Bind to keybinds:[1]
```
bind = SUPER+M, E, exec, ~/.config/hypr/scripts/smart-move.sh
```


### Time-Based Automation

Execute tasks at specific times:[1]

**~/.config/hypr/scripts/schedule-tasks.sh:**
```bash
#!/bin/bash
# Schedule tasks based on time of day

HOUR=$(date +%H)

if [ $HOUR -lt 12 ]; then
  hyprctl keyword decoration:blur_passes 3  # Light blur morning
elif [ $HOUR -lt 18 ]; then
  hyprctl keyword decoration:blur_passes 2  # Medium blur afternoon
else
  hyprsunset-util -t 3500  # Night mode evening
  hyprctl keyword decoration:blur_passes 1  # Heavy blur night
fi

notify-send "Schedule" "Applied settings for hour $HOUR"
```


Add to autostart with systemd timer:[1]
```
exec-once = watch -n 300 ~/.config/hypr/scripts/schedule-tasks.sh
```


### System Resource Monitoring

Monitor and respond to system state changes:[1]

**~/.config/hypr/scripts/monitor-resources.sh:**
```bash
#!/bin/bash
# Adjust Hyprland based on CPU/memory usage

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
MEM_USAGE=$(free | grep Mem | awk '{print int($3/$2 * 100)}')

if [ $CPU_USAGE -gt 80 ] || [ $MEM_USAGE -gt 80 ]; then
  # Reduce animations and effects under load
  hyprctl keyword animation:enabled false
  hyprctl keyword decoration:blur:enabled false
  notify-send "Performance" "Reduced effects due to high resource usage"
else
  # Restore effects under normal load
  hyprctl keyword animation:enabled true
  hyprctl keyword decoration:blur:enabled true
fi
```


### Workspace Quick Switch

Cycle through workspaces with keybind:[1]

**~/.config/hypr/scripts/cycle-workspace.sh:**
```bash
#!/bin/bash
# Cycle to next/previous workspace

CURRENT=$(hyprctl activeworkspace -j | jq '.id')
TOTAL=$(hyprctl workspaces -j | jq 'max_by(.id) | .id')

if [ "$1" = "next" ]; then
  NEXT=$((CURRENT + 1))
  [ $NEXT -gt $TOTAL ] && NEXT=1
else
  NEXT=$((CURRENT - 1))
  [ $NEXT -lt 1 ] && NEXT=$TOTAL
fi

hyprctl dispatch workspace $NEXT
```


Bind to keybinds:[1]
```
bind = SUPER, Tab, exec, ~/.config/hypr/scripts/cycle-workspace.sh next
bind = SUPER+SHIFT, Tab, exec, ~/.config/hypr/scripts/cycle-workspace.sh prev
```


### Window Stacking Automation

Organize windows in specific stacking orders:[1]

**~/.config/hypr/scripts/stack-windows.sh:**
```bash
#!/bin/bash
# Stack all windows in current workspace

WORKSPACE=$(hyprctl activeworkspace -j | jq '.id')
WINDOWS=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $WORKSPACE) | .address")

for WINDOW in $WINDOWS; do
  hyprctl dispatch movewindow u address:$WINDOW
done

notify-send "Stack" "Windows stacked in current workspace"
```


### Python Scripting

Use Python for complex automation:[1]

**~/.config/hypr/scripts/automation.py:**
```python
#!/usr/bin/env python3
import json
import subprocess
import time

def run_hyprctl(cmd):
    result = subprocess.run(f"hyprctl {cmd}", shell=True, capture_output=True, text=True)
    return result.stdout

def get_active_workspace():
    output = run_hyprctl("activeworkspace -j")
    return json.loads(output)['id']

def get_window_count():
    output = run_hyprctl("clients -j")
    return len(json.loads(output))

def main():
    workspace = get_active_workspace()
    count = get_window_count()
    print(f"Workspace {workspace}: {count} windows")

if __name__ == "__main__":
    main()
```


Make executable and bind:[1]
```bash
chmod +x ~/.config/hypr/scripts/automation.py
```


```
bind = SUPER, P, exec, ~/.config/hypr/scripts/automation.py
```


### Error Handling in Scripts

Implement robust error handling:[1]

**~/.config/hypr/scripts/safe-script.sh:**
```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

trap 'notify-send "Error" "Script failed at line $LINENO"' ERR

# Safe script operations
if hyprctl dispatch workspace 1; then
  notify-send "Success" "Workspace switched"
else
  notify-send "Error" "Failed to switch workspace"
  exit 1
fi
```


### Systemd Service Integration

Create systemd services for persistent automation:[1]

**~/.config/systemd/user/hyprland-automation.service:**
```ini
[Unit]
Description=Hyprland Automation Service
After=graphical-session-pre.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=%h/.config/hypr/scripts/automation-daemon.sh
Restart=on-failure

[Install]
WantedBy=graphical-session.target
```


Enable with:[1]
```bash
systemctl --user enable hyprland-automation.service
```


### Example Comprehensive Automation Configuration

Add to `hyprland.conf`:
```
# Automation scripts
bind = SUPER, A, exec, ~/.config/hypr/scripts/organize-workspace.sh web
bind = SUPER+SHIFT, A, exec, ~/.config/hypr/scripts/smart-move.sh
bind = SUPER, Tab, exec, ~/.config/hypr/scripts/cycle-workspace.sh next
bind = SUPER+SHIFT, Tab, exec, ~/.config/hypr/scripts/cycle-workspace.sh prev

# Time-based automation
exec-once = watch -n 300 ~/.config/hypr/scripts/schedule-tasks.sh
exec-once = watch -n 60 ~/.config/hypr/scripts/monitor-resources.sh

# Systemd service
exec-once = systemctl --user start hyprland-automation.service
```


Comprehensive scripting unlocks Hyprland's full potential for personalized, automated workflows.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Dynamic Configuration Changes

Hyprland enables live adjustment of many settings—such as appearance, input, and behavior—without reloading the compositor or losing your session. These dynamic changes are made using the `hyprctl keyword` command or IPC, providing a flexible environment for rapid workflow adaptation and scripting.[1][2]

### Runtime Variable Changes

Change configuration values instantly using `hyprctl keyword`:
```bash
hyprctl keyword general:gaps_in 6
hyprctl keyword decoration:rounding 12
hyprctl keyword input:kb_layout us
hyprctl keyword decoration:active_opacity 0.92
hyprctl keyword general:border_size 4
```


- The changes apply immediately and remain active until you reload or restart Hyprland.
- You can alter almost any variable that is present in the Hyprland config, including nested and sectioned options using the syntax `section:option`.[1][2]

### Animation, Decorations, and Compositor Effects

Alter how Hyprland looks and feels in real time:
```bash
hyprctl keyword decoration:blur:size 12
hyprctl keyword decoration:blur:enabled false
hyprctl keyword animations:enabled false
hyprctl keyword animations:global_speed 12
```


- Turn animation/blurring on or off to optimize performance for remote sessions or high-load situations.[1]
- Adjust window opacity, border color, or any other supported style for instantly different workspace "moods" or nighttime reading.[1]

### Temporary Tweaks via Scripting

Create scripts to quickly toggle or shift settings:[1]
```bash
#!/bin/bash
# Toggle window borders on/off
BORDER=$(hyprctl getoption general:border_size | grep int: | awk '{print $2}')
if [ "$BORDER" -eq 0 ]; then
  hyprctl keyword general:border_size 2
else
  hyprctl keyword general:border_size 0
fi
```


Bind to a key:
```
bind = SUPER, B, exec, ~/.config/hypr/scripts/toggle-borders.sh
```


### Window, Input, and Monitor Changes

Set focus-follows-mouse, mouse sensitivity, or touchpad properties dynamically:
```bash
hyprctl keyword input:kb_layout de
hyprctl keyword input:follow_mouse 0
hyprctl keyword input:sensitivity 0.56
hyprctl keyword input:touchpad:natural_scroll true
```


You can also change monitor orientation, scale, and workspace locations while running using dispatchers or monitor config keywords:
```bash
hyprctl keyword monitor DP-1,1920x1080,0x0,1,transform,1
hyprctl dispatch workspace name:media
```


### Automated/Time-of-Day Dynamic Changes

Combine with scripting and cron or systemd timers for automatic theme switching, night/day opacity, etc.:[1]
```bash
# At sunset, enable blue light filter and dim windows
hyprsunset-util -t 3500
hyprctl keyword decoration:inactive_opacity 0.7
```


### Resetting to Persistent Values

- Dynamic changes are lost upon `hyprctl reload`, restarting Hyprland, or editing the config file.
- To make settings persist, update them in your `hyprland.conf`.[2][1]

### Example Keybinds for Dynamic Changes

**Light/dark theme toggle:**
```
bind = SUPER, T, exec, hyprctl keyword decoration:active_opacity 1 && hyprctl keyword decoration:inactive_opacity 0.9
bind = SUPER+SHIFT, T, exec, hyprctl keyword decoration:active_opacity 0.85 && hyprctl keyword decoration:inactive_opacity 0.6
```


**Switch blur preset:**
```
bind = SUPER, F2, exec, hyprctl keyword decoration:blur:size 8
bind = SUPER, F3, exec, hyprctl keyword decoration:blur:size 18
```


**Mouse/keyboard language instant switcher:**
```
bind = SUPER, Space, exec, hyprctl keyword input:kb_layout us
bind = SUPER+SHIFT, Space, exec, hyprctl keyword input:kb_layout jp
```


Dynamic configuration changes through `hyprctl` provide on-the-fly workflow optimization, theming, troubleshooting, and accessibility in Hyprland.[2][1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

## Multi-Monitor Setups

Hyprland offers comprehensive, dynamic multi-monitor support with per-monitor configuration, hotplugging, and layout flexibility. Each monitor can have its own resolution, scale, workspace assignment, and more, all configured via the `monitor` keyword or `monitorv2` blocks.[1][2]

### Static Monitor Configuration

Define monitors in `hyprland.conf`:
```
monitor = DP-1, 3440x1440@144, 0x0, 1
monitor = HDMI-1, 1920x1080@60, 3440x0, 1
monitor = eDP-1, preferred, auto, 1
```
- **First field:** Port name (use `hyprctl monitors` to list exact names, e.g., DP-1, HDMI-A-1, eDP-1).[1]
- **Second:** Resolution and optionally refresh rate (e.g., 1920x1080@60, or preferred).[3][1]
- **Third:** Position in virtual layout (e.g., 0x0 for primary/left, 3440x0 to stack right of a 3440px-wide monitor).[1]
- **Fourth:** Scale factor for HiDPI (e.g., 1.25 for 125% scaling).[1]
- **Extra options:** Transform (rotation), mirror, bitdepth, color management, VRR, etc..[1]

### Dynamic Monitor Hotplugging

- On monitor plug/unplug, Hyprland can automatically configure new outputs by adding catch-all entries:
```
monitor = , preferred, auto, 1
```
This sets all unmapped monitors to preferred resolution, placed automatically with scale 1.[1]

### Layout Customization

Arrange monitors horizontally, vertically, or in grid layouts by adjusting the position field. Example for stacking above:[1]
```
monitor = DP-1, 2560x1440, 0x0, 1
monitor = HDMI-1, 1920x1080, 320x1440, 1  # Below and right (offset origin matched to effective pixels)
```


### Per-Monitor Advanced Options

- **Rotation:** Add a transform: `monitor = eDP-1, preferred, 0x0, 1, transform, 3` (270 degrees).[1]
- **Mirroring:** Mirror a monitor: `monitor = HDMI-1, mirror, DP-1`.[1]
- **Bitdepth:** Set 10-bit color: `monitor = DP-1, preferred, auto, 1, bitdepth, 10`.[1]
- **Color management:** Use wide, srgb, or custom color profiles with `cm`: `monitor = DP-1, preferred, auto, 1, cm, srgb`.[1]
- **HDR:** Enable experimental HDR: `monitor = DP-1, preferred, auto, 1, cm, hdr`.[1]
- **Workspace binding:** Assign workspaces to specific monitors:
  ```
  workspace = 1, monitor:DP-1
  workspace = 2, monitor:HDMI-1
  workspace = name:editor, monitor:eDP-1
  ```


### Auto-Positioning and Catch-all

Auto arrange new monitors using directional flags:
```
monitor = , preferred, auto-right, 1
monitor = , preferred, auto-center-up, 1
```


### Multi-Monitor Workflow Tips

- **Workspaces are independent per monitor** when assigned; switching workspace on one does not affect others.[4][1]
- **Focus follows mouse** or keyboard shortcuts to jump between monitors (`focusmonitor` dispatcher).[2]
  ```
  bind = SUPER, F2, focusmonitor, l
  bind = SUPER, F3, focusmonitor, r
  ```


- **Move windows between monitors** with `movetomonitor`:
  ```
  bind = SUPER+SHIFT, Left, movetomonitor, l
  bind = SUPER+SHIFT, Right, movetomonitor, r
  ```


- **Set scale per monitor** for mixed DPI/HiDPI setups:
  ```
  monitor = eDP-1, preferred, auto, 2
  monitor = DP-1, 1920x1080, auto, 1
  ```


### Alternative Monitorv2 Verbose Block

For maximal flexibility, use structured blocks:
```
monitorv2 {
  output = DP-1
  mode = 2560x1440@144
  position = 0x0
  scale = 1.25
  transform = 3
  color_profile = srgb
}
```


### Reserved Screen Areas

Create reserved (unusable) screen space at screen edges for panels or widgets:
```
monitor = DP-1, 2560x1440, 0x0, 1, addreserved, 40, 0, 0, 0
```
(Top 40px reserved—useful for bars on specific monitors).[1]

### Troubleshooting

- Use `hyprctl monitors all` to debug port names, resolutions, and active mappings.[2]
- If display issues arise (overlapping, black screens), verify that positions and scales do not overlap or conflict.[1]

### Scripts for Multi-Monitor Setups

Hotplug/autorun example:
```bash
#!/bin/bash
# ~/.config/hypr/scripts/switch-monitors.sh
if hyprctl monitors | grep 'HDMI-1'; then
  hyprctl keyword monitor HDMI-1, disable
else
  hyprctl keyword monitor HDMI-1, preferred, auto, 1
fi
```
Bind in `hyprland.conf`:
```
bind = SUPER, F7, exec, ~/.config/hypr/scripts/switch-monitors.sh
```


With flexible monitor configuration keywords and the `monitorv2` block, Hyprland enables robust and fully-scriptable multi-monitor layouts suitable for any mixed-DPI, rotated, mirrored, or hotplug workflow.[4][2][1]

Sources
[1] Monitors https://wiki.hypr.land/Configuring/Monitors/
[2] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[3] I need help with Refresh rate · hyprwm Hyprland https://github.com/hyprwm/Hyprland/discussions/3706
[4] Hyprland workspace configuration - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=298652

# System Optimization

## Power Management

Hyprland integrates power management features for battery monitoring, sleep/suspend/hibernate, display blanking, and system resource control, often using Wayland-native daemons and keybinds for full automation.[1]

### System Sleep, Suspend, and Hibernate

Use `systemctl` for system power state changes:
```
bind = SUPER, S, exec, systemctl suspend
bind = SUPER+SHIFT, S, exec, systemctl hibernate
bind = SUPER, P, exec, systemctl poweroff
bind = SUPER+SHIFT, P, exec, systemctl reboot
```
- Sleep (suspend): RAM powered, work resumes instantly.[1]
- Hibernate: RAM saved to disk, powers down completely.[1]
- Poweroff/reboot: Standard system shutdowns.

### Idle and Screen Blank Control

**Hypridle** handles all idle-related power actions with custom listeners:
```
exec-once = hypridle
```
Configure `/~/.config/hypridle/hypridle.conf`:
```
general {
  lock_cmd = hyprlock
  before_sleep_cmd = notify-send "System will sleep"
  after_sleep_cmd = notify-send "System woke up"
}

listener {
  timeout = 600
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on
}

listener {
  timeout = 1200
  on-timeout = systemctl suspend
}
```
- **DPMS off/on** blanks/unblanks displays after X seconds of inactivity (saves battery).
- System suspends after Y seconds, all via customizable timeouts.

### Battery Status and Monitoring

Waybar battery module displays live battery stats:
```json
"battery": {
  "format": "🔋 {capacity}%",
  "states": { "warning": 25, "critical": 10 },
  "format-charging": "⚡ {capacity}%"
}
```
- Supports notifications and urgent status when battery is low.[1]

Use `upower` for command-line battery info:
```bash
upower -i /org/freedesktop/UPower/devices/battery_BAT0
```
- Automate battery warnings with scripts:
```bash
#!/bin/bash
LEVEL=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}' | tr -d '%')
if [ "$LEVEL" -le 10 ]; then
  notify-send --urgency=critical "Battery Critical" "Plug in your charger!"
fi
```
Bind to periodic task or idle daemon.[1]

### Display Brightness

Adjust using `brightnessctl` and keybinds:
```
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
```
- Works for internal screens, some external monitors, and keyboard backlights.[1]

### Lid Events & Power Button

Systemd handles lid/ACPI/power-button events via `/etc/systemd/logind.conf`:
- `HandleLidSwitch=suspend`
- `HandlePowerKey=poweroff`
No need to configure separately for Hyprland unless overriding system defaults.

### Automatic Dimming/Night Mode

Combine with **Hyprsunset** for blue light reduction:
```
exec-once = hyprsunset
```
Configure color temperature and day/night profiles in `~/.config/hyprsunset/hyprsunset.conf`.

### Swayidle Alternative

`swayidle` is an alternative idle management daemon:
```
exec-once = swayidle -w timeout 900 'systemctl suspend' timeout 600 'hyprctl dispatch dpms off'
```
- Triggers suspend, screen blanking, or lock after inactivity.[1]

### System Resource Control

Reduce compositing load on battery:
```bash
hyprctl keyword animations:enabled false
hyprctl keyword decoration:blur:enabled false
hyprctl keyword general:vsync false
```
Bind to a key or script, or trigger on battery threshold via cron/hypridle.[1]

### Audio Power Saving

PulseAudio/PipeWire can suspend audio sinks on idle:
- Enable module in `/etc/pulse/default.pa` or PipeWire equivalent:
  ```
  load-module module-suspend-on-idle
  ```
Helps reduce battery use on laptops, especially with Bluetooth devices.

### Example Power Management Configuration

```ini
# IDLE/Power management
exec-once = hypridle

bind = SUPER, S, exec, systemctl suspend
bind = SUPER+SHIFT, S, exec, systemctl hibernate
bind = SUPER, P, exec, systemctl poweroff

bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

exec-once = hyprsunset

# Battery warning script integration
exec-once = watch -n 60 ~/.config/hypr/scripts/battery-warning.sh
```


Hyprland supports robust power management through compositing features, systemd, Wayland-native daemons, and full scripting/automation integration for any workflow.

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland

## DPMS Control

DPMS ("Display Power Management Signaling") enables Hyprland to manage the power state of monitors, allowing automated or manual screen blanking to save energy and extend display lifespan. DPMS actions can be triggered by idle daemons, keybinds, or scripts for flexible workflows.[1]

### Manual DPMS Toggle

Use the `dpms` dispatcher for immediate control:
```
hyprctl dispatch dpms off       # Turns off all monitors (blanks screens)
hyprctl dispatch dpms on        # Turns all monitors back on
hyprctl dispatch dpms toggle    # Toggles current state
```


Bind directly in `hyprland.conf`:
```
bind = SUPER, F8, exec, hyprctl dispatch dpms off
bind = SUPER+SHIFT, F8, exec, hyprctl dispatch dpms on
bind = SUPER, F9, exec, hyprctl dispatch dpms toggle
```
- Useful for temporarily blanking the screen (privacy, quick sleep).

### Per-Monitor DPMS

Control DPMS by monitor (Hyprland v0.38+):
```
hyprctl dispatch dpms off HDMI-1
hyprctl dispatch dpms on DP-1
```
- Specify output port name as listed by `hyprctl monitors` for targeted power control.[1]

### DPMS via Hypridle (Idle Daemon)

Automate DPMS with inactivity listeners:
```
listener {
  timeout = 600        # 10 minutes
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on
}
```
- Screen blanks after 10 minutes, resumes on input event.[1]

### DPMS and Session Lock

Combine with screen lock daemon for security:
```
listener {
  timeout = 660        # 11 minutes
  on-timeout = hyprlock
}
listener {
  timeout = 600        # 10 minutes
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on
}
```
- Blank monitors just before lock; input reactivates and triggers lock-screen for password.[1]

### Scripting DPMS

Quick scripts for more advanced DPMS:
**Toggle only external displays:**
```bash
for MON in $(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | .name'); do
  hyprctl dispatch dpms off $MON
done
```
Bind to a key or call from Hyprland automation.[1]

### DPMS for All Monitors

Use `auto` keyword:
```
hyprctl dispatch dpms off auto
hyprctl dispatch dpms on auto
```


### DPMS Troubleshooting

- **DPMS not working:** Verify output names and kernel driver support; not all HDMI or DisplayPort adapters support DPMS under Wayland.[1]
- **Delayed resume:** If monitors take long to power on, check display firmware and connection quality.[1]
- **Screens do not blank:** Ensure DPMS is enabled and that user input (mouse, touchpad, keyboard) does not interfere with the idle timeout.

### Example DPMS Integration

Add to `hyprland.conf` and `hypridle.conf`:
```
# Immediate DPMS control
bind = SUPER, F8, exec, hyprctl dispatch dpms off
bind = SUPER, F9, exec, hyprctl dispatch dpms toggle

# Per-monitor control
bind = SUPER+SHIFT, F8, exec, hyprctl dispatch dpms off DP-1
bind = SUPER+SHIFT, F9, exec, hyprctl dispatch dpms on HDMI-1

# Idle daemon automation
listener {
  timeout = 600
  on-timeout = hyprctl dispatch dpms off
  on-resume = hyprctl dispatch dpms on
}
```


DPMS controls in Hyprland provide robust and granular power management that can be automated or manually triggered, essential for both desktop and laptop workflows.

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland

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

# Desktop Portal Integration

## XDG Desktop Portal Hyprland

### Purpose and Features

- `xdg-desktop-portal-hyprland` is the recommended portal backend for full Hyprland and Wayland features such as screen sharing, global shortcuts, and fine-grained window selection.[1][2]
- It integrates closely with Hyprland’s compositor via D-Bus, providing better compatibility than the generic `xdg-desktop-portal-wlr`, especially for window sharing and advanced functionality.[3][2]

### Installation

- Install the necessary packages:
  ```
  sudo pacman -S xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  ```
  - GTK is optional but recommended for proper file dialogs.[4][1]
- Ensure other portal implementations (e.g., `xdg-desktop-portal-wlr`, `xdg-desktop-portal-gnome`) are removed or disabled to avoid conflicts.[5][1]
- For screensharing, ensure `pipewire` and `wireplumber` are installed and running.[6]

### Environment Variable Configuration

- Add the following to your `~/.config/hypr/hyprland.conf` or session start script to set the required environment for portal detection:
  ```
  exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
  ```
  - Set `XDG_CURRENT_DESKTOP=Hyprland` before Hyprland starts for the portal to recognize the session.[7][5]

### Usage and Troubleshooting

- `xdg-desktop-portal-hyprland` should launch automatically with your session.
- Test function by attempting screen sharing in OBS or a browser; a picker dialog will confirm correct operation.[3][6]
- If screensharing or open/save dialogs launch the wrong portal, verify only the Hyprland backend and optionally GTK are installed, and restart necessary services.[5][3]

### Notes and Recommendations

- Prefer the Hyprland portal (`-hyprland`) over the WLR portal for best experience and functionality in Hyprland.[2][3]
- Remove any conflicting portal implementations to ensure stable behavior, especially for screen sharing or security prompts.[8][5]
- Advanced features like individual window sharing are only supported by `xdg-desktop-portal-hyprland` within Hyprland.[2][3]

Sources
[1] xdg-desktop-portal-hyprland https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[2] xdg-desktop-portal-hyprland https://wiki.hyprland.org/0.41.2/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[3] Hyprland Desktop Portal https://wiki.hyprland.org/0.41.0/Useful-Utilities/xdg-desktop-portal-hyprland/
[4] xdg-desktop-portal-hyprland 1.3.11-1 (x86_64) https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal-hyprland/
[5] Screen sharing on Hyprland (Arch Linux) https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580?permalink_comment_id=4638574
[6] Screen sharing - Hyprland Wiki https://wiki.hypr.land/Useful-Utilities/Screen-Sharing/
[7] XDG Desktop Portal https://wiki.archlinux.org/title/XDG_Desktop_Portal
[8] wlr installed simultaneously" but xdg-desktop-portal-wlr is ... https://www.reddit.com/r/hyprland/comments/15gr18p/arch_linux_get_notification_that_you_have/
[9] Run xdg-desktop-portal-gnome on hyprland https://www.reddit.com/r/hyprland/comments/1g49k3q/run_xdgdesktopportalgnome_on_hyprland/
[10] Configuring xdg-desktop-portal with Home Manager on ... https://discourse.nixos.org/t/configuring-xdg-desktop-portal-with-home-manager-on-ubuntu-hyprland-via-nixgl/65287
[11] How to Install Arch Linux and Hyprland (Part 2 of 2) - John Ling https://www.johnling.me/blog/Hyprland-Guide
[12] Properly Setting Up `xdg-desktop-portal-hyprland` | Is It ... https://www.reddit.com/r/hyprland/comments/1m9oktp/properly_setting_up_xdgdesktopportalhyprland_is/
[13] Having certain portal implementations together in Hyprland causes ... https://github.com/flatpak/xdg-desktop-portal/issues/969
[14] Issue #64 · hyprwm/xdg-desktop-portal-hyprland - GitHub https://github.com/hyprwm/xdg-desktop-portal-hyprland/issues/64
[15] Installation https://wiki.hyprland.org/0.46.0/Getting-Started/Installation/
[16] hyprwm/xdg-desktop-portal-hyprland https://github.com/hyprwm/xdg-desktop-portal-hyprland
[17] xdg-desktop-portal-hyprland can not start https://bbs.archlinux.org/viewtopic.php?id=306801
[18] home-manager: configuring xdg portal · Issue #409 https://github.com/hyprwm/hyprland-wiki/issues/409
[19] FreshPorts -- x11/xdg-desktop-portal-hyprland https://www.freshports.org/x11/xdg-desktop-portal-hyprland
[20] Hyprland Desktop Portal https://wiki.hypr.land/hyprland-wiki/pages/Useful-Utilities/Hyprland-desktop-portal/

## Screen Sharing

### Requirements

- Ensure `xdg-desktop-portal-hyprland`, `xdg-desktop-portal`, `pipewire`, and `wireplumber` are installed and running for seamless screen sharing in Hyprland.[1][2]
- Remove or disable other portal backends (like `xdg-desktop-portal-wlr` or `gnome`) to prevent conflicts.[2][3]

### Configuration Steps

- Add to your Hyprland or environment configuration:
  ```
  XDG_CURRENT_DESKTOP=Hyprland
  exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
  ```
  This ensures the right portal is selected and signals session type to D-Bus.[3][4][2]

### Browser and App Support

- Modern browsers (e.g., Firefox, Chromium/Chrome) and video conferencing apps (WebRTC-based) work seamlessly, offering both monitor and individual window selection with the Hyprland portal.[1]
- Test screen sharing in browsers or OBS Studio to verify the picker dialog appears and your selected monitor/window can be streamed.[3][1]

### Troubleshooting

- If you get stuck on "loading preview" or see no window/monitor picker:
  - Check only `xdg-desktop-portal-hyprland` is running as a backend.
  - Restart portals and related services:
    ```
    systemctl --user restart pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-hyprland
    ```
  - Ensure `XDG_CURRENT_DESKTOP` is properly set and exported in your startup files.[5][3]
- Check logs in `~/.local/share/xdg-desktop-portal-hyprland.log` or use `journalctl` for deeper diagnostics.[3]

### Features

- Supports full screen, per-monitor, and now individual window sharing through the picker dialog in supported browsers and apps.[5][1]
- Provides better compatibility and performance than generic Wayland solutions when used with Hyprland.[1][5]

***

Related topics: Pipewire setup, Flatpak/portal integration, OBS Studio and browser-based sharing with Wayland.

Sources
[1] Screen sharing - Hyprland Wiki https://wiki.hypr.land/Useful-Utilities/Screen-Sharing/
[2] xdg-desktop-portal-hyprland https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[3] Screen sharing on Hyprland (Arch Linux) https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580?permalink_comment_id=4638574
[4] XDG Desktop Portal https://wiki.archlinux.org/title/XDG_Desktop_Portal
[5] Hyprland Desktop Portal https://wiki.hyprland.org/0.41.0/Useful-Utilities/xdg-desktop-portal-hyprland/

## File Pickers

### Integration on Hyprland

- File picker dialogs on Wayland/Hyprland depend on `xdg-desktop-portal` and an appropriate backend such as `xdg-desktop-portal-hyprland`.[1][2]
- For best results, also install a graphical backend such as `xdg-desktop-portal-gtk`, which provides the native GTK file picker dialog—essential for Flatpak or sandboxed applications.[3][1]
- For Qt-based apps, `xdg-desktop-portal-qt` can be installed for better file dialog theming and compatibility, but `-gtk` is generally sufficient on most systems.[3]

### Setup & Recommendations

- Install with:
  ```
  sudo pacman -S xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  ```
  - Ensure *only one* backend is active to avoid unpredictable picker behavior (such as wrong dialog showing, or no dialog at all).[2][1]
- `xdg-desktop-portal-hyprland` will manage requests and pass them to the proper backend for dialog display. GTK’s picker remains the default in most cases unless overridden by app configuration.[1]

### File Picker in Flatpak & Sandboxed Apps

- When running a Flatpak app or a sandboxed program, the app requests a file picker via the portal API, and the dialog appears according to the active backend (`-gtk`, `-qt`, etc.).[3]
- Problems with missing or broken file pickers can often be traced to a missing or conflicting portal backend. Check running services with:
  ```
  loginctl user-status
  ```
- Restart and ensure only the Hyprland and one visual backend are running if you have issues.[4]

### Troubleshooting

- If no dialog appears, or the wrong type shows up, check for and remove any conflicting portal implementations (e.g., `xdg-desktop-portal-wlr`, `xdg-desktop-portal-gnome`).[4][1]
- Restart with:
  ```
  systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  ```
  and log out/in if needed to clear issues.[4]

***

Related topics: Flatpak file access, sandbox escapes, portal troubleshooting, theming file dialogs on Hyprland.

Sources
[1] xdg-desktop-portal-hyprland https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[2] Hyprland Desktop Portal https://wiki.hyprland.org/0.41.0/Useful-Utilities/xdg-desktop-portal-hyprland/
[3] XDG Desktop Portal https://wiki.archlinux.org/title/XDG_Desktop_Portal
[4] Screen sharing on Hyprland (Arch Linux) https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580?permalink_comment_id=4638574

## Global Shortcuts

### Portal Support and Hyprland Methods

- `xdg-desktop-portal-hyprland` provides a portal for registering global keyboard shortcuts, directly supporting applications (including Flatpak and sandboxed apps) to receive input when unfocused.[1][2][3]
- Hyprland implements its own protocol (`hyprland_global_shortcuts_v1`) allowing clients to register triggerable actions as global shortcuts; the compositor manages keybinding and triggers.[4][5]

### Binding Global Shortcuts in Hyprland

- Native Wayland apps (or those using the GlobalShortcuts portal) can receive global shortcuts through the portal mechanism.
- Bind global shortcuts in `~/.config/hypr/hyprland.conf` using the `global` dispatcher, for example:
  ```
  bind = SUPERSHIFT, A, global, coolApp:myToggle
  ```
  - This triggers the `myToggle` action in `coolApp` when `Super+Shift+A` is pressed, even if the app is unfocused.[6][4]
- To see available global shortcuts for running apps, use:
  ```
  hyprctl globalshortcuts
  ```
  - This will list registered shortcuts for applications supporting the protocol.[4]

### Classic Pass/Sendshortcut Binding

- Hyprland allows passing keys to specific windows directly:
  ```
  bind = SUPER, F10, pass, class:^(com\\.obsproject\\.Studio)$
  ```
- Or to trigger a shortcut for an app window:
  ```
  bind = SUPER, F10, sendshortcut, SUPER, F4, class:^(com\\.obsproject\\.Studio)$
  ```
  - Works well for push-to-talk and app-specific actions. Recommended for native Wayland apps; XWayland/sandboxed apps may require portal support.[4]

### Troubleshooting

- Confirm only Hyprland's portal (`xdg-desktop-portal-hyprland`) is running to avoid backend confusion.[3]
- Some desktop environments (KDE, GNOME) have their own portals or limitations; Hyprland’s implementation offers broader application support for Wayland-native and Flatpak apps compared to generic portals.[2][7][8]
- Restart portal services and log out/in if portal registration fails or shortcuts do not work.

***

Related topics: Application/desktop integration, Flatpak sandboxed apps, Wayland protocol details for global shortcuts.

Sources
[1] xdg-desktop-portal-hyprland https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[2] xdg-desktop-portal-wlr VS xdg-desktop-portal-hyprland https://www.reddit.com/r/hyprland/comments/12uvoor/xdgdesktopportalwlr_vs_xdgdesktopportalhyprland/
[3] xdg-desktop-portal-hyprland https://wiki.hyprland.org/0.41.2/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[4] Binds https://wiki.hypr.land/Configuring/Binds/
[5] Hyprland global shortcuts protocol - Wayland Explorer https://wayland.app/protocols/hyprland-global-shortcuts-v1
[6] GlobalShortcut - Quickshell.Hyprland https://quickshell.outfoxxed.me/docs/master/types/Quickshell.Hyprland/GlobalShortcut/
[7] XDG Global Keybinds Portal in GNOME? - Fedora Discussion https://discussion.fedoraproject.org/t/xdg-global-keybinds-portal-in-gnome/121019
[8] Why KDE can't implement global shortcuts on wayland https://www.reddit.com/r/kde/comments/16fmpf5/why_kde_cant_implement_global_shortcuts_on_wayland/
[9] Implement xdg-foreign v1 & v2 protocols · Issue #6884 https://github.com/hyprwm/Hyprland/issues/6884
[10] Wayland global hotkeys (shortcut) is mostly useless https://dec05eba.com/2024/03/29/wayland-global-hotkeys-shortcut-is-mostly-useless/
[11] Add support for wayland global-shortcuts portal https://www.1password.community/discussions/1password/feature-request-add-support-for-wayland-global-shortcuts-portal/110057
[12] globalShortcut https://electronjs.org/docs/latest/api/global-shortcut
[13] XDG Desktop Portal https://wiki.archlinux.org/title/XDG_Desktop_Portal
[14] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[15] Global shortcut portal support · Issue #240 https://github.com/emersion/xdg-desktop-portal-wlr/issues/240
[16] Configuring global keybinds? : r/hyprland - Reddit https://www.reddit.com/r/hyprland/comments/1ehk51y/configuring_global_keybinds/
[17] Unable to update due to xdg-desktop-portal-hyprland-git https://forum.garudalinux.org/t/unable-to-update-due-to-xdg-desktop-portal-hyprland-git/31601
[18] Uncommon tips & tricks - Hyprland Wiki https://wiki.hypr.land/Configuring/Uncommon-tips--tricks/
[19] Global shortcut implementations #134 - flatpak/libportal https://github.com/flatpak/libportal/issues/134
[20] adopt xdg-desktop-portal GlobalShortcuts API · Issue #38288 https://github.com/electron/electron/issues/38288

# Appearance Customization

## GTK Theming

### Theme Installation and Management

- Install desired GTK themes (and icon/cursor packs) into either `/usr/share/themes` for system-wide or `~/.themes` for user-specific use.[1][2]
- Use a graphical tool like `nwg-look` or `lxappearance` to manage themes, icons, and cursors in Hyprland; these ensure proper environment variables are set and that changes persist across Wayland sessions.[3][4][5]

### Setting Themes for GTK3/GTK4 Apps

- For GTK3 apps, set the theme using:
  ```
  gsettings set org.gnome.desktop.interface gtk-theme "YourThemeName"
  ```
- For GTK4 apps, enforce dark mode with:
  ```
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
  ```
  Add these lines to your Hyprland start/exec configuration if you want a global effect.[6][5]

### Environment Variables

- Alternatively, set the environment variable in your Hyprland config:
  ```
  env = GTK_THEME,YourThemeName:dark
  ```
  - Particularly useful for apps (like Nautilus) that ignore gsettings changes.[7][8][9]

### Portal Integration for Theming

- Ensure `xdg-desktop-portal-gtk` is installed; it provides proper themed dialogs for sandboxed/flatpak applications as well as some system dialogs.[10][11]
- It's safe and recommended to run both `xdg-desktop-portal-gtk` and `xdg-desktop-portal-hyprland`; the GTK portal will handle themed dialogs, while the Hyprland portal covers screensharing/global shortcuts.[10]

### Troubleshooting

- If themes don’t apply, check configuration with `gsettings` and ensure environment variables are set before any GTK applications launch.[12][7]
- If apps display in a default or Adwaita theme, verify `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini` have the correct theme name.
  - Example entry:
    ```
    [Settings]
    gtk-theme-name=YourThemeName
    ```
- Log out and back in or restart session after changes to ensure full propagation.[7][12]

***

Related topics: Uniform look for Qt and GTK apps, icon/cursor theming, Flatpak dialog integration, dark mode consistency.

Sources
[1] How to install gtk themes on Hyprland https://www.youtube.com/watch?v=T4dyQqu1Fo0
[2] How to Rice Hyprland (Part 3) | GTK Theme https://www.youtube.com/watch?v=FVZ-8EtwXBY
[3] How to Set GTK themes on Hyprland with a GUI | nwg-look https://www.youtube.com/watch?v=F9dl2r_Htu0
[4] Master tutorial https://wiki.hypr.land/Getting-Started/Master-Tutorial/
[5] FAQ https://wiki.hyprland.org/0.46.0/FAQ/
[6] How to set dark mode? · hyprwm Hyprland https://github.com/hyprwm/Hyprland/discussions/5867
[7] How to apply gtk themes on hyprland https://www.reddit.com/r/hyprland/comments/17swxzh/how_to_apply_gtk_themes_on_hyprland/
[8] Gtk theme in garuda_hyprland - Hyprland https://forum.garudalinux.org/t/gtk-theme-in-garuda-hyprland/38120
[9] Environment variables https://wiki.hyprland.org/0.41.0/Configuring/Environment-variables/
[10] Issue #145 · hyprwm/xdg-desktop-portal-hyprland https://github.com/hyprwm/xdg-desktop-portal-hyprland/issues/145
[11] GTK apps not following theme? : r/hyprland https://www.reddit.com/r/hyprland/comments/1akc4ec/gtk_apps_not_following_theme/
[12] Problem with gtk theme doesn't change appearance https://forum.garudalinux.org/t/problem-with-gtk-theme-doesnt-change-appearance/41034
[13] How do I configure GTK in Arch, Wayland? https://bbs.archlinux.org/viewtopic.php?id=273974
[14] xdg-desktop-portal-hyprland https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[15] Uniform look for Qt and GTK applications https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
[16] FAQ https://wiki.hypr.land/FAQ/
[17] Hyprland https://wiki.archcraft.io/docs/wayland-compositors/hyprland/
[18] Hyprland Desktop Portal https://wiki.hyprland.org/0.41.0/Useful-Utilities/xdg-desktop-portal-hyprland/
[19] Setting prefered xdg-desktop-portal in gnome, to fix titlebars https://discourse.nixos.org/t/setting-prefered-xdg-desktop-portal-in-gnome-to-fix-titlebars/66149
[20] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland

## Qt Configuration

### Required Packages

- Install `qt5ct` and `qt6ct` to manage Qt5/Qt6 application theming.
- For native Wayland support, install `qt5-wayland` and `qt6-wayland`.
- For advanced SVG-based themes, add Kvantum (`kvantum-qt5`, `kvantum-qt6`, and desired theme packs).[1][2][3]

### Environment Variable Setup

Add these lines to your Hyprland configuration (`~/.config/hypr/hyprland.conf`) under the appropriate section:

```
env = QT_QPA_PLATFORM,wayland
env = QT_QPA_PLATFORMTHEME,qt5ct
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = QT_AUTO_SCREEN_SCALE_FACTOR,1
env = QT_STYLE_OVERRIDE,kvantum
```
- Use `qt5ct` for Qt5 and `qt6ct` for Qt6. Qt6 apps automatically use qt6ct if installed.[2][4][1]

### Theming & Appearance

- Set styles, colors, and icons in `qt5ct` or `qt6ct` GUI apps. Open `qt6ct`, choose a theme (such as Breeze or Kvantum), click "Apply," and restart your Qt apps.[3][2]
- For Kvantum themes, use Kvantum Manager to select and apply preferred SVG-based themes, then set `QT_STYLE_OVERRIDE=kvantum` for consistency.[1][3]

### Flatpak Applications

- Ensure Flatpak Qt apps use matching Kvantum and Platform versions (`org.kde.KStyle.Kvantum` with corresponding `org.kde.Platform`) for consistent theming.[1]

### Troubleshooting

- If scaling or theme does not apply correctly, confirm variables are present and only set in one location (prefer Hyprland config over `/etc/environment` for session control).[5]
- For broken scaling, verify `QT_AUTO_SCREEN_SCALE_FACTOR=1` is set for HiDPI screens.[1]
- If using mixed GTK/Qt environments, follow the integration guide for uniform appearance.[6]

***

Related topics: Consistent dark mode across toolkits, Wayland session variables, Kvantum and advanced theme management.

Sources
[1] QT theming on Hyprland - Reddit https://www.reddit.com/r/hyprland/comments/19cspxf/qt_theming_on_hyprland/
[2] Better KDE theming and styling in Hyprland | Lorenzo Bettini https://www.lorenzobettini.it/2024/08/better-kde-theming-and-styling-in-hyprland/
[3] How to Customize Qt and GTK Themes on Arch Linux | Siberoloji https://www.siberoloji.com/how-to-customize-qt-and-gtk-themes-on-arch-linux/
[4] Environment variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Environment-variables/
[5] Qt5ct and qt Themes! : r/hyprland - Reddit https://www.reddit.com/r/hyprland/comments/14k0qjx/qt5ct_and_qt_themes/
[6] Uniform look for Qt and GTK applications - ArchWiki https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
[7] How to set dark mode? · hyprwm Hyprland · Discussion #5867 https://github.com/hyprwm/Hyprland/discussions/5867
[8] xdg-desktop-portal-hyprland https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
[9] How to Install Arch Linux and Hyprland (Part 2 of 2) - John Ling https://www.johnling.me/blog/Hyprland-Guide
[10] Hyprland Desktop Portal https://wiki.hyprland.org/0.41.0/Useful-Utilities/xdg-desktop-portal-hyprland/
[11] Master tutorial - Hyprland Wiki https://wiki.hypr.land/Getting-Started/Master-Tutorial/
[12] Master tutorial - Hyprland Wiki https://wiki.hyprland.org/0.41.0/Getting-Started/Master-Tutorial/
[13] XDG Desktop Portal https://wiki.archlinux.org/title/XDG_Desktop_Portal
[14] [SOLVED]Incorrect themeing after updating system / Applications ... https://bbs.archlinux.org/viewtopic.php?id=304893
[15] Getting errors when trying to launch qt5ct and lxappearance #1812 https://github.com/hyprwm/Hyprland/discussions/1812
[16] Weird xdg-desktop-portal Rendering Issue on Hyprland ... https://www.reddit.com/r/hyprland/comments/1jr4zf7/weird_xdgdesktopportal_rendering_issue_on/
[17] How To Theme Qt Apps To Get a Uniform Look - YouTube https://www.youtube.com/watch?v=VC4ecxd6dn8&vl=en
[18] Guide to installing qt theme - NixOS Discourse https://discourse.nixos.org/t/guide-to-installing-qt-theme/35523
[19] Issue #145 · hyprwm/xdg-desktop-portal-hyprland https://github.com/hyprwm/xdg-desktop-portal-hyprland/issues/145
[20] Master tutorial - Hyprland Wiki https://wiki.hyprland.org/0.47.0/Getting-Started/Master-Tutorial/

## Icon Themes

### Installation and Directories

- Download icon theme packs (such as Papirus, Tela, or Qogir) from popular repositories: [GitHub](https://github.com/vinceliuice/Tela-circle-icon-theme) or from theme sharing sites.[1][2]
- Place system-wide icon themes in `/usr/share/icons`, or for per-user access, in `~/.icons`.[3][1]
- Extract any compressed theme archives before placing them into those directories; most themes include instructions.[1]

### Applying Icon Themes

- Use a graphical utility like `nwg-look` or `lxappearance` for easy theme switching and preview.[4][1]
- For GTK apps, icon theme selection can be made through these GUI tools or by editing `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini`:
  ```
  [Settings]
  icon-theme-name=YourIconTheme
  ```
  Apply the same icon theme name in `qt5ct` or `qt6ct` for Qt apps to ensure integration.[5][6]

### Theming Across GTK and Qt

- Most modern icon themes support both GTK and Qt applications. Select the matching icon set in both `nwg-look` and `qt5ct/qt6ct` for uniform appearance.[6][5]
- For KDE apps or if you’re using Kvantum, select icon theme in `qt6ct` or Kvantum Manager.[5]

### Recommendations

- Popular icon themes: Papirus, Tela Circle, Qogir, Fluent, and Nordic.[2][7]
- Fonts and cursors are similarly themed by placing files in `~/.fonts` and `~/.icons` (for cursors).[3]
- Restart your session or apps after theme changes for full effect, especially after modifying configuration files.[1]

### Troubleshooting

- If icons do not show or fallback to defaults:
  - Confirm the folder name matches the value in your config.
  - Check for missing icon sizes or required SVG/PNG formats.
  - Restart your graphical session or run `xfsettingsd` to reapply themes (especially for legacy apps).[4]
- For some notifications or custom widgets (Waybar, Mako), ensure PNG icons are available in their specific config directories, e.g., `~/.config/mako/icons/`.[8]

***

Related topics: Customizing cursors, Nerd font integration, Wayland widget icon usage, scripting theme changes.

Sources
[1] Hyprland theming. everything from getting themes/making ... https://www.reddit.com/r/hyprland/comments/14uk7s3/hyprland_theming_everything_from_getting/
[2] How to Install Arch Linux and Hyprland (Part 2 of 2) - John Ling https://www.johnling.me/blog/Hyprland-Guide
[3] Here's How You Can Customize Linux Desktop ... https://itsfoss.com/hyprland-halloween-customization/
[4] Hyprland https://wiki.archcraft.io/docs/wayland-compositors/hyprland/
[5] KDE theming and styling in Hyprland - Lorenzo Bettini https://www.lorenzobettini.it/2024/06/kde-theming-and-styling-in-hyprland/
[6] Uniform look for Qt and GTK applications https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
[7] Best free icon sets for UI design in 2025 - Adham Dannaway https://www.adhamdannaway.com/blog/icons/free-icon-sets
[8] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[9] How to install themes on Arch Linux with Hyprland and ... https://www.facebook.com/groups/archlinuxen/posts/10160417303713393/
[10] A Noobs Guide to Hyprland EP:11 | Installing Icons, ... https://www.youtube.com/watch?v=6GKMjdAai-Q
[11] Hyprland/Wayland Dynamic Bar With ICONS Using Quickshell https://www.youtube.com/watch?v=YM2FJ_aoGQA
[12] JaKooLit/Arch-Hyprland: For automated installation of ... https://github.com/JaKooLit/Arch-Hyprland
[13] Icons of programs on desktop hyprland : r/archlinux - Reddit https://www.reddit.com/r/archlinux/comments/1gobmzb/icons_of_programs_on_desktop_hyprland/
[14] Whats the best to way theme gtk and qt apps : r/hyprland https://www.reddit.com/r/hyprland/comments/1khhuud/whats_the_best_to_way_theme_gtk_and_qt_apps/
[15] My Hyprland Theme Collection (Best Setups from 2025) - YouTube https://www.youtube.com/watch?v=1D18unIwbmE
[16] How to apply gtk themes on hyprland https://www.reddit.com/r/hyprland/comments/17swxzh/how_to_apply_gtk_themes_on_hyprland/
[17] My Linux Desktop Just Got Scary! 👻 (Hyprland Halloween ... https://www.youtube.com/watch?v=TOTZedtb_d8
[18] Hyprland Made Easy: Preconfigured Beautiful Distros - It's FOSS https://itsfoss.com/hyprland-distros/
[19] I just can't set gtk theme... : r/hyprland https://www.reddit.com/r/hyprland/comments/1ixczr1/i_just_cant_set_gtk_theme/
[20] 3446 Hyprland - How to change the theme, icons and cursor https://www.youtube.com/watch?v=FuWAv2l5Oso

## Font Configuration

### Installing Fonts

- Install additional fonts from the Arch repositories with:
  ```
  sudo pacman -S ttf-<fontname>
  ```
  Examples: `ttf-nerd-fonts-symbols`, `ttf-dejavu`, `ttf-fira-sans`, `ttf-roboto`.[1][2]

### System-Wide Font Configuration

- Font rendering, fallback, and specific preferences can be set globally in `/etc/fonts/local.conf`, or per-user in `~/.config/fontconfig/fonts.conf`.[3]
- Fontconfig controls antialiasing, hinting, and subpixel rendering; presets can be enabled in `/etc/fonts/conf.d/` with symlinks to `/usr/share/fontconfig/conf.avail` (e.g., for RGB subpixel rendering).[3][1]

### GTK and Qt Application Fonts

- Use `nwg-look` (GTK) or `qt5ct`/`qt6ct` (Qt) to set default and UI fonts per toolkit.[4][5]
- For GTK3/GTK4, manually edit `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini`:
  ```
  [Settings]
  gtk-font-name=Fira Sans 11
  ```
- For Qt5/Qt6, use the configuration tool and the GUI to select your preferred font; settings are stored in `~/.config/qt5ct/qt5ct.conf` or `~/.config/qt6ct/qt6ct.conf`.[5][4]

### Per-Application Configuration

- Terminal emulators (Kitty, Alacritty, Foot) and status bars (Waybar) set fonts via their individual config files:
  - `kitty`: `~/.config/kitty/kitty.conf`
  - `alacritty`: `~/.config/alacritty/alacritty.toml`
  - `foot`: `~/.config/foot/foot.ini`
  - `waybar`: `~/.config/waybar/styles/` or the specific bar configuration file.[6][4]

### Font Fallback and Multilingual

- Fontconfig enables the order and fallback for different scripts; customize fallback in `fonts.conf` as exemplified for multilingual needs.[1]
- Use `fc-match` and `fc-list` to test and debug font config and fallback behavior.[1]

### Tips for Best Appearance

- Set scaling and adjust font sizes via toolkit tools (`nwg-look`, `qt5ct`) for HiDPI/4K monitors.[4]
- If font rendering appears poor, enable LCD filtering and tune hinting/antialiasing settings in Fontconfig.[7][3]
- Always log out/log in or restart Hyprland after major changes to ensure all applications pick up the new configuration and render correctly.[3][4]

***

Related topics: Nerd font integration, GDK/GTK/Qt toolkit settings, HiDPI scaling, and troubleshooting font rendering on Wayland.

Sources
[1] Fonts - ArchWiki https://wiki.archlinux.org/title/Fonts
[2] How to Install Arch Linux and Hyprland (Part 2 of 2) - John Ling https://www.johnling.me/blog/Hyprland-Guide
[3] Font configuration - ArchWiki https://wiki.archlinux.org/title/Font_configuration
[4] FAQ_Themes_and_Decorations · JaKooLit/Hyprland-Dots Wiki https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ_Themes_and_Decorations
[5] KDE theming and styling in Hyprland - Lorenzo Bettini https://www.lorenzobettini.it/2024/06/kde-theming-and-styling-in-hyprland/
[6] Hyprland https://wiki.archcraft.io/docs/wayland-compositors/hyprland/
[7] Bad fonts and font rendering - Newbie https://forum.endeavouros.com/t/bad-fonts-and-font-rendering/50510
[8] Can't change the font of Hyprland https://www.reddit.com/r/hyprland/comments/1cn6nfp/cant_change_the_font_of_hyprland/
[9] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[10] Installation https://wiki.hypr.land/Getting-Started/Installation/
[11] fonts are slightly off everywhere #11918 https://github.com/hyprwm/Hyprland/discussions/11918
[12] Configuring https://wiki.hypr.land/Configuring/
[13] THE FRESH ARCH LINUX HYPRLAND SETUP 2025 (Ft. ... https://www.youtube.com/watch?v=OnxU419vnts
[14] Terrible native font rendering under Hyprland for GTK4 and Electron ... https://www.reddit.com/r/hyprland/comments/194br8s/terrible_native_font_rendering_under_hyprland_for/
[15] Master tutorial https://wiki.hypr.land/Getting-Started/Master-Tutorial/
[16] [SOLVED] How to change arch default fonts? https://bbs.archlinux.org/viewtopic.php?id=265441
[17] Font is not antialiased with GTK apps on wayland #2861 - GitHub https://github.com/flatpak/flatpak/issues/2861
[18] Hyprland on Arch — Minimal Setup Guide https://www.tonybtw.com/tutorial/hyprland/
[19] How to Massively Improve Font Rendering on Hyprland - YouTube https://www.youtube.com/watch?v=G_3P_PApDK0
[20] Hyprland: getting started (part 1) - Lorenzo Bettini https://www.lorenzobettini.it/2023/07/hyprland-getting-started-part-1/

## Color Schemes

### System-Wide Color Management

- Hyprland uses a combination of environment variables, config file options, and external tools for global color theming.[1][2]
- Most popular: tools like pywal or maten to auto-generate color schemes from wallpapers and pipe these into your Hyprland, GTK, and Qt config files.[3][4][5]

### GTK and Qt Color Scheme Integration

- For GTK apps, you can switch color schemes (including dark/light) via:
  ```
  gsettings set org.gnome.desktop.interface gtk-theme "YourTheme"
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
  ```
  - Environment variables like `GTK_THEME=YourTheme:dark` may be needed if an app ignores gsettings.[6]

- For Qt apps, pick a dark/light theme and/or color scheme in `qt5ct` or `qt6ct`.  
  - Change color schemes for Qt 6 via:
    ```
    sed -i "s|color_scheme_path=.*|color_scheme_path=\"/usr/share/color-schemes/BreezeDark.colors\"|" ~/.config/qt6ct/qt6ct.conf
    ```
  - Kvantum Manager can also be used for advanced SVG-driven color schemes.[7][2]

### Hyprland Config: Color Variables

- Hyprland config supports named color variables and gradients.[1]
- Example (to set border and active window colors):
  ```
  general {
    border_col_active = rgb(198, 160, 246)
    border_col_inactive = rgba(198, 160, 246, 0.3)
    # Or in hex: border_col_active = rgba(c6a0f6ff)
  }
  ```
- You can dynamically update these via scripts, especially when using pywal/maten for wallpaper-based schemes.[4][3]

### Automation & Advanced Theming

- Tools like pywal or maten can automate color extraction from wallpapers and update all configs at once (Hyprland, Waybar, GTK, Qt, Mako, etc.) by templating/scripting.[5][3][4]
- For rapid dark/light switching, pair Hyprland exec lines like:
  ```
  exec = gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
  exec = sed -i "s/BreezeDark/BreezeLight/" ~/.config/qt6ct/qt6ct.conf
  ```
- Restart affected apps for changes to take effect.

### Notes

- Color values in Hyprland can be `rgba(hex)` (`rgba(79afaaff)`) or `rgb(r,g,b)`.[1]
- Mix and match approaches: system-wide with wallpaper automation, or manual override per-app as needed.[6][4]

***

Related topics: Wallpaper-based theming, pywal/maten scripting, Kvantum color schemes, managing light/dark modes for consistency.

Sources
[1] Variables - Hyprland Wiki https://wiki.hyprland.org/0.46.0/Configuring/Variables/
[2] Uniform look for Qt and GTK applications https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
[3] LierB/dotfiles: Hyprland Arch config based on pywal https://github.com/LierB/dotfiles
[4] How to Rice Hyprland (Part 5) | Material You Colors https://www.youtube.com/watch?v=exy01icTlSg
[5] Arch Linux https://www.facebook.com/groups/archlinuxen/posts/10161357960623393/
[6] How to set dark mode? · hyprwm Hyprland https://github.com/hyprwm/Hyprland/discussions/5867
[7] KDE theming and styling in Hyprland - Lorenzo Bettini https://www.lorenzobettini.it/2024/06/kde-theming-and-styling-in-hyprland/
[8] Best way to set a consistent color scheme system wide https://www.reddit.com/r/hyprland/comments/1fein1p/best_way_to_set_a_consistent_color_scheme_system/
[9] THIS IS NEW ARCH LINUX HYPRLAND SETUP (Ft. DANK ... https://www.youtube.com/watch?v=iqYiCpDY54E
[10] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[11] Why is it GTK and QT theme not working on all apps? https://www.reddit.com/r/hyprland/comments/17cxaw0/why_is_it_gtk_and_qt_theme_not_working_on_all_apps/
[12] Environment variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Environment-variables/
[13] How To Theme Qt Apps To Get a Uniform Look https://www.youtube.com/watch?v=VC4ecxd6dn8&vl=en
[14] Master tutorial - Hyprland Wiki https://wiki.hyprland.org/0.45.0/Getting-Started/Master-Tutorial/
[15] Hyprland on Arch — Minimal Setup Guide https://www.tonybtw.com/tutorial/hyprland/
[16] Color pickers - Hyprland Wiki https://wiki.hypr.land/Useful-Utilities/Color-Pickers/
[17] THE MOST BEAUTIFUL ARCH LINUX HYPRLAND SETUP ... https://www.youtube.com/watch?v=nI90XPjr7bI
[18] How To Choose Colors for Your Hyprland Desktop https://www.youtube.com/watch?v=Ubf42ajX-eM
[19] Dark mode switching https://wiki.archlinux.org/title/Dark_mode_switching
[20] New User Hyprland | Themes and personalization https://forum.garudalinux.org/t/new-user-hyprland-themes-and-personalization/39227

# Hardware Configuration

## Keyboard Layout & Variants

### Configuration in Hyprland

- Hyprland uses XKB for keyboard layout management, with settings placed in the `input` block of `~/.config/hypr/hyprland.conf` (or your custom config fragments).[1][2][3][4]
- To set multiple layouts and a switch key, use:

  ```
  input {
    kb_layout = us,ru   # Specify layouts: US and Russian
    kb_variant = ,      # Variant per layout, empty means default
    kb_options = grp:alt_shift_toggle # Alt+Shift toggles layout
  }
  ```
  - Replace layouts and options for your needs (e.g., add Arabic, German, French etc.).[5][3]

### Switch Keys & Options

- Popular toggles: `grp:alt_shift_toggle`, `grp:win_space_toggle`, etc.
- Example to switch with Super+Space:
  ```
  kb_options = grp:win_space_toggle
  ```
  Find all available toggles using:
  ```
  grep "grp:.*toggle" /usr/share/X11/xkb/rules/base.lst
  ```
  For layout codes and variants:
  ```
  grep -i 'NAME' /usr/share/X11/xkb/rules/base.lst
  ```
  where NAME is your language or variant.[6][1]

### On-the-Fly Switching

- You can switch layouts instantly (e.g., from scripts or binds) using:
  ```
  hyprctl switchxkblayout <layout-index>
  ```
  - Create binds for layout index changes, e.g.:
    ```
    bind = SUPER, x, exec, hyprctl switchxkblayout 1 # Switch to layout at index 1
    bind = SUPER, z, exec, hyprctl switchxkblayout 0 # Switch to layout at index 0
    ```
 .[7][3][8]

### Per-Device Config and Persistence

- If you have multiple keyboards or special devices, you can set layouts per device with:
  ```
  input {
      kb_file = <device-path> # For specific hardware
      kb_layout = us,de
      kb_variant = ,nodeadkeys
  }
  ```
  - Find device path via `ls /dev/input/by-id/`.[1]
- Restart Hyprland (logout/login) after modifying layout configs for full effect.[3][7][5]

### Additional Resources

- Reference: `/usr/share/X11/xkb/rules/base.lst`—full list of models, layouts, variants, options.[6]
- Changing console layout: Set `KEYMAP=us` in `/etc/vconsole.conf` for TTY, but this does not affect graphical sessions in Wayland/Hyprland.[9][10]

***

Related topics: Per-window layout manager, special language variants, troubleshooting dead keys or intl layouts.[11][12]

Sources
[1] Uncommon tips & tricks https://wiki.hypr.land/Configuring/Uncommon-tips--tricks/
[2] Keyboard layout in wayland - how to change - General https://discuss.cachyos.org/t/keyboard-layout-in-wayland-how-to-change/4120
[3] Change Keyboard Layout · end-4 dots-hyprland https://github.com/end-4/dots-hyprland/discussions/1448
[4] How to change keyboard variant? #2372 - hyprwm Hyprland https://github.com/hyprwm/Hyprland/discussions/2372
[5] [Bug]: After update can't change keyboard layout (language ... https://github.com/prasanthrangan/hyprdots/issues/1339
[6] Variables https://wiki.hypr.land/Configuring/Variables/
[7] Keyboard layout changing / Newbie Corner ... https://bbs.archlinux.org/viewtopic.php?id=293939
[8] Hyprland bind for switching all keyboard layouts, handling ... https://gist.github.com/martinkozle/6f622e36e5686751ef6ef90db33f4c36
[9] Arch Linux with Hyprland (2025 edition) - Richard Grundy https://rich.grundy.io/blog/arch-linux-with-hyprland-2025-edition/
[10] [SOLVED] Unable to type "ç" or "Ç" using ' + c on Wayland ... https://bbs.archlinux.org/viewtopic.php?id=301265
[11] Hyprland Per-Window Keyboard Layout Manager https://crates.io/crates/hyprland-per-window-layout
[12] Arch Linux + Hyprland-uwsm and Keyboard layout: US + ... https://github.com/ghostty-org/ghostty/discussions/8877
[13] ELI5: how do i change keyboard layout in hyprland https://www.reddit.com/r/hyprland/comments/xtxmv8/eli5_how_do_i_change_keyboard_layout_in_hyprland/
[14] How to Configure Keyboard Layout on Arch Linux https://www.siberoloji.com/how-to-configure-keyboard-layout-on-arch-linux/
[15] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[16] Switch US keyboard variant from 'intl' to 'default' in Xorg ... https://gist.github.com/datsfilipe/0f67bdf0a0ae4bba4080097ed8a79c6c
[17] Hyprland keyboard layout issue https://forum.garudalinux.org/t/hyprland-keyboard-layout-issue/33473
[18] How I change keyboard layout? - Issues & Assistance https://discuss.cachyos.org/t/how-i-change-keyboard-layout/15038
[19] Installing Arch Linux & Hyprland. My Development ... https://www.youtube.com/watch?v=iykD_ELku7g
[20] Master tutorial https://wiki.hypr.land/Getting-Started/Master-Tutorial/

## Typematic Delay & Rate

### Hyprland Configuration

- Hyprland provides direct options to set keyboard repeat rate (characters per second) and delay (milliseconds before repeat starts) in the `input` block of your `~/.config/hypr/hyprland.conf` file.[1][2][3][4]
- Example configuration:
  ```
  input {
      repeat_rate = 35     # Repeats per second
      repeat_delay = 200   # Delay in milliseconds before repeat starts
  }
  ```
- These values replace the old `xset r rate` settings used on Xorg and are handled natively by the Wayland compositor (Hyprland).[5][6]

### Per-Device Configuration

- For multiple keyboards, you may override repeat rate/delay per device in the same config as:
  ```
  input {
      kb_file = /dev/input/by-id/your-keyboard
      repeat_rate = 50
      repeat_delay = 500
  }
  ```
  - Default/global settings are overridden by specific device blocks.[7][8]

### Changes and Troubleshooting

- Save your configuration and then reload Hyprland (or restart your session) for changes to take effect.
- If you want to experiment, lowering `repeat_delay` makes repeats start faster, and increasing `repeat_rate` increases the speed of repeat events.[2][3]
- These settings are effective across all applications run in your Wayland session; apps do not typically need or override their own repeat rates unless managed through the compositor.[3]

***
Related topics: Per-keyboard settings, repeat and binding flags, compatibility with scripts and automated configuration.

Sources
[1] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/
[2] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[3] Hyprland on Arch — Minimal Setup Guide - Tony, btw. https://www.tonybtw.com/tutorial/hyprland/
[4] Variables - Hyprland Wiki https://wiki.hyprland.org/0.45.0/Configuring/Variables/
[5] is there a way to change the key repeat rate? - hyprland - Reddit https://www.reddit.com/r/hyprland/comments/134qtko/is_there_a_way_to_change_the_key_repeat_rate/
[6] Basic Config · hyprwm/Hyprland Wiki - GitHub https://github.com/hyprwm/Hyprland/wiki/Basic-Config/b1bd6a563aa109de0918b1573e3e8a52d4413990
[7] Keywords - Hyprland Wiki https://wiki.hyprland.org/0.48.0/Configuring/Keywords/
[8] Keywords https://wiki.hyprland.org/0.41.0/Configuring/Keywords/
[9] How to set keyboard delay/repeat rate in Wayland? - NixOS Discourse https://discourse.nixos.org/t/how-to-set-keyboard-delay-repeat-rate-in-wayland/56982
[10] Remapping keys and setting repeat rate under Sway/Wayland #5207 https://github.com/swaywm/sway/issues/5207
[11] Key repeat not working for raise/lower volume · Issue #1231 https://github.com/hyprwm/Hyprland/issues/1231
[12] hyprland-wiki/pages/Configuring/Variables.md at hyprpm https://code.hyprland.org/hyprwm/hyprland-wiki/src/branch/hyprpm/pages/Configuring/Variables.md
[13] Make the key repeat timer use the keyboard that triggered ... https://github.com/hyprwm/Hyprland/issues/10978
[14] hyprwm/Hyprland https://code.hyprland.org/hyprwm/Hyprland/commits/tag/v0.20.0beta?page=40
[15] Binds https://wiki.hypr.land/Configuring/Binds/
[16] hyprwm/Hyprland https://code.hyprland.org/hyprwm/Hyprland/commits/tag/v0.20.0beta/src?page=31
[17] Your OS' Keyboard Repeat Delay and Rate Settings Are ... - YouTube https://www.youtube.com/watch?v=4UnmzovK_eM
[18] Binds | Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Configuring/Binds/

## Keyboard Backlight

### Standard Controls (Wayland/Hyprland)

- Use the `brightnessctl` utility for most laptops and supported keyboards:
  - List available devices:  
    ```
    brightnessctl --list
    ```
  - Get keyboard backlight info:
    ```
    brightnessctl --device='*::kbd_backlight' info
    ```
  - Set brightness (50% in this example):
    ```
    brightnessctl --device='*::kbd_backlight' set 50%
    ```
  - Increase (`33%+`) or decrease (`33%-`) with binds in Hyprland config.[1][2]

- Symlinked sysfs:  
  Manually set with:
  ```
  echo LEVEL | sudo tee /sys/class/leds/*::kbd_backlight/brightness
  ```
  Replace `LEVEL` with a number from `0` (off) up to the maximum for your device. Find max with:
  ```
  cat /sys/class/leds/*::kbd_backlight/max_brightness
  ```

### D-Bus & Scripting

- D-Bus interface via UPower works universally and doesn't require direct sysfs access or special permissions. Example Python script using dbus (see [Arch Wiki guide]):[1]
  ```
  #!/usr/bin/env python3
  import dbus
  bus = dbus.SystemBus()
  kbd = bus.get_object('org.freedesktop.UPower', '/org/freedesktop/UPower/KbdBacklight')
  iface = dbus.Interface(kbd, 'org.freedesktop.UPower.KbdBacklight')
  iface.SetBrightness(new_level)
  ```
  - Bind such scripts to keys in your Hyprland config for full integration.[1]

### Hyprland Keybinding Example

- Example Hyprland config for backlight keys:
  ```
  bind = XF86KbdBrightnessUp, exec, brightnessctl --device='*::kbd_backlight' set +1
  bind = XF86KbdBrightnessDown, exec, brightnessctl --device='*::kbd_backlight' set 1-
  ```
  - Modern laptops often register special keys (`XF86KbdBrightnessUp/Down`); use `evtest` or `showkey` to find your keycodes if needed.[2][3]

### Notification Integration

- Add notification support with `notify-send` after changing brightness for visual feedback, or use enhanced notification scripts as outlined in the Hyprland Wiki example.[2]

### Notes and Troubleshooting

- Some custom or RGB keyboards require device-specific tools (e.g., OpenRGB or manufacturer utilities); standard sysfs or brightnessctl controls physical white backlighting on supported models.[4][5]
- Key backlight controls are hardware/vendor-dependent; if not working, check that the relevant `::kbd_backlight` device appears under `/sys/class/leds/` and that your user is in the `video` or appropriate group for permissions.[1]

***

Related topics: OpenRGB for per-key color, Fn/media key binding in Hyprland, integrating keyboard backlight state with system notifications.

Sources
[1] Keyboard backlight - ArchWiki https://wiki.archlinux.org/title/Keyboard_backlight
[2] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[3] Hyprland on Arch — Minimal Setup Guide - Tony, btw. https://www.tonybtw.com/tutorial/hyprland/
[4] Keyboard backlight color/uptime control by any means ... https://bbs.archlinux.org/viewtopic.php?id=284617
[5] Configuring LED Spacers and Keyboard colors on Arch Linux https://community.frame.work/t/configuring-led-spacers-and-keyboard-colors-on-arch-linux/51897
[6] volume and brightness controls (arch) : r/hyprland https://www.reddit.com/r/hyprland/comments/1cdumym/volume_and_brightness_controls_arch/
[7] [SOLVED]brightness button fails to properly map on hyprland https://bbs.archlinux.org/viewtopic.php?id=303898
[8] Backlit of my custom keyboard is not working even after the ... https://github.com/hyprwm/Hyprland/issues/7344
[9] Turn on keyboard backlight/leds on wayland (xset ... https://gist.github.com/ps1dr3x/b15c62eafb388ddf8bb7d3896d1a1cee
[10] A daemon to control my keyboard backlight https://github.com/GambolingPangolin/KbdBacklight
[11] Backlight - ArchWiki https://wiki.archlinux.org/title/Backlight
[12] Turning On Keyboard Backlight in KDE Plasma 6.1 ... https://discuss.kde.org/t/turning-on-keyboard-backlight-in-kde-plasma-6-1-wayland-looking-for-tips/18143
[13] Backlit of my custom keyboard is not working even after the ... https://www.reddit.com/r/archlinux/comments/1esr4ne/backlit_of_my_custom_keyboard_is_not_working_even/
[14] Uncommon tips & tricks https://wiki.hypr.land/Configuring/Uncommon-tips--tricks/
[15] Are there any PERMANENT commands to turn on ... https://www.reddit.com/r/wayland/comments/1aygvrq/are_there_any_permanent_commands_to_turn_on/
[16] How to Rice Hyprland (Part 2) | Brightness, Volume and ... https://www.youtube.com/watch?v=EajYMqfdAEo
[17] How to turn on keyboard led - fedora 39 with Wayland? https://discussion.fedoraproject.org/t/how-to-turn-on-keyboard-led-fedora-39-with-wayland/95892
[18] How do you guys change brightness levels with keys like ... https://www.facebook.com/groups/240120563956894/posts/975733813728895/
[19] Adjusting brightness on Wayland compositors without built- ... https://forums.freebsd.org/threads/adjusting-brightness-on-wayland-compositors-without-built-in-support-for-it.97881/
[20] Keyboard backlight fading on and off - Support https://forum.manjaro.org/t/keyboard-backlight-fading-on-and-off/139411
[21] You're Probably Doing Screen Brightness in Arch Linux ... https://www.youtube.com/watch?v=pGOaSS8nEQA

## Screen Brightness

### Primary Tools and Methods

- Brightness is typically managed with the `brightnessctl` utility, compatible with most laptops on Hyprland and Arch Linux.[1][2][3]
- Common usage:
  ```
  brightnessctl --list
  brightnessctl info
  brightnessctl set 50%
  brightnessctl set +5%
  brightnessctl set 5%-
  ```
  - Use `--device=backlight` if you have multiple backlight devices or want to target a specific screen.

### Sysfs Manual Option

- Advanced users may directly write values to sysfs for supported devices:
  ```
  echo VALUE | sudo tee /sys/class/backlight/intel_backlight/brightness
  cat /sys/class/backlight/intel_backlight/max_brightness  # to find max value
  ```
  - Replace `intel_backlight` with actual device name.[1]

### Hyprland Keybinding Integration

- Configure hardware keys in `~/.config/hypr/hyprland.conf` (or fragments):
  ```
  bind = XF86MonBrightnessUp, exec, brightnessctl set +5%
  bind = XF86MonBrightnessDown, exec, brightnessctl set 5%-
  ```
  - Media keys (XF86MonBrightnessUp/Down) map to brightness if supported by hardware and kernel input drivers.[2][3][4]
  - Use `evtest` or `showkey` to identify key codes if necessary.

### Notification Feedback

- For instant feedback, stack a notification:
  ```
  bind = XF86MonBrightnessUp, exec, brightnessctl set +5% && notify-send "Brightness Increased"
  ```
  - Mako works well for notifications.[2]

### Notes & Troubleshooting

- If brightness control does not work:
  - Ensure user is in the necessary groups (`video`, sometimes `input`).
  - Try different device names in `/sys/class/backlight/` or with `brightnessctl --list`.
  - Some desktop monitors do not support software brightness control; use hardware buttons.[1]

- For advanced hardware (HDR, multi-backlight setups, OLED): consult manufacturer-specific utilities or kernel modules—`brightnessctl` is for standard ACPI/backlight compliant screens.[1]

***

Related topics: Auto brightness scripts, hardware button mapping, notification integration, multi-monitor brightness with DPMS.

Sources
[1] Backlight - ArchWiki https://wiki.archlinux.org/title/Backlight
[2] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[3] How to Rice Hyprland (Part 2) | Brightness, Volume and ... https://www.youtube.com/watch?v=EajYMqfdAEo
[4] volume and brightness controls (arch) : r/hyprland https://www.reddit.com/r/hyprland/comments/1cdumym/volume_and_brightness_controls_arch/

## Audio Control

### Recommended Audio Stack

- PipeWire is the preferred audio server for Hyprland on Arch Linux, replacing PulseAudio and working seamlessly under Wayland.[1][2][3]
- Ensure the following packages are installed:
  ```
  sudo pacman -S pipewire wireplumber pipewire-pulse pamixer pavucontrol
  ```
  - `pamixer` allows CLI volume control, and `pavucontrol` is a graphical mixer interface.[4][1]

### Setting Up & Services

- Enable and start services:
  ```
  systemctl --user enable pipewire pipewire-pulse wireplumber
  systemctl --user start pipewire pipewire-pulse wireplumber
  ```
  - After installation, reboot to make sure PipeWire replaces PulseAudio fully.[2][1]

### Volume and Mute Keybindings

- Add audio bindings to your Hyprland configuration:
  ```
  bind = , XF86AudioRaiseVolume, exec, pamixer -i 5
  bind = , XF86AudioLowerVolume, exec, pamixer -d 5
  bind = , XF86AudioMute, exec, pamixer -t
  bind = , XF86AudioMicMute, exec, pamixer --default-source -m
  ```
  - Use `XF86Audio*` keys for volume/media controls.[5][6]
  - For more feedback, combine with notifications using `notify-send`.

### Waybar and Mixer Integration

- For on-screen volume control, use Waybar’s modules, or graphical tools like `pavucontrol`.[7][4]
- Change audio devices or outputs with Waybar, `pavucontrol`, or CLI tools (`pamixer --list-sources`).[7]

### Troubleshooting

- If volume resets unexpectedly, disable conflicting ALSA store/restore services:
  ```
  systemctl --user disable alsa-restore alsa-store
  ```
  - Make sure only PipeWire manages the sound devices.[8]
- For device selection and advanced configuration, edit `/etc/pipewire/pipewire.conf` or use `pavucontrol` for graphical management.[1][7]
- Use `wev` (Wayland) or `evtest` to identify keycodes if media keys aren’t mapped correctly.[9]

***

Related topics: Audio device switching, notification feedback, microphone mute toggling, PipeWire session configuration.

Sources
[1] Resolving Audio Issues on Arch Linux with Hyprland: A Step-by ... https://dev.to/laithalenooz/resolving-audio-issues-on-arch-linux-with-hyprland-a-step-by-step-guide-2n
[2] setting up pipewire on hyprland : r/archlinux https://www.reddit.com/r/archlinux/comments/17v7a4e/setting_up_pipewire_on_hyprland/
[3] What is recommeded: Pulseaudio or Pipewire? - Sound https://forum.manjaro.org/t/what-is-recommeded-pulseaudio-or-pipewire/131764
[4] Arch Linux, Pacman, Pipewire, Pavucontrol | Graphical User Interface https://www.youtube.com/watch?v=EcMLI3dYMmI
[5] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[6] Keyboard Volume Controls : r/hyprland https://www.reddit.com/r/hyprland/comments/1f2wi1m/keyboard_volume_controls/
[7] How to change audio device in Garuda Hyprland? https://forum.garudalinux.org/t/how-to-change-audio-device-in-garuda-hyprland/39702
[8] [SOLVED] Basic audio setup help, alsa and pipewire conflicting? https://bbs.archlinux.org/viewtopic.php?id=302578
[9] [SOLVED] Volume button on wireless headphones works ... https://bbs.archlinux.org/viewtopic.php?id=301874
[10] Best way to configure audio and WiFi? - hyprland - Reddit https://www.reddit.com/r/hyprland/comments/1f8ms95/best_way_to_configure_audio_and_wifi/
[11] Pipewire/pulseaudio does not work on hyprland (home- ... https://discourse.nixos.org/t/pipewire-pulseaudio-does-not-work-on-hyprland-home-manager/55771
[12] How to Rice Hyprland (Part 2) | Brightness, Volume and ... https://www.youtube.com/watch?v=EajYMqfdAEo
[13] How to Install Arch Linux and Hyprland (Part 2 of 2) - John Ling https://www.johnling.me/blog/Hyprland-Guide
[14] JaKooLit/Arch-Hyprland: For automated installation of ... https://github.com/JaKooLit/Arch-Hyprland
[15] Arch Linux - Audio Devices Menu (EWW Widget) Hyprland - YouTube https://www.youtube.com/watch?v=-OGKUgHJVL4
[16] Binds https://wiki.hypr.land/Configuring/Binds/
[17] pipewire/INSTALL.md at 1.4 - fdo-mirrors ... https://code.hyprland.org/fdo-mirrors/pipewire/src/branch/1.4/INSTALL.md
[18] Arch Linux with Hyprland: A Beginner's Guide - Tiesen https://tiesen.id.vn/blogs/arch-linux-hyprland-setup
[19] [Feature] Button to Mute/Unmute Mic in top-bar · Issue #367 https://github.com/end-4/dots-hyprland/issues/367
[20] Arch Install and Hyprland setup - YouTube https://www.youtube.com/watch?v=lfUWwZqzHmA

## Touchpad Configuration

### Basic Setup

- Hyprland uses libinput for touchpad management; most configuration is done in the `input` block of `~/.config/hypr/hyprland.conf`.[1][2]
- Example:
  ```
  input {
    touchpad {
      natural_scroll = yes
      tap-to-click = yes
      clickfinger_behavior = yes
      scroll_factor = 1.0
      sensitivity = 0.0
    }
  }
  ```
  - Boolean options accept `yes/no`, `true/false`, or `1/0`.[3]

### Common Touchpad Options

| Option                | Effect                                |
|-----------------------|---------------------------------------|
| `natural_scroll`      | Scroll direction (yes for "natural")  |
| `tap-to-click`        | Enable tap-to-click                   |
| `clickfinger_behavior`| Multi-finger tap as right click       |
| `scroll_factor`       | Pointer speed for scrolling           |
| `sensitivity`         | Touchpad sensitivity (-1.0 to 1.0)    |
| `tap-and-drag`        | Enable tap-and-drag (default: yes)    |
| `flip_x/flip_y`       | Reverse axes if needed                |
| `enabled`             | Enable/disable touchpad               |

- Example for disabling:
  ```
  input {
    touchpad {
      enabled = false
    }
  }
  ```
  Or dynamically:
  ```
  hyprctl keyword "device[YOUR_TOUCHPAD]:enabled" false
  ```

### Per-Device Customization

- Find your device name:
  ```
  hyprctl devices
  ```
- Configure specific devices:
  ```
  device {
    name = YOUR_TOUCHPAD
    sensitivity = -0.3
    scroll_factor = 0.9
  }
  ```
  - Per-device configs override input block settings for that hardware.[4]

### Advanced Gestures

- For more gestures, use the community tool `libinput-gestures` with custom scripts or bindings for actions like multi-finger swipes. Hyprland’s built-in gesture support is limited; expand with external utilities as needed.[5][6]

### Troubleshooting

- If touchpad isn’t detected, confirm device appears in `hyprctl devices` or `libinput list-devices`. Check for kernel/driver issues with system logs.[7][8][9]
- Synaptics-specific options require the legacy Xorg driver; prefer libinput for Wayland setups.[10]
- Change pointer speed with `sensitivity`, or use `xinput` for Xorg fallback if necessary (not recommended for Hyprland/Wayland).[11][12]

***

Related topics: Multi-monitor pointer mapping, gesture integration, disabling/enabling on the fly, hardware quirks, libinput documentation.

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables https://wiki.hypr.land/Configuring/Variables/
[3] Two finger right click · hyprwm Hyprland · Discussion #921 https://github.com/hyprwm/Hyprland/discussions/921
[4] Keywords https://wiki.hyprland.org/0.45.0/Configuring/Keywords/
[5] Recommendations for multitouch gestures in Hyprland on NixOS? https://discourse.nixos.org/t/recommendations-for-multitouch-gestures-in-hyprland-on-nixos/46880
[6] Linux Cookbook #2: Hyprland - Bahadır Aydın https://bahadiraydin.com/blog/linux-cookbook-hyprland
[7] Touchpad not working on Hyprland - Reddit https://www.reddit.com/r/hyprland/comments/1hymuxy/touchpad_not_working_on_hyprland/
[8] Why doesn't hyprland see the touchpad? - Arch Linux Forums https://bbs.archlinux.org/viewtopic.php?id=297947
[9] How to Install and Configure Hyprland (Wayland) on Arch Linux https://www.siberoloji.com/arch-linux-howtos-install-and-configure-hyprland-wayland/
[10] Touchpad Synaptics - ArchWiki https://wiki.archlinux.org/title/Touchpad_Synaptics
[11] How to increase touchpad speed permanantly on hyprland? - Newbie https://forum.endeavouros.com/t/how-to-increase-touchpad-speed-permanantly-on-hyprland/50159
[12] Change Touchpad Speed : r/hyprland https://www.reddit.com/r/hyprland/comments/1e26nok/change_touchpad_speed/
[13] How to disable touchpad on hyprland - Newbie - EndeavourOS Forum https://forum.endeavouros.com/t/how-to-disable-touchpad-on-hyprland/50134
[14] How to configure libinput under gnome wayland? - Reddit https://www.reddit.com/r/linuxquestions/comments/asanqt/how_to_configure_libinput_under_gnome_wayland/
[15] Change touchpad sensitivity · Issue #4457 · hyprwm/Hyprland - GitHub https://github.com/hyprwm/Hyprland/issues/4457
[16] any one here have good config for laptop touchpad https://www.reddit.com/r/hyprland/comments/1etnrzt/any_one_here_have_good_config_for_laptop_touchpad/
[17] Touchpad Disable · hyprwm Hyprland · Discussion #6900 - GitHub https://github.com/hyprwm/Hyprland/discussions/6900
[18] Ability to disable libinput Tapping Drag enabled · Issue #2179 - GitHub https://github.com/hyprwm/Hyprland/issues/2179
[19] Setting up touchpad gestures on Arch Linux - YouTube https://www.youtube.com/watch?v=RovI4g-x5d4
[20] Customizing Hyprland to Your Liking - It's FOSS https://itsfoss.com/configuring-hyprland/

## Device Enable/Disable

### Static (Config File) Control

- Devices (touchpad, mouse, keyboard, etc.) can be enabled or disabled in the `~/.config/hypr/hyprland.conf` using the `device` block:
  ```
  device {
    name = <device_name>
    enabled = false
  }
  ```
  - Get accurate device names from:
    ```
    hyprctl devices
    ```
  - Replace `<device_name>` with the string exactly as shown in the output.[1][2]

### Dynamic Control (On-the-Fly)

- You can enable or disable devices during a running session with `hyprctl`:
  ```
  hyprctl keyword "device[<device_name>]:enabled" false
  hyprctl keyword "device[<device_name>]:enabled" true
  ```
  - This takes effect immediately and does not require a restart.[3][4][1]

- Sample Hyprland config for toggling with a keybind:
  ```
  bind = $mainMod, t, exec, hyprctl keyword "device[<device_name>]:enabled" false
  bind = $mainMod Shift, t, exec, hyprctl keyword "device[<device_name>]:enabled" true
  ```
  - Replace `$mainMod` and `<device_name>` as needed.[1]

### Notes and Caveats

- Device names are case-sensitive and must be exact as listed by `hyprctl devices`.[3]
- Previous syntax (`device:<name>:enabled`) is deprecated; always use the square bracket/colon style:
  ```
  hyprctl keyword "device[my-touchpad]:enabled" false
  ```
- Changes via config file require session reload or restart, whereas `hyprctl` changes are instant but not persistent after reboot.[3][1]

***

Related topics: Per-device configuration, batch toggling, hotplugging caveats, scripting with udev rules for event-driven enable/disable.

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Help with disabling a input device - hyprland https://www.reddit.com/r/hyprland/comments/1c09gq0/help_with_disabling_a_input_device/
[3] Dynamically Enable/disable device : r/hyprland https://www.reddit.com/r/hyprland/comments/1bqohmd/dynamically_enabledisable_device/
[4] Cannot disable device as default · Issue #8458 https://github.com/hyprwm/Hyprland/issues/8458
[5] Cannot configure input devices through hyprctl #5195 https://github.com/hyprwm/Hyprland/issues/5195
[6] Monitors https://wiki.hypr.land/Configuring/Monitors/
[7] Hyprctl devices doesn't detect new devices : r/hyprland - Reddit https://www.reddit.com/r/hyprland/comments/13m1olc/hyprctl_devices_doesnt_detect_new_devices/
[8] Using hyprctl https://wiki.hypr.land/Configuring/Using-hyprctl/
[9] Run script on monitor plug in : r/hyprland - Reddit https://www.reddit.com/r/hyprland/comments/19bn9u4/run_script_on_monitor_plug_in/
[10] Disable keyboard with a bind · hyprwm Hyprland https://github.com/hyprwm/Hyprland/discussions/4283
[11] How to disable touchpad on hyprland - Newbie https://forum.endeavouros.com/t/how-to-disable-touchpad-on-hyprland/50134
[12] [SOLVED] udev rule for hotplugging monitor in gnome (wayland ... https://bbs.archlinux.org/viewtopic.php?id=283775
[13] Variables https://wiki.hypr.land/Configuring/Variables/
[14] A Noobs Guide to Hyprland | EP:6 - Devices & Environment https://www.youtube.com/watch?v=TQpUQQP7AuE
[15] Disable hotplug (auto-detect) of input devices, and pre-configure ... https://github.com/hyprwm/Hyprland/issues/9840
[16] Using hyprctl https://wiki.hyprland.org/0.41.0/Configuring/Using-hyprctl/
[17] Variables https://wiki.hyprland.org/0.45.0/Configuring/Variables/
[18] Hyprland Hot-Fixes | Josh's Notes https://notes.joshrnoll.com/notes/hyprland-hot-fixes/
[19] Binds https://wiki.hyprland.org/0.46.0/Configuring/Binds/
[20] Configuring Hyprland to Disable the Laptop Screen when ... https://www.youtube.com/shorts/deZlxPWVuN4

# Troubleshooting

## Common Issues

### Configuration Syntax & Reload Problems

- Config changes (e.g., keybindings, monitor settings, input options) may not apply if the syntax is incorrect or if the config is not reloaded—`hyprctl reload` or a full session restart is often needed for major changes.[1][2]
- Misplaced sections, wrong value formats, or missing required options can silently fail (e.g. using outdated or incorrect syntax).[3][1]

### Window & Keybinding Issues

- Some keybindings appear unreliable if set improperly, or due to modifier conflicts (e.g. Super, Ctrl, Shift used in nonstandard order).[2][1]
- Closing/focusing/highlighting windows may not work for XWayland or legacy apps without additional rules/binds.[2]
- "Kill active" can be added for reliably closing windows:
  ```
  bind = SUPER, X, killactive
  ```

### Drop-down/Popup Problems

- Disappearing popups in Steam, VSCode, and others often require windowrule fixes:
  ```
  windowrule = stayfocused, title:^(TITLE)$, class:^(CLASS)$
  ```
  Solutions depend on class/title from `hyprctl clients`.[2]

### Monitor & Multi-Monitor Issues

- Phantom monitors (e.g., `Unknown-1`) may break workspace or window management. Add
  ```
  monitor = Unknown-1,disabled
  ```
  to hide them.[4][2]

- Monitor-related crashes or blank screens—check kernel, drivers, and monitor definitions in config. For NVIDIA, using the proprietary driver and setting up `hyprland.conf` as recommended is crucial.[5]

### Audio & PipeWire Issues

- Sound issues are common when switching from PulseAudio to PipeWire. Ensure only PipeWire services are enabled; reboot after installing to avoid conflicts.[6][7][8]
- Volume resets: disable `alsa-restore` and conflicting alsa services.[7]

### Application Compatibility

- Legacy apps, complex debug tools, and some file pickers may fail or behave strangely under Wayland/Hyprland; using portals (`xdg-desktop-portal-gtk`) and flatpak-compatible versions may help.[9][2]

### Performance, Stability, & Crashes

- Frequent or random Hyprland crashes—enable debug logs in config, check for phantom devices, and ensure current/compatible kernel and drivers.[10][11][12]
- Shader, texture, or drag-and-drop issues—verify dependencies, file paths, and correct shader locations in config/logs.[13][14][9]

### Miscellaneous Problems

- Symbol lookup or `.so` errors: often caused by mismatched or outdated -git packages. Reinstall all Hyprland-related packages, preferably with a clean build.[2]
- Wayland session failing to start: Commonly missing `polkit` or `seatd.service`, so enable/start required polkit and session services.[15]

***

Related topics: Environment variable propagation, kernel bug workarounds for devices, window rule management for apps, scaling and HiDPI tweaks, session manager confusion.

Sources
[1] Issues using Hyprland https://www.reddit.com/r/hyprland/comments/1ccq69p/issues_using_hyprland/
[2] FAQ https://wiki.hypr.land/FAQ/
[3] [Issue] Tons of errors config when loading hyprland #419 https://github.com/end-4/dots-hyprland/issues/419
[4] How to fix scaling issue in Arch Linux and Hyprland without ... https://www.facebook.com/groups/GNUAndLinux/posts/10171609294630019/
[5] FAQ https://wiki.hyprland.org/0.41.0/FAQ/
[6] Resolving Audio Issues on Arch Linux with Hyprland https://dev.to/laithalenooz/resolving-audio-issues-on-arch-linux-with-hyprland-a-step-by-step-guide-2n
[7] [SOLVED] Basic audio setup help, alsa and pipewire conflicting? https://bbs.archlinux.org/viewtopic.php?id=302578
[8] setting up pipewire on hyprland : r/archlinux https://www.reddit.com/r/archlinux/comments/17v7a4e/setting_up_pipewire_on_hyprland/
[9] Drag and drop does not work in Hyprland (Wayland) #7644 https://github.com/hyprwm/Hyprland/issues/7644
[10] [SOLVED] Frequent and Random Crashes on Hyprland ... https://bbs.archlinux.org/viewtopic.php?id=302511
[11] Crashes and Bugs https://wiki.hypr.land/Crashes-and-Bugs/
[12] Perfomance issues when using Hyprland. #2637 https://github.com/hyprwm/Hyprland/issues/2637
[13] Hyprland Crashes No Matter What https://www.reddit.com/r/hyprland/comments/1lqchfn/hyprland_crashes_no_matter_what/
[14] Performance Issues & Texture Problems Arch(hyprland) #463 https://github.com/an-anime-team/an-anime-game-launcher/issues/463
[15] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[16] [Bug]: Cannot start hyprland (fresh archlinux install) #727 https://github.com/prasanthrangan/hyprdots/issues/727
[17] Fixing AL Language Extension Debugger on Linux ... https://stefanmaron.onrender.com/posts/fixing-al-debugger-linux-wayland/
[18] Other - [Wayland] Hyprland 0.49.0 Update Breaks Everything https://forums.freebsd.org/threads/wayland-hyprland-0-49-0-update-breaks-everything.97832/
[19] Switching to Wayland (Hyprland) from X11 (Plasma) / ... https://bbs.archlinux.org/viewtopic.php?id=303092
[20] Troubleshooting/FAQ | illogical-impulse - GitHub Pages https://end-4.github.io/dots-hyprland-wiki/en/ii-qs/04troubleshooting/
[21] My Problem With Arch Linux Packaging https://www.youtube.com/watch?v=zsyX04mn2_Q
[22] Problems running hyprland: Solved https://bbs.archlinux.org/viewtopic.php?id=306076

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

## JetBrains Applications

### Common Problems on Hyprland

- **Focus issues** (dragging tabs or losing window focus) can appear with the latest Hyprland and JetBrains IDEs, especially with Wayland-native support. This includes problems rearranging icons, dragging tabs, or autocompletion popups stealing focus.[1][2][3]
- **Massive flickering, border flashing, or mouse unresponsiveness** are commonly reported after Hyprland updates. Disabling early buffer release and setting specific window rules in `hyprland.conf` often relieves flickering and dialog focus bugs.[4][5]
- **Scaling and blurry text** (especially on HiDPI): XWayland does not properly support fractional scaling, producing blurry UI or oddly sized elements. Native Wayland support is much improved as of JetBrains 2024.2 EAP—enable via VM options as shown below.[6][7][8]

### Recommended Solutions

#### 1. Enable Wayland Toolkit (Native Mode)
- Add to JetBrains VM options:
  ```
  -Dawt.toolkit.name=WLToolkit
  ```
  - Go to **Help → Edit Custom VM Options** in your JetBrains IDE and append this line, then restart the app for native Wayland toolkit support.[7][8]
- This removes many scaling and input bugs, dramatically improving experience on Hyprland.

#### 2. Hyprland Window Rules & Buffer Settings
Add the following to `~/.config/hypr/hyprland.conf`:
  ```
  render {
    allow_early_buffer_release = 0
  }
  windowrulev2=noinitialfocus,xwayland:1
  windowrulev2=noinitialfocus,class:jetbrains-toolbox,floating:1
  windowrulev2=noinitialfocus,class:(jetbrains-)(.*),title:^$,initialTitle:^$,floating:1
  windowrulev2=center,class:(jetbrains-)(.*),title:^$,initialTitle:^$,floating:1
  windowrulev2=center,class:(jetbrains-)(.*),initialTitle:(.+),floating:1
  ```
  - Adjust the class/title regex for your specific JetBrains app if needed.[2][4]

#### 3. Drag & Drop/Popup Bugs
- Some drag-and-drop and popup issues are not fully fixed with config and may require you to report upstream to JetBrains. These are typically recognized as ongoing bugs and may be specific to Hyprland.[3][9][8]

#### 4. Fractional Scaling
- Avoid fractional scaling in Hyprland when using JetBrains IDEs; use integer scales and the IDE's zoom feature for best clarity if Wayland support is unavailable or buggy.[8][6]

#### 5. XWayland Workaround for Electron/Java Apps
- For persistent issues, you may force running via XWayland by adding
  ```
  env = ELECTRON_OZONE_PLATFORM_HINT,x11
  ```
  to your Hyprland config, but modern JetBrains IDEs should prefer Wayland with proper toolkit options.[2]

### Notes and Upstream/Long-Term Fixes

- Some issues remain without workaround due to Wayland toolkit bugs upstream in JetBrains. Monitor the JetBrains [YouTrack](https://youtrack.jetbrains.com/issues) and Hyprland GitHub for fixes and updates.[4][8]
- Periodically check for JetBrains EAP/beta releases with improved Wayland support.

***

Related topics: Java/GTK/QML window rules, focus workaround scripts, scaling and display DPI, window manager hints for IDEs, and reporting to JetBrains/IJPL.

Sources
[1] Anyone got focus problems with jetbrains IDEs on latest hyprland? https://www.reddit.com/r/hyprland/comments/1kup9o4/anyone_got_focus_problems_with_jetbrains_ides_on/
[2] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[3] Dragging/reordering tabs is nearly impossible in Wayland native mode https://youtrack.jetbrains.com/projects/IJPL/issues/IJPL-171564/Dragging-reordering-tabs-is-nearly-impossible-in-Wayland-native-mode
[4] Intellij is flickering heavily making it hard to work #9355 - GitHub https://github.com/hyprwm/Hyprland/issues/9355
[5] How To Fix Jetbrains IDE border flickering on Hyprland https://www.youtube.com/watch?v=cXcU48ym7d0
[6] Blurry text when using Sway or fractional scaling on Wayland https://intellij-support.jetbrains.com/hc/en-us/articles/4403794663570-Blurry-text-when-using-Sway-or-fractional-scaling-on-Wayland
[7] How to fix JetBrains IDE scaling issues on Wayland ... https://pliszko.com/blog/post/2025-08-18-how-to-fix-jetbrains-ide-scaling-on-wayland
[8] Wayland/hyprland: incorrect popup scale (reopen) : JBR-8356 https://youtrack.jetbrains.com/projects/JBR/issues/JBR-8356/Wayland-hyprland-incorrect-popup-scale-reopen
[9] Jetbrains IDE Rider/CLion - Bugs / FRs / Support - Hyprland Forum https://forum.hypr.land/t/jetbrains-ide-rider-clion/515
[10] Popups are not in the center of the screen (Wayland/Hyprland) https://youtrack.jetbrains.com/tickets/IJPL-61714/Popups-not-working-correctly-with-Wayland-Hyprland
[11] Abnormal Display in JetBrains IDEs · Issue #5942 https://github.com/hyprwm/Hyprland/issues/5942
[12] Wayland - ArchWiki https://wiki.archlinux.org/title/Wayland
[13] Screen flickering when using hyprland - Newbie https://forum.endeavouros.com/t/screen-flickering-when-using-hyprland/64723
[14] Issues with Jetbrain rider and Wayland : r/archlinux https://www.reddit.com/r/archlinux/comments/1km9olx/issues_with_jetbrain_rider_and_wayland/
[15] When using the Wayland toolkit, the Titlebar buttons do not respect ... https://youtrack.jetbrains.com/projects/IJPL/issues/IJPL-196221/When-using-the-Wayland-toolkit-the-Titlebar-buttons-do-not-respect-window-manager-hints
[16] Bugs / FRs / Support https://forum.hypr.land/c/support/13
[17] Unable to install IntelliJ in Arch Linux, Sway https://intellij-support.jetbrains.com/hc/en-us/community/posts/4402682513426-Unable-to-install-IntelliJ-in-Arch-Linux-Sway
[18] Wayland: support input methods (text-input-unstable-v3) : JBR-5672 https://youtrack.jetbrains.com/projects/JBR/issues/JBR-5672/Wayland-support-input-methods
[19] Flickering / Flashing / Refreshing UI? https://intellij-support.jetbrains.com/hc/en-us/community/posts/360006784180-Flickering-Flashing-Refreshing-UI
[20] HiDPI configuration https://intellij-support.jetbrains.com/hc/en-us/articles/360007994999-HiDPI-configuration

## XWayland Compatibility

### Overview

- XWayland allows legacy X11 applications to run inside Wayland compositors like Hyprland.[1]
- Most traditional Linux apps that do not have native Wayland support will seamlessly start under XWayland, but with some caveats regarding performance, input lag, and scaling.[2][3]

### Key Issues and Workarounds

- **Scaling and HiDPI**: Fractional scaling is not well supported; XWayland clients often appear blurry unless using integer scaling. Stick to scale factors of 1 or 2 for best quality, and use per-app zoom when available.[4][5]
- **Clipboard and Drag-and-Drop**: Most clipboard managers work with XWayland apps, but advanced features or rich content copying (especially images/formats) may fail intermittently.[6][2]
- **Input Issues**: Some X11 apps (such as older games or Java UIs) may have keyboard, focus, or mouse problems. Window rules and input remapping in `hyprland.conf` can resolve many of these bugs, but certain edge cases may remain.[7][2]
- **VSync and Performance**: XWayland applications can stutter or tear if GPU drivers or compositor settings aren’t tuned, especially with NVIDIA. Tweak `vsync`, `max_fps`, and related Hyprland/GPU env variables for optimal behavior.[8][2]
- **Window Rules**: Popups, dialogs, or special windows in XWayland apps sometimes don’t gain focus or appear behind other windows. Add targeted `windowrule` or `windowrulev2` rules in your config for these cases.[9][2]

### NVIDIA Specifics

- For NVIDIA GPUs, it’s critical to set:
  ```
  env = __GLX_VENDOR_LIBRARY_NAME,nvidia
  ```
  in your config and ensure all other NVIDIA and Wayland variables are set as described in earlier sections, or XWayland may fail to accelerate apps.[10][11][8]

### Testing and Debugging

- Run `xeyes`, `xclock`, or `xterm` to check basic XWayland function.
- For in-depth issues, consult logs in `~/.local/share/hyprland/hyprland.log` and run problematic apps from the terminal to capture XWayland-related errors.[2][7]

### Limitations

- Seamless hybrid GPU offloading, precise DPI scaling, and advanced X11 compositing features are currently limited or not supported.
- Some apps and games may simply not function perfectly outside of Xorg-based sessions; consider using integer scaling or other workarounds.
  
***

Related topics: Window rule configuration, HiDPI issues, input focus startups, running X11-only legacy software, transition strategies to pure Wayland apps.

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] FAQ https://wiki.hypr.land/FAQ/
[3] Wayland - ArchWiki https://wiki.archlinux.org/title/Wayland
[4] Blurry text when using Sway or fractional scaling on Wayland https://intellij-support.jetbrains.com/hc/en-us/articles/4403794663570-Blurry-text-when-using-Sway-or-fractional-scaling-on-Wayland
[5] Wayland/hyprland: incorrect popup scale (reopen) : JBR-8356 https://youtrack.jetbrains.com/projects/JBR/issues/JBR-8356/Wayland-hyprland-incorrect-popup-scale-reopen
[6] Drag and drop does not work in Hyprland (Wayland) #7644 https://github.com/hyprwm/Hyprland/issues/7644
[7] Abnormal Display in JetBrains IDEs · Issue #5942 https://github.com/hyprwm/Hyprland/issues/5942
[8] Nvidia - Hyprland Wiki https://wiki.hypr.land/hyprland-wiki/pages/Nvidia/
[9] Intellij is flickering heavily making it hard to work #9355 - GitHub https://github.com/hyprwm/Hyprland/issues/9355
[10] NVidia https://wiki.hyprland.org/0.45.0/Nvidia/
[11] NVidia - Hyprland Wiki https://wiki.hyprland.org/0.41.2/Nvidia/

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


