# Jinja2: A Comprehensive Guide

Jinja2 is a fast, expressive, and extensible templating engine for Python. It allows you to embed logic and dynamic content into plain-text files — most commonly HTML, but also XML, CSV, Markdown, configuration files, and more. It is maintained as part of the Pallets Projects ecosystem (the same group that maintains Flask).

---

## Installation

Install Jinja2 using pip:

```bash
pip install Jinja2
```

Verify the installation:

```python
import jinja2
print(jinja2.__version__)
```

Jinja2 requires Python 3.7 or later (as of Jinja2 3.x).

---

## Core Concepts

Jinja2 separates a **template** (a text file with special markup) from a **rendering context** (a Python dictionary or object that supplies values). When a template is rendered, Jinja2 replaces the markup with values from the context and evaluates any embedded logic.

There are three primary delimiter types:

- `{{ ... }}` — **Expressions**: output the result of an expression.
- `{% ... %}` — **Statements**: control flow, assignments, macros, etc.
- `{# ... #}` — **Comments**: not included in output.

---

## Environment and Template Loading

### The Environment Object

The `Environment` class is the central configuration object. All templates are loaded through an environment.

```python
from jinja2 import Environment, FileSystemLoader

env = Environment(
    loader=FileSystemLoader("templates/"),
    autoescape=True
)
```

Key constructor parameters:

- `loader` — how templates are found (see Loaders section).
- `autoescape` — if `True` or a callable, escapes HTML in output automatically.
- `undefined` — class used for undefined variables (default: `Undefined`).
- `trim_blocks` — removes the first newline after a block tag if `True`.
- `lstrip_blocks` — strips leading whitespace from block tags if `True`.
- `keep_trailing_newline` — preserves trailing newline in template source.
- `extensions` — list of Jinja2 extensions to load.
- `finalize` — a callable applied to every expression output before rendering.

### Loading and Rendering a Template

```python
template = env.get_template("index.html")
output = template.render(name="Alice", items=[1, 2, 3])
print(output)
```

### Rendering from a String

```python
from jinja2 import Environment

env = Environment()
template = env.from_string("Hello, {{ name }}!")
print(template.render(name="World"))
```

---

## Loaders

Loaders are responsible for finding and loading template source code.

### FileSystemLoader

Loads templates from the filesystem.

```python
from jinja2 import FileSystemLoader

loader = FileSystemLoader("templates/")
# Or multiple directories (searched in order):
loader = FileSystemLoader(["templates/", "fallback_templates/"])
```

### PackageLoader

Loads templates from a Python package directory.

```python
from jinja2 import PackageLoader

loader = PackageLoader("mypackage", "templates")
```

### DictLoader

Loads templates from a Python dictionary — useful for testing.

```python
from jinja2 import DictLoader

loader = DictLoader({
    "index.html": "Hello, {{ name }}!",
    "base.html": "{% block content %}{% endblock %}"
})
```

### BaseLoader (Custom Loader)

Subclass `BaseLoader` and implement `get_source()` to build a custom loader.

```python
from jinja2 import BaseLoader, TemplateNotFound

class MyLoader(BaseLoader):
    def get_source(self, environment, template):
        # Return (source, filename, uptodate_callable)
        raise TemplateNotFound(template)
```

### ChoiceLoader

Tries loaders in sequence.

```python
from jinja2 import ChoiceLoader

loader = ChoiceLoader([loader1, loader2])
```

### PrefixLoader

Routes to different loaders based on a prefix.

```python
from jinja2 import PrefixLoader

loader = PrefixLoader({
    "admin": FileSystemLoader("admin_templates/"),
    "public": FileSystemLoader("public_templates/"),
})
# Use as: env.get_template("admin/dashboard.html")
```

---

## Variables and Expressions

### Accessing Variables

```jinja2
{{ username }}
{{ user.name }}
{{ user['name'] }}
{{ items[0] }}
```

Dot notation and subscript notation are mostly interchangeable when accessing object attributes and dictionary keys.

