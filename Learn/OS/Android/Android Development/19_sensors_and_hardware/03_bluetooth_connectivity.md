## Bluetooth Connectivity


Bluetooth enables short-range wireless communication for device pairing, data transfer, and IoT device integration.

### Bluetooth Classic Implementation

**Setup and Permissions:**

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

<!-- Android 12+ permissions -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
```

**Bluetooth Manager:**

```kotlin
class BluetoothManager(private val context: Context) {
    private val bluetoothAdapter: BluetoothAdapter? by lazy {
        val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as android.bluetooth.BluetoothManager
        bluetoothManager.adapter
    }
    
    private val discoveredDevices = mutableListOf<BluetoothDevice>()
    
    private val bluetoothReceiver = object : BroadcastReceiver() {
        @SuppressLint("MissingPermission")
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                BluetoothDevice.ACTION_FOUND -> {
                    val device: BluetoothDevice? = 
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    device?.let { bluetoothDevice ->
                        if (!discoveredDevices.contains(bluetoothDevice)) {
                            discoveredDevices.add(bluetoothDevice)
                            onDeviceDiscovered(bluetoothDevice)
                        }
                    }
                }
                BluetoothAdapter.ACTION_DISCOVERY_STARTED -> {
                    onDiscoveryStarted()
                }
                BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                    onDiscoveryFinished()
                }
                BluetoothDevice.ACTION_BOND_STATE_CHANGED -> {
                    val device: BluetoothDevice? = 
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    val bondState = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, -1)
                    handleBondStateChange(device, bondState)
                }
            }
        }
    }
    
    fun isBluetoothEnabled(): Boolean {
        return bluetoothAdapter?.isEnabled == true
    }
    
    fun enableBluetooth(activity: Activity) {
        if (bluetoothAdapter?.isEnabled == false) {
            val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            activity.startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT)
        }
    }
    
    @SuppressLint("MissingPermission")
    fun startDiscovery() {
        if (hasBluetoothPermissions()) {
            bluetoothAdapter?.let { adapter ->
                if (adapter.isDiscovering) {
                    adapter.cancelDiscovery()
                }
                adapter.startDiscovery()
                
                // Register receiver for discovery results
                val filter = IntentFilter().apply {
                    addAction(BluetoothDevice.ACTION_FOUND)
                    addAction(BluetoothAdapter.ACTION_DISCOVERY_STARTED)
                    addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
                }
                context.registerReceiver(bluetoothReceiver, filter)
            }
        }
    }
    
    @SuppressLint("MissingPermission")
    fun getPairedDevices(): Set<BluetoothDevice>? {
        return if (hasBluetoothPermissions()) {
            bluetoothAdapter?.bondedDevices
        } else {
            null
        }
    }
    
    @SuppressLint("MissingPermission")
    fun connectToDevice(device: BluetoothDevice, uuid: UUID): BluetoothSocket? {
        return try {
            if (hasBluetoothPermissions()) {
                bluetoothAdapter?.cancelDiscovery()
                device.createRfcommSocketToServiceRecord(uuid)
            } else {
                null
            }
        } catch (e: IOException) {
            null
        }
    }
    
    private fun hasBluetoothPermissions(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_CONNECT) == 
                PackageManager.PERMISSION_GRANTED
        } else {
            ContextCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH) == 
                PackageManager.PERMISSION_GRANTED
        }
    }
    
    companion object {
        const val REQUEST_ENABLE_BT = 1001
    }
}
```

### Bluetooth Low Energy (BLE) Implementation

**BLE Scanner and Connection:**

```kotlin
class BLEManager(private val context: Context) {
    private val bluetoothAdapter: BluetoothAdapter? by lazy {
        val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as android.bluetooth.BluetoothManager
        bluetoothManager.adapter
    }
    
    private val bleScanner: BluetoothLeScanner? by lazy {
        bluetoothAdapter?.bluetoothLeScanner
    }
    
    private var bluetoothGatt: BluetoothGatt? = null
    private val discoveredDevices = mutableListOf<BluetoothDevice>()
    
    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            result?.let { scanResult ->
                val device = scanResult.device
                val rssi = scanResult.rssi
                val scanRecord = scanResult.scanRecord
                
                if (!discoveredDevices.contains(device)) {
                    discoveredDevices.add(device)
                    onBLEDeviceFound(device, rssi, scanRecord)
                }
            }
        }
        
        override fun onBatchScanResults(results: MutableList<ScanResult>?) {
            results?.forEach { result ->
                onScanResult(ScanSettings.CALLBACK_TYPE_ALL_MATCHES, result)
            }
        }
        
        override fun onScanFailed(errorCode: Int) {
            onBLEScanFailed(errorCode)
        }
    }
    
    private val gattCallback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt?, status: Int, newState: Int) {
            when (newState) {
                BluetoothProfile.STATE_CONNECTED -> {
                    onBLEConnected(gatt)
                    gatt?.discoverServices()
                }
                BluetoothProfile.STATE_DISCONNECTED -> {
                    onBLEDisconnected(gatt)
                }
            }
        }
        
        override fun onServicesDiscovered(gatt: BluetoothGatt?, status: Int) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                onBLEServicesDiscovered(gatt)
            }
        }
        
        override fun onCharacteristicRead(
            gatt: BluetoothGatt?,
            characteristic: BluetoothGattCharacteristic?,
            status: Int
        ) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                characteristic?.value?.let { data ->
                    onBLECharacteristicRead(characteristic, data)
                }
            }
        }
        
        override fun onCharacteristicWrite(
            gatt: BluetoothGatt?,
            characteristic: BluetoothGattCharacteristic?,
            status: Int
        ) {
            onBLECharacteristicWrite(characteristic, status)
        }
        
        override fun onCharacteristicChanged(
            gatt: BluetoothGatt?,
            characteristic: BluetoothGattCharacteristic?
        ) {
            characteristic?.value?.let { data ->
                onBLECharacteristicChanged(characteristic, data)
            }
        }
    }
    
    @SuppressLint("MissingPermission")
    fun startBLEScan(scanSettings: ScanSettings? = null, scanFilters: List<ScanFilter>? = null) {
        if (hasBLEPermissions()) {
            val settings = scanSettings ?: ScanSettings.Builder()
                .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                .build()
            
            bleScanner?.startScan(scanFilters, settings, scanCallback)
        }
    }
    
    @SuppressLint("MissingPermission")
    fun stopBLEScan() {
        if (hasBLEPermissions()) {
            bleScanner?.stopScan(scanCallback)
        }
    }
    
    @SuppressLint("MissingPermission")
    fun connectToDevice(device: BluetoothDevice): Boolean {
        return if (hasBLEPermissions()) {
            bluetoothGatt = device.connectGatt(context, false, gattCallback)
            bluetoothGatt != null
        } else {
            false
        }
    }
    
    @SuppressLint("MissingPermission")
    fun writeCharacteristic(characteristic: BluetoothGattCharacteristic, data: ByteArray): Boolean {
        return if (hasBLEPermissions()) {
            characteristic.value = data
            bluetoothGatt?.writeCharacteristic(characteristic) == true
        } else {
            false
        }
    }
    
    private fun hasBLEPermissions(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_SCAN) == 
                PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_CONNECT) == 
                PackageManager.PERMISSION_GRANTED
        } else {
            ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == 
                PackageManager.PERMISSION_GRANTED
        }
    }
}
```

