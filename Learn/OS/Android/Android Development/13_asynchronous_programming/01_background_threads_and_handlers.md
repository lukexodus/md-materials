## Background Threads and Handlers


Android's main thread (UI thread) handles all user interface operations. Any long-running operation must be executed on background threads to avoid blocking the UI. The Handler-Looper system provides the foundation for thread communication in Android.

**Key Points:**

- Main thread is the only thread that can update UI components
- Background threads cannot directly modify UI elements
- Handler and Looper facilitate message passing between threads
- Each thread can have at most one Looper
- Main thread has a Looper created automatically

**Handler and Looper Implementation:**

```kotlin
class BackgroundTaskActivity : AppCompatActivity() {
    
    private lateinit var binding: ActivityMainBinding
    private lateinit var backgroundHandler: Handler
    private lateinit var backgroundThread: HandlerThread
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        // Create background thread with Looper
        backgroundThread = HandlerThread("BackgroundThread")
        backgroundThread.start()
        
        // Create handler for background thread
        backgroundHandler = Handler(backgroundThread.looper)
        
        // Main thread handler
        val mainHandler = Handler(Looper.getMainLooper())
        
        binding.startTaskButton.setOnClickListener {
            performBackgroundTask(mainHandler)
        }
    }
    
    private fun performBackgroundTask(mainHandler: Handler) {
        // Update UI before starting
        binding.progressBar.visibility = View.VISIBLE
        binding.resultText.text = "Processing..."
        
        // Execute on background thread
        backgroundHandler.post {
            // Simulate long-running task
            Thread.sleep(3000)
            val result = performHeavyComputation()
            
            // Switch back to main thread for UI update
            mainHandler.post {
                binding.progressBar.visibility = View.GONE
                binding.resultText.text = "Result: $result"
            }
        }
    }
    
    private fun performHeavyComputation(): String {
        // Simulate CPU-intensive work
        return "Computation completed at ${System.currentTimeMillis()}"
    }
    
    override fun onDestroy() {
        super.onDestroy()
        backgroundThread.quitSafely()
    }
}

// Custom Handler for specific thread communication
class NetworkHandler : Handler {
    constructor(looper: Looper) : super(looper)
    
    override fun handleMessage(msg: Message) {
        when (msg.what) {
            MSG_DOWNLOAD_START -> {
                val url = msg.obj as String
                performDownload(url)
            }
            MSG_DOWNLOAD_COMPLETE -> {
                // Handle completion
            }
        }
    }
    
    private fun performDownload(url: String) {
        // Implementation here
    }
    
    companion object {
        const val MSG_DOWNLOAD_START = 1
        const val MSG_DOWNLOAD_COMPLETE = 2
    }
}

// Using Runnable for simple tasks
class SimpleBackgroundTask {
    private val handler = Handler(Looper.getMainLooper())
    
    fun executeTask() {
        Thread {
            // Background work
            val data = fetchDataFromNetwork()
            
            // Post result to main thread
            handler.post {
                updateUI(data)
            }
        }.start()
    }
    
    private fun fetchDataFromNetwork(): String {
        // Network operation
        return "Data"
    }
    
    private fun updateUI(data: String) {
        // Update UI components
    }
}
```

**Thread Communication Patterns:**

```kotlin
class ThreadCommunicationExample {
    
    // Method 1: Handler.post()
    fun methodPost() {
        val mainHandler = Handler(Looper.getMainLooper())
        
        Thread {
            val result = processData()
            mainHandler.post {
                // Update UI with result
            }
        }.start()
    }
    
    // Method 2: Activity.runOnUiThread()
    fun methodRunOnUiThread(activity: Activity) {
        Thread {
            val result = processData()
            activity.runOnUiThread {
                // Update UI with result
            }
        }.start()
    }
    
    // Method 3: View.post()
    fun methodViewPost(view: View) {
        Thread {
            val result = processData()
            view.post {
                // Update UI with result
            }
        }.start()
    }
    
    private fun processData(): String = "Processed"
}
```

