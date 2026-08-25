## Animations


The `animations` section controls all transition effects when windows open, close, move, fade, or switch workspaces. Animations are hierarchical—unset animations inherit properties from their parent in the animation tree.[1]

### Animation Syntax

Animations follow the syntax `animation = NAME, ONOFF, SPEED, CURVE [,STYLE]`. **ONOFF** is 0 (disabled) or 1 (enabled)—when disabled, further arguments can be omitted. **SPEED** measures duration in ds (deciseconds, where 1ds = 100ms), so a speed of 8 equals 800ms. **CURVE** is the bezier curve name controlling easing behavior. **STYLE** is optional and specifies the animation type (e.g., `slide`, `popin`, `fade`).[1]

### Bezier Curves

Custom bezier curves define animation acceleration and deceleration using the syntax `bezier = NAME, X0, Y0, X1, Y1`. The four values define two control points for a cubic bezier curve, controlling how the animation progresses from 0 to 1. Design curves visually at cssportal.com or use pre-made easing functions from easings.net.[1]

**Example curves:**
```
bezier = default, 0.25, 0.1, 0.25, 1
bezier = overshoot, 0.05, 0.9, 0.1, 1.1
bezier = smoothOut, 0.36, 0, 0.66, -0.56
bezier = smoothIn, 0.25, 1, 0.5, 1
```


An overshoot curve with Y values exceeding 1.0 creates bouncy animations where the target "overshoots" before settling, producing spring-like effects.[2][1]

### Animation Tree

Hyprland organizes animations hierarchically under `global`:[1]

**Windows:**
- `windows` - General window open/close animations
- `windowsIn` - Specifically window opening
- `windowsOut` - Specifically window closing
- `windowsMove` - Movement, dragging, resizing animations

[1]

**Fading:**
- `fade`, `fadeIn`, `fadeOut`, `fadeSwitch`, `fadeShadow`, `fadeDim`, `fadeLayers`, `fadeLayersIn`, `fadeLayersOut` - Various fade transitions[1]

**Workspaces:**
- `workspaces`, `workspacesIn`, `workspacesOut` - Workspace switching animations
- `specialWorkspace`, `specialWorkspaceIn`, `specialWorkspaceOut` - Special workspace animations

[1]

**Other:**
- `border` - Border color transitions
- `borderangle` - Animated gradient angle rotation (uses `loop` style for continuous rotation)[1]
- `layers` - UI element animations like status bars
- `zoomFactor` - Screen zoom animations
- `monitorAdded` - Animation when a monitor connects

[1]

### Window Animation Styles

**slide** creates directional sliding entrance/exit, optionally specifying `top`, `bottom`, `left`, or `right` direction (e.g., `slide left`). **popin** scales from a percentage (e.g., `popin 80%` animates from 80% to 100% size). **gnomed** adds a macOS-style animation effect.[1]

### Workspace Animation Styles

**slide** horizontally slides between workspaces. **slidevert** vertically slides (useful with vertical workspace layouts). **fade** fades between workspaces instead of sliding. **slidefade** combines sliding and fading effects, optionally specifying movement percentage (e.g., `slidefade 20%`). **slidefadevert** is vertical variant of slidefade.[1]

### Performance Considerations

The `borderangle` animation with `loop` style requires constant rendering at screen refresh rate (e.g., 60fps), stressing CPU/GPU and impacting battery life. This occurs even when animations are disabled or borders aren't visible.[1]

### Example Configuration

```
animations {
  enabled = true
  
  bezier = myBezier, 0.05, 0.9, 0.1, 1.05
  bezier = overshot, 0.05, 0.9, 0.1, 1.1
  bezier = smoothOut, 0.36, 0, 0.66, -0.56
  
  animation = windows, 1, 7, myBezier
  animation = windowsIn, 1, 7, myBezier, popin 80%
  animation = windowsOut, 1, 7, smoothOut, popin 80%
  animation = windowsMove, 1, 7, default
  animation = fade, 1, 7, default
  animation = border, 1, 10, default
  animation = borderangle, 1, 8, default
  
  animation = workspaces, 1, 6, overshot, slide
  animation = specialWorkspace, 1, 6, overshot, slide
}
```

Sources
[1] Animations - Hyprland Wiki https://wiki.hypr.land/Configuring/Animations/
[2] hyprland animations curves - Reddit https://www.reddit.com/r/hyprland/comments/1e3hoe6/hyprland_animations_curves/
[3] How To Customize Animations in Hyprland - YouTube https://www.youtube.com/watch?v=YetfV4MaBT8
[4] hyprwm/Hyprland - GitHub https://github.com/hyprwm/Hyprland
[5] https://raw.githubusercontent.com/miklevin/MikeLev... https://raw.githubusercontent.com/miklevin/MikeLev.in/main/_posts/2024-12-23-nixos-wayland-hyprland.md
[6] Hyprland | Phundrak's Dotfiles https://config.phundrak.com/hyprland
[7] feat(hyprland): add bezier curves & tweak animations - rosa.radicle.xyz https://app.radicle.xyz/nodes/git.jappie.dev/rad:z4HEZGDPknT12W4fuXc6wM3HtYTf2/commits/6f1e752ce67b4710685301a79ea8fcd67d3c67c4
[8] How to achieve seamless linear borderangle loop? - Hyprland Forum https://forum.hypr.land/t/how-to-achieve-seamless-linear-borderangle-loop/1046
[9] Hyprland Config - YouTube https://www.youtube.com/watch?v=cWXQ2x0p6hQ
[10] "Hyprland Configuration Guide" makalesinin özeti — YaÖzet - Yandex https://yandex.com.tr/yaozet/programming/hyprland-configuration-guide-id4-wdgpljg0

