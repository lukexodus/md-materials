## Variables and Data Types


### Variable Declaration and Assignment

#### Variable Naming and Declaration

PowerShell variables use the dollar sign ($) prefix followed by a variable name that can contain letters, numbers, and underscores. Variable names are case-insensitive and can begin with letters or underscores but not numbers. PowerShell supports Unicode characters in variable names, enabling international language support, though ASCII characters remain the standard convention.

Variable declaration occurs implicitly through assignment, requiring no explicit declaration statement like many programming languages. The assignment operator (=) creates variables automatically when first used, with PowerShell inferring the appropriate data type based on the assigned value. Variables can be reassigned different data types throughout their lifetime, demonstrating PowerShell's dynamic typing capabilities.

Special variable naming rules apply to certain contexts. Variables containing spaces or special characters require enclosure in curly braces, such as `${My Variable}` or `${C:\Program Files}`. This syntax enables variable names that match file paths or contain characters normally forbidden in identifiers.

#### Assignment Operators and Techniques

PowerShell provides multiple assignment operators beyond basic assignment. The compound assignment operators include `+=` for addition assignment, `-=` for subtraction assignment, `*=` for multiplication assignment, and `/=` for division assignment. These operators perform the specified operation and assign the result back to the variable in a single statement.

Multiple variable assignment allows simultaneous assignment of values to multiple variables using comma separation. The syntax `$var1, $var2, $var3 = "value1", "value2", "value3"` assigns corresponding values to each variable. If fewer values than variables are provided, remaining variables receive `$null`. Conversely, if more values than variables are provided, the last variable receives an array containing the remaining values.

Array destructuring enables extracting individual elements from arrays into separate variables. The assignment `$first, $second, $rest = @(1, 2, 3, 4, 5)` assigns 1 to `$first`, 2 to `$second`, and an array containing 3, 4, 5 to `$rest`. This technique proves valuable for parsing structured data and function return values.

### PowerShell Data Types

#### String Data Type

Strings in PowerShell support both single-quoted and double-quoted syntax, with distinct behaviors regarding variable expansion and escape sequences. Single-quoted strings treat content literally, preserving all characters exactly as written without interpreting variables or escape sequences. Double-quoted strings enable variable substitution and escape sequence processing, making them suitable for dynamic string construction.

String interpolation within double-quoted strings allows embedding variable values and expressions directly into string literals. The syntax `"Hello $name"` substitutes the value of `$name` variable into the string. Complex expressions require subexpression syntax `$()`, enabling embedded calculations like `"Result: $(2 + 3)"`. This capability facilitates dynamic string generation without concatenation operators.

Here-strings provide multi-line string support using `@" "@` for expandable here-strings and `@' '@` for literal here-strings. These constructs preserve formatting, whitespace, and line breaks exactly as written, making them ideal for embedding code snippets, SQL queries, or formatted text blocks within scripts.

#### Numeric Data Types

PowerShell automatically handles numeric data types based on value magnitude and precision requirements. Integer values default to `[System.Int32]` for values within 32-bit signed integer range, automatically promoting to `[System.Int64]` for larger values. Decimal values default to `[System.Double]` for floating-point arithmetic, providing standard double-precision calculations.

Numeric literals support various formats including hexadecimal (`0x` prefix), binary (`0b` prefix in PowerShell 7+), and scientific notation (`1.23e4`). Type suffixes enable explicit numeric type specification, such as `100L` for long integers, `3.14D` for decimal, or `2.5F` for single-precision float.

Arithmetic operations between different numeric types follow .NET promotion rules, typically promoting to the more precise or wider type. Mixed integer and floating-point operations result in floating-point values, while operations between different integer types promote to the larger type to prevent overflow.

#### Array Data Type

PowerShell arrays are heterogeneous collections capable of storing mixed data types within a single array structure. Array creation uses comma-separated values `@(1, "text", $true)` or the array subexpression operator `@()` for empty arrays or single-element arrays that should remain arrays rather than scalar values.

Array indexing uses square bracket notation with zero-based indexing. Negative indices access elements from the array end, where `$array[-1]` retrieves the last element and `$array[-2]` retrieves the second-to-last element. Range operators enable slice operations, such as `$array[1..3]` for elements at indices 1, 2, and 3.

Dynamic array modification occurs through addition operators, where `$array += "new item"` appends elements to existing arrays. However, this operation creates a new array rather than modifying the existing one, which can impact performance for large datasets. The `ArrayList` class provides better performance for frequently modified collections.

#### Hashtable Data Type

Hashtables store key-value pairs using associative array semantics, enabling efficient data lookup and storage. Creation syntax uses `@{key1="value1"; key2="value2"}` or the `[hashtable]` type accelerator with various initialization methods. Keys must be unique within a hashtable, while values can be any PowerShell data type including nested hashtables and arrays.

Hashtable access supports both dot notation `$hash.key1` and bracket notation `$hash["key1"]` for retrieving values. Dot notation requires keys that follow PowerShell identifier naming rules, while bracket notation supports any string key including those with spaces or special characters. Dynamic key access uses variables within brackets, such as `$hash[$keyVariable]`.

Hashtable enumeration through `foreach` loops or the `.GetEnumerator()` method returns key-value pairs as `DictionaryEntry` objects. The `.Keys` and `.Values` properties provide collections of keys and values respectively, enabling various iteration patterns and data processing techniques.

### Type Conversion and Casting

#### Implicit Type Conversion

PowerShell performs automatic type conversion when operations require compatible data types. String concatenation converts numeric values to strings when using the `+` operator with string operands. Numeric operations attempt to convert string representations of numbers to appropriate numeric types for arithmetic calculations.

