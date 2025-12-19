## Memory Management: Freeing vs Setting to NULL

These are two distinct operations that serve different purposes in memory management:

### Freeing Memory

When you call `free()` (in C) or `delete` (in C++), you're:
- Returning the allocated memory block back to the heap/memory manager
- Making that memory available for future allocations
- The pointer's value (the address) remains unchanged
- The memory at that address is now invalid to access

```c
int* ptr = malloc(sizeof(int) * 10);
free(ptr);
// ptr still contains the address, but accessing it is undefined behavior
```

### Setting to NULL

When you set a pointer to `NULL`, you're:
- Changing the pointer variable to hold the address `0` (or `nullptr` in C++)
- The pointer no longer points to any memory location
- This does NOT free any memory that was allocated
- Dereferencing a NULL pointer typically causes a predictable crash

```c
ptr = NULL;
// ptr now holds 0, doesn't point anywhere
```

### Why Both Matter

The recommended practice is to do both:

```c
int* ptr = malloc(sizeof(int) * 10);
// ... use ptr ...
free(ptr);     // Return memory to system
ptr = NULL;    // Clear the pointer
```

**Benefits of this pattern:**
- `free()` releases the memory so it's not leaked
- Setting to `NULL` prevents use-after-free bugs (accessing freed memory)
- A NULL pointer dereference fails predictably rather than causing corruption
- You can safely check `if (ptr != NULL)` before using it

**What happens if you only do one:**
- Only `free()`: You have a "dangling pointer" pointing to freed memory (undefined behavior if accessed)
- Only `= NULL`: Memory leak—the allocated memory is never returned and can't be reused

---

