## Runtime Permissions Model


The runtime permissions model, introduced in Android 6.0 (API level 23), fundamentally changed how applications request and receive permissions. Unlike the legacy install-time model where users granted all permissions during installation, runtime permissions allow users to grant or deny specific permissions when the app actually needs them.

Permissions are categorized into three protection levels: normal permissions (automatically granted), signature permissions (granted only to apps signed with the same certificate), and dangerous permissions (require explicit user consent). Dangerous permissions include access to sensitive data like contacts, location, camera, microphone, and storage.

The runtime permission flow involves checking if a permission is already granted, requesting the permission if needed, and handling the user's response appropriately. Applications must gracefully handle permission denials and provide clear explanations of why permissions are necessary for specific functionality.

Permission groups allow the system to present related permissions together in the UI. When a user grants one permission in a group, other permissions in the same group may be automatically granted, though this behavior varies by Android version and should not be relied upon programmatically.

**Example:** Implementing runtime permissions in Kotlin:

```kotlin
class CameraPermissionActivity : AppCompatActivity() {
    
    companion object {
        private const val CAMERA_PERMISSION_REQUEST_CODE = 1001
        private const val LOCATION_PERMISSION_REQUEST_CODE = 1002
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        findViewById<Button>(R.id.btnCamera).setOnClickListener {
            requestCameraPermission()
        }
        
        findViewById<Button>(R.id.btnLocation).setOnClickListener {
            requestLocationPermission()
        }
    }
    
    private fun requestCameraPermission() {
        when {
            ContextCompat.checkSelfPermission(
                this, 
                Manifest.permission.CAMERA
            ) == PackageManager.PERMISSION_GRANTED -> {
                // Permission already granted, proceed with camera functionality
                openCamera()
            }
            
            shouldShowRequestPermissionRationale(Manifest.permission.CAMERA) -> {
                // Show explanation dialog before requesting permission
                showPermissionRationale(
                    "Camera Access Required",
                    "This app needs camera access to take photos. Please grant camera permission to continue.",
                    Manifest.permission.CAMERA,
                    CAMERA_PERMISSION_REQUEST_CODE
                )
            }
            
            else -> {
                // Request permission directly
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.CAMERA),
                    CAMERA_PERMISSION_REQUEST_CODE
                )
            }
        }
    }
    
    private fun requestLocationPermission() {
        val permissions = arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION
        )
        
        when {
            permissions.all { 
                ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED 
            } -> {
                // All location permissions granted
                startLocationServices()
            }
            
            permissions.any { shouldShowRequestPermissionRationale(it) } -> {
                showPermissionRationale(
                    "Location Access Required",
                    "This app needs location access to provide location-based services.",
                    permissions,
                    LOCATION_PERMISSION_REQUEST_CODE
                )
            }
            
            else -> {
                ActivityCompat.requestPermissions(this, permissions, LOCATION_PERMISSION_REQUEST_CODE)
            }
        }
    }
    
    private fun showPermissionRationale(
        title: String, 
        message: String, 
        permission: String, 
        requestCode: Int
    ) {
        AlertDialog.Builder(this)
            .setTitle(title)
            .setMessage(message)
            .setPositiveButton("Grant") { _, _ ->
                ActivityCompat.requestPermissions(this, arrayOf(permission), requestCode)
            }
            .setNegativeButton("Cancel") { dialog, _ ->
                dialog.dismiss()
                handlePermissionDenied(permission)
            }
            .show()
    }
    
    private fun showPermissionRationale(
        title: String, 
        message: String, 
        permissions: Array<String>, 
        requestCode: Int
    ) {
        AlertDialog.Builder(this)
            .setTitle(title)
            .setMessage(message)
            .setPositiveButton("Grant") { _, _ ->
                ActivityCompat.requestPermissions(this, permissions, requestCode)
            }
            .setNegativeButton("Cancel") { dialog, _ ->
                dialog.dismiss()
                handlePermissionDenied(permissions[0])
            }
            .show()
    }
    
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        when (requestCode) {
            CAMERA_PERMISSION_REQUEST_CODE -> {
                if (grantResults.isNotEmpty() && 
                    grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    openCamera()
                } else {
                    handlePermissionDenied(Manifest.permission.CAMERA)
                }
            }
            
            LOCATION_PERMISSION_REQUEST_CODE -> {
                val allGranted = grantResults.isNotEmpty() && 
                    grantResults.all { it == PackageManager.PERMISSION_GRANTED }
                
                if (allGranted) {
                    startLocationServices()
                } else {
                    handlePermissionDenied(Manifest.permission.ACCESS_FINE_LOCATION)
                }
            }
        }
    }
    
    private fun handlePermissionDenied(permission: String) {
        when (permission) {
            Manifest.permission.CAMERA -> {
                Toast.makeText(this, "Camera permission denied. Photo features unavailable.", 
                    Toast.LENGTH_LONG).show()
                // Disable camera-related UI elements
                findViewById<Button>(R.id.btnCamera).isEnabled = false
            }
            
            Manifest.permission.ACCESS_FINE_LOCATION -> {
                Toast.makeText(this, "Location permission denied. Location features unavailable.", 
                    Toast.LENGTH_LONG).show()
                // Provide alternative functionality or disable location features
                disableLocationFeatures()
            }
        }
        
        // Check if user selected "Don't ask again"
        if (!shouldShowRequestPermissionRationale(permission)) {
            showSettingsDialog(permission)
        }
    }
    
    private fun showSettingsDialog(permission: String) {
        AlertDialog.Builder(this)
            .setTitle("Permission Required")
            .setMessage("Please enable the required permission in app settings to use this feature.")
            .setPositiveButton("Settings") { _, _ ->
                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.fromParts("package", packageName, null)
                }
                startActivity(intent)
            }
            .setNegativeButton("Cancel") { dialog, _ -> dialog.dismiss() }
            .show()
    }
    
    private fun openCamera() {
        // Implement camera functionality
        Toast.makeText(this, "Camera opened successfully", Toast.LENGTH_SHORT).show()
    }
    
    private fun startLocationServices() {
        // Implement location services
        Toast.makeText(this, "Location services started", Toast.LENGTH_SHORT).show()
    }
    
    private fun disableLocationFeatures() {
        // Disable location-dependent features
        findViewById<Button>(R.id.btnLocation).isEnabled = false
    }
}

// Extension function for cleaner permission checking
fun Context.hasPermission(permission: String): Boolean {
    return ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
}

fun Context.hasPermissions(vararg permissions: String): Boolean {
    return permissions.all { hasPermission(it) }
}
```

**Key Points:**

- Runtime permissions require explicit user consent for dangerous permissions
- Always check permission status before accessing protected resources
- Provide clear explanations when requesting permissions
- Handle permission denials gracefully with alternative functionality
- Monitor permission changes that may occur in app settings

