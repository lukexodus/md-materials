## Decorations & Visual Effects


The `decoration` section controls window styling, visual effects, and blur behavior. This section defines how windows appear on screen including borders, shadows, transparency, and background blur effects.[1]

### Rounding and Corners

**rounding** sets the corner radius in logical pixels, defaulting to 0 (sharp corners). Values define the curvature applied to all window corners. **rounding_power** adjusts the curve formula for rounding: 1.0 creates triangular corners, 2.0 produces perfect circles, 4.0 creates squircles, and values up to 10.0 provide increasingly smooth curves (default 2.0).[1]

### Opacity and Transparency

**active_opacity** sets the opacity of the currently focused window between 0.0 (fully transparent) and 1.0 (fully opaque), defaulting to 1.0. **inactive_opacity** applies to unfocused windows, also defaulting to 1.0. **fullscreen_opacity** controls opacity for fullscreen windows specifically, defaulting to 1.0.[1]

Setting opacity below 1.0 makes windows semi-transparent, allowing content behind them to show through. This is purely visual—transparent windows remain fully interactive.[1]

### Dimming and Darkening

**dim_modal** enables darkening of parent windows when their child modal dialogs are open, defaulting to true. This effect dims everything behind the modal, directing focus to the dialog.[1]

**dim_inactive** darkens inactive (unfocused) windows when enabled, defaulting to false. **dim_strength** controls how much inactive windows are dimmed between 0.0 (no dimming) and 1.0 (maximum darkness), defaulting to 0.5.[1]

**dim_special** controls dimming when a special workspace is active, darkening the background workspace (default 0.2). **dim_around** sets dimming for windows with the `dimaround` rule (default 0.4).[1]

### Border and Window Styling

**border_part_of_window** determines whether window borders count toward window dimensions when set to true, defaulting to true. When true, borders are included in resize operations and geometry calculations.[1]

### Blur Effects

The `blur` subcategory controls Kawase window background blur, the blurred area visible behind semi-transparent windows.[1]

**enabled** toggles blur functionality (default true). **size** sets the blur distance/radius in pixels (default 8). **passes** specifies how many times the blur algorithm repeats—higher values produce stronger blur but consume more GPU (default 1). Most configurations require at least 2-3 passes for noticeable blur with larger sizes.[1]

**ignore_opacity** makes blur ignore window opacity when true, always applying full blur strength regardless of transparency (default true). **new_optimizations** enables performance improvements, strongly recommended to keep enabled (default true).[1]

**xray** when enabled, makes floating windows ignore tiled windows when calculating blur, reducing blur calculation overhead (only works with new_optimizations).[1]

**Blur Appearance:** **noise** adds visible grain (0.0-1.0, default 0.0117). **contrast** modulates blur contrast (0.0-2.0, default 0.8916). **brightness** modulates blur brightness (0.0-2.0, default 0.8172). **vibrancy** increases color saturation of blurred areas (0.0-1.0, default 0.1696). **vibrancy_darkness** strengthens vibrancy effect on dark areas (0.0-1.0, default 0.0).[1]

**Special Blur Settings:** **special** blurs behind special workspaces when enabled, though this is computationally expensive (default false). **popups** blurs right-click menus and similar popups (default false). **popups_ignorealpha** prevents blurring very transparent popups below the specified threshold (0.0-1.0, default 0.2). **input_methods** blurs input method (IME) overlays (default false).[1]

### Shadows

The `shadow` subcategory controls drop shadows rendered around windows.[1]

**enabled** toggles shadow rendering (default true). **range** sets shadow size/spread distance in logical pixels (default 4). **render_power** controls falloff sharpness: values 1-4 where higher values create faster falloff (default 3). **sharp** when enabled, creates infinitely sharp shadow falloff instantly (default false).[1]

**ignore_window** when true, renders shadows only around windows, not behind them (default true). **color** sets the shadow color using rgba format, with alpha controlling shadow opacity (default 0xee1a1a1a, dark with moderate opacity). **color_inactive** sets distinct shadow color for unfocused windows when specified.[1]

**offset** positions the shadow with a vec2 (x y) offset from the window, allowing directional shadow displacement (default ). **scale** multiplies shadow size between 0.0 and 1.0 (default 1.0).[1]

### Screen Shader

**screen_shader** accepts a path to a custom fragment shader applied to the final rendered frame. This allows post-processing effects like color grading, vignetting, or distortion applied to the entire screen. See the Hyprland examples directory for shader template usage.[1]

### Example Configuration

```
decoration {
  rounding = 10
  rounding_power = 2.0
  active_opacity = 1.0
  inactive_opacity = 0.9
  
  dim_inactive = true
  dim_strength = 0.3
  
  blur {
    enabled = true
    size = 8
    passes = 2
    noise = 0.01
    contrast = 0.8916
    brightness = 0.8172
    vibrancy = 0.1696
  }
  
  shadow {
    enabled = true
    range = 4
    render_power = 3
    color = rgba(1a1a1aee)
    offset = [0, 0]
  }
}
```

Sources
[1] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

