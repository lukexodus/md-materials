## Handling Configuration Changes


Configuration changes such as screen rotation, language changes, or keyboard availability can cause the system to destroy and recreate activities.

### Default Behavior

By default, configuration changes cause the activity to be destroyed and recreated, going through the complete lifecycle.

### Preserving State

```kotlin
class ConfigurationAwareActivity : AppCompatActivity() {
    private var userInput: String = ""
    private var currentProgress: Int = 0
    
    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        // Save important data before destruction
        outState.putString("user_input", userInput)
        outState.putInt("progress", currentProgress)
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Restore saved state
        savedInstanceState?.let { bundle ->
            userInput = bundle.getString("user_input", "")
            currentProgress = bundle.getInt("progress", 0)
            restoreUIState()
        }
    }
    
    private fun restoreUIState() {
        findViewById<EditText>(R.id.editText).setText(userInput)
        findViewById<ProgressBar>(R.id.progressBar).progress = currentProgress
    }
}
```

### Handling Specific Configuration Changes

```xml
<activity
    android:name=".OrientationAwareActivity"
    android:configChanges="orientation|screenSize|keyboardHidden"
    android:exported="false" />
```

```kotlin
class OrientationAwareActivity : AppCompatActivity() {
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        
        when (newConfig.orientation) {
            Configuration.ORIENTATION_LANDSCAPE -> {
                // Handle landscape mode
                adjustLayoutForLandscape()
            }
            Configuration.ORIENTATION_PORTRAIT -> {
                // Handle portrait mode
                adjustLayoutForPortrait()
            }
        }
    }
    
    private fun adjustLayoutForLandscape() {
        // [Inference] Layout adjustments for landscape orientation
        // Modify UI elements for horizontal screen
    }
    
    private fun adjustLayoutForPortrait() {
        // [Inference] Layout adjustments for portrait orientation
        // Modify UI elements for vertical screen
    }
}
```

### ViewModel for Configuration Changes

```kotlin
class MainViewModel : ViewModel() {
    private val _userData = MutableLiveData<String>()
    val userData: LiveData<String> = _userData
    
    fun updateUserData(data: String) {
        _userData.value = data
    }
    
    override fun onCleared() {
        super.onCleared()
        // Clean up resources when ViewModel is destroyed
    }
}

class ViewModelActivity : AppCompatActivity() {
    private lateinit var viewModel: MainViewModel
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // ViewModel survives configuration changes
        viewModel = ViewModelProvider(this)[MainViewModel::class.java]
        
        viewModel.userData.observe(this) { data ->
            // Update UI with data that persists across configuration changes
            updateUI(data)
        }
    }
}
```

**Key points** for activity lifecycle management include understanding that lifecycle methods are called by the system in specific sequences, proper resource management prevents memory leaks and improves performance, and state preservation ensures a seamless user experience across configuration changes. Task and back stack management directly affects navigation patterns and user experience, while launch modes control how activities are instantiated and organized within tasks.

**Important subtopics** to explore further include Fragment lifecycle and its relationship to Activity lifecycle, Intent handling and data passing between activities, Activity result APIs for modern activity-to-activity communication, and Process lifecycle and how it relates to activity states.

---

