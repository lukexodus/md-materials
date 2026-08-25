## **`BTreeMap<K, V>` Methods**


`BTreeMap` is a key-value store where the keys are kept sorted.

- **`range(range)`**: Returns an iterator over a range of keys.

    ```rust
    use std::collections::BTreeMap;

    let mut map = BTreeMap::new();
    map.insert("apple", 3);
    map.insert("banana", 2);
    map.insert("pear", 5);

    for (key, value) in map.range("banana".."pear") {
        println!("{}: {}", key, value);
    }
    ```

- **`insert(key, value)`**: Inserts a key-value pair.

    ```rust
    map.insert("orange", 4);
    ```

- **`get(&key)`**: Returns a reference to the value for the key if it exists.

    ```rust
    if let Some(count) = map.get("banana") {
        println!("Banana count: {}", count);
    }
    ```

- **`remove(&key)`**: Removes a key-value pair by key.

    ```rust
    map.remove("apple");
    ```

- **`first_key_value()`**: Returns the first key-value pair.

    ```rust
    if let Some((first_key, first_val)) = map.first_key_value() {
        println!("First key: {}, First value: {}", first_key, first_val);
    }
    ```

- **`last_key_value()`**: Returns the last key-value pair.

    ```rust
    if let Some((last_key, last_val)) = map.last_key_value() {
        println!("Last key: {}, Last value: {}", last_key, last_val);
    }
    ```

