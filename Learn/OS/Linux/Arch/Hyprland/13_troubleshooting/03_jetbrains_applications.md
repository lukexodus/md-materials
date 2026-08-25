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

