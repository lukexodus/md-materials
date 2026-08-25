## Functions as Values


In functional programming, functions are treated as first-class citizens, meaning they have the same status as any other value like numbers, strings, or objects. A function can be assigned to a variable, just as you would assign a primitive value.

```javascript
// Assigning functions to variables
const add = (a, b) => a + b;
const multiply = (x, y) => x * y;
const greet = name => `Hello, ${name}!`;

// Using them like any other value
const result = add(5, 3);  // 8
const message = greet("Alice");  // "Hello, Alice!"
```

This fundamental property enables treating functions as data, allowing you to manipulate, compose, and transform them programmatically. Functions can be elements in collections, values in maps, or properties of objects.

```python
# Python example
def square(x):
    return x * x

def cube(x):
    return x * x * x

# Functions as dictionary values
operations = {
    'square': square,
    'cube': cube
}

result = operations['square'](5)  # 25
```

**Key Points:**

- Functions are values that can be assigned to variables
- No special syntax required to reference a function as a value
- Enables dynamic function selection and manipulation
- Forms the foundation for higher-order functions

**Example:**

```haskell
-- Haskell
double :: Int -> Int
double x = x * 2

triple :: Int -> Int
triple x = x * 3

-- Assigning to variables
let f = double
let g = triple

-- Using them
f 5  -- 10
g 5  -- 15
```