### Python Literals in Expressions

Jinja2 supports most Python literal types directly:

```jinja2
{{ "hello" }}
{{ 42 }}
{{ 3.14 }}
{{ True }}
{{ None }}
{{ [1, 2, 3] }}
{{ {"key": "value"} }}
{{ (1, 2) }}
```

### Arithmetic Operators

```jinja2
{{ 4 + 2 }}   {# 6 #}
{{ 4 - 2 }}   {# 2 #}
{{ 4 * 2 }}   {# 8 #}
{{ 4 / 2 }}   {# 2.0 (float division) #}
{{ 4 // 2 }}  {# 2 (integer division) #}
{{ 4 % 2 }}   {# 0 (modulo) #}
{{ 4 ** 2 }}  {# 16 (exponent) #}
```

### Comparison and Logic Operators

```jinja2
{{ x == y }}
{{ x != y }}
{{ x < y }}
{{ x > y }}
{{ x <= y }}
{{ x >= y }}
{{ x and y }}
{{ x or y }}
{{ not x }}
```

### String Concatenation

```jinja2
{{ "Hello" ~ ", " ~ name ~ "!" }}
```

The `~` operator converts both operands to strings before joining.

### Ternary (Inline If)

```jinja2
{{ "yes" if condition else "no" }}
```

---

## Filters

Filters transform a value. They are applied with the pipe `|` character.

### Built-in Filters

#### String Filters

```jinja2
{{ name | upper }}           {# ALICE #}
{{ name | lower }}           {# alice #}
{{ name | title }}           {# Alice Smith #}
{{ name | capitalize }}      {# Alice #}
{{ name | trim }}            {# strips whitespace #}
{{ name | truncate(20) }}    {# truncates with ellipsis #}
{{ name | replace("a","b") }}
{{ name | striptags }}       {# removes HTML tags #}
{{ name | escape }}          {# HTML-escapes: &, <, >, etc. #}
{{ name | e }}               {# shorthand for escape #}
{{ name | safe }}            {# marks string as safe, disables autoescaping #}
{{ name | wordcount }}
{{ name | wordwrap(40) }}
{{ name | center(40) }}
{{ name | ljust(40) }}
{{ name | rjust(40) }}
{{ name | urlencode }}
{{ name | forceescape }}
{{ name | xmlattr }}         {# renders a dict as HTML attributes #}
```

#### Number Filters

```jinja2
{{ number | abs }}
{{ number | round }}
{{ number | round(2) }}
{{ number | round(2, 'floor') }}
{{ number | round(2, 'ceil') }}
{{ number | int }}
{{ number | float }}
{{ number | filesizeformat }}  {# e.g., "1.2 MB" #}
```

#### List/Sequence Filters

```jinja2
{{ list | length }}
{{ list | first }}
{{ list | last }}
{{ list | reverse }}
{{ list | sort }}
{{ list | sort(attribute='name') }}
{{ list | unique }}
{{ list | min }}
{{ list | max }}
{{ list | sum }}
{{ list | join(", ") }}
{{ list | join(d=", ", attribute="name") }}
{{ list | map('upper') }}       {# applies filter to each item #}
{{ list | map(attribute='id') }}
{{ list | select('odd') }}      {# select items matching a test #}
{{ list | reject('odd') }}
{{ list | selectattr('active') }}
{{ list | rejectattr('active') }}
{{ list | list }}
{{ list | batch(3) }}           {# groups items into chunks of 3 #}
{{ list | slice(3) }}           {# slices into n lists #}
{{ list | random }}
{{ list | shuffle }}
{{ list | flatten }}
{{ list | count }}
```

#### Dictionary Filters

```jinja2
{{ dict | items }}
{{ dict | keys }}
{{ dict | values }}
{{ dict | dictsort }}
{{ dict | dictsort(by='value') }}
{{ dict | tojson }}
{{ dict | tojson(indent=2) }}
```

#### Miscellaneous Filters

