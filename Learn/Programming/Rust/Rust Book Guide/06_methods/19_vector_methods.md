## Vector Methods


In Rust, the `Vec<T>` type is one of the most commonly used collections. It represents a dynamically-sized array and provides many methods to manipulate its contents. Below is a comprehensive list of useful methods for working with vectors in Rust, categorized for better understanding.

### 1. **Creation and Initialization**

- **`new()`**  
  Creates an empty vector.

  ```rust
  let v: Vec<i32> = Vec::new();
  ```

- **`with_capacity(capacity: usize)`**  
  Creates a new vector with a specified capacity.

  ```rust
  let mut v = Vec::with_capacity(10);
  ```

- **`vec![]`**  
  A macro to create a vector with initial values.

  ```rust
  let v = vec![1, 2, 3, 4, 5];
  ```

---

### 2. **Adding and Removing Elements**

- **`push(value: T)`**  
  Appends an element to the back of the vector.

  ```rust
  let mut v = Vec::new();
  v.push(10);
  ```

- **`pop()`**  
  Removes and returns the last element of the vector (if any). Returns `None` if the vector is empty.

  ```rust
  let mut v = vec![1, 2, 3];
  let last = v.pop();  // Some(3)
  ```

- **`insert(index: usize, element: T)`**  
  Inserts an element at the specified position, shifting elements to the right.

  ```rust
  let mut v = vec![1, 2, 4];
  v.insert(2, 3);  // [1, 2, 3, 4]
  ```

- **`remove(index: usize)`**  
  Removes and returns the element at the specified position, shifting elements to the left.

  ```rust
  let mut v = vec![1, 2, 3];
  v.remove(1);  // Returns 2, vector becomes [1, 3]
  ```

---

### 3. **Accessing Elements**

- **`get(index: usize)`**  
  Returns an `Option<&T>` for the element at the specified position.

  ```rust
  let v = vec![1, 2, 3];
  let value = v.get(1);  // Some(&2)
  ```

- **`[index]` (Indexing)**  
  Directly access an element using indexing. Panics if out of bounds.

  ```rust
  let v = vec![1, 2, 3];
  let value = v[1];  // 2
  ```

- **`first()`**  
  Returns an `Option<&T>` for the first element of the vector.

  ```rust
  let v = vec![1, 2, 3];
  let first = v.first();  // Some(&1)
  ```

- **`last()`**  
  Returns an `Option<&T>` for the last element of the vector.

  ```rust
  let v = vec![1, 2, 3];
  let last = v.last();  // Some(&3)
  ```

---

### 4. **Capacity and Size**

- **`len()`**  
  Returns the number of elements in the vector.

  ```rust
  let v = vec![1, 2, 3];
  println!("{}", v.len());  // 3
  ```

- **`capacity()`**  
  Returns the number of elements the vector can hold without reallocating.

  ```rust
  let v = Vec::with_capacity(10);
  println!("{}", v.capacity());  // 10
  ```

- **`is_empty()`**  
  Returns `true` if the vector contains no elements.

  ```rust
  let v: Vec<i32> = Vec::new();
  println!("{}", v.is_empty());  // true
  ```

- **`reserve(additional: usize)`**  
  Reserves capacity for at least `additional` more elements.

  ```rust
  let mut v = Vec::new();
  v.reserve(10);
  ```

- **`shrink_to_fit()`**  
  Shrinks the capacity of the vector to match its length.

  ```rust
  let mut v = Vec::with_capacity(10);
  v.push(1);
  v.shrink_to_fit();  // Capacity becomes 1
  ```

---

### 5. **Slicing and Iterating**

- **`as_slice()`**  
  Returns a slice that references the entire vector.

  ```rust
  let v = vec![1, 2, 3];
  let slice = v.as_slice();  // &[1, 2, 3]
  ```

- **`iter()`**  
  Returns an iterator over references to the elements of the vector.

  ```rust
  let v = vec![1, 2, 3];
  for val in v.iter() {
      println!("{}", val);
  }
  ```

- **`iter_mut()`**  
  Returns a mutable iterator over the elements of the vector.

  ```rust
  let mut v = vec![1, 2, 3];
  for val in v.iter_mut() {
      *val += 10;
  }
  ```

- **`into_iter()`**  
  Consumes the vector and returns an iterator that yields the elements by value.

  ```rust
  let v = vec![1, 2, 3];
  for val in v.into_iter() {
      println!("{}", val);
  }
  ```

---

### 6. **Manipulation and Modification**

- **`retain(predicate: F)`**  
  Retains only the elements specified by the predicate function.

  ```rust
  let mut v = vec![1, 2, 3, 4];
  v.retain(|&x| x % 2 == 0);  // Retains only even numbers: [2, 4]
  ```

- **`clear()`**  
  Clears the vector, removing all elements.

  ```rust
  let mut v = vec![1, 2, 3];
  v.clear();  // Now the vector is empty: []
  ```

- **`split_off(at: usize)`**  
  Splits the vector into two at the given index. Returns the tail portion.

  ```rust
  let mut v = vec![1, 2, 3, 4];
  let tail = v.split_off(2);  // v = [1, 2], tail = [3, 4]
  ```

---

### 7. **Combining Vectors**

- **`extend<I: IntoIterator<Item=T>>(iter: I)`**  
  Extends the vector with the contents of an iterator.

  ```rust
  let mut v = vec![1, 2];
  v.extend([3, 4, 5].iter().cloned());
  // v is now [1, 2, 3, 4, 5]
  ```

- **`append(&mut other: Vec<T>)`**  
  Moves all elements from `other` into the vector, leaving `other` empty.

  ```rust
  let mut v1 = vec![1, 2];
  let mut v2 = vec![3, 4];
  v1.append(&mut v2);  // v1 = [1, 2, 3, 4], v2 is empty
  ```

- **`concat()`**  
  Concatenates all slices in the vector into a single vector.

  ```rust
  let v = vec![vec![1, 2], vec![3, 4]].concat();  // [1, 2, 3, 4]
  ```

- **`join(separator: T)`**  
  Joins all elements of the vector with the given separator.

  ```rust
  let v = vec![vec![1], vec![2], vec![3]];
  let joined = v.join(&0);  // [1, 0, 2, 0, 3]
  ```

---

### 8. **Sorting and Reversing**

- **`sort()`**  
  Sorts the vector in place using the natural order of the elements.

  ```rust
  let mut v = vec![3, 1, 2];
  v.sort();  // v becomes [1, 2, 3]
  ```

- **`sort_by(|a, b| ordering)`**  
  Sorts the vector in place using a comparator function.

  ```rust
  let mut v = vec![3, 1, 2];
  v.sort_by(|a, b| a.cmp(b));  // Same as sort(), v becomes [1, 2, 3]
  ```

- **`reverse()`**  
  Reverses the order of the elements in the vector.

  ```rust
  let mut v = vec![1, 2, 3];
  v.reverse();  // v becomes [3, 2, 1]
  ```

