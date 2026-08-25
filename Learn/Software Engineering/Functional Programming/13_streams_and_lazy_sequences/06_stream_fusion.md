## Stream Fusion


Stream fusion eliminates intermediate data structures created during chained stream operations by combining multiple operations into a single pass. Instead of materializing results between operations, the compiler or runtime merges transformations into one iteration loop.

The transformation process:

- **Deforestation**: Removes intermediate list/collection constructions
- **Loop fusion**: Combines multiple traversals into one
- **Inlining**: Merges operation definitions into a unified computation

Two primary fusion strategies exist:

**Foldr/Build fusion**: Represents producers as build functions and consumers as foldr, enabling algebraic rewriting rules to eliminate intermediates.

```haskell
-- Without fusion: creates intermediate list
map f (map g xs) = map f [g x | x <- xs]

-- With fusion: single pass
map (f . g) xs
```

**Stream fusion**: Represents operations as state machines that produce elements on demand, allowing the compiler to merge state transitions.

The fusion framework converts high-level operations into a core representation:

- Streams become state transition functions
- Map, filter, fold become state machine transformations
- The compiler recognizes patterns and applies rewrite rules

**Benefits:**

- Eliminates allocation and garbage collection of intermediate structures
- Reduces memory footprint significantly
- Improves cache locality by processing elements immediately
- Maintains abstraction without performance penalty

**Limitations:**

Stream fusion cannot always fire when:

- Operations are separated across function boundaries without inlining
- Recursive patterns don't match fusion rules
- Side effects or I/O interrupt the pipeline
- Dynamic dispatch prevents static analysis

Compiler pragmas or annotations may force inlining to enable fusion. Some languages provide fusion automatically, while others require explicit use of fusion-aware libraries.

