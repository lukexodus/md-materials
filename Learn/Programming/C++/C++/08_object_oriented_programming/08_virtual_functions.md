## Virtual Functions


- **Declaration**: When a function is declared as `virtual` in a base class, it indicates that this function can be overridden in derived classes.
- **Polymorphism**: Virtual functions enable runtime polymorphism, allowing the compiler to determine the appropriate function to call based on the actual object type at runtime.
- **Syntax**:
  ```cpp
  virtual returnType functionName(parameters) [const] [override] = 0;
  ```
  - `returnType`: Return type of the function.
  - `functionName`: Name of the function.
  - `parameters`: Parameters of the function.
  - `const`: Optionally indicates that the function does not modify the object's state.
  - `override`: Optionally indicates that the function overrides a virtual function from the base class.
- **Pure Virtual Functions**: A pure virtual function is declared with `= 0` at the end of its declaration. It means that the function has no implementation in the base class and must be overridden in derived classes.

**Example**

```cpp
class Base {
public:
    virtual void display() const {
        std::cout << "Displaying from Base class" << std::endl;
    }
};

class Derived : public Base {
public:
    void display() const override {
        std::cout << "Displaying from Derived class" << std::endl;
    }
};

int main() {
    Base* basePtr;
    Derived derivedObj;

    basePtr = &derivedObj;
    basePtr->display(); // Calls the display() method of Derived class

    return 0;
}
```

In this example:
- `Base` class has a virtual function `display()`.
- `Derived` class overrides the `display()` function.
- In `main()`, a pointer of type `Base` points to an object of type `Derived`. The `display()` method called through this pointer resolves to the overridden function in `Derived` class at runtime, demonstrating runtime polymorphism.

**Use Cases**

- **Polymorphism**: Virtual functions enable polymorphic behavior, allowing derived classes to provide their own implementation.
- **Dynamic Binding**: Virtual functions support dynamic binding, where the appropriate function to call is determined at runtime based on the object's actual type.

***

