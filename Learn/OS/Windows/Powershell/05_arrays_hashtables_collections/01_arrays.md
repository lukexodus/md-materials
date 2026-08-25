## Arrays


### Creating and Manipulating Arrays

#### Array Creation Methods

PowerShell provides multiple approaches for creating arrays, each suited for different scenarios and data types. The most common method uses the array subexpression operator `@()` which explicitly creates an array even with single elements or empty collections. Comma-separated values automatically create arrays without requiring special operators.

Range operators (`..`) generate sequential numeric arrays efficiently for iteration or index creation. Type-specific array creation uses .NET constructors or casting operations to ensure proper data types from initialization.

**Example:**

```powershell
# Array subexpression operator
$emptyArray = @()
$singleElement = @("OneItem")  # Ensures array type
$services = @(Get-Service)

# Comma-separated values
$numbers = 1, 2, 3, 4, 5
$mixed = "text", 123, (Get-Date), $true

# Range operators
$sequence = 1..100
$letters = [char[]]([int][char]'A'..[int][char]'Z')

# Type-specific creation
[string[]]$names = "John", "Jane", "Bob"
[int[]]$values = 1, 2, 3
$byteArray = [byte[]]::new(1024)
```

#### Array Element Access and Modification

Array elements are accessed using zero-based indexing with square bracket notation. PowerShell supports negative indexing where `-1` refers to the last element, `-2` to the second-to-last, and so on. Range indexing allows extraction of multiple elements or array slices.

Individual elements can be modified directly through index assignment, but the overall array size remains fixed. PowerShell arrays are implemented as .NET System.Array objects, which have immutable size characteristics.

**Example:**

```powershell
$data = "A", "B", "C", "D", "E"

# Element access
$first = $data[0]          # "A"
$last = $data[-1]          # "E"  
$second = $data[1]         # "B"

# Range access
$subset = $data[1..3]      # "B", "C", "D"
$lastTwo = $data[-2..-1]   # "D", "E"
$every2nd = $data[0,2,4]   # "A", "C", "E"

# Element modification
$data[0] = "Modified"
$data[-1] = "LastItem"

# Multiple element assignment
$data[1,3] = "X", "Y"      # Sets indices 1 and 3
```

#### Array Expansion and Concatenation

Array concatenation in PowerShell creates new array objects containing elements from the source arrays. The `+` operator performs concatenation operations, while the `+=` operator provides a convenient shorthand for appending elements to existing arrays.

**[Inference]** Each concatenation operation creates a new array object and copies all existing elements, which can impact performance with large arrays or frequent modifications. Understanding this behavior helps explain why specialized collections like ArrayList may be preferred for dynamic array operations.

**Example:**

```powershell
# Array concatenation
$first = 1, 2, 3
$second = 4, 5, 6
$combined = $first + $second        # 1, 2, 3, 4, 5, 6

# Element appending
$array = "A", "B"
$array += "C"                       # Creates new array: "A", "B", "C"
$array += "D", "E"                  # Adds multiple elements

# Mixed type concatenation
$mixed = @("text") + @(123, $true) + @(Get-Date)

# Flattening nested arrays [Inference]
$nested = @(1, 2), @(3, 4), @(5, 6)
$flattened = $nested | ForEach-Object { $_ }  # May not flatten as expected
$reallyFlattened = @($nested | ForEach-Object { $_ | ForEach-Object { $_ } })
```

### Array Methods and Properties

#### Core Array Properties

PowerShell arrays inherit properties from the .NET System.Array class, providing essential information about array characteristics. The `Length` and `Count` properties return the number of elements, while `Rank` indicates the number of dimensions for multi-dimensional arrays.

These properties are read-only and reflect the current array state. **[Unverified]** The `LongLength` property provides support for arrays exceeding 32-bit index limits, though such large arrays are uncommon in typical PowerShell scenarios.

**Example:**

