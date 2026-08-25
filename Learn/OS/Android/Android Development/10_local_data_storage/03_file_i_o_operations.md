## File I/O Operations


File operations in Android follow standard Java I/O patterns with platform-specific considerations for storage locations and permissions.

### Advanced File Operations

```kotlin
class FileOperationsManager(private val context: Context) {
    
    // Copy files between storage locations
    fun copyFile(sourceFile: File, destinationFile: File): Boolean {
        return try {
            destinationFile.parentFile?.mkdirs()
            sourceFile.inputStream().use { input ->
                destinationFile.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
            true
        } catch (e: IOException) {
            e.printStackTrace()
            false
        }
    }
    
    // Read file in chunks for large files
    fun readFileInChunks(file: File, chunkSize: Int = 8192, onChunkRead: (ByteArray, Int) -> Unit) {
        try {
            FileInputStream(file).use { input ->
                val buffer = ByteArray(chunkSize)
                var bytesRead: Int
                while (input.read(buffer).also { bytesRead = it } != -1) {
                    onChunkRead(buffer, bytesRead)
                }
            }
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }
    
    // Compress and decompress files
    fun compressFile(inputFile: File, outputFile: File): Boolean {
        return try {
            FileInputStream(inputFile).use { fileInput ->
                FileOutputStream(outputFile).use { fileOutput ->
                    GZIPOutputStream(fileOutput).use { gzipOutput ->
                        fileInput.copyTo(gzipOutput)
                    }
                }
            }
            true
        } catch (e: IOException) {
            e.printStackTrace()
            false
        }
    }
    
    fun decompressFile(inputFile: File, outputFile: File): Boolean {
        return try {
            FileInputStream(inputFile).use { fileInput ->
                GZIPInputStream(fileInput).use { gzipInput ->
                    FileOutputStream(outputFile).use { fileOutput ->
                        gzipInput.copyTo(fileOutput)
                    }
                }
            }
            true
        } catch (e: IOException) {
            e.printStackTrace()
            false
        }
    }
    
    // Calculate file/directory sizes
    fun getDirectorySize(directory: File): Long {
        return if (directory.exists() && directory.isDirectory) {
            directory.walkTopDown()
                .filter { it.isFile }
                .map { it.length() }
                .sum()
        } else {
            0L
        }
    }
    
    // Create temporary files
    fun createTemporaryFile(prefix: String, suffix: String): File? {
        return try {
            File.createTempFile(prefix, suffix, context.cacheDir)
        } catch (e: IOException) {
            e.printStackTrace()
            null
        }
    }
    
    // Secure file deletion
    fun secureDeleteFile(file: File): Boolean {
        return try {
            if (file.exists()) {
                // Overwrite with random data before deletion
                RandomAccessFile(file, "rws").use { raf ->
                    val length = raf.length()
                    raf.seek(0)
                    val data = ByteArray(64)
                    Random().nextBytes(data)
                    for (i in 0 until length step 64) {
                        raf.write(data)
                    }
                    raf.fd.sync()
                }
                file.delete()
            } else {
                false
            }
        } catch (e: IOException) {
            e.printStackTrace()
            file.delete() // Fallback to normal deletion
        }
    }
}
```

### File Monitoring and Management

```kotlin
class FileMonitor(private val context: Context) {
    private val fileObserver: FileObserver?
    
    init {
        val watchDirectory = context.filesDir
        fileObserver = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            object : FileObserver(watchDirectory, FileObserver.ALL_EVENTS) {
                override fun onEvent(event: Int, path: String?) {
                    handleFileEvent(event, path)
                }
            }
        } else {
            @Suppress("DEPRECATION")
            object : FileObserver(watchDirectory.path, FileObserver.ALL_EVENTS) {
                override fun onEvent(event: Int, path: String?) {
                    handleFileEvent(event, path)
                }
            }
        }
    }
    
    private fun handleFileEvent(event: Int, path: String?) {
        when (event and FileObserver.ALL_EVENTS) {
            FileObserver.CREATE -> {
                // File created
            }
            FileObserver.DELETE -> {
                // File deleted
            }
            FileObserver.MODIFY -> {
                // File modified
            }
            FileObserver.MOVED_FROM -> {
                // File moved from this directory
            }
            FileObserver.MOVED_TO -> {
                // File moved to this directory
            }
        }
    }
    
    fun startWatching() {
        fileObserver?.startWatching()
    }
    
    fun stopWatching() {
        fileObserver?.stopWatching()
    }
}
```

