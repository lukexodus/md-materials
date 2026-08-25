## `static` Keyword


In C++, the `static` keyword has multiple uses, each affecting different aspects of variable and function storage, lifetime, and visibility. Here’s a detailed explanation of the different uses of `static`:

### 1. **Static Variables in Functions**

**Definition:**
- A static variable inside a function retains its value between function calls. It is initialized only once and exists for the lifetime of the program.

**Characteristics:**
- **Lifetime:** Exists from the first time it is initialized until the end of the program.
- **Visibility:** Only visible within the function where it is declared.

**Example:**
```cpp
void counter() {
    static int count = 0; // Static local variable
    ++count;
    std::cout << count << std::endl;
}
```

**Behavior:**
- The `count` variable retains its value between calls to `counter()`. Each call to `counter()` increments `count` from its previous value.

### 2. **Static Variables in Classes**

**Definition:**
- A static member variable of a class is shared among all instances of that class. It is not tied to any specific object.

**Characteristics:**
- **Lifetime:** Exists for the lifetime of the program, similar to global variables.
- **Visibility:** Can be accessed using the class name or an object of the class.

**Example:**
```cpp
class MyClass {
public:
    static int staticVar; // Static member variable
};

// Definition outside the class
int MyClass::staticVar = 0;

void updateStaticVar() {
    MyClass::staticVar = 5; // Accessed using the class name
}
```

**Behavior:**
- `staticVar` is shared across all instances of `MyClass` and can be accessed using the class name or any instance of the class.

### 3. **Static Member Functions in Classes**

**Definition:**
- A static member function belongs to the class rather than any specific object. It can only access static member variables and functions.

**Characteristics:**
- **Lifetime:** Exists for the lifetime of the program.
- **Visibility:** Can be called using the class name without needing an instance.

**Example:**
```cpp
class MyClass {
public:
    static void staticMethod() {
        std::cout << "Static method called" << std::endl;
    }
};

void callStaticMethod() {
    MyClass::staticMethod(); // Call using the class name
}
```

**Behavior:**
- `staticMethod` can be called without creating an instance of `MyClass`.

### 4. **Static Variables in Global Scope (File Scope)**

**Definition:**
- A global variable or function declared with `static` is restricted to the file in which it is declared. It is not visible outside of that file, providing internal linkage.

**Characteristics:**
- **Lifetime:** Exists for the lifetime of the program.
- **Visibility:** Limited to the file where it is declared, preventing name conflicts with global variables or functions in other files.

**Example:**
```cpp
// file1.cpp
static int fileVar = 10; // Static global variable

void fileFunction() {
    // Can access fileVar
}

// file2.cpp
extern void fileFunction(); // Declaration only
```

**Behavior:**
- `fileVar` in `file1.cpp` is not visible to `file2.cpp`, preventing potential conflicts.

**Summary**

- **Static Variables in Functions**: Retain their value across function calls and are only visible within the function.
- **Static Variables in Classes**: Shared among all instances of the class and accessible using the class name or an object.
- **Static Member Functions**: Belong to the class rather than any instance and can only access static members of the class.
- **Static Variables in Global Scope**: Have file scope, preventing visibility and linkage outside the file in which they are declared.

***

