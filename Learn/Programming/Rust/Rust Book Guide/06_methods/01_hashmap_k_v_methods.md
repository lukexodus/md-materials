## **`HashMap<K, V>` Methods**


`HashMap` is used for storing key-value pairs in an unordered collection.

- **`insert(key, value)`**: Inserts a key-value pair.

    ```rust
    use std::collections::HashMap;

    let mut map = HashMap::new();
    map.insert("blue", 10);
    map.insert("yellow", 50);
    ```

- **`get(&key)`**: Returns an `Option<&V>`.

    ```rust
    if let Some(score) = map.get("blue") {
        println!("Blue team's score is: {}", score);
    }
    ```

- **`remove(&key)`**: Removes a key-value pair by key.

    ```rust
    map.remove("blue");
    ```

- **`contains_key(&key)`**: Checks if the map contains a specific key.

    ```rust
    println!("Contains 'yellow': {}", map.contains_key("yellow"));
    ```

- **`len()`**: Returns the number of elements.

    ```rust
    println!("Map length: {}", map.len());
    ```

- **`is_empty()`**: Checks if the map is empty.

    ```rust
    println!("Is the map empty? {}", map.is_empty());
    ```

- **`clear()`**: Removes all key-value pairs.

    ```rust
    map.clear();
    ```

- **`entry(key)`**: Allows inserting or modifying the value in place.

    ```rust
    let entry = map.entry("green").or_insert(0);
    *entry += 10;
    ```

- **`keys()`**: Returns an iterator over the keys.

    ```rust
    for key in map.keys() {
        println!("{}", key);
    }
    ```

- **`values()`**: Returns an iterator over the values.

    ```rust
    for value in map.values() {
        println!("{}", value);
    }
    ```

- **`get_mut()`**: Returns a mutable reference to the value corresponding to the key.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert("key", 10);
    
    if let Some(val) = map.get_mut("key") {
        *val += 5;
    }
    
    println!("{:?}", map); // {"key": 15}
    ```

- **`retain()`**: Retains only the elements specified by the predicate.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert(1, 10);
    map.insert(2, 20);
    map.insert(3, 30);
    
    map.retain(|&k, &mut v| k > 1 && v >= 20);
    
    println!("{:?}", map); // {2: 20, 3: 30}
    ```

- **`drain()`**: Creates an iterator that removes all key-value pairs from the map.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert("a", 1);
    map.insert("b", 2);
    
    for (key, value) in map.drain() {
        println!("{}: {}", key, value);
    }
    
    println!("{:?}", map); // {}
    ```

- **`extend()`**: Extends the `HashMap` with elements from another iterable collection.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert(1, "one");
    
    let new_items = vec![(2, "two"), (3, "three")];
    map.extend(new_items);
    
    println!("{:?}", map); // {1: "one", 2: "two", 3: "three"}
    ```

- **`shrink_to_fit()`**: Shrinks the capacity of the `HashMap` to match the current number of elements.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert("a", 1);
    map.insert("b", 2);
    
    map.shrink_to_fit();
    ```

- **`iter()`**: Returns an iterator over the key-value pairs in the `HashMap`.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert("a", 1);
    map.insert("b", 2);
    
    for (key, value) in map.iter() {
        println!("{}: {}", key, value);
    }
    ```

- **`iter_mut()`**: Returns a mutable iterator over the key-value pairs in the `HashMap`.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert("a", 1);
    map.insert("b", 2);
    
    for (_, value) in map.iter_mut() {
        *value *= 2;
    }
    
    println!("{:?}", map); // {"a": 2, "b": 4}
    ```

- **`entry_mut()`**: Retrieves a mutable reference to an entry corresponding to the key.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert("key", 10);
    
    let entry = map.entry("key").or_insert(0);
    *entry += 5;
    
    println!("{:?}", map); // {"key": 15}
    ```

- **`append()`**: Moves all elements from one `HashMap` to another, overwriting existing keys if they are the same.

    ```rust
    use std::collections::HashMap;
    
    let mut map1 = HashMap::new();
    map1.insert(1, "one");
    
    let mut map2 = HashMap::new();
    map2.insert(2, "two");
    map2.insert(3, "three");
    
    map1.append(&mut map2);
    
    println!("{:?}", map1); // {1: "one", 2: "two", 3: "three"}
    println!("{:?}", map2); // {}
    ```

- **`reserve()`**: Reserves capacity for additional elements in the `HashMap`.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert(1, "one");
    
    map.reserve(10); // Reserve capacity for 10 more elements
    ```

- **`capacity()`**: Returns the number of elements the `HashMap` can hold without reallocating.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert(1, "one");
    
    println!("Capacity: {}", map.capacity());
    ```

- **`retain_mut()`**: Similar to `retain()`, but allows mutating the value if the key meets the condition.

    ```rust
    use std::collections::HashMap;
    
    let mut map = HashMap::new();
    map.insert(1, 10);
    map.insert(2, 20);
    
    map.retain_mut(|&k, v| {
        if k == 1 {
            *v += 5;
        }
        *v > 15
    });
    
    println!("{:?}", map); // {1: 15, 2: 20}
    ```

