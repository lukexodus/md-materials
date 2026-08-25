## Battery Optimization Impact


Battery optimization and background execution limits significantly affect Broadcast Receiver behavior, particularly in recent Android versions.

### Doze Mode and App Standby

**Doze Mode Effects:**

- Network access restricted during deep sleep
- Alarms and jobs deferred
- Broadcast delivery delayed except for high-priority messages
- [Inference] Receivers may experience significant delays in non-whitelisted applications

**App Standby Impact:**

- Unused apps enter standby mode
- Broadcast delivery reduced for standby apps
- User interaction required to exit standby

### Background Execution Limits

**API 26+ Restrictions:**

- Most implicit broadcasts cannot be registered in manifest
- Services started from background receivers face limitations
- [Inference] Legacy broadcast patterns may fail on modern Android versions

**Exempted Broadcasts:** Critical system broadcasts still deliverable to manifest receivers:

```xml
<!-- Still allowed in manifest -->
<receiver android:name=".BootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
    </intent-filter>
</receiver>
```

### Power Management Strategies

**Efficient Receiver Design:**

```kotlin
class EfficientReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        // Quick processing only
        when {
            isUrgent(intent) -> handleImmediately(context, intent)
            else -> {
                // Schedule work for later execution using WorkManager
                val workRequest = OneTimeWorkRequestBuilder<DeferredWorker>()
                    .setInputData(workDataOf("intent_data" to intent?.extras?.toString()))
                    .build()
                
                context?.let {
                    WorkManager.getInstance(it).enqueue(workRequest)
                }
            }
        }
    }
    
    private fun isUrgent(intent: Intent?): Boolean {
        return intent?.getBooleanExtra("urgent", false) == true
    }
    
    private fun handleImmediately(context: Context?, intent: Intent?) {
        // Handle urgent broadcasts immediately
    }
}

class DeferredWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override fun doWork(): Result {
        val intentData = inputData.getString("intent_data")
        // Process deferred work
        return Result.success()
    }
}
```

**Battery-Friendly Patterns with Coroutines:**

```kotlin
class CoroutineReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val pendingResult = goAsync()
        
        // Use coroutine for async processing
        CoroutineScope(Dispatchers.IO).launch {
            try {
                processInBackground(context, intent)
            } finally {
                pendingResult.finish()
            }
        }
    }
    
    private suspend fun processInBackground(context: Context?, intent: Intent?) {
        // Perform background processing
        withContext(Dispatchers.Main) {
            // Update UI if needed
        }
    }
}
```

### Whitelisting Considerations

**Battery Optimization Whitelist:**

- Apps can request battery optimization exemption
- User must manually approve through settings
- [Unverified] Approval rates vary significantly across device manufacturers and Android versions
- Should only be requested for critical functionality

**Implementation:**

```kotlin
fun requestBatteryOptimizationExemption(context: Context) {
    val intent = Intent().apply {
        action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
        data = Uri.parse("package:${context.packageName}")
    }
    
    if (intent.resolveActivity(context.packageManager) != null) {
        context.startActivity(intent)
    }
}

fun isBatteryOptimizationIgnored(context: Context): Boolean {
    val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        powerManager.isIgnoringBatteryOptimizations(context.packageName)
    } else {
        true // No battery optimization on older versions
    }
}
```

