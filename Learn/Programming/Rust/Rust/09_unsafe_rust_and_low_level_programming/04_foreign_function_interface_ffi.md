## Foreign Function Interface (FFI)


### extern "C" Functions

The `extern "C"` keyword allows Rust to interact with code written in other languages through the C ABI (Application Binary Interface).

**Key Points**:

- Defines functions that follow C calling conventions
- Enables Rust code to be called from other languages
- Provides a mechanism for language interoperability
- No runtime overhead compared to regular Rust functions
- Critical for creating libraries usable from C/C++

#### Defining an extern "C" Function

```rust
// Function that can be called from C
#[no_mangle]
pub extern "C" fn add(a: i32, b: i32) -> i32 {
    a + b
}

// Function with C compatibility and custom naming
#[no_mangle]
#[export_name = "multiply_integers"]
pub extern "C" fn multiply(a: i32, b: i32) -> i32 {
    a * b
}
```

#### Calling Convention Variants

```rust
// Standard C calling convention
extern "C" fn standard_c_function() {
    // implementation
}

// System-specific calling conventions
extern "system" fn windows_api_compatible() {
    // Works with Windows API on Windows
}

// Other supported calling conventions
extern "cdecl" fn c_declaration_convention() {}
extern "stdcall" fn standard_call_convention() {}
extern "fastcall" fn fast_call_convention() {}
extern "win64" fn windows_64bit_convention() {}
extern "sysv64" fn system_v_64bit_convention() {}
```

**Example**: Creating a C-callable Rust library

```rust
// lib.rs
use std::ffi::{CStr, CString};
use std::os::raw::c_char;

#[no_mangle]
pub extern "C" fn process_data(input: *const c_char) -> *mut c_char {
    // Safety: ensure input pointer is valid
    let c_str = unsafe {
        if input.is_null() {
            return std::ptr::null_mut();
        }
        CStr::from_ptr(input)
    };
    
    // Convert to Rust string and process
    let rust_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    
    let result = format!("Processed: {}", rust_str.to_uppercase());
    
    // Convert back to C string
    let c_result = match CString::new(result) {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    
    // Return the raw pointer - ownership transferred to caller
    c_result.into_raw()
}

// Function to free memory allocated by Rust
#[no_mangle]
pub extern "C" fn free_rust_string(ptr: *mut c_char) {
    unsafe {
        if !ptr.is_null() {
            // Convert back to CString to properly deallocate
            let _ = CString::from_raw(ptr);
        }
    }
}
```

### extern Blocks

Extern blocks declare functions that are implemented outside of Rust, typically in C libraries, allowing Rust to call into external code.

**Key Points**:

- Declares external functions without providing their implementation
- Used to interface with existing C libraries
- Links against library specified with `#[link]` attribute
- Can include type definitions for C structures
- May require unsafe blocks when calling the functions

#### Basic Extern Block

```rust
// Declare external functions from the C standard library
#[link(name = "c")]
extern "C" {
    fn malloc(size: usize) -> *mut u8;
    fn free(ptr: *mut u8);
    fn strlen(s: *const u8) -> usize;
}

// Usage requires unsafe block
fn get_memory(size: usize) -> *mut u8 {
    unsafe { malloc(size) }
}
```

#### Linking Multiple Libraries

```rust
// Link against OpenSSL libraries
#[link(name = "ssl")]
#[link(name = "crypto")]
extern "C" {
    fn SSL_new(ctx: *mut SSL_CTX) -> *mut SSL;
    fn SSL_free(ssl: *mut SSL);
    // More OpenSSL function declarations...
}

// Link against a custom library with specific parameters
#[link(name = "mylib", kind = "static")]
#[link(name = "support", kind = "framework")]
extern "C" {
    fn my_custom_function(data: *const u8, len: usize) -> i32;
}
```

**Example**: Interfacing with SDL2 library

