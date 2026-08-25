## Accelerometer and Gyroscope


Accelerometer and gyroscope sensors provide motion and orientation data essential for gaming, fitness tracking, augmented reality, and navigation applications.

### Accelerometer

The accelerometer measures acceleration forces along three axes (X, Y, Z), including gravitational force, enabling detection of device orientation, shake gestures, and movement patterns.

**Sensor Characteristics:**

- **Range**: Typically ±2g to ±16g (g = 9.8 m/s²)
- **Resolution**: Usually 12-bit to 16-bit precision
- **Power Consumption**: Low to moderate depending on sampling rate
- **Coordinate System**: X-axis horizontal (right positive), Y-axis vertical (up positive), Z-axis perpendicular to screen (out positive)

**Implementation:**

```kotlin
class AccelerometerActivity : AppCompatActivity(), SensorEventListener {
    private lateinit var sensorManager: SensorManager
    private var accelerometer: Sensor? = null
    private var lastAccelerometerReading = FloatArray(3)
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        
        // Check sensor availability
        if (accelerometer == null) {
            // Handle device without accelerometer
            showNoSensorDialog()
        }
    }
    
    override fun onResume() {
        super.onResume()
        accelerometer?.also { sensor ->
            sensorManager.registerListener(
                this,
                sensor,
                SensorManager.SENSOR_DELAY_NORMAL
            )
        }
    }
    
    override fun onPause() {
        super.onPause()
        sensorManager.unregisterListener(this)
    }
    
    override fun onSensorChanged(event: SensorEvent?) {
        event?.let { sensorEvent ->
            if (sensorEvent.sensor.type == Sensor.TYPE_ACCELEROMETER) {
                val x = sensorEvent.values[0]
                val y = sensorEvent.values[1] 
                val z = sensorEvent.values[2]
                
                // Apply low-pass filter to reduce noise
                lastAccelerometerReading[0] = lowPass(x, lastAccelerometerReading[0])
                lastAccelerometerReading[1] = lowPass(y, lastAccelerometerReading[1])
                lastAccelerometerReading[2] = lowPass(z, lastAccelerometerReading[2])
                
                // Calculate total acceleration
                val totalAcceleration = sqrt(x*x + y*y + z*z)
                
                // Detect shake gesture
                if (totalAcceleration > 12.0f) {
                    onShakeDetected()
                }
                
                // Determine device orientation
                val orientation = calculateOrientation(x, y, z)
                updateUI(orientation, totalAcceleration)
            }
        }
    }
    
    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        when (accuracy) {
            SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> {
                // Sensor providing accurate readings
            }
            SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM -> {
                // Moderate accuracy
            }
            SensorManager.SENSOR_STATUS_ACCURACY_LOW -> {
                // Low accuracy, consider calibration
            }
            SensorManager.SENSOR_STATUS_UNRELIABLE -> {
                // Sensor readings unreliable
            }
        }
    }
    
    private fun lowPass(input: Float, output: Float): Float {
        val alpha = 0.8f
        return output + alpha * (input - output)
    }
    
    private fun calculateOrientation(x: Float, y: Float, z: Float): String {
        return when {
            abs(z) > abs(x) && abs(z) > abs(y) -> "Flat"
            abs(y) > abs(x) -> if (y > 0) "Portrait" else "Upside Down"
            else -> if (x > 0) "Landscape Right" else "Landscape Left"
        }
    }
}
```

### Gyroscope

The gyroscope measures angular velocity around three axes, providing rotation rate data for precise motion tracking and gesture recognition.

**Sensor Properties:**

- **Measurement**: Angular velocity in radians per second
- **Axes**: Rotation around X, Y, Z axes
- **Drift**: Accumulates over time, requiring periodic calibration
- **Precision**: High-resolution rotation detection

**Gyroscope Implementation:**

```kotlin
class GyroscopeActivity : AppCompatActivity(), SensorEventListener {
    private lateinit var sensorManager: SensorManager
    private var gyroscope: Sensor? = null
    private var rotationMatrix = FloatArray(9)
    private var orientation = FloatArray(3)
    private var timestamp: Long = 0
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        gyroscope = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE)
    }
    
    override fun onSensorChanged(event: SensorEvent?) {
        event?.let { sensorEvent ->
            if (sensorEvent.sensor.type == Sensor.TYPE_GYROSCOPE) {
                val deltaTime = if (timestamp != 0L) {
                    (sensorEvent.timestamp - timestamp) * 1.0e-9f
                } else {
                    0f
                }
                timestamp = sensorEvent.timestamp
                
                val axisX = sensorEvent.values[0]
                val axisY = sensorEvent.values[1]
                val axisZ = sensorEvent.values[2]
                
                // Calculate rotation angle
                val omegaMagnitude = sqrt(axisX*axisX + axisY*axisY + axisZ*axisZ)
                
                if (omegaMagnitude > 0.1f) { // Threshold to filter noise
                    // Normalize rotation axis
                    val normalizedX = axisX / omegaMagnitude
                    val normalizedY = axisY / omegaMagnitude
                    val normalizedZ = axisZ / omegaMagnitude
                    
                    // Calculate rotation angle
                    val rotationAngle = omegaMagnitude * deltaTime
                    
                    processRotation(normalizedX, normalizedY, normalizedZ, rotationAngle)
                }
            }
        }
    }
    
    private fun processRotation(x: Float, y: Float, z: Float, angle: Float) {
        // Process rotation data for application logic
        when {
            abs(x) > 2.0f -> handleXRotation(x)
            abs(y) > 2.0f -> handleYRotation(y)
            abs(z) > 2.0f -> handleZRotation(z)
        }
    }
}
```

### Combined Motion Detection

**Sensor Fusion:**

```kotlin
class MotionDetector : SensorEventListener {
    private var accelerometerData = FloatArray(3)
    private var gyroscopeData = FloatArray(3)
    private var magnetometerData = FloatArray(3)
    
    private val rotationMatrix = FloatArray(9)
    private val orientation = FloatArray(3)
    
    override fun onSensorChanged(event: SensorEvent?) {
        event?.let { sensorEvent ->
            when (sensorEvent.sensor.type) {
                Sensor.TYPE_ACCELEROMETER -> {
                    System.arraycopy(sensorEvent.values, 0, accelerometerData, 0, 3)
                }
                Sensor.TYPE_GYROSCOPE -> {
                    System.arraycopy(sensorEvent.values, 0, gyroscopeData, 0, 3)
                }
                Sensor.TYPE_MAGNETIC_FIELD -> {
                    System.arraycopy(sensorEvent.values, 0, magnetometerData, 0, 3)
                }
            }
            
            // Calculate device orientation using sensor fusion
            if (SensorManager.getRotationMatrix(rotationMatrix, null, accelerometerData, magnetometerData)) {
                SensorManager.getOrientation(rotationMatrix, orientation)
                
                val azimuth = Math.toDegrees(orientation[0].toDouble()).toFloat()
                val pitch = Math.toDegrees(orientation[1].toDouble()).toFloat()
                val roll = Math.toDegrees(orientation[2].toDouble()).toFloat()
                
                onOrientationChanged(azimuth, pitch, roll)
            }
        }
    }
    
    private fun onOrientationChanged(azimuth: Float, pitch: Float, roll: Float) {
        // Handle orientation changes
    }
}
```

