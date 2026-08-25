## Memory Manipulation in Rust


### std::mem Functions

Rust's `std::mem` module provides essential functions for low-level memory manipulation, enabling developers to work directly with memory when needed.

**Key Points**:

- Functions allow safe inspection and manipulation of memory
- Provides utilities for size calculations, alignment, and value manipulation
- Many of these functions are `unsafe` or have `unsafe` implications
- Crucial for implementing data structures and low-level optimizations

#### Core std::mem Functions

```rust
// Get size of a type at compile time
let size = std::mem::size_of::<i32>();  // 4 bytes
let size_val = std::mem::size_of_val(&"hello");  // 5 bytes

// Get alignment of a type
let align = std::mem::align_of::<i32>();  // Usually 4 on most platforms

// Swap two mutable values
let mut a = 5;
let mut b = 10;
std::mem::swap(&mut a, &mut b);  // Now a = 10, b = 5

// Replace a value, returning the old one
let mut x = String::from("hello");
let old_x = std::mem::replace(&mut x, String::from("world"));  // old_x = "hello", x = "world"

// Take ownership of a value, leaving Default in its place
let mut v = vec![1, 2, 3];
let taken = std::mem::take(&mut v);  // taken = [1, 2, 3], v = []

// Get raw bytes of a value
let bytes = std::mem::transmute_copy::<i32, [u8; 4]>(&0x12345678);  // Highly unsafe!

// Forget a value (prevent drop from being called)
let v = vec![1, 2, 3];
std::mem::forget(v);  // Memory leak! No destructor runs

// Check if a type needs dropping
let needs_drop = std::mem::needs_drop::<String>();  // true
let needs_drop = std::mem::needs_drop::<i32>();     // false

// Discriminant of an enum value
enum Foo { A, B(i32), C(bool) }
let a = Foo::A;
let b = Foo::B(10);
assert_ne!(std::mem::discriminant(&a), std::mem::discriminant(&b));
```

**Example**: Implementing a type-erased container using `std::mem` functions

```rust
use std::mem;
use std::any::Any;

struct TypeErasedBox {
    data: *mut dyn Any,
    size: usize,
    drop_fn: fn(*mut dyn Any),
}

impl TypeErasedBox {
    fn new<T: Any + 'static>(value: T) -> Self {
        let size = mem::size_of::<T>();
        let data = Box::into_raw(Box::new(value)) as *mut dyn Any;
        
        // This function will properly drop the value
        fn drop_value<T: Any>(ptr: *mut dyn Any) {
            unsafe {
                let typed_ptr = ptr as *mut T;
                Box::from_raw(typed_ptr);
                // Box destructor will run here
            }
        }
        
        TypeErasedBox {
            data,
            size,
            drop_fn: drop_value::<T>,
        }
    }
}

impl Drop for TypeErasedBox {
    fn drop(&mut self) {
        (self.drop_fn)(self.data);
    }
}
```

### MaybeUninit\<T>

`MaybeUninit<T>` provides a way to handle possibly uninitialized memory safely, which is essential for creating data structures that manage their own memory.

**Key Points**:

- Safe way to work with uninitialized memory
- Used for creating values in-place
- Essential for implementing collections and low-level data structures
- Helps avoid undefined behavior with uninitialized data

#### Basic Usage of MaybeUninit

```rust
use std::mem::MaybeUninit;

// Create uninitialized memory for a value
let mut uninit = MaybeUninit::<i32>::uninit();

// Initialize it
unsafe {
    uninit.as_mut_ptr().write(42);
}

// Extract the value (assumes it's initialized)
let value = unsafe { uninit.assume_init() };
assert_eq!(value, 42);

// Create an initialized MaybeUninit
let initialized = MaybeUninit::new(100);
let value = unsafe { initialized.assume_init() };
assert_eq!(value, 100);
```

#### Array Initialization with MaybeUninit

```rust
use std::mem::MaybeUninit;

// Create an uninitialized array
let mut array: [MaybeUninit<i32>; 1000] = unsafe {
    MaybeUninit::uninit().assume_init()
};

// Initialize each element
for (i, elem) in array.iter_mut().enumerate() {
    elem.write(i as i32);
}

// Convert to initialized array (requires Rust 1.47+)
let initialized_array = unsafe {
    let ptr = &array as *const [MaybeUninit<i32>; 1000] as *const [i32; 1000];
    ptr.read()
};

// Now we can use the initialized array
assert_eq!(initialized_array[42], 42);
```

**Example**: Building a custom Vec implementation using MaybeUninit