```jinja2
{{ value | default("fallback") }}
{{ value | default("fallback", boolean=True) }}  {# also catches falsy values #}
{{ value | pprint }}     {# pretty-prints for debugging #}
{{ value | string }}
{{ value | list }}
{{ value | bool }}
{{ value | attr('name') }}
{{ value | format("Hello %s") }}
{{ value | indent(4) }}
{{ value | indent(4, first=True) }}
```

### Chaining Filters

Filters can be chained left to right:

```jinja2
{{ name | trim | lower | replace(" ", "_") }}
```

### Filter with Arguments

Some filters accept arguments:

```jinja2
{{ items | join(", ") }}
{{ text | truncate(100, killwords=False, end="...") }}
```

### Custom Filters

Register a custom filter on the environment:

```python
def reverse_string(s):
    return s[::-1]

env.filters["reverse"] = reverse_string
```

Use in a template:

```jinja2
{{ "hello" | reverse }}  {# olleh #}
```

Filters can also accept extra arguments:

```python
def repeat(s, n=2):
    return s * n

env.filters["repeat"] = repeat
```

```jinja2
{{ "hi" | repeat(3) }}  {# hihihi #}
```

---

## Tests

Tests check a value against a condition and return a boolean. They are used with the `is` keyword.

### Built-in Tests

```jinja2
{% if x is defined %}
{% if x is undefined %}
{% if x is none %}
{% if x is string %}
{% if x is number %}
{% if x is integer %}
{% if x is float %}
{% if x is boolean %}
{% if x is sequence %}
{% if x is iterable %}
{% if x is mapping %}
{% if x is callable %}
{% if x is odd %}
{% if x is even %}
{% if x is divisibleby(3) %}
{% if x is sameas y %}
{% if x is escaped %}
{% if x is upper %}
{% if x is lower %}
```

### Custom Tests

```python
def is_palindrome(s):
    return s == s[::-1]

env.tests["palindrome"] = is_palindrome
```

```jinja2
{% if word is palindrome %}Palindrome!{% endif %}
```

---

## Control Structures

### If / Elif / Else

```jinja2
{% if user.admin %}
  <p>Welcome, admin.</p>
{% elif user.moderator %}
  <p>Welcome, moderator.</p>
{% else %}
  <p>Welcome, user.</p>
{% endif %}
```

### For Loops

```jinja2
{% for item in items %}
  <li>{{ item }}</li>
{% endfor %}
```

Loop over a dictionary:

```jinja2
{% for key, value in data.items() %}
  {{ key }}: {{ value }}
{% endfor %}
```

#### Loop Variable

Jinja2 exposes a `loop` variable inside every for block:

|Variable|Description|
|---|---|
|`loop.index`|Current iteration (1-based)|
|`loop.index0`|Current iteration (0-based)|
|`loop.revindex`|Iterations remaining (1-based)|
|`loop.revindex0`|Iterations remaining (0-based)|
|`loop.first`|`True` on first iteration|
|`loop.last`|`True` on last iteration|
|`loop.length`|Total number of items|
|`loop.depth`|Nesting depth (1 = outermost)|
|`loop.depth0`|Nesting depth (0-based)|
|`loop.previtem`|Previous iteration value|
|`loop.nextitem`|Next iteration value|
|`loop.changed(val)`|`True` if val differs from last call|

```jinja2
{% for item in items %}
  {% if loop.first %}<ul>{% endif %}
  <li class="{{ 'odd' if loop.index is odd else 'even' }}">{{ item }}</li>
  {% if loop.last %}</ul>{% endif %}
{% endfor %}
```

#### Else Clause on For

Rendered when the iterable is empty:

```jinja2
{% for item in items %}
  {{ item }}
{% else %}
  No items found.
{% endfor %}
```

#### Recursive Loops

Use `recursive` and `loop.recurse()` to iterate over nested structures:

```jinja2
{% for item in tree recursive %}
  {{ item.name }}
  {% if item.children %}
    {{ loop(item.children) }}
  {% endif %}
{% endfor %}
```

