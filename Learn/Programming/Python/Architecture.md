# Python's Execution Model: Demystifying the "Magic"

Let me walk you through Python's architecture from the ground up, so decorators and other "magic" become obvious consequences of the design rather than mysterious incantations.

---

## 1. Python's Compilation Pipeline

Python is **compiled and interpreted** — most people only see the interpreted part.

```
Your .py file
     │
     ▼
 [Lexer / Tokenizer]
     │  breaks text into tokens: def, foo, (, ), :, etc.
     ▼
 [Parser]
     │  builds an Abstract Syntax Tree (AST)
     ▼
 [Compiler]
     │  walks the AST, emits bytecode
     ▼
 .pyc file  (cached in __pycache__)
     │
     ▼
 [CPython VM / Interpreter]
     │  executes bytecode instructions one at a time
     ▼
 Your program runs
```

You can inspect every layer:

```python
import ast, dis

source = """
def add(x, y):
    return x + y
"""

# See the AST
tree = ast.parse(source)
print(ast.dump(tree, indent=2))

# See the bytecode
code = compile(source, "<string>", "exec")
exec(code)                   # defines `add` in this scope
dis.dis(add)                 # disassemble add's bytecode
```

The key insight: **Python compiles your file top-to-bottom at import time, then executes it top-to-bottom.** There is no separate "link" phase. Execution _is_ definition.

---

## 2. The Object Model: Everything Is an Object

This is the root of all the "magic."

```python
def foo():
    return 1

print(type(foo))       # <class 'function'>
print(foo.__code__)    # the compiled bytecode object
print(foo.__globals__) # the module's global namespace dict
```

A **function** is not a special primitive. It is an instance of `function` class, stored in memory like any other object. This has one enormous consequence:

> **Functions can be passed as arguments, returned from other functions, stored in variables, and put in lists — because they are just objects.**

```python
def greet():
    print("hello")

alias = greet       # no call, just reference copy
alias()             # prints "hello"

funcs = [greet, print, len]   # totally legal
```

---

## 3. How `def` Actually Works at Runtime

`def` is **not a declaration**. It is an **executable statement** that runs at runtime and produces a function object.

```python
# This:
def add(x, y):
    return x + y

# Is roughly equivalent to this:
add = FunctionType(
    code=<compiled bytecode for the body>,
    globals=globals(),
    name="add",
    ...
)
```

When Python's VM hits a `def` statement, it:

1. Takes the pre-compiled code object for that function's body (compiled earlier)
2. Creates a new `function` object wrapping it
3. Binds that object to the name in the current namespace

**This is why `def` inside an `if` block works** — the function only gets created if that branch executes.

```python
if condition:
    def foo():   # foo only exists if condition is True
        pass
```

---

## 4. Namespaces and Scope (The LEGB Rule)

Python resolves names by searching scopes in order:

```
L — Local       (inside the current function)
E — Enclosing   (any enclosing function scopes, inner to outer)
G — Global      (the module's top-level namespace)
B — Built-in    (builtins like len, print, etc.)
```

Each scope is just a **plain Python dictionary**. You can inspect them:

```python
x = 10   # goes into globals()

def outer():
    y = 20   # goes into outer's locals()
    
    def inner():
        z = 30   # goes into inner's locals()
        print(x, y, z)   # LEGB lookup: z→local, y→enclosing, x→global
    
    inner()

print(globals()['x'])   # 10
```

The compiler, at compile time, determines for each name _which scope_ it belongs to. That's why you get an `UnboundLocalError` if you assign to a name later in a function — the compiler already decided it's local.

---

## 5. Closures: How Inner Functions Capture Variables

When an inner function references a name from an enclosing scope, Python creates a **closure** — the inner function object holds a reference to a **cell object** that the enclosing scope also holds.

```python
def make_counter():
    count = 0              # stored in a cell, not a plain local

    def increment():
        nonlocal count     # tells compiler: use the enclosing cell
        count += 1
        return count

    return increment       # the function object + its closure cells

c = make_counter()
print(c())  # 1
print(c())  # 2
```

You can inspect the closure:

```python
print(c.__closure__)             # (<cell at 0x...>,)
print(c.__closure__[0].cell_contents)  # 2
```

The outer function (`make_counter`) is **gone** — its stack frame no longer exists — but `count` lives on inside the cell because `increment` still references it.

---

## 6. Decorators: Now They're Obvious

A decorator is **nothing more than a function that takes a function and returns something** (usually another function). The `@` syntax is pure syntactic sugar, resolved at compile time into a straightforward function call.

```python
@decorator
def foo():
    pass

# Exactly identical to:
def foo():
    pass
foo = decorator(foo)
```

The compiler transforms `@decorator` into that assignment. That's the entire mechanism.

### A decorator from scratch:

```python
def my_decorator(func):
    # func is the original function object
    
    def wrapper(*args, **kwargs):
        print("before")
        result = func(*args, **kwargs)   # call the original
        print("after")
        return result
    
    return wrapper   # return the replacement function object

@my_decorator
def greet(name):
    print(f"hello {name}")

# At this point: greet = my_decorator(greet)
# greet now points to `wrapper`, which closes over the original `func`

greet("alice")
# before
# hello alice
# after
```

The name `greet` now points to `wrapper`. The original function object still exists, referenced by `func` inside `wrapper`'s closure.

### Decorator with arguments:

```python
@repeat(3)
def say(msg):
    print(msg)

# Expands to:
say = repeat(3)(say)
```

So `repeat(3)` must **return a decorator** (a callable that takes a function):

```python
def repeat(n):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for _ in range(n):
                func(*args, **kwargs)
        return wrapper
    return decorator
```

Three layers of functions, each a closure over the one above it. Nothing more.

---

## 7. The Full Mental Model in One Diagram

