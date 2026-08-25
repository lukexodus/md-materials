## `Entry` 


In Rust, the Entry API is used to handle situations where you want to check if a key exists in a collection (like a HashMap), and then either modify the existing entry or insert a new one if it doesn’t exist. This is commonly done with the HashMap collection.

### Common Entry Methods

#### 1. or_insert

If the entry is vacant (doesn’t exist), inserts the provided value and returns a mutable reference to the value. If it exists, returns a mutable reference to the existing value.

Example:

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();
scores.insert("Blue", 10);

let entry = scores.entry("Blue").or_insert(50);
println!("The score is: {}", entry); // The score is: 10

let entry = scores.entry("Yellow").or_insert(50);
println!("The score is: {}", entry); // The score is: 50
```


#### 2. or_insert_with

Similar to or_insert, but instead of inserting a provided value, it inserts the result of a function or closure if the key is vacant.

Example:

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.entry("Blue").or_insert_with(|| 50);
println!("{:?}", scores); // {"Blue": 50}

scores.entry("Yellow").or_insert_with(|| 30);
println!("{:?}", scores); // {"Blue": 50, "Yellow": 30}
```

#### 3. and_modify

Modifies the value of an existing entry if it exists, but does nothing if the entry is vacant.

Example:

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();
scores.insert("Blue", 10);

scores.entry("Blue").and_modify(|v| *v += 10);
scores.entry("Yellow").and_modify(|v| *v += 10); // Does nothing

println!("{:?}", scores); // {"Blue": 20}
```


#### 4. key

Returns a reference to the key for this entry.

Example:

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();
scores.insert("Blue", 10);

let entry = scores.entry("Blue");
println!("Key: {}", entry.key()); // Key: Blue
```


### Entry Enum Variants

The Entry type can either be a Vacant or Occupied entry. These represent whether the key exists in the map or not:

#### 1. Occupied

Represents an entry that exists in the map.

Example:

```rust
use std::collections::HashMap;

let mut map = HashMap::new();
map.insert("Blue", 10);

if let std::collections::hash_map::Entry::Occupied(entry) = map.entry("Blue") {
    println!("Found: {}", entry.get()); // Found: 10
}
```


#### 2. Vacant

Represents an entry that does not exist in the map, allowing you to insert a new value.

Example:

```rust
use std::collections::HashMap;

let mut map = HashMap::new();

if let std::collections::hash_map::Entry::Vacant(entry) = map.entry("Blue") {
    entry.insert(10);
}

println!("{:?}", map); // {"Blue": 10}
```

