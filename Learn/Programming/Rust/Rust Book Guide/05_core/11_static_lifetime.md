## `'static` Lifetime


In Rust, the `'static` lifetime is a **special lifetime** that represents data that **lives for the entire duration of the program**. Data with the `'static` lifetime is stored in the program's binary or in a part of memory that persists as long as the program runs.

Here are some common scenarios where the `'static` lifetime is used:

1. **String Literals**

String literals, like `"hello"`, have a `'static` lifetime because they are hardcoded into the binary of the program and therefore live for the entire duration of the program.

```rust
let s: &'static str = "I have a static lifetime";
```

In this example, `s` is a `&'static str`. The string `"I have a static lifetime"` is stored in the binary and will remain accessible as long as the program runs.

2. **Static Variables**

Variables defined with the `static` keyword also have a `'static` lifetime, since they are meant to persist for the whole program.

```rust
static HELLO: &str = "Hello, world!";

fn main() {
    println!("{}", HELLO);
}
```

`HELLO` has a `'static` lifetime, and its value can be accessed anywhere within the program without any restrictions on lifetimes.

> **Note**: While `static` variables are `'static`, it’s often recommended to avoid mutable `static` variables (`static mut`) due to thread safety issues.

3. **`'static` Bound in Generics**

When working with generic types or trait bounds, the `'static` lifetime can be used as a constraint to ensure that the data being referenced will live for the entire duration of the program.

For instance, if you’re working with a generic type `T` that must have a `'static` lifetime, you can specify this with `T: 'static`.

```rust
fn takes_static<T: 'static>(value: T) {
    // value has a 'static lifetime
}
```

This function `takes_static` only accepts types `T` that do not have any non-`'static` references within them, effectively requiring that `T` can "live" for the entire duration of the program.

4. **`'static` in Closures and Threads**

When using threads, `'static` is often required for data because threads can outlive the scope in which they were created. For example, when passing data to a thread, Rust requires that the data has a `'static` lifetime to avoid potential dangling references.

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        println!("Running in a thread!");
    });
    
    handle.join().unwrap();
}
```

In this example, the closure `|| { println!("Running in a thread!"); }` does not capture any variables with non-`'static` references, so it’s safe to spawn a thread. If you were to capture variables from an outer scope, Rust would require that they have a `'static` lifetime to ensure they don’t get dropped while the thread is still running.

5. **Owned Types (e.g., `String`, `Vec<T>`) are `'static**`

Owned types like `String`, `Vec<T>`, `Box<T>`, etc., are `'static` because they own their data and don’t borrow it from somewhere else. This means you can often use owned types in contexts that require `'static` data since they don’t have any lifetimes tied to an outer scope.

```rust
let s: String = String::from("Hello");
```

In this example, `s` is a `String`, which is an owned type and can theoretically live as long as you want it to, though it’s dropped when it goes out of scope. You can pass `s` to a function that requires a `'static` value by moving it into that function.

**Summary**

- `'static` means that the data lives for the entire duration of the program.
- Common examples of `'static` data include **string literals** and **`static` variables**.
- The `'static` lifetime is often used as a **bound in generics** or **threaded code** to ensure data is valid for the required duration.
- **Owned types** (like `String` and `Vec`) can be treated as `'static` because they don’t depend on references from other scopes.

**Practical Example**

Here’s a practical example of using `'static` in a threaded context:

```rust
use std::thread;

fn main() {
    let greeting: &'static str = "Hello, world!";
    
    let handle = thread::spawn(move || {
        println!("{}", greeting);
    });
    
    handle.join().unwrap();
}
```

In this example, `greeting` has a `'static` lifetime, so it’s safe to use in the thread. Since `"Hello, world!"` is a string literal, it lives for the entire program duration, which meets the requirements for spawning the thread without lifetime issues.

