## Canvas and Custom Drawing


Canvas represents Android's 2D drawing API that provides direct pixel-level control over rendering. The Canvas class works in conjunction with Paint objects to define drawing operations and styling.

**Core Canvas Operations** The Canvas API supports fundamental drawing primitives including lines, rectangles, circles, paths, text, and bitmaps. Drawing operations are immediate-mode, meaning each call directly affects the target surface. Canvas coordinates use a standard 2D coordinate system with the origin at the top-left corner.

**Custom View Drawing Process** Custom views override the `onDraw(Canvas canvas)` method to perform drawing operations. The system automatically calls this method during the view's drawing pass. Drawing should be efficient since `onDraw()` may be called frequently during animations or scrolling.

```kotlin
override fun onDraw(canvas: Canvas?) {
    super.onDraw(canvas)
    canvas?.let { c ->
        // Drawing operations
        c.drawCircle(centerX, centerY, radius, paint)
        c.drawText(text, textX, textY, textPaint)
    }
}
```

**Paint Configuration** Paint objects define how drawing operations appear, controlling color, stroke width, text size, anti-aliasing, and various effects. Paint objects are reusable and should typically be created once and configured as needed.

**Path Drawing** The Path class enables complex shape creation through line segments, curves, and closed shapes. Paths support operations like union, intersection, and difference for creating composite shapes.

**Canvas Transformations** Canvas supports geometric transformations including translation, rotation, scaling, and skewing. These transformations affect subsequent drawing operations and can be combined for complex effects. The canvas maintains a transformation matrix stack for managing nested transformations.

**Bitmap Manipulation** Canvas can draw onto Bitmap objects for off-screen rendering, image processing, or caching complex graphics. This approach is useful for creating reusable graphics or implementing custom image filters.