```rust
use std::mem::MaybeUninit;
use std::ptr;
use std::alloc::{alloc, dealloc, Layout};

pub struct RawVec<T> {
    ptr: *mut T,
    capacity: usize,
}

impl<T> RawVec<T> {
    pub fn new() -> Self {
        RawVec {
            ptr: ptr::null_mut(),
            capacity: 0,
        }
    }
    
    pub fn with_capacity(capacity: usize) -> Self {
        let layout = Layout::array::<T>(capacity).unwrap();
        
        // Only allocate if capacity > 0
        let ptr = if capacity == 0 {
            ptr::null_mut()
        } else {
            unsafe {
                let ptr = alloc(layout) as *mut T;
                if ptr.is_null() {
                    std::alloc::handle_alloc_error(layout);
                }
                ptr
            }
        };
        
        RawVec {
            ptr,
            capacity,
        }
    }
    
    pub fn push(&mut self, len: &mut usize, value: T) {
        if *len == self.capacity {
            self.grow(len);
        }
        
        unsafe {
            ptr::write(self.ptr.add(*len), value);
            *len += 1;
        }
    }
    
    fn grow(&mut self, len: &mut usize) {
        let new_capacity = if self.capacity == 0 { 1 } else { self.capacity * 2 };
        
        let new_layout = Layout::array::<T>(new_capacity).unwrap();
        let new_ptr = unsafe {
            let ptr = alloc(new_layout) as *mut T;
            if ptr.is_null() {
                std::alloc::handle_alloc_error(new_layout);
            }
            
            // Copy old elements
            if *len > 0 {
                ptr::copy_nonoverlapping(self.ptr, ptr, *len);
            }
            
            // Free old memory if we had any
            if self.capacity > 0 {
                dealloc(
                    self.ptr as *mut u8,
                    Layout::array::<T>(self.capacity).unwrap()
                );
            }
            
            ptr
        };
        
        self.ptr = new_ptr;
        self.capacity = new_capacity;
    }
}

impl<T> Drop for RawVec<T> {
    fn drop(&mut self) {
        if self.capacity == 0 {
            return;
        }
        
        let layout = Layout::array::<T>(self.capacity).unwrap();
        unsafe {
            dealloc(self.ptr as *mut u8, layout);
        }
    }
}
```

### ManuallyDrop\<T>

`ManuallyDrop<T>` allows for manual control over when a value's destructor is called, which is crucial for implementing custom data structures and managing object lifetimes.

**Key Points**:

- Prevents automatic drop of a value while still allowing access to it
- Essential for implementing move semantics in custom types
- Safer alternative to `mem::forget` in many scenarios
- Allows taking ownership of values in compound types

#### Basic ManuallyDrop Usage

```rust
use std::mem::ManuallyDrop;

// Create a value that won't be dropped
let mut string = ManuallyDrop::new(String::from("Hello, world!"));

// We can still access the inner value
assert_eq!(string.len(), 13);

// Manually drop when we're ready
unsafe {
    ManuallyDrop::drop(&mut string);
    // String is now dropped, but the ManuallyDrop itself is still valid
}
```

#### Moving Out of a Field in a Drop Implementation

```rust
use std::mem::ManuallyDrop;

struct Container {
    value: ManuallyDrop<String>,
    needs_special_handling: bool,
}

impl Drop for Container {
    fn drop(&mut self) {
        // We can safely take ownership of the String
        let value = unsafe { ManuallyDrop::take(&mut self.value) };
        
        if self.needs_special_handling {
            // Do something special with value before dropping
            println!("Special handling for: {}", value);
        }
        // value will be dropped normally at the end of this scope
    }
}
```

**Example**: Implementing a self-referential struct using ManuallyDrop

```rust
use std::mem::ManuallyDrop;
use std::ptr;

struct SelfReferential {
    data: ManuallyDrop<String>,
    // Points to data within the String
    slice_ptr: *const str,
}

impl SelfReferential {
    fn new(s: String) -> Self {
        let data = ManuallyDrop::new(s);
        let slice_ptr = data.as_str() as *const str;
        
        SelfReferential {
            data,
            slice_ptr,
        }
    }
    
    fn get_slice(&self) -> &str {
        unsafe { &*self.slice_ptr }
    }
}

impl Drop for SelfReferential {
    fn drop(&mut self) {
        // Safely drop the String
        unsafe {
            ManuallyDrop::drop(&mut self.data);
        }
    }
}
```

### Transmutation (with care)

Type transmutation is a powerful but dangerous technique that reinterprets the bits of a value as a different type.

**Key Points**:

- Most direct way to reinterpret memory as another type
- Extremely unsafe and easy to cause undefined behavior
- Should be a last resort after considering safer alternatives
- Subject to compiler optimizations that can break code
- Often requires validation of platform-specific assumptions

#### Basic Transmutation

```rust
// Transmute an u32 to [u8; 4]
let num: u32 = 0x12345678;
let bytes: [u8; 4] = unsafe { std::mem::transmute(num) };
// On little-endian platforms: [0x78, 0x56, 0x34, 0x12]

// Transmute an address to a function pointer
let addr: usize = get_fn_address();
let function: fn() -> i32 = unsafe { std::mem::transmute(addr) };
let result = function(); // Very dangerous!
```

