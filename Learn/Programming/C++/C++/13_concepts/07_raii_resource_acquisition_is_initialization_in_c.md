## **RAII (Resource Acquisition Is Initialization) in C++**


### **What is RAII?**

RAII (**Resource Acquisition Is Initialization**) is a **C++ memory management** technique that ensures resources (memory, file handles, sockets, etc.) are **acquired in a constructor** and **automatically released in a destructor**.

RAII is primarily used to prevent **resource leaks** and enforce **exception safety** by **binding resource lifetimes to object lifetimes**.

---

### **How RAII Works**

RAII relies on **constructor/destructor pairs**:

- The **constructor** acquires the resource (e.g., allocates memory, opens a file).
- The **destructor** releases the resource (e.g., deallocates memory, closes a file).

Since **C++ automatically calls destructors when objects go out of scope**, this ensures that resources are properly released.

---

### **Example: Managing Dynamic Memory (Without RAII vs. With RAII)**

#### **❌ Without RAII (Memory Leak Risk)**

```cpp
#include <iostream>
using namespace std;

void allocateMemory() {
    int* arr = new int[10];  // Dynamically allocated array
    // ❌ No delete[] call → Memory Leak!
}

int main() {
    allocateMemory();
    return 0;  // Memory leak occurs!
}
```

- The `new` operator allocates memory, but since there's **no `delete[]` call**, the memory is **never freed**, causing a **leak**.

---

#### **✅ With RAII (Using a Smart Pointer)**

```cpp
#include <iostream>
#include <memory>  // For smart pointers
using namespace std;

void allocateMemory() {
    unique_ptr<int[]> arr = make_unique<int[]>(10);  // Automatically freed!
}

int main() {
    allocateMemory();  // No memory leak
    return 0;
}
```

- **`unique_ptr`** automatically releases memory when it goes out of scope.
- **No need** for manual `delete[]`.
- **Prevents memory leaks**.

---

### **RAII in File Handling**

#### **❌ Without RAII (File Not Closed Properly)**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

void writeFile() {
    ofstream file("example.txt");
    if (!file.is_open()) {
        cout << "Failed to open file!" << endl;
        return;
    }
    file << "Hello, RAII!";
    // ❌ If an exception occurs, the file might not be closed properly!
}

int main() {
    writeFile();
    return 0;
}  // File may not close properly in case of an error!
```

---

#### **✅ With RAII (Using fstream)**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

void writeFile() {
    ofstream file("example.txt");  // RAII handles file opening
    if (!file) {
        cout << "Failed to open file!" << endl;
        return;
    }
    file << "Hello, RAII!";  
}  // File automatically closed when going out of scope

int main() {
    writeFile();
    return 0;
}
```

- **`ofstream` automatically closes the file** when `file` goes out of scope.
- Prevents **file resource leaks**.

---

### **Implementing a Custom RAII Wrapper Class**

RAII can be implemented with **custom classes** that handle resources.

**Example: Managing Dynamic Memory with RAII**

```cpp
#include <iostream>
using namespace std;

class RAII_Array {
private:
    int* data;

public:
    // Constructor: Acquires resource
    RAII_Array(int size) {
        data = new int[size];
        cout << "Memory allocated!" << endl;
    }

    // Destructor: Releases resource
    ~RAII_Array() {
        delete[] data;
        cout << "Memory freed!" << endl;
    }
};

int main() {
    {
        RAII_Array arr(10);  // Memory allocated
    }  // Memory freed when arr goes out of scope

    return 0;
}
```

**Output:**

```
Memory allocated!
Memory freed!
```

- **Automatic memory cleanup** when the object goes out of scope.
- **No need** to manually delete the array.

---

### **RAII and Smart Pointers**

Modern C++ provides **smart pointers (`unique_ptr`, `shared_ptr`)** that use RAII for **safe resource management**.

**Example: Using `unique_ptr`**

```cpp
#include <iostream>
#include <memory>
using namespace std;

void useSmartPointer() {
    unique_ptr<int> ptr = make_unique<int>(100);
    cout << "Value: " << *ptr << endl;
}  // Automatically freed here!

int main() {
    useSmartPointer();
    return 0;
}
```

- **No manual `delete` required**.
- **Ensures proper cleanup**.

---

**Key Benefits of RAII**

✅ **Automatic resource management** (prevents memory leaks).  
✅ **Exception safety** (destructors are always called).  
✅ **Simplifies code** (no need for explicit `delete` calls).  
✅ **Works with multiple resource types** (memory, files, sockets).

---

