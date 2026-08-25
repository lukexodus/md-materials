## `std::collections`


`std::collections` is Rust’s standard library module that provides various collection types, including vectors, hash maps, and linked lists. These collections help manage and manipulate groups of data efficiently.

---

### **Common Collections in `std::collections`**

#### **1. `VecDeque<T>` (Double-ended queue)**

A queue that allows efficient addition and removal from both ends.

```rust
use std::collections::VecDeque;

let mut deque: VecDeque<i32> = VecDeque::new();
deque.push_back(1);
deque.push_front(2);
println!("{:?}", deque); // Output: [2, 1]
```

---

#### **2. `LinkedList<T>` (Doubly linked list)**

A doubly linked list allowing efficient insertions and removals anywhere.

```rust
use std::collections::LinkedList;

let mut list = LinkedList::new();
list.push_back(1);
list.push_front(2);
println!("{:?}", list); // Output: [2, 1]
```

---

#### **3. `HashMap<K, V>` (Key-value store with hashing)**

A collection of key-value pairs using a hash table.

```rust
use std::collections::HashMap;

let mut map = HashMap::new();
map.insert("apple", 3);
map.insert("banana", 5);
println!("{:?}", map.get("apple")); // Output: Some(3)
```

---

#### **4. `BTreeMap<K, V>` (Ordered key-value store)**

A key-value store that maintains sorted order.

```rust
use std::collections::BTreeMap;

let mut map = BTreeMap::new();
map.insert(2, "two");
map.insert(1, "one");
println!("{:?}", map); // Output: {1: "one", 2: "two"}
```

---

#### **5. `HashSet<T>` (Unordered collection of unique values)**

A set that stores unique values using hashing.

```rust
use std::collections::HashSet;

let mut set = HashSet::new();
set.insert(10);
set.insert(20);
set.insert(10); // Duplicate ignored
println!("{:?}", set); // Output: {10, 20}
```

---

#### **6. `BTreeSet<T>` (Ordered set of unique values)**

A set that stores unique values in a sorted order.

```rust
use std::collections::BTreeSet;

let mut set = BTreeSet::new();
set.insert(5);
set.insert(1);
set.insert(3);
println!("{:?}", set); // Output: {1, 3, 5}
```

---

#### **7. `BinaryHeap<T>` (Max-heap or min-heap)**

A priority queue implemented as a binary heap.

```rust
use std::collections::BinaryHeap;

let mut heap = BinaryHeap::new();
heap.push(3);
heap.push(5);
heap.push(1);
println!("{:?}", heap.pop()); // Output: Some(5) (largest value)
```

#### **8. `TryReserveError`**

An error type returned when memory allocation fails in collections like `Vec`, `HashMap`, etc.

```rust
use std::collections::TryReserveError;

fn allocate_large_vector() -> Result<(), TryReserveError> {
    let mut v = Vec::new();
    v.try_reserve(usize::MAX)?; // This will likely fail due to memory limits
    Ok(())
}

println!("{:?}", allocate_large_vector()); // Output: Err(TryReserveError { .. })
```

---

#### **9. `Bound<T>` (Range Bound)**

Used with `BTreeMap` and `BTreeSet` for range queries.

```rust
use std::collections::{BTreeMap, Bound};

let mut map = BTreeMap::new();
map.insert(1, "one");
map.insert(3, "three");
map.insert(5, "five");

let range = map.range((Bound::Included(2), Bound::Excluded(5)));
for (key, value) in range {
    println!("{}: {}", key, value); // Output: 3: three
}
```

---

#### **Other Traits and Helpers**

- **`range()` (for `BTreeMap` and `BTreeSet`)** – Enables efficient range queries.
- **`Default` implementation for collections** – Most collections implement `Default` for easy instantiation.

---

