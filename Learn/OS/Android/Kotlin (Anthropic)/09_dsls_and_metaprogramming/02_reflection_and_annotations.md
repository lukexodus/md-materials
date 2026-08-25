## Reflection and Annotations


### Kotlin Reflection API

Kotlin's reflection API provides runtime introspection capabilities, allowing you to examine and manipulate classes, functions, and properties at runtime. The reflection API is built on top of Java reflection but provides Kotlin-specific features and syntax.

#### Basic Reflection Setup

To use Kotlin reflection, add the dependency to your project:

```kotlin
// build.gradle.kts
dependencies {
    implementation("org.jetbrains.kotlin:kotlin-reflect:1.9.10")
}
```

#### Getting Class References

Kotlin provides several ways to obtain class references:

```kotlin
import kotlin.reflect.*

class Person(val name: String, val age: Int) {
    fun greet() = "Hello, I'm $name"
}

fun main() {
    // Getting KClass from class literal
    val personClass: KClass<Person> = Person::class
    
    // Getting KClass from instance
    val person = Person("Alice", 30)
    val personClassFromInstance = person::class
    
    // Getting Java Class
    val javaClass = Person::class.java
    
    // Converting between KClass and Java Class
    val kotlinClass = javaClass.kotlin
    
    println("Class name: ${personClass.simpleName}")
    println("Qualified name: ${personClass.qualifiedName}")
    println("Is data class: ${personClass.isData}")
}
```

#### Inspecting Class Members

```kotlin
data class Employee(
    val id: Long,
    val name: String,
    val department: String,
    val salary: Double
) {
    fun getDisplayName(): String = "$name ($department)"
    
    fun increaseSalary(percentage: Double): Employee {
        return copy(salary = salary * (1 + percentage / 100))
    }
}

fun inspectClass() {
    val employeeClass = Employee::class
    
    // Get all properties
    println("Properties:")
    employeeClass.memberProperties.forEach { property ->
        println("  ${property.name}: ${property.returnType}")
    }
    
    // Get all functions
    println("\nFunctions:")
    employeeClass.memberFunctions.forEach { function ->
        println("  ${function.name}: ${function.returnType}")
        println("    Parameters: ${function.parameters.map { it.name to it.type }}")
    }
    
    // Get constructors
    println("\nConstructors:")
    employeeClass.constructors.forEach { constructor ->
        println("  Parameters: ${constructor.parameters.map { it.name to it.type }}")
    }
}
```

#### Property Reflection

Property reflection allows you to get and set property values dynamically:

```kotlin
class Configuration {
    var host: String = "localhost"
    var port: Int = 8080
    var enabled: Boolean = true
}

fun demonstratePropertyReflection() {
    val config = Configuration()
    val configClass = Configuration::class
    
    // Get property by name
    val hostProperty = configClass.memberProperties.find { it.name == "host" }
    if (hostProperty is KMutableProperty1<Configuration, String>) {
        println("Current host: ${hostProperty.get(config)}")
        hostProperty.set(config, "example.com")
        println("Updated host: ${hostProperty.get(config)}")
    }
    
    // Iterate through all properties
    configClass.memberProperties.forEach { property ->
        when (property) {
            is KMutableProperty1<Configuration, *> -> {
                val value = property.get(config)
                println("${property.name}: $value (mutable)")
            }
            is KProperty1<Configuration, *> -> {
                val value = property.get(config)
                println("${property.name}: $value (read-only)")
            }
        }
    }
}
```

#### Function Reflection

Function reflection enables dynamic function invocation:

```kotlin
class Calculator {
    fun add(a: Int, b: Int): Int = a + b
    fun multiply(a: Int, b: Int): Int = a * b
    fun divide(a: Double, b: Double): Double = a / b
}

fun demonstrateFunctionReflection() {
    val calculator = Calculator()
    val calculatorClass = Calculator::class
    
    // Get function by name
    val addFunction = calculatorClass.memberFunctions.find { it.name == "add" }
    if (addFunction != null) {
        val result = addFunction.call(calculator, 5, 3)
        println("5 + 3 = $result")
    }
    
    // Dynamic function calling based on operation name
    val operations = mapOf(
        "add" to listOf(10, 5),
        "multiply" to listOf(4, 3),
        "divide" to listOf(15.0, 3.0)
    )
    
    operations.forEach { (operationName, args) ->
        val function = calculatorClass.memberFunctions.find { it.name == operationName }
        if (function != null) {
            val result = function.call(calculator, *args.toTypedArray())
            println("$operationName${args} = $result")
        }
    }
}
```

### Creating Custom Annotations

Annotations provide metadata about code elements and can be processed at compile-time or runtime.

#### Basic Annotation Declaration

