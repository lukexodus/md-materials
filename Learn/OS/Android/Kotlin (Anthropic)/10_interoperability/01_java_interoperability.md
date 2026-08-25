## Java Interoperability


### Calling Java from Kotlin

Kotlin provides seamless interoperability with Java, allowing direct use of Java classes, methods, and libraries without any special syntax or wrappers. This makes migration from Java to Kotlin gradual and practical.

```kotlin
// Using Java collections directly
val javaList = ArrayList<String>()
javaList.add("Hello")
javaList.add("World")

// Using Java streams
val filteredList = javaList.stream()
    .filter { it.startsWith("H") }
    .collect(Collectors.toList())

// Using Java classes
val date = Date()
val calendar = Calendar.getInstance()
val formatter = SimpleDateFormat("yyyy-MM-dd")
```

#### Static Methods and Fields

```kotlin
// Java static methods become regular function calls
val maxValue = Integer.MAX_VALUE
val parsedInt = Integer.parseInt("123")
val currentTime = System.currentTimeMillis()

// Java static methods with class qualification
val uuid = UUID.randomUUID()
val files = Files.list(Paths.get("/tmp"))
```

#### Method Overloading and Default Parameters

```kotlin
// Java method overloading works naturally
val stringBuilder = StringBuilder()
stringBuilder.append("Hello")
stringBuilder.append("World", 0, 5)
stringBuilder.append(42)

// Java methods with multiple overloads
val thread1 = Thread()
val thread2 = Thread("MyThread")
val thread3 = Thread(Runnable { println("Running") })
```

#### Handling Java Exceptions

```kotlin
// Java checked exceptions must be handled
fun readFile(filename: String): String {
    return try {
        Files.readString(Paths.get(filename))
    } catch (e: IOException) {
        "Error reading file: ${e.message}"
    }
}

// Multiple Java exceptions
fun parseAndWrite(input: String, output: String) {
    try {
        val number = Integer.parseInt(input)
        Files.write(Paths.get(output), number.toString().toByteArray())
    } catch (e: NumberFormatException) {
        println("Invalid number format: $input")
    } catch (e: IOException) {
        println("Failed to write file: ${e.message}")
    }
}
```

#### Working with Java Generics

```kotlin
// Java generic types work directly
val map = HashMap<String, Int>()
map["key"] = 42

val list = LinkedList<String>()
list.add("item")

// Java wildcards are handled automatically
fun processList(list: List<*>) {
    for (item in list) {
        println(item)
    }
}

// Working with Java bounded generics
class DataProcessor<T : Comparable<T>> {
    fun process(items: List<T>): T? {
        return items.maxOrNull()
    }
}
```

### Calling Kotlin from Java

Kotlin code can be called from Java with minimal friction, though some Kotlin features require special consideration or annotations to work smoothly with Java.

#### Basic Class Usage

```kotlin
// Kotlin class
class Person(val name: String, val age: Int) {
    fun greet() = "Hello, I'm $name"
    
    fun celebrateBirthday(): Person {
        return Person(name, age + 1)
    }
}
```

```java
// Java usage
public class JavaMain {
    public static void main(String[] args) {
        Person person = new Person("John", 30);
        System.out.println(person.getName()); // Kotlin val becomes getter
        System.out.println(person.getAge());
        System.out.println(person.greet());
        
        Person olderPerson = person.celebrateBirthday();
    }
}
```

#### Properties and Accessors

```kotlin
class User {
    var name: String = ""
    val id: String = UUID.randomUUID().toString()
    
    var isActive: Boolean = true
        get() = field && System.currentTimeMillis() < expirationTime
        set(value) {
            field = value
            lastModified = System.currentTimeMillis()
        }
    
    private var lastModified: Long = 0
    private val expirationTime: Long = System.currentTimeMillis() + 86400000
}
```

```java
// Java usage
User user = new User();
user.setName("Alice");        // var becomes getter/setter
String name = user.getName();
String id = user.getId();     // val becomes getter only
user.setActive(true);
boolean active = user.isActive(); // Boolean property uses is/set prefix
```

#### Companion Objects and Static Methods

```kotlin
class MathUtils {
    companion object {
        fun add(a: Int, b: Int): Int = a + b
        
        @JvmStatic
        fun multiply(a: Int, b: Int): Int = a * b
        
        const val PI = 3.14159
    }
}
```