```rust
// Partial SDL2 bindings
use std::os::raw::{c_char, c_int, c_void};

#[repr(C)]
pub struct SDL_Window;

#[repr(C)]
pub struct SDL_Renderer;

#[link(name = "SDL2")]
extern "C" {
    pub fn SDL_Init(flags: u32) -> c_int;
    pub fn SDL_CreateWindow(
        title: *const c_char,
        x: c_int,
        y: c_int,
        w: c_int,
        h: c_int,
        flags: u32,
    ) -> *mut SDL_Window;
    pub fn SDL_CreateRenderer(
        window: *mut SDL_Window,
        index: c_int,
        flags: u32,
    ) -> *mut SDL_Renderer;
    pub fn SDL_DestroyWindow(window: *mut SDL_Window);
    pub fn SDL_DestroyRenderer(renderer: *mut SDL_Renderer);
    pub fn SDL_Quit();
}

// Safe wrapper for SDL initialization
pub fn init_sdl() -> Result<(), String> {
    const SDL_INIT_VIDEO: u32 = 0x00000020;
    
    let result = unsafe { SDL_Init(SDL_INIT_VIDEO) };
    if result != 0 {
        return Err("Failed to initialize SDL".to_string());
    }
    
    Ok(())
}
```

### Calling C from Rust

Integrating C libraries into Rust projects involves more than just function declarations; it requires understanding how to properly handle types, memory, and error conditions.

**Key Points**:

- Requires matching Rust types with C equivalents
- Often needs safe wrapper functions around unsafe FFI calls
- May involve dynamic library loading
- Handles error codes and return values from C functions
- Manages pointers and memory allocated by C code

#### Basic C Function Call

```rust
use std::os::raw::{c_int, c_char};
use std::ffi::CString;

extern "C" {
    fn printf(format: *const c_char, ...) -> c_int;
}

fn print_message(message: &str) -> Result<(), std::ffi::NulError> {
    let c_message = CString::new(message)?;
    unsafe {
        printf(c_message.as_ptr());
    }
    Ok(())
}
```

#### Working with C Libraries

```rust
use std::os::raw::{c_int, c_void, c_char};
use std::ffi::{CStr, CString};

#[repr(C)]
struct sqlite3;

extern "C" {
    fn sqlite3_open(filename: *const c_char, ppdb: *mut *mut sqlite3) -> c_int;
    fn sqlite3_close(db: *mut sqlite3) -> c_int;
    fn sqlite3_errmsg(db: *mut sqlite3) -> *const c_char;
}

fn open_database(path: &str) -> Result<*mut sqlite3, String> {
    let c_path = CString::new(path).map_err(|_| "Invalid path string".to_string())?;
    let mut db_ptr: *mut sqlite3 = std::ptr::null_mut();
    
    let result = unsafe { sqlite3_open(c_path.as_ptr(), &mut db_ptr) };
    
    if result != 0 {
        let error = unsafe {
            let msg = sqlite3_errmsg(db_ptr);
            CStr::from_ptr(msg).to_string_lossy().into_owned()
        };
        
        // Clean up on error
        unsafe { sqlite3_close(db_ptr) };
        
        Err(error)
    } else {
        Ok(db_ptr)
    }
}
```

**Example**: Safe wrapper around libcurl

