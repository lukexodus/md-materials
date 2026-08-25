## WorkManager for Background Tasks


WorkManager provides a unified solution for deferrable background work that needs guaranteed execution, replacing the need for services in many use cases.

### WorkManager Implementation

WorkManager handles background tasks efficiently while respecting system constraints and battery optimization.

```kotlin
class SyncWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        return try {
            val syncType = inputData.getString(KEY_SYNC_TYPE) ?: "default"
            val retryCount = inputData.getInt(KEY_RETRY_COUNT, 0)
            
            Log.d(TAG, "Starting sync: $syncType, retry: $retryCount")
            
            // Update progress
            setProgress(workDataOf(KEY_PROGRESS to 0))
            
            val result = when (syncType) {
                "user_data" -> syncUserData()
                "media_files" -> syncMediaFiles()
                "settings" -> syncSettings()
                else -> syncDefault()
            }
            
            if (result) {
                // Set output data
                val outputData = workDataOf(
                    KEY_SYNC_RESULT to "Success",
                    KEY_SYNC_TIMESTAMP to System.currentTimeMillis()
                )
                Result.success(outputData)
            } else {
                if (retryCount < MAX_RETRIES) {
                    Result.retry()
                } else {
                    Result.failure(workDataOf(KEY_ERROR to "Max retries exceeded"))
                }
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Sync failed", e)
            Result.failure(workDataOf(KEY_ERROR to e.message))
        }
    }
    
    private suspend fun syncUserData(): Boolean {
        for (i in 1..5) {
            delay(1000) // Simulate network request
            setProgress(workDataOf(KEY_PROGRESS to i * 20))
            
            if (isStopped) {
                Log.d(TAG, "Sync cancelled")
                return false
            }
        }
        
        // Simulate API call
        val apiService = RetrofitClient.create()
        val response = apiService.syncUserData()
        
        return response.isSuccessful
    }
    
    private suspend fun syncMediaFiles(): Boolean {
        // Simulate media file synchronization
        val mediaFiles = getLocalMediaFiles()
        val totalFiles = mediaFiles.size
        
        mediaFiles.forEachIndexed { index, file ->
            if (isStopped) return false
            
            uploadMediaFile(file)
            val progress = ((index + 1) * 100 / totalFiles)
            setProgress(workDataOf(KEY_PROGRESS to progress))
            
            delay(500) // Simulate upload time
        }
        
        return true
    }
    
    private suspend fun syncSettings(): Boolean {
        delay(2000) // Simulate settings sync
        setProgress(workDataOf(KEY_PROGRESS to 100))
        return true
    }
    
    private suspend fun syncDefault(): Boolean {
        delay(1000)
        setProgress(workDataOf(KEY_PROGRESS to 100))
        return true
    }
    
    private fun getLocalMediaFiles(): List<File> {
        // Return dummy list for example
        return listOf(
            File("media1.jpg"),
            File("media2.mp4"),
            File("media3.png")
        )
    }
    
    private suspend fun uploadMediaFile(file: File) {
        // Simulate file upload
        delay(200)
    }
    
    companion object {
        private const val TAG = "SyncWorker"
        private const val MAX_RETRIES = 3
        
        const val KEY_SYNC_TYPE = "sync_type"
        const val KEY_RETRY_COUNT = "retry_count"
        const val KEY_PROGRESS = "progress"
        const val KEY_SYNC_RESULT = "sync_result"
        const val KEY_SYNC_TIMESTAMP = "sync_timestamp"
        const val KEY_ERROR = "error"
    }
}

// WorkManager usage
class DataSyncManager(private val context: Context) {
    
    fun schedulePeriodicSync() {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .setRequiresCharging(false)
            .setRequiresBatteryNotLow(true)
            .build()
        
        val periodicSyncRequest = PeriodicWorkRequestBuilder<SyncWorker>(
            15, TimeUnit.MINUTES,
            5, TimeUnit.MINUTES // Flex interval
        )
            .setConstraints(constraints)
            .setInputData(workDataOf(SyncWorker.KEY_SYNC_TYPE to "user_data"))
            .addTag("periodic_sync")
            .build()
        
        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            "periodic_user_sync",
            ExistingPeriodicWorkPolicy.KEEP,
            periodicSyncRequest
        )
    }
    
    fun scheduleOneTimeSync(syncType: String) {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()
        
        val syncRequest = OneTimeWorkRequestBuilder<SyncWorker>()
            .setConstraints(constraints)
            .setInputData(workDataOf(SyncWorker.KEY_SYNC_TYPE to syncType))
            .setBackoffCriteria(
                BackoffPolicy.EXPONENTIAL,
                OneTimeWorkRequest.MIN_BACKOFF_DELAY_MILLIS,
                TimeUnit.MILLISECONDS
            )
            .addTag("one_time_sync")
            .build()
        
        WorkManager.getInstance(context).enqueue(syncRequest)
        
        // Observe work status
        WorkManager.getInstance(context)
            .getWorkInfoByIdLiveData(syncRequest.id)
            .observe(context as LifecycleOwner) { workInfo ->
                handleWorkStatus(workInfo)
            }
    }
    
    fun scheduleChainedWork() {
        val downloadWork = OneTimeWorkRequestBuilder<DownloadWorker>()
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build()
            )
            .build()
        
        val processWork = OneTimeWorkRequestBuilder<ProcessWorker>()
            .build()


        val uploadWork = OneTimeWorkRequestBuilder<UploadWorker>()
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build()
            )
            .build()
        
        // Chain work requests
        WorkManager.getInstance(context)
            .beginWith(downloadWork)
            .then(processWork)
            .then(uploadWork)
            .enqueue()
    }
    
    private fun handleWorkStatus(workInfo: WorkInfo?) {
        when (workInfo?.state) {
            WorkInfo.State.ENQUEUED -> {
                Log.d("DataSyncManager", "Work enqueued")
            }
            WorkInfo.State.RUNNING -> {
                val progress = workInfo.progress.getInt(SyncWorker.KEY_PROGRESS, 0)
                Log.d("DataSyncManager", "Work running: $progress%")
            }
            WorkInfo.State.SUCCEEDED -> {
                val result = workInfo.outputData.getString(SyncWorker.KEY_SYNC_RESULT)
                val timestamp = workInfo.outputData.getLong(SyncWorker.KEY_SYNC_TIMESTAMP, 0)
                Log.d("DataSyncManager", "Work succeeded: $result at $timestamp")
            }
            WorkInfo.State.FAILED -> {
                val error = workInfo.outputData.getString(SyncWorker.KEY_ERROR)
                Log.e("DataSyncManager", "Work failed: $error")
            }
            WorkInfo.State.CANCELLED -> {
                Log.d("DataSyncManager", "Work cancelled")
            }
            else -> {}
        }
    }
    
    fun cancelAllSync() {
        WorkManager.getInstance(context).cancelAllWorkByTag("periodic_sync")
        WorkManager.getInstance(context).cancelAllWorkByTag("one_time_sync")
    }
    
    fun getWorkStatus(): LiveData<List<WorkInfo>> {
        return WorkManager.getInstance(context).getWorkInfosByTagLiveData("periodic_sync")
    }
}

// ProcessWorker implementation
class ProcessWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        return try {
            // Get input data from previous worker (DownloadWorker)
            val downloadedData = inputData.getString(KEY_DOWNLOADED_DATA)
            val downloadPath = inputData.getString(KEY_DOWNLOAD_PATH)
            
            if (downloadedData.isNullOrEmpty()) {
                return Result.failure(workDataOf(KEY_ERROR to "No data to process"))
            }
            
            Log.d(TAG, "Starting data processing for: $downloadPath")
            
            // Update progress
            setProgress(workDataOf(KEY_PROGRESS to 0))
            
            val processedData = processDownloadedData(downloadedData)
            val processedFilePath = saveProcessedData(processedData)
            
            // Set output data for next worker
            val outputData = workDataOf(
                KEY_PROCESSED_DATA to processedData,
                KEY_PROCESSED_FILE_PATH to processedFilePath,
                KEY_PROCESS_TIMESTAMP to System.currentTimeMillis()
            )
            
            Log.d(TAG, "Data processing completed: $processedFilePath")
            Result.success(outputData)
            
        } catch (e: Exception) {
            Log.e(TAG, "Processing failed", e)
            Result.failure(workDataOf(KEY_ERROR to e.message))
        }
    }
    
    private suspend fun processDownloadedData(rawData: String): String {
        // Simulate data processing steps
        val steps = listOf(
            "Validating data format",
            "Cleaning data",
            "Transforming data structure",
            "Applying business rules",
            "Generating final output"
        )
        
        steps.forEachIndexed { index, step ->
            if (isStopped) {
                throw InterruptedException("Processing cancelled")
            }
            
            Log.d(TAG, "Step ${index + 1}: $step")
            delay(1000) // Simulate processing time
            
            val progress = ((index + 1) * 100 / steps.size)
            setProgress(workDataOf(KEY_PROGRESS to progress))
        }
        
        // Return processed data
        return "PROCESSED: $rawData - ${System.currentTimeMillis()}"
    }
    
    private suspend fun saveProcessedData(processedData: String): String {
        val fileName = "processed_data_${System.currentTimeMillis()}.txt"
        val file = File(applicationContext.cacheDir, fileName)
        
        withContext(Dispatchers.IO) {
            file.writeText(processedData)
        }
        
        return file.absolutePath
    }
    
    companion object {
        private const val TAG = "ProcessWorker"
        
        const val KEY_DOWNLOADED_DATA = "downloaded_data"
        const val KEY_DOWNLOAD_PATH = "download_path"
        const val KEY_PROCESSED_DATA = "processed_data"
        const val KEY_PROCESSED_FILE_PATH = "processed_file_path"
        const val KEY_PROCESS_TIMESTAMP = "process_timestamp"
        const val KEY_PROGRESS = "progress"
        const val KEY_ERROR = "error"
    }
}

// UploadWorker implementation
class UploadWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        return try {
            // Get input data from previous worker (ProcessWorker)
            val processedData = inputData.getString(ProcessWorker.KEY_PROCESSED_DATA)
            val processedFilePath = inputData.getString(ProcessWorker.KEY_PROCESSED_FILE_PATH)
            
            if (processedData.isNullOrEmpty()) {
                return Result.failure(workDataOf(KEY_ERROR to "No processed data to upload"))
            }
            
            Log.d(TAG, "Starting upload for: $processedFilePath")
            
            // Update progress
            setProgress(workDataOf(KEY_PROGRESS to 0))
            
            val uploadResult = uploadProcessedData(processedData, processedFilePath)
            
            // Set final output data
            val outputData = workDataOf(
                KEY_UPLOAD_RESULT to uploadResult.success.toString(),
                KEY_UPLOAD_URL to uploadResult.url,
                KEY_UPLOAD_TIMESTAMP to System.currentTimeMillis(),
                KEY_FILE_SIZE to uploadResult.fileSize
            )
            
            if (uploadResult.success) {
                Log.d(TAG, "Upload completed successfully: ${uploadResult.url}")
                Result.success(outputData)
            } else {
                Log.e(TAG, "Upload failed: ${uploadResult.error}")
                Result.failure(workDataOf(KEY_ERROR to uploadResult.error))
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Upload failed", e)
            Result.failure(workDataOf(KEY_ERROR to e.message))
        }
    }
    
    private suspend fun uploadProcessedData(data: String, filePath: String?): UploadResult {
        return try {
            // Simulate upload process with progress updates
            val uploadSteps = listOf(
                "Preparing upload",
                "Connecting to server",
                "Uploading data",
                "Verifying upload",
                "Cleaning up"
            )
            
            uploadSteps.forEachIndexed { index, step ->
                if (isStopped) {
                    return UploadResult(false, "", "Upload cancelled", 0)
                }
                
                Log.d(TAG, "Upload step ${index + 1}: $step")
                delay(800) // Simulate upload time
                
                val progress = ((index + 1) * 100 / uploadSteps.size)
                setProgress(workDataOf(KEY_PROGRESS to progress))
            }
            
            // Simulate API call to upload server
            val uploadUrl = simulateUploadToServer(data)
            val fileSize = filePath?.let { File(it).length() } ?: data.length.toLong()
            
            UploadResult(
                success = true,
                url = uploadUrl,
                error = null,
                fileSize = fileSize
            )
            
        } catch (e: Exception) {
            UploadResult(
                success = false,
                url = "",
                error = e.message ?: "Unknown upload error",
                fileSize = 0
            )
        }
    }
    
    private suspend fun simulateUploadToServer(data: String): String {
        // Simulate network delay
        delay(1500)
        
        // Return mock upload URL
        val uploadId = System.currentTimeMillis().toString()
        return "https://storage.example.com/uploads/$uploadId"
    }
    
    data class UploadResult(
        val success: Boolean,
        val url: String,
        val error: String?,
        val fileSize: Long
    )
    
    companion object {
        private const val TAG = "UploadWorker"
        
        const val KEY_UPLOAD_RESULT = "upload_result"
        const val KEY_UPLOAD_URL = "upload_url"
        const val KEY_UPLOAD_TIMESTAMP = "upload_timestamp"
        const val KEY_FILE_SIZE = "file_size"
        const val KEY_PROGRESS = "progress"
        const val KEY_ERROR = "error"
    }
}

// DownloadWorker implementation (to complete the chain)
class DownloadWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        return try {
            val downloadUrl = inputData.getString(KEY_DOWNLOAD_URL) ?: "https://api.example.com/data"
            
            Log.d(TAG, "Starting download from: $downloadUrl")
            
            // Update progress
            setProgress(workDataOf(KEY_PROGRESS to 0))
            
            val downloadedData = downloadFromUrl(downloadUrl)
            val downloadPath = saveDownloadedData(downloadedData)
            
            // Set output data for ProcessWorker
            val outputData = workDataOf(
                ProcessWorker.KEY_DOWNLOADED_DATA to downloadedData,
                ProcessWorker.KEY_DOWNLOAD_PATH to downloadPath,
                KEY_DOWNLOAD_TIMESTAMP to System.currentTimeMillis()
            )
            
            Log.d(TAG, "Download completed: $downloadPath")
            Result.success(outputData)
            
        } catch (e: Exception) {
            Log.e(TAG, "Download failed", e)
            Result.failure(workDataOf(KEY_ERROR to e.message))
        }
    }
    
    private suspend fun downloadFromUrl(url: String): String {
        // Simulate download with progress updates
        for (i in 1..5) {
            if (isStopped) {
                throw InterruptedException("Download cancelled")
            }
            
            delay(1000) // Simulate network request
            setProgress(workDataOf(KEY_PROGRESS to i * 20))
        }
        
        // Return simulated downloaded data
        return "Downloaded data from $url at ${System.currentTimeMillis()}"
    }
    
    private suspend fun saveDownloadedData(data: String): String {
        val fileName = "downloaded_data_${System.currentTimeMillis()}.txt"
        val file = File(applicationContext.cacheDir, fileName)
        
        withContext(Dispatchers.IO) {
            file.writeText(data)
        }
        
        return file.absolutePath
    }
    
    companion object {
        private const val TAG = "DownloadWorker"
        
        const val KEY_DOWNLOAD_URL = "download_url"
        const val KEY_DOWNLOAD_TIMESTAMP = "download_timestamp"
        const val KEY_PROGRESS = "progress"
        const val KEY_ERROR = "error"
    }
}

// Enhanced DataSyncManager with complete chained work implementation
class DataSyncManager(private val context: Context) {
    
    // ... existing methods ...
    
    fun scheduleChainedWorkWithData(downloadUrl: String) {
        val downloadWork = OneTimeWorkRequestBuilder<DownloadWorker>()
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build()
            )
            .setInputData(workDataOf(DownloadWorker.KEY_DOWNLOAD_URL to downloadUrl))
            .addTag("chained_work")
            .build()
        
        val processWork = OneTimeWorkRequestBuilder<ProcessWorker>()
            .addTag("chained_work")
            .build()

        val uploadWork = OneTimeWorkRequestBuilder<UploadWorker>()
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build()
            )
            .addTag("chained_work")
            .build()
        
        // Chain work requests and observe the entire chain
        val chainOperation = WorkManager.getInstance(context)
            .beginWith(downloadWork)
            .then(processWork)
            .then(uploadWork)
        
        chainOperation.enqueue()
        
        // Observe the final work in the chain
        WorkManager.getInstance(context)
            .getWorkInfoByIdLiveData(uploadWork.id)
            .observe(context as LifecycleOwner) { workInfo ->
                handleChainedWorkCompletion(workInfo)
            }
    }
    
    private fun handleChainedWorkCompletion(workInfo: WorkInfo?) {
        when (workInfo?.state) {
            WorkInfo.State.SUCCEEDED -> {
                val uploadUrl = workInfo.outputData.getString(UploadWorker.KEY_UPLOAD_URL)
                val fileSize = workInfo.outputData.getLong(UploadWorker.KEY_FILE_SIZE, 0)
                Log.d("DataSyncManager", "Chained work completed successfully!")
                Log.d("DataSyncManager", "Upload URL: $uploadUrl, File size: $fileSize bytes")
            }
            WorkInfo.State.FAILED -> {
                val error = workInfo.outputData.getString(UploadWorker.KEY_ERROR)
                Log.e("DataSyncManager", "Chained work failed: $error")
            }
            WorkInfo.State.CANCELLED -> {
                Log.d("DataSyncManager", "Chained work cancelled")
            }
            else -> {
                Log.d("DataSyncManager", "Chained work state: ${workInfo?.state}")
            }
        }
    }
    
    fun cancelChainedWork() {
        WorkManager.getInstance(context).cancelAllWorkByTag("chained_work")
    }
    
    fun observeChainedWorkProgress(): LiveData<List<WorkInfo>> {
        return WorkManager.getInstance(context).getWorkInfosByTagLiveData("chained_work")
    }
}
```