#### Loop Filtering

```jinja2
{% for user in users if user.active %}
  {{ user.name }}
{% endfor %}
```

### While Loops

Jinja2 does not have a `while` loop. Iteration must be over a finite sequence.

### Break and Continue

Jinja2 does not support `break` or `continue` natively. Use the `loopcontrols` extension to add them:

```python
env = Environment(extensions=["jinja2.ext.loopcontrols"])
```

```jinja2
{% for item in items %}
  {% if item == "stop" %}{% break %}{% endif %}
  {{ item }}
{% endfor %}
```

---

## Template Inheritance

Template inheritance is one of Jinja2's most powerful features. A **base template** defines a skeleton with named blocks. **Child templates** extend the base and fill in those blocks.

### Base Template (`base.html`)

```jinja2
<!DOCTYPE html>
<html>
<head>
  <title>{% block title %}Default Title{% endblock %}</title>
  {% block head %}{% endblock %}
</head>
<body>
  <header>{% block header %}<h1>My Site</h1>{% endblock %}</header>
  <main>{% block content %}{% endblock %}</main>
  <footer>{% block footer %}&copy; 2024{% endblock %}</footer>
</body>
</html>
```

### Child Template

```jinja2
{% extends "base.html" %}

{% block title %}Home Page{% endblock %}

{% block content %}
  <p>Welcome to the home page.</p>
{% endblock %}
```

### `super()`

Call `super()` to include the parent block's content:

```jinja2
{% block content %}
  {{ super() }}
  <p>Additional content appended below the parent block.</p>
{% endblock %}
```

### Nesting Blocks

Blocks can be nested arbitrarily:

```jinja2
{% block outer %}
  {% block inner %}Inner default{% endblock %}
{% endblock %}
```

### Scoped Blocks

By default, blocks do not have access to variables defined in the surrounding for loop or with statements. Use the `scoped` modifier to change this:

```jinja2
{% for item in items %}
  {% block item_row scoped %}
    {{ item }}
  {% endblock %}
{% endfor %}
```

### Multiple Levels of Inheritance

A child template can itself be a base for further child templates. Inheritance chains can be as deep as needed.

---

## Includes

Use `{% include %}` to insert another template inline at the current position. The included template shares the current context.

```jinja2
{% include "header.html" %}
{% include "footer.html" %}
```

### Ignore Missing

```jinja2
{% include "optional.html" ignore missing %}
```

### Fallback Includes

```jinja2
{% include ["custom.html", "default.html"] %}
```

The first template found is used.

---

## Macros

Macros are reusable template fragments, analogous to Python functions.

### Defining a Macro

```jinja2
{% macro input(name, value="", type="text", required=False) %}
  <input type="{{ type }}" name="{{ name }}" value="{{ value }}"
         {{ "required" if required }}>
{% endmacro %}
```

### Calling a Macro

```jinja2
{{ input("username") }}
{{ input("password", type="password", required=True) }}
```

### Macro Special Variables

Inside a macro, several special variables are available:

- `varargs` — extra positional arguments as a tuple.
- `kwargs` — extra keyword arguments as a dict.
- `caller` — if the macro was called with a `{% call %}` block, this holds the block content.

### The `call` Block

Use `{% call %}` to pass a block of template content into a macro:

```jinja2
{% macro dialog(title) %}
  <div class="dialog">
    <h2>{{ title }}</h2>
    <div class="body">{{ caller() }}</div>
  </div>
{% endmacro %}

{% call dialog("Confirm") %}
  <p>Are you sure?</p>
{% endcall %}
```

### Importing Macros

Macros defined in one template can be imported in another.

```jinja2
{% import "macros/forms.html" as forms %}
{{ forms.input("email") }}
```

Or import individual names:

```jinja2
{% from "macros/forms.html" import input, button %}
{{ input("email") }}
```

### Import with Context

By default, imported macros do not have access to the current template's context. Use `with context` to share it:

