## CGO for C Integration


CGO enables calling C code from Go and vice versa, facilitating integration with existing C libraries.

### Basic CGO Usage

```go
package main

/*
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Simple C function
int add(int a, int b) {
    return a + b;
}

// String manipulation
char* concat_strings(const char* str1, const char* str2) {
    size_t len1 = strlen(str1);
    size_t len2 = strlen(str2);
    char* result = malloc(len1 + len2 + 1);
    strcpy(result, str1);
    strcat(result, str2);
    return result;
}

// Array processing
void process_array(int* arr, int size) {
    for (int i = 0; i < size; i++) {
        arr[i] *= 2;
    }
}

// Callback function type
typedef void (*callback_func)(int);

// Function that accepts callback
void call_callback(callback_func cb, int value) {
    cb(value);
}
*/
import "C"

import (
    "fmt"
    "unsafe"
)

func basicCGO() {
    // Simple function call
    result := C.add(10, 20)
    fmt.Printf("C.add(10, 20) = %d\n", result)
    
    // String operations
    str1 := C.CString("Hello, ")
    str2 := C.CString("World!")
    defer C.free(unsafe.Pointer(str1))
    defer C.free(unsafe.Pointer(str2))
    
    concatenated := C.concat_strings(str1, str2)
    defer C.free(unsafe.Pointer(concatenated))
    
    goString := C.GoString(concatenated)
    fmt.Printf("Concatenated: %s\n", goString)
    
    // Array processing
    goArray := []int{1, 2, 3, 4, 5}
    cArray := (*C.int)(unsafe.Pointer(&goArray[0]))
    C.process_array(cArray, C.int(len(goArray)))
    
    fmt.Printf("Processed array: %v\n", goArray)
}
```

### Advanced CGO Patterns

```go
// Wrapper for C library with error handling
package mathlib

/*
#include <math.h>
#include <errno.h>

// Error handling wrapper
double safe_sqrt(double x, int* error) {
    errno = 0;
    double result = sqrt(x);
    *error = errno;
    return result;
}

// Complex number operations
typedef struct {
    double real;
    double imag;
} complex_t;

complex_t add_complex(complex_t a, complex_t b) {
    complex_t result;
    result.real = a.real + b.real;
    result.imag = a.imag + b.imag;
    return result;
}

// Memory management helpers
void* allocate_buffer(size_t size) {
    return malloc(size);
}

void free_buffer(void* ptr) {
    free(ptr);
}
*/
import "C"

import (
    "errors"
    "fmt"
    "unsafe"
)

type Complex struct {
    Real, Imag float64
}

// Safe wrapper for C sqrt function
func SafeSqrt(x float64) (float64, error) {
    var cerror C.int
    result := C.safe_sqrt(C.double(x), &cerror)
    
    if cerror != 0 {
        return 0, errors.New("math domain error")
    }
    
    return float64(result), nil
}

// Complex number operations
func (c Complex) Add(other Complex) Complex {
    ca := C.complex_t{real: C.double(c.Real), imag: C.double(c.Imag)}
    cb := C.complex_t{real: C.double(other.Real), imag: C.double(other.Imag)}
    
    result := C.add_complex(ca, cb)
    
    return Complex{
        Real: float64(result.real),
        Imag: float64(result.imag),
    }
}

// Memory buffer management
type CBuffer struct {
    ptr  unsafe.Pointer
    size int
}

func NewCBuffer(size int) *CBuffer {
    ptr := C.allocate_buffer(C.size_t(size))
    if ptr == nil {
        return nil
    }
    
    return &CBuffer{
        ptr:  ptr,
        size: size,
    }
}

func (b *CBuffer) Free() {
    if b.ptr != nil {
        C.free_buffer(b.ptr)
        b.ptr = nil
    }
}

func (b *CBuffer) AsBytes() []byte {
    if b.ptr == nil {
        return nil
    }
    return C.GoBytes(b.ptr, C.int(b.size))
}

func (b *CBuffer) WriteBytes(data []byte) error {
    if b.ptr == nil {
        return errors.New("buffer is freed")
    }
    
    if len(data) > b.size {
        return errors.New("data too large for buffer")
    }
    
    C.memcpy(b.ptr, unsafe.Pointer(&data[0]), C.size_t(len(data)))
    return nil
}
```

### Callback Functions and Go/C Interop

```go
/*
// Callback definitions in C
typedef void (*log_callback)(const char* message);
typedef int (*compute_callback)(int x, int y);

// Global callback storage
static log_callback g_log_cb = NULL;
static compute_callback g_compute_cb = NULL;

// Callback registration
void register_log_callback(log_callback cb) {
    g_log_cb = cb;
}

void register_compute_callback(compute_callback cb) {
    g_compute_cb = cb;
}

// Functions that use callbacks
void log_message(const char* message) {
    if (g_log_cb != NULL) {
        g_log_cb(message);
    }
}

int compute_with_callback(int x, int y) {
    if (g_compute_cb != NULL) {
        return g_compute_cb(x, y);
    }
    return 0;
}

// Event loop simulation
void process_events(int count) {
    for (int i = 0; i < count; i++) {
        char buffer[100];
        snprintf(buffer, sizeof(buffer), "Processing event %d", i);
        log_message(buffer);
        
        int result = compute_with_callback(i, i * 2);
        snprintf(buffer, sizeof(buffer), "Computed result: %d", result);
        log_message(buffer);
    }
}
*/
import "C"

import (
    "fmt"
    "log"
)

// Go callback functions
//export logCallback
func logCallback(message *C.char) {
    goMessage := C.GoString(message)
    log.Printf("[C LOG] %s", goMessage)
}

//export computeCallback  
func computeCallback(x, y C.int) C.int {
    goX, goY := int(x), int(y)
    result := goX * goY + 10 // Custom computation
    return C.int(result)
}

func setupCallbacks() {
    // Register Go functions as C callbacks
    C.register_log_callback(C.log_callback(C.logCallback))
    C.register_compute_callback(C.compute_callback(C.computeCallback))
    
    // Process events using callbacks
    C.process_events(5)
}
```

**Key Points:**

- CGO enables seamless C library integration with performance overhead
- Memory management requires careful coordination between Go GC and C malloc/free
- Callback functions must be exported and follow CGO naming conventions
- String conversions between Go and C require explicit memory management

