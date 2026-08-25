## Parametrized Decorators


Parametrized decorators are higher-order functions that accept arguments to customize their behavior, then return a decorator that can be applied to a target function. This adds an additional layer of function nesting.

### Three-Level Structure

A parametrized decorator requires three nested functions:

```python
def decorator_with_params(param1, param2):      # 1. Accepts parameters
    def actual_decorator(func):                  # 2. Accepts target function
        @wraps(func)
        def wrapper(*args, **kwargs):            # 3. Accepts function arguments
            # Use param1, param2, func, args, kwargs
            return func(*args, **kwargs)
        return wrapper
    return actual_decorator
```

### Basic Example - Repeat Execution

```python
def repeat(times):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            results = []
            for _ in range(times):
                results.append(func(*args, **kwargs))
            return results
        return wrapper
    return decorator

@repeat(times=3)
def greet(name):
    return f"Hello, {name}!"

print(greet("Alice"))
```

**Output:**

```
['Hello, Alice!', 'Hello, Alice!', 'Hello, Alice!']
```

The `@repeat(times=3)` syntax calls `repeat(3)`, which returns the actual decorator that then wraps `greet`.

### Customizable Logging

```python
def log_with_level(level="INFO"):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            print(f"[{level}] Calling {func.__name__}")
            result = func(*args, **kwargs)
            print(f"[{level}] {func.__name__} returned {result}")
            return result
        return wrapper
    return decorator

@log_with_level(level="DEBUG")
def calculate(x, y):
    return x + y

@log_with_level(level="ERROR")
def divide(a, b):
    return a / b

calculate(5, 3)
divide(10, 2)
```

**Output:**

```
[DEBUG] Calling calculate
[DEBUG] calculate returned 8
[ERROR] Calling divide
[ERROR] divide returned 5.0
```

### Conditional Execution

```python
def run_if(condition):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            if condition:
                return func(*args, **kwargs)
            else:
                print(f"Skipping {func.__name__}: condition not met")
                return None
        return wrapper
    return decorator

debug_mode = True

@run_if(debug_mode)
def debug_info(message):
    return f"DEBUG: {message}"

print(debug_info("System starting"))

debug_mode = False

@run_if(debug_mode)
def another_debug(message):
    return f"DEBUG: {message}"

print(another_debug("This won't run"))
```

**Output:**

```
DEBUG: System starting
Skipping another_debug: condition not met
None
```

### Retry Logic with Parameters

```python
import time

def retry(max_attempts=3, delay=1):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            attempts = 0
            while attempts < max_attempts:
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    attempts += 1
                    if attempts >= max_attempts:
                        raise
                    print(f"Attempt {attempts} failed: {e}. Retrying in {delay}s...")
                    time.sleep(delay)
        return wrapper
    return decorator

@retry(max_attempts=3, delay=0.5)
def unstable_operation(fail_times):
    if unstable_operation.call_count < fail_times:
        unstable_operation.call_count += 1
        raise ValueError(f"Failed on attempt {unstable_operation.call_count}")
    return "Success!"

unstable_operation.call_count = 0
print(unstable_operation(2))
```

**Output:**

```
Attempt 1 failed: Failed on attempt 1. Retrying in 0.5s...
Attempt 2 failed: Failed on attempt 2. Retrying in 0.5s...
Success!
```

### Rate Limiting

```python
import time

def rate_limit(calls_per_second):
    min_interval = 1.0 / calls_per_second
    
    def decorator(func):
        last_call = [0]  # Mutable to modify in nested scope
        
        @wraps(func)
        def wrapper(*args, **kwargs):
            elapsed = time.time() - last_call[0]
            if elapsed < min_interval:
                time.sleep(min_interval - elapsed)
            last_call[0] = time.time()
            return func(*args, **kwargs)
        return wrapper
    return decorator

@rate_limit(calls_per_second=2)
def api_call(endpoint):
    return f"Called {endpoint} at {time.time():.2f}"

# These calls will be throttled
print(api_call("/users"))
print(api_call("/posts"))
print(api_call("/comments"))
```

### Type Validation

```python
def validate_types(**expected_types):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Validate kwargs
            for param_name, expected_type in expected_types.items():
                if param_name in kwargs:
                    if not isinstance(kwargs[param_name], expected_type):
                        raise TypeError(
                            f"{param_name} must be {expected_type.__name__}, "
                            f"got {type(kwargs[param_name]).__name__}"
                        )
            return func(*args, **kwargs)
        return wrapper
    return decorator

@validate_types(name=str, age=int, active=bool)
def create_user(name, age, active=True):
    return f"User {name}, age {age}, active={active}"

print(create_user(name="Alice", age=30))
# create_user(name="Bob", age="thirty")  # Would raise TypeError
```

### Optional Parameters with Defaults

Supporting both `@decorator` and `@decorator()` syntax:

```python
def smart_cache(max_size=None):
    def decorator(func):
        cache = {}
        @wraps(func)
        def wrapper(*args):
            if args in cache:
                return cache[args]
            
            result = func(*args)
            cache[args] = result
            
            if max_size and len(cache) > max_size:
                cache.pop(next(iter(cache)))  # Remove oldest
            
            return result
        return wrapper
    
    # Support @smart_cache without parentheses
    if callable(max_size):
        func = max_size
        max_size = None
        return decorator(func)
    
    return decorator

@smart_cache  # No parentheses
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

@smart_cache(max_size=100)  # With parameter
def expensive_computation(x):
    return x ** 2
```

### Chaining Parametrized Decorators

```python
@retry(max_attempts=3, delay=0.1)
@log_with_level(level="WARNING")
@validate_types(x=int, y=int)
def safe_divide(x, y):
    return x / y
```

**Key Points:**

- Parametrized decorators use three levels: parameter function → decorator function → wrapper function
- Parameters are captured in the closure and accessible to all inner functions
- The outermost function is called at decoration time with the parameters
- Supports flexible, reusable decorators that adapt to different use cases
- Can be combined with regular decorators in chains
- Consider providing sensible defaults and supporting parameter-less invocation for better usability

---

