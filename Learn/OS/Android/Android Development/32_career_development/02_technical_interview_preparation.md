## Technical Interview Preparation


Technical interview preparation for Android development positions requires comprehensive understanding of computer science fundamentals, Android-specific concepts, system design principles, and practical coding skills demonstrated through structured practice and portfolio projects.

**Key Points** Android technical interviews typically cover data structures and algorithms, Android framework knowledge, system design scenarios, and live coding exercises. Preparation should include algorithm practice on platforms like LeetCode, Android-specific concept review, mock interview sessions, and system design study for senior positions. [Inference] Companies often emphasize practical problem-solving over theoretical knowledge, particularly for mobile development roles.

**Algorithm and Data Structure Focus** Android interviews commonly test array manipulation, string processing, tree traversals, graph algorithms, and dynamic programming concepts. Mobile-specific problems often involve memory optimization, caching strategies, and efficient data processing for limited device resources.

```kotlin
// Common Android Interview Problem: LRU Cache Implementation
class LRUCache<K, V>(private val maxSize: Int) {
    private val cache = LinkedHashMap<K, V>(maxSize + 1, 0.75f, true)
    
    fun get(key: K): V? {
        return cache[key] // LinkedHashMap automatically moves to end on access
    }
    
    fun put(key: K, value: V) {
        if (cache.size >= maxSize && !cache.containsKey(key)) {
            val firstKey = cache.keys.iterator().next()
            cache.remove(firstKey)
        }
        cache[key] = value
    }
    
    fun size(): Int = cache.size
    
    fun clear() = cache.clear()
}

// Usage in Android context - Image Cache
class ImageCacheManager {
    private val memoryCache = LRUCache<String, Bitmap>(
        maxSize = (Runtime.getRuntime().maxMemory() / 1024 / 8).toInt()
    )
    
    fun getBitmap(url: String): Bitmap? {
        return memoryCache.get(url)
    }
    
    fun addBitmapToMemoryCache(url: String, bitmap: Bitmap) {
        if (getBitmap(url) == null) {
            memoryCache.put(url, bitmap)
        }
    }
}

// Tree Traversal Problem: File System Navigation
data class FileNode(
    val name: String,
    val isDirectory: Boolean,
    val children: MutableList<FileNode> = mutableListOf()
)

class FileSystemNavigator {
    fun findAllFiles(root: FileNode, extension: String): List<String> {
        val result = mutableListOf<String>()
        
        fun dfs(node: FileNode, currentPath: String) {
            val fullPath = if (currentPath.isEmpty()) node.name else "$currentPath/${node.name}"
            
            if (!node.isDirectory && node.name.endsWith(extension)) {
                result.add(fullPath)
            }
            
            if (node.isDirectory) {
                for (child in node.children) {
                    dfs(child, fullPath)
                }
            }
        }
        
        dfs(root, "")
        return result
    }
}
```

**Android Framework Deep Dive** Interview questions frequently cover Activity lifecycle, Fragment management, View rendering, memory leaks, ANR prevention, and performance optimization techniques. Candidates must demonstrate understanding of threading, database operations, network communication, and security best practices.

