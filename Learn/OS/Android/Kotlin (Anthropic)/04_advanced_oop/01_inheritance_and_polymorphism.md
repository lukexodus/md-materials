## Inheritance and Polymorphism


### Class Inheritance

Kotlin classes are final by default, requiring the `open` modifier to enable inheritance. This design promotes composition over inheritance and prevents fragile base class problems.

```kotlin
// Base class - must be open for inheritance
open class Animal(val name: String, val species: String) {
    open val sound: String = "Some sound"
    
    open fun makeSound() {
        println("$name makes a $sound")
    }
    
    open fun move() {
        println("$name is moving")
    }
    
    // Final method - cannot be overridden
    fun sleep() {
        println("$name is sleeping")
    }
}

// Derived class
class Dog(name: String, val breed: String) : Animal(name, "Canine") {
    override val sound: String = "woof"
    
    override fun makeSound() {
        println("$name barks: $sound")
    }
    
    override fun move() {
        super.move() // Call parent implementation
        println("$name runs on four legs")
    }
    
    // Additional method specific to Dog
    fun fetch() {
        println("$name fetches the ball")
    }
}

// Multiple inheritance levels
open class Mammal(name: String, species: String) : Animal(name, species) {
    open val bodyTemperature: Double = 37.0
    
    open fun regulate() {
        println("$name regulates body temperature")
    }
}

class Cat(name: String, val breed: String) : Mammal(name, "Feline") {
    override val sound: String = "meow"
    override val bodyTemperature: Double = 38.5
    
    override fun makeSound() {
        println("$name meows: $sound")
    }
    
    fun purr() {
        println("$name purrs contentedly")
    }
}
```

**Key points:**

- Classes and methods are final by default
- `open` keyword enables inheritance and overriding
- `override` keyword is mandatory for overriding members
- `super` keyword accesses parent class implementations
- Primary constructor parameters can be passed to parent constructors
- Derived classes can add their own properties and methods

### Abstract Classes and Members

Abstract classes cannot be instantiated and may contain abstract members that must be implemented by subclasses.

```kotlin
// Abstract base class
abstract class Shape {
    abstract val area: Double
    abstract val perimeter: Double
    
    // Abstract method
    abstract fun draw()
    
    // Concrete method
    fun display() {
        println("Shape with area: $area and perimeter: $perimeter")
        draw()
    }
    
    // Abstract property with custom getter
    abstract val description: String
        get() = "This is a shape"
}

// Concrete implementation
class Circle(val radius: Double) : Shape() {
    override val area: Double
        get() = Math.PI * radius * radius
    
    override val perimeter: Double
        get() = 2 * Math.PI * radius
    
    override fun draw() {
        println("Drawing a circle with radius $radius")
    }
    
    override val description: String = "Circle"
}

class Rectangle(val width: Double, val height: Double) : Shape() {
    override val area: Double = width * height
    override val perimeter: Double = 2 * (width + height)
    
    override fun draw() {
        println("Drawing a rectangle ${width}x${height}")
    }
    
    override val description: String = "Rectangle"
}

// Abstract class with constructor
abstract class Vehicle(val brand: String, val model: String) {
    abstract val maxSpeed: Int
    abstract fun start()
    abstract fun stop()
    
    fun info() {
        println("$brand $model - Max speed: $maxSpeed km/h")
    }
}

class Car(brand: String, model: String, override val maxSpeed: Int) : Vehicle(brand, model) {
    override fun start() {
        println("Car engine started")
    }
    
    override fun stop() {
        println("Car engine stopped")
    }
}

// Abstract class with template method pattern
abstract class DataProcessor<T> {
    abstract fun loadData(): List<T>
    abstract fun processItem(item: T): T
    abstract fun saveData(data: List<T>)
    
    // Template method
    fun execute() {
        val data = loadData()
        val processed = data.map { processItem(it) }
        saveData(processed)
    }
}
```

**Key points:**

- Abstract classes cannot be instantiated
- Abstract members must be implemented by subclasses
- Abstract classes can contain both abstract and concrete members
- Abstract properties can have custom getters/setters
- Abstract classes can have constructors
- Useful for template method pattern and shared behavior

### Interfaces and Implementation

Interfaces define contracts that classes must fulfill and support multiple inheritance.

