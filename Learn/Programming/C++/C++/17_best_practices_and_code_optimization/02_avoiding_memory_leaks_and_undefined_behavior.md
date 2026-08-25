## **Avoiding Memory Leaks and Undefined Behavior**


Memory management is critical in C++. Failing to handle memory properly can lead to **memory leaks, dangling pointers, and undefined behavior**, causing crashes or unpredictable program execution.

---

### **1. Preventing Memory Leaks**

A **memory leak** occurs when dynamically allocated memory is not released, leading to increasing memory usage over time.

✅ **Always `delete` dynamically allocated memory**

```cpp
int* ptr = new int(10);
delete ptr;  // Free the memory
ptr = nullptr;  // Avoid dangling pointer
```

✅ **Use Smart Pointers (`std::unique_ptr`, `std::shared_ptr`)**  
Smart pointers **automatically manage memory** and prevent leaks.

```cpp
#include <memory>
std::unique_ptr<int> ptr = std::make_unique<int>(10);  // No manual delete needed
```

✅ **Avoid memory leaks in loops**

```cpp
for (int i = 0; i < 100; i++) {
    int* ptr = new int(10);
    delete ptr;  // Free memory inside loop
}
```

✅ **Use `valgrind` to detect leaks**

```sh
valgrind --leak-check=full ./program
```

---

### **2. Avoiding Dangling Pointers**

A **dangling pointer** points to memory that has been freed.

❌ **Incorrect Usage**

```cpp
int* ptr = new int(10);
delete ptr;  // Memory freed
cout << *ptr;  // Undefined behavior! Accessing freed memory
```

✅ **Solution: Set pointers to `nullptr` after `delete`**

```cpp
int* ptr = new int(10);
delete ptr;
ptr = nullptr;  // Safe to check later
```

✅ **Use Smart Pointers** – They automatically clean up memory.

---

### **3. Avoiding Double `delete`**

Calling `delete` twice on the same pointer leads to **undefined behavior**.

❌ **Incorrect Usage**

```cpp
int* ptr = new int(10);
delete ptr;
delete ptr;  // ERROR: Double delete!
```

✅ **Solution: Set pointer to `nullptr`**

```cpp
int* ptr = new int(10);
delete ptr;
ptr = nullptr;  // Second delete has no effect
```

---

### **4. Avoiding Use of Uninitialized Pointers**

❌ **Incorrect Usage**

```cpp
int* ptr;  // Uninitialized
*ptr = 10;  // Undefined behavior
```

✅ **Solution: Initialize pointers**

```cpp
int* ptr = nullptr;
```

---

### **5. Preventing Buffer Overflows and Array Out-of-Bounds Access**

❌ **Incorrect Usage**

```cpp
int arr[5] = {1, 2, 3, 4, 5};
cout << arr[10];  // ERROR: Accessing out of bounds!
```

✅ **Solution: Use `std::vector` for safety**

```cpp
#include <vector>
std::vector<int> vec = {1, 2, 3, 4, 5};
cout << vec.at(4);  // Safe access
```

✅ **Use Bounds Checking Tools**  
Enable **AddressSanitizer** to catch out-of-bounds errors.

```sh
g++ -fsanitize=address -g program.cpp -o program
./program
```

---

### **6. Detecting and Avoiding Undefined Behavior**

**Undefined Behavior (UB)** happens when the program does something that is not well-defined by the C++ standard.

✅ **Common Causes of UB**

- Dereferencing `nullptr`
- Using an uninitialized variable
- Accessing out-of-bounds memory
- Signed integer overflow

✅ **Use Compiler Flags to Detect Issues**

```sh
g++ -Wall -Wextra -Werror program.cpp
```

✅ **Use Static Analysis Tools**

```sh
clang-tidy program.cpp
cppcheck program.cpp
```

---

### **7. Using RAII (Resource Acquisition Is Initialization)**

RAII ensures **automatic resource cleanup** using objects' destructors.

✅ **Example: Managing File Handles Safely**

```cpp
#include <fstream>
void writeFile() {
    std::ofstream file("data.txt");  // Automatically closed when out of scope
    file << "Hello, world!";
}  // No need for manual `close()`
```


***