```java
// Java usage
public class JavaMath {
    public static void main(String[] args) {
        // Without @JvmStatic - requires Companion reference
        int sum = MathUtils.Companion.add(5, 3);
        
        // With @JvmStatic - can call directly
        int product = MathUtils.multiply(5, 3);
        
        // Constants work directly
        double pi = MathUtils.PI;
    }
}
```

#### Top-Level Functions

```kotlin
// File: StringUtils.kt
package com.example.utils

fun capitalize(str: String): String {
    return str.replaceFirstChar { it.uppercase() }
}

@JvmName("reverseString")
fun reverse(str: String): String {
    return str.reversed()
}
```

```java
// Java usage
import com.example.utils.StringUtilsKt;

public class JavaStringProcessor {
    public static void main(String[] args) {
        String capitalized = StringUtilsKt.capitalize("hello");
        String reversed = StringUtilsKt.reverseString("world");
    }
}
```

#### Extension Functions

```kotlin
// Extension functions are not directly accessible from Java
fun String.isPalindrome(): Boolean {
    return this == this.reversed()
}

// Create a utility class for Java interop
class StringExtensions {
    companion object {
        @JvmStatic
        fun isPalindrome(str: String): Boolean {
            return str == str.reversed()
        }
    }
}
```

```java
// Java usage
boolean result = StringExtensions.isPalindrome("racecar");
```

### Handling Java Nullability

Java's nullable types are represented as platform types in Kotlin, which require careful handling to maintain null safety.

#### Platform Types

```kotlin
// Java method that might return null
fun processJavaString(javaString: String) {
    // javaString has platform type String!
    // Kotlin doesn't know if it's nullable or not
    
    // Safe approach - treat as nullable
    val length = javaString?.length ?: 0
    
    // Risky approach - assume non-null
    val upperCase = javaString.uppercase() // Could throw NPE
}
```

#### Null Checks and Safe Calls

```kotlin
// Working with Java collections that might contain nulls
fun processJavaList(javaList: List<String>) {
    for (item in javaList) {
        // item has platform type String!
        item?.let { safeItem ->
            println("Processing: $safeItem")
        }
    }
}

// Converting platform types to Kotlin nullable types
fun convertPlatformType(javaResult: String): String? {
    return javaResult.takeIf { it.isNotEmpty() }
}
```

#### Defensive Programming with Platform Types

```kotlin
class UserService {
    fun processUser(javaUser: User) {
        // Validate platform type inputs
        val safeName = javaUser.name?.takeIf { it.isNotBlank() }
            ?: throw IllegalArgumentException("User name is required")
        
        val safeEmail = javaUser.email?.takeIf { it.contains("@") }
            ?: throw IllegalArgumentException("Valid email is required")
        
        // Process with validated data
        createKotlinUser(safeName, safeEmail)
    }
}
```

### Platform Types and Annotations

Platform types represent Java types whose nullability is unknown to Kotlin. Annotations can provide nullability information to improve interoperability.

#### JSR-305 Annotations

```java
// Java code with JSR-305 annotations
import javax.annotation.Nullable;
import javax.annotation.Nonnull;

public class JavaService {
    @Nonnull
    public String getRequiredValue() {
        return "value";
    }
    
    @Nullable
    public String getOptionalValue() {
        return null;
    }
    
    public void processData(@Nonnull String data, @Nullable String metadata) {
        // Implementation
    }
}
```

```kotlin
// Kotlin usage with annotation information
fun useJavaService(service: JavaService) {
    val required: String = service.requiredValue // Non-null type
    val optional: String? = service.optionalValue // Nullable type
    
    service.processData("data", null) // Accepts null for metadata
}
```

#### Android Support Annotations

```java
// Java code with Android annotations
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class AndroidService {
    @NonNull
    public List<String> getItems() {
        return Arrays.asList("item1", "item2");
    }
    
    @Nullable
    public String findItem(@NonNull String id) {
        return items.get(id);
    }
}
```

```kotlin
// Kotlin automatically recognizes Android annotations
fun useAndroidService(service: AndroidService) {
    val items: List<String> = service.items // Non-null
    val item: String? = service.findItem("123") // Nullable
}
```

#### JetBrains Annotations

```java
// Java code with JetBrains annotations
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

public class DataRepository {
    @NotNull
    public User createUser(@NotNull String name, @Nullable String email) {
        return new User(name, email);
    }
    
    @Nullable
    public User findUser(@NotNull String id) {
        return database.findById(id);
    }
}
```

