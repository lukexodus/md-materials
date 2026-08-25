## String Methods


In Rust, the `String` type provides several useful methods for creating, modifying, querying, and manipulating string data. Here are some of the common methods available for `String`:

`new`
Creates a new empty `String`.

```rust
let s = String::new();
```

---

`from`
Creates a `String` from a string literal.

```rust
let s = String::from("Hello");
```

---

`push`
Appends a single character to the end of a `String`.

```rust
let mut s = String::from("Hello");
s.push('!');
println!("{}", s);  // "Hello!"
```

---

`push_str`
Appends a string slice (`&str`) to the end of a `String`.

```rust
let mut s = String::from("Hello");
s.push_str(", world!");
println!("{}", s);  // "Hello, world!"
```

---

`len`
Returns the length of the `String`, in bytes.

```rust
let s = String::from("Hello");
println!("{}", s.len());  // 5
```

---

`is_empty`
Returns `true` if the `String` is empty.

```rust
let s = String::new();
println!("{}", s.is_empty());  // true
```

---

`clear`
Clears the `String`, removing all contents but keeping the allocated memory.

```rust
let mut s = String::from("Hello");
s.clear();
println!("{}", s.is_empty());  // true
```

---
 `insert`
Inserts a character at a specific index in the `String`.

```rust
let mut s = String::from("Hello");
s.insert(5, ',');
println!("{}", s);  // "Hello,"
```

---

`insert_str`
Inserts a string slice at a specific index in the `String`.

```rust
let mut s = String::from("Hello");
s.insert_str(5, ", world!");
println!("{}", s);  // "Hello, world!"
```

---

`remove`
Removes and returns the character at a specified index. Shifts all characters after the removed one to the left.

```rust
let mut s = String::from("Hello, world!");
let ch = s.remove(5);
println!("{}", s);  // "Hello world!"
println!("{}", ch); // ','
```

---

`replace`
Replaces all matches of a pattern (string slice) with another string slice.

```rust
let s = String::from("I like apples");
let new_s = s.replace("apples", "oranges");
println!("{}", new_s);  // "I like oranges"
```

---

`find`
Returns the byte index of the first occurrence of a substring. Returns `None` if not found.

```rust
let s = String::from("I like apples");
let idx = s.find("apples");
println!("{:?}", idx);  // Some(7)
```

---

`split_whitespace`
Splits the string by whitespace and returns an iterator.

```rust
let s = String::from("I like apples");
for word in s.split_whitespace() {
    println!("{}", word);
}
// Output:
// I
// like
// apples
```

---

`trim`
Removes leading and trailing whitespace from a string.

```rust
let s = String::from("   Hello, world!   ");
println!("{}", s.trim());  // "Hello, world!"
```

---

`chars`
Returns an iterator over the characters of the `String`.

```rust
let s = String::from("Hello");
for ch in s.chars() {
    println!("{}", ch);
}
// Output:
// H
// e
// l
// l
// o
```

---

`to_uppercase`
Returns a new `String` where all the characters are converted to uppercase.

```rust
let s = String::from("Hello");
let upper = s.to_uppercase();
println!("{}", upper);  // "HELLO"
```

---

`to_lowercase`
Returns a new `String` where all the characters are converted to lowercase.

```rust
let s = String::from("HELLO");
let lower = s.to_lowercase();
println!("{}", lower);  // "hello"
```

---

`pop`
Removes the last character from the `String` and returns it. Returns `None` if the `String` is empty.

```rust
let mut s = String::from("Hello!");
let ch = s.pop();
println!("{}", s);  // "Hello"
println!("{:?}", ch);  // Some('!')
```

---

`concat`
Concatenates two or more `String`s or `&str` slices.

```rust
let s1 = String::from("Hello, ");
let s2 = String::from("world!");
let s3 = s1 + &s2;  // Note: s1 is moved here and can no longer be used
println!("{}", s3);  // "Hello, world!"
```

---

`capacity`
Returns the total allocated capacity of the `String` in bytes.

```rust
let s = String::with_capacity(10);
println!("{}", s.capacity());  // 10
```

---

 `reserve`
Reserves at least the specified number of bytes of capacity.

```rust
let mut s = String::new();
s.reserve(10);  // Allocates at least 10 bytes for the string
```

---

`as_str`
Returns a string slice (`&str`) of the `String`.

```rust
let s = String::from("Hello");
let slice = s.as_str();
println!("{}", slice);  // "Hello"
```

---

`split_off`
Splits the string at the given index and returns the second half as a new `String`. The original string is truncated.

```rust
let mut s = String::from("Hello, world!");
let second_half = s.split_off(7);
println!("{}", s);         // "Hello, "
println!("{}", second_half);  // "world!"
```