```
Source code
    │
    ├─ [Lexer] → tokens
    ├─ [Parser] → AST
    └─ [Compiler] → bytecode (code objects)
                         │
                    Stored in .pyc
                         │
              ┌──────────▼──────────┐
              │   CPython VM        │
              │                     │
              │  executes bytecode  │
              │  top to bottom      │
              │                     │
              │  `def` statement    │
              │   → creates         │
              │     function object │
              │     in namespace    │
              │     dict            │
              │                     │
              │  `@decorator`       │
              │   → wraps that      │
              │     object before   │
              │     binding name    │
              └─────────────────────┘
```

---

## 8. Other "Magic" That Falls Out of This Model

Once you have this model, these stop being magic:

|Feature|What's actually happening|
|---|---|
|`@staticmethod` / `@classmethod`|Descriptors — objects with `__get__` that intercept attribute access|
|`@property`|A descriptor that routes `.x` reads/writes to methods|
|`__dunder__` methods|The VM checks for these by name when it needs to do an operation (e.g. `+` calls `__add__`)|
|`with` statement|Calls `__enter__` on entry, `__exit__` on exit (even on exception)|
|`yield` / generators|`def` creates a generator object instead of running the body; `next()` resumes the frame|
|`async/await`|Similar to generators — the event loop drives frame resumption|
|Class creation (`class Foo`)|`class` is also an executable statement — calls a metaclass to produce a class object|

---

## Where to Go Next

- **`dis` module** — disassemble any function to see its exact bytecode
- **`ast` module** — inspect and even transform the AST before compilation
- **`inspect` module** — examine functions, closures, signatures at runtime
- **CPython source** (`Objects/funcobject.c`) — the actual C implementation of function objects, if you want to go all the way down

The core insight to hold onto: **Python executes your file like a script. `def` and `class` are statements that produce objects. Names are just dictionary keys. Decorators are assignment. Everything else follows from that.**

---

# The `dis` Module

`dis` disassembles Python bytecode — it shows you the actual instructions the CPython VM executes. Every Python function, method, class body, and module has a **code object** containing these instructions. `dis` makes them readable.

---

## The Code Object

Before `dis`, understand what it's reading:

```python
def add(x, y):
    return x + y

code = add.__code__

print(code.co_varnames)   # ('x', 'y') — local variable names
print(code.co_consts)     # (None,)    — literal constants
print(code.co_filename)   # where it was defined
print(code.co_firstlineno)# 1
print(code.co_code)       # b'...' — raw bytes of bytecode
```

`dis` turns those raw bytes into something human-readable.

---

## Basic Usage

```python
import dis

def add(x, y):
    return x + y

dis.dis(add)
```

Output:

```
  2           RESUME                   0

  3           LOAD_FAST                0 (x)
              LOAD_FAST                1 (y)
              BINARY_OP                0 (+)
              RETURN_VALUE
```

### Reading the columns

```
  3           LOAD_FAST                0 (x)
  │           │                        │  │
  │           │                        │  └─ human-readable arg hint
  │           │                        └──── argument (index, offset, etc.)
  │           └───────────────────────────── instruction name (opcode)
  └───────────────────────────────────────── source line number
```

An `>>` prefix means the line is a **jump target** — something else in the bytecode can jump to it.

---

## The Most Common Instructions

### Loading values onto the stack

|Instruction|What it does|
|---|---|
|`LOAD_FAST`|Load a local variable|
|`LOAD_GLOBAL`|Load a global (module-level) name|
|`LOAD_CONST`|Load a literal constant (`1`, `"hello"`, `None`)|
|`LOAD_ATTR`|Load an attribute (`obj.x` → loads `x` from `obj`)|
|`LOAD_DEREF`|Load from a closure cell (enclosing scope variable)|

### Storing values

| Instruction    | What it does                           |
| -------------- | -------------------------------------- |
| `STORE_FAST`   | Assign to a local variable             |
| `STORE_GLOBAL` | Assign to a global name                |
| `STORE_ATTR`   | Assign to an attribute (`obj.x = ...`) |
| `STORE_DEREF`  | Store into a closure cell              |

### Operations

| Instruction      | What it does                                      |
| ---------------- | ------------------------------------------------- |
| `BINARY_OP`      | `+`, `-`, `*`, `/`, etc. (argument selects which) |
| `COMPARE_OP`     | `\==`, `<`, `in`, `is`, etc.                      |
| `UNARY_NEGATIVE` | `-x`                                              |
| `CALL`           | Call a callable with args already on the stack    |

### Control flow

|Instruction|What it does|
|---|---|
|`JUMP_FORWARD`|Unconditional jump forward|
|`POP_JUMP_IF_TRUE`|Pop top of stack; jump if it was truthy|
|`POP_JUMP_IF_FALSE`|Pop top of stack; jump if it was falsy|
|`FOR_ITER`|Advance an iterator; jump to end if exhausted|
|`RETURN_VALUE`|Return top of stack to caller|

---

## The Stack Machine Model

CPython is a **stack-based VM**. Instructions don't have registers — they push and pop values on an internal value stack.

```python
return x + y
```

Executes as:

```
LOAD_FAST  x     # stack: [x]
LOAD_FAST  y     # stack: [x, y]
BINARY_OP  +     # pops x and y, pushes result: [x+y]
RETURN_VALUE     # pops x+y, returns it: []
```

Every operation is: pop inputs, push output. That's the whole model.

---

## Seeing a Decorator in Bytecode

This is where it becomes concrete:

```python
import dis

def my_decorator(func):
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

@my_decorator
def greet():
    pass

dis.dis(greet.__wrapped__ if hasattr(greet, '__wrapped__') else greet)
```

Disassemble the **module** to see the decorator application itself:

```python
source = """
def my_decorator(func):
    return func

@my_decorator
def greet():
    pass
"""

code = compile(source, "<string>", "exec")
dis.dis(code)
```

Output (abbreviated):

```
  2           LOAD_CONST    0 (<code object my_decorator>)
              MAKE_FUNCTION 0
              STORE_NAME    0 (my_decorator)

  5           LOAD_NAME     0 (my_decorator)    ← push the decorator

  6           LOAD_CONST    1 (<code object greet>)
              MAKE_FUNCTION 0                   ← create function object
              CALL          1                   ← call decorator(greet)
              STORE_NAME    1 (greet)            ← bind result to 'greet'
```

