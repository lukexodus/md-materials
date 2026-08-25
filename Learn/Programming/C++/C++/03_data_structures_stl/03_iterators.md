## **Iterators**


Iterators in C++ are objects that allow traversal through containers like arrays, vectors, lists, and maps. They work similarly to pointers and provide a way to access container elements sequentially.

---

### **Types of Iterators**

C++ iterators can be categorized based on their functionality and direction:

| **Iterator Type**          | **Operations Supported**         | **Example Containers**     |
| -------------------------- | -------------------------------- | -------------------------- |
| **Input Iterator**         | Read-only, single-pass           | `istream_iterator`         |
| **Output Iterator**        | Write-only, single-pass          | `ostream_iterator`         |
| **Forward Iterator**       | Read/Write, single-pass          | `forward_list`             |
| **Bidirectional Iterator** | Read/Write, forward and backward | `list`, `map`              |
| **Random Access Iterator** | Read/Write, direct index access  | `vector`, `deque`, `array` |

---

### **Basic Iterator Usage**

**Example: Using Iterators with a `vector`**

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> numbers = {10, 20, 30, 40, 50};

    // Declaring an iterator
    std::vector<int>::iterator it;

    // Traversing using an iterator
    for (it = numbers.begin(); it != numbers.end(); ++it) {
        std::cout << *it << " ";
    }
}
```

**Output:**

```
10 20 30 40 50
```

✅ **`begin()`** points to the first element, and **`end()`** points to **one past** the last element.

---

### **`auto` Keyword with Iterators**

Instead of writing `std::vector<int>::iterator`, you can use `auto`:

```cpp
for (auto it = numbers.begin(); it != numbers.end(); ++it) {
    std::cout << *it << " ";
}
```

---

### **Reverse Iterators**

To traverse a container **backwards**, use `rbegin()` and `rend()`:

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> numbers = {10, 20, 30, 40, 50};

    for (auto it = numbers.rbegin(); it != numbers.rend(); ++it) {
        std::cout << *it << " ";
    }
}
```

**Output:**

```
50 40 30 20 10
```

---

### **Constant Iterators (`const_iterator`)**

If you don’t want to modify elements, use `const_iterator`:

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> numbers = {10, 20, 30, 40, 50};

    for (std::vector<int>::const_iterator it = numbers.cbegin(); it != numbers.cend(); ++it) {
        std::cout << *it << " ";
        // *it = 100;  // ❌ Compilation error (cannot modify)
    }
}
```

---

### **Iterator Invalidation**

Be careful when modifying a container while iterating. Some operations **invalidate** iterators.

✅ **Example: Safe deletion using `erase()`**

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> numbers = {10, 20, 30, 40, 50};

    for (auto it = numbers.begin(); it != numbers.end(); ) {
        if (*it == 30) {
            it = numbers.erase(it);  // `erase()` returns the next valid iterator
        } else {
            ++it;
        }
    }

    for (int num : numbers) {
        std::cout << num << " ";
    }
}
```

### **Output:**

```
10 20 40 50
```

❌ **Don't use an invalidated iterator (after `erase()`).**

**What is iterator invalidation?**

1. **What Happens During Invalidation**:
    - When a container is modified (for example, by adding or removing elements), the internal structure of the container may change. This can cause existing iterators to point to memory locations that are no longer valid.
    - For instance, if you remove an element from a vector, any iterators pointing to that element or any elements after it may become invalid.
2. **Types of Modifications That Cause Invalidation**:
    - **Insertion**: Adding elements can cause reallocation of memory, especially in dynamic arrays like `std::vector`. This can invalidate all iterators pointing to the vector.
    - **Deletion**: Removing elements can invalidate iterators pointing to the deleted element or any elements that follow it.
    - **Resizing**: Changing the size of a container can also lead to invalidation.
3. **Container-Specific Rules**:
    - Different containers have different rules regarding iterator invalidation. For example:
        - **`std::vector`**: Inserting or deleting elements can invalidate all iterators if the vector needs to reallocate memory.
        - **`std::list`**: Inserting or deleting elements does not invalidate iterators to other elements, as lists are implemented as linked structures.
        - **`std::deque`**: Similar to vectors, but the rules can vary based on the operation.
4. **Consequences of Using Invalidated Iterators**:
    - Using an invalidated iterator can lead to undefined behavior, which may manifest as crashes, incorrect data access, or other unpredictable outcomes.
5. **Best Practices**:
    - Always check the validity of iterators after modifying the container.
    - Use container-specific methods to safely manage iterators, such as `erase` returning a valid iterator to the next element after deletion.
    - Consider using higher-level abstractions or algorithms that manage iterators more safely.

Some operations **invalidate iterators** (make them unusable):

| **Operation** | **Affected Containers**   | **Invalidates Iterators?**   |
| ------------- | ------------------------- | ---------------------------- |
| `push_back()` | `vector`, `deque`         | Yes (if reallocation occurs) |
| `insert()`    | `vector`, `deque`, `list` | Yes                          |
| `erase()`     | `vector`, `deque`, `list` | Yes                          |
| `clear()`     | All containers            | Yes                          |

---

### **Random Access with Iterators (`vector`, `deque`, `array`)**

```cpp
std::vector<int>::iterator it = numbers.begin();
std::cout << *(it + 2);  // Access the 3rd element (random access)
```

This works only for **random access iterators**, like those in `vector` and `array`.

---

### **All Iterator Methods**

