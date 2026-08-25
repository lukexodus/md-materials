## Image and Asset Optimization


Image optimization balances visual quality with file size and memory consumption through format selection, compression settings, and efficient loading strategies.

**Image Format Selection** Choosing appropriate image formats based on content characteristics optimizes file size and quality. WebP provides superior compression for photographs while vector formats suit scalable graphics.

```kotlin
// Dynamic image format selection based on content
fun selectOptimalFormat(imageType: ImageType): Bitmap.CompressFormat {
    return when (imageType) {
        ImageType.PHOTO -> Bitmap.CompressFormat.WEBP_LOSSY
        ImageType.SCREENSHOT -> Bitmap.CompressFormat.PNG
        ImageType.DIAGRAM -> Bitmap.CompressFormat.WEBP_LOSSLESS
    }
}

// Adaptive quality based on use case
fun compressImage(bitmap: Bitmap, usage: ImageUsage): ByteArray {
    val quality = when (usage) {
        ImageUsage.THUMBNAIL -> 60
        ImageUsage.FULL_SCREEN -> 85
        ImageUsage.PRINT_QUALITY -> 95
    }
    
    val outputStream = ByteArrayOutputStream()
    bitmap.compress(Bitmap.CompressFormat.WEBP_LOSSY, quality, outputStream)
    return outputStream.toByteArray()
}
```

**Image Loading Optimization** Efficient image loading requires proper scaling, caching, and memory management to prevent OutOfMemoryError exceptions and improve user experience.

```kotlin
class OptimizedImageLoader {
    private val memoryCache = LruCache<String, Bitmap>(getCacheSize())
    
    fun loadImage(imageUrl: String, targetWidth: Int, targetHeight: Int): Bitmap? {
        // Check memory cache first
        memoryCache.get(imageUrl)?.let { return it }
        
        // Load and scale image appropriately
        val options = BitmapFactory.Options().apply {
            inJustDecodeBounds = true
        }
        
        // Calculate inSampleSize for memory efficiency
        BitmapFactory.decodeFile(imageUrl, options)
        options.inSampleSize = calculateInSampleSize(options, targetWidth, targetHeight)
        options.inJustDecodeBounds = false
        
        return BitmapFactory.decodeFile(imageUrl, options)?.also { bitmap ->
            memoryCache.put(imageUrl, bitmap)
        }
    }
    
    private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
        val (height, width) = options.run { outHeight to outWidth }
        var inSampleSize = 1
        
        if (height > reqHeight || width > reqWidth) {
            val halfHeight = height / 2
            val halfWidth = width / 2
            
            while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
                inSampleSize *= 2
            }
        }
        return inSampleSize
    }
    
    private fun getCacheSize(): Int {
        val maxMemory = (Runtime.getRuntime().maxMemory() / 1024).toInt()
        return maxMemory / 8 // Use 1/8th of available memory for cache
    }
}
```

**Progressive Image Loading** Progressive loading improves perceived performance by showing lower quality images immediately while higher quality versions load in the background.

```kotlin
class ProgressiveImageView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : AppCompatImageView(context, attrs) {
    
    private var lowResolutionBitmap: Bitmap? = null
    private var highResolutionBitmap: Bitmap? = null
    
    fun loadProgressively(lowResUrl: String, highResUrl: String) {
        // Load low resolution immediately
        loadLowResolution(lowResUrl) {
            setImageBitmap(it)
            
            // Load high resolution in background
            loadHighResolution(highResUrl) { highResBitmap ->
                animateImageTransition(highResBitmap)
            }
        }
    }
    
    private fun animateImageTransition(newBitmap: Bitmap) {
        val fadeIn = ObjectAnimator.ofFloat(this, "alpha", 0.7f, 1.0f).apply {
            duration = 300
        }
        
        setImageBitmap(newBitmap)
        fadeIn.start()
    }
}
```

**Image Caching Strategy** Multi-level caching with memory and disk tiers optimizes loading performance while managing storage constraints.

```kotlin
class MultiLevelImageCache(private val context: Context) {
    private val memoryCache = LruCache<String, Bitmap>(getMemoryCacheSize())
    private val diskCache = DiskLruCache.open(getCacheDirectory(), 1, 1, DISK_CACHE_SIZE)
    
    fun getBitmap(key: String): Bitmap? {
        // Try memory cache first
        memoryCache.get(key)?.let { return it }
        
        // Try disk cache
        return getDiskCachedBitmap(key)?.also { bitmap ->
            // Promote to memory cache
            memoryCache.put(key, bitmap)
        }
    }
    
    fun putBitmap(key: String, bitmap: Bitmap) {
        memoryCache.put(key, bitmap)
        saveToDiskCache(key, bitmap)
    }
    
    private fun getDiskCachedBitmap(key: String): Bitmap? {
        return try {
            val snapshot = diskCache.get(key.md5())
            snapshot?.getInputStream(0)?.use { inputStream ->
                BitmapFactory.decodeStream(inputStream)
            }
        } catch (e: IOException) {
            null
        }
    }
    
    companion object {
        private const val DISK_CACHE_SIZE = 50 * 1024 * 1024L // 50MB
    }
}
```

