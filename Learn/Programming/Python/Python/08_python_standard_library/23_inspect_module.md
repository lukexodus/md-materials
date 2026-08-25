## `inspect` Module


The `inspect` module provides functions for introspecting live Python objects, including modules, classes, methods, functions, tracebacks, frame objects, and code objects.

### Core Purpose

The module helps you examine the source code, signatures, and internal structure of Python objects at runtime. It's particularly useful for debugging, documentation generation, testing frameworks, and building developer tools.

### Getting Object Information

You can retrieve various types of information about Python objects:

**Type Checking**
- `inspect.ismodule()`, `inspect.isclass()`, `inspect.ismethod()`, `inspect.isfunction()` - Check object types
- `inspect.isbuiltin()`, `inspect.isroutine()` - Identify built-in and callable objects
- `inspect.isgeneratorfunction()`, `inspect.iscoroutinefunction()` - Check for special function types

**Source Code Access**
- `inspect.getsource(object)` - Returns the source code of an object as a string
- `inspect.getsourcelines(object)` - Returns a tuple of (source lines list, starting line number)
- `inspect.getfile(object)` - Returns the file path where an object is defined
- `inspect.getmodule(object)` - Returns the module an object belongs to

### Function Signatures

The module provides detailed signature inspection:

```python
import inspect

def example(a, b=10, *args, **kwargs):
    pass

sig = inspect.signature(example)
# sig contains parameter names, defaults, annotations, etc.

for param_name, param in sig.parameters.items():
    print(f"{param_name}: {param.kind}, default={param.default}")
```

The `Signature` object contains `Parameter` objects with attributes like `name`, `default`, `annotation`, and `kind` (POSITIONAL_OR_KEYWORD, VAR_POSITIONAL, KEYWORD_ONLY, etc.).

#### `inspect.signature` vs `get_type_hints`

##### Core Purpose

**`get_type_hints()`** (from `typing` module):
- Returns a dictionary mapping parameter names to their **resolved type annotations**
- Evaluates forward references and string annotations
- Processes `from __future__ import annotations`

**`inspect.signature()`** (from `inspect` module):
- Returns a `Signature` object with detailed metadata about function parameters
- Provides **raw annotations** without evaluation
- Includes parameter kinds (positional, keyword, etc.) and default values

##### Key Differences

###### 1. Return Type
```python
from typing import get_type_hints
import inspect

def example(x: int, y: str = "hello") -> bool:
    return True

# get_type_hints returns dict
hints = get_type_hints(example)
# {'x': <class 'int'>, 'y': <class 'str'>, 'return': <class 'bool'>}

# inspect.signature returns Signature object
sig = inspect.signature(example)
# <Signature (x: int, y: str = 'hello') -> bool>
```

###### 2. Forward Reference Handling
```python
def func(x: "MyClass") -> "MyClass":
    pass

# get_type_hints() evaluates string annotations
hints = get_type_hints(func)  # Attempts to resolve "MyClass"

# inspect.signature() keeps raw strings
sig = inspect.signature(func)
sig.parameters['x'].annotation  # Returns the string "MyClass"
```

###### 3. Information Provided

`get_type_hints()` only gives you:
- Type annotations
- Return type annotation

`inspect.signature()` gives you:
- Type annotations (raw)
- Default values
- Parameter kinds (`POSITIONAL_ONLY`, `POSITIONAL_OR_KEYWORD`, `VAR_POSITIONAL`, `KEYWORD_ONLY`, `VAR_KEYWORD`)
- Parameter order

###### 4. Usage Example
```python
def process(a: int, b: int = 5, *args: str, key: bool = True, **kwargs: float) -> None:
    pass

# With get_type_hints
hints = get_type_hints(process)
# {'a': int, 'b': int, 'args': str, 'key': bool, 'kwargs': float, 'return': None}

# With inspect.signature
sig = inspect.signature(process)
for name, param in sig.parameters.items():
    print(f"{name}: kind={param.kind}, default={param.default}, annotation={param.annotation}")
```

##### When to Use Each

**Use `get_type_hints()`** when:
- You need resolved type annotations for type checking
- Working with forward references
- Building type validation systems
- You only care about types, not parameter details

**Use `inspect.signature()`** when:
- You need parameter metadata (defaults, kinds)
- Building function wrappers or decorators
- Generating documentation
- You need the raw, unevaluated annotations
- Working with function introspection tools

##### Combined Usage
They're often used together:
```python
sig = inspect.signature(func)
hints = get_type_hints(func)

for name, param in sig.parameters.items():
    param_type = hints.get(name)
    default = param.default
    # Now you have both resolved type and default value
```

### Class Inspection

You can examine class hierarchies and members:

- `inspect.getmembers(object)` - Returns all members as (name, value) pairs
- `inspect.getmro(class)` - Returns the method resolution order tuple
- `inspect.getclasstree(classes)` - Arranges classes into a hierarchy

