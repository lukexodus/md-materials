## Memory debugging


Memory debugging involves the identification, isolation, and resolution of memory-related errors such as leaks, corruption, and invalid access patterns. In high-performance or systems-level languages (C, C++, Rust, Assembly), effective memory debugging is critical for stability and security.

**Key Points**

- **Memory Leaks:** Occur when allocated memory is not deallocated, leading to resource exhaustion. Detection involves tracking allocation sites and verifying reachability graphs at runtime.
    
- **Buffer Overflows/Underflows:** Writing or reading beyond the allocated bounds of a buffer (stack or heap). This corrupts adjacent data structures, control flow information (return addresses), or causes segmentation faults.
    
- **Use-After-Free (Dangling Pointers):** Accessing memory after it has been freed. This leads to undefined behavior, data corruption, or potential security vulnerabilities (arbitrary code execution).
    
- **Double Free:** Attempting to deallocate the same memory region twice. This corrupts the memory allocator's internal structures (free lists/bins).
    
- **Uninitialized Memory Read:** Reading from memory that has not been initialized. The behavior is non-deterministic and depends on the previous contents of that memory address.
    
- **Data Races:** Concurrent access to the same memory location by multiple threads without proper synchronization, where at least one access is a write.
    

**Tooling and Instrumentation**

- **AddressSanitizer (ASan):** A compiler-based instrumentation module (GCC/Clang) that detects out-of-bounds accesses, use-after-free, and double-free errors. It uses shadow memory to track the state of every byte of application memory (accessible, redzone, freed).
    
- **Valgrind (Memcheck):** A dynamic binary instrumentation framework. It runs the program on a virtual CPU, tracking every bit of memory (defined/undefined) and every byte of addressable memory. It is slower than ASan but does not require recompilation (though debug symbols help).
    
- **LeakSanitizer (LSan):** Often integrated with ASan, it detects memory leaks by scanning the memory heap for unreachable blocks at process exit.
    
- **Memory Sanitizer (MSan):** Detects reads of uninitialized memory. It tracks the initialization state of memory bits (shadow memory) and reports uses of uninitialized values in control flow or system calls.
    
- **Custom Allocators:** Implementing allocators with "guard pages" or "canaries" (magic values placed before/after allocations) to manually detect buffer overruns.
    

**Techniques**

- **Redzones:** Surrounding allocated memory with "poisoned" areas. Accessing these zones triggers an immediate trap.
    
- **Quarantine:** When memory is freed, it is not immediately returned to the OS or the allocator's free list. Instead, it is placed in a quarantine list to detect subsequent use-after-free attempts.
    
- **Stack Canaries:** Placing a random integer (canary) before the stack return pointer. If the canary is modified before the function returns, a stack buffer overflow has occurred.
    
- **RAII (Resource Acquisition Is Initialization):** Binding the lifecycle of heap-allocated resources to the scope of stack-allocated objects (e.g., C++ `std::unique_ptr`, `std::shared_ptr`) to eliminate manual memory management errors.
    

**Example**

The following C++ example demonstrates a subtle heap-buffer-overflow that might pass unnoticed during standard execution but is caught by instrumentation.

C++

```
#include <iostream>
#include <vector>

void process_data(int* data, size_t size) {
    // Intentional off-by-one error
    // Accessing index 'size' is out of bounds (0 to size-1 is valid)
    data[size] = 100; 
}

int main() {
    std::vector<int> vec(5, 0); // Vector of size 5
    process_data(vec.data(), vec.size());
    return 0;
}
```

To debug this using AddressSanitizer:

clang++ -O1 -g -fsanitize=address main.cpp -o main

**Output**

The instrumented binary produces a detailed report upon execution:

Plaintext

```
=================================================================
==12345==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x602000000024 at pc 0x00010896f6d0 bp 0x7ffee6a9b9a0 sp 0x7ffee6a9b998
WRITE of size 4 at 0x602000000024 thread T0
    #0 0x10896f6cf in process_data(int*, unsigned long) main.cpp:6
    #1 0x10896f78e in main main.cpp:11
    #2 0x7fff6c003cc8 in start (libdyld.dylib:x86_64+0x1cc8)

0x602000000024 is located 0 bytes to the right of 20-byte region [0x602000000010,0x602000000024)
allocated by thread T0 here:
    #0 0x1089ca6cd in operator new(unsigned long) (libclang_rt.asan_osx_dynamic.dylib:x86_64+0x506cd)
    #1 0x10896f74e in main main.cpp:10
    #2 0x7fff6c003cc8 in start (libdyld.dylib:x86_64+0x1cc8)

SUMMARY: AddressSanitizer: heap-buffer-overflow main.cpp:6 in process_data(int*, unsigned long)
Shadow bytes around the buggy address:
  0x1c0400000000: fa fa fd fd fa fa 00 00
=>0x1c0400000010: 00 00 00 00[fa]fa fa fa
  0x1c0400000020: fa fa fa fa fa fa fa fa
Legend:
  [fa] = Heap Left Redzone (partially addressable)
```

**Next Steps**

Implement Continuous Integration (CI) pipelines that run unit tests with sanitizers enabled (`-fsanitize=address,undefined`) to catch memory errors before they merge into the main branch.

---

