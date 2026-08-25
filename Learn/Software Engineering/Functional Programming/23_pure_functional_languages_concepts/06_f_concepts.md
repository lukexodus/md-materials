## F# Concepts


F# is a strongly-typed language on .NET with ML-family syntax, emphasizing immutability, type inference, and algebraic data types.

**Discriminated Unions**

Discriminated unions (sum types) represent values that can be one of several named cases, each potentially carrying different data.

```fsharp
type Shape =
    | Circle of radius: float
    | Rectangle of width: float * height: float
    | Triangle of base: float * height: float

let area shape =
    match shape with
    | Circle r -> Math.PI * r * r
    | Rectangle (w, h) -> w * h
    | Triangle (b, h) -> 0.5 * b * h
```

**Active Patterns**

Active patterns enable custom pattern matching logic, creating dynamic decompositions of data.

```fsharp
let (|Even|Odd|) n = if n % 2 = 0 then Even else Odd

let describe n =
    match n with
    | Even -> "even"
    | Odd -> "odd"

// Partial active patterns
let (|ParseInt|_|) str =
    match System.Int32.TryParse(str) with
    | true, value -> Some value
    | false, _ -> None

match "123" with
| ParseInt i -> printfn "Parsed: %d" i
| _ -> printfn "Not a number"
```

**Computation Expressions**

Computation expressions (monadic syntax) provide custom control flow for various computational contexts (async, sequence generation, options, etc.).

```fsharp
let asyncOperation = async {
    let! data = fetchDataAsync()
    let processed = processData data
    return processed
}

let optionWorkflow = maybe {
    let! x = Some 5
    let! y = Some 10
    return x + y
}
```

**Type Providers**

Type providers generate types at compile-time from external data sources (databases, web services, JSON, CSV), providing statically-typed access to external data.

```fsharp
type People = CsvProvider<"people.csv">
let rows = People.Load("people.csv")
for row in rows.Rows do
    printfn "%s is %d years old" row.Name row.Age
```

**Units of Measure**

F# supports compile-time dimensional analysis through units of measure, preventing unit mismatches without runtime overhead.

```fsharp
[<Measure>] type m
[<Measure>] type s
[<Measure>] type kg

let distance = 10.0<m>
let time = 2.0<s>
let velocity = distance / time  // Type: float<m/s>
// let invalid = distance + time  // Compile error: unit mismatch
```

**Object Expressions**

Object expressions create anonymous implementations of interfaces or abstract classes inline.

```fsharp
let comparer = 
    { new IComparer<int> with
        member _.Compare(x, y) = compare (x % 10) (y % 10) }
```

**Quotations**

Code quotations represent F# expressions as abstract syntax trees for metaprogramming and reflection.

```fsharp
open Microsoft.FSharp.Quotations

let expr = <@ fun x -> x + 1 @>
match expr with
| Patterns.Lambda(var, body) -> printfn "Lambda with parameter %s" var.Name
| _ -> ()
```

**Async Workflows**

F#'s async model provides lightweight asynchronous computation without callbacks, integrating with .NET's Task-based async.

```fsharp
let fetchMultiple urls = async {
    let! results = 
        urls 
        |> List.map downloadAsync
        |> Async.Parallel
    return results |> Array.sum
}
```

**Mutable Records and Reference Cells**

While records are immutable by default, fields can be marked mutable. Reference cells provide mutable containers.

```fsharp
type Counter = { mutable Count: int }
let c = { Count = 0 }
c.Count <- c.Count + 1

let refCell = ref 0
refCell := !refCell + 1
```

**Type Abbreviations and Measure Annotations**

Type aliases create readable names, and measures can be applied to existing numeric types.

```fsharp
type CustomerId = int
type Temperature = float<celsius>

[<Measure>] type celsius
[<Measure>] type fahrenheit

let convert (temp: float<celsius>) : float<fahrenheit> =
    temp * 9.0<fahrenheit> / 5.0<celsius> + 32.0<fahrenheit>
```

**Sequence Expressions**

Lazy sequences can be generated using `seq { }` expressions with imperative-style code.

```fsharp
let fibonacci = seq {
    let mutable a, b = 0, 1
    while true do
        yield a
        let temp = a
        a <- b
        b <- temp + b
}

fibonacci |> Seq.take 10 |> Seq.toList
```

