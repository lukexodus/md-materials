## Custom Types and Type Definitions


Go supports creating new types through type definitions and type aliases. Type definitions using the `type` keyword create distinct types with their own method sets, while type aliases create alternative names for existing types.

**Underlying Types and Method Sets** Custom types based on built-in types inherit the underlying type's operations but start with empty method sets. Methods can be defined on custom types to extend functionality while maintaining type safety. The underlying type determines which operations are valid, but method sets remain separate between different custom types even when they share the same underlying type.

**Type Conversions and Assignments** Converting between custom types and their underlying types requires explicit conversion even when they share identical representations. This design prevents accidental mixing of conceptually different types while allowing intentional conversions when needed.

**Named Types vs Unnamed Types** Named types created through type definitions can have methods associated with them, while unnamed types (like struct literals or slice types) cannot. This distinction affects how types participate in interface satisfaction and method resolution.

