## Unsafe Rust Fundamentals


### Introduction to Unsafe Rust

Rust's safety guarantees are one of its most powerful features, but sometimes we need to step outside the bounds of what the compiler can verify. That's where unsafe Rust comes in - a way to tell the compiler "trust me, I know what I'm doing" when performing operations that could potentially violate memory safety.

**Key Points**

- Unsafe Rust doesn't disable the borrow checker or other Rust safety checks
- It only allows you to do five specific things that aren't permitted in safe code
- The goal is to isolate unsafe code in small, well-documented sections
- The programmer takes responsibility for upholding safety guarantees

### The Unsafe Keyword and Blocks

The `unsafe` keyword creates a context where you're allowed to perform certain operations that the compiler cannot verify as safe.

**Key Points**

- `unsafe` blocks create a scope where unsafe operations are permitted
- Code outside the `unsafe` block still follows all normal Rust safety rules
- The unsafe block itself doesn't make operations unsafe; it allows potentially unsafe operations

```rust
fn main() {
    let mut num = 5;
    
    // Regular Rust code
    let r1 = &num;
    
    unsafe {
        // Inside unsafe block
        let raw_ptr = &num as *const i32;
        println!("Raw pointer value: {}", *raw_ptr); // Dereferencing raw pointer
    }
    
    // Back to safe Rust
    println!("Reference value: {}", r1);
}
```

The five capabilities that unsafe unlocks:

1. Dereferencing raw pointers
2. Calling unsafe functions/methods
3. Implementing unsafe traits
4. Mutating static variables
5. Accessing fields of unions

### Unsafe Functions

Functions marked as `unsafe` explicitly require the caller to ensure certain conditions or invariants that the compiler cannot verify.

**Key Points**

- Functions are marked unsafe when they have preconditions that the compiler cannot check
- Calling an unsafe function requires an unsafe block
- Unsafe functions should clearly document their safety requirements
- Standard library uses unsafe functions for operations requiring invariants

```rust
// An unsafe function that requires the pointer to be valid and aligned
unsafe fn dangerous_operation(ptr: *mut i32) {
    *ptr = 42; // Dereference and modify the raw pointer
}

fn main() {
    let mut num = 0;
    
    // Must be called within an unsafe block
    unsafe {
        let raw_ptr = &mut num as *mut i32;
        dangerous_operation(raw_ptr);
    }
    
    println!("num: {}", num); // Prints: num: 42
}
```

Standard library examples:

```rust
// From std::slice
pub unsafe fn from_raw_parts<'a, T>(data: *const T, len: usize) -> &'a [T]

// From std::str
pub unsafe fn from_utf8_unchecked(v: &[u8]) -> &str
```

### Unsafe Traits

Traits can be marked as unsafe when implementing them incorrectly could cause undefined behavior, even if all methods are called correctly.

**Key Points**

- Unsafe traits indicate that implementors must uphold specific invariants
- Implementing an unsafe trait requires the `unsafe` keyword
- Common unsafe traits include `Send`, `Sync`, and `GlobalAlloc`
- An unsafe trait doesn't necessarily have unsafe methods

```rust
// An unsafe trait for types that can be safely created from a raw pointer
unsafe trait FromRawPtr {
    unsafe fn from_ptr<'a>(ptr: *const Self) -> &'a Self;
}

// Implementing an unsafe trait requires the unsafe keyword
unsafe impl FromRawPtr for u32 {
    unsafe fn from_ptr<'a>(ptr: *const Self) -> &'a Self {
        &*ptr // Creates a reference from the raw pointer
    }
}

fn main() {
    let value: u32 = 42;
    let ptr = &value as *const u32;
    
    unsafe {
        let reference = u32::from_ptr(ptr);
        println!("Value: {}", reference);
    }
}
```

Common standard library unsafe traits:

- `Send`: Types that can be safely transferred between threads
- `Sync`: Types that can be safely shared between threads
- `GlobalAlloc`: Types that can allocate memory for the global allocator

### Safety Invariants Documentation

Documenting safety invariants is crucial for unsafe code, as it tells users what conditions must be maintained to avoid undefined behavior.

**Key Points**

- Safety invariants should be explicitly documented with `# Safety` sections
- Document what could go wrong if invariants are violated
- Be specific about requirements for pointers, alignment, initialization, etc.
- Good documentation reduces the chance of misuse

```rust
/// Dereferences the given pointer and returns the value.
///
/// # Safety
///
/// The caller must ensure that:
/// - The pointer is properly aligned for its type
/// - The pointer points to an initialized instance of T
/// - The pointed memory is valid for the duration of 'a
/// - No mutable references to the same memory exist during the lifetime 'a
unsafe fn deref_pointer<'a, T>(ptr: *const T) -> &'a T {
    &*ptr
}
```

Best practices for documenting unsafe code:

1. Be explicit about what invariants must be maintained
2. Document the consequences of violating invariants
3. Include examples showing safe usage
4. Explain why unsafe is necessary for this functionality

### When and Why to Use Unsafe

Unsafe code should be used judiciously and only when necessary. Understanding when it's appropriate helps maintain Rust's safety guarantees.

**Key Points**

- Use unsafe only when the functionality cannot be expressed safely
- Keep unsafe blocks as small as possible
- Create safe abstractions around unsafe code
- Common legitimate uses include FFI, performance-critical code, and low-level data structures

#### Common Legitimate Uses

