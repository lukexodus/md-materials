## Internet of Things (IoT) Connectivity


Android applications can connect to IoT devices through multiple protocols including Wi-Fi, Bluetooth, NFC, and cellular connectivity. The platform provides comprehensive APIs for device discovery, pairing, data exchange, and network management across various IoT ecosystems.

**Key Points**
Android supports IoT connectivity through Bluetooth Low Energy (BLE) for battery-efficient communication, Wi-Fi Direct for peer-to-peer connections, NFC for proximity-based interactions, and network service discovery for local device detection. The Nearby Connections API enables cross-platform communication, while the Companion Device API simplifies pairing with wearables and IoT devices.

**Bluetooth Low Energy Implementation**
BLE provides energy-efficient communication for IoT devices with extended battery life requirements. Android's BLE APIs support both central and peripheral roles, enabling applications to scan for devices, establish connections, and exchange data through GATT services and characteristics.

```kotlin
// BLE Device Scanner
class BLEDeviceScanner(private val context: Context) {
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private val bleScanner = bluetoothAdapter?.bluetoothLeScanner
    private val scanResults = mutableListOf<ScanResult>()
    
    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            super.onScanResult(callbackType, result)
            
            if (!scanResults.any { it.device.address == result.device.address }) {
                scanResults.add(result)
                onDeviceDiscovered(result)
            }
        }
        
        override fun onScanFailed(errorCode: Int) {
            super.onScanFailed(errorCode)
            handleScanError(errorCode)
        }
    }
    
    fun startScanning() {
        val scanFilter = ScanFilter.Builder()
            .setServiceUuid(ParcelUuid.fromString(IoT_SERVICE_UUID))
            .build()
            
        val scanSettings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .setCallbackType(ScanSettings.CALLBACK_TYPE_ALL_MATCHES)
            .build()
            
        bleScanner?.startScan(listOf(scanFilter), scanSettings, scanCallback)
    }
    
    fun connectToDevice(device: BluetoothDevice) {
        val gattCallback = object : BluetoothGattCallback() {
            override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
                when (newState) {
                    BluetoothProfile.STATE_CONNECTED -> {
                        gatt.discoverServices()
                    }
                    BluetoothProfile.STATE_DISCONNECTED -> {
                        handleDisconnection(gatt)
                    }
                }
            }
            
            override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
                if (status == BluetoothGatt.GATT_SUCCESS) {
                    setupGattServices(gatt)
                }
            }
        }
        
        device.connectGatt(context, false, gattCallback)
    }
}
```

**Wi-Fi Direct and Network Service Discovery**
Wi-Fi Direct enables direct device-to-device communication without requiring an access point, suitable for high-bandwidth IoT applications. Network Service Discovery (NSD) allows applications to advertise and discover services on local networks using DNS-SD protocols.

```kotlin
// Network Service Discovery
class NetworkServiceDiscovery(private val context: Context) {
    private val nsdManager = context.getSystemService(Context.NSD_SERVICE) as NsdManager
    private var serviceInfo: NsdServiceInfo? = null
    
    private val discoveryListener = object : NsdManager.DiscoveryListener {
        override fun onStartDiscoveryFailed(serviceType: String, errorCode: Int) {
            handleDiscoveryError(errorCode)
        }
        
        override fun onStopDiscoveryFailed(serviceType: String, errorCode: Int) {
            handleDiscoveryError(errorCode)
        }
        
        override fun onDiscoveryStarted(serviceType: String) {
            // Discovery started successfully
        }
        
        override fun onDiscoveryStopped(serviceType: String) {
            // Discovery stopped
        }
        
        override fun onServiceFound(service: NsdServiceInfo) {
            resolveService(service)
        }
        
        override fun onServiceLost(service: NsdServiceInfo) {
            handleServiceLost(service)
        }
    }
    
    fun startDiscovery() {
        nsdManager.discoverServices("_iot._tcp", NsdManager.PROTOCOL_DNS_SD, discoveryListener)
    }
    
    private fun resolveService(service: NsdServiceInfo) {
        val resolveListener = object : NsdManager.ResolveListener {
            override fun onResolveFailed(serviceInfo: NsdServiceInfo, errorCode: Int) {
                handleResolveError(errorCode)
            }
            
            override fun onServiceResolved(serviceInfo: NsdServiceInfo) {
                this@NetworkServiceDiscovery.serviceInfo = serviceInfo
                connectToService(serviceInfo)
            }
        }
        
        nsdManager.resolveService(service, resolveListener)
    }
}
```