```powershell
$data = 1..1000

# Basic properties
$data.Length                # 1000
$data.Count                 # 1000 (equivalent to Length)
$data.Rank                  # 1 (single dimension)

# Index boundaries
$data.GetLowerBound(0)      # 0
$data.GetUpperBound(0)      # 999

# Type information
$data.GetType().Name        # Object[]
$data.GetType().BaseType    # System.Array
```

#### Array Search and Query Methods

.NET array methods provide efficient searching and querying capabilities beyond basic PowerShell operations. These methods often perform better than pipeline-based alternatives for simple operations and support predicate-based searching through delegates.

**[Inference]** Method performance generally exceeds equivalent pipeline operations because they execute at the .NET runtime level without PowerShell's object wrapper overhead.

**Example:**

```powershell
$numbers = 1, 5, 3, 8, 2, 9, 4

# Search methods
$numbers.Contains(5)                    # True
$index = $numbers.IndexOf(8)            # 3
$lastIndex = $numbers.LastIndexOf(2)    # 4

# Existence checking
$exists = [Array]::Exists($numbers, [Predicate[int]]{param($x) $x -gt 7})  # True
$found = [Array]::Find($numbers, [Predicate[int]]{param($x) $x -gt 7})     # 8
$all = [Array]::FindAll($numbers, [Predicate[int]]{param($x) $x -gt 3})    # 5, 8, 9, 4

# Binary search (requires sorted array)
$sorted = $numbers | Sort-Object
$position = [Array]::BinarySearch($sorted, 5)
```

#### Array Manipulation Methods

Static Array methods provide functionality for sorting, reversing, and copying array contents. These methods modify arrays in-place when possible, offering performance advantages over creating new array objects.

**[Inference]** In-place modifications can be more memory-efficient than pipeline operations that create new objects, particularly important for large arrays or memory-constrained environments.

**Example:**

```powershell
$original = 5, 1, 9, 3, 7, 2

# Copying arrays
$copy = [Array]::CreateInstance([int], $original.Length)
[Array]::Copy($original, $copy, $original.Length)

# In-place modifications
$mutable = $original.Clone()
[Array]::Sort($mutable)                 # Sorts in-place
[Array]::Reverse($mutable)              # Reverses in-place

# Resize operations (creates new array)
[Array]::Resize([ref]$mutable, 10)      # Resizes to 10 elements

# Clear operations  
[Array]::Clear($mutable, 2, 3)          # Clears 3 elements starting at index 2
```

### Multi-dimensional Arrays

#### Rectangular Array Creation

Multi-dimensional arrays in PowerShell use .NET's rectangular array structure where all dimensions have fixed sizes. These arrays are created using the `New-Object` cmdlet with dimension specifications or through .NET constructor calls.

Rectangular arrays provide efficient memory layout and direct indexing capabilities but require predetermined dimensions. **[Inference]** They are most suitable for mathematical operations, matrices, or structured data with known dimensions.

**Example:**

```powershell
# 2D array creation
$matrix = New-Object 'int[,]' 3, 4      # 3 rows, 4 columns
$grid = [int[,]]::new(5, 5)             # 5x5 grid

# 3D array creation
$cube = New-Object 'string[,,]' 2, 3, 4 # 2x3x4 three-dimensional array

# Element access and assignment
$matrix[0, 1] = 42
$matrix[2, 3] = 99
$value = $matrix[1, 2]

# Dimension information
$matrix.Rank                            # 2
$matrix.GetLength(0)                    # 3 (rows)
$matrix.GetLength(1)                    # 4 (columns)
$matrix.Length                          # 12 (total elements)
```

#### Jagged Array Implementation

Jagged arrays consist of arrays containing other arrays, allowing variable-length sub-arrays within the same structure. This flexibility accommodates irregular data patterns but requires more complex indexing and iteration logic.

**[Inference]** Jagged arrays offer memory efficiency for sparse data structures and provide flexibility for varying row lengths, making them suitable for representing hierarchical or irregular data patterns.

**Example:**

