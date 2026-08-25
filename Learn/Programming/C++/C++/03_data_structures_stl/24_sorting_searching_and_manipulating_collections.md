## **Sorting, Searching, and Manipulating Collections**


C++ provides a rich set of functions for sorting, searching, and manipulating collections (containers like `vector`, `list`, `deque`, etc.) through the **Standard Template Library (STL)**. These operations improve performance and reduce the need for manual implementations.

---

### **Sorting Collections**

#### **Using `std::sort()` (Efficient QuickSort-based Algorithm)**

✅ **Sorts a range in ascending order (default)**

```cpp
#include <iostream>
#include <vector>
#include <algorithm> 
using namespace std;

int main() {
    vector<int> v = {5, 2, 9, 1, 5, 6};
    
    sort(v.begin(), v.end());  // Sorts in ascending order

    for (int x : v) cout << x << " ";
}
```

**Output:**

```
1 2 5 5 6 9
```

✅ **Sort in Descending Order**

```cpp
sort(v.begin(), v.end(), greater<int>());
```

✅ **Custom Comparator (Sort by Absolute Value)**

```cpp
sort(v.begin(), v.end(), [](int a, int b) { return abs(a) < abs(b); });
```

---

### **Searching in Collections**

#### **Using `std::binary_search()` (Fast Logarithmic Search)**

✅ **Check if an element exists (Requires Sorted Collection)**

```cpp
sort(v.begin(), v.end());
bool found = binary_search(v.begin(), v.end(), 5);
cout << (found ? "Found" : "Not Found");
```

#### **Using `std::find()` (Linear Search for Any Container)**

✅ **Find an Element in Any Collection**

```cpp
auto it = find(v.begin(), v.end(), 9);
if (it != v.end()) cout << "Element found at index " << distance(v.begin(), it);
```

#### **Using `std::lower_bound()` and `std::upper_bound()`**

✅ **Find First Occurrence of an Element (Sorted Collections Only)**

```cpp
auto it = lower_bound(v.begin(), v.end(), 5);  // First element >= 5
```

✅ **Find Next Greater Element After a Given Value**

```cpp
auto it = upper_bound(v.begin(), v.end(), 5);  // First element > 5
```

---

### **Manipulating Collections**

#### **Reversing a Collection**

✅ **Using `std::reverse()`**

```cpp
reverse(v.begin(), v.end());
```

#### **Rotating Elements**

✅ **Using `std::rotate()`**

```cpp
rotate(v.begin(), v.begin() + 2, v.end());  // Moves first 2 elements to the end
```

#### **Shuffling Elements (Randomizing Order)**

✅ **Using `std::shuffle()`**

```cpp
#include <random>
random_device rd;
mt19937 g(rd());
shuffle(v.begin(), v.end(), g);
```

#### **Removing Duplicates from Sorted Collection**

✅ **Using `std::unique()`**

```cpp
v.erase(unique(v.begin(), v.end()), v.end());
```

---

### **Key Points**

✅ **Use `std::sort()` for efficient sorting; it defaults to ascending order.**  
✅ **Use `std::binary_search()` for fast searches in sorted collections.**  
✅ **Use `std::find()` for searching in any container.**  
✅ **Use `std::reverse()`, `std::rotate()`, and `std::shuffle()` for collection manipulation.**  
✅ **Use `std::unique()` to remove consecutive duplicates efficiently.**

🚀 **These functions provide optimized performance, reducing the need for manual algorithms!**

---

