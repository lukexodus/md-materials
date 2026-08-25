## Stream Operations


Stream operations divide into two categories: intermediate operations that transform streams, and terminal operations that produce concrete results. This division establishes the boundary between pipeline construction and execution.

**Intermediate Operations**

Intermediate operations transform streams into new streams, remaining unevaluated until a terminal operation triggers computation. These operations are lazy by design and can be chained indefinitely without processing data.

Mapping operations transform each element through a function. `map` applies one-to-one transformations, producing a stream of the same length with transformed elements. `flatMap` handles one-to-many transformations, applying a function that returns a stream per element, then flattening the nested streams into a single sequence. This proves essential for operations that generate multiple results per input.

Filtering operations select subsets based on predicates. `filter` retains elements satisfying a boolean condition. `takeWhile` consumes elements until a predicate fails, useful for processing sorted streams or bounded segments. `dropWhile` discards elements until a predicate fails, then yields the remainder.

Limiting operations control stream size. `take` (or `limit`) restricts output to a specified count. `drop` (or `skip`) discards an initial segment. These operations enable processing stream prefixes without evaluating the entire sequence.

Transformation operations modify stream structure. `distinct` eliminates duplicate elements, typically requiring state tracking. `sorted` orders elements, demanding full or partial evaluation depending on the sorting algorithm. `reverse` inverts element order, generally requiring complete materialization.

**Terminal Operations**

Terminal operations trigger pipeline execution and produce concrete results, closing the stream for further use.

Reduction operations aggregate streams into single values. `reduce` (or `fold`) applies a binary operation cumulatively, often with an initial accumulator value. Common reductions include sum, product, min, max, and custom aggregations. Left-fold processes elements left-to-right; right-fold reverses direction, though right-folds may require full materialization.

Collection operations materialize streams into data structures. `collect` (or `toList`, `toArray`) builds collections from stream elements. Grouping operations partition streams into maps based on key functions. These operations necessarily force full evaluation.

Searching operations find elements matching criteria. `find` returns the first matching element, short-circuiting on success. `exists` checks if any element satisfies a predicate. `forall` verifies all elements meet a condition. These operations can terminate early, leveraging laziness.

Iteration operations execute side effects. `forEach` applies a procedure to each element, useful for output or mutations. Since streams emphasize immutability, forEach typically represents the pipeline boundary where functional processing yields to imperative actions.

Counting operations determine stream size. `count` tallies elements, potentially optimized for certain sources but generally requiring full traversal.

