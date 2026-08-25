## Explicit and Implicit Intents


Intents are messaging objects that facilitate communication between Android components, categorized as either explicit or implicit based on how they specify their target.

### Explicit Intents

Explicit intents specify the exact component to start by providing the target component's class name. They are primarily used for navigation within the same application.

```kotlin
class ExplicitIntentActivity : AppCompatActivity() {
    
    private fun navigateToDetailActivity() {
        val intent = Intent(this, DetailActivity::class.java)
        intent.putExtra("item_id", 123)
        intent.putExtra("item_title", "Sample Title")
        startActivity(intent)
    }
    
    private fun startServiceExplicitly() {
        val serviceIntent = Intent(this, BackgroundService::class.java)
        serviceIntent.putExtra("task_type", "data_sync")
        startService(serviceIntent)
    }
    
    private fun sendBroadcastExplicitly() {
        val broadcastIntent = Intent(this, CustomBroadcastReceiver::class.java)
        broadcastIntent.action = "com.example.CUSTOM_ACTION"
        sendBroadcast(broadcastIntent)
    }
}
```

### Implicit Intents

Implicit intents do not specify a particular component but declare a general action to perform. The system determines which components can handle the intent based on intent filters.

```kotlin
class ImplicitIntentActivity : AppCompatActivity() {
    
    private fun shareContent() {
        val shareIntent = Intent().apply {
            action = Intent.ACTION_SEND
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, "Check out this amazing content!")
            putExtra(Intent.EXTRA_SUBJECT, "Shared from MyApp")
        }
        
        val chooser = Intent.createChooser(shareIntent, "Share via")
        if (shareIntent.resolveActivity(packageManager) != null) {
            startActivity(chooser)
        }
    }
    
    private fun openWebPage(url: String) {
        val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        if (webIntent.resolveActivity(packageManager) != null) {
            startActivity(webIntent)
        } else {
            // Handle case where no browser is available
            showToast("No browser app found")
        }
    }
    
    private fun makePhoneCall(phoneNumber: String) {
        val callIntent = Intent(Intent.ACTION_DIAL).apply {
            data = Uri.parse("tel:$phoneNumber")
        }
        startActivity(callIntent)
    }
    
    private fun sendEmail() {
        val emailIntent = Intent(Intent.ACTION_SENDTO).apply {
            data = Uri.parse("mailto:")
            putExtra(Intent.EXTRA_EMAIL, arrayOf("recipient@example.com"))
            putExtra(Intent.EXTRA_SUBJECT, "Subject line")
            putExtra(Intent.EXTRA_TEXT, "Email body content")
        }
        
        if (emailIntent.resolveActivity(packageManager) != null) {
            startActivity(emailIntent)
        }
    }
    
    private fun captureImage() {
        val cameraIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        if (cameraIntent.resolveActivity(packageManager) != null) {
            startActivityForResult(cameraIntent, REQUEST_IMAGE_CAPTURE)
        }
    }
    
    companion object {
        private const val REQUEST_IMAGE_CAPTURE = 1001
    }
}
```

### Intent Resolution Process

The system uses intent filters to determine which components can handle implicit intents through a matching process.

```kotlin
class IntentResolutionHelper {
    
    fun checkIntentAvailability(context: Context, intent: Intent): Boolean {
        val packageManager = context.packageManager
        val activities = packageManager.queryIntentActivities(intent, 0)
        return activities.isNotEmpty()
    }
    
    fun getAvailableActivities(context: Context, intent: Intent): List<ResolveInfo> {
        val packageManager = context.packageManager
        return packageManager.queryIntentActivities(intent, 0)
    }
    
    fun createCustomChooser(context: Context, baseIntent: Intent, title: String): Intent {
        val activities = getAvailableActivities(context, baseIntent)
        
        if (activities.isEmpty()) {
            return baseIntent
        }
        
        val targetIntents = mutableListOf<Intent>()
        for (resolveInfo in activities) {
            val targetIntent = Intent(baseIntent).apply {
                setPackage(resolveInfo.activityInfo.packageName)
            }
            targetIntents.add(targetIntent)
        }
        
        val chooserIntent = Intent.createChooser(targetIntents.removeAt(0), title)
        chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, targetIntents.toTypedArray())
        return chooserIntent
    }
}
```

