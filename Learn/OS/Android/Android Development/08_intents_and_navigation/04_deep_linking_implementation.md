## Deep Linking Implementation


Deep linking enables users to navigate directly to specific content within your application through URLs or other external triggers.

### Basic Deep Link Setup

```xml
<activity
    android:name=".DeepLinkActivity"
    android:exported="true"
    android:launchMode="singleTop">
    
    <!-- HTTP/HTTPS deep links -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https"
              android:host="myapp.com"
              android:pathPrefix="/product" />
    </intent-filter>
    
    <!-- Custom scheme deep links -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="myapp" />
    </intent-filter>
    
</activity>
```

### Deep Link Handling

```kotlin
class DeepLinkActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_deep_link)
        
        handleDeepLink(intent)
    }
    
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent?.let { handleDeepLink(it) }
    }
    
    private fun handleDeepLink(intent: Intent) {
        val data = intent.data
        data?.let { uri ->
            when (uri.scheme) {
                "https" -> handleWebDeepLink(uri)
                "myapp" -> handleCustomSchemeDeepLink(uri)
            }
        }
    }
    
    private fun handleWebDeepLink(uri: Uri) {
        when {
            uri.path?.startsWith("/product") == true -> {
                val productId = uri.getQueryParameter("id")
                val category = uri.getQueryParameter("category")
                navigateToProduct(productId, category)
            }
            uri.path?.startsWith("/user") == true -> {
                val userId = uri.lastPathSegment
                navigateToUserProfile(userId)
            }
            uri.path?.startsWith("/article") == true -> {
                val articleId = uri.lastPathSegment
                navigateToArticle(articleId)
            }
        }
    }
    
    private fun handleCustomSchemeDeepLink(uri: Uri) {
        when (uri.host) {
            "open" -> {
                val screen = uri.getQueryParameter("screen")
                val params = uri.getQueryParameter("params")
                navigateToScreen(screen, params)
            }
            "share" -> {
                val content = uri.getQueryParameter("content")
                handleShareContent(content)
            }
        }
    }
    
    private fun navigateToProduct(productId: String?, category: String?) {
        productId?.let { id ->
            val intent = Intent(this, ProductDetailActivity::class.java).apply {
                putExtra("product_id", id)
                category?.let { putExtra("category", it) }
            }
            startActivity(intent)
        }
    }
    
    private fun navigateToUserProfile(userId: String?) {
        userId?.let { id ->
            val intent = Intent(this, UserProfileActivity::class.java).apply {
                putExtra("user_id", id)
            }
            startActivity(intent)
        }
    }
}
```

### App Link Verification

```kotlin
class AppLinkVerificationHelper {
    
    fun createDigitalAssetLinks(): String {
        // This JSON should be hosted at https://yourdomain.com/.well-known/assetlinks.json
        return """
        [{
            "relation": ["delegate_permission/common.handle_all_urls"],
            "target": {
                "namespace": "android_app",
                "package_name": "com.example.myapp",
                "sha256_cert_fingerprints": ["SHA256_FINGERPRINT_HERE"]
            }
        }]
        """.trimIndent()
    }
    
    fun verifyAppLinks(context: Context) {
        val packageManager = context.packageManager
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://yourdomain.com"))
        
        val resolveInfoList = packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
        val canHandleLink = resolveInfoList.any { resolveInfo ->
            resolveInfo.activityInfo.packageName == context.packageName
        }
        
        // [Inference] Log verification result for debugging
        if (canHandleLink) {
            android.util.Log.d("AppLink", "App can handle the deep link")
        } else {
            android.util.Log.w("AppLink", "App cannot handle the deep link")
        }
    }
}
```

### Dynamic Deep Link Generation

```kotlin
class DynamicLinkGenerator {
    
    fun generateShareableLink(contentId: String, contentType: String): String {
        val baseUrl = "https://myapp.com"
        return when (contentType) {
            "product" -> "$baseUrl/product?id=$contentId"
            "article" -> "$baseUrl/article/$contentId"
            "user" -> "$baseUrl/user/$contentId"
            else -> "$baseUrl"
        }
    }
    
    fun generateCustomSchemeLink(action: String, parameters: Map<String, String>): String {
        val baseUri = "myapp://$action"
        if (parameters.isEmpty()) return baseUri
        
        val queryParams = parameters.map { "${it.key}=${it.value}" }
            .joinToString("&")
        return "$baseUri?$queryParams"
    }
    
    fun createShareIntent(deepLink: String, title: String): Intent {
        val shareText = "Check this out: $deepLink"
        return Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, shareText)
            putExtra(Intent.EXTRA_SUBJECT, title)
        }
    }
}
```