#### Safer Alternatives to Transmutation

```rust
// Instead of transmuting a u32 to [u8; 4], use to_ne_bytes
let num: u32 = 0x12345678;
let bytes = num.to_ne_bytes(); // Safe!

// Instead of transmuting a pointer to usize, use as_ptr and as
let s = "hello";
let ptr = s.as_ptr();
let addr = ptr as usize; // Safe!

// Instead of transmuting to change lifetimes, use pointer casts
let data: &[u8] = &[1, 2, 3, 4];
// Unsafe but better than transmute for changing lifetime
let static_data: &'static [u8] = unsafe { &*(data as *const [u8]) };
```

**Example**: Converting between slices of different types

```rust
// Convert &[T] to &[U] when sizes match
fn cast_slice<T, U>(slice: &[T]) -> &[U] {
    // Verify types are compatible for transmutation
    assert_eq!(std::mem::size_of::<T>(), std::mem::size_of::<U>());
    assert_eq!(std::mem::align_of::<T>(), std::mem::align_of::<U>());
    
    let len = slice.len();
    let ptr = slice.as_ptr() as *const U;
    
    // Safe because we've verified size and alignment
    unsafe { std::slice::from_raw_parts(ptr, len) }
}

// Example usage
let ints = [1i32, 2, 3, 4];
let floats = cast_slice::<i32, f32>(&ints);
```

### Bit Manipulation

Bit manipulation is essential for low-level programming, especially when working with hardware, network protocols, or optimizing memory usage.

**Key Points**:

- Useful for packing data into smaller spaces
- Essential for implementing binary protocols
- Important for performance-critical applications
- Platform-dependent results need careful handling
- Includes operations like shifting, masking, and bit testing

#### Basic Bit Operations

```rust
// Basic operations
let a = 0b1010;
let b = 0b1100;

let bitwise_and = a & b;     // 0b1000 (8)
let bitwise_or = a | b;      // 0b1110 (14)
let bitwise_xor = a ^ b;     // 0b0110 (6)
let bitwise_not = !a;        // Depends on type, for u8: 0b11110101 (245)

// Shifts
let left_shift = a << 1;     // 0b10100 (20)
let right_shift = a >> 1;    // 0b0101 (5)

// Bit testing
let has_bit_set = (a & (1 << 3)) != 0;  // Check if bit 3 is set

// Bit setting/clearing
let with_bit_set = a | (1 << 2);        // Set bit 2
let with_bit_cleared = a & !(1 << 3);   // Clear bit 3
let with_bit_toggled = a ^ (1 << 1);    // Toggle bit 1
```

#### Bit Manipulation Patterns

```rust
// Count trailing zeros
let trailing_zeros = 0b10100u32.trailing_zeros();  // 2

// Count leading zeros
let leading_zeros = 0b10100u32.leading_zeros();    // 27 (for u32)

// Count ones
let ones = 0b10101u32.count_ones();               // 3

// Rotate left/right
let rotated_left = 0b10100u32.rotate_left(1);     // 0b101000
let rotated_right = 0b10100u32.rotate_right(1);   // 0b01010

// Swap bytes
let swapped = 0x12345678u32.swap_bytes();         // 0x78563412

// Extract bits n..m
let extract_bits = |val: u32, start: u32, len: u32| -> u32 {
    (val >> start) & ((1 << len) - 1)
};
let bits = extract_bits(0b10110, 1, 3);  // 0b011 (3)
```

**Example**: Implementing a simple bit flag set

```rust
#[derive(Debug, Clone, Copy)]
struct BitFlags(u32);

impl BitFlags {
    const FLAG_A: u32 = 1 << 0;
    const FLAG_B: u32 = 1 << 1;
    const FLAG_C: u32 = 1 << 2;
    
    fn new() -> Self {
        BitFlags(0)
    }
    
    fn with_flags(flags: u32) -> Self {
        BitFlags(flags)
    }
    
    fn has_flag(&self, flag: u32) -> bool {
        (self.0 & flag) == flag
    }
    
    fn set_flag(&mut self, flag: u32) {
        self.0 |= flag;
    }
    
    fn clear_flag(&mut self, flag: u32) {
        self.0 &= !flag;
    }
    
    fn toggle_flag(&mut self, flag: u32) {
        self.0 ^= flag;
    }
}

// Usage
let mut flags = BitFlags::new();
flags.set_flag(BitFlags::FLAG_A | BitFlags::FLAG_C);
assert!(flags.has_flag(BitFlags::FLAG_A));
assert!(!flags.has_flag(BitFlags::FLAG_B));
assert!(flags.has_flag(BitFlags::FLAG_C));
```

### Uninitialized Memory

