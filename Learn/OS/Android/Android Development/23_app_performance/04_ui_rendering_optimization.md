## UI Rendering Optimization


UI rendering optimization focuses on maintaining 60 FPS performance through efficient layout management, view recycling, and animation optimization. Understanding the Android rendering pipeline helps identify performance bottlenecks.

**Layout Optimization**

Complex view hierarchies and inefficient layouts cause rendering performance issues. ConstraintLayout and proper view hierarchy design improve rendering performance.

```kotlin
class LayoutOptimization {
    
    // ViewHolder pattern for RecyclerView optimization
    class OptimizedViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val titleText: TextView = itemView.findViewById(R.id.title)
        private val subtitleText: TextView = itemView.findViewById(R.id.subtitle)
        private val imageView: ImageView = itemView.findViewById(R.id.image)
        private val actionButton: Button = itemView.findViewById(R.id.action_button)
        
        fun bind(item: ListItem) {
            titleText.text = item.title
            subtitleText.text = item.subtitle
            
            // Use View.GONE instead of View.INVISIBLE when possible
            if (item.subtitle.isBlank()) {
                subtitleText.visibility = View.GONE
            } else {
                subtitleText.visibility = View.VISIBLE
            }
            
            // Load images asynchronously
            Glide.with(itemView.context)
                .load(item.imageUrl)
                .into(imageView)
            
            actionButton.setOnClickListener { 
                item.onActionClick()
            }
        }
        
        // Pre-create expensive objects to avoid allocation during scrolling
        companion object {
            private val dateFormat = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())
            private val colorStateList = ColorStateList.valueOf(Color.BLUE)
        }
    }
    
    // Custom ViewGroup for optimized layout performance
    class OptimizedLinearLayout @JvmOverloads constructor(
        context: Context,
        attrs: AttributeSet? = null,
        defStyleAttr: Int = 0
    ) : ViewGroup(context, attrs, defStyleAttr) {
        
        override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
            var totalHeight = 0
            val widthSize = MeasureSpec.getSize(widthMeasureSpec)
            
            // Single pass measurement
            for (i in 0 until childCount) {
                val child = getChildAt(i)
                if (child.visibility != View.GONE) {
                    measureChild(child, widthMeasureSpec, heightMeasureSpec)
                    totalHeight += child.measuredHeight
                }
            }
            
            setMeasuredDimension(widthSize, totalHeight)
        }
        
        override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
            var currentTop = 0
            
            for (i in 0 until childCount) {
                val child = getChildAt(i)
                if (child.visibility != View.GONE) {
                    child.layout(0, currentTop, child.measuredWidth, currentTop + child.measuredHeight)
                    currentTop += child.measuredHeight
                }
            }
        }
    }
    
    // View recycling for complex UI components
    class ViewPool<T : View>(
        private val creator: () -> T,
        private val resetter: (T) -> Unit
    ) {
        private val availableViews = mutableListOf<T>()
        private val usedViews = mutableSetOf<T>()
        
        fun acquire(): T {
            val view = if (availableViews.isNotEmpty()) {
                availableViews.removeAt(availableViews.size - 1)
            } else {
                creator()
            }
            
            usedViews.add(view)
            return view
        }
        
        fun release(view: T) {
            if (usedViews.remove(view)) {
                resetter(view)
                availableViews.add(view)
            }
        }
        
        fun clear() {
            availableViews.clear()
            usedViews.clear()
        }
    }
}
```

**Animation Performance**

Animations should use GPU-accelerated properties and avoid triggering layout passes during animation execution.

