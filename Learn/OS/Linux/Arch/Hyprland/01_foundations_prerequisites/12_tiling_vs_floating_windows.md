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