```rust
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_void, c_long};
use std::ptr;

// Opaque struct from libcurl
#[repr(C)]
struct CURL;

// Function typedefs for callbacks
type WriteCallback = extern "C" fn(
    ptr: *mut c_char,
    size: usize,
    nmemb: usize,
    userdata: *mut c_void,
) -> usize;

// External libcurl functions
#[link(name = "curl")]
extern "C" {
    fn curl_easy_init() -> *mut CURL;
    fn curl_easy_setopt(curl: *mut CURL, option: c_long, ...) -> c_long;
    fn curl_easy_perform(curl: *mut CURL) -> c_long;
    fn curl_easy_cleanup(curl: *mut CURL);
}

// Constants from curl.h
const CURLOPT_URL: c_long = 10002;
const CURLOPT_WRITEFUNCTION: c_long = 20011;
const CURLOPT_WRITEDATA: c_long = 10001;
const CURLE_OK: c_long = 0;

// Callback to receive data
extern "C" fn write_callback(
    ptr: *mut c_char,
    size: usize,
    nmemb: usize,
    userdata: *mut c_void,
) -> usize {
    let real_size = size * nmemb;
    
    unsafe {
        let data = &mut *(userdata as *mut Vec<u8>);
        let slice = std::slice::from_raw_parts(ptr as *const u8, real_size);
        data.extend_from_slice(slice);
    }
    
    real_size
}

// Safe wrapper for curl
struct Curl {
    handle: *mut CURL,
}

impl Curl {
    fn new() -> Option<Self> {
        let handle = unsafe { curl_easy_init() };
        if handle.is_null() {
            None
        } else {
            Some(Curl { handle })
        }
    }
    
    fn fetch(&self, url: &str) -> Result<Vec<u8>, String> {
        let c_url = CString::new(url).map_err(|_| "Invalid URL string".to_string())?;
        let mut buffer = Vec::new();
        
        unsafe {
            // Set URL
            let res = curl_easy_setopt(self.handle, CURLOPT_URL, c_url.as_ptr());
            if res != CURLE_OK {
                return Err(format!("Failed to set URL, error code: {}", res));
            }
            
            // Set write callback
            curl_easy_setopt(self.handle, CURLOPT_WRITEFUNCTION, write_callback as *const c_void);
            
            // Set data pointer for callback
            curl_easy_setopt(self.handle, CURLOPT_WRITEDATA, &mut buffer as *mut _ as *mut c_void);
            
            // Perform request
            let res = curl_easy_perform(self.handle);
            if res != CURLE_OK {
                return Err(format!("Request failed, error code: {}", res));
            }
        }
        
        Ok(buffer)
    }
}

impl Drop for Curl {
    fn drop(&mut self) {
        unsafe { curl_easy_cleanup(self.handle) }
    }
}
```

### Creating C-compatible APIs

Designing Rust APIs that can be consumed by C or other languages requires careful attention to ABI compatibility, memory management, and error handling.

**Key Points**:

- Functions must follow C ABI with `extern "C"` and `#[no_mangle]`
- Types must have stable memory layout using `#[repr(C)]`
- Errors must be handled without panicking
- Memory ownership must be explicitly managed
- Documentation should include usage from C

#### C-compatible Struct

```rust
// C-compatible struct with stable layout
#[repr(C)]
pub struct Point {
    pub x: f64,
    pub y: f64,
}

// C-compatible enum with specified values
#[repr(C)]
pub enum Status {
    Success = 0,
    InvalidArgument = 1,
    OutOfMemory = 2,
    IoError = 3,
}
```

#### C-compatible API with Error Handling

```rust
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int};
use std::ptr;

// Error codes
pub const SUCCESS: c_int = 0;
pub const ERROR_NULL_POINTER: c_int = 1;
pub const ERROR_INVALID_UTF8: c_int = 2;
pub const ERROR_INTERNAL: c_int = 3;

// String processing function with proper error handling
#[no_mangle]
pub extern "C" fn to_uppercase(
    input: *const c_char,
    output: *mut *mut c_char,
) -> c_int {
    // Check for null pointers
    if input.is_null() || output.is_null() {
        return ERROR_NULL_POINTER;
    }
    
    // Convert C string to Rust string
    let c_str = unsafe { CStr::from_ptr(input) };
    let rust_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => return ERROR_INVALID_UTF8,
    };
    
    // Process the string
    let uppercase = rust_str.to_uppercase();
    
    // Convert back to C string
    let c_result = match CString::new(uppercase) {
        Ok(s) => s,
        Err(_) => return ERROR_INTERNAL,
    };
    
    // Return the result
    unsafe {
        *output = c_result.into_raw();
    }
    
    SUCCESS
}

// Free memory allocated by the library
#[no_mangle]
pub extern "C" fn free_string(ptr: *mut c_char) {
    unsafe {
        if !ptr.is_null() {
            let _ = CString::from_raw(ptr);
        }
    }
}
```

