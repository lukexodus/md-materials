## Reducing function transformations


The core mechanism of transducers is transforming reducing functions. A reducing function has type `(accumulator, input) => accumulator`. A transducer wraps this function to intercept and modify the reduction process.

The transformation happens in layers. The innermost reducer knows how to accumulate results into the target structure. Each transducer layer wraps the next, adding its transformation logic. When an element flows through, it passes through each wrapper in sequence.

**Anatomy of a transformed reducer**:

```javascript
const mappingTransducer = f => reducer => {
  return (acc, input) => {
    const transformed = f(input);
    return reducer(acc, transformed);
  };
};
```

The outer function takes the transformation parameter (`f`). It returns a function that takes the next reducer in the chain. That function returns the actual reducing function that will process each element.

Filtering transforms reducers by conditionally calling the wrapped reducer:

```javascript
const filteringTransducer = predicate => reducer => {
  return (acc, input) => {
    return predicate(input) ? reducer(acc, input) : acc;
  };
};
```

When the predicate fails, the reducer returns the accumulator unchanged, effectively skipping that element without creating intermediate collections.

**Stateful transformations** maintain local state in the closure:

```javascript
const takeTransducer = n => reducer => {
  let taken = 0;
  return (acc, input) => {
    if (taken < n) {
      taken++;
      return reducer(acc, input);
    }
    return acc; // or use reduced() to signal early termination
  };
};
```

The `reduced` protocol signals early termination. When a transducer wraps its result in `reduced()`, the reduction stops immediately. This enables efficient short-circuiting for operations like `take`, `takeWhile`, or finding the first match.

Completion handling uses the arity-1 form of reducers. After all inputs are processed, calling `reducer(acc)` allows cleanup, flushing buffers, or final transformations. This is critical for transducers like `partition` or `chunk` that batch elements.

