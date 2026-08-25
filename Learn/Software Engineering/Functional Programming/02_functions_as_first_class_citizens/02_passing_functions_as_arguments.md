## Passing Functions as Arguments


Higher-order functions accept other functions as parameters, enabling powerful abstraction patterns. This allows you to inject behavior into existing functions, creating flexible and reusable code.

```javascript
// Higher-order function that accepts a function
const applyOperation = (arr, operation) => {
    return arr.map(operation);
};

const numbers = [1, 2, 3, 4, 5];

// Passing different functions as arguments
const doubled = applyOperation(numbers, x => x * 2);
// [2, 4, 6, 8, 10]

const squared = applyOperation(numbers, x => x * x);
// [1, 4, 9, 16, 25]
```

This pattern is ubiquitous in functional programming, appearing in standard library functions like `map`, `filter`, `reduce`, and `sort`. The ability to parameterize behavior enables separation of concerns and eliminates code duplication.

```scala
// Scala example
def processData[A, B](data: List[A], transformer: A => B): List[B] = {
    data.map(transformer)
}

val numbers = List(1, 2, 3, 4, 5)

// Different transformations
processData(numbers, x => x * 2)  // List(2, 4, 6, 8, 10)
processData(numbers, x => x.toString)  // List("1", "2", "3", "4", "5")
```

**Key Points:**

- Enables strategy pattern without classes
- Allows behavior injection and customization
- Core mechanism for abstraction in functional programming
- Eliminates need for template methods or inheritance hierarchies

**Example:**

```python
# Custom filter implementation
def custom_filter(predicate, items):
    result = []
    for item in items:
        if predicate(item):
            result.append(item)
    return result

numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# Passing different predicates
evens = custom_filter(lambda x: x % 2 == 0, numbers)
# [2, 4, 6, 8, 10]

greater_than_five = custom_filter(lambda x: x > 5, numbers)
# [6, 7, 8, 9, 10]
```