**Example**: Creating a C-compatible data processing library

```rust
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_double};
use std::slice;
use std::ptr;

// Opaque handle type for C API
pub struct Context {
    data: Vec<f64>,
    name: String,
}

// Create type alias for pointer to opaque type
pub type ContextHandle = *mut Context;

// Create a new context
#[no_mangle]
pub extern "C" fn create_context(name: *const c_char) -> ContextHandle {
    // Check input
    if name.is_null() {
        return ptr::null_mut();
    }
    
    // Convert name to Rust string
    let c_name = match unsafe { CStr::from_ptr(name) }.to_str() {
        Ok(n) => n,
        Err(_) => return ptr::null_mut(),
    };
    
    // Allocate context
    Box::into_raw(Box::new(Context {
        data: Vec::new(),
        name: c_name.to_owned(),
    }))
}

// Add data to the context
#[no_mangle]
pub extern "C" fn add_data(
    ctx: ContextHandle,
    data: *const c_double,
    count: c_int,
) -> c_int {
    // Validate parameters
    if ctx.is_null() || data.is_null() || count <= 0 {
        return 0; // Error
    }
    
    let context = unsafe { &mut *ctx };
    
    // Convert to slice and add data
    let slice = unsafe { slice::from_raw_parts(data, count as usize) };
    context.data.extend_from_slice(slice);
    
    1 // Success
}

// Calculate statistics
#[no_mangle]
pub extern "C" fn calculate_average(ctx: ContextHandle) -> c_double {
    if ctx.is_null() {
        return 0.0;
    }
    
    let context = unsafe { &*ctx };
    
    if context.data.is_empty() {
        return 0.0;
    }
    
    let sum: f64 = context.data.iter().sum();
    sum / context.data.len() as f64
}

// Get context name
#[no_mangle]
pub extern "C" fn get_context_name(
    ctx: ContextHandle,
    buffer: *mut c_char,
    buffer_size: c_int,
) -> c_int {
    if ctx.is_null() || buffer.is_null() || buffer_size <= 0 {
        return 0; // Error
    }
    
    let context = unsafe { &*ctx };
    
    let c_name = match CString::new(context.name.clone()) {
        Ok(s) => s,
        Err(_) => return 0,
    };
    
    let bytes = c_name.as_bytes_with_nul();
    if bytes.len() > buffer_size as usize {
        return 0; // Buffer too small
    }
    
    unsafe {
        ptr::copy_nonoverlapping(
            bytes.as_ptr() as *const c_char,
            buffer,
            bytes.len(),
        );
    }
    
    1 // Success
}

// Free the context
#[no_mangle]
pub extern "C" fn destroy_context(ctx: ContextHandle) {
    if !ctx.is_null() {
        unsafe {
            // Convert back to Box and drop
            let _ = Box::from_raw(ctx);
        }
    }
}
```

### bindgen and cbindgen

Automated tools can significantly simplify the process of creating and maintaining FFI bindings between Rust and C/C++.

**Key Points**:

- bindgen automatically generates Rust FFI bindings from C/C++ headers
- cbindgen produces C/C++ headers from Rust code
- Both tools help keep bindings up-to-date as code evolves
- They handle complex type mappings and ABI compatibility
- Reduce manual work and potential sources of error

#### Using bindgen

```toml
# Cargo.toml
[build-dependencies]
bindgen = "0.60.0"
```

```rust
// build.rs
use std::env;
use std::path::PathBuf;

fn main() {
    // Tell cargo to rerun if header changes
    println!("cargo:rerun-if-changed=wrapper.h");
    
    // Link to C library
    println!("cargo:rustc-link-lib=example");
    
    // Generate bindings
    let bindings = bindgen::Builder::default()
        .header("wrapper.h")
        .parse_callbacks(Box::new(bindgen::CargoCallbacks))
        .allowlist_function("example_.*")
        .allowlist_type("Example.*")
        .generate()
        .expect("Unable to generate bindings");
    
    // Write the bindings to the $OUT_DIR/bindings.rs file
    let out_path = PathBuf::from(env::var("OUT_DIR").unwrap());
    bindings
        .write_to_file(out_path.join("bindings.rs"))
        .expect("Couldn't write bindings!");
}
```

