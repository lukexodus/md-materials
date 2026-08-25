## Biometric Authentication


Biometric authentication provides secure user verification using fingerprint, face recognition, or other biometric sensors.

### BiometricPrompt Implementation

**Biometric Manager Setup:**

```kotlin
class BiometricAuthenticationManager(private val activity: FragmentActivity) {
    private lateinit var biometricPrompt: BiometricPrompt
    private lateinit var promptInfo: BiometricPrompt.PromptInfo
    
    init {
        setupBiometricPrompt()
    }
    
    private fun setupBiometricPrompt() {
        val executor = ContextCompat.getMainExecutor(activity)
        
        biometricPrompt = BiometricPrompt(activity, executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    onBiometricError(errorCode, errString.toString())
                }
                
                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(result)
                    onBiometricSuccess(result)
                }
                
                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    onBiometricFailed()
                }
            })
        
        promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Biometric Authentication")
            .setSubtitle("Use your fingerprint or face to authenticate")
            .setDescription("Place your finger on the sensor or look at the camera")
            .setNegativeButtonText("Cancel")
            .setConfirmationRequired(true)
            .build()
    }
    
    fun checkBiometricSupport(): BiometricSupportStatus {
        return when (BiometricManager.from(activity).canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)) {
            BiometricManager.BIOMETRIC_SUCCESS -> BiometricSupportStatus.AVAILABLE
            BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE -> BiometricSupportStatus.NO_HARDWARE
            BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE -> BiometricSupportStatus.HARDWARE_UNAVAILABLE
            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> BiometricSupportStatus.NONE_ENROLLED
            BiometricManager.BIOMETRIC_ERROR_SECURITY_UPDATE_REQUIRED -> BiometricSupportStatus.SECURITY_UPDATE_REQUIRED
            BiometricManager.BIOMETRIC_ERROR_UNSUPPORTED -> BiometricSupportStatus.UNSUPPORTED
            BiometricManager.BIOMETRIC_STATUS_UNKNOWN -> BiometricSupportStatus.UNKNOWN
            else -> BiometricSupportStatus.UNKNOWN
        }
    }
    
    fun authenticateWithBiometric() {
        val supportStatus = checkBiometricSupport()
        
        when (supportStatus) {
            BiometricSupportStatus.AVAILABLE -> {
                biometricPrompt.authenticate(promptInfo)
            }
            BiometricSupportStatus.NONE_ENROLLED -> {
                showEnrollmentDialog()
            }
            BiometricSupportStatus.NO_HARDWARE -> {
                onBiometricError(-1, "No biometric hardware available")
            }
            else -> {
                onBiometricError(-1, "Biometric authentication unavailable: $supportStatus")
            }
        }
    }
    
    fun authenticateWithCrypto(cryptoObject: BiometricPrompt.CryptoObject) {
        if (checkBiometricSupport() == BiometricSupportStatus.AVAILABLE) {
            biometricPrompt.authenticate(promptInfo, cryptoObject)
        }
    }
    
    private fun showEnrollmentDialog() {
        AlertDialog.Builder(activity)
            .setTitle("Biometric Enrollment Required")
            .setMessage("No biometric credentials are enrolled. Would you like to add them now?")
            .setPositiveButton("Settings") { _, _ ->
                val enrollIntent = Intent(Settings.ACTION_BIOMETRIC_ENROLL).apply {
                    putExtra(Settings.EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED,
                        BiometricManager.Authenticators.BIOMETRIC_STRONG)
                }
                activity.startActivity(enrollIntent)
            }
            .setNegativeButton("Cancel", null)
            .show()
    }
    
    private fun onBiometricSuccess(result: BiometricPrompt.AuthenticationResult) {
        val authenticatedUser = result.authenticationType
        val cryptoObject = result.cryptoObject
        
        // Handle successful authentication
        when (authenticatedUser) {
            BiometricPrompt.AUTHENTICATION_RESULT_TYPE_BIOMETRIC -> {
                // Biometric authentication successful
                handleBiometricAuthentication(cryptoObject)
            }
            BiometricPrompt.AUTHENTICATION_RESULT_TYPE_DEVICE_CREDENTIAL -> {
                // Device credential authentication successful
                handleDeviceCredentialAuthentication()
            }
        }
    }
    
    private fun onBiometricError(errorCode: Int, errorMessage: String) {
        when (errorCode) {
            BiometricPrompt.ERROR_USER_CANCELED -> {
                // User cancelled authentication
            }
            BiometricPrompt.ERROR_NEGATIVE_BUTTON -> {
                // User pressed negative button
            }
            BiometricPrompt.ERROR_HW_UNAVAILABLE -> {
                // Hardware unavailable
            }
            BiometricPrompt.ERROR_UNABLE_TO_PROCESS -> {
                // Unable to process
            }
            BiometricPrompt.ERROR_TIMEOUT -> {
                // Authentication timeout
            }
            else -> {
                // Other errors
            }
        }
    }
    
    private fun onBiometricFailed() {
        // Authentication failed but user can retry
    }
    
    private fun handleBiometricAuthentication(cryptoObject: BiometricPrompt.CryptoObject?) {
        // Process successful biometric authentication
        cryptoObject?.let { crypto ->
            // Use crypto object for secure operations
            when (crypto.cipher) {
                null -> {
                    // No cipher available
                }
                else -> {
                    // Use cipher for encryption/decryption
                    performSecureCryptoOperation(crypto.cipher)
                }
            }
        }
    }
    
    private fun handleDeviceCredentialAuthentication() {
        // Handle device credential authentication
    }
    
    private fun performSecureCryptoOperation(cipher: Cipher?) {
        // [Inference] Specific cryptographic operations would depend on application requirements
        cipher?.let { 
            // Perform encryption/decryption operations
        }
    }
}

enum class BiometricSupportStatus {
    AVAILABLE,
    NO_HARDWARE,
    HARDWARE_UNAVAILABLE,
    NONE_ENROLLED,
    SECURITY_UPDATE_REQUIRED,
    UNSUPPORTED,
    UNKNOWN
}
```

