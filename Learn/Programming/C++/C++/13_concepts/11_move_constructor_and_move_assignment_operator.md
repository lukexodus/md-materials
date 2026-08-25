## **Move Constructor and Move Assignment Operator**


Move semantics **transfer ownership** of resources instead of copying them. This is useful in **resource-intensive** operations (e.g., dynamic memory, file handles).

### **Move Constructor (`T(T&&)`)**

Moves resources from a temporary object, leaving the source in a valid but unspecified state.

### **Move Assignment (`operator=(T&&)`)**

Transfers resources from an existing object to another, avoiding deep copies.

✅ **Example: Move Semantics in Action**

```cpp
#include <iostream>
#include <cstring>
using namespace std;

class String {
private:
    char* data;
public:
    String(const char* str) {  // Constructor
        data = new char[strlen(str) + 1];
        strcpy(data, str);
        cout << "Created: " << data << endl;
    }

    // Move Constructor
    String(String&& other) noexcept {
        data = other.data;
        other.data = nullptr;
        cout << "Moved\n";
    }

    // Move Assignment Operator
    String& operator=(String&& other) noexcept {
        if (this != &other) {
            delete[] data;  // Clean up existing resource
            data = other.data;
            other.data = nullptr;
            cout << "Moved via Assignment\n";
        }
        return *this;
    }

    void show() { cout << (data ? data : "Empty") << endl; }

    ~String() { delete[] data; }
};

int main() {
    String s1("Hello");
    String s2 = move(s1); // Move Constructor
    s2.show();
    s1.show();  // Should be empty

    String s3("World");
    s3 = move(s2);  // Move Assignment
    s3.show();
    s2.show();  // Should be empty

    return 0;
}
```

**Output:**

```
Created: Hello
Moved
Hello
Empty
Created: World
Moved via Assignment
Hello
Empty
```

---

**Key Points**

✅ **Rvalue references (`&&`)** enable moving instead of copying.  
✅ **Move constructor (`T(T&&)`)** transfers ownership of resources.  
✅ **Move assignment operator (`operator=(T&&)`)** moves an existing object’s resources.  
✅ **Use `std::move(obj)`** to convert an lvalue into an rvalue for moving.


---