```rust
// wrapper.h
#include <example_lib.h>
```

```rust
// lib.rs
#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

// Include the generated bindings
include!(concat!(env!("OUT_DIR"), "/bindings.rs"));

// Safe wrapper for C function
pub fn example_function(value: i32) -> i32 {
    unsafe { example_add(value, 5) }
}
```

#### Using cbindgen

```toml
# Cargo.toml
[build-dependencies]
cbindgen = "0.24.0"
```

```rust
// build.rs
use std::env;

fn main() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    
    // Generate C header
    cbindgen::Builder::new()
        .with_crate(crate_dir)
        .generate()
        .expect("Unable to generate bindings")
        .write_to_file("include/my_library.h");
}
```

```rust
// lib.rs
use std::os::raw::{c_char, c_int};
use std::ffi::CString;

/// A point in 2D space
#[repr(C)]
pub struct Point {
    pub x: f64,
    pub y: f64,
}

/// Calculate distance between two points
#[no_mangle]
pub extern "C" fn distance(p1: Point, p2: Point) -> f64 {
    let dx = p2.x - p1.x;
    let dy = p2.y - p1.y;
    (dx * dx + dy * dy).sqrt()
}

/// Greet a person by name
#[no_mangle]
pub extern "C" fn greet(name: *const c_char) -> *mut c_char {
    let c_str = unsafe {
        if name.is_null() {
            return std::ptr::null_mut();
        }
        std::ffi::CStr::from_ptr(name)
    };
    
    let rust_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    
    let greeting = format!("Hello, {}!", rust_str);
    match CString::new(greeting) {
        Ok(s) => s.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Free a string created by this library
#[no_mangle]
pub extern "C" fn free_string(s: *mut c_char) {
    unsafe {
        if !s.is_null() {
            let _ = CString::from_raw(s);
        }
    }
}
```

**Example**: Complex project using both bindgen and cbindgen

```rust
// build.rs
use std::{env, path::PathBuf};

fn main() {
    // Generate C bindings for this crate
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    
    cbindgen::Builder::new()
        .with_crate(crate_dir.clone())
        .with_config(cbindgen::Config {
            language: cbindgen::Language::C,
            ..Default::default()
        })
        .generate()
        .expect("Unable to generate C header")
        .write_to_file("target/include/my_rust_lib.h");
    
    // Generate Rust bindings for C lib we depend on
    println!("cargo:rerun-if-changed=c_headers/external_lib.h");
    
    // Link to the C library
    println!("cargo:rustc-link-lib=external");
    println!("cargo:rustc-link-search=native=c_lib");
    
    let bindings = bindgen::Builder::default()
        .header("c_headers/external_lib.h")
        .parse_callbacks(Box::new(bindgen::CargoCallbacks))
        .generate()
        .expect("Unable to generate bindings");
    
    let out_path = PathBuf::from(env::var("OUT_DIR").unwrap());
    bindings
        .write_to_file(out_path.join("bindings.rs"))
        .expect("Couldn't write bindings!");
}
```

### Handling C Strings and Structures

Working with C strings and structures requires understanding differences in memory management, layout, and representation between Rust and C.

**Key Points**:

- C strings are null-terminated, unlike Rust strings
- C structures must match memory layout for compatibility
- Proper handling of memory ownership is crucial
- Special types help convert between Rust and C string representations
- Errors must be handled carefully when converting between representations

#### Working with C Strings