```powershell
# Jagged array creation
$jagged = @(
    @(1, 2, 3),
    @(4, 5),
    @(6, 7, 8, 9, 10)
)

# Alternative creation
$jaggedArray = New-Object 'int[][]' 3
$jaggedArray[0] = @(1, 2, 3)
$jaggedArray[1] = @(4, 5)
$jaggedArray[2] = @(6, 7, 8, 9, 10)

# Element access
$value = $jagged[0][2]                  # 3
$subArray = $jagged[1]                  # @(4, 5)

# Iteration
for ($i = 0; $i -lt $jagged.Length; $i++) {
    for ($j = 0; $j -lt $jagged[$i].Length; $j++) {
        "Row $i, Col $j: $($jagged[$i][$j])"
    }
}
```

#### Multi-dimensional Array Operations

Working with multi-dimensional arrays requires understanding of dimension boundaries, iteration patterns, and access methods. PowerShell's pipeline operations may not work intuitively with multi-dimensional structures, often requiring explicit loops or .NET methods.

**[Inference]** Performance considerations become more significant with multi-dimensional arrays due to memory layout and access patterns. Row-major order access typically provides better cache performance than column-major access in .NET arrays.

**Example:**

```powershell
# Matrix operations
$matrixA = New-Object 'int[,]' 2, 2
$matrixB = New-Object 'int[,]' 2, 2

# Initialize matrices
$matrixA[0,0] = 1; $matrixA[0,1] = 2
$matrixA[1,0] = 3; $matrixA[1,1] = 4

$matrixB[0,0] = 5; $matrixB[0,1] = 6  
$matrixB[1,0] = 7; $matrixB[1,1] = 8

# Matrix multiplication [Inference]
$result = New-Object 'int[,]' 2, 2
for ($i = 0; $i -lt 2; $i++) {
    for ($j = 0; $j -lt 2; $j++) {
        $sum = 0
        for ($k = 0; $k -lt 2; $k++) {
            $sum += $matrixA[$i,$k] * $matrixB[$k,$j]
        }
        $result[$i,$j] = $sum
    }
}

# Display results
for ($i = 0; $i -lt 2; $i++) {
    for ($j = 0; $j -lt 2; $j++) {
        Write-Host -NoNewline "$($result[$i,$j]) "
    }
    Write-Host ""
}
```

### ArrayList vs Array Performance

#### Array Performance Characteristics

Standard PowerShell arrays are implemented as fixed-size .NET System.Array objects. **[Inference]** Adding elements requires creating new arrays and copying existing elements, resulting in O(n) complexity for append operations. This becomes increasingly expensive as array size grows, particularly noticeable with thousands of elements.

Memory allocation patterns for array growth can lead to significant overhead in scenarios requiring frequent modifications. **[Inference]** Each append operation potentially doubles memory usage temporarily during the copy process.

**Example:**

```powershell
# Performance test - Array concatenation
$array = @()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

for ($i = 0; $i -lt 10000; $i++) {
    $array += $i  # O(n) operation - creates new array each time
}

$stopwatch.Stop()
"Array append time: $($stopwatch.ElapsedMilliseconds) ms"
"Final array size: $($array.Count)"
```

#### ArrayList Performance Benefits

`System.Collections.ArrayList` provides dynamic resizing capabilities with amortized O(1) append performance. **[Inference]** The ArrayList automatically manages internal buffer sizing, typically doubling capacity when expansion is needed, which provides better performance characteristics for frequently modified collections.

ArrayList objects support the same indexing operations as arrays but offer additional methods for insertion, removal, and capacity management. **[Unverified]** The performance advantage becomes particularly pronounced with collections exceeding several hundred elements.

**Example:**

```powershell
# Performance test - ArrayList
$arrayList = [System.Collections.ArrayList]::new()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

for ($i = 0; $i -lt 10000; $i++) {
    $null = $arrayList.Add($i)  # O(1) amortized - much faster
}

$stopwatch.Stop()
"ArrayList add time: $($stopwatch.ElapsedMilliseconds) ms"
"Final ArrayList size: $($arrayList.Count)"

# ArrayList-specific operations
$arrayList.Insert(0, "First")          # Insert at specific position
$arrayList.Remove(5000)                # Remove specific value
$arrayList.RemoveAt(100)               # Remove at specific index
$arrayList.TrimToSize()                # Optimize memory usage
```