You can see exactly what `@my_decorator` compiles to:

1. Push the decorator onto the stack
2. Build the function object
3. `CALL` — apply decorator to function
4. `STORE_NAME` — bind the result

No magic. Four instructions.

---

## Disassembling Other Things

`dis.dis()` accepts more than just functions:

```python
# A string of source code
dis.dis("x = 1 + 2")

# A class (disassembles all methods)
class Foo:
    def bar(self): pass

dis.dis(Foo)

# A code object directly
dis.dis(compile("x + y", "<string>", "eval"))

# A generator
def gen():
    yield 1
    yield 2

dis.dis(gen)
```

---

## `dis.get_instructions()` — Programmatic Access

Instead of printing, get instruction objects you can work with:

```python
import dis

def add(x, y):
    return x + y

for instr in dis.get_instructions(add):
    print(f"{instr.offset:>4}  {instr.opname:<20} {instr.argrepr}")
```

Output:

```
   0  RESUME                
   2  LOAD_FAST            x
   4  LOAD_FAST            y
   6  BINARY_OP            + (0)
  10  RETURN_VALUE         
```

Each `Instruction` is a named tuple with:

|Field|Meaning|
|---|---|
|`opname`|Instruction name as string|
|`opcode`|Numeric opcode|
|`arg`|Numeric argument|
|`argrepr`|Human-readable argument hint|
|`offset`|Byte offset in the code object|
|`starts_line`|Source line number (if new line starts here)|
|`is_jump_target`|Whether anything jumps to this offset|

---

## Seeing Closures

```python
import dis

def outer():
    x = 10
    def inner():
        return x
    return inner

dis.dis(outer)
print("---")
dis.dis(outer())
```

`outer` will contain `MAKE_CELL` / `STORE_DEREF` for `x`. `inner` will contain `LOAD_DEREF` instead of `LOAD_FAST` — reading from a cell, not a plain local.

That single difference in opcode is **the entire mechanism of closures**.

---

## Version Note

Bytecode is **CPython-specific and version-specific.** Instruction names and behavior can change between Python versions (3.11 and 3.12 made significant changes; 3.12+ uses `RESUME`, merged several ops). What you see in `dis` output is not guaranteed to be stable across versions. It's a diagnostic tool, not a contract.

---

# The `ast` Module

The `ast` module gives you access to Python's **Abstract Syntax Tree** — the structured representation of your source code that exists _after_ parsing but _before_ compilation to bytecode. It's the layer where your code is fully understood as syntax but hasn't yet become executable instructions.

---

## Where AST Sits in the Pipeline

```
source code (.py)
      │
   [Lexer]          tokenizes raw text
      │
   [Parser]         builds the AST        ← ast module lives here
      │
   [Compiler]       walks AST → bytecode
      │
   [CPython VM]     executes bytecode
```

The AST is a **tree of Python objects**, each representing a syntactic construct: a function definition, a binary operation, a name reference, an if-statement, etc.

---

## Parsing Source into an AST

```python
import ast

source = """
x = 1 + 2
print(x)
"""

tree = ast.parse(source)
print(type(tree))         # <class 'ast.Module'>
print(ast.dump(tree, indent=2))
```

`ast.parse()` returns an `ast.Module` node — the root of the tree. Every node in the tree is an instance of a class defined in the `ast` module.

---

## Reading `ast.dump()` Output

```python
source = "x = 1 + 2"
tree = ast.parse(source)
print(ast.dump(tree, indent=2))
```

Output:

```
Module(
  body=[
    Assign(
      targets=[
        Name(id='x', ctx=Store())
      ],
      value=BinOp(
        left=Constant(value=1),
        op=Add(),
        right=Constant(value=2)
      )
    )
  ],
  type_ignores=[]
)
```

Reading this tree directly:

- The module body is a list of statements
- The one statement is an `Assign`
- The target is `Name(id='x')` with a `Store` context (being written to)
- The value is a `BinOp`: `1 + 2`
- `Add()` is the operator; `Constant(1)` and `Constant(2)` are the operands

---

## Node Categories

Every AST node falls into one of these categories:

### Statements (`stmt`)

Things that _do_ something. They appear in `body` lists.

|Node|Source construct|
|---|---|
|`Assign`|`x = 1`|
|`AugAssign`|`x += 1`|
|`AnnAssign`|`x: int = 1`|
|`FunctionDef`|`def foo():`|
|`AsyncFunctionDef`|`async def foo():`|
|`ClassDef`|`class Foo:`|
|`Return`|`return x`|
|`If`|`if x:`|
|`For`|`for x in y:`|
|`While`|`while x:`|
|`With`|`with x as y:`|
|`Import`|`import os`|
|`ImportFrom`|`from os import path`|
|`Raise`|`raise ValueError`|
|`Try`|`try / except`|
|`Delete`|`del x`|
|`Expr`|An expression used as a statement (e.g. a bare function call)|

### Expressions (`expr`)

Things that _produce a value_. They appear as `value`, `left`, `right`, etc.

|Node|Source construct|
|---|---|
|`Constant`|`1`, `"hello"`, `True`, `None`|
|`Name`|`x` (a variable reference)|
|`BinOp`|`x + y`|
|`UnaryOp`|`-x`, `not x`|
|`BoolOp`|`x and y`, `x or y`|
|`Compare`|`x < y`, `x == y`|
|`Call`|`foo(x, y)`|
|`Attribute`|`obj.x`|
|`Subscript`|`x[i]`|
|`Lambda`|`lambda x: x + 1`|
|`IfExp`|`x if cond else y`|
|`ListComp`|`[x for x in y]`|
|`DictComp`|`{k: v for k, v in d.items()}`|
|`List`, `Tuple`, `Set`, `Dict`|Literal collections|
|`JoinedStr`|f-strings|

