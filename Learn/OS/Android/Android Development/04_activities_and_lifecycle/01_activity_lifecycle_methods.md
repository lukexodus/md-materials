## Activity Lifecycle Methods


The Android system manages activities through a well-defined lifecycle consisting of several callback methods that developers can override to handle state changes appropriately.

### onCreate()

Called when the activity is first created. This is where you perform basic application startup logic that should happen only once for the entire life of the activity.

```kotlin
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Initialize UI components
        // Set up click listeners
        // Restore saved state if available
        savedInstanceState?.let {
            // Restore previous state
        }
    }
}
```

### onStart()

Called when the activity becomes visible to the user. The activity is preparing to come to the foreground and become interactive.

```kotlin
override fun onStart() {
    super.onStart()
    // Activity is becoming visible
    // Start animations, register broadcast receivers
}
```

### onResume()

Called when the activity starts interacting with the user. At this point, the activity is at the top of the activity stack and capturing all user input.

```kotlin
override fun onResume() {
    super.onResume()
    // Activity is in foreground and interactive
    // Resume camera preview, start location updates
    startLocationUpdates()
}
```

### onPause()

Called when the system is about to start resuming another activity. This is typically used to commit unsaved changes to persistent data and stop animations or other ongoing actions.

```kotlin
override fun onPause() {
    super.onPause()
    // Another activity is taking focus
    // Pause ongoing operations, save draft data
    pauseLocationUpdates()
}
```

### onStop()

Called when the activity is no longer visible to the user. This may happen because a new activity is being started, an existing one is being brought in front of this one, or this one is being destroyed.

```kotlin
override fun onStop() {
    super.onStop()
    // Activity is no longer visible
    // Stop heavy operations, unregister receivers
    unregisterReceiver(broadcastReceiver)
}
```

### onRestart()

Called after the activity has been stopped, prior to it being started again. Always followed by onStart().

```kotlin
override fun onRestart() {
    super.onRestart()
    // Activity is being restarted
    // Prepare for onStart()
}
```

### onDestroy()

Called before the activity is destroyed. This is the final call that the activity receives.

```kotlin
override fun onDestroy() {
    super.onDestroy()
    // Clean up resources
    // Cancel ongoing tasks, close databases
    networkCall?.cancel()
}
```

