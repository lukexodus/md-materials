## Network Optimization


Network optimization focuses on reducing data usage, minimizing request frequency, and handling connectivity changes gracefully. Effective caching and compression strategies improve both performance and user experience.

**HTTP Client Optimization**

OkHttp provides comprehensive networking capabilities with built-in optimization features including connection pooling, response caching, and request/response compression.

```kotlin
class OptimizedNetworkClient {
    
    private val okHttpClient = OkHttp.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(15, TimeUnit.SECONDS)
        .connectionPool(ConnectionPool(5, 5, TimeUnit.MINUTES))
        .cache(createCache())
        .addInterceptor(createCacheInterceptor())
        .addInterceptor(createCompressionInterceptor())
        .build()
    
    private fun createCache(): Cache {
        val cacheSize = 50 * 1024 * 1024 // 50 MB
        val cacheDirectory = File(context.cacheDir, "http_cache")
        return Cache(cacheDirectory, cacheSize.toLong())
    }
    
    private fun createCacheInterceptor(): Interceptor {
        return Interceptor { chain ->
            val request = chain.request()
            val response = chain.proceed(request)
            
            // Cache responses for 5 minutes by default
            val cacheControl = CacheControl.Builder()
                .maxAge(5, TimeUnit.MINUTES)
                .build()
            
            response.newBuilder()
                .header("Cache-Control", cacheControl.toString())
                .build()
        }
    }
    
    private fun createCompressionInterceptor(): Interceptor {
        return Interceptor { chain ->
            val originalRequest = chain.request()
            val compressedRequest = originalRequest.newBuilder()
                .header("Accept-Encoding", "gzip, deflate")
                .build()
            
            chain.proceed(compressedRequest)
        }
    }
    
    fun createRetrofit(): Retrofit {
        return Retrofit.Builder()
            .baseUrl("https://api.example.com/")
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .addCallAdapterFactory(RxJava3CallAdapterFactory.create())
            .build()
    }
}
```

**Request Batching and Deduplication**

Batch multiple requests together and eliminate duplicate requests to reduce network overhead and improve efficiency.

```kotlin
class RequestBatcher {
    private val pendingRequests = mutableMapOf<String, MutableList<CompletableDeferred<String>>>()
    private val batchHandler = Handler(Looper.getMainLooper())
    private var batchRunnable: Runnable? = null
    
    suspend fun fetchData(id: String): String = suspendCancellableCoroutine { continuation ->
        val deferred = CompletableDeferred<String>()
        
        // Add to pending requests
        pendingRequests.getOrPut(id) { mutableListOf() }.add(deferred)
        
        // Schedule batch processing
        scheduleBatchExecution()
        
        // Return result when available
        continuation.invokeOnCancellation { 
            pendingRequests[id]?.remove(deferred)
        }
        
        CoroutineScope(Dispatchers.Main).launch {
            try {
                val result = deferred.await()
                continuation.resume(result)
            } catch (e: Exception) {
                continuation.resumeWithException(e)
            }
        }
    }
    
    private fun scheduleBatchExecution() {
        batchRunnable?.let { batchHandler.removeCallbacks(it) }
        
        batchRunnable = Runnable {
            executeBatch()
        }
        
        batchHandler.postDelayed(batchRunnable!!, 100) // Batch for 100ms
    }
    
    private fun executeBatch() {
        if (pendingRequests.isEmpty()) return
        
        val batchIds = pendingRequests.keys.toList()
        val requestMap = pendingRequests.toMap()
        pendingRequests.clear()
        
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val results = performBatchRequest(batchIds)
                
                results.forEach { (id, result) ->
                    requestMap[id]?.forEach { deferred ->
                        deferred.complete(result)
                    }
                }
            } catch (e: Exception) {
                requestMap.values.flatten().forEach { deferred ->
                    deferred.completeExceptionally(e)
                }
            }
        }
    }
    
    private suspend fun performBatchRequest(ids: List<String>): Map<String, String> {
        // [Inference] Implementation would make batch API request
        return ids.associateWith { "Result for $it" }
    }
}
```

**Image Loading Optimization**

Optimize image loading with appropriate sizing, format selection, and progressive loading techniques.

