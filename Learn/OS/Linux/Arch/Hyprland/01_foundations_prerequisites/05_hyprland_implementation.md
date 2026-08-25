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