```kotlin
// Kotlin respects JetBrains annotations
fun useRepository(repository: DataRepository) {
    val user: User = repository.createUser("John", null)
    val foundUser: User? = repository.findUser("123")
}
```

#### Custom Nullability Annotations

```java
// Define custom annotations
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.METHOD, ElementType.PARAMETER, ElementType.FIELD})
public @interface NonNull {}

@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.METHOD, ElementType.PARAMETER, ElementType.FIELD})
public @interface Nullable {}

// Use in Java code
public class CustomService {
    @NonNull
    public String process(@NonNull String input, @Nullable String options) {
        return input.toUpperCase();
    }
}
```

#### Configuring Nullability Annotations

```kotlin
// Configure annotation recognition in build script
android {
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = "1.8"
        freeCompilerArgs += [
            "-Xjsr305=strict",
            "-Xtype-enhancement-improvements-strict-mode"
        ]
    }
}
```

### Advanced Interoperability Patterns

#### Functional Interfaces and SAM Conversion

```kotlin
// Java functional interface
interface Processor {
    fun process(input: String): String
}

// Kotlin can use lambda for SAM conversion
fun useProcessor() {
    val processor = Processor { input ->
        input.uppercase()
    }
    
    // Or method reference
    val anotherProcessor = Processor(String::lowercase)
}
```

#### Handling Java Varargs

```kotlin
// Java method with varargs
fun callJavaVarargs() {
    val formatter = Formatter()
    
    // Pass individual arguments
    formatter.format("Hello %s, age %d", "John", 30)
    
    // Pass array with spread operator
    val args = arrayOf("Jane", 25)
    formatter.format("Hello %s, age %d", *args)
}
```

#### Working with Java Builders

```kotlin
// Using Java builder pattern
fun createHttpClient(): OkHttpClient {
    return OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .addInterceptor(LoggingInterceptor())
        .build()
}
```

**Key points:**

- Java code can be called directly from Kotlin without special syntax
- Kotlin properties become getters/setters in Java
- Platform types require careful null handling
- Annotations provide nullability information for better interoperability
- @JvmStatic and @JvmName annotations improve Java usage of Kotlin code

**Example** of comprehensive Java interoperability:

```kotlin
// Kotlin service that works well with Java
class UserManagementService {
    private val users = mutableMapOf<String, User>()
    
    @JvmOverloads
    fun createUser(
        name: String,
        email: String? = null,
        age: Int = 0
    ): User {
        val user = User(name, email, age)
        users[user.id] = user
        return user
    }
    
    @JvmName("findUserById")
    fun findUser(id: String): User? {
        return users[id]
    }
    
    @JvmStatic
    fun validateEmail(email: String?): Boolean {
        return email?.contains("@") == true
    }
    
    companion object {
        @JvmField
        val DEFAULT_AGE = 18
        
        @JvmStatic
        fun createService(): UserManagementService {
            return UserManagementService()
        }
    }
}

// Data class with Java-friendly design
data class User(
    val name: String,
    val email: String?,
    val age: Int
) {
    val id: String = UUID.randomUUID().toString()
    
    @JvmName("hasEmail")
    fun hasEmail(): Boolean = email != null
}
```

```java
// Java usage of Kotlin code
public class JavaUserManager {
    public static void main(String[] args) {
        UserManagementService service = UserManagementService.createService();
        
        // Use overloaded methods
        User user1 = service.createUser("John");
        User user2 = service.createUser("Jane", "jane@example.com");
        User user3 = service.createUser("Bob", "bob@example.com", 25);
        
        // Use renamed method
        User found = service.findUserById(user1.getId());
        
        // Use static method
        boolean isValid = UserManagementService.validateEmail("test@example.com");
        
        // Use static field
        int defaultAge = UserManagementService.DEFAULT_AGE;
    }
}
```

**Conclusion**

Java interoperability is one of Kotlin's strongest features, enabling seamless integration with existing Java codebases and libraries. Understanding platform types, proper annotation usage, and interop-friendly API design patterns ensures smooth collaboration between Java and Kotlin code. The key is to be mindful of nullability when working with Java APIs and to use appropriate annotations and naming conventions when exposing Kotlin APIs to Java consumers.

---

