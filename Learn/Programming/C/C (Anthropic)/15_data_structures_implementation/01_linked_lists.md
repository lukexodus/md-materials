## Linked Lists


Linked lists are linear data structures where elements (nodes) are stored in sequence, with each node containing data and a reference (pointer) to the next node in the sequence.

### Singly Linked Lists

A singly linked list consists of nodes where each node points to the next node in the sequence, with the last node pointing to null.

**Structure:**

```
[Data|Next] -> [Data|Next] -> [Data|Next] -> NULL
```

**Implementation Components:**

- Node structure containing data field and next pointer
- Head pointer referencing the first node
- Basic operations: insertion, deletion, traversal, search

**Time Complexity:**

- Access: O(n)
- Search: O(n)
- Insertion: O(1) at head, O(n) at arbitrary position
- Deletion: O(1) at head, O(n) at arbitrary position

**Space Complexity:** O(n) where n is the number of elements

**Advantages:**

- Dynamic size allocation
- Efficient insertion and deletion at the beginning
- No memory waste (allocates exactly what's needed)

**Disadvantages:**

- No random access to elements
- Extra memory overhead for storing pointers
- Poor cache locality due to non-contiguous memory allocation

### Doubly Linked Lists

Doubly linked lists extend singly linked lists by adding a previous pointer to each node, allowing bidirectional traversal.

**Structure:**

```
NULL <- [Prev|Data|Next] <-> [Prev|Data|Next] <-> [Prev|Data|Next] -> NULL
```

**Additional Features:**

- Backward traversal capability
- More efficient deletion when node reference is known
- Easier implementation of certain algorithms

**Time Complexity:**

- Same as singly linked lists for most operations
- Deletion: O(1) when node reference is given

**Trade-offs:**

- Additional memory overhead for previous pointers
- Slightly more complex implementation
- Better flexibility for bidirectional operations

### Circular Linked Lists

Circular linked lists form a closed loop where the last node points back to the first node instead of null.

**Structure:**

```
[Data|Next] -> [Data|Next] -> [Data|Next] -> (back to first node)
```

**Characteristics:**

- No null pointers (except when empty)
- Continuous traversal possible
- Can be implemented as singly or doubly circular
- Useful for round-robin scheduling and cyclic data processing

**Special Considerations:**

- Traversal termination requires careful condition checking
- Memory management needs attention to prevent infinite loops during deletion

