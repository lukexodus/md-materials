## Stacks Implementation


Stacks follow the Last-In-First-Out (LIFO) principle, where elements are added and removed from the same end called the top.

**Core Operations:**

- Push: Add element to top
- Pop: Remove element from top
- Peek/Top: View top element without removing
- IsEmpty: Check if stack is empty
- Size: Get number of elements

**Array-Based Implementation:**

- Uses fixed-size array with top index tracker
- Simple and memory-efficient
- Limited by predefined capacity
- Risk of stack overflow

**Linked List-Based Implementation:**

- Uses linked list with head as stack top
- Dynamic size allocation
- No size limitations (except available memory)
- Additional pointer overhead

**Time Complexity:**

- Push: O(1)
- Pop: O(1)
- Peek: O(1)
- Search: O(n) [Inference - not typically supported operation]

**Space Complexity:** O(n) for n elements

**Applications:**

- Function call management (call stack)
- Expression evaluation and syntax parsing
- Undo operations in applications
- Backtracking algorithms
- Browser history management