```kotlin
// Basic interface
interface Drawable {
    fun draw()
    fun resize(factor: Double)
}

// Interface with default implementation
interface Clickable {
    fun click()
    
    // Default implementation
    fun doubleClick() {
        println("Double clicked")
        click()
        click()
    }
    
    // Property with default getter
    val isEnabled: Boolean
        get() = true
}

// Interface with properties
interface Named {
    val name: String
    val displayName: String
        get() = name.uppercase()
}

// Multiple interface implementation
class Button(override val name: String) : Clickable, Drawable, Named {
    override fun click() {
        println("Button $name clicked")
    }
    
    override fun draw() {
        println("Drawing button $name")
    }
    
    override fun resize(factor: Double) {
        println("Resizing button $name by factor $factor")
    }
}

// Interface inheritance
interface Movable {
    fun move(dx: Int, dy: Int)
}

interface Transformable : Drawable, Movable {
    fun rotate(angle: Double)
    fun scale(factor: Double)
}

// Resolving conflicts between interfaces
interface A {
    fun foo() {
        println("A.foo()")
    }
}

interface B {
    fun foo() {
        println("B.foo()")
    }
}

class C : A, B {
    override fun foo() {
        super<A>.foo() // Call A's implementation
        super<B>.foo() // Call B's implementation
        println("C.foo()")
    }
}

// Functional interfaces (SAM interfaces)
fun interface Predicate<T> {
    fun test(t: T): Boolean
}

// Usage with lambda
val isPositive = Predicate<Int> { it > 0 }
val numbers = listOf(-1, 2, -3, 4)
val positiveNumbers = numbers.filter(isPositive::test)
```

**Key points:**

- Interfaces define contracts without implementation constraints
- Can contain abstract and concrete members
- Support multiple inheritance
- Default implementations reduce boilerplate
- Conflicts resolved with explicit `super<Interface>` calls
- Functional interfaces enable SAM conversion with lambdas

### Polymorphism in Practice

Polymorphism allows objects of different types to be treated uniformly through common interfaces or base classes.

```kotlin
// Polymorphism with abstract classes
abstract class Employee(val name: String, val id: Int) {
    abstract fun calculateSalary(): Double
    abstract fun getRole(): String
    
    fun displayInfo() {
        println("$name (ID: $id) - ${getRole()}: ${calculateSalary()}")
    }
}

class Developer(name: String, id: Int, val hourlyRate: Double, val hoursWorked: Int) : Employee(name, id) {
    override fun calculateSalary(): Double = hourlyRate * hoursWorked
    override fun getRole(): String = "Developer"
}

class Manager(name: String, id: Int, val baseSalary: Double, val bonus: Double) : Employee(name, id) {
    override fun calculateSalary(): Double = baseSalary + bonus
    override fun getRole(): String = "Manager"
}

// Polymorphic usage
fun processEmployees(employees: List<Employee>) {
    employees.forEach { employee ->
        employee.displayInfo() // Calls appropriate implementation
        
        // Type checking and casting
        when (employee) {
            is Developer -> println("  Hours worked: ${employee.hoursWorked}")
            is Manager -> println("  Bonus: ${employee.bonus}")
        }
    }
}

// Interface-based polymorphism
interface PaymentProcessor {
    fun processPayment(amount: Double): Boolean
    fun getProviderName(): String
}

class CreditCardProcessor : PaymentProcessor {
    override fun processPayment(amount: Double): Boolean {
        println("Processing credit card payment: $$amount")
        return true
    }
    
    override fun getProviderName(): String = "Credit Card"
}

class PayPalProcessor : PaymentProcessor {
    override fun processPayment(amount: Double): Boolean {
        println("Processing PayPal payment: $$amount")
        return true
    }
    
    override fun getProviderName(): String = "PayPal"
}

class BankTransferProcessor : PaymentProcessor {
    override fun processPayment(amount: Double): Boolean {
        println("Processing bank transfer: $$amount")
        return true
    }
    
    override fun getProviderName(): String = "Bank Transfer"
}

// Polymorphic payment processing
class PaymentService {
    fun processPayment(processor: PaymentProcessor, amount: Double) {
        println("Using ${processor.getProviderName()}")
        val success = processor.processPayment(amount)
        if (success) {
            println("Payment processed successfully")
        } else {
            println("Payment failed")
        }
    }
}

// Generic polymorphism
interface Repository<T> {
    fun save(item: T)
    fun findById(id: String): T?
    fun findAll(): List<T>
    fun delete(id: String)
}

class UserRepository : Repository<User> {
    private val users = mutableMapOf<String, User>()
    
    override fun save(item: User) {
        users[item.id] = item
    }
    
    override fun findById(id: String): User? = users[id]
    override fun findAll(): List<User> = users.values.toList()
    override fun delete(id: String) { users.remove(id) }
}

// Polymorphism with sealed classes
sealed class Result<out T>
data class Success<T>(val data: T) : Result<T>()
data class Error(val message: String) : Result<Nothing>()

fun <T> handleResult(result: Result<T>) {
    when (result) {
        is Success -> println("Success: ${result.data}")
        is Error -> println("Error: ${result.message}")
    }
}
```

