## Dynamic Workspaces


Hyprland implements virtual desktops called workspaces that organize windows into separate logical screens. Workspaces are dynamic by default, meaning they are created automatically when you navigate to them or assign a window to them. Empty workspaces automatically disappear when you switch away from them, maintaining a minimal workspace count.[11][8]

You can make workspaces persistent (always present even when empty) through configuration using the `workspace` keyword with the `persistent:true` option. This prevents automatic workspace cleanup and maintains fixed workspace numbers.[1]

Workspaces can contain any combination of tiled and floating windows. Each workspace maintains its own window arrangement independent of other workspaces, allowing different organizational schemes per workspace.[8][1]

