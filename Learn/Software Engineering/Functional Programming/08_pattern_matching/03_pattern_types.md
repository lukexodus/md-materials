## Pattern Types


Pattern types encompass the various categories of patterns available in a pattern matching system. Each pattern type serves specific matching and destructuring purposes, and they can be composed to create sophisticated matching expressions.

The type system determines which patterns are available and how they interact with data constructors. Richer type systems enable more expressive patterns, including type patterns, constructor patterns, tuple patterns, list patterns, and record patterns.

**Key Points:**

- Variable patterns bind matched values to names
- Constructor patterns match algebraic data type variants
- Tuple/record patterns destructure product types
- List patterns handle sequential data with head/tail decomposition
- Type patterns enable runtime type testing and casting
- OR patterns allow multiple alternatives in a single case
- AS patterns bind a value while matching a subpattern

Variable patterns are the simplest form, binding the matched value to a name for use in the branch body. They always succeed in matching:

**Example:**

```ocaml
match value with
| x -> process x  (* x binds to whatever value is *)
```

Constructor patterns match specific variants of sum types, extracting their fields. This enables discriminating between different cases of a type and accessing their data:

**Example:**

```haskell
data Tree a = Leaf a | Node (Tree a) a (Tree a)

depth tree = case tree of
    Leaf _     -> 1
    Node l _ r -> 1 + max (depth l) (depth r)
```

Tuple and record patterns destructure product types, extracting multiple values simultaneously. Named record patterns are particularly useful for clarity when dealing with many fields:

**Example:**

```reason
type point = { x: int, y: int, z: int };

let magnitude = ({x, y, z}) => {
  sqrt(x * x + y * y + z * z)
};
```

List patterns provide special syntax for matching on sequences, typically supporting head/tail decomposition and literal list matching:

**Example:**

```elixir
def sum(list) do
  case list do
    [] -> 0
    [head | tail] -> head + sum(tail)
  end
end
```

OR patterns (using `|`) allow specifying multiple patterns that should trigger the same action, reducing code duplication:

**Example:**

```ocaml
match day with
| Saturday | Sunday -> "weekend"
| _ -> "weekday"
```

AS patterns (using `as` or `@`) bind the entire matched value to a name while simultaneously matching against a more specific pattern:

**Example:**

```haskell
case tree of
    node@(Node left _ right) -> (node, max (depth left) (depth right))
```

Type patterns enable matching based on runtime type information, useful in languages with dynamic typing or when dealing with existential types. [Inference: This requires runtime type information which may not be available in all statically typed languages without explicit type evidence.]

**Conclusion:** The diversity of pattern types provides a comprehensive toolkit for data inspection and decomposition, enabling expressive and type-safe code that clearly communicates intent.

