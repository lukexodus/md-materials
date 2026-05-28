# PyYAML Comprehensive Guide

## Overview

PyYAML is the most widely used YAML parser and emitter library for Python. It supports YAML 1.1 and provides tools for loading, dumping, and customizing YAML serialization.

Install it with:

```bash
pip install pyyaml
```

Import convention:

```python
import yaml
```

---

## YAML Basics Refresher

YAML (YAML Ain't Markup Language) is a human-readable data serialization format. Key structural rules:

- Indentation defines nesting (spaces only, no tabs)
- `:` separates keys and values in mappings
- `-` denotes list items
- `#` starts a comment
- Strings generally don't need quotes, but quotes handle special characters

```yaml
name: Alice
age: 30
active: true
scores:
  - 95
  - 87
  - 100
address:
  city: Manila
  country: Philippines
```

---

## Loading YAML

### `yaml.safe_load()`

The recommended function for loading untrusted or general-purpose YAML. Deserializes only basic Python types.

```python
import yaml

data = yaml.safe_load("""
name: Alice
age: 30
tags:
  - admin
  - user
""")

print(data)
# {'name': 'Alice', 'age': 30, 'tags': ['admin', 'user']}
```

### `yaml.safe_load_all()`

Loads a YAML stream containing multiple documents separated by `---`.

```python
docs = list(yaml.safe_load_all("""
---
name: Alice
---
name: Bob
"""))
# [{'name': 'Alice'}, {'name': 'Bob'}]
```

### `yaml.load()` — Use With Caution

Requires an explicit `Loader` argument. Without a safe loader, it can execute arbitrary Python code embedded in YAML, which is a known security risk.

```python
# Unsafe — do not use with untrusted input
data = yaml.load(content, Loader=yaml.FullLoader)

# Safer alternatives for the Loader argument:
# yaml.SafeLoader      — basic types only, recommended for untrusted input
# yaml.FullLoader      — default since PyYAML 5.1, handles most cases safely
# yaml.UnsafeLoader    — allows Python-specific tags, dangerous with untrusted input
# yaml.BaseLoader      — loads everything as strings
```

Loader comparison:

|Loader|Python objects|Safe for untrusted input|
|---|---|---|
|`SafeLoader`|No|Yes|
|`FullLoader`|Partial|Generally yes|
|`UnsafeLoader`|Yes|No|
|`BaseLoader`|No (strings only)|Yes|

### Loading from a File

```python
with open("config.yaml", "r") as f:
    data = yaml.safe_load(f)
```

---

## Dumping YAML

### `yaml.dump()`

Serializes a Python object to a YAML string.

```python
data = {"name": "Alice", "age": 30, "tags": ["admin", "user"]}

output = yaml.dump(data)
print(output)
# age: 30
# name: Alice
# tags:
# - admin
# - user
```

Keys are sorted alphabetically by default.

### Common `dump()` Parameters

```python
yaml.dump(
    data,
    default_flow_style=False,   # block style (True = inline/JSON-like style)
    indent=4,                   # indentation spaces
    sort_keys=False,            # preserve insertion order
    allow_unicode=True,         # write unicode characters directly
    width=80,                   # line wrap width
    explicit_start=True,        # prepend ---
    explicit_end=True,          # append ...
)
```

#### Flow style vs block style

```python
data = {"a": [1, 2, 3]}

yaml.dump(data, default_flow_style=True)
# {a: [1, 2, 3]}

yaml.dump(data, default_flow_style=False)
# a:
# - 1
# - 2
# - 3
```

### `yaml.dump_all()`

Dumps multiple documents into one stream.

```python
docs = [{"name": "Alice"}, {"name": "Bob"}]
output = yaml.dump_all(docs, explicit_start=True)
print(output)
# --- 
# name: Alice
# ---
# name: Bob
```

### Dumping to a File

```python
with open("output.yaml", "w") as f:
    yaml.dump(data, f, default_flow_style=False)
```

---

## Type Handling

### Python ↔ YAML Type Mapping

|Python type|YAML representation|
|---|---|
|`str`|scalar string|
|`int`|integer|
|`float`|float|
|`bool`|`true` / `false`|
|`None`|`null` or `~`|
|`list`|sequence|
|`dict`|mapping|
|`datetime.date`|date scalar|
|`datetime.datetime`|timestamp scalar|

### Scalars and Edge Cases

```python
# Booleans: PyYAML (YAML 1.1) treats these as bool
# yes, no, on, off, true, false, True, False — all parsed as bool

yaml.safe_load("value: yes")   # {'value': True}
yaml.safe_load("value: no")    # {'value': False}
yaml.safe_load("value: 'no'")  # {'value': 'no'}  — quoted = string

# Nulls
yaml.safe_load("value: ~")     # {'value': None}
yaml.safe_load("value: null")  # {'value': None}

# Octal (YAML 1.1 quirk in PyYAML)
yaml.safe_load("value: 0777")  # {'value': 511}  — parsed as octal
```

This octal and boolean behavior reflects YAML 1.1, which PyYAML implements. It differs from YAML 1.2. Keep this in mind when migrating configs from other parsers.

### Dates and Datetimes

```python
result = yaml.safe_load("date: 2024-01-15")
# {'date': datetime.date(2024, 1, 15)}

result = yaml.safe_load("ts: 2024-01-15 10:30:00")
# {'ts': datetime.datetime(2024, 1, 15, 10, 30)}
```

To prevent auto-conversion of dates, quote them:

```yaml
date: "2024-01-15"
```

---

## Multiline Strings

### Literal Block Scalar (`|`)

Preserves newlines exactly.

```yaml
message: |
  Line one
  Line two
  Line three
```

```python
# {'message': 'Line one\nLine two\nLine three\n'}
```

### Folded Block Scalar (`>`)

Folds newlines into spaces (single newlines become spaces; blank lines become newlines).

```yaml
message: >
  This is a long
  sentence that will
  be joined.
```

```python
# {'message': 'This is a long sentence that will be joined.\n'}
```

### Chomping Indicators

Appended to `|` or `>` to control trailing newlines:

|Indicator|Behavior|
|---|---|
|`|` (default)|
|`|-`|
|`|+`|

```yaml
a: |
  text

b: |-
  text

c: |+
  text

```

---

## Anchors and Aliases

YAML anchors (`&`) define a reusable node; aliases (`*`) reference it.

```yaml
defaults: &defaults
  timeout: 30
  retries: 3

production:
  <<: *defaults
  host: prod.example.com

staging:
  <<: *defaults
  host: staging.example.com
```

```python
data = yaml.safe_load(content)
# production and staging both inherit timeout and retries
```

The `<<` merge key is a YAML 1.1 feature supported by PyYAML's SafeLoader.

---

## Custom Tags and Constructors

### Defining a Custom Class

```python
import yaml

class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    def __repr__(self):
        return f"Point(x={self.x}, y={self.y})"
```

### Registering a Constructor (loading)

```python
def point_constructor(loader, node):
    values = loader.construct_mapping(node)
    return Point(**values)

yaml.add_constructor("!point", point_constructor, Loader=yaml.SafeLoader)

data = yaml.safe_load("""
location: !point
  x: 10
  y: 20
""")
print(data["location"])  # Point(x=10, y=20)
```

### Registering a Representer (dumping)

```python
def point_representer(dumper, obj):
    return dumper.represent_mapping("!point", {"x": obj.x, "y": obj.y})

yaml.add_representer(Point, point_representer)

p = Point(10, 20)
print(yaml.dump({"location": p}))
# location: !point
#   x: 10
#   y: 20
```

---

## Custom Loaders and Dumpers

For isolated customization without modifying global state, subclass the built-in loaders or dumpers.

```python
class CustomLoader(yaml.SafeLoader):
    pass

def my_constructor(loader, node):
    return loader.construct_scalar(node).upper()

CustomLoader.add_constructor("!upper", my_constructor)

data = yaml.load("word: !upper hello", Loader=CustomLoader)
# {'word': 'HELLO'}
```

This pattern is preferable to `yaml.add_constructor()` when you need to avoid affecting other parts of your application.

---

## Handling Special Characters and Encoding

### Unicode

```python
data = {"city": "Zürich", "emoji": "✓"}
print(yaml.dump(data, allow_unicode=True))
# city: Zürich
# emoji: ✓

print(yaml.dump(data, allow_unicode=False))
# city: "Z\xFCrich"
# emoji: "\u2713"
```

### Reading Files with Explicit Encoding

```python
with open("config.yaml", "r", encoding="utf-8") as f:
    data = yaml.safe_load(f)
```

---

## Error Handling

### Common Exceptions

|Exception|When it occurs|
|---|---|
|`yaml.YAMLError`|Base class for all PyYAML errors|
|`yaml.scanner.ScannerError`|Malformed YAML syntax|
|`yaml.parser.ParserError`|Structural parsing error|
|`yaml.constructor.ConstructorError`|Type construction failure|

### Catching Errors

```python
try:
    data = yaml.safe_load(content)
except yaml.YAMLError as e:
    print(f"YAML error: {e}")
    if hasattr(e, "problem_mark"):
        mark = e.problem_mark
        print(f"  Line {mark.line + 1}, column {mark.column + 1}")
```

---

## Security Considerations

### Never Use `yaml.load()` Without a Safe Loader on Untrusted Input

PyYAML's `UnsafeLoader` (and the old default behavior before 5.1) allows YAML files to execute arbitrary Python code via tags like `!!python/object/apply`.

Example of a malicious payload — do not run:

```yaml
!!python/object/apply:os.system
- "rm -rf /"
```

Safe practices:

- Use `yaml.safe_load()` for all untrusted input
- If you need custom types, register them on a `SafeLoader` subclass
- Never use `Loader=yaml.UnsafeLoader` or the legacy `yaml.load(data)` (no Loader) in production

---

## Working with Streams and StringIO

```python
import io
import yaml

# Write to a string buffer
buf = io.StringIO()
yaml.dump({"key": "value"}, buf)
buf.seek(0)
print(buf.read())

# Read from a string buffer
source = io.StringIO("name: Alice\nage: 30")
data = yaml.safe_load(source)
```

---

## Practical Patterns

### Config File Pattern

```python
import yaml
from pathlib import Path

def load_config(path: str) -> dict:
    config_path = Path(path)
    if not config_path.exists():
        raise FileNotFoundError(f"Config not found: {path}")
    with config_path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}

config = load_config("config.yaml")
```

### Round-Trip Preservation

PyYAML does not preserve comments, key order (without `sort_keys=False`), or formatting on round-trip. For round-trip fidelity including comments, consider `ruamel.yaml` instead.

```python
# With PyYAML, comments are lost
data = yaml.safe_load("# My comment\nname: Alice")
print(yaml.dump(data))
# name: Alice
# (comment gone)
```

### Merging Multiple YAML Files

```python
def merge_yaml_files(*paths):
    merged = {}
    for path in paths:
        with open(path) as f:
            data = yaml.safe_load(f) or {}
            merged.update(data)
    return merged
```

### Environment Variable Interpolation

PyYAML does not natively support `${VAR}` substitution. You handle it manually:

```python
import os
import re
import yaml

def interpolate_env(content: str) -> str:
    return re.sub(
        r"\$\{(\w+)\}",
        lambda m: os.environ.get(m.group(1), m.group(0)),
        content
    )

with open("config.yaml") as f:
    raw = f.read()

data = yaml.safe_load(interpolate_env(raw))
```

---

## Comparison with Related Libraries

|Feature|PyYAML|ruamel.yaml|strictyaml|
|---|---|---|---|
|YAML version|1.1|1.2|Subset|
|Preserves comments|No|Yes|N/A|
|Round-trip safe|No|Yes|Yes|
|Strict typing|No|No|Yes|
|Custom tags|Yes|Yes|No|
|Active maintenance|Moderate|Active|Active|

Use `ruamel.yaml` when you need comment preservation or YAML 1.2 compliance. Use `strictyaml` when you want schema validation and rejection of implicit typing.

---

## Quick Reference

```python
import yaml

# Load
data = yaml.safe_load(string_or_file)
docs = list(yaml.safe_load_all(multi_doc_stream))

# Dump
string = yaml.dump(data, default_flow_style=False, sort_keys=False, allow_unicode=True)
yaml.dump(data, file_object)

# Multiple docs
yaml.dump_all([doc1, doc2], explicit_start=True)

# Custom tag constructor
yaml.add_constructor("!tag", fn, Loader=yaml.SafeLoader)

# Custom representer
yaml.add_representer(MyClass, fn)

# Error handling
try:
    yaml.safe_load(content)
except yaml.YAMLError as e:
    handle(e)
```