```jinja2
{% import "macros.html" as m with context %}
```

---

## Variables and Assignments

### `set`

Assign a value to a variable:

```jinja2
{% set username = "alice" %}
{% set items = [1, 2, 3] %}
```

### Block Assignment (`set` + `endset`)

Capture a block of template output into a variable:

```jinja2
{% set nav %}
  <nav>
    <a href="/">Home</a>
    <a href="/about">About</a>
  </nav>
{% endset %}

{{ nav }}
```

### `namespace`

Variables assigned inside a loop or block are local to that scope. Use `namespace` to share state across loop iterations:

```jinja2
{% set ns = namespace(found=False) %}
{% for item in items %}
  {% if item.active %}
    {% set ns.found = True %}
  {% endif %}
{% endfor %}

{% if ns.found %}Found an active item.{% endif %}
```

---

## Whitespace Control

Jinja2 preserves whitespace around tags by default. You can control this with the minus `-` modifier.

### Strip Before (`-` at end of opening tag)

```jinja2
{%- if condition %}...{% endif %}
```

Strips whitespace (including newlines) before the tag.

### Strip After (`-` at start of closing tag)

```jinja2
{% if condition -%}...{%- endif %}
```

Strips whitespace after the tag.

### Environment-Level Whitespace

The `trim_blocks` and `lstrip_blocks` options in `Environment` handle common cases automatically:

```python
env = Environment(trim_blocks=True, lstrip_blocks=True)
```

- `trim_blocks=True` — removes the first newline after a block tag.
- `lstrip_blocks=True` — strips leading whitespace (including tabs) from block tags at the start of a line.

---

## Escaping and Autoescape

### Manual Escaping

```jinja2
{{ user_input | e }}
{{ user_input | escape }}
```

### Marking Safe

When you know content is safe and should not be escaped:

```jinja2
{{ html_content | safe }}
```

Or in Python code:

```python
from markupsafe import Markup
safe_html = Markup("<strong>Bold</strong>")
```

### Autoescaping

Enable globally:

```python
env = Environment(autoescape=True)
```

Enable selectively by file extension:

```python
from jinja2 import select_autoescape

env = Environment(autoescape=select_autoescape(["html", "xml"]))
```

### Escaping Jinja2 Delimiters

To output literal `{{`, `}}`, `{%`, `%}` in your template:

```jinja2
{{ '{{' }}
{% raw %}{{ this will not be processed }}{% endraw %}
```

---

## Template Context

The context is the dictionary of variables passed to `template.render()`. You can also pass keyword arguments:

```python
template.render(user=user_obj, items=item_list)
template.render(**my_dict)
```

### Global Variables

Set variables available in all templates:

```python
env.globals["app_name"] = "My App"
env.globals["current_year"] = 2024
```

Or pass a function:

```python
import datetime
env.globals["now"] = datetime.datetime.utcnow
```

### Context Object

Inside a template, the special `_context` variable is not normally available. Use `{% set %}` assignments and pass all necessary data explicitly.

---

## Undefined Variables

By default, accessing an undefined variable returns an empty string silently. You can change this behavior:

```python
from jinja2 import Environment, StrictUndefined, DebugUndefined

# Raise an error on any undefined variable access
env = Environment(undefined=StrictUndefined)

# Print a debug string instead of empty string
env = Environment(undefined=DebugUndefined)
```

Available `Undefined` classes:

- `Undefined` — silent, returns empty string (default).
- `DebugUndefined` — prints `{{ varname }}` in output.
- `StrictUndefined` — raises `UndefinedError` immediately.
- `ChainableUndefined` — like `Undefined` but also supports attribute/item access on undefined.
- `make_undefined` — factory for custom behavior.

---

## Sandboxed Environment

Jinja2 provides a `SandboxedEnvironment` that restricts template capabilities to prevent execution of dangerous code. It is intended for untrusted templates.

```python
from jinja2.sandbox import SandboxedEnvironment

env = SandboxedEnvironment()
```

