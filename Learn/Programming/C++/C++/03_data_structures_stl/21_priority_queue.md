## priority_queue


### Overview

A `priority_queue` is a **heap-based container adapter** that **stores elements in sorted order** such that the largest (or smallest) element is always at the top.

By default, it is a **max-heap**, meaning the largest element has the highest priority.

### Syntax

```cpp
#include <iostream>
#include <queue>

int main() {
    std::priority_queue<int> pq;

    // Insert elements
    pq.push(10);
    pq.push(30);
    pq.push(20);

    // Retrieve the top element (highest priority)
    std::cout << "Top: " << pq.top() << "\n";  // 30

    // Remove the top element
    pq.pop();
    std::cout << "Top after pop: " << pq.top() << "\n";  // 20

    return 0;
}
```

**Output:**

```
Top: 30  
Top after pop: 20  
```

### Key Features

- **Uses a binary heap (by default, max-heap).**
- **Elements are sorted automatically on insertion.**
- **Retrieving (`top`) and removing (`pop`) the highest-priority element takes `O(log n)`.**
- **Efficient for scenarios requiring frequent access to the highest or lowest value.**

### Important Methods

#### Insert Element

```cpp
pq.push(42);  // Inserts 42 into the priority_queue
```

#### Retrieve the Highest Priority Element

```cpp
std::cout << pq.top();  // Returns the highest priority element
```

#### Remove the Highest Priority Element

```cpp
pq.pop();  // Removes the highest priority element
```

#### Check Size

```cpp
std::cout << pq.size();  // Returns the number of elements
```

#### Check if Empty

```cpp
if (pq.empty()) {
    std::cout << "Priority queue is empty\n";
}
```

### Min-Heap (Smallest Element First)

By default, `priority_queue` is a **max-heap** (largest element first). To create a **min-heap**, use `greater<T>`:

```cpp
std::priority_queue<int, std::vector<int>, std::greater<int>> minHeap;
```

**Example:**

```cpp
#include <iostream>
#include <queue>

int main() {
    std::priority_queue<int, std::vector<int>, std::greater<int>> minHeap;
    minHeap.push(10);
    minHeap.push(30);
    minHeap.push(20);

    std::cout << "Top: " << minHeap.top() << "\n";  // 10

    return 0;
}
```

**Output:**

```
Top: 10  
```

---

