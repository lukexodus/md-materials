## Intent Filters and Data Sharing


Intent filters declare the capabilities of components and specify which implicit intents they can handle.

### Declaring Intent Filters

```xml
<activity
    android:name=".ShareReceiveActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.SEND" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="text/plain" />
    </intent-filter>
    <intent-filter>
        <action android:name="android.intent.action.SEND_MULTIPLE" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="image/*" />
    </intent-filter>
</activity>

<activity
    android:name=".WebViewActivity"
    android:exported="true">
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https"
              android:host="www.example.com" />
    </intent-filter>
</activity>
```

### Handling Received Intents

```kotlin
class ShareReceiveActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_share_receive)
        
        handleIncomingIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        intent?.let { handleIncomingIntent(it) }
    }
    
    private fun handleIncomingIntent(intent: Intent) {
        when (intent.action) {
            Intent.ACTION_SEND -> {
                if (intent.type?.startsWith("text/") == true) {
                    handleTextShare(intent)
                } else if (intent.type?.startsWith("image/") == true) {
                    handleImageShare(intent)
                }
            }
            Intent.ACTION_SEND_MULTIPLE -> {
                handleMultipleShare(intent)
            }
            Intent.ACTION_VIEW -> {
                handleDeepLink(intent)
            }
        }
    }
    
    private fun handleTextShare(intent: Intent) {
        val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
        val sharedSubject = intent.getStringExtra(Intent.EXTRA_SUBJECT)
        
        sharedText?.let { text ->
            displaySharedContent(text, sharedSubject)
        }
    }
    
    private fun handleImageShare(intent: Intent) {
        val imageUri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
        imageUri?.let { uri ->
            displaySharedImage(uri)
        }
    }
    
    private fun handleMultipleShare(intent: Intent) {
        val imageUris = intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
        imageUris?.let { uris ->
            displayMultipleImages(uris)
        }
    }
    
    private fun handleDeepLink(intent: Intent) {
        val data = intent.data
        data?.let { uri ->
            processDeepLink(uri)
        }
    }
}
```

### Data Sharing Between Activities

```kotlin
class DataSharingActivity : AppCompatActivity() {
    
    // Sending data with Intent extras
    private fun sendDataToActivity() {
        val intent = Intent(this, ReceivingActivity::class.java).apply {
            // Primitive data types
            putExtra("string_key", "Sample text")
            putExtra("int_key", 42)
            putExtra("boolean_key", true)
            
            // Arrays
            putExtra("string_array", arrayOf("item1", "item2", "item3"))
            putExtra("int_array", intArrayOf(1, 2, 3))
            
            // Parcelable objects
            putExtra("user_object", createUserObject())
            
            // Serializable objects (less efficient)
            putExtra("data_object", createDataObject())
        }
        startActivity(intent)
    }
    
    // Using Bundle for complex data
    private fun sendComplexData() {
        val bundle = Bundle().apply {
            putString("title", "Complex Data")
            putParcelableArrayList("items", createItemList())
        }
        
        val intent = Intent(this, ComplexDataActivity::class.java)
        intent.putExtras(bundle)
        startActivity(intent)
    }
    
    // Sending data via URI
    private fun shareDataViaUri() {
        val fileUri = createContentUri()
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(fileUri, "image/jpeg")
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
        }
        startActivity(intent)
    }
}

class ReceivingActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_receiving)
        
        extractIntentData()
    }
    
    private fun extractIntentData() {
        val stringValue = intent.getStringExtra("string_key") ?: ""
        val intValue = intent.getIntExtra("int_key", 0)
        val booleanValue = intent.getBooleanExtra("boolean_key", false)
        val stringArray = intent.getStringArrayExtra("string_array")
        val userObject = intent.getParcelableExtra<User>("user_object")
        
        // Process received data
        displayReceivedData(stringValue, intValue, booleanValue, stringArray, userObject)
    }
}
```