The sandboxed environment blocks access to private attributes, dunder methods, and other potentially unsafe operations. It does not constitute a full security boundary — avoid using it as the sole defense against malicious input in high-stakes contexts.

---

## Extensions

Extensions add new tags, filters, or global functions to Jinja2.

### Built-in Extensions

#### `jinja2.ext.i18n`

Internationalization support. Adds `{% trans %}` tag and `_()` / `gettext()` helpers.

```python
env = Environment(extensions=["jinja2.ext.i18n"])
env.install_gettext_callables(gettext_fn, ngettext_fn)
```

```jinja2
{% trans %}Hello, World!{% endtrans %}
{% trans count=items|length %}
  One item.
{% pluralize %}
  {{ count }} items.
{% endtrans %}
```

#### `jinja2.ext.debug`

Adds `{% debug %}` tag that dumps the current context:

```python
env = Environment(extensions=["jinja2.ext.debug"])
```

```jinja2
{% debug %}
```

#### `jinja2.ext.loopcontrols`

Adds `{% break %}` and `{% continue %}` inside for loops.

```python
env = Environment(extensions=["jinja2.ext.loopcontrols"])
```

#### `jinja2.ext.do`

Adds the `{% do %}` tag, which evaluates an expression and discards the result (useful for calling functions with side effects):

```python
env = Environment(extensions=["jinja2.ext.do"])
```

```jinja2
{% do my_list.append(item) %}
```

### Writing a Custom Extension

Subclass `jinja2.ext.Extension` and implement `tags` and `parse()`:

```python
from jinja2 import nodes
from jinja2.ext import Extension

class HighlightExtension(Extension):
    tags = {"highlight"}

    def parse(self, parser):
        lineno = next(parser.stream).lineno
        body = parser.parse_statements(["name:endhighlight"], drop_needle=True)
        return nodes.CallBlock(
            self.call_method("_highlight"),
            [], [], body
        ).set_lineno(lineno)

    def _highlight(self, caller):
        return f"<mark>{caller()}</mark>"
```

---

## Template Caching

Jinja2 compiles templates to Python bytecode. By default this happens in memory. Use a bytecode cache to persist compiled templates across process restarts.

### FileSystemBytecodeCache

```python
from jinja2 import FileSystemBytecodeCache

cache = FileSystemBytecodeCache("/tmp/jinja_cache/")
env = Environment(
    loader=FileSystemLoader("templates/"),
    bytecode_cache=cache
)
```

### MemcachedBytecodeCache

```python
from jinja2 import MemcachedBytecodeCache
import pylibmc

client = pylibmc.Client(["127.0.0.1"])
cache = MemcachedBytecodeCache(client)
env = Environment(bytecode_cache=cache)
```

### Custom Bytecode Cache

Subclass `BytecodeCache` and implement `load_bytecode()` and `dump_bytecode()`.

---

## Template Compilation and Code Generation

Jinja2 compiles templates to Python source before executing them. You can inspect the generated source:

```python
source = env.parse("Hello, {{ name }}!")
generated = env.get_source("Hello, {{ name }}!")[0]
code = env._parse("Hello, {{ name }}!", None, None)
```

Or generate Python code:

```python
source = env.get_template("index.html")
```

This is primarily useful for debugging or advanced optimization.

---

## Error Handling

### Exception Types

- `jinja2.TemplateNotFound` — template file could not be located.
- `jinja2.TemplatesNotFound` — none of a list of templates were found.
- `jinja2.TemplateSyntaxError` — syntax error in template source.
- `jinja2.UndefinedError` — accessed an undefined variable (with `StrictUndefined`).
- `jinja2.TemplateRuntimeError` — generic runtime error.
- `jinja2.TemplateAssertionError` — `{% assert %}` (non-standard) or internal assertion failed.

### Handling Errors

