## Operator Overloading


Operator overloading in Rust allows you to define custom behavior for standard operators (e.g., `+`, `-`, `*`, `==`) when used with your custom types. Rust achieves this using **traits** from the `std::ops` module.

---

**Defining Operator Overloading**

To overload an operator, you implement the corresponding trait for your type. Each trait provides an associated method that you must define.

---

**Example: Overloading `+` (Addition)**

The `+` operator corresponds to the `std::ops::Add` trait.

**Step 1: Implementing `Add` for a Custom Struct**

```rust
use std::ops::Add;

#[derive(Debug, Copy, Clone)]
struct Point {
    x: i32,
    y: i32,
}

// Implement addition for `Point`
impl Add for Point {
    type Output = Point; // Specifies the result type of `+`

    fn add(self, other: Point) -> Point {
        Point {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

fn main() {
    let p1 = Point { x: 2, y: 3 };
    let p2 = Point { x: 4, y: 5 };

    let p3 = p1 + p2; // Uses overloaded `+`
    println!("{:?}", p3); // Output: Point { x: 6, y: 8 }
}
```

🔹 **`type Output`** defines the result type of `+`.  
🔹 **`fn add(self, other: Self) -> Self::Output`** implements the behavior.

---

### **Common Operator Overload Traits**

Rust provides several traits for overloading operators:

|Operator|Trait (`std::ops::`)|Example Signature|
|---|---|---|
|`+` (Addition)|`Add<T>`|`fn add(self, rhs: T) -> Self::Output`|
|`-` (Subtraction)|`Sub<T>`|`fn sub(self, rhs: T) -> Self::Output`|
|`*` (Multiplication)|`Mul<T>`|`fn mul(self, rhs: T) -> Self::Output`|
|`/` (Division)|`Div<T>`|`fn div(self, rhs: T) -> Self::Output`|
|`%` (Remainder)|`Rem<T>`|`fn rem(self, rhs: T) -> Self::Output`|
|`==` (Equality)|`PartialEq`|`fn eq(&self, other: &Self) -> bool`|
|`!=` (Inequality)|`PartialEq`|Uses `eq` but negated|
|`<`, `<=`, `>`, `>=`|`PartialOrd`|`fn partial_cmp(&self, other: &Self) -> Option<Ordering>`|
|`&` (Bitwise AND)|`BitAnd<T>`|`fn bitand(self, rhs: T) -> Self::Output`|
|`|` (Bitwise OR)|`BitOr<T>`|
|`^` (Bitwise XOR)|`BitXor<T>`|`fn bitxor(self, rhs: T) -> Self::Output`|
|`<<` (Left Shift)|`Shl<T>`|`fn shl(self, rhs: T) -> Self::Output`|
|`>>` (Right Shift)|`Shr<T>`|`fn shr(self, rhs: T) -> Self::Output`|
|`!` (Logical NOT)|`Not`|`fn not(self) -> Self::Output`|
|`&` (Borrowing)|`Deref`|`fn deref(&self) -> &T`|
|`&mut` (Mutable Borrowing)|`DerefMut`|`fn deref_mut(&mut self) -> &mut T`|

---

**Example: Overloading `*` (Multiplication)**

```rust
use std::ops::Mul;

struct Scalar(i32);

impl Mul for Scalar {
    type Output = Scalar;

    fn mul(self, rhs: Scalar) -> Scalar {
        Scalar(self.0 * rhs.0)
    }
}

fn main() {
    let a = Scalar(3);
    let b = Scalar(4);
    let c = a * b; // Uses overloaded `*`
    println!("{}", c.0); // Output: 12
}
```

---

### **Handling Different Types (`T`) in Overloading**

You can overload operators for **different types** instead of only `Self`:

```rust
use std::ops::Add;

struct Point {
    x: i32,
    y: i32,
}

// Implement addition with `i32`
impl Add<i32> for Point {
    type Output = Point;

    fn add(self, scalar: i32) -> Point {
        Point {
            x: self.x + scalar,
            y: self.y + scalar,
        }
    }
}

fn main() {
    let p = Point { x: 2, y: 3 };
    let p_new = p + 5; // Add 5 to both x and y
    println!("({}, {})", p_new.x, p_new.y); // Output: (7, 8)
}
```

🔹 `Add<i32>` allows adding an integer to a `Point` instead of another `Point`.

---

**Key Takeaways**

- **Rust uses traits to overload operators.**
- **Each operator has a corresponding `std::ops` trait.**
- **You must implement the trait for your type and define `type Output`.**
- **Overloading allows operations between custom types and even different types.**
- **Rust enforces strong type safety, preventing unexpected operator misuse.**

