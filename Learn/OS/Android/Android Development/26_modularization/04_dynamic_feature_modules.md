## Dynamic Feature Modules


Dynamic feature modules enable on-demand delivery of features through Google Play's Dynamic Delivery system, allowing users to download features when needed.

**Key Points:**

- Features are downloaded at runtime rather than included in the base APK
- Reduces initial app size and improves download conversion rates
- Requires careful consideration of dependencies and shared resources
- Not all features are suitable for dynamic delivery

**Configuration Requirements:**

```kotlin
// dynamic-feature/build.gradle.kts
plugins {
    id("com.android.dynamic-feature")
    id("org.jetbrains.kotlin.android")
}

android {
    compileSdk = 34
    
    defaultConfig {
        minSdk = 21
    }
}

dependencies {
    implementation(project(":app"))
    implementation(project(":core"))
}
```

**Installation Handling:**

```kotlin
class DynamicFeatureManager(private val context: Context) {
    
    private val splitInstallManager = SplitInstallManagerFactory.create(context)
    
    fun installFeature(moduleName: String, callback: (Boolean) -> Unit) {
        val request = SplitInstallRequest.newBuilder()
            .addModule(moduleName)
            .build()
            
        splitInstallManager.startInstall(request)
            .addOnSuccessListener { sessionId ->
                // Monitor installation progress
                callback(true)
            }
            .addOnFailureListener { exception ->
                // Handle installation failure
                callback(false)
            }
    }
    
    fun isFeatureInstalled(moduleName: String): Boolean {
        return splitInstallManager.installedModules.contains(moduleName)
    }
}
```

