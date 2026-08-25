## Object-Oriented Programming


### Classes and Objects

Kotlin classes are declared using the `class` keyword and can contain properties, methods, constructors, and nested classes.

```kotlin
class Person {
    var name: String = ""
    var age: Int = 0
    
    fun introduce() {
        println("Hi, I'm $name and I'm $age years old")
    }
}

// Creating objects
val person = Person()
person.name = "Alice"
person.age = 30
person.introduce()
```

#### Class Declaration Syntax

Classes can be declared with various components in a single line or expanded format.

```kotlin
// Minimal class
class Empty

// Class with primary constructor
class Person(firstName: String, lastName: String)

// Class with body
class Person(firstName: String, lastName: String) {
    val fullName = "$firstName $lastName"
    
    fun greet() = println("Hello, I'm $fullName")
}
```

**Key points:**

- Classes are public and final by default
- Objects are created without `new` keyword
- Class members are accessed using dot notation
- Empty classes don't require curly braces

### Primary and Secondary Constructors

#### Primary Constructor

The primary constructor is part of the class header and cannot contain executable code.

```kotlin
class Person(firstName: String, lastName: String) {
    val fullName: String = "$firstName $lastName"
    
    init {
        println("Person created: $fullName")
    }
}

// Primary constructor with property declarations
class Person(val firstName: String, val lastName: String) {
    val fullName = "$firstName $lastName"
}

// Primary constructor with default values
class Person(val firstName: String, val lastName: String = "Unknown") {
    fun introduce() = println("I'm $firstName $lastName")
}
```

#### Secondary Constructors

Secondary constructors are declared inside the class body using the `constructor` keyword.

```kotlin
class Person(val firstName: String, val lastName: String) {
    var age: Int = 0
    
    // Secondary constructor
    constructor(firstName: String, lastName: String, age: Int) : this(firstName, lastName) {
        this.age = age
    }
    
    // Another secondary constructor
    constructor(fullName: String) : this(fullName.split(" ")[0], fullName.split(" ")[1])
}

// Usage
val person1 = Person("John", "Doe")
val person2 = Person("Jane", "Smith", 25)
val person3 = Person("Bob Wilson")
```

**Key points:**

- Primary constructor parameters can be properties using `val` or `var`
- Secondary constructors must delegate to primary constructor using `this()`
- Default parameter values reduce need for multiple constructors
- Constructor parameters without `val`/`var` are just initialization parameters

### Properties and Fields

#### Property Declaration

Properties in Kotlin combine field storage with getter/setter methods.

```kotlin
class Person {
    var name: String = ""        // Mutable property
    val birthYear: Int = 1990    // Read-only property
    
    // Property with custom getter
    val age: Int
        get() = 2024 - birthYear
    
    // Property with custom getter and setter
    var nickname: String = ""
        get() = field.uppercase()
        set(value) {
            field = value.trim()
        }
}
```

#### Backing Fields

The `field` identifier references the backing field within property accessors.

```kotlin
class Temperature {
    var celsius: Double = 0.0
        set(value) {
            if (value >= -273.15) {
                field = value
            } else {
                throw IllegalArgumentException("Temperature cannot be below absolute zero")
            }
        }
    
    val fahrenheit: Double
        get() = celsius * 9/5 + 32
    
    val kelvin: Double
        get() = celsius + 273.15
}
```

#### Late-Initialized Properties

Properties that are initialized after object creation using `lateinit`.

```kotlin
class DatabaseConnection {
    lateinit var connection: Connection
    
    fun connect() {
        connection = DriverManager.getConnection("jdbc:...")
    }
    
    fun isConnected(): Boolean {
        return ::connection.isInitialized && !connection.isClosed
    }
}
```

**Key points:**

- Properties automatically generate getter/setter methods
- `field` identifier accesses backing field in custom accessors
- `lateinit` delays property initialization for non-null properties
- Custom getters/setters enable computed and validated properties

### Init Blocks

Init blocks contain initialization code that runs when an object is created.

```kotlin
class Person(firstName: String, lastName: String) {
    val fullName: String
    
    init {
        println("Initializing person...")
        fullName = "$firstName $lastName".trim()
        require(fullName.isNotEmpty()) { "Name cannot be empty" }
    }
    
    init {
        println("Person created: $fullName")
    }
}
```

#### Multiple Init Blocks

