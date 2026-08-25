## Local Optimization Techniques


Local optimizations operate within basic blocks—maximal sequences of consecutive statements with single entry and exit points. These optimizations require minimal analysis overhead while providing significant performance improvements for common code patterns.

### Basic Block Optimizations

Algebraic simplifications transform expressions using mathematical identities. Common transformations include strength reduction (replacing multiplication by powers of two with shifts), identity elimination (x + 0 → x, x * 1 → x), and constant folding (2 + 3 → 5).

Redundant expression elimination identifies repeated computations within basic blocks. When the same expression appears multiple times without intervening modifications to its operands, the compiler can compute the value once and reuse the result.

**Example** of local optimization:

```
// Original code
x = a + b;
y = a + b + c;
z = a + b + d;

// After optimization
temp = a + b;
x = temp;
y = temp + c;
z = temp + d;
```

Copy propagation replaces variable uses with their definitions when possible. If a variable is assigned the value of another variable (x = y), subsequent uses of x can be replaced with y, provided neither variable is modified between the assignment and use.

### Peephole Optimization

Peephole optimization examines small instruction windows to identify improvement opportunities. This technique operates on generated code, replacing instruction sequences with more efficient equivalents.

Common peephole optimizations include:

- Eliminating redundant loads and stores
- Combining arithmetic operations
- Removing unnecessary jumps
- Optimizing instruction sequences for specific architectures

Machine-specific peephole optimizations can exploit processor features like addressing modes, instruction parallelism, and specialized operations. [Inference] These optimizations typically show measurable performance improvements with minimal implementation complexity.