```kotlin
class AnimationOptimization {
    
    // GPU-accelerated animations using property animators
    fun createOptimizedFadeAnimation(view: View, duration: Long = 300): Animator {
        return ObjectAnimator.ofFloat(view, "alpha", 0f, 1f).apply {
            this.duration = duration
            interpolator = AccelerateDecelerateInterpolator()
            
            // Use hardware layer during animation
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationStart(animation: Animator) {
                    view.setLayerType(View.LAYER_TYPE_HARDWARE, null)
                }
                
                override fun onAnimationEnd(animation: Animator) {
                    view.setLayerType(View.LAYER_TYPE_NONE, null)
                }
            })
        }
    }
    
    fun createScaleAnimation(view: View): Animator {
        val scaleX = PropertyValuesHolder.ofFloat("scaleX", 0.8f, 1.0f)
        val scaleY = PropertyValuesHolder.ofFloat("scaleY", 0.8f, 1.0f)
        val alpha = PropertyValuesHolder.ofFloat("alpha", 0.5f, 1.0f)
        
        return ObjectAnimator.ofPropertyValuesHolder(view, scaleX, scaleY, alpha).apply {
            duration = 250
            interpolator = OvershootInterpolator()
        }
    }
    
    // Recycler view animation optimization
    class OptimizedItemAnimator : DefaultItemAnimator() {
        
        override fun animateAdd(holder: RecyclerView.ViewHolder?): Boolean {
            holder?.itemView?.let { view ->
                view.alpha = 0f
                view.animate()
                    .alpha(1f)
                    .setDuration(addDuration)
                    .setListener(object : AnimatorListenerAdapter() {
                        override fun onAnimationEnd(animation: Animator) {
                            dispatchAddFinished(holder)
                        }
                    })
                    .start()
            }
            return true
        }
        
        override fun animateRemove(holder: RecyclerView.ViewHolder?): Boolean {
            holder?.itemView?.let { view ->
                view.animate()
                    .alpha(0f)
                    .setDuration(removeDuration)
                    .setListener(object : AnimatorListenerAdapter() {
                        override fun onAnimationEnd(animation: Animator) {
                            view.alpha = 1f
                            dispatchRemoveFinished(holder)
                        }
                    })
                    .start()
            }
            return true
        }
    }
    
    // Choreographer-based animation timing
    class ChoreographerAnimationController {
        private var isAnimating = false
        private var startTime = 0L
        private val choreographer = Choreographer.getInstance()
        
        private val frameCallback = object : Choreographer.FrameCallback {
            override fun doFrame(frameTimeNanos: Long) {
                if (!isAnimating) return
                
                val elapsed = (frameTimeNanos - startTime) / 1_000_000f // Convert to milliseconds
                val progress = (elapsed / ANIMATION_DURATION).coerceIn(0f, 1f)
                
                updateAnimation(progress)
                
                if (progress < 1f) {
                    choreographer.postFrameCallback(this)
                } else {
                    isAnimating = false
                    onAnimationComplete()
                }
            }
        }
        
        fun startAnimation() {
            if (isAnimating) return
            
            isAnimating = true
            startTime = System.nanoTime()
            choreographer.postFrameCallback(frameCallback)
        }
        
        fun stopAnimation() {
            isAnimating = false
            choreographer.removeFrameCallback(frameCallback)
        }
        
        private fun updateAnimation(progress: Float) {
            // Update animation based on progress
        }
        
        private fun onAnimationComplete() {
            // Handle animation completion
        }
        
        companion object {
            private const val ANIMATION_DURATION = 300f
        }
    }
}
```

**RecyclerView Performance**

RecyclerView optimization involves proper ViewHolder implementation, efficient item decoration, and smooth scrolling techniques.

