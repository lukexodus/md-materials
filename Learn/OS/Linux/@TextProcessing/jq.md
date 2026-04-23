# Comprehensive Guide to jq and Its DSL

`jq` is a lightweight, portable command-line processor for JSON. It lets you slice, filter, map, and transform structured JSON data using a purpose-built functional DSL (domain-specific language). It is written in C, has no runtime dependencies, and is available on Linux, macOS, and Windows.

---

## Installation

**macOS (Homebrew)**

```sh
brew install jq
```

**Debian / Ubuntu**

```sh
sudo apt-get install jq
```

**Fedora / RHEL**

```sh
sudo dnf install jq
```

**Windows (Chocolatey)**

```sh
choco install jq
```

**Direct download**  
Pre-built binaries are available at https://jqlang.github.io/jq/download/.

---

## Basic Invocation

```sh
jq FILTER [FILE...]
```

If no file is given, `jq` reads from stdin.

```sh
echo '{"name":"ada","age":36}' | jq '.name'
# "ada"
```

### Common Flags

|Flag|Effect|
|---|---|
|`-r`|Raw output — strips JSON string quotes|
|`-c`|Compact output (no pretty-printing)|
|`-n`|Null input — use `jq` without any input|
|`-e`|Exit with a non-zero status if the last output is `false` or `null`|
|`-s`|Slurp — read entire input into a single array|
|`-R`|Raw input — treat each line as a plain string|
|`-j`|Like `-r` but does not append a newline|
|`--arg name val`|Bind a shell string to a `$name` variable|
|`--argjson name val`|Bind a JSON value to a `$name` variable|
|`--slurpfile name file`|Slurp a JSON file into `$name` as an array|
|`--rawfile name file`|Slurp a text file into `$name` as a string|
|`--jsonargs`|Treat remaining positional args as JSON `$ARGS.positional`|
|`--args`|Treat remaining positional args as strings in `$ARGS.positional`|
|`--indent N`|Set indentation (0–7 spaces, or use `\t`)|
|`--tab`|Use tab indentation|
|`--stream`|Parse input in streaming form|
|`--exit-status` / `-e`|Non-zero exit if output is `false`/`null`|

---

## The Identity Filter

The simplest filter is `.` — it returns its input unchanged, but pretty-prints it.

```sh
echo '{"a":1}' | jq '.'
# {
#   "a": 1
# }
```

---

## Field Access

### Object Field Access

```jq
.key
.["key"]
```

Use `.["key"]` when the key contains special characters or spaces.

```sh
echo '{"name":"turing"}' | jq '.name'
# "turing"
```

### Optional Field Access

Append `?` to suppress errors if the value is not an object or array:

```jq
.key?
```

---

## Array and Object Indexing

### Array Index

```jq
.[0]     # first element
.[-1]    # last element
.[2]     # third element
```

### Array Slice

```jq
.[2:5]   # elements at indices 2, 3, 4
.[:3]    # first three elements
.[-2:]   # last two elements
```

### String Slice

Slicing works on strings as well, returning a substring.

```sh
echo '"hello"' | jq '.[1:3]'
# "el"
```

---

## Iterator: `.[]`

`.[]` explodes an array or object into a stream of its values.

```sh
echo '[1,2,3]' | jq '.[]'
# 1
# 2
# 3

echo '{"a":1,"b":2}' | jq '.[]'
# 1
# 2
```

Combining with field access:

```sh
echo '[{"n":"a"},{"n":"b"}]' | jq '.[].n'
# "a"
# "b"
```

---

## Pipe: `|`

Passes the output of one filter as input to the next — the core composition mechanism.

```sh
echo '{"user":{"name":"lovelace"}}' | jq '.user | .name'
# "lovelace"
```

---

## Comma: Multiple Outputs

`,` runs two filters on the same input and produces both outputs in sequence.

```sh
echo '{"a":1,"b":2}' | jq '.a, .b'
# 1
# 2
```

---

## Array Construction: `[]`

Collects a stream or multiple expressions into a single array.