### Stack and Frame Inspection

The module allows you to examine the call stack:

- `inspect.currentframe()` - Returns the current stack frame
- `inspect.stack()` - Returns a list of frame records for the caller's stack
- `inspect.getframeinfo(frame)` - Extracts information from a frame object

Each frame record contains the frame object, filename, line number, function name, context lines, and context index.

### Practical Use Cases

The inspect module is commonly used in:

- **Testing frameworks** - To discover test methods and examine function signatures
- **Documentation tools** - To extract docstrings and signatures automatically
- **Decorators** - To preserve or examine wrapped function metadata
- **Debugging tools** - To examine the call stack and local variables
- **Serialization** - To understand object structure before pickling
- **API introspection** - To validate function calls or generate API documentation

### Important Limitations

[Inference] The module cannot retrieve source code for built-in functions written in C, objects defined in the interactive interpreter without saving to a file, or dynamically generated code that wasn't properly associated with source. [Inference] It also cannot access source for objects whose source files are no longer available or have been modified since the module was imported.

### Frame Objects

Frame objects represent execution frames in Python's call stack. Each time a function is called, Python creates a frame object that contains all the runtime information for that function's execution.

**What a Frame Contains**

A frame object holds:
- Local variables for the current function (`frame.f_locals`)
- Global variables accessible to the frame (`frame.f_globals`)
- Built-in namespace (`frame.f_builtins`)
- The code object being executed (`frame.f_code`)
- The previous frame in the stack (`frame.f_back`)
- Current line number being executed (`frame.f_lineno`)
- Last instruction executed (`frame.f_lasti`)

**Accessing Frames**

```python
import inspect
import sys

def inner():
    frame = inspect.currentframe()
    print(f"Function: {frame.f_code.co_name}")
    print(f"Local vars: {frame.f_locals}")
    print(f"Line number: {frame.f_lineno}")

def outer():
    x = 42
    inner()

outer()
```

You can also use `sys._getframe(n)` where n is the number of stack levels to go back (0 is current frame, 1 is caller, etc.).

**Frame Lifecycle**

Frames are created when functions are called and typically destroyed when functions return. However, if you keep a reference to a frame object, it can create reference cycles and prevent garbage collection of that frame's local variables.

### Code Objects

Code objects contain the compiled bytecode and metadata for executable Python code blocks (functions, methods, classes, modules, etc.). They're created by Python's compiler and are immutable.

**What a Code Object Contains**

Key attributes include:
- `co_name` - Name of the function/class/module
- `co_filename` - File where the code was defined
- `co_firstlineno` - First line number in the source
- `co_argcount` - Number of positional arguments
- `co_kwonlyargcount` - Number of keyword-only arguments
- `co_nlocals` - Number of local variables
- `co_varnames` - Tuple of local variable names
- `co_code` - The actual bytecode as bytes
- `co_consts` - Tuple of constants used in the bytecode
- `co_names` - Tuple of names used in the bytecode

**Accessing Code Objects**

```python
def example(a, b=10):
    x = a + b
    return x

code = example.__code__
print(f"Name: {code.co_name}")
print(f"Arg count: {code.co_argcount}")
print(f"Local vars: {code.co_varnames}")
print(f"Filename: {code.co_filename}")
```

**Bytecode Inspection**

You can examine the compiled bytecode using the `dis` module:

```python
import dis

def add(x, y):
    return x + y

dis.dis(add)
# Shows the bytecode instructions
```

### Relationship Between Frame and Code Objects

Every frame object has a code object (`frame.f_code`) that defines what code the frame is executing. Multiple frames can reference the same code object if the same function is called multiple times (recursively or from different places).

Think of it this way:
- **Code object** = The recipe (static, immutable, shared)
- **Frame object** = The kitchen workspace with ingredients (dynamic, per-execution, unique)

### Practical Applications

**Debugging and Profiling**

Debuggers like `pdb` use frame objects to inspect local variables and step through code. Profilers use frame information to track function calls and execution time.

**Stack Traces**

When exceptions occur, Python walks the frame stack to build traceback information. Each traceback entry corresponds to a frame.

**Dynamic Code Inspection**

```python
def get_caller_info():
    frame = inspect.currentframe().f_back
    return {
        'function': frame.f_code.co_name,
        'filename': frame.f_code.co_filename,
        'line': frame.f_lineno,
        'locals': frame.f_locals
    }
```

**Code Modification**

[Unverified] While code objects themselves are immutable, tools can create new code objects with modified bytecode for advanced metaprogramming, though this is fragile and version-dependent.

### Memory Considerations

Frame objects can create memory leaks if you're not careful. [Inference] When you store a reference to a frame object, it keeps all its local variables alive, and through `f_back`, it can keep the entire call stack alive. It's good practice to explicitly delete frame references when done:

```python
frame = inspect.currentframe()
try:
    # use frame
    pass
finally:
    del frame
```

