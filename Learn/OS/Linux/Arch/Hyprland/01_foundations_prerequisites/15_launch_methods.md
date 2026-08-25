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

