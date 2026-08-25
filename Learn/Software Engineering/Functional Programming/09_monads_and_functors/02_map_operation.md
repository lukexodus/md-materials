## Map Operation


The map operation is the fundamental operation of functors, transforming values inside a context by applying a function to each element while maintaining the structure. It represents the ability to lift ordinary functions into the functor context.

The type signature generalizes as: `(a -> b) -> f a -> f b`, where `f` is the functor type constructor. This signature shows that map takes a function from `a` to `b` and produces a function from `f a` to `f b`.

**Key Points:**

- Map is structure-preserving: the shape of the container remains unchanged
- Only the values are transformed, never the context itself
- Map can be chained to compose multiple transformations
- Different functors implement map according to their specific structure
- Map is lazy in many implementations, enabling efficient composition

**Example:**

```javascript
// Array map
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.map(x => x * 2);
const processed = numbers
    .map(x => x * 2)
    .map(x => x + 1)
    .map(x => x.toString());

// Option/Maybe map
class Maybe {
    constructor(value) {
        this.value = value;
    }
    
    static of(value) {
        return new Maybe(value);
    }
    
    map(fn) {
        return this.value === null || this.value === undefined
            ? Maybe.of(null)
            : Maybe.of(fn(this.value));
    }
}

const result = Maybe.of(5)
    .map(x => x * 2)
    .map(x => x + 3);

// Function map (composition)
const addOne = x => x + 1;
const double = x => x * 2;
const composed = x => double(addOne(x));
// Equivalent to: const composed = addOne.map(double);
```

**Output:**

```javascript
[2, 4, 6, 8, 10]
["3", "5", "7", "9", "11"]
Maybe { value: 13 }
```

Map operations enable declarative data transformation pipelines that are easier to reason about than imperative loops.

