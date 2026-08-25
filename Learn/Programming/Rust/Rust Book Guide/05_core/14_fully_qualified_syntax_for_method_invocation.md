## **Fully Qualified Syntax for Method Invocation**


In Rust, methods are typically called using **dot syntax** (e.g., `object.method()`), but sometimes **fully qualified syntax** is required to resolve ambiguity, especially when dealing with:

1. **Trait methods with the same name**
2. **Methods from different traits with the same name**
3. **Calling a trait method directly without an instance**

---

**Syntax Format**

```rust
<TraitName as TraitPath>::method(receiver, args...)
```

- `<TraitName>` – The trait that defines the method.
- `as TraitPath` – The full path of the trait (if necessary).
- `method(receiver, args...)` – The method call, with `self` explicitly passed.

---

**Example: Disambiguating Trait Methods**

### **Case: Two Traits with the Same Method Name**

```rust
trait A {
    fn foo(&self);
}

trait B {
    fn foo(&self);
}

struct MyType;

impl A for MyType {
    fn foo(&self) {
        println!("A's foo()");
    }
}

impl B for MyType {
    fn foo(&self) {
        println!("B's foo()");
    }
}

fn main() {
    let obj = MyType;

    // Normal method call (Ambiguous)
    // obj.foo(); // ❌ ERROR: multiple `foo` implementations

    // Fully Qualified Syntax to disambiguate
    <MyType as A>::foo(&obj); // Output: A's foo()
    <MyType as B>::foo(&obj); // Output: B's foo()
}
```

🔹 Without **fully qualified syntax**, Rust doesn’t know which `foo()` method to call.

---

### **Calling a Trait Method Without an Instance**

Some trait methods **don’t require `self`**, and can be called directly on the type:

```rust
trait Math {
    fn double(n: i32) -> i32;
}

struct Number;

impl Math for Number {
    fn double(n: i32) -> i32 {
        n * 2
    }
}

fn main() {
    let result = <Number as Math>::double(10); // Fully qualified syntax
    println!("{}", result); // Output: 20
}
```

🔹 `Math::double` doesn’t require `self`, so it can be called **directly on the type**.

---

**Example: Overriding Default Trait Methods**

```rust
trait Greet {
    fn hello(&self) {
        println!("Hello from trait!");
    }
}

struct Person;

impl Greet for Person {
    fn hello(&self) {
        println!("Hello from Person!");
    }
}

fn main() {
    let p = Person;
    
    p.hello(); // Calls overridden method: "Hello from Person!"
    
    <Person as Greet>::hello(&p); // Explicitly calls trait method: "Hello from trait!"
}
```

---

**When to Use Fully Qualified Syntax?**

✅ When a type implements **multiple traits** with the **same method name**.  
✅ When calling a **trait method without `self`** (i.e., an **associated function**).  
✅ When you **override a trait method** but still want to call the default implementation.

---

**Key Takeaways**

- **Use `<Type as Trait>::method()` to explicitly call a trait method.**
- **Necessary when multiple traits define the same method name.**
- **Used for calling associated functions (static methods) in traits.**
- **Helps avoid ambiguity and makes the code explicit.**

