## App Signing and Security


App signing is a critical security mechanism that ensures application authenticity and integrity. Every Android application must be digitally signed before installation, using public key cryptography to verify the developer's identity and detect tampering.

The signing process involves creating a digital signature using a private key, which is embedded in the APK file. The corresponding public key certificate is also included, allowing the Android system to verify the signature during installation and updates.

Android supports two signing schemes: JAR signing (v1) for backward compatibility and APK Signature Scheme v2 (and v3) for improved security and performance. Modern applications should use v2 signing as the primary method, with v1 signing for compatibility with older Android versions.

Key management is crucial for long-term application maintenance. The same signing key must be used for all updates to an application, as Android uses the signature to verify that updates come from the original developer. Loss of the signing key effectively prevents future updates to the application.

**Example:** Gradle configuration for app signing:

```kotlin
// build.gradle.kts (Module: app)
android {
    compileSdk = 34
    
    defaultConfig {
        applicationId = "com.example.secureapp"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }
    
    signingConfigs {
        create("release") {
            storeFile = file("../keystore/release.keystore")
            storePassword = System.getenv("STORE_PASSWORD") ?: 
                project.findProperty("storePassword") as String?
            keyAlias = System.getenv("KEY_ALIAS") ?: 
                project.findProperty("keyAlias") as String?
            keyPassword = System.getenv("KEY_PASSWORD") ?: 
                project.findProperty("keyPassword") as String?
            
            // Enable v2 and v3 signing
            enableV2Signing = true
            enableV3Signing = true
            enableV4Signing = true
        }
        
        create("debug") {
            storeFile = file("debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }
    
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
            
            // Additional security configurations
            isDebuggable = false
            isJniDebuggable = false
            renderscriptOptimLevel = 3
        }
        
        debug {
            isMinifyEnabled = false
            isDebuggable = true
            signingConfig = signingConfigs.getByName("debug")
            applicationIdSuffix = ".debug"
        }
    }
}

// gradle.properties (keep sensitive information here, not in version control)
// storePassword=YourStorePassword
// keyPassword=YourKeyPassword
// keyAlias=YourKeyAlias
```

**Key Management Best Practices:**

```kotlin
// KeystoreManager.kt - Secure key storage utility
class KeystoreManager(private val context: Context) {
    
    companion object {
        private const val KEYSTORE_ALIAS = "SecureAppKey"
        private const val ANDROID_KEYSTORE = "AndroidKeystore"
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val IV_LENGTH = 12
    }
    
    private val keystore: KeyStore by lazy {
        KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
    }
    
    @RequiresApi(Build.VERSION_CODES.M)
    fun generateSecretKey() {
        val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE)
        val keyGenParameterSpec = KeyGenParameterSpec.Builder(
            KEYSTORE_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setUserAuthenticationRequired(false) // Set to true for biometric/PIN protection
            .setRandomizedEncryptionRequired(true)
            .build()
        
        keyGenerator.init(keyGenParameterSpec)
        keyGenerator.generateKey()
    }
    
    @RequiresApi(Build.VERSION_CODES.M)
    fun encryptData(data: String): EncryptedData? {
        return try {
            val secretKey = keystore.getKey(KEYSTORE_ALIAS, null) as SecretKey
            val cipher = Cipher.getInstance(TRANSFORMATION)
            cipher.init(Cipher.ENCRYPT_MODE, secretKey)
            
            val iv = cipher.iv
            val encryptedData = cipher.doFinal(data.toByteArray(Charsets.UTF_8))
            
            EncryptedData(encryptedData, iv)
        } catch (e: Exception) {
            Log.e("KeystoreManager", "Encryption failed", e)
            null
        }
    }
    
    @RequiresApi(Build.VERSION_CODES.M)
    fun decryptData(encryptedData: EncryptedData): String? {
        return try {
            val secretKey = keystore.getKey(KEYSTORE_ALIAS, null) as SecretKey
            val cipher = Cipher.getInstance(TRANSFORMATION)
            val spec = GCMParameterSpec(128, encryptedData.iv)
            cipher.init(Cipher.DECRYPT_MODE, secretKey, spec)
            
            val decryptedData = cipher.doFinal(encryptedData.data)
            String(decryptedData, Charsets.UTF_8)
        } catch (e: Exception) {
            Log.e("KeystoreManager", "Decryption failed", e)
            null
        }
    }
    
    fun keyExists(): Boolean {
        return keystore.containsAlias(KEYSTORE_ALIAS)
    }
}

data class EncryptedData(
    val data: ByteArray,
    val iv: ByteArray
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false
        
        other as EncryptedData
        
        if (!data.contentEquals(other.data)) return false
        if (!iv.contentEquals(other.iv)) return false
        
        return true
    }
    
    override fun hashCode(): Int {
        var result = data.contentHashCode()
        result = 31 * result + iv.contentHashCode()
        return result
    }
}
```

**Key Points:**

- All Android apps must be digitally signed before installation
- Use the same signing key for all updates to maintain app continuity
- Store signing keys securely and create backups in multiple locations
- Enable v2/v3 signing for improved security and performance
- Never include signing credentials in version control systems

