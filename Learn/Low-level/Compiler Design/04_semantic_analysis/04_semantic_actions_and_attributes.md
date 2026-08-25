## Semantic Actions and Attributes


Semantic actions embed computation within grammar productions, enabling semantic analysis to proceed incrementally during parsing rather than requiring separate tree traversal phases. These actions compute and propagate semantic information using attribute systems that associate values with grammar symbols and production rules.

Synthesized attributes flow information upward from leaves to roots in parse trees, computing values based on children's attribute values and production-specific rules. Inherited attributes flow information downward from roots toward leaves, propagating context information that affects semantic interpretation of nested constructs. S-attributed grammars use only synthesized attributes and can be evaluated during bottom-up parsing, while L-attributed grammars add inherited attributes that flow from left to right within productions.

Attribute evaluation strategies determine when and how attribute values are computed during parsing or tree traversal. One-pass evaluation computes attributes during parsing without requiring additional tree traversals, but restricts the types of attributes that can be computed to those compatible with parsing order. Multi-pass evaluation allows arbitrary attribute dependencies at the cost of additional tree traversal overhead.

Circular attribute dependencies occur when attribute evaluation requires values that transitively depend on the attribute being computed, creating evaluation deadlocks that must be detected and resolved. Fixed-point iteration can resolve some circular dependencies by repeatedly evaluating attributes until reaching stable values, but this approach may not converge for all attribute systems.

Attribute grammar systems provide formal frameworks for specifying semantic actions through attribute equations that define how attribute values are computed from other attributes and terminal symbols. These systems enable automatic generation of evaluators that correctly handle attribute dependencies while optimizing evaluation order for efficiency.

Higher-order attribute grammars extend basic attribute systems by allowing attributes to contain tree fragments or functions, enabling more sophisticated transformations and analysis. Reference attribute grammars support attributes that contain references to other tree nodes, facilitating complex analysis that requires non-local information access.