```python
from jinja2 import TemplateNotFound, TemplateSyntaxError

try:
    template = env.get_template("missing.html")
except TemplateNotFound as e:
    print(f"Template not found: {e}")

try:
    template = env.from_string("{% for %}")
except TemplateSyntaxError as e:
    print(f"Syntax error at line {e.lineno}: {e.message}")
```

---

## Async Support

Jinja2 supports asynchronous rendering for use with async Python frameworks (e.g., AIOHTTP, FastAPI).

Enable async mode on the environment:

```python
env = Environment(enable_async=True)
```

Render asynchronously:

```python
template = env.get_template("index.html")
output = await template.render_async(name="Alice")
```

Generate asynchronously (streaming):

```python
async for chunk in template.generate_async(name="Alice"):
    print(chunk, end="")
```

Async filters and globals are supported — Jinja2 will await any coroutine returned by a filter or global function.

---

## Integration with Flask

Flask uses Jinja2 as its default templating engine. The `flask.render_template()` function renders a template from the `templates/` directory relative to the application:

```python
from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html", user="Alice")
```

Flask automatically adds `request`, `session`, `g`, `config`, `url_for()`, and `get_flashed_messages()` to the template context. It also enables autoescaping for `.html` and `.xml` files by default.

To add custom filters:

```python
@app.template_filter("reverse")
def reverse_filter(s):
    return s[::-1]
```

Or directly:

```python
app.jinja_env.filters["reverse"] = reverse_filter
```

To add globals:

```python
app.jinja_env.globals["site_name"] = "My Site"
```

---

## Advanced Usage

### Template Streams

Rather than rendering the entire template into one string, stream output in chunks:

```python
stream = template.stream(name="Alice")
stream.enable_buffering(5)  # buffer every 5 items
for chunk in stream:
    response.write(chunk)
```

### Module Mode

A compiled template can be used as a Python module:

```python
module = template.make_module(vars={"name": "Alice"})
print(module.title)   # access exported variables
```

### `with` Statement

Create a temporary variable scope:

```jinja2
{% with x = 42 %}
  {{ x }}
{% endwith %}

{# Or: #}
{% with %}
  {% set x = 42 %}
  {{ x }}
{% endwith %}
```

Variables defined inside `{% with %}` do not leak into the outer scope.

### Expression Statement (`do`)

With the `do` extension:

```jinja2
{% do my_list.append("new item") %}
```

### `pluralize` (i18n)

With the `i18n` extension:

```jinja2
{% trans count=users|length %}
  {{ count }} user
{% pluralize %}
  {{ count }} users
{% endtrans %}
```

### Custom Delimiters

Change delimiters to avoid conflicts with other template languages:

```python
env = Environment(
    block_start_string="[%",
    block_end_string="%]",
    variable_start_string="[[",
    variable_end_string="]]",
    comment_start_string="[#",
    comment_end_string="#]",
)
```

---

## Security Considerations

### Autoescaping

Always enable autoescaping when rendering user-supplied content into HTML or XML output. This is the most important defense against cross-site scripting (XSS).

```python
env = Environment(autoescape=select_autoescape(["html", "xml"]))
```

Mark strings as safe only when you have verified they contain no untrusted content:

```python
from markupsafe import Markup
safe = Markup("<b>Bold</b>")
```

### Untrusted Templates

If you allow end users to supply template source, use `SandboxedEnvironment`. Be aware that no sandbox is an absolute guarantee of safety; evaluate the risk carefully for your use case.

### Path Traversal

When using `FileSystemLoader`, Jinja2 prevents path traversal by default (e.g., `../../etc/passwd` in a template name will raise an error).

### Template Injection

Avoid constructing template strings from user input and rendering them with `env.from_string()`. Prefer loading templates from trusted files on disk and passing user data only through the render context.

---

## Performance Tips

Jinja2 compiles templates to Python bytecode on first use. Subsequent renders reuse the compiled bytecode, which is fast. To further reduce startup time:

