## Progress Indicators


Progress indicators provide visual feedback about ongoing operations, loading states, and task completion status.

### ProgressBar

ProgressBar displays progress for determinate and indeterminate operations with various visual styles.

**Key points:**

- Supports horizontal and circular orientations
- Provides determinate (specific progress) and indeterminate (ongoing) modes
- Can be styled with custom colors and animations
- Integrates with Material Design specifications

```kotlin
// Indeterminate progress bar (XML)
<ProgressBar
    android:id="@+id/progressBarIndeterminate"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:indeterminate="true" />

// Determinate progress bar (XML)
<ProgressBar
    android:id="@+id/progressBarDeterminate"
    style="?android:attr/progressBarStyleHorizontal"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:max="100"
    android:progress="0" />

// Programmatic usage
val progressBar = findViewById<ProgressBar>(R.id.progressBarDeterminate)

// Update progress
fun updateProgress(currentProgress: Int) {
    progressBar.progress = currentProgress
}

// Animate progress changes
fun animateProgress(targetProgress: Int) {
    val animator = ObjectAnimator.ofInt(progressBar, "progress", progressBar.progress, targetProgress)
    animator.duration = 1000
    animator.start()
}

// Material Design progress indicator
<com.google.android.material.progressindicator.LinearProgressIndicator
    android:id="@+id/linearProgress"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    app:indicatorColor="@color/primary"
    app:trackColor="@color/surface" />
```

### SeekBar

SeekBar allows users to select values from a continuous range through touch interactions.

**Key points:**

- Supports custom range definitions (min/max values)
- Provides progress change callbacks
- Can display custom thumb and track styling
- Supports discrete value selection with tick marks

```kotlin
// XML implementation
<SeekBar
    android:id="@+id/seekBar"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:max="100"
    android:progress="50" />

// Usage with listener
val seekBar = findViewById<SeekBar>(R.id.seekBar)
seekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
    override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
        if (fromUser) {
            // Handle progress change from user interaction
        }
    }
    
    override fun onStartTrackingTouch(seekBar: SeekBar?) {
        // User started touching the seek bar
    }
    
    override fun onStopTrackingTouch(seekBar: SeekBar?) {
        // User stopped touching the seek bar
    }
})

// Custom styling
<SeekBar
    android:id="@+id/styledSeekBar"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:max="200"
    android:progress="100"
    android:progressTint="@color/primary"
    android:thumbTint="@color/accent" />
```

