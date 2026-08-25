## Borrowing and Ownership


### Moving Values to a Function vs Passing References to It

#### 1. Moving Values to a Function

When you move a value into a function, ownership of that value is transferred to the function. The original variable in the caller is no longer valid after the move, and attempting to use it will result in a compile-time error.

**Example:**

```rust
fn take_ownership(s: String) {
    println!("{}", s);
}

fn main() {
    let my_string = String::from("Hello");
    take_ownership(my_string); // Ownership moved to the function
    // my_string can no longer be used here.
}
```

After calling take_ownership, the ownership of my_string is transferred to the function, so it can’t be used in the main function anymore.

#### 2. Passing References to a Function

When you pass a reference (&T) to a function, you allow the function to borrow the value without taking ownership. This means that the original value can still be used after the function call.

Example:

```rust
fn borrow_string(s: &String) {
    println!("{}", s);
}

fn main() {
    let my_string = String::from("Hello");
    borrow_string(&my_string); // Pass a reference (borrow)
    // my_string can still be used here because ownership is not moved.
    println!("{}", my_string);
}
```

In this case, my_string is borrowed by borrow_string, and after the function call, my_string can still be used in the main function.


### Moving Values to a Struct vs Passing References to It

#### 1. Moving Values to a Struct

When you move a value into a struct, the struct becomes the new owner of that value, and the original variable loses ownership. This means the original variable cannot be used anymore after the move.

**Example:**

```rust
struct Person {
    name: String,
}

fn main() {
    let my_name = String::from("Alice");
    let person = Person { name: my_name }; // my_name is moved to the struct
    // my_name can no longer be used here.
}
```

Here, my_name is moved into the Person struct, so it can’t be accessed anymore in the main function after the move.


#### 2. Passing References to a Struct

When you pass references to a struct, the struct does not take ownership of the values, but instead, it borrows them. The original variables can still be used while the struct holds the references.

**Example:**

```rust
struct Person<'a> {
    name: &'a String,
}

fn main() {
    let my_name = String::from("Alice");
    let person = Person { name: &my_name }; // Borrowing my_name
    // my_name can still be used here because ownership is not moved.
    println!("{}", my_name);
}
```

In this example, the struct Person borrows the my_name using a reference, so my_name can still be used after creating the person struct.


**When to Use Each**

1. **Move (Ownership Transfer):**

Use when you want the function/struct to take ownership of the value.

This makes sense when the function or struct needs to modify, consume, or store the value long-term (e.g., storing in a struct or collection).

Be mindful that after the move, the original variable is no longer accessible.


2. **References (Borrowing):**

Use when you don’t want to transfer ownership but still want to allow the function/struct to access the value.

Ideal for cases where the value is large or expensive to clone, but you only need to read (or occasionally mutate) it temporarily.

Remember that references require careful management of lifetimes and borrowing rules.

