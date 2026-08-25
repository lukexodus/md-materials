## IntentService Implementation


IntentService provides a simplified service implementation for handling asynchronous requests on a separate thread, automatically stopping when work completes.

### Basic IntentService Structure

IntentService handles each intent sequentially on a background thread and automatically stops when all requests are processed.

```kotlin
class FileProcessingIntentService : IntentService("FileProcessingIntentService") {
    
    override fun onHandleIntent(intent: Intent?) {
        when (intent?.action) {
            ACTION_PROCESS_IMAGE -> {
                val imagePath = intent.getStringExtra(EXTRA_IMAGE_PATH)
                val outputPath = intent.getStringExtra(EXTRA_OUTPUT_PATH)
                processImage(imagePath, outputPath)
            }
            ACTION_COMPRESS_FILE -> {
                val filePath = intent.getStringExtra(EXTRA_FILE_PATH)
                val compressionLevel = intent.getIntExtra(EXTRA_COMPRESSION_LEVEL, 5)
                compressFile(filePath, compressionLevel)
            }
            ACTION_GENERATE_THUMBNAIL -> {
                val videoPath = intent.getStringExtra(EXTRA_VIDEO_PATH)
                val thumbnailPath = intent.getStringExtra(EXTRA_THUMBNAIL_PATH)
                generateThumbnail(videoPath, thumbnailPath)
            }
        }
    }
    
    private fun processImage(inputPath: String?, outputPath: String?) {
        if (inputPath == null || outputPath == null) return
        
        try {
            Log.d(TAG, "Processing image: $inputPath")
            
            // Simulate image processing
            val bitmap = BitmapFactory.decodeFile(inputPath)
            val processedBitmap = applyImageFilters(bitmap)
            
            // Save processed image
            val outputStream = FileOutputStream(outputPath)
            processedBitmap.compress(Bitmap.CompressFormat.JPEG, 90, outputStream)
            outputStream.close()
            
            // Notify completion
            sendProcessingResult(ACTION_PROCESS_IMAGE, outputPath, true)
            
            Log.d(TAG, "Image processing completed: $outputPath")
            
        } catch (e: Exception) {
            Log.e(TAG, "Image processing failed", e)
            sendProcessingResult(ACTION_PROCESS_IMAGE, inputPath, false)
        }
    }
    
    private fun compressFile(filePath: String?, compressionLevel: Int) {
        if (filePath == null) return
        
        try {
            Log.d(TAG, "Compressing file: $filePath")
            
            val inputFile = File(filePath)
            val outputFile = File(inputFile.parent, "${inputFile.nameWithoutExtension}_compressed.zip")
            
            // Simulate file compression
            Thread.sleep(2000) // Simulate processing time
            
            sendProcessingResult(ACTION_COMPRESS_FILE, outputFile.absolutePath, true)
            
            Log.d(TAG, "File compression completed: ${outputFile.absolutePath}")
            
        } catch (e: Exception) {
            Log.e(TAG, "File compression failed", e)
            sendProcessingResult(ACTION_COMPRESS_FILE, filePath, false)
        }
    }
    
    private fun generateThumbnail(videoPath: String?, thumbnailPath: String?) {
        if (videoPath == null || thumbnailPath == null) return
        
        try {
            Log.d(TAG, "Generating thumbnail: $videoPath")
            
            // Simulate thumbnail generation
            val retriever = MediaMetadataRetriever()
            retriever.setDataSource(videoPath)
            val bitmap = retriever.getFrameAtTime(1000000) // 1 second
            retriever.release()
            
            if (bitmap != null) {
                val outputStream = FileOutputStream(thumbnailPath)
                bitmap.compress(Bitmap.CompressFormat.JPEG, 80, outputStream)
                outputStream.close()
                
                sendProcessingResult(ACTION_GENERATE_THUMBNAIL, thumbnailPath, true)
                Log.d(TAG, "Thumbnail generation completed: $thumbnailPath")
            } else {
                throw Exception("Failed to extract frame from video")
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Thumbnail generation failed", e)
            sendProcessingResult(ACTION_GENERATE_THUMBNAIL, videoPath, false)
        }
    }
    
    private fun applyImageFilters(original: Bitmap): Bitmap {
        // Simulate image filtering
        val matrix = ColorMatrix().apply {
            setSaturation(1.2f)
        }
        
        val paint = Paint().apply {
            colorFilter = ColorMatrixColorFilter(matrix)
        }
        
        val result = Bitmap.createBitmap(original.width, original.height, original.config)
        val canvas = Canvas(result)
        canvas.drawBitmap(original, 0f, 0f, paint)
        
        return result
    }
    
    private fun sendProcessingResult(action: String, filePath: String, success: Boolean) {
        val resultIntent = Intent(BROADCAST_PROCESSING_RESULT).apply {
            putExtra(EXTRA_ACTION, action)
            putExtra(EXTRA_FILE_PATH, filePath)
            putExtra(EXTRA_SUCCESS, success)
        }
        
        LocalBroadcastManager.getInstance(this).sendBroadcast(resultIntent)
    }
    
    companion object {
        private const val TAG = "FileProcessingService"
        
        const val ACTION_PROCESS_IMAGE = "com.example.PROCESS_IMAGE"
        const val ACTION_COMPRESS_FILE = "com.example.COMPRESS_FILE"
        const val ACTION_GENERATE_THUMBNAIL = "com.example.GENERATE_THUMBNAIL"
        
        const val EXTRA_IMAGE_PATH = "image_path"
        const val EXTRA_OUTPUT_PATH = "output_path"
        const val EXTRA_FILE_PATH = "file_path"
        const val EXTRA_VIDEO_PATH = "video_path"
        const val EXTRA_THUMBNAIL_PATH = "thumbnail_path"
        const val EXTRA_COMPRESSION_LEVEL = "compression_level"
        
        const val BROADCAST_PROCESSING_RESULT = "com.example.PROCESSING_RESULT"
        const val EXTRA_ACTION = "action"
        const val EXTRA_SUCCESS = "success"
    }
}

// Usage in Activity
class MainActivity : AppCompatActivity() {
    
    private val processingReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val action = intent?.getStringExtra(FileProcessingIntentService.EXTRA_ACTION)
            val filePath = intent?.getStringExtra(FileProcessingIntentService.EXTRA_FILE_PATH)
            val success = intent?.getBooleanExtra(FileProcessingIntentService.EXTRA_SUCCESS, false) ?: false
            
            handleProcessingResult(action, filePath, success)
        }
    }
    
    override fun onResume() {
        super.onResume()
        LocalBroadcastManager.getInstance(this).registerReceiver(
            processingReceiver,
            IntentFilter(FileProcessingIntentService.BROADCAST_PROCESSING_RESULT)
        )
    }
    
    override fun onPause() {
        super.onPause()
        LocalBroadcastManager.getInstance(this).unregisterReceiver(processingReceiver)
    }
    
    private fun startImageProcessing(inputPath: String, outputPath: String) {
        val intent = Intent(this, FileProcessingIntentService::class.java).apply {
            action = FileProcessingIntentService.ACTION_PROCESS_IMAGE
            putExtra(FileProcessingIntentService.EXTRA_IMAGE_PATH, inputPath)
            putExtra(FileProcessingIntentService.EXTRA_OUTPUT_PATH, outputPath)
        }
        startService(intent)
    }
    
    private fun handleProcessingResult(action: String?, filePath: String?, success: Boolean) {
        runOnUiThread {
            val message = if (success) {
                "Processing completed: $filePath"
            } else {
                "Processing failed: $filePath"
            }
            Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
        }
    }
}
```

