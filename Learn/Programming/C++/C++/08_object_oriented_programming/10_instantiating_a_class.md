## Instantiating a Class


### Instantiating a Class Regularly:

- **Syntax**:
  ```cpp
  ClassName objectName(parameters);
  ```
- **Automatic Allocation**: Allocates memory for the object on the stack.
- **Lifetime**: Object exists until the end of the scope where it's declared.
- **Automatic Cleanup**: Memory is automatically deallocated when the object goes out of scope.
- **Usage**:
  ```cpp
  objectName.memberFunction(); // Accessing member functions and attributes using the '.' operator
  ```
- **Common Use Cases**:
  - Objects with short lifetimes, scoped within a function or block.
  - Objects that don't need to be dynamically allocated.
### Instantiating a Class as a Pointer:

- **Syntax**:
  ```cpp
  ClassName* pointerName = new ClassName(parameters);
  ```
- **Dynamic Allocation**: Allocates memory for the object on the heap.
- **Lifetime**: Object exists until explicitly deleted using `delete` keyword.
- **Ownership**: The programmer is responsible for managing the object's memory (deallocation).
- **Usage**:
  ```cpp
  pointerName->memberFunction(); // Accessing member functions and attributes using '->' operator
  delete pointerName; // Explicitly deallocating memory
  ```
- **Common Use Cases**:
  - Objects whose lifetimes need to extend beyond their scope.
  - Objects that are part of a data structure like linked lists or trees.

#### Polymorphic Behavior:

- Polymorphic behavior allows objects of different derived classes to be treated as objects of the base class.
- To achieve polymorphism, you typically use pointers or references to the base class.
- When you call a virtual function through a base class pointer or reference, the correct function implementation based on the actual derived class type is invoked at runtime (dynamic dispatch).

#### Storing Objects in Data Structures:

- You can store objects of a class (instantiated regularly) in a data structure without using pointers.
- However, if you want to store objects of derived classes polymorphically, you need to use pointers or references to the base class.
- Storing objects by value (regular instantiation) in a data structure can lead to object slicing, where the derived class-specific attributes are lost when stored in a container that expects objects of the base class type.

**Example**:

```cpp
#include <iostream>
#include <vector>

class Base {
public:
    virtual void print() const {
        std::cout << "Base" << std::endl;
    }
};

class Derived : public Base {
public:
    void print() const override {
        std::cout << "Derived" << std::endl;
    }
};

int main() {
    // Using pointers for polymorphic behavior
    std::vector<Base*> objects;
    objects.push_back(new Base());
    objects.push_back(new Derived());

    for (auto obj : objects) {
        obj->print(); // Calls the correct print() based on the object type
        delete obj;   // Clean up allocated memory
    }

    // Storing objects by value
    std::vector<Base> objectsByValue;
    Base baseObj;
    Derived derivedObj;

    objectsByValue.push_back(baseObj);    // Slicing occurs
    objectsByValue.push_back(derivedObj); // Slicing occurs

    for (const auto& obj : objectsByValue) {
        obj.print(); // Calls the Base::print() function for all objects
    }

    return 0;
}
```

In this example:
- We use pointers to `Base` to store objects of different derived classes in a vector polymorphically.
- We demonstrate object slicing when storing objects by value in a vector of the base class. Only the base class part of the objects is retained.

**Guidelines**:

- Prefer regular instantiation (`ClassName objectName`) when possible, as it simplifies memory management and reduces the risk of memory-related errors.
- Use pointers (`ClassName* pointerName`) when dynamic memory allocation is necessary or when polymorphic behavior is required.

***