### Contexts (`expr_context`)

Appear on `Name`, `Subscript`, `Attribute` nodes. Tell you _how_ the name is being used.

|Context|Meaning|
|---|---|
|`Load()`|Reading the value|
|`Store()`|Being assigned to|
|`Del()`|Being deleted|

---

## Node Fields and Attributes

Every node has:

- **Fields** — the named children of the node (listed in `_fields`)
- **Attributes** — metadata added by the parser (`lineno`, `col_offset`, `end_lineno`, `end_col_offset`)

```python
import ast

source = "x = 1 + 2"
tree = ast.parse(source)

assign = tree.body[0]
print(assign._fields)          # ('targets', 'value', 'type_comment')
print(assign.lineno)           # 1
print(assign.col_offset)       # 0

binop = assign.value
print(binop._fields)           # ('left', 'op', 'right')
print(type(binop.op))          # <class 'ast.Add'>
```

---

## Walking the Tree

### `ast.walk()` — flat iterator over all nodes

```python
import ast

source = """
def add(x, y):
    return x + y
"""

tree = ast.parse(source)

for node in ast.walk(tree):
    if isinstance(node, ast.Name):
        print(f"Name: {node.id}  ctx: {type(node.ctx).__name__}")
```

Output:

```
Name: x   ctx: Load
Name: y   ctx: Load
```

`ast.walk()` visits every node in the tree in breadth-first order. No guarantees on order relative to siblings.

### `ast.NodeVisitor` — structured traversal

Override `visit_<NodeType>` methods. The base class routes each node to the right method.

```python
import ast

class NameCollector(ast.NodeVisitor):
    def __init__(self):
        self.names = []

    def visit_Name(self, node):
        self.names.append((node.id, type(node.ctx).__name__))
        self.generic_visit(node)  # continue traversal into children

source = """
x = 1
y = x + 2
print(y)
"""

tree = ast.parse(source)
visitor = NameCollector()
visitor.visit(tree)
print(visitor.names)
# [('x', 'Store'), ('x', 'Load'), ('y', 'Store'), ('print', 'Load'), ('y', 'Load')]
```

`generic_visit()` is important — without it, traversal **stops** at that node. Call it whenever you want to continue into children.

---

## `ast.NodeTransformer` — rewriting the tree

`NodeTransformer` is like `NodeVisitor` but your `visit_*` methods **return** the replacement node. Return the original node unchanged, return a different node, or return `None` to delete the node.

```python
import ast

class DoubleConstants(ast.NodeTransformer):
    def visit_Constant(self, node):
        if isinstance(node.value, int):
            return ast.Constant(value=node.value * 2)
        return node  # leave non-ints alone

source = "x = 1 + 2"
tree = ast.parse(source)
new_tree = DoubleConstants().visit(tree)

ast.fix_missing_locations(new_tree)  # fill in lineno etc.
code = compile(new_tree, "<string>", "exec")
exec(code)
print(x)  # 6  (was 1+2=3, now 2+4=6)
```

`ast.fix_missing_locations()` is required after transformation — new nodes you create won't have `lineno`/`col_offset` set, and `compile()` requires them.

---

## Compiling and Executing a Modified Tree

```python
import ast

source = "x = 40 + 2"
tree = ast.parse(source)

# inspect, modify, whatever
ast.fix_missing_locations(tree)

code = compile(tree, filename="<ast>", mode="exec")
namespace = {}
exec(code, namespace)
print(namespace['x'])  # 42
```

The three `mode` values for `compile()`:

|Mode|Use for|Returns|
|---|---|---|
|`"exec"`|A module or sequence of statements|`None`|
|`"eval"`|A single expression|The expression's value|
|`"single"`|One interactive statement|Prints if expression|

---

## Practical Use Cases

### 1. Static analysis — find all function calls

```python
import ast

source = """
import os
x = len([1, 2, 3])
print(os.path.join("a", "b"))
"""

tree = ast.parse(source)

for node in ast.walk(tree):
    if isinstance(node, ast.Call):
        # the function being called
        if isinstance(node.func, ast.Name):
            print(f"call: {node.func.id}()")
        elif isinstance(node.func, ast.Attribute):
            print(f"call: <obj>.{node.func.attr}()")
```

Output:

```
call: len()
call: <obj>.join()
call: print()
```

### 2. Detect use of a forbidden name

```python
import ast

class ForbiddenNameChecker(ast.NodeVisitor):
    def __init__(self, forbidden):
        self.forbidden = forbidden
        self.violations = []

    def visit_Name(self, node):
        if node.id in self.forbidden and isinstance(node.ctx, ast.Load):
            self.violations.append((node.id, node.lineno))
        self.generic_visit(node)

source = """
import eval
x = eval("1+1")
"""

tree = ast.parse(source)
checker = ForbiddenNameChecker({"eval", "exec"})
checker.visit(tree)
print(checker.violations)  # [('eval', 3)]
```

### 3. Macro-like transformation — auto-logging

```python
import ast

class AutoLogger(ast.NodeTransformer):
    """Wraps every function body with an entry log."""

    def visit_FunctionDef(self, node):
        log_call = ast.Expr(
            value=ast.Call(
                func=ast.Name(id='print', ctx=ast.Load()),
                args=[ast.Constant(value=f"entering {node.name}")],
                keywords=[]
            )
        )
        node.body.insert(0, log_call)
        self.generic_visit(node)
        return node

source = """
def greet(name):
    print(f"hello {name}")
"""

tree = ast.parse(source)
new_tree = AutoLogger().visit(tree)
ast.fix_missing_locations(new_tree)
exec(compile(new_tree, "<string>", "exec"))
greet("alice")
# entering greet
# hello alice
```

---

## `ast.literal_eval()` — safe evaluation

Evaluates a string containing only **literal** Python structures. No function calls, no name lookups, no side effects.

```python
import ast

# Safe — only literals
ast.literal_eval("[1, 2, {'key': True}]")   # returns the list

# Raises ValueError — not a literal
ast.literal_eval("os.getcwd()")
```

