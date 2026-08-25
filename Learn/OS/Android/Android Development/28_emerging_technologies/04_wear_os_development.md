## Wear OS Development


Wear OS development focuses on creating applications optimized for wearable devices with considerations for limited screen space, battery efficiency, and gesture-based interactions. The platform provides specialized APIs for complications, tiles, health sensors, and communication with paired mobile devices.

**Key Points**
Wear OS applications can run independently or as companions to mobile apps, supporting offline functionality and cloud synchronization. The platform provides watch faces, complications for glanceable information, tiles for quick actions, and health/fitness APIs for sensor data access. Communication between watch and phone occurs through the Wearable Data Layer API.

**Watch Face Development**
Custom watch faces provide personalized time display with interactive complications and ambient mode support. Watch faces must handle both active and ambient modes, managing power consumption while maintaining time accuracy and complication updates.

```kotlin
// Watch Face Service
class CustomWatchFace : CanvasWatchFaceService() {
    
    override fun onCreateEngine(): Engine = CustomWatchFaceEngine()
    
    private inner class CustomWatchFaceEngine : CanvasWatchFaceService.Engine() {
        private lateinit var calendar: Calendar
        private lateinit var paint: Paint
        private var muteMode = false
        private var centerX = 0f
        private var centerY = 0f
        
        override fun onCreate(holder: SurfaceHolder) {
            super.onCreate(holder)
            
            setWatchFaceStyle(
                WatchFaceStyle.Builder(this@CustomWatchFace)
                    .setAcceptsTapEvents(true)
                    .setHideNotificationIndicator(false)
                    .build()
            )
            
            calendar = Calendar.getInstance()
            initializePaint()
        }
        
        override fun onDraw(canvas: Canvas, bounds: Rect) {
            val now = System.currentTimeMillis()
            calendar.timeInMillis = now
            
            drawBackground(canvas)
            drawWatchHands(canvas, bounds)
            drawComplications(canvas, now)
        }
        
        override fun onAmbientModeChanged(inAmbientMode: Boolean) {
            super.onAmbientModeChanged(inAmbientMode)
            
            if (inAmbientMode) {
                paint.isAntiAlias = false
                paint.color = Color.WHITE
            } else {
                paint.isAntiAlias = true
                paint.color = Color.BLUE
            }
            
            invalidate()
        }
        
        override fun onTapCommand(tapType: Int, x: Int, y: Int, eventTime: Long) {
            when (tapType) {
                TAP_TYPE_TOUCH -> {
                    // Handle touch events
                }
                TAP_TYPE_TAP -> {
                    handleTap(x, y)
                }
            }
        }
    }
}
```

**Health and Fitness Integration**
Wear OS provides comprehensive health and fitness APIs including heart rate monitoring, step counting, workout tracking, and integration with Google Fit. Applications can access real-time sensor data and historical fitness information while managing battery consumption.

```kotlin
// Health Sensors Manager
class HealthSensorsManager(private val context: Context) {
    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val heartRateSensor = sensorManager.getDefaultSensor(Sensor.TYPE_HEART_RATE)
    private val stepCountSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
    
    private val sensorEventListener = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent) {
            when (event.sensor.type) {
                Sensor.TYPE_HEART_RATE -> {
                    val heartRate = event.values[0].toInt()
                    onHeartRateChanged(heartRate)
                }
                Sensor.TYPE_STEP_COUNTER -> {
                    val stepCount = event.values[0].toInt()
                    onStepCountChanged(stepCount)
                }
            }
        }
        
        override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {
            handleAccuracyChange(sensor, accuracy)
        }
    }
    
    fun startMonitoring() {
        heartRateSensor?.let { sensor ->
            sensorManager.registerListener(
                sensorEventListener,
                sensor,
                SensorManager.SENSOR_DELAY_NORMAL
            )
        }
        
        stepCountSensor?.let { sensor ->
            sensorManager.registerListener(
                sensorEventListener,
                sensor,
                SensorManager.SENSOR_DELAY_UI
            )
        }
    }
    
    fun recordWorkout(activityType: Int) {
        val client = Fitness.getRecordingClient(context, GoogleSignIn.getLastSignedInAccount(context)!!)
        
        client.subscribe(DataType.TYPE_HEART_RATE_BPM)
            .addOnSuccessListener {
                startWorkoutRecording(activityType)
            }
            .addOnFailureListener { exception ->
                handleSubscriptionError(exception)
            }
    }
}
```