```kotlin
// Activity Lifecycle Management Interview Question
class InterviewActivity : AppCompatActivity() {
    private lateinit var viewModel: InterviewViewModel
    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Demonstrate proper initialization
        viewModel = ViewModelProvider(this)[InterviewViewModel::class.java]
        
        // Show understanding of saved state
        savedInstanceState?.let { bundle ->
            restoreState(bundle)
        }
        
        // Demonstrate lifecycle-aware components
        lifecycle.addObserver(LocationObserver())
        
        setupNetworkCallback()
    }
    
    override fun onStart() {
        super.onStart()
        // Register network callback
        val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        networkCallback?.let { callback ->
            connectivityManager.registerDefaultNetworkCallback(callback)
        }
    }
    
    override fun onStop() {
        super.onStop()
        // Unregister to prevent memory leaks
        val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        networkCallback?.let { callback ->
            connectivityManager.unregisterNetworkCallback(callback)
        }
    }
    
    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        // Save critical state
        outState.putString("user_input", getCurrentUserInput())
        outState.putParcelable("current_data", getCurrentData())
    }
    
    // Memory leak prevention demonstration
    class LocationObserver : LifecycleObserver {
        @OnLifecycleEvent(Lifecycle.Event.ON_START)
        fun startLocationUpdates() {
            // Start location services
        }
        
        @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
        fun stopLocationUpdates() {
            // Stop location services to prevent memory leaks
        }
    }
}

// Threading and Background Work Interview Topic
class BackgroundTaskManager(private val context: Context) {
    
    // Demonstrate understanding of different threading approaches
    fun demonstrateThreadingConcepts() {
        // Main thread - UI operations only
        runOnUiThread {
            updateProgressBar(50)
        }
        
        // Background thread - network/database operations
        CoroutineScope(Dispatchers.IO).launch {
            val data = performNetworkCall()
            
            withContext(Dispatchers.Main) {
                updateUI(data)
            }
        }
        
        // WorkManager for guaranteed background work
        val workRequest = OneTimeWorkRequestBuilder<DataSyncWorker>()
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build()
            )
            .build()
            
        WorkManager.getInstance(context).enqueue(workRequest)
    }
    
    // AsyncTask replacement with coroutines (common interview topic)
    suspend fun loadUserData(userId: String): Result<User> {
        return withContext(Dispatchers.IO) {
            try {
                val user = userRepository.getUser(userId)
                Result.Success(user)
            } catch (exception: Exception) {
                Result.Error(exception)
            }
        }
    }
}
```

**System Design Scenarios** Senior Android positions require system design knowledge covering app architecture, scalability considerations, offline functionality, data synchronization, and performance optimization strategies for large-scale applications.

```kotlin
// System Design Example: Chat Application Architecture
interface ChatSystemDesign {
    // Data Layer
    interface MessageRepository {
        suspend fun sendMessage(message: Message): Result<Message>
        suspend fun getMessages(chatId: String, limit: Int, offset: Int): List<Message>
        fun observeMessages(chatId: String): Flow<List<Message>>
    }
    
    // Network Layer with caching strategy
    class MessageRepositoryImpl(
        private val localDataSource: MessageLocalDataSource,
        private val remoteDataSource: MessageRemoteDataSource,
        private val cacheManager: CacheManager
    ) : MessageRepository {
        
        override suspend fun sendMessage(message: Message): Result<Message> {
            return try {
                // Optimistic UI update
                localDataSource.insertMessage(message.copy(status = MessageStatus.SENDING))
                
                // Send to server
                val sentMessage = remoteDataSource.sendMessage(message)
                
                // Update local database
                localDataSource.updateMessage(sentMessage)
                
                Result.Success(sentMessage)
            } catch (exception: Exception) {
                // Mark message as failed
                localDataSource.updateMessage(message.copy(status = MessageStatus.FAILED))
                Result.Error(exception)
            }
        }
        
        override fun observeMessages(chatId: String): Flow<List<Message>> {
            return combine(
                localDataSource.observeMessages(chatId),
                networkConnectivity.observe()
            ) { localMessages, isConnected ->
                if (isConnected && shouldSync(chatId)) {
                    syncMessages(chatId)
                }
                localMessages
            }
        }
    }
    
    // Real-time communication
    class WebSocketManager {
        private var webSocket: WebSocket? = null
        private val messageFlow = MutableSharedFlow<Message>()
        
        fun connect(userId: String) {
            val client = OkHttpClient()
            val request = Request.Builder()
                .url("wss://chat-server.com/ws/$userId")
                .build()
                
            webSocket = client.newWebSocket(request, object : WebSocketListener() {
                override fun onMessage(webSocket: WebSocket, text: String) {
                    val message = Json.decodeFromString<Message>(text)
                    messageFlow.tryEmit(message)
                }
            })
        }
        
        fun observeIncomingMessages(): Flow<Message> = messageFlow.asSharedFlow()
    }
}
```

