## Object-Oriented Programming Concepts


Object-oriented programming principles guide Android application architecture and component design. These concepts enable code reusability, maintainability, and scalable application development.

**Key Points:**

- Classes, objects, and instantiation
- Encapsulation and access modifiers
- Inheritance and polymorphism
- Abstract classes and interfaces
- Composition vs inheritance
- SOLID principles application
- Design patterns (Singleton, Observer, Factory, Builder)

**Example:**

```kotlin
abstract class Vehicle(protected val brand: String, protected val model: String) {
    abstract fun start()
    abstract fun stop()
    
    open fun getInfo(): String = "$brand $model"
}

class Car(brand: String, model: String, private val fuelType: String) : Vehicle(brand, model) {
    override fun start() {
        println("$brand $model engine started")
    }
    
    override fun stop() {
        println("$brand $model engine stopped")
    }
    
    override fun getInfo(): String = "${super.getInfo()} - $fuelType"
}

interface Drivable {
    fun accelerate()
    fun brake()
}
```