- Use `FileSystemBytecodeCache` to persist compiled bytecode across restarts.
- Pre-warm the cache by loading all templates at application startup using `env.get_template()`.
- Avoid creating a new `Environment` per request; instantiate it once at module load time.
- Use `trim_blocks` and `lstrip_blocks` to reduce unnecessary whitespace in output without runtime overhead.
- Prefer filters over Python code in templates for clarity, but avoid chaining many heavy filters on large datasets in hot rendering paths.

---

## Reference: Global Functions Available in Templates

Jinja2 provides several built-in global functions:

|Function|Description|
|---|---|
|`range([start], stop[, step])`|Like Python's `range()`|
|`lipsum(n=5, html=True, min=20, max=100)`|Generates Lorem Ipsum|
|`dict(**kwargs)`|Creates a dict from keyword args|
|`joiner(sep=", ")`|Returns a callable that outputs sep on every call after the first|
|`cycler(*items)`|Cycles through items on each call to `.next()`|
|`namespace(**kwargs)`|Creates a namespace object for cross-scope variable sharing|

### `joiner` Example

```jinja2
{% set comma = joiner() %}
{% for item in items %}{{ comma() }}{{ item }}{% endfor %}
```

### `cycler` Example

```jinja2
{% set row_class = cycler("odd", "even") %}
{% for item in items %}
  <tr class="{{ row_class.next() }}">...</tr>
{% endfor %}
```

---

## Debugging Templates

### `{% debug %}`

With the debug extension:

```jinja2
{% debug %}
```

Dumps the context and available filters/tests as a JSON-like structure in the output.

### `pprint` Filter

```jinja2
{{ my_variable | pprint }}
```

Formats the value using Python's `pprint` module — useful for inspecting complex objects.

### `DebugUndefined`

```python
from jinja2 import DebugUndefined
env = Environment(undefined=DebugUndefined)
```

Prints `{{ varname }}` where the variable is missing instead of outputting nothing, making it easier to spot missing context keys.

---

## Common Patterns

### Conditional CSS Classes

```jinja2
<li class="{{ 'active' if page == 'home' else '' }}">Home</li>
```

### Rendering a List as Comma-Separated

```jinja2
{{ items | join(", ") }}
```

### Default Values

```jinja2
{{ user.bio | default("No biography provided.") }}
```

### Table Rows with Alternating Styles

```jinja2
{% for row in rows %}
  <tr class="{{ 'odd' if loop.index is odd else 'even' }}">
    <td>{{ row.name }}</td>
  </tr>
{% endfor %}
```

### Recursive Tree Rendering

```jinja2
{% macro render_node(node) %}
  <li>
    {{ node.label }}
    {% if node.children %}
    <ul>
      {% for child in node.children %}
        {{ render_node(child) }}
      {% endfor %}
    </ul>
    {% endif %}
  </li>
{% endmacro %}

<ul>
  {% for root in tree %}
    {{ render_node(root) }}
  {% endfor %}
</ul>
```

### Reusing a Macro Across Files

`macros/ui.html`:

```jinja2
{% macro badge(text, color="blue") %}
  <span class="badge badge-{{ color }}">{{ text }}</span>
{% endmacro %}
```

`page.html`:

```jinja2
{% from "macros/ui.html" import badge %}
{{ badge("New", color="green") }}
```

---

## Glossary

**Block** — a named section in a template that can be overridden by child templates.

**Context** — the dictionary of variables passed to `template.render()`.

**Environment** — the central object holding configuration, loaders, filters, tests, and globals.

**Expression** — a Jinja2 construct surrounded by `{{ }}` that is evaluated and output.

**Filter** — a transformation applied to a value using the pipe `|` operator.

**Loader** — an object responsible for finding and loading template source code.

**Macro** — a reusable template snippet defined with `{% macro %}`.

**Statement** — a Jinja2 construct surrounded by `{% %}` that controls template logic.

**Test** — a predicate applied to a value using the `is` keyword.

**Undefined** — the object returned when a variable is not found in the context; behavior depends on the `undefined` class configured on the environment.