### Advanced WorkManager Features

WorkManager supports complex scheduling scenarios with expedited work, work chaining, and custom constraints.

```kotlin
class ExpeditiousWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        // Set foreground for expedited work on Android 12+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            setForeground(createForegroundInfo())
        }
        
        return try {
            val urgentTask = inputData.getString(KEY_URGENT_TASK)
            performUrgentTask(urgentTask)
            Result.success()
        } catch (e: Exception) {
            Result.failure(workDataOf(KEY_ERROR to e.message))
        }
    }
    
    private fun createForegroundInfo(): ForegroundInfo {
        val notification = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
            .setContentTitle("Processing urgent task")
            .setSmallIcon(R.drawable.ic_work)
            .setOngoing(true)
            .build()
        
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ForegroundInfo(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
        } else {
            ForegroundInfo(NOTIFICATION_ID, notification)
        }
    }
    
    private suspend fun performUrgentTask(task: String?) {
        when (task) {
            "emergency_backup" -> performEmergencyBackup()
            "critical_update" -> performCriticalUpdate()
            "security_scan" -> performSecurityScan()
        }
    }
    
    private suspend fun performEmergencyBackup() {
        // Implementation for emergency backup
        delay(5000)
    }
    
    private suspend fun performCriticalUpdate() {
        // Implementation for critical update
        delay(3000)
    }
    
    private suspend fun performSecurityScan() {
        // Implementation for security scan
        delay(7000)
    }
    
    companion object {
        const val KEY_URGENT_TASK = "urgent_task"
        const val KEY_ERROR = "error"
        private const val CHANNEL_ID = "urgent_work_channel"
        private const val NOTIFICATION_ID = 2001
    }
}

// Custom constraint implementation
class CustomConstraintWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        // Check custom business logic constraints
        if (!isCustomConditionMet()) {
            return Result.retry()
        }
        
        return try {
            performConditionalWork()
            Result.success()
        } catch (e: Exception) {
            Result.failure()
        }
    }
    
    private fun isCustomConditionMet(): Boolean {
        // Check device storage space
        val availableSpace = getAvailableStorageSpace()
        if (availableSpace < MINIMUM_STORAGE_MB) {
            return false
        }
        
        // Check time-based constraints
        val currentHour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
        if (currentHour in 22..6) { // Night hours
            return false
        }
        
        // Check app-specific conditions
        val sharedPrefs = applicationContext.getSharedPreferences("work_prefs", Context.MODE_PRIVATE)
        val lastExecution = sharedPrefs.getLong("last_execution", 0)
        val minimumInterval = 24 * 60 * 60 * 1000 // 24 hours
        
        return System.currentTimeMillis() - lastExecution > minimumInterval
    }
    
    private fun getAvailableStorageSpace(): Long {
        val stat = StatFs(applicationContext.filesDir.path)
        return stat.availableBytes / (1024 * 1024) // Convert to MB
    }
    
    private suspend fun performConditionalWork() {
        // Update last execution timestamp
        val sharedPrefs = applicationContext.getSharedPreferences("work_prefs", Context.MODE_PRIVATE)
        sharedPrefs.edit()
            .putLong("last_execution", System.currentTimeMillis())
            .apply()
        
        // Perform the actual work
        delay(2000)
    }
    
    companion object {
        private const val MINIMUM_STORAGE_MB = 100L
    }
}

// WorkManager with custom constraints usage
class AdvancedWorkManager(private val context: Context) {
    
    fun scheduleExpeditedWork(urgentTask: String) {
        val expeditedRequest = OneTimeWorkRequestBuilder<ExpeditiousWorker>()
            .setInputData(workDataOf(ExpeditiousWorker.KEY_URGENT_TASK to urgentTask))
            .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
            .build()
        
        WorkManager.getInstance(context).enqueue(expeditedRequest)
    }
    
    fun scheduleConditionalWork() {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.UNMETERED) // WiFi only
            .setRequiresDeviceIdle(true) // Device must be idle
            .setRequiresStorageNotLow(true) // Sufficient storage
            .build()
        
        val conditionalRequest = PeriodicWorkRequestBuilder<CustomConstraintWorker>(
            6, TimeUnit.HOURS
        )
            .setConstraints(constraints)
            .setBackoffCriteria(
                BackoffPolicy.LINEAR,
                PeriodicWorkRequest.MIN_BACKOFF_DELAY_MILLIS,
                TimeUnit.MILLISECONDS
            )
            .build()
        
        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            "conditional_work",
            ExistingPeriodicWorkPolicy.KEEP,
            conditionalRequest
        )
    }
    
    fun scheduleComplexChain() {
        // Create parallel work branches
        val downloadBranch1 = OneTimeWorkRequestBuilder<DownloadWorker>()
            .setInputData(workDataOf("url" to "https://api.example.com/data1"))
            .build()
        
        val downloadBranch2 = OneTimeWorkRequestBuilder<DownloadWorker>()
            .setInputData(workDataOf("url" to "https://api.example.com/data2"))
            .build()
        
        // Merge results
        val mergeWork = OneTimeWorkRequestBuilder<MergeWorker>()
            .build()
        
        // Final processing
        val finalWork = OneTimeWorkRequestBuilder<FinalProcessorWorker>()
            .build()
        
        // Execute complex chain
        WorkManager.getInstance(context)
            .beginWith(listOf(downloadBranch1, downloadBranch2))
            .then(mergeWork)
            .then(finalWork)
            .enqueue()
    }
}

// Specialized workers for different purposes
class DownloadWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        val url = inputData.getString("url") ?: return Result.failure()
        
        return try {
            val downloadedData = downloadData(url)
            val outputData = workDataOf("downloaded_data" to downloadedData)
            Result.success(outputData)
        } catch (e: Exception) {
            Result.retry()
        }
    }
    
    private suspend fun downloadData(url: String): String {
        // Simulate download
        delay(2000)
        return "Downloaded data from $url"
    }
}

class MergeWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        val data1 = inputData.getString("downloaded_data")
        // Note: In real implementation, you'd access multiple input data sources
        
        return try {
            val mergedData = mergeData(listOf(data1 ?: ""))
            val outputData = workDataOf("merged_data" to mergedData)
            Result.success(outputData)
        } catch (e: Exception) {
            Result.failure()
        }
    }
    
    private suspend fun mergeData(dataList: List<String>): String {
        delay(1000)
        return dataList.joinToString(" | ")
    }
}

class FinalProcessorWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        val mergedData = inputData.getString("merged_data")
        
        return try {
            processAndStore(mergedData ?: "")
            Result.success()
        } catch (e: Exception) {
            Result.failure()
        }
    }
    
    private suspend fun processAndStore(data: String) {
        // Final processing and storage
        delay(1000)
        
        // Store in database or file system
        val sharedPrefs = applicationContext.getSharedPreferences("processed_data", Context.MODE_PRIVATE)
        sharedPrefs.edit()
            .putString("final_result", data)
            .putLong("processing_timestamp", System.currentTimeMillis())
            .apply()
    }
}
```

