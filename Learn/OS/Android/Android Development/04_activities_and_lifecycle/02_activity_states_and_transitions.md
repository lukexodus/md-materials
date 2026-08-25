## Activity States and Transitions


Activities exist in different states throughout their lifecycle, with specific transitions between these states.

### Active/Running State

The activity is in the foreground and has user focus. The activity is at the top of the activity stack and is fully interactive.

### Paused State

Another activity has focus, but the paused activity is still visible (partially obscured). The activity is alive but may be killed by the system in extreme low memory situations.

### Stopped State

The activity is completely obscured by another activity. The activity is still alive and maintains all state information, but can be killed by the system when memory is needed elsewhere.

### Destroyed State

The activity has been terminated either by the system calling finish() or by the system destroying the process.

### State Transition Flow

```kotlin
class LifecycleAwareActivity : AppCompatActivity() {
    private val TAG = "ActivityLifecycle"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "onCreate called")
        // Created → Started (next: onStart)
    }
    
    override fun onStart() {
        super.onStart()
        Log.d(TAG, "onStart called")
        // Started → Resumed (next: onResume)
    }
    
    override fun onResume() {
        super.onResume()
        Log.d(TAG, "onResume called")
        // Now in Active state
    }
    
    override fun onPause() {
        super.onPause()
        Log.d(TAG, "onPause called")
        // Active → Paused (next: onResume or onStop)
    }
    
    override fun onStop() {
        super.onStop()
        Log.d(TAG, "onStop called")
        // Paused → Stopped (next: onRestart or onDestroy)
    }
    
    override fun onRestart() {
        super.onRestart()
        Log.d(TAG, "onRestart called")
        // Stopped → Started (next: onStart)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "onDestroy called")
        // Activity destroyed
    }
}
```

