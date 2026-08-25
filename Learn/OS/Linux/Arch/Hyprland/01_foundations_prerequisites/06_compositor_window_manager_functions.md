## Compositor/Window Manager Functions


### Unified Role in Wayland

A Wayland compositor combines the display server, window manager, and compositing functionality into a single process. Display servers using the Wayland protocol are called compositors because they additionally perform the task of a compositing window manager. Starting a Wayland session amounts to starting a compositor, which handles all graphics server operations, window management, and visual compositing in one unified process.[2][3][5]

### Core Compositor Responsibilities

**Window Management:** Compositors control window placement, sizing, focus management, workspace organization, and tiling/stacking behavior. In Wayland, window management is a shared responsibility between compositor and client, meaning each compositor defines its own window management behavior rather than plugging into a separate window manager.[5][6]

**Rendering and Compositing:** Compositors render graphical elements including windows and visual effects like shadows, transparency, animations, and rounded corners. They perform off-screen rendering where windows are drawn to buffers before display, reducing screen tearing and ensuring smooth performance.[3][6]

**Display Server Functions:** The compositor manages communication with client applications through the Wayland protocol, handling requests from clients to draw buffers on screen and sending events like mouse clicks and key-presses back to clients. It controls buffer display, directly manages hardware through kernel display drivers (DRM) and libinput, and coordinates GPU-accelerated rendering.[3][5]

### Input and Hardware Management

Compositors handle all input device management including keyboards, mice, touchpads, and touchscreens through libinput. They manage display configuration, output routing, and direct interaction with graphics hardware without intermediate layers.[5]

