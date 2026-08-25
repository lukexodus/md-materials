## Dead Code Elimination


Dead code elimination removes computations that do not affect program output. Dead code can arise from constant propagation, unreachable code, or programmer-introduced redundancies.

### Unreachable Code Elimination

Unreachable code elimination removes basic blocks that cannot be reached from program entry points. Control flow analysis identifies unreachable blocks by traversing the CFG from entry points and marking reachable blocks.

Conditional expressions that evaluate to constants during optimization can create unreachable code. After constant propagation determines a condition is always true or false, the unreachable branch can be eliminated.

### Dead Assignment Elimination

Dead assignment elimination removes assignments to variables that are never subsequently used. Live variable analysis identifies which variables are live (potentially used) at each program point, enabling removal of assignments to dead variables.

The analysis must consider:

- Variable uses in expressions and function calls
- Variable modifications that kill previous definitions
- Control flow paths that may bypass variable uses

### Aggressive Dead Code Elimination

Aggressive dead code elimination removes all computations that do not contribute to program output, including function calls without observable side effects. This optimization requires careful analysis of function behavior and potential side effects.

**Key points** for dead code elimination:

- Must preserve observable program behavior (I/O, function calls with side effects)
- Works synergistically with constant propagation
- May expose additional optimization opportunities
- Requires precise live variable analysis for correctness