#### Generic Collections Performance

.NET generic collections like `List<T>` provide type safety and performance benefits over ArrayList by avoiding boxing/unboxing operations with value types. **[Inference]** Generic collections typically offer the best performance for homogeneous data types in PowerShell scenarios requiring dynamic sizing.

Type-specific generic collections eliminate the performance overhead of object casting and provide compile-time type checking benefits. **[Inference]** For numeric data or specific object types, generic collections represent the optimal choice for performance-critical applications.

**Example:**

```powershell
# Generic List creation
$intList = [System.Collections.Generic.List[int]]::new()
$stringList = [System.Collections.Generic.List[string]]::new()

# Performance comparison - Generic List
$genericList = [System.Collections.Generic.List[int]]::new()
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

for ($i = 0; $i -lt 10000; $i++) {
    $genericList.Add($i)  # Type-safe, no boxing overhead
}

$stopwatch.Stop()
"Generic List add time: $($stopwatch.ElapsedMilliseconds) ms"

# Generic List methods
$genericList.AddRange(20000..25000)    # Add multiple elements
$genericList.BinarySearch(15000)      # Efficient searching
$genericList.Sort()                    # In-place sorting
$capacity = $genericList.Capacity      # Current capacity
$genericList.TrimExcess()              # Minimize memory usage
```

#### Performance Comparison Summary

**[Inference]** Performance differences between collection types become significant with larger datasets and frequent modifications. Arrays excel for fixed-size scenarios and provide the simplest syntax. ArrayList offers good performance for dynamic collections without type requirements. Generic collections provide optimal performance for type-specific scenarios.

**Key points:**

- Use arrays for fixed-size collections or when maximum simplicity is required
- Choose ArrayList for dynamic collections with mixed data types
- Prefer generic collections (`List<T>`) for type-specific dynamic collections
- Consider memory usage patterns and modification frequency when selecting collection types
- **[Unverified]** Profile performance in your specific use case as results can vary based on data size and usage patterns

**Example:**

```powershell
# Comprehensive performance comparison
function Test-CollectionPerformance {
    param([int]$ElementCount = 10000)
    
    # Array test
    $array = @()
    $arrayTime = (Measure-Command {
        for ($i = 0; $i -lt $ElementCount; $i++) {
            $array += $i
        }
    }).TotalMilliseconds
    
    # ArrayList test  
    $arrayList = [System.Collections.ArrayList]::new()
    $arrayListTime = (Measure-Command {
        for ($i = 0; $i -lt $ElementCount; $i++) {
            $null = $arrayList.Add($i)
        }
    }).TotalMilliseconds
    
    # Generic List test
    $genericList = [System.Collections.Generic.List[int]]::new()
    $genericTime = (Measure-Command {
        for ($i = 0; $i -lt $ElementCount; $i++) {
            $genericList.Add($i)
        }
    }).TotalMilliseconds
    
    # Results
    "Performance Results for $ElementCount elements:"
    "Array:        $([math]::Round($arrayTime, 2)) ms"
    "ArrayList:    $([math]::Round($arrayListTime, 2)) ms"
    "Generic List: $([math]::Round($genericTime, 2)) ms"
    
    # Performance ratios [Inference]
    "ArrayList is $([math]::Round($arrayTime / $arrayListTime, 1))x faster than Array"
    "Generic List is $([math]::Round($arrayTime / $genericTime, 1))x faster than Array"
}

Test-CollectionPerformance -ElementCount 5000
```

**Key Points** PowerShell arrays provide flexible data structures with multiple creation methods, comprehensive manipulation capabilities, and integration with .NET array functionality. Understanding the performance characteristics of different collection types enables optimal selection for specific use cases. Multi-dimensional arrays support complex data structures but require careful consideration of access patterns and iteration methods. ArrayList and generic collections offer significant performance advantages for dynamic collection scenarios where frequent modifications are required.

---