```rust
use std::ffi::{CStr, CString};
use std::os::raw::c_char;

// Convert Rust string to C string
fn to_c_string(s: &str) -> Result<CString, std::ffi::NulError> {
    CString::new(s)
}

// Convert C string to Rust string
unsafe fn from_c_string(s: *const c_char) -> Result<String, std::str::Utf8Error> {
    if s.is_null() {
        return Ok(String::new());
    }
    
    CStr::from_ptr(s).to_str().map(|s| s.to_owned())
}

// Using C string functions
extern "C" {
    fn strlen(s: *const c_char) -> usize;
    fn strcpy(dest: *mut c_char, src: *const c_char) -> *mut c_char;
}

// Example of using C string functions
fn get_c_string_length(s: &CString) -> usize {
    unsafe { strlen(s.as_ptr()) }
}
```

#### Working with C Structures

Working with C structures in Rust requires careful mapping between Rust's memory layout and C's structure representation. This is critical for ensuring data is correctly shared across the language boundary.

**Key Points**

- C structures must be represented in Rust with correct memory layout and alignment
- Rust provides `#[repr(C)]` attribute to ensure C-compatible memory layout
- Field ordering matters for compatibility with C structures
- Handling nested structures requires careful attention to layout guarantees

When working with C structures in Rust, you'll commonly use these techniques:

```rust
// Define a Rust struct with C-compatible memory layout
#[repr(C)]
struct Point {
    x: i32,
    y: i32,
}

// C-compatible enum
#[repr(C)]
enum Direction {
    North = 0,
    East = 1,
    South = 2,
    West = 3,
}

// C-compatible struct with complex fields
#[repr(C)]
struct Rectangle {
    top_left: Point,
    bottom_right: Point,
    color: u32,
    is_filled: bool,
}
```

### Memory Alignment and Padding

C structures often include padding for memory alignment. Rust's `#[repr(C)]` attribute ensures that the Rust structure follows C's alignment rules:

```rust
#[repr(C)]
struct AlignmentExample {
    a: u8,     // 1 byte + 3 bytes padding
    b: u32,    // 4 bytes
    c: u16,    // 2 bytes + 2 bytes padding
    d: u32,    // 4 bytes
}
// Total size: 16 bytes (due to alignment)
```

For precise control over memory layout:

```rust
#[repr(C, packed)]
struct PackedStruct {
    a: u8,     // 1 byte, no padding
    b: u32,    // 4 bytes, may not be aligned
    c: u16,    // 2 bytes, may not be aligned
}
// Total size: 7 bytes (due to packed attribute)
```

**Example**

A complete example showing interaction with a C library that uses structs:

```rust
// C header (example.h):
// typedef struct {
//     int width;
//     int height;
//     char* name;
// } Rectangle;
// 
// Rectangle create_rectangle(int width, int height, const char* name);
// void destroy_rectangle(Rectangle rect);

// Rust FFI code:
use std::ffi::{CString, c_char};
use std::os::raw::{c_int};

#[repr(C)]
struct Rectangle {
    width: c_int,
    height: c_int,
    name: *mut c_char,
}

extern "C" {
    fn create_rectangle(width: c_int, height: c_int, name: *const c_char) -> Rectangle;
    fn destroy_rectangle(rect: Rectangle);
}

fn main() {
    let name = CString::new("My Rectangle").unwrap();
    
    unsafe {
        let rect = create_rectangle(10, 20, name.as_ptr());
        println!("Created rectangle: {}x{}", rect.width, rect.height);
        
        // Clean up resources
        destroy_rectangle(rect);
    }
}
```

### Handling Nested and Complex Structures

Working with complex nested structures requires careful attention:

```rust
#[repr(C)]
struct ComplexStruct {
    data: *mut u8,
    length: usize,
    capacity: usize,
    next: *mut ComplexStruct,
}

impl ComplexStruct {
    // Safe wrapper to create from Rust data
    fn new(data: Vec<u8>) -> Self {
        let mut data_vec = data;
        let ptr = data_vec.as_mut_ptr();
        let length = data_vec.len();
        let capacity = data_vec.capacity();
        
        // Important: forget the original vec to prevent double-free
        std::mem::forget(data_vec);
        
        ComplexStruct {
            data: ptr,
            length,
            capacity,
            next: std::ptr::null_mut(),
        }
    }
    
    // Safe cleanup
    unsafe fn free(&mut self) {
        if !self.data.is_null() {
            // Reconstruct the Vec to properly free memory
            let _ = Vec::from_raw_parts(self.data, self.length, self.capacity);
            self.data = std::ptr::null_mut();
        }
    }
}
```

