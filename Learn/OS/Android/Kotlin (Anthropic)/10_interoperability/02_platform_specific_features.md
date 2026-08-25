## Platform-Specific Features


### JVM-Specific Features

Kotlin on the JVM provides seamless interoperability with existing Java code while adding powerful language features that leverage JVM capabilities.

#### Java Interoperability

Kotlin can call Java code directly without any wrapper or conversion layer. Java classes, methods, and fields are accessible using standard Kotlin syntax. When calling Java methods that can return null, Kotlin treats the return type as nullable unless annotated with nullability annotations.

```kotlin
// Calling Java code from Kotlin
val list = ArrayList<String>()
list.add("Hello")
val calendar = Calendar.getInstance()
val date = calendar.time
```

Kotlin properties are accessible from Java as getter/setter methods following JavaBean conventions. The `@JvmName` annotation allows customizing the generated method names, while `@JvmStatic` makes companion object members accessible as static methods in Java.

```kotlin
class KotlinClass {
    @JvmName("getSpecialName")
    val property: String = "value"
    
    companion object {
        @JvmStatic
        fun staticMethod() = "static"
    }
}
```

#### JVM Annotations and Reflection

Kotlin provides JVM-specific annotations to control bytecode generation and Java interoperability. The `@JvmField` annotation exposes a property as a public field in bytecode, while `@JvmOverloads` generates overloaded methods for functions with default parameters.

```kotlin
class Example {
    @JvmField
    val publicField = "accessible from Java"
    
    @JvmOverloads
    fun method(param1: String, param2: Int = 0) {
        // Generates multiple Java methods
    }
}
```

Kotlin's reflection API on the JVM provides runtime introspection capabilities. The `::class` syntax gives access to KClass objects, while `::` can create callable references to functions and properties.

```kotlin
val kClass = String::class
val members = kClass.members
val function = ::println
val property = Person::name
```

#### Threading and Concurrency

On the JVM, Kotlin coroutines are implemented using thread pools and continuation-passing style. The default dispatchers map to different thread pools: `Dispatchers.Default` uses a shared thread pool for CPU-intensive work, `Dispatchers.IO` uses a larger pool for I/O operations, and `Dispatchers.Main` integrates with UI frameworks.

```kotlin
// JVM-specific thread pool configuration
val customDispatcher = Executors.newFixedThreadPool(4).asCoroutineDispatcher()

launch(customDispatcher) {
    // Work on custom thread pool
}
```

#### Bytecode Generation and Optimization

Kotlin generates efficient JVM bytecode that's often equivalent to hand-written Java. Inline functions are expanded at call sites, eliminating function call overhead. The `@JvmInline` annotation creates value classes that are erased at runtime when possible.

```kotlin
@JvmInline
value class UserId(val id: String)

inline fun <T> measureTime(block: () -> T): T {
    val start = System.nanoTime()
    return block().also {
        println("Time: ${System.nanoTime() - start}ns")
    }
}
```

### Android-Specific Considerations

Android development with Kotlin involves platform-specific APIs, lifecycle management, and performance considerations unique to mobile environments.

#### Android Extensions and View Binding

While Android synthetic properties are deprecated, View Binding provides type-safe access to views. The binding classes are generated automatically and provide direct references to views without findViewById calls.

```kotlin
class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        binding.textView.text = "Hello World"
    }
}
```

#### Coroutines and Android Lifecycle

Android provides lifecycle-aware coroutine scopes that automatically cancel when the lifecycle owner is destroyed. `lifecycleScope` and `viewModelScope` prevent memory leaks and ensure proper cleanup.

```kotlin
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        lifecycleScope.launch {
            // Automatically cancelled when activity is destroyed
            val data = withContext(Dispatchers.IO) {
                loadData()
            }
            updateUI(data)
        }
    }
}

class MyViewModel : ViewModel() {
    fun loadData() {
        viewModelScope.launch {
            // Automatically cancelled when ViewModel is cleared
            repository.getData()
        }
    }
}
```

#### Android-Specific APIs

Kotlin provides extension functions and properties for common Android patterns. Intent creation, SharedPreferences access, and resource handling are streamlined with Kotlin's syntax.

```kotlin
// Intent creation
val intent = Intent(this, MainActivity::class.java).apply {
    putExtra("key", "value")
}

// SharedPreferences
val prefs = getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
prefs.edit {
    putString("username", "john")
    putBoolean("logged_in", true)
}

// Resource access
val color = ContextCompat.getColor(this, R.color.primary)
val string = getString(R.string.app_name)
```

#### Performance Considerations

Android apps have strict performance requirements due to limited resources and battery constraints. Kotlin's compilation to efficient bytecode helps, but developers must consider object allocation, garbage collection, and main thread blocking.

```kotlin
// Efficient collection operations
val result = list.asSequence()
    .filter { it.isValid }
    .map { it.transform() }
    .take(10)
    .toList()

// Avoid allocations in hot paths
class RecyclerAdapter : RecyclerView.Adapter<ViewHolder>() {
    private val reusableIntent = Intent()
    
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        // Reuse objects to avoid garbage collection pressure
    }
}
```

### Kotlin/Native Basics