Iterators provide various methods/functions to traverse and manipulate elements in C++ containers. Below is a **comprehensive list** of iterator methods commonly used in C++ Standard Library (STL) containers.

---

#### **Common Iterator Methods**

These methods are available in **most containers** (`vector`, `list`, `map`, `set`, etc.).

| **Method**  | **Description**                                                   |
| ----------- | ----------------------------------------------------------------- |
| `begin()`   | Returns an iterator to the first element.                         |
| `end()`     | Returns an iterator **past the last element** (invalid position). |
| `rbegin()`  | Returns a reverse iterator to the **last** element.               |
| `rend()`    | Returns a reverse iterator **before the first** element.          |
| `cbegin()`  | Returns a **constant iterator** to the first element.             |
| `cend()`    | Returns a **constant iterator** past the last element.            |
| `crbegin()` | Returns a **constant reverse iterator** to the last element.      |
| `crend()`   | Returns a **constant reverse iterator** before the first element. |

✅ **Example:**

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> nums = {10, 20, 30, 40, 50};

    auto it = nums.begin();    // Iterator to first element
    auto rit = nums.rbegin();  // Reverse iterator to last element

    std::cout << *it << "\n";   // 10
    std::cout << *rit << "\n";  // 50
}
```

---

#### **Iterator Operations**

Iterator objects support **pointer-like operations**:

| **Operation** | **Description**                                             |
| ------------- | ----------------------------------------------------------- |
| `*it`         | Dereference to access the value.                            |
| `it->member`  | Access struct/class members using iterator.                 |
| `++it`        | Move forward (prefix increment).                            |
| `it++`        | Move forward (postfix increment).                           |
| `--it`        | Move backward (prefix decrement).                           |
| `it--`        | Move backward (postfix decrement).                          |
| `it + n`      | Move forward `n` positions (random access iterators only).  |
| `it - n`      | Move backward `n` positions (random access iterators only). |
| `it1 - it2`   | Get distance between two iterators.                         |
| `it1 == it2`  | Compare iterators (equality check).                         |
| `it1 != it2`  | Compare iterators (inequality check).                       |

✅ **Example:**

```cpp
#include <iostream>
#include <vector>

#include <string>

class Person {
public:
    std::string name;
    Person(std::string n) : name(n) {}
};

int main() {
    std::vector<int> nums = {10, 20, 30, 40, 50};
    
    auto it = nums.begin();
    std::cout << *(it + 2) << "\n";  // 30 (Random Access)
    
    ++it;   // Move forward
    std::cout << *it << "\n";  // 20

	std::vector<Person> people = { Person("Alice"), Person("Bob"), Person("Charlie") };

    for (auto it = people.begin(); it != people.end(); ++it) {
        std::cout << it->name << std::endl; // Accessing the 'name' member
    }
}
```

---

#### **Special Methods for Different Containers**

Some **container-specific** iterator methods:

|**Method**|**Container**|**Description**|
|---|---|---|
|`insert(it, value)`|`vector`, `list`, `deque`|Inserts value at iterator position.|
|`erase(it)`|`vector`, `list`, `deque`|Removes element at iterator position.|
|`erase(it1, it2)`|`vector`, `list`, `deque`|Removes a range of elements.|
|`find(value)`|`set`, `map`, `unordered_map`|Returns iterator to the value (or `end()` if not found).|
|`lower_bound(value)`|`set`, `map`|Returns iterator to first element **≥ value**.|
|`upper_bound(value)`|`set`, `map`|Returns iterator to first element **> value**.|

✅ **Example: Erasing Elements Safely**

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> nums = {10, 20, 30, 40, 50};

    auto it = nums.begin() + 2;  // Iterator to 30
    nums.erase(it);  // Remove 30

    for (int num : nums) {
        std::cout << num << " ";  // 10 20 40 50
    }
}
```

---

#### **Stream Iterators (`istream_iterator` and `ostream_iterator`)**

For reading/writing from streams:

✅ **Reading Input Using `istream_iterator`**

```cpp
#include <iostream>
#include <iterator>

int main() {
    std::istream_iterator<int> in(std::cin), end;
    int value = *in;  // Read integer input
    std::cout << "You entered: " << value << "\n";
}
```

✅ **Writing Output Using `ostream_iterator`**

```cpp
#include <iostream>
#include <iterator>
#include <vector>

int main() {
    std::vector<int> nums = {10, 20, 30};
    std::ostream_iterator<int> out(std::cout, " ");
    
    std::copy(nums.begin(), nums.end(), out);  // Print elements: 10 20 30
}
```

##### `std::copy`

`std::copy` is a standard algorithm in C++ that is used to copy elements from one range to another. It is part of the C++ Standard Library and is defined in the `<algorithm>` header. Here’s a detailed explanation of how it works and its usage.

**Function Signature**

The basic signature of `std::copy` is as follows:

```cpp
template<class InputIt, class OutputIt>
OutputIt copy(InputIt first, InputIt last, OutputIt d_first);
```

**Parameters**

- **`first`**: An iterator pointing to the beginning of the source range (the first element to copy).
- **`last`**: An iterator pointing to the end of the source range (one past the last element to copy).
- **`d_first`**: An iterator pointing to the beginning of the destination range where the elements will be copied.

**Return Value**

`std::copy` returns an iterator pointing to the end of the destination range, which is one past the last element copied. This allows you to easily determine where the copying has stopped.


***

