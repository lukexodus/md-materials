## Bound and Started Services


Bound services provide client-server interfaces that allow components to interact with the service, send requests, receive results, and perform interprocess communication.

### Local Bound Service Implementation

Local bound services use Binder objects to provide direct method access within the same process.

```kotlin
class LocalBoundService : Service() {
    
    private val binder = LocalBinder()
    private var isServiceRunning = false
    private val serviceData = mutableListOf<String>()
    
    inner class LocalBinder : Binder() {
        fun getService(): LocalBoundService = this@LocalBoundService
    }
    
    override fun onBind(intent: Intent?): IBinder {
        Log.d("LocalBoundService", "Service bound")
        return binder
    }
    
    override fun onUnbind(intent: Intent?): Boolean {
        Log.d("LocalBoundService", "Service unbound")
        return true // Allow rebinding
    }
    
    override fun onRebind(intent: Intent?) {
        Log.d("LocalBoundService", "Service rebound")
        super.onRebind(intent)
    }
    
    // Public methods accessible to bound clients
    fun startOperation(): Boolean {
        return if (!isServiceRunning) {
            isServiceRunning = true
            performBackgroundOperation()
            true
        } else {
            false
        }
    }
    
    fun stopOperation() {
        isServiceRunning = false
    }
    
    fun getServiceData(): List<String> = serviceData.toList()
    
    fun addData(data: String) {
        serviceData.add("${System.currentTimeMillis()}: $data")
    }
    
    private fun performBackgroundOperation() {
        Thread {
            var counter = 0
            while (isServiceRunning && counter < 10) {
                addData("Background operation step ${counter + 1}")
                Thread.sleep(1000)
                counter++
            }
            isServiceRunning = false
        }.start()
    }
}

// Client Activity implementation
class MainActivity : AppCompatActivity() {
    
    private var boundService: LocalBoundService? = null
    private var isServiceBound = false
    
    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as LocalBoundService.LocalBinder
            boundService = binder.getService()
            isServiceBound = true
            Log.d("MainActivity", "Service connected")
        }
        
        override fun onServiceDisconnected(name: ComponentName?) {
            boundService = null
            isServiceBound = false
            Log.d("MainActivity", "Service disconnected")
        }
    }
    
    override fun onStart() {
        super.onStart()
        val intent = Intent(this, LocalBoundService::class.java)
        bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
    }
    
    override fun onStop() {
        super.onStop()
        if (isServiceBound) {
            unbindService(serviceConnection)
            isServiceBound = false
        }
    }
    
    private fun interactWithService() {
        boundService?.let { service ->
            service.startOperation()
            service.addData("Data from activity")
            val data = service.getServiceData()
            Log.d("MainActivity", "Service data: $data")
        }
    }
}
```

### AIDL Interface for Remote Services

Android Interface Definition Language (AIDL) enables communication between different processes.

```kotlin
// IRemoteService.aidl
interface IRemoteService {
    int performCalculation(int a, int b);
    String getServiceInfo();
    void registerCallback(IRemoteServiceCallback callback);
    void unregisterCallback(IRemoteServiceCallback callback);
}

// IRemoteServiceCallback.aidl
interface IRemoteServiceCallback {
    void onCalculationComplete(int result);
    void onServiceStatusChanged(String status);
}

// Remote service implementation
class RemoteService : Service() {
    
    private val callbacks = mutableListOf<IRemoteServiceCallback>()
    
    private val binder = object : IRemoteService.Stub() {
        override fun performCalculation(a: Int, b: Int): Int {
            val result = a + b
            notifyCallbacks { it.onCalculationComplete(result) }
            return result
        }
        
        override fun getServiceInfo(): String {
            return "Remote Service v1.0 - Process: ${android.os.Process.myPid()}"
        }
        
        override fun registerCallback(callback: IRemoteServiceCallback?) {
            callback?.let { callbacks.add(it) }
        }
        
        override fun unregisterCallback(callback: IRemoteServiceCallback?) {
            callback?.let { callbacks.remove(it) }
        }
    }
    
    override fun onBind(intent: Intent?): IBinder {
        return binder
    }
    
    private fun notifyCallbacks(action: (IRemoteServiceCallback) -> Unit) {
        callbacks.forEach { callback ->
            try {
                action(callback)
            } catch (e: RemoteException) {
                Log.e("RemoteService", "Callback failed", e)
                callbacks.remove(callback)
            }
        }
    }
}
```