### Unions in FFI

C unions can also be represented in Rust:

```rust
#[repr(C)]
union CUnion {
    integer_value: i32,
    float_value: f32,
    boolean_value: bool,
}

// Usage requires unsafe
unsafe {
    let mut value = CUnion { integer_value: 42 };
    println!("As integer: {}", value.integer_value);
    value.float_value = 3.14;
    println!("As float: {}", value.float_value);
}
```

### Memory Management across FFI

When passing structures across FFI boundaries, memory ownership must be carefully managed:

**Key Points**

- Understand who owns the memory: Rust or C?
- Define clear ownership transfer conventions
- Use appropriate memory allocation strategies
- Implement proper cleanup mechanisms to prevent leaks

```rust
// A safe Rust wrapper around a C structure
struct SafeRectangle {
    inner: *mut Rectangle,
}

impl SafeRectangle {
    fn new(width: i32, height: i32, name: &str) -> Self {
        let c_name = CString::new(name).unwrap();
        
        let inner = unsafe {
            create_rectangle(width, height, c_name.as_ptr())
        };
        
        SafeRectangle { inner }
    }
    
    fn width(&self) -> i32 {
        unsafe { (*self.inner).width }
    }
    
    fn height(&self) -> i32 {
        unsafe { (*self.inner).height }
    }
}

impl Drop for SafeRectangle {
    fn drop(&mut self) {
        unsafe {
            if !self.inner.is_null() {
                destroy_rectangle(*self.inner);
            }
        }
    }
}
```

### Type Checking and Safety

Rust's type system can help catch potential FFI errors:

```rust
// Using newtype pattern to prevent mixing up different C integer types
#[repr(transparent)]
struct WindowHandle(u32);

#[repr(transparent)]
struct DeviceHandle(u32);

extern "C" {
    fn c_function_using_window(handle: WindowHandle);
    fn c_function_using_device(handle: DeviceHandle);
}

// This prevents accidentally passing a device handle to a window function
```

### Bitfields and Custom Layouts

C bitfields require special handling in Rust:

```rust
// C struct with bitfields:
// struct Flags {
//     unsigned int readable : 1;
//     unsigned int writable : 1;
//     unsigned int executable : 1;
// };

#[repr(C)]
struct Flags {
    bits: u8,
}

impl Flags {
    const READABLE: u8 = 0b00000001;
    const WRITABLE: u8 = 0b00000010;
    const EXECUTABLE: u8 = 0b00000100;
    
    fn new() -> Self {
        Flags { bits: 0 }
    }
    
    fn set_readable(&mut self, value: bool) {
        if value {
            self.bits |= Self::READABLE;
        } else {
            self.bits &= !Self::READABLE;
        }
    }
    
    fn is_readable(&self) -> bool {
        self.bits & Self::READABLE != 0
    }
    
    // Similar methods for other flags...
}
```

### Commonly Used C Structures in FFI

Many Rust FFI interfaces need to work with common C structures:

```rust
// Common C time structure
#[repr(C)]
struct CTm {
    tm_sec: c_int,
    tm_min: c_int,
    tm_hour: c_int,
    tm_mday: c_int,
    tm_mon: c_int,
    tm_year: c_int,
    tm_wday: c_int,
    tm_yday: c_int,
    tm_isdst: c_int,
}

// Socket address structures
#[repr(C)]
struct CSockAddr {
    sa_family: u16,
    sa_data: [c_char; 14],
}

// File descriptor sets for select()
#[repr(C)]
struct CFdSet {
    fds_bits: [c_long; 16],
}
```

**Conclusion**