```kotlin
class RecyclerViewOptimization {
    
    class OptimizedAdapter(
        private val items: List<ListItem>
    ) : RecyclerView.Adapter<OptimizedAdapter.ViewHolder>() {
        
        private val recycledViewPool = RecyclerView.RecycledViewPool()
        
        init {
            // Pre-populate view pool
            recycledViewPool.setMaxRecycledViews(VIEW_TYPE_DEFAULT, 20)
            setHasStableIds(true) // Enable stable IDs if items have unique identifiers
        }
        
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.list_item, parent, false)
            return ViewHolder(view)
        }
        
        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            holder.bind(items[position])
        }
        
        override fun onBindViewHolder(
            holder: ViewHolder, 
            position: Int, 
            payloads: MutableList<Any>
        ) {
            if (payloads.isEmpty()) {
                super.onBindViewHolder(holder, position, payloads)
            } else {
                // Handle partial updates for better performance
                holder.bindPartial(items[position], payloads)
            }
        }
        
        override fun getItemCount(): Int = items.size
        
        override fun getItemId(position: Int): Long {
            return items[position].id // Use stable IDs
        }
        
        class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
            private val titleText: TextView = itemView.findViewById(R.id.title)
            private val imageView: ImageView = itemView.findViewById(R.id.image)
            
            fun bind(item: ListItem) {
                titleText.text = item.title
                
                // Use efficient image loading
                if (item.imageUrl.isNotEmpty()) {
                    Glide.with(itemView.context)
                        .load(item.imageUrl)
                        .placeholder(R.drawable.placeholder)
                        .into(imageView)
                } else {
                    imageView.setImageResource(R.drawable.default_image)
                }
            }
            
            fun bindPartial(item: ListItem, payloads: List<Any>) {
                payloads.forEach { payload ->
                    when (payload) {
                        is TitleUpdate -> titleText.text = payload.newTitle
                        is ImageUpdate -> {
                            Glide.with(itemView.context)
                                .load(payload.newImageUrl)
                                .into(imageView)
                        }
                    }
                }
            }
        }
        
        companion object {
            private const val VIEW_TYPE_DEFAULT = 0
        }
    }
    
    // DiffUtil for efficient list updates
    class ListItemDiffCallback : DiffUtil.ItemCallback<ListItem>() {
        override fun areItemsTheSame(oldItem: ListItem, newItem: ListItem): Boolean {
            return oldItem.id == newItem.id
        }
        
        override fun areContentsTheSame(oldItem: ListItem, newItem: ListItem): Boolean {
            return oldItem == newItem
        }
        
        override fun getChangePayload(oldItem: ListItem, newItem: ListItem): Any? {
            return when {
                oldItem.title != newItem.title -> TitleUpdate(newItem.title)
                oldItem.imageUrl != newItem.imageUrl -> ImageUpdate(newItem.imageUrl)
                else -> null
            }
        }
    }
    
    // Smooth scrolling implementation
    class SmoothScrollLayoutManager(context: Context) : LinearLayoutManager(context) {
        
        override fun smoothScrollToPosition(
            recyclerView: RecyclerView, 
            state: RecyclerView.State, 
            position: Int
        ) {
            val smoothScroller = object : LinearSmoothScroller(recyclerView.context) {
                override fun calculateSpeedPerPixel(displayMetrics: DisplayMetrics): Float {
                    return 100f / displayMetrics.densityDpi // Adjust scroll speed
                }
                
                override fun getVerticalSnapPreference(): Int {
                    return SNAP_TO_START
                }
            }
            
            smoothScroller.targetPosition = position
            startSmoothScroll(smoothScroller)
        }
    }
    
    // Optimized item decoration
    class OptimizedItemDecoration(
        private val spacing: Int
    ) : RecyclerView.ItemDecoration() {
        
        private val bounds = Rect()
        
        override fun getItemOffsets(
            outRect: Rect,
            view: View,
            parent: RecyclerView,
            state: RecyclerView.State
        ) {
            val position = parent.getChildAdapterPosition(view)
            
            outRect.left = spacing
            outRect.right = spacing
            outRect.bottom = spacing
            
            if (position == 0) {
                outRect.top = spacing
            }
        }
        
        override fun onDraw(c: Canvas, parent: RecyclerView, state: RecyclerView.State) {
            // Custom drawing optimization - cache paint objects
            drawHorizontalDividers(c, parent)
        }
        
        private fun drawHorizontalDividers(canvas: Canvas, parent: RecyclerView) {
            canvas.save()
            
            val left: Int
            val right: Int
            
            if (parent.clipToPadding) {
                left = parent.paddingLeft
                right = parent.width - parent.paddingRight
                canvas.clipRect(left, parent.paddingTop, right, parent.height - parent.paddingBottom)
            } else {
                left = 0
                right = parent.width
            }
            
            val childCount = parent.childCount
            for (i in 0 until childCount - 1) {
                val child = parent.getChildAt(i)
                parent.getDecoratedBoundsWithMargins(child, bounds)
                val bottom = bounds.bottom + Math.round(child.translationY)
                val top = bottom - spacing
                
                // Draw divider efficiently
                canvas.drawRect(left.toFloat(), top.toFloat(), right.toFloat(), bottom.toFloat(), dividerPaint)
            }
            
            canvas.restore()
        }
        
        companion object {
            private val dividerPaint = Paint().apply {
                color = Color.LTGRAY
                isAntiAlias = false // Disable anti-aliasing for simple shapes
            }
        }
    }
    
    data class TitleUpdate(val newTitle: String)
    data class ImageUpdate(val newImageUrl: String)
}
```

