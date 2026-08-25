## Augmented Reality (ARCore)


ARCore enables augmented reality experiences on Android devices by providing motion tracking, environmental understanding, and light estimation capabilities. The platform uses visual-inertial odometry to track device position and orientation while mapping the physical environment.

**Key Points**
ARCore supports plane detection for horizontal and vertical surfaces, anchor placement for persistent AR objects, light estimation for realistic rendering, and cloud anchors for shared AR experiences across devices. The framework integrates with rendering engines like Sceneform, Unity, and Unreal Engine, supporting both Java and Kotlin development through native Android APIs.

**Core Components**
Session management handles ARCore initialization and configuration, providing access to camera images and device pose. Trackables represent detected features in the environment including planes, points, and anchors. Anchors maintain fixed positions in 3D space relative to the real world, enabling persistent placement of virtual objects across sessions.

```kotlin
// ARCore Session Setup
class ARActivity : AppCompatActivity() {
    private lateinit var arSession: Session
    private lateinit var surfaceView: GLSurfaceView
    private lateinit var renderer: ARRenderer
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        setupARSession()
        setupSurfaceView()
    }
    
    private fun setupARSession() {
        arSession = Session(this)
        val config = Config(arSession).apply {
            planeFindingMode = Config.PlaneFindingMode.HORIZONTAL_AND_VERTICAL
            lightEstimationMode = Config.LightEstimationMode.ENVIRONMENTAL_HDR
        }
        arSession.configure(config)
    }
    
    private fun setupSurfaceView() {
        renderer = ARRenderer(this, arSession)
        surfaceView = GLSurfaceView(this).apply {
            setEGLContextClientVersion(2)
            setRenderer(renderer)
            renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY
        }
        setContentView(surfaceView)
    }
    
    override fun onResume() {
        super.onResume()
        try {
            arSession.resume()
            surfaceView.onResume()
        } catch (e: CameraNotAvailableException) {
            handleCameraError(e)
        }
    }
}
```

**Plane Detection and Anchoring**
ARCore continuously scans for planes in the environment, providing normal vectors and polygon boundaries for detected surfaces. Anchors can be attached to planes or arbitrary points in 3D space, maintaining their position as the device moves and the understanding of the environment improves.

```kotlin
// Plane Detection and Anchor Placement
class PlaneDetectionHandler {
    fun handleTap(session: Session, camera: Camera, motionEvent: MotionEvent) {
        val hits = session.hitTest(motionEvent.x, motionEvent.y)
        
        for (hit in hits) {
            val trackable = hit.trackable
            
            if (trackable is Plane && trackable.isPoseInPolygon(hit.hitPose)) {
                val anchor = hit.createAnchor()
                placeObject(anchor)
                break
            }
        }
    }
    
    private fun placeObject(anchor: Anchor) {
        val anchorNode = AnchorNode(anchor)
        // Add 3D model or rendering node to anchor
        sceneView.scene.addChild(anchorNode)
    }
    
    fun updatePlanes(session: Session) {
        session.getAllTrackables(Plane::class.java).forEach { plane ->
            when (plane.trackingState) {
                TrackingState.TRACKING -> {
                    if (plane.subsumedBy == null) {
                        updatePlaneVisualization(plane)
                    }
                }
                TrackingState.PAUSED -> hidePlaneVisualization(plane)
                TrackingState.STOPPED -> removePlaneVisualization(plane)
            }
        }
    }
}
```