### Advanced Biometric Authentication with Cryptography

**Secure Biometric Authentication:**

```kotlin
class SecureBiometricManager(private val activity: FragmentActivity) {
    private lateinit var keyGenerator: KeyGenerator
    private lateinit var keyStore: KeyStore
    private lateinit var cipher: Cipher
    
    companion object {
        private const val KEY_NAME = "SecureBiometricKey"
        private const val TRANSFORMATION = "AES/CBC/PKCS7Padding"
        private const val ANDROID_KEYSTORE = "AndroidKeyStore"
    }
    
    init {
        setupCryptography()
    }
    
    private fun setupCryptography() {
        try {
            keyStore = KeyStore.getInstance(ANDROID_KEYSTORE)
            keyStore.load(null)
            
            keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE)
            cipher = Cipher.getInstance(TRANSFORMATION)
            
            generateSecretKey()
        } catch (e: Exception) {
            // Handle cryptography setup errors
        }
    }
    
    @RequiresApi(Build.VERSION_CODES.M)
    private fun generateSecretKey() {
        val keyGenParameterSpec = KeyGenParameterSpec.Builder(
            KEY_NAME,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_CBC)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_PKCS7)
            .setUserAuthenticationRequired(true)
            .setInvalidatedByBiometricEnrollment(true)
            .build()
        
        keyGenerator.init(keyGenParameterSpec)
        keyGenerator.generateKey()
    }
    
    private fun initCipher(mode: Int): Boolean {
        return try {
            keyStore.load(null)
            val secretKey = keyStore.getKey(KEY_NAME, null) as SecretKey
            cipher.init(mode, secretKey)
            true
        } catch (e: Exception) {
            false
        }
    }
    
    fun authenticateForEncryption(data: String, callback: (String?) -> Unit) {
        if (initCipher(Cipher.ENCRYPT_MODE)) {
            val biometricPrompt = createBiometricPrompt { result ->
                result.cryptoObject?.cipher?.let { cipher ->
                    val encryptedData = encryptData(data, cipher)
                    callback(encryptedData)
                } ?: callback(null)
            }
            
            val promptInfo = createPromptInfo("Encrypt Data", "Authenticate to encrypt sensitive data")
            val cryptoObject = BiometricPrompt.CryptoObject(cipher)
            biometricPrompt.authenticate(promptInfo, cryptoObject)
        } else {
            callback(null)
        }
    }
    
    fun authenticateForDecryption(encryptedData: String, iv: ByteArray, callback: (String?) -> Unit) {
        if (initCipherForDecryption(iv)) {
            val biometricPrompt = createBiometricPrompt { result ->
                result.cryptoObject?.cipher?.let { cipher ->
                    val decryptedData = decryptData(encryptedData, cipher)
                    callback(decryptedData)
                } ?: callback(null)
            }
            
            val promptInfo = createPromptInfo("Decrypt Data", "Authenticate to decrypt sensitive data")
            val cryptoObject = BiometricPrompt.CryptoObject(cipher)
            biometricPrompt.authenticate(promptInfo, cryptoObject)
        } else {
            callback(null)
        }
    }
    
    private fun initCipherForDecryption(iv: ByteArray): Boolean {
        return try {
            keyStore.load(null)
            val secretKey = keyStore.getKey(KEY_NAME, null) as SecretKey
            val ivSpec = IvParameterSpec(iv)
            cipher.init(Cipher.DECRYPT_MODE, secretKey, ivSpec)
            true
        } catch (e: Exception) {
            false
        }
    }
    
    private fun encryptData(data: String, cipher: Cipher): String? {
        return try {
            val encryptedBytes = cipher.doFinal(data.toByteArray())
            val iv = cipher.iv
            val combined = iv + encryptedBytes
            Base64.encodeToString(combined, Base64.DEFAULT)
        } catch (e: Exception) {
            null
        }
    }
    
    private fun decryptData(encryptedData: String, cipher: Cipher): String? {
        return try {
            val combined = Base64.decode(encryptedData, Base64.DEFAULT)
            val encryptedBytes = combined.sliceArray(16 until combined.size) // Skip IV
            val decryptedBytes = cipher.doFinal(encryptedBytes)
            String(decryptedBytes)
        } catch (e: Exception) {
            null
        }
    }
    
    private fun createBiometricPrompt(onSuccess: (BiometricPrompt.AuthenticationResult) -> Unit): BiometricPrompt {
        val executor = ContextCompat.getMainExecutor(activity)
        
        return BiometricPrompt(activity, executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(result)
                    onSuccess(result)
                }
                
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    // Handle error
                }
                
                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    // Handle failure
                }
            })
    }
    
    private fun createPromptInfo(title: String, subtitle: String): BiometricPrompt.PromptInfo {
        return BiometricPrompt.PromptInfo.Builder()
            .setTitle(title)
            .setSubtitle(subtitle)
            .setNegativeButtonText("Cancel")
            .setConfirmationRequired(false)
            .build()
    }
}
```