**Custom View Performance**

Custom views should optimize drawing operations and minimize unnecessary invalidations.

```kotlin
class PerformantCustomView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : View(context, attrs, defStyleAttr) {
    
    // Pre-allocated objects to avoid garbage collection during drawing
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
        color = Color.BLUE
    }
    
    private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        textSize = 48f
        color = Color.WHITE
        textAlign = Paint.Align.CENTER
    }
    
    private val bounds = Rect()
    private val tempRect = RectF()
    private var cachedBitmap: Bitmap? = null
    private var cacheCanvas: Canvas? = null
    private var isDirty = true
    
    private var circleRadius = 100f
        set(value) {
            if (field != value) {
                field = value
                isDirty = true
                invalidate()
            }
        }
    
    private var text = "Sample"
        set(value) {
            if (field != value) {
                field = value
                isDirty = true
                invalidate()
            }
        }
    
    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        
        // Recreate cache bitmap when size changes
        createCacheBitmap(w, h)
        isDirty = true
    }
    
    private fun createCacheBitmap(width: Int, height: Int) {
        cachedBitmap?.recycle()
        cachedBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        cacheCanvas = Canvas(cachedBitmap!!)
    }
    
    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        
        val bitmap = cachedBitmap ?: return
        
        if (isDirty) {
            drawToCache()
            isDirty = false
        }
        
        // Draw cached bitmap
        canvas.drawBitmap(bitmap, 0f, 0f, null)
    }
    
    private fun drawToCache() {
        val canvas = cacheCanvas ?: return
        
        // Clear previous content
        canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR)
        
        val centerX = width / 2f
        val centerY = height / 2f
        
        // Draw circle
        canvas.drawCircle(centerX, centerY, circleRadius, paint)
        
        // Draw text
        textPaint.getTextBounds(text, 0, text.length, bounds)
        val textY = centerY + bounds.height() / 2f
        canvas.drawText(text, centerX, textY, textPaint)
    }
    
    // Animate properties efficiently
    fun animateRadius(targetRadius: Float) {
        val animator = ValueAnimator.ofFloat(circleRadius, targetRadius)
        animator.duration = 300
        animator.addUpdateListener { animation ->
            circleRadius = animation.animatedValue as Float
        }
        animator.start()
    }
    
    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        // Clean up resources
        cachedBitmap?.recycle()
        cachedBitmap = null
        cacheCanvas = null
    }
}
```

**Key Points:**

- Use ConstraintLayout to flatten view hierarchies and improve layout performance
- Implement proper ViewHolder patterns with object reuse in RecyclerViews
- Optimize animations by using GPU-accelerated properties and hardware layers
- Cache complex drawing operations in custom views to avoid redundant calculations
- Use DiffUtil for efficient RecyclerView updates and stable IDs when appropriate

