## Secure Data Transmission


Secure data transmission protects information as it travels between the client application and remote servers. This involves implementing proper encryption protocols, certificate validation, and secure communication channels that prevent eavesdropping and tampering.

Transport Layer Security (TLS) provides the foundation for secure HTTPS communication. Modern Android applications should use TLS 1.2 or higher, with proper certificate validation and strong cipher suites. Network Security Configuration allows declarative specification of security settings for network communication.

Certificate pinning enhances security by validating that the server presents an expected certificate or public key, preventing man-in-the-middle attacks even with compromised certificate authorities. This technique requires careful implementation to handle certificate rotation without breaking the application.

Request and response encryption adds an additional layer of security beyond TLS, protecting data even if the transport layer is compromised. This typically involves encrypting sensitive payloads before sending them over HTTPS and decrypting received data on the client side.

**Example:** Secure networking implementation:

```kotlin
// NetworkSecurityConfig.kt
class NetworkSecurityConfig {
    
    companion object {
        private const val API_BASE_URL = "https://api.example.com/"
        private const val CERTIFICATE_PIN = "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    }
    
    fun createSecureOkHttpClient(): OkHttpClient {
        val certificatePinner = CertificatePinner.Builder()
            .add("api.example.com", CERTIFICATE_PIN)
            .build()
        
        val connectionSpec = ConnectionSpec.Builder(ConnectionSpec.MODERN_TLS)
            .tlsVersions(TlsVersion.TLS_1_2, TlsVersion.TLS_1_3)
            .cipherSuites(
                CipherSuite.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
                CipherSuite.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
                CipherSuite.TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
            )
            .build()
        
        return OkHttpClient.Builder()
            .certificatePinner(certificatePinner)
            .connectionSpecs(listOf(connectionSpec))
            .addInterceptor(createSecurityInterceptor())
            .addInterceptor(createLoggingInterceptor())
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build()
    }
    
    private fun createSecurityInterceptor(): Interceptor {
        return Interceptor { chain ->
            val originalRequest = chain.request()
            
            // Add security headers
            val secureRequest = originalRequest.newBuilder()
                .addHeader("X-Requested-With", "XMLHttpRequest")
                .addHeader("Cache-Control", "no-cache, no-store, must-revalidate")
                .addHeader("Pragma", "no-cache")
                .addHeader("Expires", "0")
                .build()
            
            val response = chain.proceed(secureRequest)
            
            // Validate response security headers
            validateSecurityHeaders(response)
            
            response
        }
    }
    
    private fun createLoggingInterceptor(): HttpLoggingInterceptor {
        return HttpLoggingInterceptor { message ->
            // Log only in debug builds, sanitize sensitive data
            if (BuildConfig.DEBUG) {
                val sanitizedMessage = sanitizeLogMessage(message)
                Log.d("NetworkSecurity", sanitizedMessage)
            }
        }.apply {
            level = if (BuildConfig.DEBUG) {
                HttpLoggingInterceptor.Level.BODY
            } else {
                HttpLoggingInterceptor.Level.NONE
            }
        }
    }
    
    private fun sanitizeLogMessage(message: String): String {
        // Remove sensitive information from logs
        return message
            .replace(Regex("(\"password\"\\s*:\\s*\")[^\"]*\""), "$1[REDACTED]\"")
            .replace(Regex("(\"token\"\\s*:\\s*\")[^\"]*\""), "$1[REDACTED]\"")
            .replace(Regex("(\"apiKey\"\\s*:\\s*\")[^\"]*\""), "$1[REDACTED]\"")
            .replace(Regex("(Authorization:\\s*)[^\\s]+"), "$1[REDACTED]")
    }
    
    private fun validateSecurityHeaders(response: Response) {
        val headers = response.headers
        
        // Check for security headers
        if (headers["Strict-Transport-Security"] == null) {
            Log.w("NetworkSecurity", "Missing HSTS header")
        }
        
        if (headers["X-Content-Type-Options"] == null) {
            Log.w("NetworkSecurity", "Missing X-Content-Type-Options header")
        }
        
        if (headers["X-Frame-Options"] == null) {
            Log.w("NetworkSecurity", "Missing X-Frame-Options header")
        }
    }
}

// EncryptionManager.kt - Application-level encryption
class EncryptionManager {
    
    companion object {
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val KEY_LENGTH = 256
        private const val IV_LENGTH = 12
        private const val TAG_LENGTH = 128
    }
    
    fun generateSecretKey(): SecretKey {
        val keyGenerator = KeyGenerator.getInstance("AES")
        keyGenerator.init(KEY_LENGTH)
        return keyGenerator.generateKey()
    }
    
    fun encryptPayload(data: String, secretKey: SecretKey): EncryptedPayload {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, secretKey)
        
        val iv = cipher.iv
        val encryptedData = cipher.doFinal(data.toByteArray(Charsets.UTF_8))
        
        return EncryptedPayload(
            data = Base64.encodeToString(encryptedData, Base64.NO_WRAP),
            iv = Base64.encodeToString(iv, Base64.NO_WRAP)
        )
    }
    
    fun decryptPayload(payload: EncryptedPayload, secretKey: SecretKey): String? {
        return try {
            val cipher = Cipher.getInstance(TRANSFORMATION)
            val spec = GCMParameterSpec(TAG_LENGTH, Base64.decode(payload.iv, Base64.NO_WRAP))
            cipher.init(Cipher.DECRYPT_MODE, secretKey, spec)
            
            val encryptedData = Base64.decode(payload.data, Base64.NO_WRAP)
            val decryptedData = cipher.doFinal(encryptedData)
            
            String(decryptedData, Charsets.UTF_8)
        } catch (e: Exception) {
            Log.e("EncryptionManager", "Decryption failed", e)
            null
        }
    }
    
    fun generateKeyFromPassword(password: String, salt: ByteArray): SecretKey {
        val factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
        val spec = PBEKeySpec(password.toCharArray(), salt, 10000, KEY_LENGTH)
        val tmp = factory.generateSecret(spec)
        return SecretKeySpec(tmp.encoded, "AES")
    }
    
    fun generateSalt(): ByteArray {
        val salt = ByteArray(16)
        SecureRandom().nextBytes(salt)
        return salt
    }
}

data class EncryptedPayload(
    val data: String,
    val iv: String
)

// SecureApiService.kt - Retrofit service with encryption
interface SecureApiService {
    
    @POST("api/secure-endpoint")
    suspend fun secureApiCall(@Body encryptedPayload: EncryptedPayload): Response<EncryptedPayload>
    
    @GET("api/public-data")
    suspend fun getPublicData(): Response<List<PublicDataModel>>
}

class SecureApiClient(
    private val encryptionManager: EncryptionManager,
    private val secretKey: SecretKey
) {
    
    private val apiService: SecureApiService by lazy {
        val networkConfig = NetworkSecurityConfig()
        val okHttpClient = networkConfig.createSecureOkHttpClient()
        
        val retrofit = Retrofit.Builder()
            .baseUrl("https://api.example.com/")
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
        
        retrofit.create(SecureApiService::class.java)
    }
    
    suspend fun sendSecureData(data: SensitiveDataModel): Result<String> {
        return try {
            // Serialize and encrypt the data
            val gson = Gson()
            val jsonData = gson.toJson(data)
            val encryptedPayload = encryptionManager.encryptPayload(jsonData, secretKey)
            
            // Send encrypted data
            val response = apiService.secureApiCall(encryptedPayload)
            
            if (response.isSuccessful) {
                response.body()?.let { encryptedResponse ->
                    // Decrypt response
                    val decryptedResponse = encryptionManager.decryptPayload(encryptedResponse, secretKey)
                    if (decryptedResponse != null) {
                        Result.success(decryptedResponse)
                    } else {
                        Result.failure(Exception("Failed to decrypt response"))
                    }
                } ?: Result.failure(Exception("Empty response body"))
            } else {
                Result.failure(Exception("API call failed: ${response.code()}"))
            }
        } catch (e: Exception) {
            Log.e("SecureApiClient", "Secure API call failed", e)
            Result.failure(e)
        }
    }
}

// Network Security Configuration XML
// res/xml/network_security_config.xml
/*
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">api.example.com</domain>
        <pin-set expiration="2025-12-31">
            <pin digest="SHA-256">AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=</pin>
            <pin digest="SHA-256">BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=</pin>
        </pin-set>
        <trust-anchors>
            <certificates src="system"/>
        </trust-anchors>
    </domain-config>
    
    <!-- Debug configuration for development -->
    <debug-overrides>
        <trust-anchors>
            <certificates src="user"/>
        </trust-anchors>
    </debug-overrides>
    
    <!-- Base configuration for other domains -->
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system"/>
        </trust-anchors>
    </base-config>
</network-security-config>
*/

// TokenManager.kt - Secure token storage and management
class TokenManager(private val context: Context) {
    
    companion object {
        private const val ENCRYPTED_PREFS_NAME = "secure_tokens"
        private const val TOKEN_KEY = "auth_token"
        private const val REFRESH_TOKEN_KEY = "refresh_token"
        private const val TOKEN_EXPIRY_KEY = "token_expiry"
    }
    
    private val encryptedSharedPreferences: SharedPreferences by lazy {
        EncryptedSharedPreferences.create(
            ENCRYPTED_PREFS_NAME,
            MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC),
            context,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }
    
    fun saveAuthToken(token: String, refreshToken: String, expiryTimeMillis: Long) {
        encryptedSharedPreferences.edit {
            putString(TOKEN_KEY, token)
            putString(REFRESH_TOKEN_KEY, refreshToken)
            putLong(TOKEN_EXPIRY_KEY, expiryTimeMillis)
        }
    }
    
    fun getAuthToken(): String? {
        val expiryTime = encryptedSharedPreferences.getLong(TOKEN_EXPIRY_KEY, 0)
        
        return if (System.currentTimeMillis() < expiryTime) {
            encryptedSharedPreferences.getString(TOKEN_KEY, null)
        } else {
            // Token expired, attempt refresh
            refreshTokenIfNeeded()
        }
    }
    
    fun getRefreshToken(): String? {
        return encryptedSharedPreferences.getString(REFRESH_TOKEN_KEY, null)
    }
    
    private fun refreshTokenIfNeeded(): String? {
        // Implementation would typically make an API call to refresh the token
        // This is a simplified example
        val refreshToken = getRefreshToken()
        return if (refreshToken != null) {
            // Make API call to refresh token
            // Return new token or null if refresh failed
            null
        } else {
            null
        }
    }
    
    fun clearTokens() {
        encryptedSharedPreferences.edit {
            remove(TOKEN_KEY)
            remove(REFRESH_TOKEN_KEY)
            remove(TOKEN_EXPIRY_KEY)
        }
    }
    
    fun isTokenValid(): Boolean {
        val token = encryptedSharedPreferences.getString(TOKEN_KEY, null)
        val expiryTime = encryptedSharedPreferences.getLong(TOKEN_EXPIRY_KEY, 0)
        
        return token != null && System.currentTimeMillis() < expiryTime
    }
}

// Usage example in Repository
class AuthRepository(
    private val apiClient: SecureApiClient,
    private val tokenManager: TokenManager
) {
    
    suspend fun authenticateUser(credentials: LoginCredentials): Result<AuthResponse> {
        return try {
            val result = apiClient.sendSecureData(credentials)
            
            result.fold(
                onSuccess = { response ->
                    val gson = Gson()
                    val authResponse = gson.fromJson(response, AuthResponse::class.java)
                    
                    // Store tokens securely
                    tokenManager.saveAuthToken(
                        authResponse.accessToken,
                        authResponse.refreshToken,
                        System.currentTimeMillis() + authResponse.expiresInMillis
                    )
                    
                    Result.success(authResponse)
                },
                onFailure = { exception ->
                    Result.failure(exception)
                }
            )
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    fun logout() {
        tokenManager.clearTokens()
    }
    
    fun isUserAuthenticated(): Boolean {
        return tokenManager.isTokenValid()
    }
}

data class LoginCredentials(
    val username: String,
    val password: String
) : SensitiveDataModel

data class AuthResponse(
    val accessToken: String,
    val refreshToken: String,
    val expiresInMillis: Long,
    val userId: String
)

interface SensitiveDataModel

data class PublicDataModel(
    val id: String,
    val title: String,
    val description: String
)
```

**Key Points:**

- Always use HTTPS with TLS 1.2 or higher for network communication
- Implement certificate pinning to prevent man-in-the-middle attacks
- Encrypt sensitive data at the application layer for additional security
- Store authentication tokens using EncryptedSharedPreferences
- Validate security headers in API responses to ensure proper server configuration

**Security Considerations:**

- Regularly rotate certificate pins to handle certificate updates
- Implement proper error handling that doesn't leak sensitive information
- Use secure random number generation for cryptographic operations
- Monitor network traffic in debug builds but sanitize logs in production
- Implement token refresh mechanisms to handle expiration gracefully

**Network Security Configuration Benefits:**

- Declarative security policy configuration without code changes
- Certificate pinning with backup pins for rotation
- Debug-specific configurations for development and testing
- Protection against cleartext traffic in production builds
- Integration with Android's security features and certificate validation

**Related Topics:** For comprehensive security implementation, explore biometric authentication integration, secure local database encryption with SQLCipher, secure file storage techniques, and implementation of security monitoring and threat detection. Additionally, consider network security monitoring, API rate limiting strategies, and secure backup and restore mechanisms for user data.

---

