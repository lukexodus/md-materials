## Recursive Functions


Recursive functions call themselves, either directly or indirectly. Each recursive call creates a new stack frame, allowing independent local variables and return addresses.

### Basic Recursive Function Structure

Recursive functions must have:

1. Base case(s) - conditions that terminate recursion
2. Recursive case(s) - conditions that make recursive calls
3. Proper stack frame management for each call

**Example (factorial):**

```nasm
; int factorial(int n)
; Returns n! = n × (n-1) × (n-2) × ... × 1

factorial:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]     ; Get parameter n
    
    ; Base case: if n <= 1, return 1
    cmp eax, 1
    jg recursive_case
    mov eax, 1           ; Return 1
    jmp done
    
recursive_case:
    ; Recursive case: return n * factorial(n-1)
    push eax             ; Save n
    dec eax              ; n - 1
    push eax             ; Pass n-1 as parameter
    call factorial       ; Recursive call
    add esp, 4           ; Clean up parameter
    pop ecx              ; Restore n into ECX
    imul eax, ecx        ; n * factorial(n-1)
    
done:
    pop ebp
    ret
```

### Stack Growth in Recursion

Each recursive call pushes a new stack frame. Deep recursion can cause stack overflow if:

- Recursion depth is too large
- Local variables consume significant space
- Stack size limit is reached

**Example (stack frames for factorial(3)):**

```
Initial: factorial(3)
+------------------+
| n = 3            |  Frame 1
| Return to main   |
+------------------+
After first recursive call: factorial(2)
+------------------+
| n = 2            |  Frame 2
| Return to Frame 1|
+------------------+
| n = 3            |  Frame 1
| Return to main   |
+------------------+
After second recursive call: factorial(1)
+------------------+
| n = 1            |  Frame 3 (base case)
| Return to Frame 2|
+------------------+
| n = 2            |  Frame 2
| Return to Frame 1|
+------------------+
| n = 3            |  Frame 1
| Return to main   |
+------------------+
```

### Fibonacci Sequence (Multiple Recursive Calls)

Functions may make multiple recursive calls within a single invocation.

**Example:**

```nasm
; int fibonacci(int n)
; Returns the nth Fibonacci number
; fib(n) = fib(n-1) + fib(n-2)

fibonacci:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]     ; Get n
    
    ; Base cases: if n <= 1, return n
    cmp eax, 1
    jg recursive_case
    ; n is 0 or 1, return n
    pop ebp
    ret
    
recursive_case:
    push ebx             ; Save EBX (callee-saved)
    mov ebx, eax         ; Save n
    
    ; Calculate fib(n-1)
    dec eax              ; n - 1
    push eax
    call fibonacci
    add esp, 4
    push eax             ; Save fib(n-1) result
    
    ; Calculate fib(n-2)
    mov eax, ebx
    sub eax, 2           ; n - 2
    push eax
    call fibonacci
    add esp, 4
    
    ; Add fib(n-1) + fib(n-2)
    pop ecx              ; fib(n-1)
    add eax, ecx         ; eax = fib(n-1) + fib(n-2)
    
    pop ebx              ; Restore EBX
    pop ebp
    ret
```

### Tail Recursion

Tail recursion occurs when the recursive call is the last operation in the function. Tail-recursive functions can be optimized to avoid stack growth.

**Example (tail-recursive factorial):**

```nasm
; int factorial_tail(int n, int accumulator)
; Helper function for tail recursion

factorial_tail:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]         ; Get n
    mov ecx, [ebp+12]        ; Get accumulator
    
    ; Base case: if n <= 1, return accumulator
    cmp eax, 1
    jg recursive_case
    mov eax, ecx
    pop ebp
    ret
    
recursive_case:
    ; Tail recursive call: factorial_tail(n-1, n * accumulator)
    imul ecx, eax            ; n * accumulator
    dec eax                  ; n - 1
    mov [ebp+8], eax         ; Update n parameter
    mov [ebp+12], ecx        ; Update accumulator parameter
    pop ebp
    jmp factorial_tail       ; Tail call optimization with jmp instead of call
```

**Key Points:** Tail recursion can be optimized by replacing `call` with `jmp`, reusing the same stack frame instead of creating new ones.

### Mutual Recursion

Functions can call each other recursively.

**Example (even/odd test):**

```nasm
; bool is_even(int n)
is_even:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]
    
    ; Base case: 0 is even
    test eax, eax
    jnz not_zero
    mov eax, 1               ; Return true
    pop ebp
    ret
    
not_zero:
    ; Recursive case: even(n) = odd(n-1)
    dec eax
    push eax
    call is_odd
    add esp, 4
    pop ebp
    ret

; bool is_odd(int n)
is_odd:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]
    
    ; Base case: 0 is not odd
    test eax, eax
    jnz not_zero_odd
    xor eax, eax             ; Return false
    pop ebp
    ret
    
not_zero_odd:
    ; Recursive case: odd(n) = even(n-1)
    dec eax
    push eax
    call is_even
    add esp, 4
    pop ebp
    ret
```

### Stack Overflow Prevention

Deep recursion can exhaust stack space. Mitigation strategies include:

1. **Converting to iteration** - Eliminate recursion entirely
2. **Tail call optimization** - Reuse stack frames for tail-recursive calls
3. **Increasing stack size** - Allocate larger stack (system/linker dependent)
4. **Depth limiting** - Check recursion depth and fail gracefully

**Example (depth-limited recursion):**

```nasm
; int factorial_limited(int n, int depth)
factorial_limited:
    push ebp
    mov ebp, esp
    
    ; Check depth limit
    mov ecx, [ebp+12]        ; Get current depth
    cmp ecx, 1000            ; Maximum depth
    jl depth_ok
    mov eax, -1              ; Return error code
    pop ebp
    ret
    
depth_ok:
    mov eax, [ebp+8]         ; Get n
    cmp eax, 1
    jg recursive_case
    mov eax, 1
    pop ebp
    ret
    
recursive_case:
    push eax
    dec eax
    push eax                 ; n - 1
    mov eax, [ebp+12]
    inc eax
    push eax                 ; depth + 1
    call factorial_limited
    add esp, 8
    pop ecx
    imul eax, ecx
    pop ebp
    ret
```

### Recursion vs Iteration

Many recursive algorithms can be converted to iterative ones, which avoid stack overhead.

**Example (iterative factorial):**

```nasm
; int factorial_iterative(int n)
factorial_iterative:
    push ebp
    mov ebp, esp
    mov ecx, [ebp+8]         ; Get n
    mov eax, 1               ; result = 1
    
loop_start:
    cmp ecx, 1
    jle done
    imul eax, ecx            ; result *= n
    dec ecx                  ; n--
    jmp loop_start
    
done:
    pop ebp
    ret
```

**Comparison:**

- Recursive: More intuitive for some algorithms, cleaner code structure, but higher memory overhead
- Iterative: Better performance, no stack overflow risk, but may be more complex to implement for certain algorithms

### Advanced: Trampolining

Trampolining is a technique to implement recursion without growing the stack by returning function pointers instead of making direct calls.

**Example concept:**

```nasm
; Returns a function pointer and arguments instead of making recursive call
; Caller repeatedly invokes returned functions until base case
factorial_trampoline:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]
    
    cmp eax, 1
    jg return_continuation
    ; Base case: return value 1 with null continuation
    mov eax, 1
    xor ecx, ecx             ; null pointer
    pop ebp
    ret
    
return_continuation:
    ; Return function pointer and argument
    dec eax
    mov ecx, factorial_trampoline  ; Return function to call
    ; Caller will invoke ECX with EAX as argument
    pop ebp
    ret
```

