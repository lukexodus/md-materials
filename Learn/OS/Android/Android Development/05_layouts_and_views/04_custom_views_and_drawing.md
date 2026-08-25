## Custom Views and Drawing


Creating custom views allows you to implement specialized UI components that aren't available in the standard Android toolkit. Custom views involve extending the View class and overriding key methods to handle measurement, layout, and drawing operations.

The custom view lifecycle involves several key methods: `onMeasure()` determines the view's size requirements, `onLayout()` positions child views (for ViewGroups), `onDraw()` handles rendering, and various touch event methods manage user interaction.

**Key Points:**

- Extend View for leaf nodes or ViewGroup for containers
- Override `onMeasure()` to specify size requirements
- Implement `onDraw()` for custom rendering
- Handle touch events through `onTouchEvent()` or gesture detectors
- Use `invalidate()` to trigger redraws when state changes

**Example** of a simple custom view:

```kotlin
class CircleProgressView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : View(context, attrs, defStyleAttr) {
    
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.BLUE
        strokeWidth = 10f
        style = Paint.Style.STROKE
    }
    
    private val backgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.LIGHT_GRAY
        strokeWidth = 10f
        style = Paint.Style.STROKE
    }
    
    var progress: Float = 0f
        set(value) {
            field = value.coerceIn(0f, 1f)
            invalidate() // Trigger redraw
        }
    
    private val rect = RectF()
    
    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val desiredSize = 200.dpToPx()
        
        val widthMode = MeasureSpec.getMode(widthMeasureSpec)
        val widthSize = MeasureSpec.getSize(widthMeasureSpec)
        val heightMode = MeasureSpec.getMode(heightMeasureSpec)
        val heightSize = MeasureSpec.getSize(heightMeasureSpec)
        
        val width = when (widthMode) {
            MeasureSpec.EXACTLY -> widthSize
            MeasureSpec.AT_MOST -> minOf(desiredSize, widthSize)
            else -> desiredSize
        }
        
        val height = when (heightMode) {
            MeasureSpec.EXACTLY -> heightSize
            MeasureSpec.AT_MOST -> minOf(desiredSize, heightSize)
            else -> desiredSize
        }
        
        setMeasuredDimension(width, height)
    }
    
    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        
        val padding = 20f
        rect.set(padding, padding, width - padding, height - padding)
        
        // Draw background circle
        canvas.drawArc(rect, 0f, 360f, false, backgroundPaint)
        
        // Draw progress arc
        val sweepAngle = 360f * progress
        canvas.drawArc(rect, -90f, sweepAngle, false, paint)
    }
    
    private fun Int.dpToPx(): Int {
        return (this * context.resources.displayMetrics.density).toInt()
    }
}
```

**Usage in layout:**

```xml
<com.yourpackage.CircleProgressView
    android:id="@+id/progressView"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:layout_centerInParent="true" />
```

**Controlling from Activity/Fragment:**

```kotlin
val progressView = findViewById<CircleProgressView>(R.id.progressView)
progressView.progress = 0.75f // 75% progress
```

