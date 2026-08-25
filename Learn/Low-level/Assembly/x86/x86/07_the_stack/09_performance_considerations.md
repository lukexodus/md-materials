## Performance Considerations


Stack operations have performance implications that affect overall program efficiency.

### Stack Cache Behavior

The stack typically exhibits excellent cache locality because:

- Recent stack accesses remain in L1 data cache
- Sequential stack operations access adjacent cache lines
- Function call patterns create temporal locality

However, large stack frames can cause cache misses:

```asm
; Large frame may span multiple cache lines
huge_function:
    SUB RSP, 16384      ; 16KB frame
    ; Accessing [RSP] and [RSP+16000] may miss cache
```

[Inference] Keeping stack frames small (< 1KB) generally ensures good cache performance, though specific performance characteristics depend on cache sizes and processor microarchitecture.

### Stack Frame Overhead

Function call overhead includes:

- CALL instruction: pushes return address
- Prologue: establishes frame, saves registers
- Epilogue: restores registers, restores stack
- RET instruction: pops return address

Typical overhead: [Inference] 5-20 cycles for simple functions, depending on saved register count and processor.

**Optimization strategies**:

**Inline functions**: Eliminate call overhead entirely by inserting function body at call site.

**Leaf function optimization**: Omit frame pointer setup for functions that don't call others.

**Register allocation**: Minimize saved register count by careful register use.

**Tail call optimization**: Convert tail calls to jumps, eliminating frame overhead.

**Interprocedural optimization**: Optimize across function boundaries, potentially using custom calling conventions.

### Stack vs Heap Allocation

Stack allocation advantages:

- Extremely fast: single pointer adjustment
- Automatic deallocation: happens at scope exit
- Good cache locality: recent allocations nearby
- No fragmentation: linear allocation pattern

Stack allocation disadvantages:

- Limited size: typically MB, not GB
- LIFO discipline: can't free arbitrary items
- Scope-bound: can't return stack-allocated data
- Stack overflow: no graceful degradation

Heap allocation provides flexibility at performance cost: [Inference] heap allocation is typically 10-100× slower than stack allocation due to allocator overhead and TLB/cache effects.

### Function Call Optimization

Modern processors optimize call/return using:

**Return address prediction**: Branch predictors maintain a stack of return addresses, accurately predicting RET targets.

**Call/return pairing**: Processors recognize CALL/RET pairs and optimize the pattern.

**Return stack buffer (RSB)**: Hardware structure that tracks return addresses separately from branch prediction.

[Unverified] Mismatches between CALL/RET (such as using PUSH+JMP instead of CALL) can cause return mispredictions and performance degradation, though modern processors may adapt to these patterns.

