## AsyncTask (Deprecated Understanding)


[Unverified] AsyncTask was deprecated in API level 30 (Android 11) but understanding its concepts helps grasp Android's threading evolution and migration patterns.

**Key Points:**

- Designed for short operations (few seconds maximum)
- Provided easy UI thread communication
- Suffered from memory leaks and lifecycle issues
- Replaced by modern alternatives like coroutines and executors

**AsyncTask Structure (for reference only):**

```kotlin
// DO NOT USE - This is for educational purposes only
@Suppress("DEPRECATION")
private class DownloadTask : AsyncTask<String, Int, String>() {
    
    override fun onPreExecute() {
        // Runs on UI thread before background work
        // Show progress indicator
    }
    
    override fun doInBackground(vararg urls: String): String {
        // Runs on background thread
        // Cannot update UI directly
        var totalSize = 0
        
        urls.forEachIndexed { index, url ->
            val data = downloadFile(url)
            totalSize += data.length
            
            // Report progress
            publishProgress((index + 1) * 100 / urls.size)
        }
        
        return "Downloaded $totalSize bytes"
    }
    
    override fun onProgressUpdate(vararg progress: Int) {
        // Runs on UI thread
        // Update progress bar
    }
    
    override fun onPostExecute(result: String) {
        // Runs on UI thread after background work
        // Update UI with final result
    }
    
    override fun onCancelled() {
        // Handle cancellation
    }
    
    private fun downloadFile(url: String): ByteArray {
        // Simulate download
        Thread.sleep(1000)
        return ByteArray(1024)
    }
}

// Problems with AsyncTask:
class ProblematicAsyncTask(
    private val activity: Activity // Strong reference causes memory leak
) : AsyncTask<Void, Void, String>() {
    
    override fun doInBackground(vararg params: Void?): String {
        // If activity is destroyed while this runs,
        // onPostExecute still tries to update destroyed UI
        return "Result"
    }
    
    override fun onPostExecute(result: String) {
        // This can cause crashes if activity is destroyed
        if (!activity.isDestroyed) {
            // Update UI
        }
    }
}
```

