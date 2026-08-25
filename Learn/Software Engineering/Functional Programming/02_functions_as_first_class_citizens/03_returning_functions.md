## Returning Functions


Functions can create and return other functions, enabling function factories, partial application, and closure-based encapsulation. This allows functions to generate specialized behavior based on parameters.

```javascript
// Function factory
const createMultiplier = (factor) => {
    return (number) => number * factor;
};

const double = createMultiplier(2);
const triple = createMultiplier(3);
const quadruple = createMultiplier(4);

console.log(double(5));      // 10
console.log(triple(5));      // 15
console.log(quadruple(5));   // 20
```

The returned function "closes over" variables from its parent scope, creating a closure. This enables state encapsulation without classes or mutable objects.

```python
# Python closure example
def create_counter(initial=0):
    count = [initial]  # Using list to allow modification in closure
    
    def increment():
        count[0] += 1
        return count[0]
    
    def decrement():
        count[0] -= 1
        return count[0]
    
    def get_value():
        return count[0]
    
    return increment, decrement, get_value

inc, dec, get = create_counter(10)
inc()  # 11
inc()  # 12
dec()  # 11
get()  # 11
```

**Key Points:**

- Enables function composition and currying
- Creates closures that encapsulate state
- Implements the factory pattern functionally
- Allows configuration-based function generation

**Example:**

```haskell
-- Haskell: returning functions
makeAdder :: Int -> (Int -> Int)
makeAdder x = \y -> x + y

-- Usage
add5 = makeAdder 5
add10 = makeAdder 10

add5 3   -- 8
add10 3  -- 13

-- More complex: function composition builder
composeWith :: (b -> c) -> (a -> b) -> (a -> c)
composeWith f g = \x -> f (g x)

doubleAndSquare = composeWith (\x -> x * x) (\x -> x * 2)
doubleAndSquare 5  -- 100 (5 * 2 = 10, then 10 * 10 = 100)
```