```kotlin
// Simple marker annotation
@Target(AnnotationTarget.CLASS)
@Retention(AnnotationRetention.RUNTIME)
annotation class Entity

// Annotation with parameters
@Target(AnnotationTarget.PROPERTY)
@Retention(AnnotationRetention.RUNTIME)
annotation class Column(
    val name: String,
    val nullable: Boolean = true,
    val unique: Boolean = false
)

// Annotation with multiple targets
@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
annotation class Deprecated(
    val message: String,
    val replaceWith: String = ""
)
```

#### Advanced Annotation Features

```kotlin
// Annotation with array parameters
@Target(AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
annotation class ValidateParams(
    val rules: Array<String>,
    val groups: Array<KClass<*>> = []
)

// Annotation with enum parameters
enum class AccessLevel { PUBLIC, PRIVATE, PROTECTED }

@Target(AnnotationTarget.PROPERTY)
@Retention(AnnotationRetention.RUNTIME)
annotation class AccessControl(
    val level: AccessLevel = AccessLevel.PUBLIC,
    val roles: Array<String> = []
)

// Nested annotations
@Target(AnnotationTarget.CLASS)
@Retention(AnnotationRetention.RUNTIME)
annotation class ApiEndpoint(
    val path: String,
    val method: HttpMethod = HttpMethod.GET,
    val security: Security = Security()
)

annotation class Security(
    val requiresAuth: Boolean = true,
    val roles: Array<String> = []
)

enum class HttpMethod { GET, POST, PUT, DELETE }
```

#### Using Custom Annotations

```kotlin
@Entity
@ApiEndpoint("/users", HttpMethod.POST)
class User(
    @Column("user_id", nullable = false, unique = true)
    val id: Long,
    
    @Column("full_name")
    val name: String,
    
    @Column("email_address", unique = true)
    @AccessControl(AccessLevel.PRIVATE, ["admin", "user"])
    val email: String
) {
    @ValidateParams(["notEmpty", "validEmail"])
    fun updateEmail(newEmail: String) {
        // Update email logic
    }
}
```

### Annotation Processing

Annotation processing allows you to read and act upon annotations at runtime.

#### Runtime Annotation Processing

```kotlin
class AnnotationProcessor {
    fun processEntity(obj: Any) {
        val kClass = obj::class
        
        // Check if class has Entity annotation
        val entityAnnotation = kClass.findAnnotation<Entity>()
        if (entityAnnotation != null) {
            println("Processing entity: ${kClass.simpleName}")
            
            // Process API endpoint annotation
            val apiAnnotation = kClass.findAnnotation<ApiEndpoint>()
            if (apiAnnotation != null) {
                println("  API Path: ${apiAnnotation.path}")
                println("  HTTP Method: ${apiAnnotation.method}")
                println("  Requires Auth: ${apiAnnotation.security.requiresAuth}")
            }
            
            // Process property annotations
            processProperties(obj, kClass)
        }
    }
    
    private fun processProperties(obj: Any, kClass: KClass<*>) {
        kClass.memberProperties.forEach { property ->
            val columnAnnotation = property.findAnnotation<Column>()
            if (columnAnnotation != null) {
                val value = property.getter.call(obj)
                println("  Column ${columnAnnotation.name}: $value")
                println("    Nullable: ${columnAnnotation.nullable}")
                println("    Unique: ${columnAnnotation.unique}")
            }
            
            val accessAnnotation = property.findAnnotation<AccessControl>()
            if (accessAnnotation != null) {
                println("  Access Level: ${accessAnnotation.level}")
                println("  Roles: ${accessAnnotation.roles.joinToString()}")
            }
        }
    }
}

fun demonstrateAnnotationProcessing() {
    val user = User(1L, "John Doe", "john@example.com")
    val processor = AnnotationProcessor()
    processor.processEntity(user)
}
```

#### Building a Simple ORM with Annotations

