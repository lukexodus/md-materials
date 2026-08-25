## Permission Best Practices


Effective permission management requires a strategic approach that balances functionality with user privacy and trust. The principle of least privilege suggests requesting only the permissions actually needed for core functionality, avoiding unnecessary or overly broad permission requests that may concern users.

Permission timing is crucial for user acceptance rates. Request permissions just-in-time when users are about to use features that require them, rather than requesting all permissions upfront. This contextual approach helps users understand why each permission is necessary.

Progressive permission requests involve starting with minimal permissions and requesting additional ones as users engage with more advanced features. This gradual approach builds trust and allows users to experience app value before granting sensitive permissions.

Fallback strategies ensure app functionality continues even when permissions are denied. Design alternative workflows that provide value without requiring sensitive permissions, such as allowing manual location entry when location services are unavailable.

Permission education through clear, user-friendly explanations helps users make informed decisions. Avoid technical jargon and focus on benefits to the user rather than technical requirements of the app.

**Example:** Permission management utility class:

```kotlin
class PermissionManager(private val activity: Activity) {
    
    companion object {
        private const val PERMISSION_REQUEST_CODE = 1000
    }
    
    private var pendingPermissionCallback: ((Boolean) -> Unit)? = null
    
    fun requestPermission(
        permission: String,
        rationale: PermissionRationale,
        callback: (Boolean) -> Unit
    ) {
        pendingPermissionCallback = callback
        
        when {
            activity.hasPermission(permission) -> {
                callback(true)
                pendingPermissionCallback = null
            }
            
            ActivityCompat.shouldShowRequestPermissionRationale(activity, permission) -> {
                showRationaleDialog(permission, rationale)
            }
            
            else -> {
                ActivityCompat.requestPermissions(
                    activity, 
                    arrayOf(permission), 
                    PERMISSION_REQUEST_CODE
                )
            }
        }
    }
    
    fun requestMultiplePermissions(
        permissions: Array<String>,
        rationale: PermissionRationale,
        callback: (Map<String, Boolean>) -> Unit
    ) {
        val deniedPermissions = permissions.filter { !activity.hasPermission(it) }
        
        if (deniedPermissions.isEmpty()) {
            callback(permissions.associateWith { true })
            return
        }
        
        val shouldShowRationale = deniedPermissions.any { 
            ActivityCompat.shouldShowRequestPermissionRationale(activity, it) 
        }
        
        if (shouldShowRationale) {
            showMultiplePermissionsRationale(deniedPermissions.toTypedArray(), rationale) {
                ActivityCompat.requestPermissions(
                    activity, 
                    deniedPermissions.toTypedArray(), 
                    PERMISSION_REQUEST_CODE
                )
            }
        } else {
            ActivityCompat.requestPermissions(
                activity, 
                deniedPermissions.toTypedArray(), 
                PERMISSION_REQUEST_CODE
            )
        }
    }
    
    fun handlePermissionResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() && 
                grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            
            pendingPermissionCallback?.invoke(granted)
            pendingPermissionCallback = null
            
            if (!granted) {
                handlePermissionDenial(permissions)
            }
        }
    }
    
    private fun showRationaleDialog(permission: String, rationale: PermissionRationale) {
        AlertDialog.Builder(activity)
            .setTitle(rationale.title)
            .setMessage(rationale.message)
            .setPositiveButton("Allow") { _, _ ->
                ActivityCompat.requestPermissions(
                    activity, 
                    arrayOf(permission), 
                    PERMISSION_REQUEST_CODE
                )
            }
            .setNegativeButton("Deny") { dialog, _ ->
                dialog.dismiss()
                pendingPermissionCallback?.invoke(false)
                pendingPermissionCallback = null
            }
            .setCancelable(false)
            .show()
    }
    
    private fun showMultiplePermissionsRationale(
        permissions: Array<String>,
        rationale: PermissionRationale,
        onPositive: () -> Unit
    ) {
        AlertDialog.Builder(activity)
            .setTitle(rationale.title)
            .setMessage(rationale.message)
            .setPositiveButton("Allow") { _, _ -> onPositive() }
            .setNegativeButton("Deny") { dialog, _ ->
                dialog.dismiss()
                pendingPermissionCallback?.invoke(false)
                pendingPermissionCallback = null
            }
            .setCancelable(false)
            .show()
    }
    
    private fun handlePermissionDenial(permissions: Array<out String>) {
        val permanentlyDeniedPermissions = permissions.filter { permission ->
            !ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)
        }
        
        if (permanentlyDeniedPermissions.isNotEmpty()) {
            showSettingsRedirectDialog()
        }
    }
    
    private fun showSettingsRedirectDialog() {
        AlertDialog.Builder(activity)
            .setTitle("Permissions Required")
            .setMessage("Some features may not work properly without the required permissions. " +
                       "You can enable them in the app settings.")
            .setPositiveButton("Settings") { _, _ ->
                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.fromParts("package", activity.packageName, null)
                }
                activity.startActivity(intent)
            }
            .setNegativeButton("Cancel") { dialog, _ -> dialog.dismiss() }
            .show()
    }
}

data class PermissionRationale(
    val title: String,
    val message: String
)

// Usage example
class MainActivity : AppCompatActivity() {
    
    private lateinit var permissionManager: PermissionManager
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        permissionManager = PermissionManager(this)
        
        findViewById<Button>(R.id.btnCamera).setOnClickListener {
            requestCameraPermission()
        }
    }
    
    private fun requestCameraPermission() {
        val rationale = PermissionRationale(
            title = "Camera Permission",
            message = "This app needs camera access to take photos for your profile. " +
                     "Your photos will only be stored locally on your device."
        )
        
        permissionManager.requestPermission(
            Manifest.permission.CAMERA,
            rationale
        ) { granted ->
            if (granted) {
                openCamera()
            } else {
                showCameraUnavailableMessage()
            }
        }
    }
    
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        permissionManager.handlePermissionResult(requestCode, permissions, grantResults)
    }
    
    private fun openCamera() {
        // Implement camera functionality
    }
    
    private fun showCameraUnavailableMessage() {
        Toast.makeText(this, "Camera features are not available without permission", 
            Toast.LENGTH_LONG).show()
    }
}
```