### WorkManager Testing and Debugging

Proper testing ensures WorkManager implementations function correctly across different scenarios.

```kotlin
// Test implementation for WorkManager
@RunWith(AndroidJUnit4::class)
class SyncWorkerTest {
    
    @get:Rule
    val instantTaskExecutorRule = InstantTaskExecutorRule()
    
    private lateinit var context: Context
    private lateinit var workManager: WorkManager
    
    @Before
    fun setup() {
        context = ApplicationProvider.getApplicationContext()
        
        // Initialize WorkManager for testing
        val config = Configuration.Builder()
            .setMinimumLoggingLevel(Log.DEBUG)
            .setExecutor(SynchronousExecutor())
            .build()
        
        WorkManagerTestInitHelper.initializeTestWorkManager(context, config)
        workManager = WorkManager.getInstance(context)
    }
    
    @Test
    fun testSyncWorkerSuccess() = runBlocking {
        // Create test input data
        val inputData = workDataOf(SyncWorker.KEY_SYNC_TYPE to "user_data")
        
        // Create work request
        val request = OneTimeWorkRequestBuilder<SyncWorker>()
            .setInputData(inputData)
            .build()
        
        // Enqueue and wait for result
        workManager.enqueue(request).result.get()
        
        // Get work info
        val workInfo = workManager.getWorkInfoById(request.id).get()
        
        // Verify work completed successfully
        assertThat(workInfo.state, `is`(WorkInfo.State.SUCCEEDED))
        
        // Verify output data
        val outputData = workInfo.outputData
        assertThat(outputData.getString(SyncWorker.KEY_SYNC_RESULT), `is`("Success"))
        assertTrue(outputData.getLong(SyncWorker.KEY_SYNC_TIMESTAMP, 0) > 0)
    }
    
    @Test
    fun testSyncWorkerRetry() = runBlocking {
        // Test retry mechanism by simulating network failure
        val inputData = workDataOf(
            SyncWorker.KEY_SYNC_TYPE to "network_failure_simulation",
            SyncWorker.KEY_RETRY_COUNT to 1
        )
        
        val request = OneTimeWorkRequestBuilder<SyncWorker>()
            .setInputData(inputData)
            .build()
        
        workManager.enqueue(request).result.get()
        val workInfo = workManager.getWorkInfoById(request.id).get()
        
        // Verify work is retried
        assertThat(workInfo.state, `is`(WorkInfo.State.FAILED))
    }
    
    @Test
    fun testPeriodicWorkConstraints() {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .setRequiresBatteryNotLow(true)
            .build()
        
        val periodicRequest = PeriodicWorkRequestBuilder<SyncWorker>(15, TimeUnit.MINUTES)
            .setConstraints(constraints)
            .build()
        
        workManager.enqueue(periodicRequest)
        
        val workInfo = workManager.getWorkInfoById(periodicRequest.id).get()
        assertThat(workInfo.constraints.requiredNetworkType, `is`(NetworkType.CONNECTED))
        assertTrue(workInfo.constraints.requiresBatteryNotLow())
    }
}

// Debug utilities for WorkManager
class WorkManagerDebugUtils {
    
    companion object {
        fun logAllWorkInfo(context: Context) {
            WorkManager.getInstance(context)
                .getWorkInfos(WorkQuery.Builder.fromStates(WorkInfo.State.values().toList()).build())
                .let { future ->
                    try {
                        val workInfoList = future.get()
                        workInfoList.forEach { workInfo ->
                            Log.d("WorkManager", """
                                ID: ${workInfo.id}
                                State: ${workInfo.state}
                                Tags: ${workInfo.tags}
                                Progress: ${workInfo.progress}
                                Output: ${workInfo.outputData}
                                Run Attempt: ${workInfo.runAttemptCount}
                            """.trimIndent())
                        }
                    } catch (e: Exception) {
                        Log.e("WorkManager", "Error getting work info", e)
                    }
                }
        }
        
        fun cancelAllWork(context: Context) {
            WorkManager.getInstance(context).cancelAllWork()
            Log.d("WorkManager", "All work cancelled")
        }
        
        fun pruneCompletedWork(context: Context) {
            WorkManager.getInstance(context).pruneWork()
            Log.d("WorkManager", "Completed work pruned")
        }
    }
}
```

**Services and background processing in Android development require careful consideration of system constraints, battery optimization, and user experience. Modern Android development favors WorkManager for most background tasks due to its reliability and system integration, while traditional services remain important for specific use cases like music playback and real-time communication. Understanding when to use each approach ensures applications perform efficiently while respecting Android's background execution limits.**

Important related topics include: JobScheduler integration for system-level scheduling, Firebase Cloud Messaging for push-triggered background tasks, and Doze mode optimization strategies for maintaining functionality during device sleep states.

---

