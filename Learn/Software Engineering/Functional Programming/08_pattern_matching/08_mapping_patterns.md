## Mapping Patterns


Mapping patterns match dictionary-like structures (maps, records, objects) by their key-value pairs, enabling extraction of specific fields while optionally ignoring others. They support both exact and partial matching of associative structures.

**Key Points:**

- Match against specific keys and their associated values
- Support partial matching (subset of keys)
- Enable simultaneous existence checking and value extraction
- Can nest other patterns as values
- Useful for JSON, configuration, and record processing

Basic record/map field extraction:

**Example:**

```python
# Python 3.10+ mapping patterns
match user:
    case {"name": name, "age": age}:  # extract specific fields
        print(f"{name} is {age} years old")
    case {"name": name}:  # partial match, age optional
        print(f"User: {name}")
    case _:
        print("Invalid user data")

# Nested mapping patterns
match response:
    case {"status": "success", "data": {"id": user_id, "email": email}}:
        register_user(user_id, email)
```

**Example:**

```scala
// Scala: case class patterns (structural mapping)
case class Person(name: String, age: Int, city: String)

person match {
    case Person(name, age, _) =>  // extract name and age, ignore city
        s"$name ($age years)"
    case Person("Alice", _, city) =>  // match specific name
        s"Alice from $city"
}
```

Map patterns with value constraints:

**Example:**

```python
# Python: mapping patterns with nested patterns
match config:
    case {"mode": "production", "replicas": n} if n > 1:
        setup_cluster(n)
    case {"mode": "development", "debug": True}:
        enable_debugging()
    case {"mode": mode, **rest}:  # capture remaining keys
        setup_generic(mode, rest)
```

**Example:**

```haskell
-- Haskell: record patterns
data Config = Config 
    { host :: String
    , port :: Int
    , timeout :: Int
    }

processConfig :: Config -> String
processConfig Config{host = h, port = p} =  -- partial pattern, ignore timeout
    h ++ ":" ++ show p

-- Pattern match with specific field values
isLocalhost :: Config -> Bool
isLocalhost Config{host = "localhost"} = True
isLocalhost _ = False
```

Mapping patterns for JSON-like structures:

**Example:**

```ocaml
(* OCaml with ppx_yojson for JSON patterns - illustrative *)
let process_json json =
    match json with
    | `Assoc [("type", `String "user"); ("id", `Int id); ("name", `String name)] ->
        Printf.sprintf "User %d: %s" id name
    | `Assoc [("type", `String "error"); ("message", `String msg)] ->
        "Error: " ^ msg
    | _ -> "Unknown format"
```

**Example:**

```fsharp
// F# record patterns with guards
type Request = { Method: string; Path: string; Query: Map<string, string> }

match request with
| { Method = "GET"; Path = path; Query = query } when query.ContainsKey("id") ->
    handleGetById path query.["id"]
| { Method = "POST"; Path = "/users"; Query = _ } ->
    createUser()
| { Method = method; Path = path } ->
    handleGeneric method path
```

Combining mapping patterns with sequence patterns:

**Example:**

```python
# Python: complex nested patterns
match event:
    case {"type": "batch", "items": [first, *rest]} if len(rest) > 0:
        process_batch(first, rest)
    case {"type": "single", "data": {"value": v, "timestamp": ts}}:
        process_single(v, ts)
```

**[Inference]** Mapping patterns provide type-safe extraction from dynamic structures, particularly valuable when interfacing with external data formats where field presence may vary.

**Conclusion:** Pattern matching forms a unified framework for data inspection and decomposition in functional programming. Capture patterns extract values, wildcards ignore irrelevant data, sequence patterns decompose ordered collections, and mapping patterns handle associative structures. Together, they replace imperative conditional logic and manual data access with declarative specifications of data shapes, improving both readability and correctness. Modern languages increasingly adopt pattern matching as the combination of type safety, exhaustiveness checking, and expressive power makes it superior to traditional control flow for data-oriented code.