```sh
echo '{"a":1,"b":2}' | jq '[.a, .b]'
# [1, 2]

echo '[1,2,3]' | jq '[.[] | . * 2]'
# [2, 4, 6]
```

---

## Object Construction: `{}`

Builds a new object. Keys can be identifiers, expressions, or parenthesised expressions.

```sh
echo '{"name":"euler","age":76}' | jq '{n: .name}'
# {"n": "euler"}
```

Shorthand — if key and path match:

```sh
echo '{"name":"euler"}' | jq '{name}'
# {"name": "euler"}
```

Dynamic keys use parentheses:

```sh
echo '{"k":"x","v":1}' | jq '{(.k): .v}'
# {"x": 1}
```

---

## Types and Values

### Literals

```jq
null
true
false
42
3.14
"hello"
```

### `type`

Returns the type of a value as a string.

```sh
echo '42' | jq 'type'
# "number"
```

Possible return values: `"null"`, `"boolean"`, `"number"`, `"string"`, `"array"`, `"object"`.

---

## Comparison and Logic

### Comparison Operators

```jq
==   !=   <   <=   >   >=
```

### Boolean Operators

```jq
and   or   not
```

`not` is a filter, not an operator:

```sh
echo 'true' | jq 'not'
# false
```

### Truthiness

In jq, `false` and `null` are falsy. Everything else — including `0` and `""` — is truthy.

---

## Arithmetic

```jq
+   -   *   /   %
```

`+` is overloaded:

- Numbers: addition
- Strings: concatenation
- Arrays: concatenation
- Objects: merge (right-hand side wins on key conflict)
- `null + x` → `x`

`-` on arrays removes matching elements.  
`*` on a string and integer repeats the string.  
`/` on strings splits the first by the second.

```sh
echo '"hello world"' | jq '. / " "'
# ["hello", "world"]
```

---

## Conditionals

### `if-then-else-end`

```jq
if CONDITION then EXPR else EXPR end
```

```sh
echo '5' | jq 'if . > 3 then "big" else "small" end'
# "big"
```

The `else` branch is required. For chained conditions:

```jq
if . < 0 then "neg"
elif . == 0 then "zero"
else "pos"
end
```

### `//` — Alternative Operator

Returns the left-hand value unless it is `false` or `null`, in which case it returns the right.

```sh
echo 'null' | jq '. // "default"'
# "default"
```

---

## Try-Catch

```jq
try EXPR
try EXPR catch HANDLER
```

Suppresses errors from `EXPR`. If `catch` is given, `HANDLER` receives the error message as a string.

```sh
echo '"x"' | jq 'try tonumber catch "not a number"'
# "not a number"
```

---

## String Interpolation

Use `\(EXPR)` inside a string literal:

```sh
echo '{"name":"gauss"}' | jq '"Hello, \(.name)!"'
# "Hello, gauss!"
```

---

## Built-in Functions

### Length

```jq
length
```

- Array: number of elements
- Object: number of keys
- String: number of bytes (not Unicode codepoints — use `explode | length` for codepoints)
- Null: 0
- Number: absolute value

### utf8bytelength

Returns the byte length of a string encoded as UTF-8.

### keys, values, has, in

```jq
keys           # array of object keys, sorted
keys_unsorted  # array of object keys, insertion order
values         # array of object values
has("key")     # true/false — key exists in object, or index exists in array
"key" | in(OBJ)  # inverse of has
```

### to_entries, from_entries, with_entries

```jq
to_entries     # [{key:K, value:V}, ...]
from_entries   # inverse
with_entries(f)  # shorthand for: to_entries | map(f) | from_entries
```

```sh
echo '{"a":1,"b":2}' | jq 'with_entries(.value += 10)'
# {"a": 11, "b": 12}
```

### map and map_values

```jq
map(f)          # [.[] | f]
map_values(f)   # applies f to each value; preserves keys for objects
```

### select

```jq
select(BOOL_EXPR)
```