```kotlin
class OptimizedImageLoader(private val context: Context) {
    
    private val imageLoader = ImageLoader.Builder(context)
        .memoryCache {
            MemoryCache.Builder(context)
                .maxSizePercent(0.25) // Use 25% of available memory
                .strongReferencesEnabled(false) // Enable weak references
                .build()
        }
        .diskCache {
            DiskCache.Builder()
                .directory(context.cacheDir.resolve("image_cache"))
                .maxSizeBytes(100 * 1024 * 1024) // 100 MB
                .build()
        }
        .components {
            add(SvgDecoder.Factory())
            add(VideoFrameDecoder.Factory())
        }
        .build()
    
    fun loadImage(
        url: String,
        imageView: ImageView,
        targetWidth: Int = imageView.width,
        targetHeight: Int = imageView.height
    ) {
        val request = ImageRequest.Builder(context)
            .data(url)
            .target(imageView)
            .size(targetWidth, targetHeight)
            .crossfade(true)
            .placeholder(R.drawable.placeholder)
            .error(R.drawable.error)
            .transformations(
                if (targetWidth > 0 && targetHeight > 0) {
                    listOf(CenterCropTransformation())
                } else {
                    emptyList()
                }
            )
            .build()
        
        imageLoader.enqueue(request)
    }
    
    // Progressive image loading for large images
    fun loadProgressiveImage(url: String, imageView: ImageView, callback: ProgressCallback) {
        val request = ImageRequest.Builder(context)
            .data(url)
            .target(
                onStart = { placeholder ->
                    imageView.setImageDrawable(placeholder)
                    callback.onProgress(0)
                },
                onSuccess = { result ->
                    imageView.setImageDrawable(result)
                    callback.onProgress(100)
                },
                onError = { error ->
                    imageView.setImageDrawable(error)
                    callback.onError()
                }
            )
            .listener(
                onStart = { callback.onProgress(10) },
                onCancel = { callback.onError() },
                onError = { _, _ -> callback.onError() },
                onSuccess = { _, _ -> callback.onProgress(100) }
            )
            .build()
        
        imageLoader.enqueue(request)
    }
    
    interface ProgressCallback {
        fun onProgress(progress: Int)
        fun onError()
    }
}
```

**Connectivity Management**

Handle network connectivity changes gracefully with automatic retry mechanisms and offline capabilities.

```kotlin
class ConnectivityManager(private val context: Context) {
    private val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as android.net.ConnectivityManager
    private val networkCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
            onNetworkAvailable()
        }
        
        override fun onLost(network: Network) {
            onNetworkLost()
        }
        
        override fun onCapabilitiesChanged(network: Network, networkCapabilities: NetworkCapabilities) {
            handleCapabilitiesChanged(networkCapabilities)
        }
    }
    
    private val pendingRequests = mutableListOf<PendingNetworkRequest>()
    
    fun registerNetworkCallback() {
        val request = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .addCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
            .build()
        
        connectivityManager.registerNetworkCallback(request, networkCallback)
    }
    
    fun unregisterNetworkCallback() {
        connectivityManager.unregisterNetworkCallback(networkCallback)
    }
    
    private fun onNetworkAvailable() {
        // Execute pending requests when network becomes available
        val requestsToExecute = pendingRequests.toList()
        pendingRequests.clear()
        
        requestsToExecute.forEach { request ->
            executeRequest(request)
        }
    }
    
    private fun onNetworkLost() {
        // Handle network loss - could notify UI or pause certain operations
    }
    
    private fun handleCapabilitiesChanged(capabilities: NetworkCapabilities) {
        val isWifi = capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
        val isCellular = capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)
        val isMetered = !capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED)
        
        // Adjust behavior based on network type
        if (isMetered) {
            // Reduce image quality, defer non-essential requests
            adjustForMeteredConnection()
        }
    }
    
    fun isNetworkAvailable(): Boolean {
        val activeNetwork = connectivityManager.activeNetwork ?: return false
        val capabilities = connectivityManager.getNetworkCapabilities(activeNetwork) ?: return false
        
        return capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
               capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
    }
    
    fun executeWithRetry(request: NetworkRequest, maxRetries: Int = 3): CompletableDeferred<NetworkResponse> {
        val deferred = CompletableDeferred<NetworkResponse>()
        
        if (!isNetworkAvailable()) {
            pendingRequests.add(PendingNetworkRequest(request, deferred, maxRetries))
            return deferred
        }
        
        executeRequestWithRetry(request, deferred, maxRetries, 0)
        return deferred
    }
    
    private fun executeRequestWithRetry(
        request: NetworkRequest, 
        deferred: CompletableDeferred<NetworkResponse>,
        maxRetries: Int,
        currentAttempt: Int
    ) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val response = executeRequest(request)
                deferred.complete(response)
            } catch (e: Exception) {
                if (currentAttempt < maxRetries) {
                    delay(1000 * (currentAttempt + 1)) // Exponential backoff
                    executeRequestWithRetry(request, deferred, maxRetries, currentAttempt + 1)
                } else {
                    deferred.completeExceptionally(e)
                }
            }
        }
    }
    
    private fun adjustForMeteredConnection() {
        // [Inference] Implementation would adjust app behavior for metered connections
    }
    
    private suspend fun executeRequest(request: NetworkRequest): NetworkResponse {
        // [Inference] Implementation would execute the actual network request
        return NetworkResponse()
    }
    
    private fun executeRequest(pendingRequest: PendingNetworkRequest) {
        executeRequestWithRetry(
            pendingRequest.request, 
            pendingRequest.deferred, 
            pendingRequest.maxRetries, 
            0
        )
    }
    
    data class PendingNetworkRequest(
        val request: NetworkRequest,
        val deferred: CompletableDeferred<NetworkResponse>,
        val maxRetries: Int
    )
    
    data class NetworkRequest(val url: String, val method: String = "GET")
    data class NetworkResponse(val data: String = "")
}
```

**Key Points:**

- Implement comprehensive caching strategies with appropriate expiration times
- Batch network requests to reduce overhead and improve efficiency
- Handle connectivity changes with automatic retry mechanisms
- Optimize image loading with proper sizing and progressive techniques
- Use compression and connection pooling for better performance

