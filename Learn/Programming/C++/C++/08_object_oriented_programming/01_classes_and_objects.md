## Classes and objects


### Classes:

- **Definition**: A class is a blueprint or template for creating objects. It defines the attributes (data) and behaviors (methods) that all objects of that class will have.
- **Purpose**: Classes provide a way to model real-world entities and encapsulate their properties and behaviors into a single entity.
- **Syntax**:
  ```cpp
  class ClassName {
  private:
      // Private members
  public:
      // Public members
  };
  ```
- **Example**:
  ```cpp
  class Car {
  private:
      std::string brand;
      int year;
  public:
      void setBrand(std::string b);
      void setYear(int y);
  };
  ```

### Objects:

- **Definition**: An object is an instance of a class. It represents a specific entity with its own state (attributes) and behavior (methods).
- **Purpose**: Objects allow us to create and manipulate instances of classes, providing a way to interact with the data and behaviors defined in the class.
- **Syntax**:
  ```cpp
  ClassName objectName;
  ```
- **Example**:
  ```cpp
  Car myCar; // Creating an object of class Car
  ```

**Key Points**:

- **Attributes**: Also known as data members or fields, attributes represent the state of an object.
- **Methods**: Also known as member functions, methods define the behavior of an object and allow it to perform actions and manipulate its state.

**Example**:

```cpp
#include <iostream>
#include <string>

class Car {
private:
    std::string brand;
    int year;
public:
    void setBrand(std::string b) {
        brand = b;
    }
    void setYear(int y) {
        year = y;
    }
    void displayInfo() {
        std::cout << "Brand: " << brand << ", Year: " << year << std::endl;
    }
};

int main() {
    Car myCar; // Creating an object of class Car
    myCar.setBrand("Toyota");
    myCar.setYear(2022);
    myCar.displayInfo();
    return 0;
}
```

In this example, `Car` is a class that represents a car entity. We create an object `myCar` of the `Car` class and use its methods to set and display information about the car.

### Direct Initialization

- **Syntax**:
    - The syntax for direct initialization looks like this:
```cpp
ClassName objectName(); // This is a declaration, not an instantiation
ClassName objectName;    // This is default initialization
ClassName objectName();   // This is direct initialization
```
        
- **Default Constructor**:
    - If you use empty parentheses, such as `ClassName objectName();`, it calls the default constructor of the class. However, be cautious, as this can sometimes lead to confusion due to the "Most Vexing Parse," where the compiler interprets this as a function declaration instead of an object instantiation.
- **Function Declaration vs. Object Instantiation**:
    - It's important to note that `ClassName objectName();` is interpreted as a function declaration that returns an object of type `ClassName` and takes no parameters, rather than creating an instance of the class. To avoid this ambiguity, you can use the following syntax:
```cpp
ClassName objectName; // This creates an instance of ClassName
```

***

