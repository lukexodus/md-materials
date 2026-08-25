## Variable Scopes


In C++, the concept of scope refers to the region of a program where a particular identifier (e.g., variable or function name) is accessible. Different types of scopes control the visibility and lifetime of variables and functions. Here’s a detailed explanation of the various scopes in C++:

### 1. **File Scope**

**Definition:**
- File scope (also known as global scope) refers to the scope of identifiers declared outside of any functions or classes. These identifiers are accessible throughout the entire file in which they are declared and can be made accessible to other files using the `extern` keyword.

**Characteristics:**
- **Global Variables:** Variables declared outside of functions and classes.
- **Global Functions:** Functions declared outside of any class or function.

**Example:**
```cpp
// file1.cpp
int globalVar = 10; // File scope

void globalFunction() {
    // Can access globalVar
}
```

**Access from Other Files:**
```cpp
// file2.cpp
extern int globalVar; // Declaration of globalVar from file1.cpp

void anotherFunction() {
    // Can access globalVar
}
```

### 2. **Block Scope**

**Definition:**
- Block scope refers to identifiers declared inside a block of code enclosed by curly braces `{}`. These identifiers are only accessible within that block.

**Characteristics:**
- **Local Variables:** Variables declared inside a function or any block (e.g., loops, conditionals).
- **Parameters:** Parameters of functions and blocks have block scope.

**Example:**
```cpp
void exampleFunction() {
    int localVar = 5; // Block scope
    if (true) {
        int blockVar = 10; // Block scope
        // Can access localVar and blockVar
    }
    // Cannot access blockVar here
}
```

### 3. **Class Scope**

**Definition:**
- Class scope refers to identifiers declared within a class. These identifiers are accessible from within the class and its member functions.

**Characteristics:**
- **Member Variables:** Variables declared within a class.
- **Member Functions:** Functions declared within a class.
- **Access Specifiers:** Members can be public, protected, or private, affecting their accessibility.

**Example:**
```cpp
class MyClass {
public:
    int publicVar; // Class scope

private:
    int privateVar; // Class scope
    void privateMethod() { /*...*/ }
};
```

### 4. **Function Prototype Scope**

**Definition:**
- Function prototype scope refers to the scope within the prototype declaration of a function. It specifies the types of arguments and return type but does not define the function body.

**Characteristics:**
- **Function Parameters:** Variables declared within the function prototype.
- **Limited Scope:** The parameters are only visible within the function prototype.

**Example:**
```cpp
void myFunction(int a, double b); // Function prototype

// Parameters 'a' and 'b' are only visible in the function prototype
```

### 5. **Function Scope**

**Definition:**
- Function scope refers to identifiers declared within a function. These variables are only accessible within that function.

**Characteristics:**
- **Function Local Variables:** Variables declared inside the function body.
- **Function Parameters:** Parameters of the function are also in function scope.

**Example:**
```cpp
void myFunction(int a) {
    int localVar = 5; // Function scope
    // Can access a and localVar
    // Cannot access a or localVar outside this function
}
```

**Summary**

- **File Scope**: Identifiers declared outside functions and classes, accessible throughout the file and potentially across files (with `extern`).
- **Block Scope**: Identifiers declared within a block of code (e.g., inside a function or loop), accessible only within that block.
- **Class Scope**: Identifiers declared within a class, accessible within the class and its member functions, subject to access specifiers.
- **Function Prototype Scope**: The scope within the function prototype; parameters are visible only in the prototype.
- **Function Scope**: Identifiers declared within a function, accessible only within that function.

***

