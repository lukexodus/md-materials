## PowerShell Conditional Logic


### If, ElseIf, Else Statements

PowerShell's `If` statement evaluates boolean expressions and executes code blocks based on the results. The basic syntax follows a straightforward pattern where conditions are tested sequentially until a true condition is found.

```powershell
if ($condition) {
    # Code block executed if condition is true
} elseif ($anotherCondition) {
    # Code block executed if first condition is false and this condition is true
} else {
    # Code block executed if all previous conditions are false
}
```

**Key points:**

- Conditions must be enclosed in parentheses
- Code blocks must be enclosed in curly braces
- Multiple `elseif` statements can be chained together
- The `else` block is optional and executes when all previous conditions are false

**Example:**

```powershell
$score = 85

if ($score -ge 90) {
    Write-Host "Grade: A"
} elseif ($score -ge 80) {
    Write-Host "Grade: B"
} elseif ($score -ge 70) {
    Write-Host "Grade: C"
} elseif ($score -ge 60) {
    Write-Host "Grade: D"
} else {
    Write-Host "Grade: F"
}
```

### Comparison Operators in Conditional Logic

PowerShell uses specific comparison operators that differ from many other programming languages:

- `-eq` (equal)
- `-ne` (not equal)
- `-gt` (greater than)
- `-ge` (greater than or equal)
- `-lt` (less than)
- `-le` (less than or equal)
- `-like` (wildcard matching)
- `-match` (regular expression matching)
- `-contains` (array contains value)
- `-in` (value in array)

### Logical Operators

Combine multiple conditions using logical operators:

- `-and` (logical AND)
- `-or` (logical OR)
- `-not` or `!` (logical NOT)

**Example:**

```powershell
if (($age -ge 18) -and ($hasLicense -eq $true)) {
    Write-Host "Can drive"
}
```

### Switch Statements

The `Switch` statement provides an efficient way to test a single expression against multiple values. It's particularly useful when you have many possible conditions to test against the same variable.

```powershell
switch ($expression) {
    value1 { # Code block for value1 }
    value2 { # Code block for value2 }
    default { # Code block for default case }
}
```

**Key points:**

- More efficient than multiple `if-elseif` statements for testing one variable against many values
- Supports pattern matching, regular expressions, and wildcards
- Can use `break` to exit the switch after a match
- Without `break`, execution continues to subsequent matching cases
- The `default` case is optional and executes when no other cases match

**Example:**

```powershell
$dayOfWeek = (Get-Date).DayOfWeek

switch ($dayOfWeek) {
    "Monday" { 
        Write-Host "Start of work week"
        break
    }
    "Friday" { 
        Write-Host "TGIF!"
        break
    }
    { $_ -in @("Saturday", "Sunday") } {
        Write-Host "Weekend!"
        break
    }
    default { 
        Write-Host "Midweek day: $_"
    }
}
```

### Advanced Switch Features

#### Wildcard Matching

```powershell
switch -Wildcard ($filename) {
    "*.txt" { Write-Host "Text file" }
    "*.log" { Write-Host "Log file" }
    "temp*" { Write-Host "Temporary file" }
}
```

#### Regular Expression Matching

```powershell
switch -Regex ($input) {
    "^\d+$" { Write-Host "Numbers only" }
    "^[A-Za-z]+$" { Write-Host "Letters only" }
    "\s" { Write-Host "Contains whitespace" }
}
```

#### Processing Arrays

```powershell
$numbers = @(1, 2, 3, 4, 5)
switch ($numbers) {
    { $_ -gt 3 } { Write-Host "$_ is greater than 3" }
    { $_ -le 2 } { Write-Host "$_ is less than or equal to 2" }
}
```

### Nested Conditionals

Nested conditionals involve placing conditional statements inside other conditional statements. While powerful, they require careful structuring to maintain readability.

**Example:**

```powershell
if ($user.IsActive) {
    if ($user.Role -eq "Admin") {
        if ($user.LastLogin -gt (Get-Date).AddDays(-30)) {
            Write-Host "Active admin with recent login"
        } else {
            Write-Host "Active admin but stale login"
        }
    } else {
        Write-Host "Active regular user"
    }
} else {
    Write-Host "Inactive user"
}
```

### Conditional Logic with Pipeline Operations

PowerShell's pipeline integrates well with conditional logic through cmdlets like `Where-Object`:

```powershell
Get-Process | Where-Object { $_.CPU -gt 100 -and $_.WorkingSet -gt 50MB }
```

### Best Practices for Conditional Logic

#### Code Readability and Maintainability

Write conditions that clearly express intent. Use descriptive variable names and avoid complex nested conditions when possible.

**Example of clear conditional logic:**

```powershell
$isValidUser = ($user.IsActive -eq $true) -and ($user.HasPermission -eq $true)
$isWithinBusinessHours = ((Get-Date).Hour -ge 9) -and ((Get-Date).Hour -lt 17)

if ($isValidUser -and $isWithinBusinessHours) {
    # Process user request
}
```

#### Performance Considerations

Order conditions from most likely to least likely when using `if-elseif` chains. This reduces the number of evaluations needed on average.

Use `switch` statements instead of long `if-elseif` chains when testing a single variable against multiple values. [Inference] Switch statements are generally more efficient for multiple value comparisons.

#### Error Prevention

Always use explicit comparison operators rather than relying on implicit boolean conversion:

```powershell
# Preferred - explicit
if ($variable -eq $null) { }

# Avoid - implicit
if (!$variable) { }
```

Validate input before using it in conditional logic:

```powershell
if (($input -is [string]) -and ($input.Length -gt 0)) {
    # Process valid string input
}
```

#### Avoiding Common Pitfalls

**String Comparisons:** PowerShell string comparisons are case-insensitive by default. Use `-ceq` for case-sensitive comparisons when needed.

**Null Handling:** Test for `$null` explicitly, as PowerShell's truthiness evaluation can be unexpected:

```powershell
# This may not work as expected if $array is empty
if ($array) { }

# Better approach
if ($null -ne $array -and $array.Count -gt 0) { }
```

**Array Comparisons:** When comparing arrays or collections, use appropriate operators:

```powershell
# Check if array contains value
if ($array -contains $value) { }

# Check if value exists in array
if ($value -in $array) { }
```

#### Refactoring Complex Conditionals

Break complex conditional logic into functions or use intermediate variables:

```powershell
function Test-UserEligibility {
    param($User, $Service)
    
    $hasValidSubscription = $User.Subscription.IsActive -and 
                           ($User.Subscription.ExpiryDate -gt (Get-Date))
    $hasRequiredRole = $User.Role -in @("Premium", "Admin")
    $serviceAvailable = $Service.Status -eq "Available"
    
    return $hasValidSubscription -and $hasRequiredRole -and $serviceAvailable
}

if (Test-UserEligibility -User $currentUser -Service $requestedService) {
    # Grant access
}
```

**Key points for maintainable conditional logic:**

- Keep conditions simple and readable
- Use meaningful variable names
- Extract complex logic into functions
- Order conditions by likelihood for performance
- Handle edge cases like null values explicitly
- Use appropriate comparison operators for the data type
- Consider using `switch` for multiple value comparisons
- Document complex conditional logic with comments

---

