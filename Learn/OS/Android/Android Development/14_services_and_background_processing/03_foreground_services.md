## Foreground Services


Foreground services perform operations noticeable to users and must display persistent notifications, providing transparency about background activities.

### Foreground Service Implementation

Foreground services require ongoing notifications and appropriate permissions for long-running operations.

```kotlin
class DownloadService : Service() {
    
    private val notificationId = 1001
    private val channelId = "download_channel"
    private var downloadJob: Job? = null
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START_DOWNLOAD -> {
                val downloadUrl = intent.getStringExtra(EXTRA_DOWNLOAD_URL)
                val fileName = intent.getStringExtra(EXTRA_FILE_NAME)
                startDownload(downloadUrl, fileName)
            }
            ACTION_CANCEL_DOWNLOAD -> {
                cancelDownload()
            }
        }
        
        return START_NOT_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    private fun startDownload(url: String?, fileName: String?) {
        if (url == null || fileName == null) {
            stopSelf()
            return
        }
        
        val notification = createNotification("Starting download...", 0)
        startForeground(notificationId, notification)
        
        downloadJob = CoroutineScope(Dispatchers.IO).launch {
            try {
                downloadFile(url, fileName)
            } catch (e: Exception) {
                Log.e("DownloadService", "Download failed", e)
                showErrorNotification("Download failed: ${e.message}")
            } finally {
                stopForeground(true)
                stopSelf()
            }
        }
    }
    
    private suspend fun downloadFile(url: String, fileName: String) {
        val client = OkHttpClient()
        val request = Request.Builder().url(url).build()
        
        client.newCall(request).execute().use { response ->
            if (!response.isSuccessful) {
                throw IOException("Download failed: ${response.code}")
            }
            
            val body = response.body ?: throw IOException("Empty response body")
            val contentLength = body.contentLength()
            val inputStream = body.byteStream()
            
            val outputFile = File(getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS), fileName)
            val outputStream = FileOutputStream(outputFile)
            
            val buffer = ByteArray(8192)
            var totalBytesRead = 0L
            var bytesRead: Int
            
            while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                if (!isActive) break // Check for cancellation
                
                outputStream.write(buffer, 0, bytesRead)
                totalBytesRead += bytesRead
                
                // Update progress notification
                val progress = if (contentLength > 0) {
                    (totalBytesRead * 100 / contentLength).toInt()
                } else 0
                
                withContext(Dispatchers.Main) {
                    updateNotification("Downloading $fileName", progress)
                }
            }
            
            outputStream.close()
            inputStream.close()
            
            if (isActive) {
                withContext(Dispatchers.Main) {
                    showCompletionNotification("Download completed: $fileName")
                }
            }
        }
    }
    
    private fun cancelDownload() {
        downloadJob?.cancel()
        stopForeground(true)
        stopSelf()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Download Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows download progress"
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(title: String, progress: Int): Notification {
        val cancelIntent = Intent(this, DownloadService::class.java).apply {
            action = ACTION_CANCEL_DOWNLOAD
        }
        val cancelPendingIntent = PendingIntent.getService(
            this, 0, cancelIntent, PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, channelId)
            .setContentTitle(title)
            .setSmallIcon(R.drawable.ic_download)
            .setProgress(100, progress, progress == 0)
            .setOngoing(true)
            .addAction(R.drawable.ic_cancel, "Cancel", cancelPendingIntent)
            .build()
    }
    
    private fun updateNotification(title: String, progress: Int) {
        val notification = createNotification(title, progress)
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(notificationId, notification)
    }
    
    private fun showCompletionNotification(message: String) {
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Download Complete")
            .setContentText(message)
            .setSmallIcon(R.drawable.ic_download_done)
            .setAutoCancel(true)
            .build()
        
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(notificationId + 1, notification)
    }
    
    private fun showErrorNotification(message: String) {
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Download Error")
            .setContentText(message)
            .setSmallIcon(R.drawable.ic_error)
            .setAutoCancel(true)
            .build()
        
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(notificationId + 2, notification)
    }
    
    companion object {
        const val ACTION_START_DOWNLOAD = "com.example.START_DOWNLOAD"
        const val ACTION_CANCEL_DOWNLOAD = "com.example.CANCEL_DOWNLOAD"
        const val EXTRA_DOWNLOAD_URL = "download_url"
        const val EXTRA_FILE_NAME = "file_name"
    }
}
```

### Foreground Service Types

Android 10+ requires declaring specific foreground service types based on the service's functionality.

```xml
<!-- AndroidManifest.xml -->
<service 
    android:name=".services.DownloadService"
    android:foregroundServiceType="dataSync" />

<service 
    android:name=".services.LocationTrackingService"
    android:foregroundServiceType="location" />

<service 
    android:name=".services.MusicPlayerService"
    android:foregroundServiceType="mediaPlayback" />
```

```kotlin
class LocationTrackingService : Service() {
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID, 
                createNotification(),
                ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
            )
        } else {
            startForeground(NOTIFICATION_ID, createNotification())
        }
        
        startLocationTracking()
        return START_STICKY
    }
    
    private fun startLocationTracking() {
        // Implementation for location tracking
    }
}
```