Useful for safely parsing config files, user input, or serialized data that looks like Python but shouldn't be `eval()`'d.

---

## Key Relationships to Keep in Mind

```
ast.parse()          source str → AST tree
ast.dump()           AST tree → readable string (for inspection)
ast.walk()           AST tree → flat iterator of all nodes
ast.NodeVisitor      structured read-only traversal
ast.NodeTransformer  structured rewriting traversal
ast.fix_missing_locations()   required after building/modifying nodes
compile()            AST tree → code object
exec() / eval()      code object → execution
```

The AST is the layer where your source code has **full semantic structure** but is still **pure data** — inspectable, modifiable, and serializable before any execution happens. Everything the compiler knows about your program, you can know too.

---

# The `inspect` Module

`inspect` gives you **runtime introspection** — examining live Python objects as they exist in memory during execution. Where `dis` reads bytecode and `ast` reads source structure, `inspect` reads the actual objects the VM is currently working with.

---

## Where `inspect` Sits

```
source → AST → bytecode → [VM running] ← inspect lives here
                                │
                         live objects in memory:
                         functions, classes, frames,
                         modules, methods, closures
```

---

## Functions

### Signature inspection

```python
import inspect

def connect(host, port=5432, *, timeout=30, ssl=False):
    pass

sig = inspect.signature(connect)
print(sig)
# (host, port=5432, *, timeout=30, ssl=False)

for name, param in sig.parameters.items():
    print(f"{name}: kind={param.kind.name}, default={param.default}")
```

Output:

```
host:    kind=POSITIONAL_OR_KEYWORD, default=<class 'inspect._empty'>
port:    kind=POSITIONAL_OR_KEYWORD, default=5432
timeout: kind=KEYWORD_ONLY,          default=30
ssl:     kind=KEYWORD_ONLY,          default=False
```

### Parameter kinds

|Kind|Syntax|How it can be passed|
|---|---|---|
|`POSITIONAL_ONLY`|before `/` in signature|positional only|
|`POSITIONAL_OR_KEYWORD`|normal args|either way|
|`VAR_POSITIONAL`|`*args`|captures extra positional|
|`KEYWORD_ONLY`|after `*` or `*args`|keyword only|
|`VAR_KEYWORD`|`**kwargs`|captures extra keyword|

### Binding arguments to a signature

```python
sig = inspect.signature(connect)
bound = sig.bind("localhost", timeout=10)
bound.apply_defaults()
print(bound.arguments)
# {'host': 'localhost', 'port': 5432, 'timeout': 10, 'ssl': False}
```

`bind()` does exactly what the VM does when calling a function — maps positional and keyword arguments to parameter names, raising `TypeError` on mismatch. Useful for validating calls before making them.

---

## Source Code

```python
import inspect

def add(x, y):
    # adds two things
    return x + y

print(inspect.getsource(add))
print(inspect.getsourcefile(add))   # path to the .py file
print(inspect.getsourcelines(add))  # (list of lines, start line number)
```

Works on functions, classes, methods, and modules — anything that was defined in a `.py` file. Raises `OSError` for built-ins or objects defined in the REPL (no source file to read from).

---

## Function Internals

```python
import inspect

def outer(x):
    def inner(y):
        return x + y
    return inner

f = outer(10)

print(inspect.isfunction(f))          # True
print(inspect.isbuiltin(len))         # True
print(inspect.ismethod(str.upper))    # False (unbound)

# Closure variables
closure_vars = inspect.getclosurevars(f)
print(closure_vars.nonlocals)         # {'x': 10}
print(closure_vars.globals)           # {} (none used)
print(closure_vars.builtins)          # {} (none used)
```

`getclosurevars()` resolves the actual _values_ currently in the closure cells — not just that cells exist, but what they contain right now.

---

## The Call Stack and Frames

This is where `inspect` becomes uniquely powerful. The **call stack** is the sequence of active function calls at any moment. Each call has a **frame** — an object holding that call's local variables, the code being executed, and a pointer to the caller's frame.

```python
import inspect

def third():
    stack = inspect.stack()
    for frame_info in stack:
        print(f"{frame_info.function}() at {frame_info.filename}:{frame_info.lineno}")

def second():
    third()

def first():
    second()

first()
```

Output:

```
third()  at script.py:4
second() at script.py:10
first()  at script.py:13
<module> at script.py:16
```

### `FrameInfo` fields

Each entry in `inspect.stack()` is a `FrameInfo`:

|Field|Contains|
|---|---|
|`frame`|The live frame object|
|`filename`|Source file path|
|`lineno`|Current line number|
|`function`|Function name|
|`code_context`|List of source lines around current line|
|`index`|Which line in `code_context` is current|

### The frame object itself

```python
import inspect

def examine():
    frame = inspect.currentframe()
    print(frame.f_locals)     # local variables dict
    print(frame.f_globals)    # module global dict
    print(frame.f_code)       # the code object
    print(frame.f_back)       # the caller's frame
    print(frame.f_lineno)     # current line number

x = 42
examine()
```

`frame.f_locals` is a **snapshot** — for optimized functions, modifying it does not affect actual locals. `frame.f_globals` is the real dict and writes do take effect.

### `inspect.currentframe()` vs `inspect.stack()`

||`currentframe()`|`stack()`|
|---|---|---|
|Returns|One frame object|List of FrameInfo for entire stack|
|Cost|Very cheap|More expensive (reads source files)|
|Use for|Getting your own frame|Understanding the full call context|

---

## Classes and Inheritance

```python
import inspect

class Animal:
    def speak(self): pass

class Dog(Animal):
    def speak(self):
        return "woof"
    
    def fetch(self):
        return "fetching"

print(inspect.getmembers(Dog, predicate=inspect.isfunction))
# [('fetch', <function Dog.fetch ...>), ('speak', <function Dog.speak ...>)]

print(inspect.getmro(Dog))
# (<class 'Dog'>, <class 'Animal'>, <class 'object'>)

print(inspect.classify_class_attrs(Dog))
# detailed list of every attribute: name, kind, defining class, object
```

