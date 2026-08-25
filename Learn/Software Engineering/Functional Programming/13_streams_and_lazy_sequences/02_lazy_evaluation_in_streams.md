## Lazy Evaluation in Streams


Lazy evaluation defers computation until results are absolutely required, creating a fundamental efficiency mechanism in stream operations. When intermediate operations are applied to streams, they don't execute immediately—instead, they record transformation intent, building a computation pipeline that executes only when a terminal operation demands values.

The evaluation strategy follows a just-in-time principle. Transformations like `map`, `filter`, and `flatMap` return new stream objects that encapsulate both the previous stream and the transformation function. No element processing occurs at this stage. Only when terminal operations like `reduce`, `collect`, or `forEach` execute does the runtime traverse the pipeline backward, pulling elements through each transformation.

This lazy behavior enables several critical optimizations. Short-circuit operations can terminate processing early—finding the first element matching a predicate doesn't require examining the entire stream. Loop fusion combines multiple transformations into a single pass, eliminating intermediate data structures. A chain like `stream.map(f).filter(g).map(h)` executes as a single traversal applying all three operations per element rather than three separate passes.

Infinite streams demonstrate the power of lazy evaluation. You can define unbounded sequences like natural numbers or fibonacci sequences, then extract finite subsets using operations like `take` or `takeWhile`. The stream generates only the requested elements, never attempting to materialize the entire infinite sequence.

State management in lazy streams requires careful consideration. Stateless operations like `map` and `filter` process elements independently, making them ideal for lazy evaluation. Stateful operations like `sorted` or `distinct` require examining relationships between elements, potentially forcing partial or full evaluation. Understanding these distinctions helps design efficient stream pipelines.

The lazy model also impacts error handling and side effects. Exceptions within transformations don't occur until evaluation. Side effects in intermediate operations execute unpredictably since the runtime controls evaluation timing. Pure transformations without side effects align naturally with lazy evaluation, maintaining referential transparency.

