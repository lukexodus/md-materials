## Broadcast Receiver Registration


Broadcast Receivers can be registered through two primary mechanisms: manifest registration (static) and runtime registration (dynamic).

### Manifest Registration (Static)

Static registration declares receivers in AndroidManifest.xml, allowing them to receive broadcasts even when the application is not running.

```xml
<receiver android:name=".MyBroadcastReceiver"
          android:enabled="true"
          android:exported="true">
    <intent-filter android:priority="100">
        <action android:name="android.intent.action.BOOT_COMPLETED" />
        <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>
</receiver>
```

**Kotlin Receiver Implementation:**

```kotlin
class MyBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        when (intent?.action) {
            Intent.ACTION_BOOT_COMPLETED -> {
                // Handle boot completion
                context?.let { ctx ->
                    val notification = createBootNotification(ctx)
                    showNotification(ctx, notification)
                }
            }
            "com.example.CUSTOM_ACTION" -> {
                val data = intent.getStringExtra("data")
                processCustomAction(context, data)
            }
        }
    }
    
    private fun createBootNotification(context: Context): Notification {
        // Notification creation logic
        return NotificationCompat.Builder(context, "boot_channel")
            .setContentTitle("App Started")
            .setContentText("Application initialized on boot")
            .setSmallIcon(R.drawable.ic_notification)
            .build()
    }
}
```

**Manifest Attributes:**

- `android:enabled`: Controls receiver availability
- `android:exported`: Determines if other apps can trigger the receiver
- `android:permission`: Requires specific permission to send broadcasts
- `android:priority`: Sets delivery priority for ordered broadcasts (-1000 to 1000)

**Android 8.0+ Restrictions:** Starting with API level 26, most implicit broadcasts cannot be registered in the manifest due to background execution limits. Exceptions include:

- `ACTION_BOOT_COMPLETED`
- `ACTION_LOCALE_CHANGED`
- `ACTION_MY_PACKAGE_REPLACED`
- Several other critical system events

### Runtime Registration (Dynamic)

Dynamic registration occurs during application execution, typically in Activities, Services, or other components.

```kotlin
class NetworkMonitorActivity : AppCompatActivity() {
    private val connectivityReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == ConnectivityManager.CONNECTIVITY_ACTION) {
                val connectivityManager = context?.getSystemService(Context.CONNECTIVITY_SERVICE) 
                    as ConnectivityManager
                val networkInfo = connectivityManager.activeNetworkInfo
                
                val isConnected = networkInfo?.isConnected == true
                updateUI(isConnected)
            }
        }
    }
    
    override fun onResume() {
        super.onResume()
        val filter = IntentFilter().apply {
            addAction(ConnectivityManager.CONNECTIVITY_ACTION)
            addCategory(Intent.CATEGORY_DEFAULT)
        }
        registerReceiver(connectivityReceiver, filter)
    }
    
    override fun onPause() {
        super.onPause()
        unregisterReceiver(connectivityReceiver)
    }
    
    private fun updateUI(isConnected: Boolean) {
        // Update UI based on connectivity state
    }
}
```

**Dynamic Registration with Extension Functions:**

```kotlin
// Extension function for cleaner registration
fun Context.registerReceiverSafely(
    receiver: BroadcastReceiver,
    filter: IntentFilter,
    permission: String? = null
): Boolean {
    return try {
        registerReceiver(receiver, filter, permission, null)
        true
    } catch (e: SecurityException) {
        false
    }
}

fun Context.unregisterReceiverSafely(receiver: BroadcastReceiver): Boolean {
    return try {
        unregisterReceiver(receiver)
        true
    } catch (e: IllegalArgumentException) {
        false
    }
}
```

**Dynamic Registration Benefits:**

- No background execution limitations
- Component lifecycle awareness
- Conditional registration based on app state
- Better memory management control

**Registration Contexts:**

- **Activity Context**: Receiver tied to activity lifecycle
- **Application Context**: Receiver persists across activity changes
- **Service Context**: Receiver bound to service lifecycle

### Intent Filters

Intent filters define which broadcasts a receiver can handle through action, category, and data specifications.

```xml
<intent-filter android:priority="500">
    <action android:name="android.intent.action.ACTION_POWER_CONNECTED" />
    <action android:name="com.example.CUSTOM_ACTION" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:scheme="http" android:host="example.com" />
</intent-filter>
```

**Kotlin Intent Filter Creation:**

```kotlin
val intentFilter = IntentFilter().apply {
    addAction(Intent.ACTION_POWER_CONNECTED)
    addAction(Intent.ACTION_POWER_DISCONNECTED)
    addCategory(Intent.CATEGORY_DEFAULT)
    priority = 100
}

// Multiple action handling
class PowerReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        when (intent?.action) {
            Intent.ACTION_POWER_CONNECTED -> handlePowerConnected(context)
            Intent.ACTION_POWER_DISCONNECTED -> handlePowerDisconnected(context)
        }
    }
    
    private fun handlePowerConnected(context: Context?) {
        // Handle charging state
    }
    
    private fun handlePowerDisconnected(context: Context?) {
        // Handle unplugged state
    }
}
```

**Filter Components:**

- **Actions**: Specific broadcast identifiers
- **Categories**: Additional classification
- **Data**: MIME types, schemes, hosts, paths
- **Priority**: Delivery order for ordered broadcasts