Working with C structures in Rust requires careful attention to memory layout, alignment, and ownership. By properly using the `#[repr(C)]` attribute and understanding C's memory model, you can safely and efficiently bridge the gap between Rust and C code. The key to successful FFI is creating a clean abstraction that handles the unsafe operations internally while providing a safe interface to the rest of your Rust code.

### Advanced FFI Techniques

Beyond the basics of handling C strings and structures, Rust's FFI capabilities extend to several advanced use cases:

#### Callbacks across FFI Boundaries

Passing Rust functions to C as callbacks requires careful lifetime management:

```rust
type CallbackFn = extern "C" fn(data: *mut c_void) -> c_int;

extern "C" {
    fn register_callback(callback: CallbackFn, user_data: *mut c_void);
}

extern "C" fn rust_callback(data: *mut c_void) -> c_int {
    // Safe conversion back to original data
    let rust_data = unsafe { &mut *(data as *mut RustData) };
    println!("Callback called with value: {}", rust_data.value);
    0 // Success
}

struct RustData {
    value: i32,
}

fn main() {
    let mut data = RustData { value: 42 };
    
    unsafe {
        register_callback(rust_callback, &mut data as *mut _ as *mut c_void);
    }
    
    // Note: data must remain valid while the callback is registered!
}
```

#### Handling Variadic Functions

Interacting with C's variadic functions (like printf):

```rust
extern "C" {
    fn printf(format: *const c_char, ...) -> c_int;
}

fn main() {
    let format = CString::new("Number: %d, String: %s\n").unwrap();
    let message = CString::new("Hello from Rust").unwrap();
    
    unsafe {
        printf(format.as_ptr(), 42, message.as_ptr());
    }
}
```

#### Dynamic Library Loading

Loading C libraries dynamically at runtime:

```rust
use libloading::{Library, Symbol};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Open the library
    let lib = Library::new("libexample.so")?;
    
    unsafe {
        // Load a function from the library
        let func: Symbol<unsafe extern "C" fn(x: i32) -> i32> = 
            lib.get(b"example_function")?;
        
        // Call the function
        let result = func(42);
        println!("Result: {}", result);
    }
    
    Ok(())
}
```

#### Threading Considerations

When using FFI across threads, special care is needed:

```rust
// Example of thread-safe FFI
use std::thread;

extern "C" {
    fn thread_safe_c_function(value: i32) -> i32;
}

fn main() {
    let handles: Vec<_> = (0..5)
        .map(|i| {
            thread::spawn(move || {
                let result = unsafe { thread_safe_c_function(i) };
                println!("Thread {} got result {}", i, result);
            })
        })
        .collect();
    
    for handle in handles {
        handle.join().unwrap();
    }
}
```

#### Platform-Specific Considerations

Handling platform differences in FFI:

```rust
#[cfg(target_os = "windows")]
extern "system" {  // Windows uses "system" calling convention
    fn WindowsSpecificFunction(param: i32) -> i32;
}

#[cfg(not(target_os = "windows"))]
extern "C" {  // Other platforms use "C" calling convention
    fn unix_specific_function(param: i32) -> i32;
}

fn cross_platform_function(value: i32) -> i32 {
    unsafe {
        #[cfg(target_os = "windows")]
        {
            WindowsSpecificFunction(value)
        }
        #[cfg(not(target_os = "windows"))]
        {
            unix_specific_function(value)
        }
    }
}
```

**Conclusion**

Rust's FFI capabilities provide a powerful way to interoperate with C code while maintaining type safety and memory safety wherever possible. By understanding how to properly handle C structures, manage memory across language boundaries, and work with callbacks and platform-specific details, you can create robust applications that leverage existing C libraries while benefiting from Rust's safety guarantees.

Related topics you might want to explore:

- Rust's unsafe code guidelines
- Cross-language testing strategies for FFI
- Performance optimization for FFI boundaries
- FFI with languages other than C (C++, Objective-C, etc.)
- Dynamic vs. static linking considerations

