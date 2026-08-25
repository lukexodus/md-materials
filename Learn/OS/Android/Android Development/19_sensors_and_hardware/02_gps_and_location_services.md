## GPS and Location Services


GPS and location services provide geographical positioning capabilities essential for navigation, location-based services, and geofencing applications.

### Location Providers

**Available Providers:**

- **GPS Provider**: Satellite-based positioning, high accuracy outdoors
- **Network Provider**: Cell tower and WiFi-based positioning, works indoors
- **Passive Provider**: Receives locations from other applications
- **Fused Location Provider**: Google Play Services optimized location API

### Fused Location Provider Implementation

**Setup and Permissions:**

```xml
<!-- Manifest permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

**Location Service Implementation:**

```kotlin
class LocationService : Service() {
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private lateinit var locationRequest: LocationRequest
    
    override fun onCreate() {
        super.onCreate()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        createLocationRequest()
        createLocationCallback()
    }
    
    private fun createLocationRequest() {
        locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 10000L)
            .setMinUpdateIntervalMillis(5000L)
            .setMinUpdateDistanceMeters(10f)
            .setMaxUpdateDelayMillis(15000L)
            .build()
    }
    
    private fun createLocationCallback() {
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                locationResult.locations.forEach { location ->
                    processLocationUpdate(location)
                }
            }
            
            override fun onLocationAvailability(locationAvailability: LocationAvailability) {
                if (!locationAvailability.isLocationAvailable) {
                    // Handle location unavailable
                    notifyLocationUnavailable()
                }
            }
        }
    }
    
    @SuppressLint("MissingPermission")
    private fun startLocationUpdates() {
        if (hasLocationPermissions()) {
            fusedLocationClient.requestLocationUpdates(
                locationRequest,
                locationCallback,
                Looper.getMainLooper()
            )
        } else {
            requestLocationPermissions()
        }
    }
    
    private fun processLocationUpdate(location: Location) {
        val latitude = location.latitude
        val longitude = location.longitude
        val accuracy = location.accuracy
        val altitude = location.altitude
        val bearing = location.bearing
        val speed = location.speed
        val timestamp = location.time
        
        // Create location data object
        val locationData = LocationData(
            latitude = latitude,
            longitude = longitude,
            accuracy = accuracy,
            altitude = altitude,
            bearing = bearing,
            speed = speed,
            timestamp = timestamp
        )
        
        // Process location update
        handleLocationUpdate(locationData)
        
        // Check geofences
        checkGeofences(location)
    }
    
    private fun hasLocationPermissions(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
}

data class LocationData(
    val latitude: Double,
    val longitude: Double,
    val accuracy: Float,
    val altitude: Double,
    val bearing: Float,
    val speed: Float,
    val timestamp: Long
)
```

### Geofencing Implementation

**Geofence Setup:**

```kotlin
class GeofencingManager(private val context: Context) {
    private lateinit var geofencingClient: GeofencingClient
    private lateinit var geofenceList: MutableList<Geofence>
    
    init {
        geofencingClient = LocationServices.getGeofencingClient(context)
        geofenceList = mutableListOf()
    }
    
    fun createGeofence(
        requestId: String,
        latitude: Double,
        longitude: Double,
        radius: Float,
        transitionTypes: Int = Geofence.GEOFENCE_TRANSITION_ENTER or Geofence.GEOFENCE_TRANSITION_EXIT
    ): Geofence {
        return Geofence.Builder()
            .setRequestId(requestId)
            .setCircularRegion(latitude, longitude, radius)
            .setTransitionTypes(transitionTypes)
            .setExpirationDuration(Geofence.NEVER_EXPIRE)
            .setLoiteringDelay(30000) // 30 seconds
            .build()
    }
    
    @SuppressLint("MissingPermission")
    fun addGeofences(geofences: List<Geofence>) {
        val geofencingRequest = GeofencingRequest.Builder()
            .setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER)
            .addGeofences(geofences)
            .build()
        
        geofencingClient.addGeofences(geofencingRequest, geofencePendingIntent)
            .addOnSuccessListener {
                // Geofences added successfully
            }
            .addOnFailureListener { exception ->
                // Handle geofence addition failure
                handleGeofenceError(exception)
            }
    }
    
    private val geofencePendingIntent: PendingIntent by lazy {
        val intent = Intent(context, GeofenceBroadcastReceiver::class.java)
        PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}

class GeofenceBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val geofencingEvent = GeofencingEvent.fromIntent(intent ?: return)
        
        if (geofencingEvent?.hasError() == true) {
            val errorMessage = GeofenceStatusCodes.getStatusCodeString(geofencingEvent.errorCode)
            return
        }
        
        val geofenceTransition = geofencingEvent?.geofenceTransition
        
        when (geofenceTransition) {
            Geofence.GEOFENCE_TRANSITION_ENTER -> {
                val triggeringGeofences = geofencingEvent.triggeringGeofences
                handleGeofenceEnter(context, triggeringGeofences)
            }
            Geofence.GEOFENCE_TRANSITION_EXIT -> {
                val triggeringGeofences = geofencingEvent.triggeringGeofences
                handleGeofenceExit(context, triggeringGeofences)
            }
            Geofence.GEOFENCE_TRANSITION_DWELL -> {
                // Handle dwelling in geofence
            }
        }
    }
}
```

