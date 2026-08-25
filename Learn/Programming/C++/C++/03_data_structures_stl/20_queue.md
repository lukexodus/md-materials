## queue


### Overview

A `queue` is a **FIFO (First-In, First-Out) container adapter** where elements are **added at the back** and **removed from the front**.

### Syntax

```cpp
#include <iostream>
#include <queue>

int main() {
    std::queue<int> q;

    // Enqueue elements
    q.push(10);
    q.push(20);
    q.push(30);

    // Front and back elements
    std::cout << "Front: " << q.front() << "\n";  // 10
    std::cout << "Back: " << q.back() << "\n";    // 30

    // Dequeue
    q.pop();  // Removes 10
    std::cout << "Front after pop: " << q.front() << "\n";  // 20

    return 0;
}
```

**Output:**

```
Front: 10  
Back: 30  
Front after pop: 20  
```

### Key Features

- **FIFO (First-In, First-Out) order.**
- **Efficient enqueue (`push`) and dequeue (`pop`) operations (`O(1)`).**
- **Only allows access to the front and back elements.**
- **Uses `deque` (default) or `list` as the underlying container.**

### Important Methods

#### Enqueue (Push to Back)

```cpp
q.push(42);  // Adds 42 to the back of the queue
```

#### Accessing Front and Back Elements

```cpp
std::cout << q.front();  // Retrieves the front element
std::cout << q.back();   // Retrieves the back element
```

#### Dequeue (Pop from Front)

```cpp
q.pop();  // Removes the front element
```

#### Checking Size

```cpp
std::cout << q.size();  // Returns number of elements in queue
```

#### Checking if Queue is Empty

```cpp
if (q.empty()) {
    std::cout << "Queue is empty\n";
}
```

### Custom Queue with `list` as Underlying Container

```cpp
std::queue<int, std::list<int>> q;
```

---

