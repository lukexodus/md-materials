# HyprLTM-Net — Comprehensive Guide

## What Is It?

HyprLTM-Net is a sleek, open source network management GUI powered by Rofi and NetworkManager (nmcli), published on GitHub under the GNU GPL v3.0 license. It started as a personal project for a Hyprland setup and has grown into a real open source project used by hundreds of users.

The project is part of the broader **HyprLTM** ecosystem — a custom Hyprland desktop setup — and is created by **Djalel Oukid (sniper1720)**.

---

## Core Features

**Wi-Fi:** Scan for nearby networks, connect to new ones, or manage existing SSIDs. **Wired:** Quickly switch between different Ethernet profiles and configurations. **VPN:** Modular support for WireGuard and OpenVPN, including the ability to import profile files directly through the interface. **Status:** View real-time connection details, local/public IP addresses, and DNS info. **Connection Management:** Edit passwords, rename connections, or forget/delete old profiles.

Additional notable features from the GitHub README:

- Airplane Mode toggle
- QR Code sharing for Wi-Fi passwords
- Hotspot creation and management
- Ethernet-Only Mode for systems that only have Ethernet interfaces (no Wi-Fi)
- Global Theme Support, enabling loading the Rofi theme from global system paths (e.g., `/etc/xdg/rofi/themes`) in addition to local user configs

---

## Menu Structure

The full hierarchical menu (from the GitHub README) is:

```
Main Menu
├── Wi-Fi
│   ├── Status → View Details (IP, Signal, MAC...)
│   ├── Toggle (Enable / Disable)
│   ├── Available Networks (SSID List)
│   │   ├── [New Secure Network] → Enter Password → Show/Hide/Edit/Confirm
│   │   └── [Saved Network]
│   │       ├── Autoconnect (Toggle)
│   │       ├── Connect / Disconnect Now
│   │       ├── IPv4 / IPv6 Configuration
│   │       ├── Forget / Rename / Edit Password
│   │       └── Share via QR Code
│   ├── Create Hotspot
│   ├── Known Connections (Saved Profiles)
│   └── Connect to a Hidden Network
├── Wired
│   ├── [Available Interface] → Connect
│   └── [Saved Profile] → (Same options as Wi-Fi)
├── VPN
│   ├── [VPN Profile]
│   │   ├── Autoconnect (Toggle)
│   │   ├── Connect / Disconnect
│   │   ├── IPv4 / IPv6 Configuration
│   │   ├── Forget / Rename / Edit Password
│   └── Import Configuration (.conf / .ovpn)
├── Saved Connections (All Profiles)
├── Status
│   ├── Active Connection Details
│   └── All Device Status
└── Airplane Mode (Toggle)
```

---

## Prerequisites

The following packages must be installed:

|Package|Purpose|
|---|---|
|`networkmanager`|Backend connection management via `nmcli`|
|`rofi-wayland`|The graphical menu engine|
|`qrencode`|Generating Wi-Fi QR codes|
|Nerd Fonts|Icons (e.g., JetBrains Mono Nerd Font)|

---

## Installation

### Automated (Recommended)

```bash
git clone https://github.com/hyprltm/hyprltm-net.git
cd hyprltm-net
chmod +x install.sh
./install.sh
```

The install script performs distro detection and offers to install missing dependencies automatically. It supports **Arch, Fedora, openSUSE, and NixOS**. It then gives you three interactive options:

1. **Desktop Entry** — creates a launcher menu entry and icon
2. **Keybind Setup** — shows instructions for Hyprland keybind
3. **Waybar Setup** — shows instructions to configure Waybar

### Manual Installation

```bash
mkdir -p ~/.local/bin && cp hyprltm-net.sh ~/.local/bin/hyprltm-net && chmod +x ~/.local/bin/hyprltm-net
mkdir -p ~/.config/rofi/themes/ && cp *.rasi ~/.config/rofi/themes/
```

### Hyprland Keybind

Add to `~/.config/hypr/hyprland.conf`:

```
bind = SUPER, N, exec, hyprltm-net
```

### Waybar Integration

Add to your `network` module in `~/.config/waybar/config.jsonc`:

```json
"on-click": "hyprltm-net"
```

---

## Theming

HyprLTM-Net uses the LTMNight color palette. To customize the appearance, edit `~/.config/rofi/themes/ltmnight.rasi`.

Key theme variables:

|Variable|Description|Default|
|---|---|---|
|`@ltmnight9`|Primary Accent (Purple)|`#bd93f9`|
|`@ltmnight0`|Background|`#282a36`|
|`@ltmnight2`|Foreground|`#f8f8f2`|
|`@ltmnight7`|Success (Green)|`#50fa7b`|

---

## Project Status & Roadmap

The project is currently at **v0.3.0** (as of late March 2026). As it moves toward the 1.0.0 milestone, the author intends to make HyprLTM-Net one of the most user-friendly Linux network managers, while keeping the code stable and clean and continuing to add new features. The full roadmap is not publicly disclosed.

The repository is written entirely in **Shell (100%)**, licensed under **GPL-3.0**, and hosted at `https://github.com/hyprltm/hyprltm-net`.

---

## Important Notes

- **Compatibility:** The tool is designed for **Hyprland on Wayland**. [Inference] It likely does not work on X11 environments since it depends on `rofi-wayland`, but this is not explicitly confirmed in the documentation.
- **Distro support:** The installer targets Arch, Fedora, openSUSE, and NixOS. Use on other distros may require manual dependency installation. [Unverified — behavior on unsupported distros is not documented.]
- The project is still pre-1.0 and actively developed. Expect changes between versions.