## Common Pitfalls


**File Descriptor Leaks:** Forgetting to close file descriptors leads to resource exhaustion. Always close FDs in error paths too.

**Race Conditions:** Multiple threads accessing shared data without synchronization causes undefined behavior. Always protect shared data with mutexes or atomic operations.

**Deadlocks:** Circular waiting for resources causes deadlock. Avoid by:

- Always acquiring locks in the same order
- Using try-lock with timeout
- Lock hierarchies

**Buffer Overflows:** Writing beyond allocated memory corrupts data and creates security vulnerabilities. Always validate sizes and use bounds checking.

**Memory Leaks:** Allocating memory without freeing it causes memory exhaustion. Track all allocations and ensure corresponding deallocations.

**Dangling Pointers:** Using freed memory causes crashes or corruption. Set pointers to NULL after freeing.

**Stack Overflow:** Excessive recursion or large local arrays exhaust stack space. Be mindful of stack usage, especially in embedded systems or with limited stack sizes.

**Signal Safety:** Many functions are not async-signal-safe. Only use safe functions in signal handlers (write, _exit, etc.).

**Zombie Processes:** Child processes become zombies if parent doesn't call wait(). Always reap child processes.

**Permission Issues:** File operations fail if process lacks permissions. Check return values and handle EACCES/EPERM errors.

**Errno Handling:** System calls return error codes, but detailed error information is in errno. Check errno for specific error conditions.

**TOCTOU (Time-of-Check-Time-of-Use):** Checking file existence then opening it creates race condition. Use atomic open with O_EXCL when appropriate.

**Interrupted System Calls:** Signals can interrupt syscalls (EINTR). Restart interrupted syscalls or handle appropriately.

**Key Points:**

- File handling uses system calls (open, read, write, close) with file descriptors
- Processes are independent execution units; threads share memory within a process
- fork() creates new processes, clone() creates threads
- Synchronization primitives prevent race conditions in concurrent programs
- Memory management involves allocating (brk, mmap) and protecting memory regions
- Understanding virtual memory, stack, heap, and memory protection is essential
- Performance depends on minimizing syscalls, maintaining cache locality, and proper resource management
- Always validate inputs, check return values, and handle errors appropriately

---