1. **FFI (Foreign Function Interface)**
    
    ```rust
    extern "C" {
        fn some_c_function(data: *mut u8, len: usize) -> i32;
    }
    
    fn call_c_code(buffer: &mut [u8]) -> i32 {
        unsafe {
            some_c_function(buffer.as_mut_ptr(), buffer.len())
        }
    }
    ```
    
2. **Implementing Data Structures**
    
    ```rust
    pub struct MyVec<T> {
        ptr: *mut T,
        len: usize,
        cap: usize,
    }
    
    impl<T> MyVec<T> {
        pub fn push(&mut self, value: T) {
            if self.len == self.cap {
                self.grow();
            }
            
            unsafe {
                std::ptr::write(self.ptr.add(self.len), value);
            }
            self.len += 1;
        }
        
        // Other methods...
    }
    ```
    
3. **Performance-Critical Code**
    
    ```rust
    pub fn fast_memcpy(dst: &mut [u8], src: &[u8]) {
        assert!(dst.len() >= src.len(), "Destination buffer too small");
        
        unsafe {
            std::ptr::copy_nonoverlapping(
                src.as_ptr(),
                dst.as_mut_ptr(),
                src.len()
            );
        }
    }
    ```
    
4. **Platform-Specific Intrinsics**
    
    ```rust
    #[cfg(target_arch = "x86_64")]
    use std::arch::x86_64::*;
    
    pub fn sum_avx(values: &[f32]) -> f32 {
        if is_x86_feature_detected!("avx2") {
            return unsafe { sum_avx_unsafe(values) };
        }
        
        // Fallback implementation
        values.iter().sum()
    }
    
    #[target_feature(enable = "avx2")]
    unsafe fn sum_avx_unsafe(values: &[f32]) -> f32 {
        // Use AVX intrinsics...
        // ...
    }
    ```
    

### Safe Abstractions Over Unsafe Code

The ideal approach is to build safe abstractions that encapsulate unsafe code, allowing users to benefit from its capabilities without risking memory safety.

**Key Points**

- Public interfaces should be safe whenever possible
- Use encapsulation to hide unsafe details
- Validate inputs at the safe/unsafe boundary
- Unit tests should verify that safety invariants are maintained

```rust
// A safe abstraction over raw memory operations
pub struct Buffer {
    ptr: *mut u8,
    len: usize, 
    capacity: usize,
}

impl Buffer {
    // Safe public constructor
    pub fn new(capacity: usize) -> Self {
        let layout = std::alloc::Layout::array::<u8>(capacity).unwrap();
        let ptr = unsafe { std::alloc::alloc(layout) };
        
        if ptr.is_null() {
            std::alloc::handle_alloc_error(layout);
        }
        
        Buffer {
            ptr,
            len: 0,
            capacity,
        }
    }
    
    // Safe public interface
    pub fn write(&mut self, data: &[u8]) -> Result<(), &'static str> {
        if self.len + data.len() > self.capacity {
            return Err("Buffer capacity exceeded");
        }
        
        unsafe {
            std::ptr::copy_nonoverlapping(
                data.as_ptr(),
                self.ptr.add(self.len),
                data.len()
            );
        }
        
        self.len += data.len();
        Ok(())
    }
}

// Ensure proper cleanup
impl Drop for Buffer {
    fn drop(&mut self) {
        unsafe {
            let layout = std::alloc::Layout::array::<u8>(self.capacity).unwrap();
            std::alloc::dealloc(self.ptr, layout);
        }
    }
}
```

### Common Pitfalls and How to Avoid Them

**Key Points**

- Assuming pointers are valid without verification
- Not handling alignment requirements correctly
- Creating multiple mutable references to the same data
- Forgetting to uphold invariants when modifying code

```rust
// Bad practice: Assuming a pointer is valid
unsafe fn bad_example(ptr: *const u32) -> u32 {
    *ptr  // No validation, could be null or unaligned
}

// Better practice: Validate as much as possible
unsafe fn better_example(ptr: *const u32) -> Option<u32> {
    if ptr.is_null() {
        return None;
    }
    
    // Check alignment
    if (ptr as usize) % std::mem::align_of::<u32>() != 0 {
        return None;
    }
    
    // Still unsafe but with more verification
    Some(*ptr)
}
```

### Testing Unsafe Code

**Key Points**

- Testing unsafe code is crucial for verifying safety invariants
- Use tools like Miri for detecting undefined behavior
- Fuzzing can help discover edge cases
- Write tests specifically aimed at boundary conditions

```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_buffer_write() {
        let mut buffer = Buffer::new(10);
        assert!(buffer.write(&[1, 2, 3]).is_ok());
        assert!(buffer.write(&[4, 5, 6, 7]).is_ok());
        
        // Test boundary condition
        assert!(buffer.write(&[8, 9, 10]).is_err());
    }
    
    #[test]
    fn test_buffer_concurrent_access() {
        // Test that Buffer maintains thread safety invariants
        // ...
    }
}
```

**Conclusion**

Unsafe Rust is a powerful tool that allows systems programmers to perform low-level operations when necessary, while still benefiting from Rust's safety features in the rest of their code. By understanding when to use unsafe, documenting safety invariants clearly, and creating safe abstractions, you can write robust code that leverages the full power of unsafe Rust without compromising on safety. The key is to treat unsafe code with respect, keep it minimal, and thoroughly document and test the safety invariants it depends on.

---