Kotlin/Native compiles Kotlin code to native binaries without requiring a virtual machine, enabling deployment to platforms where the JVM isn't available.

#### Native Compilation Model

Kotlin/Native uses LLVM as its backend, producing native executables for various platforms including Linux, macOS, Windows, iOS, and embedded systems. The compilation process includes whole-program optimization and dead code elimination.

```kotlin
// Native-specific annotations
@ThreadLocal
var globalVariable: String = ""

@SharedImmutable
val sharedConstant = "immutable data"

@ExperimentalForeignApi
external fun nativeFunction(): Int
```

#### Memory Management

Kotlin/Native uses automatic memory management with a concurrent mark-and-sweep garbage collector. Objects are allocated on the heap, and the runtime handles deallocation automatically. The memory model supports both shared and thread-local objects.

```kotlin
// Memory management in Native
class NativeClass {
    private val data = ByteArray(1024)
    
    fun processData() {
        // Memory is automatically managed
        val temp = data.copyOf()
        // temp is collected when no longer referenced
    }
}
```

#### Platform-Specific APIs

Kotlin/Native provides access to platform-specific APIs through expect/actual declarations and C interop. The cinterop tool generates Kotlin bindings for C libraries, enabling access to system APIs.

```kotlin
// Platform-specific implementation
actual fun getCurrentTimestamp(): Long {
    return platform.posix.time(null)
}

// C interop
@OptIn(ExperimentalForeignApi::class)
fun callNativeLibrary() {
    val result = nativeLibrary.someFunction()
}
```

#### Concurrency in Native

Kotlin/Native's concurrency model is based on isolated mutability and shared immutable state. Objects are either mutable and confined to a single thread or immutable and shareable across threads.

```kotlin
// Worker-based concurrency
val worker = Worker.start()
val future = worker.execute(TransferMode.SAFE, { "data" }) {
    // This runs on worker thread
    it.uppercase()
}
val result = future.result
```

### Multiplatform Project Setup

Kotlin Multiplatform enables sharing code between different platforms while maintaining platform-specific implementations where needed.

#### Project Structure

A typical multiplatform project consists of common source sets containing shared code and platform-specific source sets for platform implementations. The hierarchy allows for intermediate source sets that target subsets of platforms.

```kotlin
// build.gradle.kts
kotlin {
    jvm()
    js(IR) {
        browser()
        nodejs()
    }
    
    iosX64()
    iosArm64()
    iosSimulatorArm64()
    
    sourceSets {
        commonMain {
            dependencies {
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
            }
        }
        
        jvmMain {
            dependencies {
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core-jvm:1.7.3")
            }
        }
        
        jsMain {
            dependencies {
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core-js:1.7.3")
            }
        }
    }
}
```

#### Expected and Actual Declarations

The expect/actual mechanism allows declaring common APIs in shared code with platform-specific implementations. Expected declarations define the contract, while actual declarations provide the implementation.

```kotlin
// commonMain
expect fun getPlatformName(): String
expect class Platform {
    fun getVersion(): String
}

// jvmMain
actual fun getPlatformName(): String = "JVM"
actual class Platform {
    actual fun getVersion(): String = System.getProperty("java.version")
}

// jsMain
actual fun getPlatformName(): String = "JavaScript"
actual class Platform {
    actual fun getVersion(): String = js("process.version")
}
```

#### Shared Libraries and Dependencies

Multiplatform libraries provide common APIs that work across platforms. Popular libraries like kotlinx.coroutines, kotlinx.serialization, and Ktor offer multiplatform support with platform-specific optimizations.

```kotlin
// Common networking code
class ApiClient {
    private val httpClient = HttpClient()
    
    suspend fun getData(): ApiResponse {
        return httpClient.get("https://api.example.com/data")
    }
}

// Common serialization
@Serializable
data class User(val name: String, val age: Int)

val json = Json.encodeToString(User("John", 30))
```

#### Platform-Specific Modules

Each platform can have its own module with platform-specific dependencies and implementations. This allows leveraging platform-specific features while maintaining shared business logic.

```kotlin
// Android-specific module
android {
    compileSdk = 34
    
    defaultConfig {
        minSdk = 21
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
}

// iOS-specific configuration
iosMain {
    dependencies {
        implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core-iosarm64:1.7.3")
    }
}
```

#### Testing Multiplatform Code

Multiplatform projects support testing common code with platform-specific test implementations. The testing framework runs tests on all configured platforms, ensuring consistent behavior.

```kotlin
// commonTest
class CommonTest {
    @Test
    fun testSharedLogic() {
        val result = SharedLogic.process("input")
        assertEquals("expected", result)
    }
}

// jvmTest
class JvmSpecificTest {
    @Test
    fun testJvmImplementation() {
        val platform = Platform()
        assertTrue(platform.getVersion().isNotEmpty())
    }
}
```

**Key points**: JVM features provide seamless Java interoperability with powerful reflection and concurrency capabilities. Android development leverages lifecycle-aware coroutines and platform-specific APIs for optimal mobile performance. Kotlin/Native enables native compilation with automatic memory management and platform-specific API access. Multiplatform projects share code across platforms using expect/actual declarations while maintaining platform-specific optimizations.

---