### `getmembers()` predicates

```python
inspect.isfunction       # regular def functions
inspect.ismethod         # bound methods
inspect.isclass          # class objects
inspect.ismodule         # module objects
inspect.isbuiltin        # built-in functions (C-level)
inspect.isdatadescriptor # descriptors with __set__ (like property)
inspect.isgetsetdescriptor
inspect.ismethoddescriptor
```

### Checking where an attribute actually comes from

```python
for name, kind, defining_class, obj in inspect.classify_class_attrs(Dog):
    if name == 'speak':
        print(f"defined in: {defining_class}")  # <class 'Dog'>

# compare with an inherited method:
for name, kind, defining_class, obj in inspect.classify_class_attrs(Dog):
    if name == '__init__':
        print(f"defined in: {defining_class}")  # <class 'object'>
```

---

## Modules

```python
import inspect
import os.path

print(inspect.ismodule(os.path))         # True
print(inspect.getfile(os.path))          # path to posixpath.py or ntpath.py
print(inspect.getmodule(os.path.join))   # the module an object belongs to

# All members of a module
for name, obj in inspect.getmembers(os.path, inspect.isfunction):
    print(name)
```

---

## Abstract Base Class and Generator Checks

```python
import inspect

def gen():
    yield 1
    yield 2

async def coro():
    pass

print(inspect.isgeneratorfunction(gen))    # True
print(inspect.isgenerator(gen()))          # True — the live generator object
print(inspect.iscoroutinefunction(coro))   # True
print(inspect.isawaitable(coro()))         # True
```

The distinction between `isgeneratorfunction` (checks the function) and `isgenerator` (checks a live instance) matters: `gen` is a generator function, `gen()` is a generator object.

---

## Practical Patterns

### A decorator that logs its call site

```python
import inspect

def traced(func):
    def wrapper(*args, **kwargs):
        caller = inspect.stack()[1]
        print(f"  called from {caller.function}() line {caller.lineno}")
        return func(*args, **kwargs)
    return wrapper

@traced
def add(x, y):
    return x + y

def main():
    result = add(1, 2)

main()
# called from main() line 13
```

### Validate arguments against a signature at runtime

```python
import inspect

def strict_call(func, *args, **kwargs):
    sig = inspect.signature(func)
    try:
        sig.bind(*args, **kwargs)
    except TypeError as e:
        raise TypeError(f"Bad call to {func.__name__}: {e}") from None
    return func(*args, **kwargs)

def connect(host, port):
    pass

strict_call(connect, "localhost", 5432)   # fine
strict_call(connect, "localhost")         # TypeError: Bad call to connect: ...
```

### Find all subclasses currently in memory

```python
import inspect, sys

def all_subclasses_of(cls):
    return [
        obj for name, obj in inspect.getmembers(sys.modules[__name__], inspect.isclass)
        if issubclass(obj, cls) and obj is not cls
    ]
```

---

## What `inspect` Cannot Do

|Limitation|Reason|
|---|---|
|Can't read source for built-ins|Defined in C, no `.py` file|
|Can't read source for REPL-defined objects|No file to read|
|`f_locals` writes don't affect optimized frames|CPython copies locals into a C array for speed|
|Stack inspection has a cost|Reading source context requires file I/O|
|Can't inspect across threads reliably|Frame pointers can change between reads|

---

## Module at a Glance

```
# Source
inspect.getsource()          object → source string
inspect.getsourcefile()      object → .py path
inspect.getsourcelines()     object → (lines, lineno)

# Signatures
inspect.signature()          function → Signature object
  sig.parameters             OrderedDict of Parameter objects
  sig.bind(*args, **kwargs)  → BoundArguments (validates call)

# Functions / closures
inspect.getclosurevars()     function → resolved closure values
inspect.isfunction/ismethod/isbuiltin/isclass/ismodule...

# Stack / frames
inspect.currentframe()       → current frame object
inspect.stack()              → list of FrameInfo (full call stack)
inspect.getframeinfo()       frame → FrameInfo

# Classes
inspect.getmembers()         object, predicate → [(name, value)]
inspect.getmro()             class → tuple of classes in MRO order
inspect.classify_class_attrs() → name, kind, defining class, object
```

The three modules together give you complete visibility at every layer:

```
ast      — what your code means as syntax, before execution
dis      — what the VM will execute as instructions
inspect  — what exists in memory while it runs
```

---

# CPython Source: `Objects/funcobject.c`

This is the C implementation of Python function objects — what actually exists in memory when you write `def`. Everything `dis` and `inspect` show you from Python-land is backed by this.

---

## Getting the Source

```bash
# Clone CPython
git clone https://github.com/python/cpython.git
cd cpython

# The file
Objects/funcobject.c      # function object implementation
Include/cpython/funcobject.h  # the struct definition
Objects/codeobject.c      # the code object (func.__code__)
```

Or read it online: `https://github.com/python/cpython/blob/main/Objects/funcobject.c`

---

## The Struct: What a Function Actually Is

In `Include/cpython/funcobject.h`:

```c
typedef struct {
    PyObject_HEAD

    PyObject *func_code;        /* A code object — the bytecode */
    PyObject *func_globals;     /* The module's __dict__ */
    PyObject *func_defaults;    /* Default arg values, or NULL */
    PyObject *func_kwdefaults;  /* Keyword-only defaults, or NULL */
    PyObject *func_closure;     /* Tuple of cells, or NULL */
    PyObject *func_doc;         /* The docstring */
    PyObject *func_name;        /* __name__ — a string */
    PyObject *func_dict;        /* __dict__ — the function's attribute dict */
    PyObject *func_weakreflist; /* For weakref support */
    PyObject *func_module;      /* __module__ */
    PyObject *func_annotations; /* __annotations__ dict */
    PyObject *func_typeparams;  /* PEP 695 type parameters */
    vectorcallfunc vectorcall;  /* fast call path */

    int func_version;           /* For specializing call sites */
} PyFunctionObject;
```

