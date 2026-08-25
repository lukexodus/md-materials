## Chaining Decorators


Multiple decorators can be stacked on a single function, applying transformations in a specific order. Decorators are applied bottom-up (closest to the function first), but execution flows top-down.

### Application Order

```python
@decorator_a
@decorator_b
@decorator_c
def target():
    pass

# Equivalent to:
# target = decorator_a(decorator_b(decorator_c(target)))
```

The innermost decorator (`decorator_c`) wraps the original function first, then `decorator_b` wraps that result, and finally `decorator_a` wraps everything.

### Execution Flow

When the decorated function is called, execution flows from outermost to innermost decorator:

```python
def uppercase(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        result = func(*args, **kwargs)
        return result.upper()
    return wrapper

def exclaim(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        result = func(*args, **kwargs)
        return f"{result}!"
    return wrapper

@exclaim      # Applied second, executes first
@uppercase    # Applied first, executes second
def greet(name):
    return f"hello {name}"

print(greet("world"))
```

**Output:**

```
HELLO WORLD!
```

The flow: `greet("world")` → `uppercase` converts to "HELLO WORLD" → `exclaim` adds "!" → "HELLO WORLD!"

### Order Matters

Different orders produce different results:

```python
@uppercase
@exclaim
def greet_reversed(name):
    return f"hello {name}"

print(greet_reversed("world"))
```

**Output:**

```
HELLO WORLD!
```

Now: `greet_reversed("world")` → `exclaim` adds "!" to "hello world!" → `uppercase` converts all → "HELLO WORLD!"

The exclamation point gets uppercased in this order.

### Practical Chaining Example

Combining authentication, logging, and caching:

```python
def authenticate(func):
    @wraps(func)
    def wrapper(user, *args, **kwargs):
        if not user.get('authenticated'):
            raise PermissionError("User not authenticated")
        return func(user, *args, **kwargs)
    return wrapper

def log_access(func):
    @wraps(func)
    def wrapper(user, *args, **kwargs):
        print(f"User {user['name']} accessed {func.__name__}")
        return func(user, *args, **kwargs)
    return wrapper

def cache_result(func):
    cache = {}
    @wraps(func)
    def wrapper(*args, **kwargs):
        key = (args, tuple(kwargs.items()))
        if key not in cache:
            cache[key] = func(*args, **kwargs)
        return cache[key]
    return wrapper

@cache_result      # Outermost: caches final result
@log_access        # Middle: logs after auth, before execution
@authenticate      # Innermost: validates first
def get_sensitive_data(user, resource_id):
    return f"Data for resource {resource_id}"

user = {'name': 'Alice', 'authenticated': True}
print(get_sensitive_data(user, 123))
```

**Output:**

```
User Alice accessed get_sensitive_data
Data for resource 123
```

Execution sequence:

1. `cache_result` checks cache (miss on first call)
2. `log_access` logs the access
3. `authenticate` verifies credentials
4. Original function executes
5. Result propagates back through decorators
6. `cache_result` stores result

### Debugging Chains

Understanding which decorator is executing:

```python
def debug_decorator(name):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            print(f"[{name}] Before")
            result = func(*args, **kwargs)
            print(f"[{name}] After: {result}")
            return result
        return wrapper
    return decorator

@debug_decorator("Outer")
@debug_decorator("Middle")
@debug_decorator("Inner")
def compute(x):
    print(f"[Original] Computing {x}")
    return x * 2

compute(5)
```

**Output:**

```
[Outer] Before
[Middle] Before
[Inner] Before
[Original] Computing 5
[Inner] After: 10
[Middle] After: 10
[Outer] After: 10
```

### Composition Considerations

When chaining decorators:

- **Order determines behavior** - authentication before logging vs. logging before authentication
- **Performance implications** - caching should typically be outermost to avoid redundant inner decorator execution
- **Error handling** - decorators that raise exceptions affect downstream execution
- **Side effects** - decorators with side effects (I/O, state modification) may interact unexpectedly

**Key Points:**

- Decorators apply bottom-up but execute top-down
- Each decorator wraps the result of the decorator below it
- Order significantly impacts final behavior
- Use descriptive decorator names to maintain readability in chains
- Consider execution order when decorators have dependencies or side effects

