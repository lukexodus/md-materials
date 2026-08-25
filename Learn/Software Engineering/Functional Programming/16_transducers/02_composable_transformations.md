## Composable transformations


Composability emerges from the mathematical property that transducers form under function composition. When you compose two transducers, you get another transducer. This closure property enables building complex transformations from simple, reusable pieces.

The composition order follows right-to-left evaluation, mirroring standard function composition. If you compose `transduce(xf1, xf2, xf3)`, the data flows through `xf3` first, then `xf2`, then `xf1`. This matches the intuition that `(f ∘ g)(x) = f(g(x))`.

**Key advantage**: Compose first, execute later. You can build transformation pipelines as pure data descriptions, then apply them to any reducible source. The same composed transducer can process arrays with `reduce`, async streams with reactive operators, or channels in concurrent systems.

**Example of composition**:

```javascript
const xform = compose(
  map(x => x * 2),
  filter(x => x > 10),
  take(5)
);

// Use with arrays
const result1 = transduce(xform, arrayReducer, [], input);

// Use with streams
const result2 = transduce(xform, streamReducer, stream, input);
```

Composition preserves the transducer laws: identity and associativity. Composing with an identity transducer returns the original transducer. Composing `(a ∘ b) ∘ c` equals `a ∘ (b ∘ c)`. These properties guarantee predictable behavior when combining transformations.

Stateful transducers (like `take`, `drop`, `dedupe`) maintain internal state across reductions while still composing correctly. The state is encapsulated within the transducer's closure, isolated from other transformations in the pipeline.

