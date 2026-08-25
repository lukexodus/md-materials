## Generator Pipelines


Generator pipelines represent lazy sequences as functions that yield elements on demand rather than computing all values upfront. Each stage in the pipeline is a generator that consumes from its predecessor and produces for its successor, creating a pull-based evaluation model.

The architecture consists of:

- **Producer**: Initial generator creates base sequence
- **Transformers**: Intermediate generators modify elements
- **Consumer**: Terminal operation that materializes or reduces results

Generators maintain internal state across yield points:

```python
def integers_from(n):
    while True:
        yield n
        n += 1

def filter_pred(gen, pred):
    for item in gen:
        if pred(item):
            yield item

def take(gen, n):
    for i, item in enumerate(gen):
        if i >= n:
            break
        yield item

# Pipeline composition
evens = filter_pred(integers_from(0), lambda x: x % 2 == 0)
result = take(evens, 10)  # Only computes what's needed
```

**Execution characteristics:**

- **Lazy evaluation**: Elements computed only when requested
- **Single-pass**: Each element flows through the entire pipeline before the next is produced
- **Minimal memory**: No intermediate collections stored
- **Composability**: Generators chain naturally through function composition

Control flow is inverted—consumers pull data from producers rather than producers pushing to consumers. This enables:

- Processing infinite sequences by consuming finite prefixes
- Short-circuiting when terminal conditions are met
- Resource management where production is expensive

State management in generators requires capturing:

- Current position in sequence
- Predicate or transformation closures
- Buffered elements when look-ahead is needed

**Coroutine model**: Generators are specialized coroutines that yield control back to the caller, preserving local state until resumed. The yield mechanism creates suspension points where execution can pause and resume.

Pipeline termination occurs when:

- Generator exhausts its source
- Consumer completes its requirement
- Exception propagates through the pipeline

Generators compose both horizontally (chaining transformations) and vertically (nested generation), enabling complex data flows with minimal overhead.

