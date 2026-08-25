## Constant Folding and Propagation


Constant folding evaluates expressions with compile-time constant operands, replacing them with their computed values. This optimization reduces runtime computation and may enable additional optimizations by exposing more constant values.

### Compile-Time Evaluation

Simple constant folding handles arithmetic expressions with literal operands (5 + 3 → 8). More sophisticated folding can evaluate complex expressions involving multiple operations, function calls with constant arguments, and array references with constant indices.

Floating-point constant folding requires careful consideration of rounding modes and special values (infinity, NaN) to ensure runtime equivalence. [Unverified] Some compilers provide options to control aggressive floating-point optimizations that might affect numerical precision.

### Constant Propagation

Constant propagation tracks variable assignments to constant values, enabling folding of expressions that become constant through variable substitution. The analysis maintains constant/non-constant information for each variable at every program point.

Conditional constant propagation simultaneously performs constant propagation and dead code elimination. When a conditional expression evaluates to a constant, unreachable branches can be eliminated, potentially exposing additional constant propagation opportunities.

**Example** of constant propagation:

```
// Original code
x = 5;
y = x + 2;
if (y > 10) {
    // This branch is unreachable
    z = y * 2;
}

// After optimization
x = 5;
y = 7;
// if statement and unreachable branch eliminated
```

### Sparse Conditional Constant Propagation

Sparse conditional constant propagation combines SSA-based constant propagation with control flow analysis. The algorithm maintains work lists of SSA edges and control flow edges, processing only those elements that may contribute to constant propagation.

This approach achieves the combined effects of constant propagation, constant folding, and dead code elimination in a single pass with improved efficiency compared to separate optimization phases.

