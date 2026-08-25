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

