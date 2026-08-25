## Local Broadcast Manager


LocalBroadcastManager provides an efficient way to send broadcasts within a single application process, offering improved security and performance over system-wide broadcasts.

**Advantages:**

- **Security**: Broadcasts never leave the application boundary
- **Performance**: No inter-process communication overhead
- **Privacy**: Sensitive data remains within application scope
- **Efficiency**: Faster delivery compared to system broadcasts

**Implementation:**

```kotlin
class MainActivity : AppCompatActivity() {
    private val localReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val data = intent?.getStringExtra("key")
            // Process local broadcast
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Registering local receiver
        LocalBroadcastManager.getInstance(this).registerReceiver(
            localReceiver, 
            IntentFilter("local.action.CUSTOM")
        )
    }
    
    private fun sendLocalBroadcast() {
        val localIntent = Intent("local.action.CUSTOM").apply {
            putExtra("key", "value")
        }
        LocalBroadcastManager.getInstance(this).sendBroadcast(localIntent)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // Unregistering
        LocalBroadcastManager.getInstance(this).unregisterReceiver(localReceiver)
    }
}
```

**Use Cases:**

- Inter-component communication within single app
- UI updates based on background service events
- Data synchronization notifications
- Internal state change propagation

**Limitations:**

- Cannot receive system broadcasts through LocalBroadcastManager
- Only works within single application process
- Does not support ordered broadcasts