```kotlin
@Target(AnnotationTarget.CLASS)
@Retention(AnnotationRetention.RUNTIME)
annotation class Table(val name: String)

@Target(AnnotationTarget.PROPERTY)
@Retention(AnnotationRetention.RUNTIME)
annotation class Id

@Target(AnnotationTarget.PROPERTY)
@Retention(AnnotationRetention.RUNTIME)
annotation class Column(val name: String = "")

class SimpleORM {
    fun generateCreateTableSQL(kClass: KClass<*>): String {
        val tableAnnotation = kClass.findAnnotation<Table>()
        val tableName = tableAnnotation?.name ?: kClass.simpleName?.lowercase()
        
        val columns = kClass.memberProperties.mapNotNull { property ->
            val columnAnnotation = property.findAnnotation<Column>()
            val idAnnotation = property.findAnnotation<Id>()
            
            if (columnAnnotation != null || idAnnotation != null) {
                val columnName = columnAnnotation?.name?.takeIf { it.isNotEmpty() } 
                    ?: property.name.lowercase()
                
                val sqlType = when (property.returnType.classifier) {
                    String::class -> "VARCHAR(255)"
                    Int::class -> "INTEGER"
                    Long::class -> "BIGINT"
                    Double::class -> "DOUBLE"
                    Boolean::class -> "BOOLEAN"
                    else -> "TEXT"
                }
                
                val constraints = mutableListOf<String>()
                if (idAnnotation != null) {
                    constraints.add("PRIMARY KEY")
                }
                
                "$columnName $sqlType ${constraints.joinToString(" ")}"
            } else null
        }
        
        return "CREATE TABLE $tableName (\n  ${columns.joinToString(",\n  ")}\n);"
    }
}

@Table("users")
class DatabaseUser(
    @Id
    val id: Long,
    
    @Column("full_name")
    val name: String,
    
    @Column("email_address")
    val email: String,
    
    val age: Int // No annotation, will be ignored
)

fun demonstrateORM() {
    val orm = SimpleORM()
    val sql = orm.generateCreateTableSQL(DatabaseUser::class)
    println(sql)
}
```

### KClass and KFunction Usage

#### Working with KClass

```kotlin
class TypeInspector {
    fun inspectType(kClass: KClass<*>) {
        println("=== Type Information ===")
        println("Simple name: ${kClass.simpleName}")
        println("Qualified name: ${kClass.qualifiedName}")
        println("Is abstract: ${kClass.isAbstract}")
        println("Is final: ${kClass.isFinal}")
        println("Is open: ${kClass.isOpen}")
        println("Is data class: ${kClass.isData}")
        println("Is sealed: ${kClass.isSealed}")
        
        // Supertypes
        println("\nSupertypes:")
        kClass.supertypes.forEach { supertype ->
            println("  $supertype")
        }
        
        // Type parameters
        if (kClass.typeParameters.isNotEmpty()) {
            println("\nType parameters:")
            kClass.typeParameters.forEach { param ->
                println("  ${param.name}: ${param.upperBounds}")
            }
        }
    }
}

// Generic class for demonstration
class Repository<T : Any>(private val entityClass: KClass<T>) {
    fun getEntityType(): KClass<T> = entityClass
    
    fun createInstance(): T? {
        return try {
            // Attempt to create instance using no-arg constructor
            entityClass.constructors.firstOrNull { it.parameters.isEmpty() }?.call()
        } catch (e: Exception) {
            null
        }
    }
}
```

#### Advanced KFunction Usage

```kotlin
class FunctionAnalyzer {
    fun analyzeFunction(kFunction: KFunction<*>) {
        println("=== Function Analysis ===")
        println("Name: ${kFunction.name}")
        println("Return type: ${kFunction.returnType}")
        println("Is suspend: ${kFunction.isSuspend}")
        println("Is inline: ${kFunction.isInline}")
        println("Is operator: ${kFunction.isOperator}")
        println("Is infix: ${kFunction.isInfix}")
        
        // Parameters
        println("\nParameters:")
        kFunction.parameters.forEach { param ->
            println("  ${param.name}: ${param.type}")
            println("    Kind: ${param.kind}")
            println("    Is optional: ${param.isOptional}")
            println("    Is vararg: ${param.isVararg}")
        }
        
        // Annotations
        if (kFunction.annotations.isNotEmpty()) {
            println("\nAnnotations:")
            kFunction.annotations.forEach { annotation ->
                println("  $annotation")
            }
        }
    }
}

class MathOperations {
    @ValidateParams(["positive"])
    fun power(base: Double, exponent: Double = 2.0): Double {
        return Math.pow(base, exponent)
    }
    
    operator fun invoke(operation: String, vararg args: Double): Double {
        return when (operation) {
            "power" -> power(args[0], args.getOrElse(1) { 2.0 })
            else -> 0.0
        }
    }
}

fun demonstrateFunctionAnalysis() {
    val mathClass = MathOperations::class
    val powerFunction = mathClass.memberFunctions.find { it.name == "power" }
    
    if (powerFunction != null) {
        val analyzer = FunctionAnalyzer()
        analyzer.analyzeFunction(powerFunction)
    }
}
```

#### Dynamic Object Creation and Manipulation