This struct **is** the function object. When Python does `def foo(): ...`, it allocates one of these on the heap and fills in the fields. Every attribute you access in Python maps directly to a field here:

|Python|C field|
|---|---|
|`foo.__code__`|`func_code`|
|`foo.__globals__`|`func_globals`|
|`foo.__defaults__`|`func_defaults`|
|`foo.__closure__`|`func_closure`|
|`foo.__name__`|`func_name`|
|`foo.__doc__`|`func_doc`|
|`foo.__annotations__`|`func_annotations`|

### `PyObject_HEAD`

Every Python object starts with this macro. It expands to:

```c
Py_ssize_t ob_refcnt;     /* reference count */
PyTypeObject *ob_type;    /* pointer to the type object */
```

This is how Python knows the type of anything at runtime, and how garbage collection works — when `ob_refcnt` drops to zero, the object is freed.

---

## Creating a Function: `PyFunction_NewWithQualName`

When the VM executes a `MAKE_FUNCTION` bytecode instruction, this is what it calls:

```c
PyObject *
PyFunction_NewWithQualName(PyObject *code, PyObject *globals,
                           PyObject *qualname)
{
    PyFunctionObject *op;

    // 1. Allocate the struct
    op = PyObject_GC_New(PyFunctionObject, &PyFunction_Type);
    if (op == NULL)
        return NULL;

    // 2. Store the code object
    op->func_code = Py_NewRef(code);

    // 3. Store the globals dict (the module's __dict__)
    op->func_globals = Py_NewRef(globals);

    // 4. Pull the name out of the code object
    op->func_name = ((PyCodeObject *)code)->co_name;
    Py_INCREF(op->func_name);

    // 5. Qualname (e.g. "OuterClass.method")
    op->func_qualname = qualname ? qualname : op->func_name;
    Py_INCREF(op->func_qualname);

    // 6. Pull docstring from first constant in code object
    PyObject *consts = ((PyCodeObject *)code)->co_consts;
    PyObject *first = PyTuple_GetItem(consts, 0);
    op->func_doc = (PyUnicode_Check(first)) ? Py_NewRef(first) : Py_NewRef(Py_None);

    // 7. Everything else starts NULL
    op->func_defaults    = NULL;
    op->func_kwdefaults  = NULL;
    op->func_closure     = NULL;
    op->func_annotations = NULL;
    op->func_dict        = NULL;

    // 8. Register with garbage collector
    PyObject_GC_Track(op);

    return (PyObject *)op;
}
```

The key insight: **a function is just a code object + a globals dict, wrapped in a struct.** The code object is shared — every call to `make_counter()` creates a new function object, but they all reference the _same_ code object. Only the closure cells differ.

---

## The Code Object

`func_code` points to a `PyCodeObject` (in `Include/cpython/code.h`):

```c
typedef struct {
    PyObject_HEAD

    int co_argcount;          /* positional arg count */
    int co_posonlyargcount;   /* positional-only args (before /) */
    int co_kwonlyargcount;    /* keyword-only args (after *) */
    int co_nlocals;           /* number of local variables */
    int co_stacksize;         /* max stack depth needed */
    int co_flags;             /* CO_NESTED, CO_VARARGS, etc. */

    PyObject *co_consts;      /* tuple of constants (literals) */
    PyObject *co_names;       /* tuple of names used */
    PyObject *co_localsplusnames;  /* local + cell + free var names */
    PyObject *co_filename;    /* source file */
    PyObject *co_name;        /* function name */
    PyObject *co_qualname;    /* qualified name */

    PyObject *co_code;        /* bytes — the actual bytecode */
    PyObject *co_linetable;   /* maps bytecode offsets → line numbers */

    /* ... more fields ... */
} PyCodeObject;
```

This is what `dis` reads. `co_code` is the raw bytes of instructions. `co_consts` is why `LOAD_CONST 0` means "load the first thing in this tuple." `co_linetable` is how Python produces tracebacks with line numbers.

---

## Closure Cells: `cellobject.c`

Closure variables don't live directly in the function struct. They live in **cell objects**, defined in `Objects/cellobject.c`:

```c
typedef struct {
    PyObject_HEAD
    PyObject *ob_ref;    /* the actual value, or NULL if unset */
} PyCellObject;
```

That's it. A cell is a pointer to a value, wrapped in a Python object so it can be shared.

When the compiler determines a variable is captured by an inner function, it emits `MAKE_CELL` and `LOAD_DEREF`/`STORE_DEREF` instead of `LOAD_FAST`/`STORE_FAST`. Both the outer and inner function's `func_closure` tuple point to the **same** cell object.

```
outer's frame          inner's func_closure
  [cell for x] ──────────► [PyCellObject]
                                  │
                             ob_ref = 10
```

When `outer` writes `x = 10`, it writes into `ob_ref`. When `inner` reads `x`, it reads from the same `ob_ref`. When `outer`'s frame is destroyed, the cell lives on because `inner` still holds a reference to it.

---

## Attribute Access: The `tp_getattro` Slot

How does `foo.__code__` work? The function type defines a **getset table** — a list of attribute names mapped to getter/setter C functions:

```c
static PyGetSetDef func_getsetlist[] = {
    {"__code__",     func_get_code, func_set_code,     NULL},
    {"__defaults__", func_get_defaults, func_set_defaults, NULL},
    {"__closure__",  func_get_closure, func_set_closure,   NULL},
    {"__globals__",  func_get_globals, NULL, NULL},   /* read-only */
    {"__annotations__", func_get_annotations, func_set_annotations, NULL},
    {"__dict__",     func_get_dict, func_set_dict, NULL},
    {"__name__",     func_get_name, func_set_name, NULL},
    {NULL}   /* sentinel */
};
```

Each getter is a C function that receives the `PyFunctionObject*` and returns the appropriate field:

