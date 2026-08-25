## Activity Launch Modes


Launch modes define how activities are instantiated and how they behave in relation to tasks and the back stack.

### Standard Mode (Default)

Creates a new instance of the activity every time it's started.

```xml
<activity
    android:name=".StandardActivity"
    android:launchMode="standard" />
```

### SingleTop Mode

If an instance of the activity already exists at the top of the current task, the system routes the intent to that instance through onNewIntent() rather than creating a new instance.

```xml
<activity
    android:name=".SingleTopActivity"
    android:launchMode="singleTop" />
```

```kotlin
class SingleTopActivity : AppCompatActivity() {
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        setIntent(intent) // Update the intent
        // Handle the new intent without recreating activity
        handleNewData(intent?.getStringExtra("data"))
    }
}
```

### SingleTask Mode

Creates the activity in a new task or brings the existing task to the foreground if an instance already exists.

```xml
<activity
    android:name=".SingleTaskActivity"
    android:launchMode="singleTask" />
```

### SingleInstance Mode

Similar to singleTask, but the activity is the only activity in its task. No other activities can be launched into this task.

```xml
<activity
    android:name=".SingleInstanceActivity"
    android:launchMode="singleInstance" />
```

### Programmatic Launch Mode Control

```kotlin
class LaunchModeController : AppCompatActivity() {
    
    private fun launchWithFlags() {
        val intent = Intent(this, TargetActivity::class.java)
        
        // Equivalent to singleTop
        intent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
        
        // Equivalent to singleTask
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        
        // Clear everything and start fresh
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        
        startActivity(intent)
    }
}
```

