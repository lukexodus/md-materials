## Transducer composition


Composition creates transformation pipelines by stacking transducer functions. The composition utility threads reducers through each transducer from right to left, building a single composite reducing function.

**Implementation pattern**:

```javascript
const compose = (...transducers) => {
  return transducers.reduce((acc, xf) => {
    return reducer => acc(xf(reducer));
  });
};
```

This creates a function that takes a base reducer and applies each transducer in reverse order. The rightmost transducer receives the base reducer first, its output becomes input to the next transducer, and so on.

**Execution flow**: During reduction, data flows left-to-right through the transformations. An element enters the leftmost transducer's step function, which may transform and pass it to the next, continuing until it reaches the base reducer or gets filtered out.

Composed transducers maintain the single-pass property. Regardless of how many transformations you compose, the data is only traversed once. Each element visits each transformation layer exactly once before being accumulated.

**Performance characteristics**: Composition is O(n) where n is the number of transducers. The composed function is built once at composition time. Runtime cost per element is also O(n) - each element passes through n transformation layers. However, this is vastly superior to chained collection operations which would be O(n*m) where m is the collection size, creating m intermediate collections.

Transducer composition respects early termination across all layers. When an inner transducer signals `reduced`, the signal propagates outward through all wrapping layers, halting the entire reduction immediately.

**[Inference]** The composition strategy enables algebraic reasoning about transformations. You can prove properties of composed pipelines by proving properties of individual transducers, then applying composition laws. This makes complex transformation logic verifiable and maintainable.

Type safety in statically-typed languages requires careful handling. The reducer type changes as it passes through each transducer layer. Type systems like TypeScript require variance annotations or existential types to express this correctly, though the runtime behavior remains straightforward.