```kotlin
class ObjectFactory {
    inline fun <reified T : Any> create(vararg args: Any?): T? {
        return create(T::class, *args)
    }
    
    fun <T : Any> create(kClass: KClass<T>, vararg args: Any?): T? {
        return try {
            // Find constructor that matches the number of arguments
            val constructor = kClass.constructors.find { 
                it.parameters.size == args.size 
            }
            
            constructor?.call(*args)
        } catch (e: Exception) {
            println("Failed to create instance: ${e.message}")
            null
        }
    }
    
    fun <T : Any> copyWithModifications(
        original: T,
        modifications: Map<String, Any?>
    ): T? {
        val kClass = original::class
        
        // Find primary constructor
        val primaryConstructor = kClass.primaryConstructor ?: return null
        
        // Get current property values
        val currentValues = mutableMapOf<String, Any?>()
        kClass.memberProperties.forEach { property ->
            currentValues[property.name] = property.getter.call(original)
        }
        
        // Apply modifications
        modifications.forEach { (name, value) ->
            currentValues[name] = value
        }
        
        // Create new instance with modified values
        val constructorArgs = primaryConstructor.parameters.map { param ->
            currentValues[param.name]
        }.toTypedArray()
        
        return try {
            primaryConstructor.call(*constructorArgs)
        } catch (e: Exception) {
            println("Failed to create modified copy: ${e.message}")
            null
        }
    }
}

data class Product(
    val id: Long,
    val name: String,
    val price: Double,
    val category: String
)

fun demonstrateObjectFactory() {
    val factory = ObjectFactory()
    
    // Create object dynamically
    val product = factory.create<Product>(1L, "Laptop", 999.99, "Electronics")
    println("Created product: $product")
    
    // Create modified copy
    if (product != null) {
        val discountedProduct = factory.copyWithModifications(
            product,
            mapOf("price" to 799.99, "name" to "Laptop (Sale)")
        )
        println("Modified product: $discountedProduct")
    }
}
```

#### Reflection-based Validation Framework

```kotlin
@Target(AnnotationTarget.PROPERTY)
@Retention(AnnotationRetention.RUNTIME)
annotation class NotNull

@Target(AnnotationTarget.PROPERTY)
@Retention(AnnotationRetention.RUNTIME)
annotation class Size(val min: Int = 0, val max: Int = Int.MAX_VALUE)

@Target(AnnotationTarget.PROPERTY)
@Retention(AnnotationRetention.RUNTIME)
annotation class Range(val min: Double, val max: Double)

class ValidationResult(
    val isValid: Boolean,
    val errors: List<String>
)

class Validator {
    fun validate(obj: Any): ValidationResult {
        val errors = mutableListOf<String>()
        val kClass = obj::class
        
        kClass.memberProperties.forEach { property ->
            val value = property.getter.call(obj)
            
            // Check @NotNull
            if (property.findAnnotation<NotNull>() != null && value == null) {
                errors.add("${property.name} cannot be null")
            }
            
            // Check @Size
            val sizeAnnotation = property.findAnnotation<Size>()
            if (sizeAnnotation != null && value is String) {
                if (value.length < sizeAnnotation.min || value.length > sizeAnnotation.max) {
                    errors.add("${property.name} must be between ${sizeAnnotation.min} and ${sizeAnnotation.max} characters")
                }
            }
            
            // Check @Range
            val rangeAnnotation = property.findAnnotation<Range>()
            if (rangeAnnotation != null && value is Number) {
                val doubleValue = value.toDouble()
                if (doubleValue < rangeAnnotation.min || doubleValue > rangeAnnotation.max) {
                    errors.add("${property.name} must be between ${rangeAnnotation.min} and ${rangeAnnotation.max}")
                }
            }
        }
        
        return ValidationResult(errors.isEmpty(), errors)
    }
}

data class UserProfile(
    @NotNull
    @Size(min = 2, max = 50)
    val username: String?,
    
    @Range(min = 0.0, max = 120.0)
    val age: Int,
    
    @Size(min = 10, max = 200)
    val bio: String
)

fun demonstrateValidation() {
    val validator = Validator()
    
    val validProfile = UserProfile("john_doe", 25, "Software developer")
    val validResult = validator.validate(validProfile)
    println("Valid profile: ${validResult.isValid}")
    
    val invalidProfile = UserProfile(null, 150, "Bio")
    val invalidResult = validator.validate(invalidProfile)
    println("Invalid profile: ${invalidResult.isValid}")
    if (!invalidResult.isValid) {
        println("Errors: ${invalidResult.errors}")
    }
}
```

**Key points:**

- Kotlin reflection provides powerful runtime introspection capabilities
- Custom annotations can carry metadata and be processed at runtime
- KClass provides comprehensive class information and manipulation
- KFunction enables dynamic function invocation and analysis
- Reflection enables building frameworks like ORMs and validation systems
- Performance overhead should be considered when using reflection extensively

**Conclusion:** Kotlin's reflection and annotation systems provide the foundation for building sophisticated frameworks and libraries. By combining custom annotations with runtime reflection processing, you can create powerful metaprogramming solutions that reduce boilerplate code and enable declarative programming patterns. Understanding these concepts is essential for advanced Kotlin development and framework creation.

---

