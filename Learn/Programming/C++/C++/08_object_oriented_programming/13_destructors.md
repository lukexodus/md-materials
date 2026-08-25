## Destructors


**Key Points About Destructors**:

1. **Naming and Syntax:**
   - A destructor has the same name as the class, but it is preceded by a tilde `~`.
   - It takes no arguments and has no return type, not even `void`.

   **Example:**
   ```cpp
   class MyClass {
   public:
       ~MyClass() {
           // Destructor code here
       }
   };
   ```

2. **Automatic Invocation:**
   - A destructor is automatically called when:
     - An object goes out of scope (e.g., at the end of a block, like a function).
     - An object is explicitly deleted using the `delete` keyword for dynamically allocated objects.

3. **Resource Management:**
   - Destructors are often used to free resources that were acquired by the object, such as dynamically allocated memory.
   - If your class manages a resource, it should have a destructor to ensure that the resource is properly released.

   **Example with Dynamic Memory:**
   ```cpp
   class MyClass {
   private:
       int* data;
   public:
       MyClass(int size) {
           data = new int[size];  // Allocating memory
       }

       ~MyClass() {
           delete[] data;  // Releasing memory
       }
   };
   ```

4. **Order of Destruction:**
   - For local (stack-allocated) objects, destructors are called in the reverse order of their creation.
   - For class members, destructors are called in the reverse order of their declaration in the class.

5. **Base and Derived Classes:**
   - If a class is intended to be used as a base class, its destructor should be declared as `virtual`. This ensures that the destructor of the derived class is called when an object of the derived class is deleted through a pointer to the base class.

   **Example:**
   ```cpp
   class Base {
   public:
       virtual ~Base() {
           // Base class destructor
       }
   };

   class Derived : public Base {
   public:
       ~Derived() {
           // Derived class destructor
       }
   };

   void example() {
       Base* obj = new Derived();
       delete obj;  // Calls Derived's destructor, then Base's destructor
   }
   ```

6. **Rule of Three:**
   - If your class requires a destructor (usually because it manages resources like dynamic memory), it often also requires a copy constructor and a copy assignment operator. This is known as the Rule of Three.
   - With C++11, the Rule of Three is often extended to the Rule of Five, which includes the move constructor and move assignment operator.

7. **Default Destructor:**
   - If you do not explicitly define a destructor, the compiler generates a default destructor for you. This default destructor will properly clean up built-in types but won't manage any dynamically allocated resources, which may lead to memory leaks if your class allocates memory dynamically.

   **Example:**
   ```cpp
   class MyClass {
       // No explicit destructor defined
   };

   MyClass obj;  // Default destructor will be called automatically when obj goes out of scope
   ```

**Summary**:
- A destructor is a special member function in C++ that cleans up when an object is destroyed.
- It is automatically called when an object goes out of scope or is deleted.
- Destructors are essential for resource management, especially when dealing with dynamic memory.
- For classes intended to be base classes, always declare the destructor as `virtual` to ensure proper cleanup in derived classes.

***