Passes the input through only if the expression is truthy. Produces no output otherwise (not `null` — it vanishes from the stream).

```sh
echo '[1,2,3,4,5]' | jq '[.[] | select(. > 3)]'
# [4, 5]
```

### empty

Produces no output at all — useful to discard values.

```sh
echo 'null' | jq 'empty'
# (no output)
```

### add

Reduces a stream or array by `+`.

```sh
echo '[1,2,3]' | jq 'add'
# 6

echo '["a","b","c"]' | jq 'add'
# "abc"
```

`add` on an empty array returns `null`.

### any and all

```jq
any           # true if any element is truthy
any(EXPR)     # true if f is truthy for any element
any(GEN; COND)  # more general form

all           # true if all elements are truthy
all(EXPR)
all(GEN; COND)
```

### flatten

```jq
flatten       # fully flatten nested arrays
flatten(DEPTH)
```

### range

```jq
range(N)         # 0, 1, ..., N-1 as a stream
range(FROM; TO)
range(FROM; TO; STEP)
```

### floor, ceil, round, fabs, sqrt, pow, log, exp, nan, infinite, isinfinite, isnan, isnormal, isfinite

Standard math functions. Most expect a number.

```sh
echo '2' | jq 'sqrt'
# 1.4142135623730951

echo '[2,10]' | jq '.[0] | pow(.; 10)'  # or: pow(2;10)
# 1024
```

`pow(base; exp)` takes two arguments via `;` (see below).

### fma(x; y; z)

Fused multiply-add: `x * y + z`.

### min, max, min_by, max_by

```jq
min
max
min_by(.field)
max_by(.field)
```

### sort, sort_by, group_by, unique, unique_by

```jq
sort
sort_by(.field)
group_by(.field)   # array of arrays, grouped by value
unique             # sorted unique values
unique_by(.field)
```

### reverse

Reverses an array or string.

### contains and inside

```jq
contains(B)   # true if B is "contained" in input (recursive subset check)
inside(B)     # inverse: true if input is contained in B
```

### indices, index, rindex

```jq
indices("x")    # all positions of a value in array or string
index("x")      # first position
rindex("x")     # last position
```

### limit

```jq
limit(N; EXPR)   # take first N outputs of EXPR
```

### first and last

```jq
first(EXPR)   # first output of EXPR
last(EXPR)    # last output of EXPR
first         # .[0]
last          # .[-1]
```

### nth

```jq
nth(N; EXPR)   # Nth output (0-indexed) of EXPR
```

### recurse and recurse_down

```jq
recurse          # recursively descend into all values
recurse(f)       # apply f repeatedly until no output
recurse(f; COND) # stop when COND is false
```

```sh
echo '{"a":{"b":{"c":1}}}' | jq '[recurse | .c? // empty]'
# [1]
```

### walk

```jq
walk(f)   # apply f bottom-up to every node in the structure
```

### paths and leaf_paths

```jq
paths          # stream of all paths (as arrays) in input
paths(f)       # only paths where f is truthy for the leaf
leaf_paths     # paths to scalar values only
getpath(PATH)  # value at a given path array
setpath(PATH; VAL)
delpaths([PATH, ...])
path(EXPR)     # the path array that EXPR would access
```

### env and $ENV

```jq
env          # object of all environment variables
$ENV.HOME    # direct access to a specific env var
```

### ascii_downcase, ascii_upcase

```jq
ascii_downcase
ascii_upcase
```

### ltrimstr, rtrimstr, startswith, endswith

```jq
ltrimstr("prefix")
rtrimstr("suffix")
startswith("x")
endswith("x")
```

### split and join

```jq
split("SEP")
join("SEP")
```

### test, match, capture, scan, sub, gsub

These use ONIG (Oniguruma) extended regex.

```jq
test("REGEX")             # true/false
test("REGEX"; "FLAGS")    # flags: g, x, i, s, m
match("REGEX")            # match object: {offset, length, string, captures}
capture("REGEX")          # named captures as an object
scan("REGEX")             # stream of matched strings (or arrays for groups)
sub("REGEX"; "REPL")      # replace first match
gsub("REGEX"; "REPL")     # replace all matches
sub("REGEX"; f)           # replacement via filter
```

