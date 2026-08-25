## **`forward_list`**


`std::forward_list` is a **singly linked list** in C++ that provides **fast insertion and deletion** at any position but does not support direct access like a vector or a `std::list`. Unlike `std::list`, it only maintains a **single pointer to the next node**, making it **memory efficient** but **less flexible** in bidirectional traversal.

---

### **Header File**

```cpp
#include <forward_list>
```

---

### **Creating a `forward_list`**

✅ **Basic Declaration and Initialization**

```cpp
#include <iostream>
#include <forward_list>
using namespace std;

int main() {
    forward_list<int> fl = {10, 20, 30, 40};

    for (int x : fl) cout << x << " ";
}
```

**Output:**

```
10 20 30 40
```

✅ **Default Constructor**

```cpp
forward_list<int> fl; // Empty forward_list
```

✅ **Custom Size with Default Values**

```cpp
forward_list<int> fl(5, 100); // 5 elements, each initialized to 100
```

---

### **Modifying a `forward_list`**

#### **Adding Elements**

✅ **`push_front(value)` – Insert at the front**

```cpp
fl.push_front(5);  // Adds 5 at the beginning
```

✅ **`emplace_front(value)` – Faster insertion at the front**

```cpp
fl.emplace_front(2);  // Similar to push_front but avoids extra copying
```

✅ **`insert_after(iterator, value)` – Insert after a given position**

```cpp
auto it = fl.before_begin(); // Iterator before first element
fl.insert_after(it, 15);  // Inserts 15 after first element
```

✅ **`emplace_after(iterator, value)` – Construct element after iterator**

```cpp
fl.emplace_after(it, 25);  // Faster insertion
```

#### **Removing Elements**

✅ **`pop_front()` – Remove first element**

```cpp
fl.pop_front();  // Removes the first element
```

✅ **`erase_after(iterator)` – Remove after a given position**

```cpp
fl.erase_after(fl.before_begin());  // Removes the element after the first
```

✅ **`remove(value)` – Remove all elements with a specific value**

```cpp
fl.remove(30);  // Removes all occurrences of 30
```

✅ **`remove_if(condition)` – Remove elements based on a condition**

```cpp
fl.remove_if([](int x) { return x % 2 == 0; }); // Removes all even numbers
```

---

### **Accessing Elements**

Since `forward_list` does not support random access (`[]` or `.at()`), we must **iterate over it manually**.

✅ **Using a Range-based Loop**

```cpp
for (int x : fl) cout << x << " ";
```

✅ **Using an Iterator**

```cpp
for (auto it = fl.begin(); it != fl.end(); ++it)
    cout << *it << " ";
```

---

### **Other Operations**

✅ **`assign()` – Assign new values**

```cpp
fl.assign({1, 2, 3, 4});
```

✅ **`reverse()` – Reverse the order**

```cpp
fl.reverse();
```

✅ **`sort()` – Sort in ascending order**

```cpp
fl.sort();
```

✅ **`merge(other_list)` – Merge two sorted lists**

```cpp
forward_list<int> fl2 = {5, 15, 25};
fl.merge(fl2);  // Both lists must be sorted
```

✅ **`unique()` – Remove consecutive duplicates**

```cpp
fl.unique();  // Removes consecutive duplicates only
```

---

### **Key Points**

✅ **`forward_list` is a singly linked list (more memory efficient than `list`).**  
✅ **Supports fast insertions and deletions but lacks random access.**  
✅ **Operations like `push_front()`, `pop_front()`, `insert_after()`, and `erase_after()` modify elements efficiently.**  
✅ **Sorting, merging, and reversing are available.**  
✅ **Ideal for scenarios requiring frequent insertions/deletions but not random access.**

🚀 **Use `forward_list` for optimized memory usage when you don’t need bidirectional traversal!**

---

