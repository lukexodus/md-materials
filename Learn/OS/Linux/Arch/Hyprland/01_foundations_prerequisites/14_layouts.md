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

