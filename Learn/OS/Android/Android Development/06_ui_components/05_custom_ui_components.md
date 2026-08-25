## Custom UI Components


Creating custom UI components extends Android's built-in functionality to meet specific application requirements and design specifications.

### Custom View Creation

Custom views inherit from existing view classes or the base View class, implementing specialized drawing and interaction logic.

**Key points:**

- Extends existing view classes or creates entirely new view types
- Implements custom drawing through onDraw() method
- Handles touch interactions and state management
- Supports custom attributes through XML styling

```kotlin
class CircularProgressView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : View(context, attrs, defStyleAttr) {
    
    private var progress = 0f
    private var maxProgress = 100f
    private val paint = Paint().apply {
        isAntiAlias = true
        strokeWidth = 20f
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
    }
    
    private val backgroundPaint = Paint().apply {
        isAntiAlias = true
        strokeWidth = 20f
        style = Paint.Style.STROKE
        color = Color.LTGRAY
    }
    
    init {
        // Initialize custom attributes
        context.theme.obtainStyledAttributes(
            attrs,
            R.styleable.CircularProgressView,
            0, 0
        ).apply {
            try {
                progress = getFloat(R.styleable.CircularProgressView_progress, 0f)
                maxProgress = getFloat(R.styleable.CircularProgressView_maxProgress, 100f)
                paint.color = getColor(R.styleable.CircularProgressView_progressColor, Color.BLUE)
            } finally {
                recycle()
            }
        }
    }
    
    override fun onDraw(canvas: Canvas?) {
        super.onDraw(canvas)
        
        val centerX = width / 2f
        val centerY = height / 2f
        val radius = minOf(centerX, centerY) - paint.strokeWidth / 2
        
        // Draw background circle
        canvas?.drawCircle(centerX, centerY, radius, backgroundPaint)
        
        // Draw progress arc
        val sweepAngle = (progress / maxProgress) * 360f
        canvas?.drawArc(
            centerX - radius,
            centerY - radius,
            centerX + radius,
            centerY + radius,
            -90f,
            sweepAngle,
            false,
            paint
        )
    }
    
    fun setProgress(newProgress: Float) {
        progress = newProgress.coerceIn(0f, maxProgress)
        invalidate()
    }
    
    fun getProgress(): Float = progress
}
```

### Custom Attributes

Custom attributes enable XML styling for custom views, providing declarative configuration options.

**Example:** Custom attributes definition and usage

```kotlin
// res/values/attrs.xml
<resources>
    <declare-styleable name="CircularProgressView">
        <attr name="progress" format="float" />
        <attr name="maxProgress" format="float" />
        <attr name="progressColor" format="color" />
    </declare-styleable>
</resources>

// XML usage
<com.yourpackage.CircularProgressView
    android:layout_width="200dp"
    android:layout_height="200dp"
    app:progress="75"
    app:maxProgress="100"
    app:progressColor="@color/primary" />
```

### Compound Views

Compound views combine multiple existing views into reusable components with coordinated behavior.

**Example:** Custom toolbar with search functionality

```kotlin
class SearchToolbar @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : LinearLayout(context, attrs, defStyleAttr) {
    
    private val titleTextView: TextView
    private val searchEditText: EditText
    private val searchButton: ImageButton
    
    var onSearchListener: ((String) -> Unit)? = null
    
    init {
        inflate(context, R.layout.search_toolbar, this)
        
        titleTextView = findViewById(R.id.toolbarTitle)
        searchEditText = findViewById(R.id.searchEditText)
        searchButton = findViewById(R.id.searchButton)
        
        searchButton.setOnClickListener {
            val query = searchEditText.text.toString()
            onSearchListener?.invoke(query)
        }
        
        searchEditText.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                val query = searchEditText.text.toString()
                onSearchListener?.invoke(query)
                true
            } else {
                false
            }
        }
    }
    
    fun setTitle(title: String) {
        titleTextView.text = title
    }
    
    fun setSearchHint(hint: String) {
        searchEditText.hint = hint
    }
}
```

**Key points:**

- Combines multiple views into cohesive components
- Encapsulates complex interactions and state management
- Provides simplified APIs for common use cases
- Can be styled and configured through custom attributes

**Next steps:** Understanding ViewGroups and Layout managers, implementing touch event handling, exploring Material Design components, and integrating custom views with data binding are essential areas for advancing UI component development skills.

---

