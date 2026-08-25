## Queues Implementation


Queues follow the First-In-First-Out (FIFO) principle, where elements are added at the rear and removed from the front.

**Core Operations:**

- Enqueue: Add element to rear
- Dequeue: Remove element from front
- Front: View front element without removing
- Rear: View rear element without removing
- IsEmpty: Check if queue is empty
- Size: Get number of elements

**Array-Based Implementation:**

- Uses circular array to avoid shifting elements
- Maintains front and rear pointers
- Efficient space utilization
- Fixed capacity limitation

**Linked List-Based Implementation:**

- Uses linked list with separate front and rear pointers
- Dynamic size allocation
- No capacity restrictions
- Additional memory overhead for pointers

**Circular Queue:**

- Array-based implementation that wraps around
- Efficient memory usage
- Prevents array shifting operations
- Requires careful index management

**Time Complexity:**

- Enqueue: O(1)
- Dequeue: O(1)
- Front/Rear access: O(1)

**Space Complexity:** O(n) for n elements

**Applications:**

- Process scheduling in operating systems
- Buffer for data streams
- Breadth-first search algorithms
- Print job management
- Handling requests in web servers