Regex flags: `g` (global), `i` (case-insensitive), `x` (extended/whitespace-ignoring), `s` (single-line — `.` matches newline), `m` (multiline — `^`/`$` match line boundaries).

```sh
echo '"foo bar baz"' | jq '[scan("[a-z]+")]'
# ["foo", "bar", "baz"]
```

### ascii, implode, explode

```jq
explode    # string → array of codepoints
implode    # array of codepoints → string
```

### tojson, fromjson

```jq
tojson     # value → JSON string
fromjson   # JSON string → value
```

### @base64, @base64d, @uri, @csv, @tsv, @sh, @html, @json, @text

Format strings — usable inside string interpolation or as a filter:

```jq
@base64         # encode to base64
@base64d        # decode from base64
@uri            # percent-encode
@csv            # format array as CSV line
@tsv            # format array as TSV line
@sh             # shell-quote
@html           # HTML-escape (&, <, >, ', ")
@json           # same as tojson
@text           # identity (same as tostring)
```

```sh
echo '["a","b,c"]' | jq '@csv'
# "\"a\",\"b,c\""

echo '"hello world"' | jq '@uri'
# "hello%20world"

echo '"<b>hi</b>"' | jq '@html'
# "&lt;b&gt;hi&lt;/b&gt;"
```

### tostring and tonumber

```jq
tostring   # converts any value to a string
tonumber   # parses a string to a number
```

### nan, infinite, isinfinite, isnan, isnormal, isfinite

```jq
nan        # IEEE 754 NaN
infinite   # positive infinity
isinfinite # true if value is ±infinity
isnan
isnormal
isfinite
```

### input and inputs

Used with `-n` flag:

```jq
input     # read one more JSON value from input
inputs    # read remaining JSON values as a stream
```

```sh
echo -e '1\n2\n3' | jq -n '[inputs]'
# [1, 2, 3]
```

### debug

```jq
debug          # print input to stderr, pass through
debug("MSG")   # print message and value to stderr
```

### stderr

Emits value to stderr, passes through to stdout — similar to `debug` but without formatting.

### error

```jq
error          # raise an error with input as message
error("MSG")
```

### halt and halt_error

```jq
halt              # exit immediately, status 0
halt_error        # exit with status 5
halt_error(N)     # exit with status N
```

### builtins

```jq
builtins   # array of all built-in names as "name/arity" strings
```

### getpath, setpath, delpaths

```jq
getpath(["a","b"])
setpath(["a","b"]; 42)
delpaths([["a","b"], ["c"]])
```

### leaf_paths

```jq
leaf_paths   # stream of paths to all scalar values
```

### to_date, from_date, now, dateadd, datesub, gmtime, mktime, strftime, strptime, dateiso8601, fromdateiso8601

Date/time functions (jq 1.6+):

```jq
now               # current UTC time as Unix timestamp (float)
gmtime            # Unix timestamp → broken-down time (array)
mktime            # broken-down time → Unix timestamp
strftime("FMT")   # format broken-down time
strptime("FMT")   # parse string → broken-down time
todate            # alias for strftime("%FT%TZ") with gmtime
fromdate          # alias for strptime | mktime
dateiso8601       # alias for todate
fromdateiso8601   # alias for fromdate
```

```sh
echo 'null' | jq 'now | todate'
# "2025-04-22T10:00:00Z"  (example)
```

---

## Variables

### `as` Pattern Binding

```jq
EXPR as $name | BODY
```

Binds the output of `EXPR` to `$name` within `BODY`. The input to `BODY` is unchanged.

```sh
echo '5' | jq '. as $x | $x * $x'
# 25
```

`as` can destructure arrays and objects using patterns:

```jq
. as {name: $n, age: $a} | "\($n) is \($a)"
. as [$first, $second] | [$second, $first]
```

### `--arg` and `--argjson`

