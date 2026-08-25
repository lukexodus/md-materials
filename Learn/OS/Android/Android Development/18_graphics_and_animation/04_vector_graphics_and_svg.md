## Vector Graphics and SVG


Vector graphics provide resolution-independent imagery that scales cleanly across different screen densities and sizes. Android supports vector graphics through the VectorDrawable system and limited SVG compatibility.

**VectorDrawable Format** VectorDrawable uses XML syntax similar to SVG but adapted for Android's rendering system. Vector drawables define graphics using paths, shapes, and styling attributes within a viewport coordinate system.

```xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24.0"
    android:viewportHeight="24.0">
    <path
        android:fillColor="#FF000000"
        android:pathData="M12,2C6.48,2 2,6.48 2,12s4.48,10 10,10 10,-4.48 10,-10S17.52,2 12,2z"/>
</vector>
```

**Path Data Syntax** Vector paths use SVG path data syntax with commands like M (move to), L (line to), C (cubic bezier), and Z (close path). This provides precise control over shape geometry while maintaining compact file sizes.

**Vector Animation** AnimatedVectorDrawable enables animation of vector graphics properties including path morphing, color changes, rotation, and scaling. These animations can be triggered programmatically or through state changes.

**Gradient and Pattern Support** Vector graphics support linear and radial gradients, providing rich visual effects without requiring bitmap resources. Gradients are defined using color stops and can be animated for dynamic effects.

**Compatibility Considerations** Vector graphics require API level 21+ for native support, though the support library provides backward compatibility through automatic bitmap conversion on older devices. [Inference] This conversion may impact performance and memory usage on legacy devices.

**SVG Import Process** Android Studio can import SVG files and convert them to VectorDrawable format, though complex SVG features may not be fully supported. Manual optimization is often required for imported vectors.

**Performance Characteristics** Vector graphics excel for simple shapes and icons but may perform poorly for complex illustrations with many paths. Bitmap caching may be beneficial for frequently-used complex vectors.

