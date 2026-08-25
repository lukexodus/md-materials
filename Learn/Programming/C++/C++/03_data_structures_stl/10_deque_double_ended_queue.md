## **Deque (Double-Ended Queue)**


The **`std::deque` (double-ended queue)** is a dynamic array-like container that allows **fast insertions and deletions from both ends**.

---

### **Key Features of `deque`**

| **Feature**                     | **Description**                                                                           |
| ------------------------------- | ----------------------------------------------------------------------------------------- |
| **Fast Insert/Remove**          | O(1) at both front and back (unlike `vector`, which is O(n) for front insertions).        |
| **Random Access**               | Provides **O(1) access** like `vector`.                                                   |
| **Dynamic Resizing**            | Grows automatically when needed, like `vector`.                                           |
| **Efficient Middle Operations** | Better than `vector`, but `list` is still better for frequent middle insertions/removals. |

---

### **Basic Usage of `deque`**

```cpp
#include <iostream>
#include <deque>

int main() {
    std::deque<int> dq = {10, 20, 30};

    dq.push_front(5);  // Insert at the front: {5, 10, 20, 30}
    dq.push_back(40);  // Insert at the back: {5, 10, 20, 30, 40}

    std::cout << "Front: " << dq.front() << "\n";  // 5
    std::cout << "Back: " << dq.back() << "\n";   // 40
}
```

---

### **`deque` Iterator Methods**

Like `vector`, `deque` supports **iterators**.

|**Method**|**Description**|
|---|---|
|`begin()`|Iterator to the first element.|
|`end()`|Iterator **past the last element**.|
|`rbegin()`|Reverse iterator to the last element.|
|`rend()`|Reverse iterator **before the first** element.|
|`cbegin()`|Constant iterator to the first element.|
|`cend()`|Constant iterator past the last element.|
|`crbegin()`|Constant reverse iterator to the last element.|
|`crend()`|Constant reverse iterator before the first element.|

✅ **Example: Using Iterators**

```cpp
#include <iostream>
#include <deque>

int main() {
    std::deque<int> dq = {10, 20, 30, 40};

    // Normal iteration
    for (auto it = dq.begin(); it != dq.end(); ++it) {
        std::cout << *it << " ";  // 10 20 30 40
    }

    std::cout << "\n";

    // Reverse iteration
    for (auto rit = dq.rbegin(); rit != dq.rend(); ++rit) {
        std::cout << *rit << " ";  // 40 30 20 10
    }
}
```

---

### **`deque` Methods**

#### **(A) Modifiers**

|**Method**|**Description**|
|---|---|
|`push_front(x)`|Insert `x` at the front.|
|`push_back(x)`|Insert `x` at the back.|
|`pop_front()`|Remove the first element.|
|`pop_back()`|Remove the last element.|
|`insert(it, x)`|Insert `x` at iterator `it` position.|
|`erase(it)`|Erase element at iterator `it` position.|
|`erase(it1, it2)`|Erase elements in the range `[it1, it2)`.|
|`clear()`|Remove all elements.|
|`resize(n)`|Resize `deque` to `n` elements.|

✅ **Example: Insertions and Deletions**

```cpp
#include <iostream>
#include <deque>

int main() {
    std::deque<int> dq = {10, 20, 30};

    dq.push_front(5);   // {5, 10, 20, 30}
    dq.push_back(40);   // {5, 10, 20, 30, 40}

    dq.pop_front();  // {10, 20, 30, 40}
    dq.pop_back();   // {10, 20, 30}

    dq.insert(dq.begin() + 1, 15);  // {10, 15, 20, 30}
    dq.erase(dq.begin());  // {15, 20, 30}

    for (int num : dq) {
        std::cout << num << " ";  // 15 20 30
    }
}
```

---

#### **(B) Access Methods**

|**Method**|**Description**|
|---|---|
|`front()`|Returns the first element.|
|`back()`|Returns the last element.|
|`at(i)`|Returns the element at index `i` with **bounds checking**.|
|`operator[i]`|Returns the element at index `i` **without bounds checking**.|

✅ **Example: Accessing Elements**

```cpp
#include <iostream>
#include <deque>

int main() {
    std::deque<int> dq = {10, 20, 30, 40};

    std::cout << dq.front() << "\n";  // 10
    std::cout << dq.back() << "\n";   // 40
    std::cout << dq[2] << "\n";       // 30
}
```

---

#### **(C) Capacity Methods**

| **Method**   | **Description**                                  |
| ------------ | ------------------------------------------------ |
| `size()`     | Returns the number of elements.                  |
| `max_size()` | Returns the maximum possible number of elements. |
| `empty()`    | Checks if `deque` is empty.                      |

✅ **Example: Checking Size and Emptiness**

```cpp
#include <iostream>
#include <deque>

int main() {
    std::deque<int> dq = {10, 20, 30};

    std::cout << dq.size() << "\n";  // 3
    std::cout << (dq.empty() ? "Empty" : "Not Empty") << "\n";  // Not Empty
}
```

---

### **`deque` vs `vector` vs `list`**

|**Feature**|**deque**|**vector**|**list**|
|---|---|---|---|
|**Random Access**|✅ Yes|✅ Yes|❌ No|
|**Fast Front Insert/Remove**|✅ Yes|❌ No|✅ Yes|
|**Fast Back Insert/Remove**|✅ Yes|✅ Yes|✅ Yes|
|**Memory Efficiency**|✅ Medium|✅ Best|❌ Worst|
|**Middle Insert/Remove**|✅ Medium|❌ Slow|✅ Fast|

👉 **Use `deque` when you need:**  
✅ **Fast insertions/removals at both ends** but still want **random access**.  
✅ A balance between **`vector` (fast access)** and **`list` (fast middle insertions)**.

---

**Summary**

✔ **`deque` is a hybrid of `vector` and `list`**, offering fast insertions/removals at both ends while allowing **O(1) random access**.  
✔ **Use `push_front()` and `push_back()`** for efficient insertions.  
✔ **Supports iterators** for traversal (`begin()`, `end()`, `rbegin()`, etc.).  
✔ **Middle insertions (`insert()`) are faster than `vector`, but `list` is still better**.  
✔ **Avoid using `deque` for large middle modifications** (use `list` instead).

---

