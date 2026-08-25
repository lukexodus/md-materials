## stack


### Overview

A `stack` is a **container adapter** that follows the **LIFO (Last-In, First-Out) principle**. Elements are added and removed from the **top** only.

### Syntax

```cpp
#include <iostream>
#include <stack>

int main() {
    std::stack<int> s;

    // Pushing elements
    s.push(10);
    s.push(20);
    s.push(30);

    // Accessing top element
    std::cout << "Top: " << s.top() << "\n";  // 30

    // Popping elements
    s.pop();  // Removes 30
    std::cout << "Top after pop: " << s.top() << "\n";  // 20

    return 0;
}
```

**Output:**

```
Top: 30  
Top after pop: 20  
```

### Key Features

- **LIFO (Last-In, First-Out) order.**
- **Only allows access to the top element.**
- **Efficient push/pop operations (`O(1)`).**
- **Uses `deque` (default), `vector`, or `list` as the underlying container.**

### Important Methods

#### Pushing Elements

```cpp
s.push(42);  // Adds 42 to the top
```

#### Accessing the Top Element

```cpp
std::cout << s.top();  // Retrieves the top element without removing it
```

#### Popping Elements

```cpp
s.pop();  // Removes the top element
```

#### Checking Size

```cpp
std::cout << s.size();  // Returns number of elements in stack
```

#### Checking if Stack is Empty

```cpp
if (s.empty()) {
    std::cout << "Stack is empty\n";
}
```

### Custom Stack with `list` as Underlying Container

```cpp
std::stack<int, std::list<int>> s;
```

---

