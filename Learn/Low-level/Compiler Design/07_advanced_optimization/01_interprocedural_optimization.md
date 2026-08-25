## Interprocedural Optimization


Interprocedural optimization extends analysis and transformation beyond individual function boundaries to consider entire program call graphs, enabling optimizations that would be impossible with purely local analysis. This approach requires sophisticated analysis frameworks that can model control flow, data flow, and side effects across function call boundaries while handling complexities like indirect calls, recursion, and separate compilation.

Call graph construction forms the foundation of interprocedural analysis, building representations that capture all possible calling relationships within the program. Static call graph construction analyzes function pointer assignments and virtual method dispatch to identify potential call targets, though [Inference] dynamic dispatch and function pointers may introduce uncertainty that requires conservative approximations. Class hierarchy analysis refines virtual call targets by examining inheritance relationships and eliminating impossible dispatch targets based on type information.

Whole-program analysis enables the most aggressive interprocedural optimizations by examining complete program call graphs without external dependencies. This approach supports dead function elimination, where unused functions are removed entirely from the final executable. Global constant propagation can track constant values across function boundaries, enabling optimizations that depend on knowing specific parameter values at call sites.

Separate compilation constraints limit interprocedural optimization scope since individual compilation units cannot access complete program information. Link-time optimization addresses these limitations by performing interprocedural analysis and transformation during the linking phase when multiple compilation units are combined. This approach requires intermediate representations that preserve sufficient information for cross-module optimization while maintaining separate compilation benefits.

Function inlining represents one of the most impactful interprocedural optimizations, replacing function calls with copies of the called function's body. Inlining eliminates call overhead while exposing additional optimization opportunities within the expanded code. However, aggressive inlining can increase code size substantially, potentially degrading cache performance and causing instruction cache misses that offset the benefits of eliminated call overhead.

Inlining heuristics must balance the performance benefits of eliminated calls against the costs of increased code size and compilation time. Small functions with simple control flow are generally good inlining candidates, while large functions with complex control structures may not provide sufficient benefit to justify their expansion. Call frequency information from profiling can guide inlining decisions by prioritizing frequently executed call sites.

Interprocedural constant propagation tracks constant values across function boundaries, enabling optimizations in called functions based on knowledge of specific argument values. This analysis requires sophisticated value propagation algorithms that can handle conditional constants (values that are constant along some execution paths but not others) and context-sensitive analysis that distinguishes between different call sites to the same function.

Global code motion moves computations across function boundaries to reduce redundant calculations or improve instruction scheduling. Loop-invariant code motion can hoist computations out of loops even when the computations span multiple functions. However, such transformations must carefully consider side effects and exception handling to maintain program correctness.