Pass external values in as variables:

```sh
jq --arg greeting "hello" '.name as $n | "\($greeting), \($n)"' file.json
```

---

## Reduce

```jq
reduce STREAM as $x (INIT; UPDATE)
```

Folds a stream into a single accumulated value.

```sh
echo '[1,2,3,4,5]' | jq 'reduce .[] as $x (0; . + $x)'
# 15
```

---

## foreach

```jq
foreach STREAM as $x (INIT; UPDATE)
foreach STREAM as $x (INIT; UPDATE; EXTRACT)
```

Like `reduce`, but emits intermediate states as a stream. If `EXTRACT` is provided, it is applied to each state to produce the output.

```sh
echo 'null' | jq '[foreach range(4) as $x (0; . + $x)]'
# [0, 1, 3, 6]
```

---

## label-break

For early exit from a generator:

```jq
label $out | foreach EXPR as $x (...; if COND then ., break $out else . end)
```

---

## Function Definitions

### `def`

```jq
def NAME: BODY;
def NAME(ARGS): BODY;
```

Arguments are filters (not values) — they are called at each use site.

```sh
echo '5' | jq 'def double: . * 2; double'
# 10
```

Multiple arguments are separated by `;`:

```sh
echo 'null' | jq 'def add(a; b): a + b; add(3; 4)'
# 7
```

Recursive functions use `def` with self-reference:

```sh
echo '5' | jq '
  def fact:
    if . <= 1 then 1
    else . * ((. - 1) | fact)
    end;
  fact
'
# 120
```

### Tail-Call Optimisation

jq performs TCO when the last call in a function body is a direct self-call or a call to another function — this avoids stack overflow for deeply recursive definitions.

---

## Optional Object Identifier: `?//`

The `?//` operator is the "try alternative" operator (jq 1.6+):

```jq
EXPR ?// ALT
```

If `EXPR` produces no output or errors, `ALT` is used instead.

---

## String Interpolation (Advanced)

Format strings work inside `\(...)`:

```sh
echo '3.14159' | jq '"Pi is approximately \(. * 100 | round / 100)"'
# "Pi is approximately 3.14"
```

---

## Multiple Outputs and Streams

A filter can produce zero, one, or many outputs. This is first-class in jq — it is not an error condition.

```sh
echo 'null' | jq '1, 2, 3'
# 1
# 2
# 3
```

Wrapping in `[]` collects a stream:

```sh
echo 'null' | jq '[range(5)]'
# [0, 1, 2, 3, 4]
```

---

## update (|=), update-add (+=), etc.

```jq
.field |= EXPR        # update in place using current value
.field += N           # add N to field
.field -= N
.field *= N
.field /= N
.field %= N
.field //= DEFAULT    # assign if null/false
```

`|=` applies the filter to the current value and replaces it:

```sh
echo '{"a":5}' | jq '.a |= . + 1'
# {"a": 6}
```

---

## del

Remove a field or array element:

```jq
del(.field)
del(.[2])
del(.[] | select(. < 3))
```

---

## Grouping Parentheses

```jq
(EXPR)
```

Parentheses control precedence or group sub-expressions.

---

## `?` Operator (Suppress Errors)

Append `?` to any filter to suppress errors and discard failing outputs:

```jq
.foo?
.[0]?
(.[] | .x)?
```

---

## Streaming Mode (`--stream`)

With `--stream`, input is parsed as a stream of `[path, value]` events. Useful for large documents:

```sh
echo '{"a":{"b":1}}' | jq --stream '.'
# [[["a","b"],1]]
# [[["a","b"]],{"truncated":true}]
```

`truncate_stream(f)`, `tostream`, `fromstream`, `tojson | fromjson` can all work with streaming data.

---

## `$__loc__`

A special variable that expands to `{"file": "...", "line": N}` — useful for debugging inside jq programs.

---

## Modules and Imports

jq supports a module system for reusable code (via `--library-path` or `~/.jq`).

```jq
import "path/to/module" as alias;
include "path/to/module";
```

