## Internal and External Storage


Android provides distinct storage areas with different access permissions, security characteristics, and persistence behaviors.

### Internal Storage

Internal storage provides private app-specific storage that other applications cannot access without root permissions.

**Key points:**

- Always available regardless of external storage state
- Files are private to the application by default
- Automatically removed when app is uninstalled
- No special permissions required for access

```kotlin
class InternalStorageManager(private val context: Context) {
    
    // Write text data to internal storage
    fun writeToInternalFile(filename: String, content: String): Boolean {
        return try {
            context.openFileOutput(filename, Context.MODE_PRIVATE).use { output ->
                output.write(content.toByteArray())
            }
            true
        } catch (e: IOException) {
            e.printStackTrace()
            false
        }
    }
    
    // Read text data from internal storage
    fun readFromInternalFile(filename: String): String? {
        return try {
            context.openFileInput(filename).use { input ->
                input.readBytes().toString(Charset.defaultCharset())
            }
        } catch (e: IOException) {
            e.printStackTrace()
            null
        }
    }
    
    // Write binary data (images, documents)
    fun writeBinaryToInternal(filename: String, data: ByteArray): Boolean {
        return try {
            val file = File(context.filesDir, filename)
            FileOutputStream(file).use { output ->
                output.write(data)
            }
            true
        } catch (e: IOException) {
            e.printStackTrace()
            false
        }
    }
    
    // Cache directory operations
    fun writeToCacheDir(filename: String, content: String): Boolean {
        return try {
            val cacheFile = File(context.cacheDir, filename)
            cacheFile.writeText(content)
            true
        } catch (e: IOException) {
            e.printStackTrace()
            false
        }
    }
    
    fun getCacheFileSize(): Long {
        return context.cacheDir.walkTopDown()
            .filter { it.isFile }
            .map { it.length() }
            .sum()
    }
    
    // List all files in internal storage
    fun listInternalFiles(): Array<String> {
        return context.fileList()
    }
    
    // Delete internal file
    fun deleteInternalFile(filename: String): Boolean {
        return context.deleteFile(filename)
    }
}
```

### External Storage

External storage provides broader access patterns but requires permission management and availability checking.

**Key points:**

- May not always be available (removable storage)
- Requires WRITE_EXTERNAL_STORAGE permission for API < 29
- Uses scoped storage for API 29+ (Android 10)
- Files may persist after app uninstallation

```kotlin
class ExternalStorageManager(private val context: Context) {
    
    // Check external storage availability
    fun isExternalStorageWritable(): Boolean {
        return Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED
    }
    
    fun isExternalStorageReadable(): Boolean {
        val state = Environment.getExternalStorageState()
        return state == Environment.MEDIA_MOUNTED || state == Environment.MEDIA_MOUNTED_READ_ONLY
    }
    
    // App-specific external storage (no permissions required API 19+)
    fun writeToExternalAppStorage(filename: String, content: String): Boolean {
        if (!isExternalStorageWritable()) return false
        
        return try {
            val file = File(context.getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS), filename)
            file.parentFile?.mkdirs()
            file.writeText(content)
            true
        } catch (e: IOException) {
            e.printStackTrace()
            false
        }
    }
    
    fun readFromExternalAppStorage(filename: String): String? {
        if (!isExternalStorageReadable()) return null
        
        return try {
            val file = File(context.getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS), filename)
            if (file.exists()) file.readText() else null
        } catch (e: IOException) {
            e.printStackTrace()
            null
        }
    }
    
    // Media storage operations (scoped storage compliant)
    fun saveImageToMediaStore(bitmap: Bitmap, displayName: String): Uri? {
        val resolver = context.contentResolver
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, displayName)
            put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
            put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_PICTURES)
        }
        
        return try {
            val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
            uri?.let { imageUri ->
                resolver.openOutputStream(imageUri)?.use { output ->
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 90, output)
                }
            }
            uri
        } catch (e: IOException) {
            e.printStackTrace()
            null
        }
    }
    
    // Legacy external storage (requires permissions)
    @Deprecated("Use scoped storage for API 29+")
    fun writeToPublicExternalStorage(directory: String, filename: String, content: String): Boolean {
        if (!isExternalStorageWritable()) return false
        
        return try {
            val publicDir = File(Environment.getExternalStoragePublicDirectory(directory), filename)
            publicDir.parentFile?.mkdirs()
            publicDir.writeText(content)
            true
        } catch (e: IOException) {
            e.printStackTrace()
            false
        }
    }
}
```

