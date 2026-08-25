## Embedded Structs and Composition


Go uses composition through embedded structs rather than traditional inheritance. Embedding promotes fields and methods from the embedded type to the embedding type, creating a "has-a" relationship with "is-a" semantics.

**Field and Method Promotion** When a struct embeds another type, the embedded type's exported fields and methods become directly accessible on the embedding struct. This promotion follows specific rules: closer embedded fields shadow more distant ones, and conflicts at the same level must be resolved explicitly.

**Embedding Interfaces** Interfaces can be embedded within other interfaces, combining method sets to create more comprehensive interface definitions. A type satisfies an interface containing embedded interfaces if it implements all methods from all embedded interfaces.

**Anonymous Field Access** Embedded types create anonymous fields accessible by their type name. This allows both promoted access (`outer.Method()`) and explicit access (`outer.EmbeddedType.Method()`), providing flexibility in how embedded functionality is utilized.