Module files have the `.jq` extension. `$ENV.HOME/.jq` or `~/.jq` is loaded automatically if it exists.

---

## Operator Precedence (High to Low)

|Precedence|Operators|
|---|---|
|Highest|`|
||`,`|
||`//`|
||`=`, `|
||`or`|
||`and`|
||`not`|
||Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`|
||`+`, `-`|
||`*`, `/`, `%`|
|Lowest|Postfix: `?`, `[]`, `.field`|

When in doubt, use parentheses.

---

## Common Patterns

### Extract a field from every object in an array

```sh
jq '[.[].name]' data.json
# or equivalently:
jq 'map(.name)' data.json
```

### Filter array by condition

```sh
jq '[.[] | select(.active == true)]' data.json
# or:
jq 'map(select(.active))' data.json
```

### Count items matching a condition

```sh
jq '[.[] | select(.score > 50)] | length' data.json
```

### Flatten and deduplicate

```sh
jq '[.[]] | flatten | unique' data.json
```

### Transform keys

```sh
jq 'with_entries(.key |= ascii_upcase)' data.json
```

### Group and count

```sh
jq 'group_by(.category) | map({key: .[0].category, value: length}) | from_entries' data.json
```

### Merge two objects

```sh
jq -s '.[0] * .[1]' a.json b.json
```

### Convert CSV-ish data

```sh
echo '[["a","b"],[1,2],[3,4]]' | jq '.[0] as $h | .[1:] | map([$h, .] | transpose | map({(.[0]): .[1]}) | add)'
# [{"a":1,"b":2},{"a":3,"b":4}]
```

### Pass a shell variable into jq

```sh
NAME="lovelace"
jq --arg n "$NAME" '.[] | select(.name == $n)' data.json
```

### Build a lookup table

```sh
jq 'map({(.id): .}) | add' data.json
```

### Recursive search for a key

```sh
jq '.. | .email? // empty' data.json
```

---

## Error Handling Patterns

### Provide a default for missing fields

```sh
jq '.missing // "default"' data.json
```

### Ignore errors on a whole sub-expression

```sh
jq 'try (.a.b.c) catch null' data.json
```

### Validate structure before processing

```sh
jq 'if type == "array" then map(.id) else error("expected array") end' data.json
```

---

## Performance Notes

- Use `--stream` for very large JSON documents to avoid loading the entire structure into memory.
- Prefer `select` over `map` followed by filtering when the filtered-out portion is large.
- `limit(N; EXPR)` short-circuits — useful when you only need a few results from a large generator.
- Recursive functions with TCO (tail position) do not blow the stack.

---

## Differences Between jq Versions

|Feature|Minimum Version|
|---|---|
|`@base64d`, `@uri`, `@sh`|1.5|
|`env`, `$ENV`|1.5|
|`path`, `getpath`, `setpath`|1.5|
|`debug("MSG")`|1.6|
|`?//` (try-alternative)|1.6|
|Date/time builtins (`now`, `strftime`, etc.)|1.5|
|`$__loc__`|1.5|
|`label-break`|1.5|
|`limit`, `first`, `last`, `nth`|1.5|

The current stable release is **jq 1.7** (as of 2024). Check `jq --version` to confirm what you have.

---

## Quick Reference

```
.                   identity
.foo                field access
.foo.bar            nested access
.["foo"]            bracket field access
.[0]                array index
.[-1]               last element
.[2:5]              slice
.[]                 iterate
,                   multiple outputs
|                   pipe
+  -  *  /  %       arithmetic
==  !=  <  >  <=  >= comparison
and  or  not        logic
if-then-else-end    conditional
try-catch           error handling
//                  alternative
|=  +=  -=  ...     update
del(PATH)           delete
as $x               variable binding
def f: ...;         function definition
reduce X as $x (I; U)   fold
foreach X as $x (I; U)  unfold stream
[]                  collect stream
{}                  object construction
@fmt                format string
\(EXPR)             string interpolation
?                   suppress errors
..                  recursive descent
```