Working with uninitialized memory is one of the most powerful but dangerous aspects of low-level programming. Rust provides several tools to handle this safely.

**Key Points**:

- Reading uninitialized memory is undefined behavior
- Rust provides tools like `MaybeUninit` to work safely with uninitialized memory
- Crucial for implementing high-performance data structures
- Requires careful tracking of initialized vs. uninitialized regions
- May require explicit drop handling for partially initialized data

#### Creating an Uninitialized Array

```rust
use std::mem::MaybeUninit;

// Create uninitialized array (safer alternative to deprecated mem::uninitialized)
let mut data: [MaybeUninit<u32>; 1000] = unsafe {
    MaybeUninit::uninit().assume_init()
};

// Initialize parts of it
for i in 0..500 {
    data[i].write(i as u32);
}

// Work with initialized part (first 500 elements)
let initialized_slice = &data[0..500];
for item in initialized_slice {
    // Read the initialized value
    let value = unsafe { item.assume_init() };
    println!("{}", value);
}
```

#### Initializing Memory In-Place

```rust
use std::mem::MaybeUninit;
use std::ptr;

// Allocate memory for a complex structure
let mut buffer = MaybeUninit::<Vec<String>>::uninit();

// Initialize it in-place
unsafe {
    ptr::write(buffer.as_mut_ptr(), vec![
        String::from("hello"),
        String::from("world")
    ]);
}

// Use the initialized value
let vec = unsafe { buffer.assume_init() };
assert_eq!(vec.len(), 2);
```

**Example**: Building an efficient buffer pool using uninitialized memory

```rust
use std::mem::{MaybeUninit, ManuallyDrop};
use std::ptr;
use std::alloc::{alloc, dealloc, Layout};

struct BufferPool<T> {
    // Each buffer is uninitialized until requested
    buffers: Vec<MaybeUninit<T>>,
    // Track which buffers are currently in use
    in_use: Vec<bool>,
}

impl<T> BufferPool<T> {
    pub fn new(capacity: usize) -> Self {
        let mut buffers = Vec::with_capacity(capacity);
        let mut in_use = Vec::with_capacity(capacity);
        
        // Allocate uninitialized buffers
        for _ in 0..capacity {
            buffers.push(MaybeUninit::uninit());
            in_use.push(false);
        }
        
        BufferPool { buffers, in_use }
    }
    
    // Get a buffer, initializing it with the provided value
    pub fn acquire(&mut self, value: T) -> Option<BufferHandle<T>> {
        // Find first available buffer
        let index = self.in_use.iter().position(|&in_use| !in_use)?;
        
        // Mark as in use
        self.in_use[index] = true;
        
        // Initialize the buffer with the value
        unsafe {
            ptr::write(self.buffers[index].as_mut_ptr(), value);
        }
        
        Some(BufferHandle {
            pool: self,
            index,
            _marker: std::marker::PhantomData,
        })
    }
    
    // Internal function to release a buffer
    fn release(&mut self, index: usize) {
        if self.in_use[index] {
            // Mark as no longer in use
            self.in_use[index] = false;
            
            // Drop the value
            unsafe {
                ptr::drop_in_place(self.buffers[index].as_mut_ptr());
            }
        }
    }
}

struct BufferHandle<'a, T> {
    pool: &'a mut BufferPool<T>,
    index: usize,
    _marker: std::marker::PhantomData<T>,
}

impl<'a, T> std::ops::Deref for BufferHandle<'a, T> {
    type Target = T;
    
    fn deref(&self) -> &T {
        unsafe { &*self.pool.buffers[self.index].as_ptr() }
    }
}

impl<'a, T> std::ops::DerefMut for BufferHandle<'a, T> {
    fn deref_mut(&mut self) -> &mut T {
        unsafe { &mut *self.pool.buffers[self.index].as_mut_ptr() }
    }
}

impl<'a, T> Drop for BufferHandle<'a, T> {
    fn drop(&mut self) {
        self.pool.release(self.index);
    }
}

// Safety: clean up any initialized buffers
impl<T> Drop for BufferPool<T> {
    fn drop(&mut self) {
        for i in 0..self.buffers.len() {
            if self.in_use[i] {
                unsafe {
                    ptr::drop_in_place(self.buffers[i].as_mut_ptr());
                }
            }
        }
    }
}
```

**Conclusion**: Memory manipulation in Rust provides the power of low-level control while maintaining safety through carefully designed abstractions. The `std::mem` module, along with types like `MaybeUninit<T>` and `ManuallyDrop<T>`, enable developers to work efficiently with memory when performance is critical. While these features open the door to undefined behavior, Rust's design encourages best practices that minimize risks. By understanding these tools, you can write high-performance code that interfaces with hardware, implements custom data structures, or optimizes critical paths without sacrificing Rust's safety guarantees.

---

