## Service Types and Lifecycle


Android services operate through a well-defined lifecycle with specific callback methods that manage their creation, execution, and destruction phases.

### Started Services

Started services run indefinitely until explicitly stopped or until they stop themselves, making them suitable for operations that don't require interaction with other components.

```kotlin
class MusicPlayerService : Service() {
    
    private var mediaPlayer: MediaPlayer? = null
    private var isPlaying = false
    
    override fun onCreate() {
        super.onCreate()
        Log.d("MusicPlayerService", "Service created")
        initializeMediaPlayer()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_PLAY -> startPlaying()
            ACTION_PAUSE -> pausePlaying()
            ACTION_STOP -> stopPlaying()
        }
        
        // Return START_STICKY to restart service if killed by system
        return START_STICKY
    }
    
    override fun onDestroy() {
        super.onDestroy()
        mediaPlayer?.release()
        mediaPlayer = null
        Log.d("MusicPlayerService", "Service destroyed")
    }
    
    override fun onBind(intent: Intent?): IBinder? {
        return null // Not a bound service
    }
    
    private fun initializeMediaPlayer() {
        mediaPlayer = MediaPlayer().apply {
            setOnPreparedListener { 
                isPlaying = true
                start()
            }
            setOnCompletionListener {
                isPlaying = false
                stopSelf()
            }
            setOnErrorListener { _, what, extra ->
                Log.e("MusicPlayerService", "MediaPlayer error: $what, $extra")
                stopSelf()
                true
            }
        }
    }
    
    private fun startPlaying() {
        mediaPlayer?.let { player ->
            if (!isPlaying) {
                try {
                    player.prepareAsync()
                } catch (e: IllegalStateException) {
                    Log.e("MusicPlayerService", "Error starting playback", e)
                }
            }
        }
    }
    
    private fun pausePlaying() {
        mediaPlayer?.let { player ->
            if (isPlaying && player.isPlaying) {
                player.pause()
                isPlaying = false
            }
        }
    }
    
    private fun stopPlaying() {
        mediaPlayer?.let { player ->
            if (player.isPlaying) {
                player.stop()
                isPlaying = false
            }
        }
        stopSelf()
    }
    
    companion object {
        const val ACTION_PLAY = "com.example.ACTION_PLAY"
        const val ACTION_PAUSE = "com.example.ACTION_PAUSE"
        const val ACTION_STOP = "com.example.ACTION_STOP"
    }
}
```

### Service Return Flags

Different return flags from `onStartCommand()` determine service restart behavior when the system kills the service due to resource constraints.

```kotlin
class BackgroundSyncService : Service() {
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val taskType = intent?.getStringExtra("task_type")
        
        when (taskType) {
            "critical_sync" -> {
                performCriticalSync()
                // Restart with same intent if killed
                return START_REDELIVER_INTENT
            }
            "periodic_cleanup" -> {
                performCleanup()
                // Restart without intent if killed
                return START_STICKY
            }
            "one_time_task" -> {
                performOneTimeTask()
                // Don't restart if killed
                return START_NOT_STICKY
            }
            else -> {
                stopSelf(startId)
                return START_NOT_STICKY
            }
        }
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    private fun performCriticalSync() {
        Thread {
            // Simulate critical sync operation
            Thread.sleep(5000)
            stopSelf()
        }.start()
    }
    
    private fun performCleanup() {
        Thread {
            // Simulate cleanup operation
            Thread.sleep(3000)
            stopSelf()
        }.start()
    }
    
    private fun performOneTimeTask() {
        Thread {
            // Simulate one-time task
            Thread.sleep(2000)
            stopSelf()
        }.start()
    }
}
```

