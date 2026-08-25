## Master Layout


The master layout designates one or more windows as "master" occupying a fixed area (left side by default) while remaining windows tile in the slave area. This layout suits workflows prioritizing one primary application (editor, browser) with secondary tools arranged nearby.[1]

### Master Area Configuration

**mfact** sets the master area size as a percentage of screen space, defaulting to 0.55 (55% master, 45% slave). Values range from 0.0 to 1.0; setting `mfact = 0.70` allocates 70% to master and 30% to slave.[1]

**allow_small_split** enables horizontally splitting the master area to accommodate multiple master windows when true (default false). With this disabled, adding additional masters still works but they stack vertically.[1]

**orientation** determines master area placement: `left` (default, master left/slaves right), `right`, `top`, `bottom`, or `center`. Center orientation alternates slave windows left and right around the centered master, creating a symmetric layout.[1]

### Window Hierarchy

**new_status** determines where new windows appear: `slave` (default, added to slave stack), `master` (becomes new master), or `inherit` (inherits focused window's status).[1]

**new_on_top** places newly opened windows at the top of the slave stack when true, or at the bottom when false (default false).[1]

**new_on_active** controls placement relative to focused windows: `before` (above focused), `after` (below focused), or `none` (use new_on_top).[1]

### Advanced Options

**smart_resizing** determines resize direction based on mouse position when true (default true), using tiling position when false.[1]

**drop_at_cursor** places drag-dropped windows at cursor position when true; when false, drops follow new_on_top stacking rules (default true).[1]

**always_keep_position** maintains master window position even with zero slave windows when true (default false).[1]

**special_scale_factor** scales special workspace windows between 0.0 and 1.0 (default 1.0).[1]

**inherit_fullscreen** propagates fullscreen status when cycling or swapping windows (e.g., monocle-style fullscreen persistence) when true (default true).[1]

**center_master_fallback** defines fallback orientation when center master has fewer slaves than `slave_count_for_center_master`: `left`, `right`, `top`, or `bottom` (default left).[1]

**slave_count_for_center_master** specifies minimum slave windows before centering master (default 2); setting to 0 always centers.[1]

### Layout Message Dispatchers

**swapwithmaster** exchanges focused window with master; if already master, swaps with first slave. Optional params: `master` (focus new master), `child` (focus new child), `auto` (preserve focus), or add `ignoremaster` to skip if master already focused.[1]

**focusmaster** focuses the master window with params `master` (stay on master), `auto` (default; focus first slave if already on master), or `previous` (remember previous window).[1]

**cyclenext/cycleprev** moves focus through windows; optional `loop` (default, wrap around) or `noloop` (stop at edges).[1]

**swapnext/swapprev** exchange focused window with next/previous; optional `loop` (default) or `noloop`.[1]

**addmaster/removemaster** adds or removes windows from the master area.[1]

**orientationleft/right/top/bottom/center** sets workspace master area orientation. **orientationnext/prev** cycles through orientations clockwise or counter-clockwise. **orientationcycle** cycles through specific orientations: `layoutmsg, orientationcycle left top right`.[1]

**mfact** adjusts master area size: relative delta (e.g., `-0.05` or `+0.05`) or `exact` with precise value (e.g., `mfact exact 0.65`).[1]

**rollnext/rollprev** rotates the next/previous window to master position while keeping focus on master.[1]

### Workspace-Specific Configuration

Apply master layout settings per-workspace using workspace rules:[1]

```
workspace = 1, layoutopt:orientation:left
workspace = 2, layoutopt:orientation:top
workspace = 3, layoutopt:orientation:center
```


### Example Master Configuration

```
master {
  mfact = 0.55
  allow_small_split = false
  new_status = slave
  new_on_top = false
  new_on_active = none
  orientation = left
  smart_resizing = true
  drop_at_cursor = true
  always_keep_position = false
  inherit_fullscreen = true
  center_master_fallback = left
  slave_count_for_center_master = 2
}
```

Sources
[1] Master Layout https://wiki.hypr.land/Configuring/Master-Layout/