Classes can have multiple init blocks that execute in order of appearance.

```kotlin
class ComplexInitialization(val data: String) {
    val processedData: String
    val metadata: Map<String, Any>
    
    init {
        println("Starting initialization...")
        processedData = data.uppercase()
    }
    
    init {
        println("Processing metadata...")
        metadata = mapOf(
            "length" to processedData.length,
            "created" to System.currentTimeMillis()
        )
    }
    
    init {
        println("Initialization complete")
    }
}
```

#### Init Blocks with Secondary Constructors

Init blocks run before secondary constructor bodies.

```kotlin
class Example {
    init {
        println("Init block executed")
    }
    
    constructor(value: String) {
        println("Secondary constructor executed")
    }
}

// Output when created:
// Init block executed
// Secondary constructor executed
```

**Key points:**

- Init blocks execute in order of appearance
- Init blocks run before secondary constructor bodies
- Use init blocks for complex initialization logic
- Primary constructor parameters are available in init blocks

### Visibility Modifiers

Kotlin provides four visibility modifiers that control access to classes, properties, and functions.

#### Public (Default)

Public members are accessible from anywhere.

```kotlin
class PublicExample {
    public val publicProperty = "Accessible everywhere"
    val defaultProperty = "Also public by default"
    
    public fun publicFunction() = "Called from anywhere"
    fun defaultFunction() = "Also public by default"
}
```

#### Private

Private members are only accessible within the same class.

```kotlin
class PrivateExample {
    private val secretData = "Hidden from outside"
    private var internalCounter = 0
    
    private fun incrementCounter() {
        internalCounter++
    }
    
    fun performAction() {
        incrementCounter()  // OK - same class
        println("Action performed $internalCounter times")
    }
}
```

#### Protected

Protected members are accessible within the class and its subclasses.

```kotlin
open class BaseClass {
    protected val protectedProperty = "Visible to subclasses"
    private val privateProperty = "Not visible to subclasses"
    
    protected fun protectedMethod() {
        println("Available in subclasses")
    }
}

class DerivedClass : BaseClass() {
    fun accessProtected() {
        println(protectedProperty)  // OK
        protectedMethod()          // OK
        // println(privateProperty)  // Error - not accessible
    }
}
```

#### Internal

Internal members are accessible within the same module.

```kotlin
// In module A
internal class InternalClass {
    internal val internalProperty = "Visible within module"
    
    internal fun internalMethod() {
        println("Available in same module")
    }
}

// In same module
class SameModuleClass {
    fun useInternal() {
        val obj = InternalClass()  // OK - same module
        println(obj.internalProperty)
    }
}
```

#### Visibility in Constructors

Constructors can also have visibility modifiers.

```kotlin
class RestrictedAccess private constructor(val data: String) {
    companion object {
        fun create(input: String): RestrictedAccess? {
            return if (input.isNotEmpty()) {
                RestrictedAccess(input)
            } else null
        }
    }
}

// Usage
val obj = RestrictedAccess.create("valid data")  // OK
// val direct = RestrictedAccess("data")  // Error - private constructor
```

**Key points:**

- `public` is the default visibility modifier
- `private` restricts access to the declaring class
- `protected` allows access in subclasses but not other classes
- `internal` provides module-level visibility
- Visibility modifiers can be applied to constructors

### Nested and Inner Classes

#### Nested Classes

Nested classes are declared inside other classes but don't have access to outer class instances.

```kotlin
class Outer {
    private val outerProperty = "Outer"
    
    class Nested {
        fun nestedFunction() = "Nested class function"
        // Cannot access outerProperty
    }
}

// Usage
val nested = Outer.Nested()
println(nested.nestedFunction())
```

#### Inner Classes

Inner classes are marked with `inner` and have access to outer class members.

```kotlin
class Outer {
    private val outerProperty = "Outer"
    
    inner class Inner {
        fun innerFunction() = "Accessing $outerProperty from inner class"
    }
}

// Usage
val outer = Outer()
val inner = outer.Inner()
println(inner.innerFunction())
```

**Key points:**

- Nested classes don't hold references to outer class instances
- Inner classes can access outer class members
- Inner classes require outer class instance for creation
- Use nested classes for helper classes that don't need outer access

**Related topics:** Inheritance and polymorphism, interfaces and abstract classes, data classes and sealed classes, companion objects, and generics extend these object-oriented programming concepts.

---