Boolean context conversion follows specific rules where empty strings, zero values, null references, and empty collections evaluate to `$false`, while non-empty strings, non-zero numbers, and populated collections evaluate to `$true`. This enables conditional logic using various data types without explicit boolean conversion.

Collection flattening occurs when arrays are passed to cmdlets expecting pipeline input, with PowerShell automatically enumerating array elements. The comma operator `,` forces array preservation, preventing automatic flattening when array structure must be maintained through pipeline operations.

#### Explicit Type Casting

Type casting uses square bracket notation to specify target data types, such as `[int]$stringNumber` to convert string representations to integers. Type casting can fail with exceptions if conversion is impossible, requiring error handling for robust script operation. The `-as` operator provides safe casting that returns `$null` instead of throwing exceptions for invalid conversions.

Common type accelerators simplify casting operations for frequently used .NET types. Examples include `[string]`, `[int]`, `[double]`, `[bool]`, `[array]`, and `[hashtable]`. These accelerators provide shorter syntax than full .NET type names like `[System.String]` or `[System.Int32]`.

Custom type conversion can be implemented through PowerShell classes or by leveraging .NET conversion methods. The `[System.Convert]` class provides extensive conversion capabilities between various data types, while PowerShell's type system enables custom conversion operators for user-defined types.

#### Type Validation and Constraints

Variable type constraints enforce specific data types throughout variable lifetime using attribute syntax like `[int]$number = 42`. Once constrained, attempts to assign incompatible values trigger automatic conversion or generate errors if conversion fails. This provides type safety similar to statically typed languages while maintaining PowerShell's dynamic nature.

Parameter validation attributes extend type constraints to function parameters, enabling comprehensive input validation. Attributes like `[ValidateRange()]`, `[ValidateSet()]`, and `[ValidatePattern()]` provide additional constraints beyond basic type checking, ensuring data integrity and preventing invalid parameter values.

### Variable Scope Basics

#### Scope Hierarchy and Rules

PowerShell implements hierarchical variable scoping with four primary scope levels: Global, Script, Local, and Private. Global scope contains variables accessible throughout the entire PowerShell session, persisting across function calls and script executions. Script scope encompasses variables defined within a script file, accessible throughout that script but isolated from other scripts.

Local scope represents the current execution context, typically within a function or script block. Variables created in local scope are visible to child scopes but not to parent or sibling scopes. Private scope restricts variable visibility to the exact scope where they're defined, preventing access from child scopes.

Scope inheritance allows child scopes to access variables from parent scopes through the scope chain. However, variable assignment in child scopes creates new local variables rather than modifying parent scope variables, unless explicitly specified using scope modifiers.

#### Scope Modifiers and Access

Explicit scope modification uses scope modifiers like `$global:variableName`, `$script:variableName`, `$local:variableName`, and `$private:variableName` to control variable access and modification across scope boundaries. These modifiers enable reading from or writing to variables in specific scopes regardless of current execution context.

The `Set-Variable` cmdlet provides advanced scope manipulation through its `-Scope` parameter, enabling programmatic variable creation and modification in specific scopes. This approach offers more control than direct assignment and supports scope specification through numeric values where 0 represents local scope, 1 represents parent scope, and so forth.

Function parameter scope follows special rules where parameters create local variables within the function scope. However, reference types like arrays and hashtables can be modified by functions, affecting the original objects in calling scopes. Understanding reference versus value semantics is crucial for managing data integrity across scope boundaries.

#### Scope Best Practices

Minimizing global variable usage prevents naming conflicts and reduces unintended side effects between scripts and functions. Local variables should be preferred for temporary calculations and intermediate results, while script scope variables suit data sharing within single script files.

Explicit scope specification improves code clarity and prevents accidental variable shadowing, where local variables hide identically named variables in parent scopes. Using descriptive variable names reduces the likelihood of naming conflicts across different scope levels.

Variable initialization at appropriate scope levels ensures predictable behavior and prevents references to undefined variables. Functions should accept necessary data through parameters rather than relying on variables from outer scopes, promoting modularity and testability.

**Key points** for effective variable usage: Use meaningful variable names following PowerShell conventions, understand the distinction between reference and value types for proper data handling, leverage type constraints for input validation, and apply appropriate scoping to prevent unintended variable interactions.

**Example** demonstrating variable concepts:

```powershell
# Variable declaration and assignment
$name = "PowerShell"           # String variable
$version = 7.3                 # Numeric variable (Double)
$isActive = $true              # Boolean variable
$servers = @("web01", "db01")  # Array variable
$config = @{env="prod"; port=443} # Hashtable variable

# Type casting examples
[int]$stringNumber = "123"     # Explicit casting
$result = "5" * 3              # Implicit conversion (results in "555")
$mathResult = [int]"5" * 3     # Explicit conversion (results in 15)

# Scope demonstration
$global:appName = "MyApp"      # Global scope variable

function Test-Scope {
    $local:tempValue = "temporary"  # Local scope
    $script:scriptLevel = "script"  # Script scope
    Write-Output "Global: $global:appName"
    Write-Output "Local: $tempValue"
}

# Array and hashtable operations
$servers += "app01"            # Array expansion
$config.timeout = 30           # Hashtable modification
$config["retry"] = 3           # Alternative hashtable syntax
```

**Output** of the example:

```
Global: MyApp
Local: temporary
```

**Next steps**: Practice creating variables with different data types, experiment with type casting and conversion scenarios, explore scope behavior through function and script examples, and understand the performance implications of different collection types for specific use cases.

---

