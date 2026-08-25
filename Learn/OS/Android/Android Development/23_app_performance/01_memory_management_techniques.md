## Memory Management Techniques


Android memory management involves understanding the garbage collector, heap allocation patterns, and lifecycle-aware resource management. Effective memory management prevents OutOfMemoryError crashes and maintains application responsiveness.

**Heap Management and Garbage Collection**

Android uses generational garbage collection with different heap regions for object allocation. The ART runtime optimizes memory through compacting garbage collection, but applications must still manage allocation patterns carefully.

```kotlin
class ImageManager {
    private val imageCache = LruCache<String, Bitmap>(getCacheSize())
    private val weakReferences = WeakHashMap<String, WeakReference<Bitmap>>()
    
    private fun getCacheSize(): Int {
        val maxMemory = (Runtime.getRuntime().maxMemory() / 1024).toInt()
        return maxMemory / 8 // Use 1/8th of available memory
    }
    
    fun loadImage(url: String): Bitmap? {
        // Check strong cache first
        imageCache.get(url)?.let { return it }
        
        // Check weak references
        weakReferences[url]?.get()?.let { bitmap ->
            imageCache.put(url, bitmap) // Move back to strong cache
            return bitmap
        }
        
        return loadImageFromNetwork(url)
    }
    
    private fun loadImageFromNetwork(url: String): Bitmap? {
        // [Inference] Implementation would involve network loading
        // and proper bitmap scaling to prevent memory issues
        return null
    }
}
```

**Memory Leak Prevention**

Memory leaks occur when objects retain references preventing garbage collection. Common sources include static contexts, inner class references, and unclosed resources.

```kotlin
class LeakPreventionExamples {
    
    // Weak reference for context to prevent leaks
    private var contextRef: WeakReference<Context>? = null
    
    // Static inner class prevents outer class reference retention
    private static class StaticHandler : Handler(Looper.getMainLooper()) {
        private val activityRef = WeakReference<MainActivity>()
        
        constructor(activity: MainActivity) : this() {
            activityRef = WeakReference(activity)
        }
        
        override fun handleMessage(msg: Message) {
            activityRef.get()?.let { activity ->
                // Handle message with activity reference
            }
        }
    }
    
    // Proper resource management with try-with-resources equivalent
    fun readFileContent(file: File): String? {
        return try {
            file.inputStream().bufferedReader().use { reader ->
                reader.readText()
            }
        } catch (e: IOException) {
            null
        }
    }
    
    // Lifecycle-aware observer registration
    class LocationTracker(private val lifecycleOwner: LifecycleOwner) {
        private val locationManager = LocationManagerCompat()
        
        fun startTracking() {
            lifecycleOwner.lifecycle.addObserver(object : DefaultLifecycleObserver {
                override fun onStart(owner: LifecycleOwner) {
                    registerLocationUpdates()
                }
                
                override fun onStop(owner: LifecycleOwner) {
                    unregisterLocationUpdates()
                }
                
                override fun onDestroy(owner: LifecycleOwner) {
                    cleanup()
                }
            })
        }
        
        private fun registerLocationUpdates() {
            // Register for location updates
        }
        
        private fun unregisterLocationUpdates() {
            // Unregister location updates
        }
        
        private fun cleanup() {
            // Clean up resources
        }
    }
}
```

**Bitmap Memory Management**

Bitmap handling requires special attention due to their large memory footprint. Proper scaling, recycling, and caching prevent memory exhaustion.

```kotlin
class BitmapManager {
    
    fun decodeBitmapFromResource(
        resources: Resources,
        resId: Int,
        reqWidth: Int,
        reqHeight: Int
    ): Bitmap {
        return BitmapFactory.Options().run {
            inJustDecodeBounds = true
            BitmapFactory.decodeResource(resources, resId, this)
            
            inSampleSize = calculateInSampleSize(this, reqWidth, reqHeight)
            inJustDecodeBounds = false
            inPreferredConfig = Bitmap.Config.RGB_565 // Use less memory when appropriate
            
            BitmapFactory.decodeResource(resources, resId, this)
        }
    }
    
    private fun calculateInSampleSize(
        options: BitmapFactory.Options,
        reqWidth: Int,
        reqHeight: Int
    ): Int {
        val (height: Int, width: Int) = options.run { outHeight to outWidth }
        var inSampleSize = 1
        
        if (height > reqHeight || width > reqWidth) {
            val halfHeight: Int = height / 2
            val halfWidth: Int = width / 2
            
            while (halfHeight / inSampleSize >= reqHeight && 
                   halfWidth / inSampleSize >= reqWidth) {
                inSampleSize *= 2
            }
        }
        
        return inSampleSize
    }
    
    // Bitmap pool for reusing bitmap memory
    class BitmapPool {
        private val pool = mutableMapOf<String, MutableList<Bitmap>>()
        
        fun getBitmap(width: Int, height: Int, config: Bitmap.Config): Bitmap? {
            val key = "${width}x${height}_${config}"
            return pool[key]?.removeFirstOrNull()
        }
        
        fun returnBitmap(bitmap: Bitmap) {
            if (!bitmap.isRecycled) {
                val key = "${bitmap.width}x${bitmap.height}_${bitmap.config}"
                pool.getOrPut(key) { mutableListOf() }.add(bitmap)
            }
        }
    }
}
```

**Memory Profiling and Monitoring**

Memory monitoring helps identify allocation patterns and potential issues during development and production.

```kotlin
class MemoryMonitor {
    
    fun logMemoryStats() {
        val runtime = Runtime.getRuntime()
        val maxMemory = runtime.maxMemory() / 1024 / 1024
        val totalMemory = runtime.totalMemory() / 1024 / 1024
        val freeMemory = runtime.freeMemory() / 1024 / 1024
        val usedMemory = totalMemory - freeMemory
        
        Log.d("MemoryMonitor", "Memory Stats:")
        Log.d("MemoryMonitor", "Max: ${maxMemory}MB")
        Log.d("MemoryMonitor", "Total: ${totalMemory}MB")
        Log.d("MemoryMonitor", "Used: ${usedMemory}MB")
        Log.d("MemoryMonitor", "Free: ${freeMemory}MB")
    }
    
    fun checkLowMemory(context: Context): Boolean {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memoryInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memoryInfo)
        
        return memoryInfo.lowMemory
    }
    
    // Custom memory warning system
    fun monitorMemoryPressure(callback: (MemoryPressure) -> Unit) {
        val handler = Handler(Looper.getMainLooper())
        val runnable = object : Runnable {
            override fun run() {
                val runtime = Runtime.getRuntime()
                val usedMemoryPercentage = (runtime.totalMemory() - runtime.freeMemory()).toFloat() / runtime.maxMemory()
                
                val pressure = when {
                    usedMemoryPercentage > 0.9f -> MemoryPressure.CRITICAL
                    usedMemoryPercentage > 0.75f -> MemoryPressure.HIGH
                    usedMemoryPercentage > 0.5f -> MemoryPressure.MODERATE
                    else -> MemoryPressure.LOW
                }
                
                callback(pressure)
                handler.postDelayed(this, 5000) // Check every 5 seconds
            }
        }
        handler.post(runnable)
    }
    
    enum class MemoryPressure {
        LOW, MODERATE, HIGH, CRITICAL
    }
}
```

**Key Points:**

- Implement proper caching strategies with size limitations
- Use weak references for context and activity references
- Scale bitmaps appropriately before loading into memory
- Monitor memory usage during development and testing
- Handle low memory conditions gracefully with resource cleanup

