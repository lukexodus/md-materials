## Abstract Classes


### Abstract Classes:

- An abstract class is a class that cannot be instantiated on its own.
- It may contain one or more pure virtual functions.
- Abstract classes serve as base classes for other classes.
- Abstract classes can define some methods with implementations alongside pure virtual functions.
- Classes derived from abstract classes must implement all pure virtual functions.

### Pure Virtual Functions:

- A pure virtual function is a virtual function that has no implementation in the base class.
- It is declared using the syntax `virtual returnType functionName() = 0;`.
- Any class containing a pure virtual function becomes an abstract class.
- Derived classes must override and provide implementations for all pure virtual functions to become concrete classes.

**Example**:

```cpp
#include <iostream>

// Abstract class (Interface)
class Shape {
public:
    // Pure virtual function (Interface method)
    virtual void draw() const = 0;
};

// `const` means this function does not modify the object.

// Concrete class implementing the Shape interface
class Circle : public Shape {
public:
    void draw() const override {
        std::cout << "Drawing a circle" << std::endl;
    }
};

// Concrete class implementing the Shape interface
class Square : public Shape {
public:
    void draw() const override {
        std::cout << "Drawing a square" << std::endl;
    }
};

int main() {
    Circle circle;
    Square square;

    // Polymorphic behavior
    Shape* shapes[] = {&circle, &square};
    for (auto shape : shapes) {
        shape->draw(); // Calls the appropriate draw() method based on the actual object type
    }

    return 0;
}
```

In this example:
- `Shape` is an abstract class defining an interface with a pure virtual function `draw()`.
- `Circle` and `Square` are concrete classes that implement the `Shape` interface by providing an implementation for the `draw()` method.
- In `main()`, we demonstrate polymorphic behavior by storing `Circle` and `Square` objects in an array of `Shape` pointers and calling the `draw()` method on each object through the base class pointer.

***

