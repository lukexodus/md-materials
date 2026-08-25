## What Wayland Replaces


### X Window System (X11)

Wayland replaces X11, a network-transparent windowing system dating from 1984 that uses a client-server model where the X server runs on the user's computer accepting requests from client programs. X11 handles window management, compositing, and input as separate components, with the X server acting as a go-between for users and applications.[3][2]

### Architectural Differences

**X11 Architecture:** Applications render to X pixmaps via GLX/EGL, the X server copies pixmaps to the compositor's texture, the compositor applies effects, then presents the final composite to screen—resulting in 4 steps with 2-3 memory copies per frame.[2]

**Wayland Architecture:** Applications render directly to DMA-BUF via EGL, the compositor textures from the buffer directly as a GL texture, then presents the composite in one pass—resulting in 3 steps with zero copies.[2]

### Security Model

X11 provides no application isolation, allowing any client to access the entire display server and inject input or read content from other applications globally. Wayland enforces strict separation where each client runs in a sandboxed environment with isolated access, preventing applications from accessing other clients' windows or input without explicit permission.[4][2]