**Key points:**

- Polymorphism enables treating different types uniformly
- Runtime type checking with `is` operator
- Smart casting automatically casts after type checks
- Interface-based polymorphism promotes loose coupling
- Generic polymorphism provides type-safe flexibility
- Sealed classes enable exhaustive polymorphic handling

### Advanced Inheritance Patterns

```kotlin
// Delegation pattern
interface Engine {
    fun start()
    fun stop()
}

class GasEngine : Engine {
    override fun start() = println("Gas engine started")
    override fun stop() = println("Gas engine stopped")
}

class ElectricEngine : Engine {
    override fun start() = println("Electric engine started")
    override fun stop() = println("Electric engine stopped")
}

// Class delegation
class Car(private val engine: Engine) : Engine by engine {
    fun drive() {
        start() // Delegates to engine
        println("Car is driving")
        stop() // Delegates to engine
    }
}

// Mixin pattern with interfaces
interface Flyable {
    fun fly() = println("Flying")
}

interface Swimmable {
    fun swim() = println("Swimming")
}

class Duck : Flyable, Swimmable {
    fun move() {
        fly()
        swim()
    }
}

// Strategy pattern with polymorphism
interface SortingStrategy {
    fun <T : Comparable<T>> sort(list: MutableList<T>)
}

class QuickSort : SortingStrategy {
    override fun <T : Comparable<T>> sort(list: MutableList<T>) {
        // QuickSort implementation
        println("Sorting with QuickSort")
    }
}

class MergeSort : SortingStrategy {
    override fun <T : Comparable<T>> sort(list: MutableList<T>) {
        // MergeSort implementation
        println("Sorting with MergeSort")
    }
}

class Sorter(private var strategy: SortingStrategy) {
    fun setStrategy(strategy: SortingStrategy) {
        this.strategy = strategy
    }
    
    fun <T : Comparable<T>> sort(list: MutableList<T>) {
        strategy.sort(list)
    }
}
```

**Key points:**

- Delegation promotes composition over inheritance
- `by` keyword provides automatic delegation
- Mixin pattern combines multiple behaviors
- Strategy pattern leverages polymorphism for algorithm selection
- Polymorphism enables flexible design patterns

### Best Practices and Common Pitfalls

```kotlin
// Prefer composition over inheritance
// Good
class Car(private val engine: Engine) {
    fun start() = engine.start()
}

// Less flexible
open class Vehicle
class Car : Vehicle() // Tight coupling

// Use sealed classes for restricted hierarchies
sealed class UIEvent
data class Click(val x: Int, val y: Int) : UIEvent()
data class Scroll(val direction: String) : UIEvent()

// Avoid deep inheritance hierarchies
// Bad
class A
open class B : A()
open class C : B()
class D : C() // Too deep

// Good - prefer interfaces and composition
interface Printable
interface Scannable
class MultiFunctionPrinter : Printable, Scannable

// Use abstract classes for shared state and behavior
abstract class BaseActivity {
    protected val commonData = mutableMapOf<String, Any>()
    
    abstract fun onCreate()
    
    protected fun log(message: String) {
        println("[$javaClass.simpleName] $message")
    }
}

// Prefer dependency injection for polymorphism
class ServiceLayer(private val repository: Repository<User>) {
    fun getUser(id: String) = repository.findById(id)
}
```

**Key points:**

- Favor composition over inheritance for flexibility
- Use sealed classes for controlled hierarchies
- Avoid deep inheritance trees
- Abstract classes for shared state, interfaces for contracts
- Dependency injection enables testable polymorphism
- Consider the Liskov Substitution Principle when designing hierarchies

---

