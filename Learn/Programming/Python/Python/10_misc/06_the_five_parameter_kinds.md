## The Five Parameter Kinds


### 1. POSITIONAL_ONLY
Parameters that can **only** be passed by position, not by keyword.

```python
def func(a, b, /):  # "/" marks end of positional-only params
    return a + b

func(1, 2)        # ✓ Valid
func(a=1, b=2)    # ✗ TypeError: got some positional-only arguments passed as keyword
```

**Inspection:**
```python
import inspect

sig = inspect.signature(func)
for name, param in sig.parameters.items():
    print(f"{name}: {param.kind}")
# a: POSITIONAL_ONLY
# b: POSITIONAL_ONLY
```

### 2. POSITIONAL_OR_KEYWORD
Parameters that can be passed **either** by position or by keyword. This is the default.

```python
def func(a, b):
    return a + b

func(1, 2)        # ✓ Valid - positional
func(a=1, b=2)    # ✓ Valid - keyword
func(1, b=2)      # ✓ Valid - mixed
```

**Inspection:**
```python
sig = inspect.signature(func)
for name, param in sig.parameters.items():
    print(f"{name}: {param.kind}")
# a: POSITIONAL_OR_KEYWORD
# b: POSITIONAL_OR_KEYWORD
```

### 3. VAR_POSITIONAL
Captures excess positional arguments (the `*args` parameter).

```python
def func(*args):
    return args

func(1, 2, 3)     # Returns (1, 2, 3)
```

**Inspection:**
```python
sig = inspect.signature(func)
for name, param in sig.parameters.items():
    print(f"{name}: {param.kind}")
# args: VAR_POSITIONAL
```

### 4. KEYWORD_ONLY
Parameters that can **only** be passed by keyword, not by position.

```python
def func(*, a, b):  # "*" marks start of keyword-only params
    return a + b

func(a=1, b=2)    # ✓ Valid
func(1, 2)        # ✗ TypeError: takes 0 positional arguments but 2 were given
```

**Also applies after `*args`:**
```python
def func(*args, key):
    return args, key

func(1, 2, key=3)   # ✓ Valid: (1, 2), 3
func(1, 2, 3)       # ✗ TypeError: missing required keyword-only argument
```

**Inspection:**
```python
sig = inspect.signature(func)
for name, param in sig.parameters.items():
    print(f"{name}: {param.kind}")
# a: KEYWORD_ONLY
# b: KEYWORD_ONLY
```

### 5. VAR_KEYWORD
Captures excess keyword arguments (the `**kwargs` parameter).

```python
def func(**kwargs):
    return kwargs

func(a=1, b=2, c=3)  # Returns {'a': 1, 'b': 2, 'c': 3}
```

**Inspection:**
```python
sig = inspect.signature(func)
for name, param in sig.parameters.items():
    print(f"{name}: {param.kind}")
# kwargs: VAR_KEYWORD
```

### Complete Example: All Five Kinds

```python
def complete(pos_only, /,           # POSITIONAL_ONLY
             pos_or_kw,             # POSITIONAL_OR_KEYWORD
             *args,                 # VAR_POSITIONAL
             kw_only,               # KEYWORD_ONLY
             **kwargs):             # VAR_KEYWORD
    pass

# Valid call:
complete(1, 2, 3, 4, kw_only=5, extra=6)
```

**Inspection:**
```python
import inspect

sig = inspect.signature(complete)
for name, param in sig.parameters.items():
    print(f"{name:12} {param.kind}")

# Output:
# pos_only     Parameter.POSITIONAL_ONLY
# pos_or_kw    Parameter.POSITIONAL_OR_KEYWORD
# args         Parameter.VAR_POSITIONAL
# kw_only      Parameter.KEYWORD_ONLY
# kwargs       Parameter.VAR_KEYWORD
```

### Parameter Ordering Rules

Python enforces this strict order:
1. `POSITIONAL_ONLY` parameters
2. `POSITIONAL_OR_KEYWORD` parameters
3. `VAR_POSITIONAL` (`*args`)
4. `KEYWORD_ONLY` parameters
5. `VAR_KEYWORD` (`**kwargs`)

```python
# ✓ Valid ordering
def valid(a, /, b, *args, c, **kwargs):
    pass

# ✗ Invalid - keyword-only before positional
def invalid(*, a, b):  # SyntaxError if you try to add positional params after
    pass
```

### Practical Usage: Checking Parameter Kinds

```python
import inspect

def analyze_function(func):
    sig = inspect.signature(func)
    
    for name, param in sig.parameters.items():
        kind_name = str(param.kind).split('.')[-1]
        default = f"= {param.default}" if param.default != inspect.Parameter.empty else ""
        annotation = f": {param.annotation}" if param.annotation != inspect.Parameter.empty else ""
        
        print(f"{name}{annotation} {default} [{kind_name}]")

def example(a, /, b, *args, key=None, **kwargs):
    pass

analyze_function(example)
# Output:
# a [POSITIONAL_ONLY]
# b [POSITIONAL_OR_KEYWORD]
# args [VAR_POSITIONAL]
# key = None [KEYWORD_ONLY]
# kwargs [VAR_KEYWORD]
```

### Why This Matters

Understanding parameter kinds is essential for:
- **Building decorators** that preserve function signatures
- **Creating function wrappers** that forward arguments correctly
- **Generating documentation** that accurately describes how to call functions
- **Implementing dynamic dispatch** systems
- **Type checking and validation** tools

---