```c
static PyObject *
func_get_code(PyFunctionObject *op, void *Py_UNUSED(ignored))
{
    if (PySys_Audit("object.__getattr__", "Os", op, "__code__") < 0) {
        return NULL;
    }
    return Py_NewRef(op->func_code);
}
```

`func_set_code` does the write — it validates the new value is actually a code object, then swaps the pointer:

```c
static int
func_set_code(PyFunctionObject *op, PyObject *value, void *Py_UNUSED(ignored))
{
    /* Not legal to del f.__code__ */
    if (value == NULL || !PyCode_Check(value)) {
        PyErr_SetString(PyExc_TypeError, "__code__ must be set to a code object");
        return -1;
    }
    /* ... additional validation ... */
    Py_XSETREF(op->func_code, Py_NewRef(value));
    return 0;
}
```

`Py_XSETREF` decrements the old object's refcount (possibly freeing it) and stores the new pointer. This is the mechanism behind `foo.__code__ = bar.__code__` — you can swap bytecode at runtime because it's just a pointer swap in a struct.

---

## Calling a Function: `func_vectorcall`

When the VM executes `CALL`, it eventually reaches:

```c
static PyObject *
func_vectorcall(PyObject *func, PyObject *const *stack,
                size_t nargsf, PyObject *kwnames)
{
    PyFunctionObject *f = (PyFunctionObject *)func;
    PyCodeObject *co = (PyCodeObject *)f->func_code;
    Py_ssize_t nargs = PyVectorcall_NARGS(nargsf);

    // 1. Create a new frame for this call
    PyFrameObject *frame = _PyEval_MakeFrameVector(
        tstate, co, f->func_globals, f->func_closure,
        stack, nargs, kwnames
    );
    if (frame == NULL) return NULL;

    // 2. Push frame onto the call stack and execute
    return _PyEval_EvalFrame(tstate, frame, 0);
}
```

The frame is a new `PyFrameObject` that holds:

- The code object being executed
- The globals dict
- The closure cells
- The local variables (as a C array, not a Python dict — for speed)
- The value stack
- A pointer back to the calling frame

`_PyEval_EvalFrame` is the main interpreter loop — a massive `switch` statement over opcodes in `Python/ceval.c`. It reads one instruction at a time from `co_code` and executes it.

---

## Reference Counting: The Memory Model

Every `Py_NewRef`, `Py_INCREF`, `Py_DECREF`, `Py_XSETREF` you see in the source is reference counting. The rules are mechanical:

- Every time you store a pointer to an object, call `Py_INCREF` (or `Py_NewRef` which returns it)
- Every time you're done with a pointer, call `Py_DECREF`
- When `ob_refcnt` hits zero, CPython calls the type's `tp_dealloc` to free the memory

For `PyFunctionObject`, `tp_dealloc` is:

```c
static void
func_dealloc(PyFunctionObject *op)
{
    PyObject_GC_UnTrack(op);         // remove from GC tracking
    Py_DECREF(op->func_code);        // release code object
    Py_DECREF(op->func_globals);     // release globals dict
    Py_XDECREF(op->func_defaults);   // release defaults if any
    Py_XDECREF(op->func_kwdefaults);
    Py_XDECREF(op->func_closure);    // release closure cells
    Py_XDECREF(op->func_doc);
    Py_DECREF(op->func_name);
    Py_DECREF(op->func_qualname);
    Py_XDECREF(op->func_dict);
    Py_XDECREF(op->func_annotations);
    PyObject_GC_Del(op);             // free the memory
}
```

`Py_XDECREF` (vs `Py_DECREF`) handles `NULL` safely — used for fields that may not be set.

---

## The Type Object: `PyFunction_Type`

Every Python type is itself a C struct — `PyTypeObject`. The function type is:

```c
PyTypeObject PyFunction_Type = {
    PyVarObject_HEAD_INIT(&PyType_Type, 0)
    "function",                         /* tp_name */
    sizeof(PyFunctionObject),           /* tp_basicsize */
    0,                                  /* tp_itemsize */
    (destructor)func_dealloc,           /* tp_dealloc */
    offsetof(PyFunctionObject,vectorcall), /* tp_vectorcall_offset */
    0,                                  /* tp_getattr */
    0,                                  /* tp_setattr */
    0,                                  /* tp_as_async */
    (reprfunc)func_repr,                /* tp_repr */
    0,                                  /* tp_as_number */
    0,                                  /* tp_as_sequence */
    0,                                  /* tp_as_mapping */
    0,                                  /* tp_hash */
    PyObject_GenericGetAttr,            /* tp_getattro */
    PyObject_GenericSetAttr,            /* tp_setattro */
    /* ... */
    func_getsetlist,                    /* tp_getset */
    /* ... */
    func_new,                           /* tp_new */
};
```

The slots in this struct are **the protocol**. `tp_call` is how `foo()` works. `tp_repr` is how `repr(foo)` works. `tp_getattro` is how `foo.x` works. Every "magic" Python behavior is one of these slots in the type object.

---

## The Full Picture

```
def foo(x):           Python source
    return x + 1
        │
        ▼
  MAKE_FUNCTION       bytecode instruction
        │
        ▼
PyFunction_NewWithQualName()     C function
        │
        ▼
  PyFunctionObject {             heap-allocated C struct
    func_code     ──────────► PyCodeObject { co_code: b'...', co_consts: (...) }
    func_globals  ──────────► module's __dict__
    func_closure  ──────────► NULL  (or tuple of PyCellObjects)
    func_name     ──────────► "foo"
    ...
  }
        │
        ▼
  STORE_NAME "foo"    bytecode instruction
        │
  globals()["foo"] = the PyFunctionObject
```

`foo` in your Python code is a key in a dictionary. The value is a `PyFunctionObject` on the heap. The function's behavior lives in `func_code`. Its data access lives in `func_globals` and `func_closure`. Calling it allocates a new `PyFrameObject` and enters the eval loop.

There is no magic — only structs, pointers, and reference counts.

---