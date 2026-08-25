## PowerShell Loops


### ForEach-Object Cmdlet

The `ForEach-Object` cmdlet processes each object in a pipeline, making it one of the most commonly used loop constructs in PowerShell. It operates on objects passed through the pipeline and executes a script block for each item.

**Basic Syntax:**

```powershell
Get-Process | ForEach-Object { $_.Name }
Get-ChildItem | ForEach-Object { Write-Host $_.FullName }
```

**Alias Usage:** The cmdlet has several aliases that provide shorter syntax:

- `%` (percent sign)
- `foreach`

```powershell
1..10 | % { $_ * 2 }
Get-Service | foreach { $_.DisplayName }
```

**Advanced Parameters:**

- `-Begin`: Executed once before processing any pipeline objects
- `-Process`: Executed for each pipeline object (default parameter)
- `-End`: Executed once after processing all pipeline objects

```powershell
1..5 | ForEach-Object -Begin { Write-Host "Starting" } -Process { $_ * 2 } -End { Write-Host "Complete" }
```

**Parallel Processing:** PowerShell 7+ supports parallel execution with the `-Parallel` parameter:

```powershell
1..10 | ForEach-Object -Parallel { Start-Sleep 1; $_ } -ThrottleLimit 5
```

### For Loops

Traditional `for` loops provide precise control over iteration with initialization, condition, and increment expressions.

**Basic Syntax:**

```powershell
for ($i = 0; $i -lt 10; $i++) {
    Write-Host "Iteration: $i"
}
```

**Multiple Variable Control:**

```powershell
for ($i = 0, $j = 10; $i -lt $j; $i++, $j--) {
    Write-Host "i: $i, j: $j"
}
```

**Nested For Loops:**

```powershell
for ($i = 1; $i -le 3; $i++) {
    for ($j = 1; $j -le 3; $j++) {
        Write-Host "($i,$j)"
    }
}
```

**Array Iteration:**

```powershell
$array = @("apple", "banana", "cherry")
for ($i = 0; $i -lt $array.Length; $i++) {
    Write-Host "$i : $($array[$i])"
}
```

### While and Do-While Loops

While loops execute code blocks based on conditional expressions, with different timing for condition evaluation.

**While Loop:** Tests the condition before executing the code block:

```powershell
$counter = 0
while ($counter -lt 5) {
    Write-Host "Counter: $counter"
    $counter++
}
```

**Do-While Loop:** Executes the code block at least once, then tests the condition:

```powershell
$input = ""
do {
    $input = Read-Host "Enter 'quit' to exit"
    Write-Host "You entered: $input"
} while ($input -ne "quit")
```

**Do-Until Loop:** Similar to do-while but continues until the condition becomes true:

```powershell
$number = 0
do {
    $number = Get-Random -Minimum 1 -Maximum 100
    Write-Host "Generated: $number"
} until ($number -gt 90)
```

**Infinite Loops with Break Conditions:**

```powershell
while ($true) {
    $response = Read-Host "Continue? (y/n)"
    if ($response -eq "n") { break }
    Write-Host "Processing..."
}
```

### ForEach Statement

The `foreach` statement iterates through collections without using the pipeline, providing better performance for large datasets.

**Basic Syntax:**

```powershell
$fruits = @("apple", "banana", "cherry")
foreach ($fruit in $fruits) {
    Write-Host "Processing: $fruit"
}
```

**Hashtable Iteration:**

```powershell
$hashtable = @{
    Name = "John"
    Age = 30
    City = "Seattle"
}

foreach ($key in $hashtable.Keys) {
    Write-Host "$key : $($hashtable[$key])"
}
```

**File System Operations:**

```powershell
$files = Get-ChildItem -Path "C:\Temp" -Filter "*.txt"
foreach ($file in $files) {
    $content = Get-Content $file.FullName
    Write-Host "$($file.Name) has $($content.Count) lines"
}
```

**Performance Comparison:** The `foreach` statement typically performs faster than `ForEach-Object` for large collections because it doesn't use the pipeline:

```powershell
# Faster for large collections
foreach ($item in $largeArray) { $item.Process() }

# Slower due to pipeline overhead
$largeArray | ForEach-Object { $_.Process() }
```

### Loop Control

Loop control statements modify the normal flow of loop execution.

**Break Statement:** Immediately exits the current loop:

```powershell
for ($i = 1; $i -le 10; $i++) {
    if ($i -eq 5) { break }
    Write-Host $i
}
# Output: 1, 2, 3, 4
```

**Continue Statement:** Skips the remaining code in the current iteration and moves to the next:

```powershell
for ($i = 1; $i -le 5; $i++) {
    if ($i -eq 3) { continue }
    Write-Host $i
}
# Output: 1, 2, 4, 5
```

**Labeled Breaks and Continues:** Control outer loops from inner loops using labels:

```powershell
:outerLoop for ($i = 1; $i -le 3; $i++) {
    for ($j = 1; $j -le 3; $j++) {
        if ($i -eq 2 -and $j -eq 2) {
            break outerLoop
        }
        Write-Host "($i,$j)"
    }
}
```

**Exception Handling in Loops:**

```powershell
foreach ($file in $files) {
    try {
        $content = Get-Content $file -ErrorAction Stop
        # Process content
    }
    catch {
        Write-Warning "Failed to read $file : $($_.Exception.Message)"
        continue
    }
}
```

### Performance Considerations

**Memory Usage:**

- `ForEach-Object` processes objects one at a time, using less memory
- `foreach` statement loads the entire collection into memory first

**Speed Comparison:**

```powershell
# Fastest for arrays
foreach ($item in $array) { }

# Fast for pipeline operations
$array | ForEach-Object { }

# Slowest but most flexible
for ($i = 0; $i -lt $array.Count; $i++) { }
```

**Pipeline vs Non-Pipeline:**

- Use `ForEach-Object` when working with cmdlet output
- Use `foreach` statement when working with pre-existing collections
- Use `for` loops when you need index control

### Advanced Patterns

**Conditional Loop Execution:**

```powershell
$processes = Get-Process
foreach ($process in $processes) {
    switch ($process.ProcessName) {
        "notepad" { Stop-Process $process -Force }
        "calculator" { $process | Select-Object Name, CPU }
        default { continue }
    }
}
```

**Loop with Progress Indication:**

```powershell
$total = $files.Count
$current = 0

foreach ($file in $files) {
    $current++
    Write-Progress -Activity "Processing Files" -Status "File $current of $total" -PercentComplete (($current / $total) * 100)
    # Process file
}
```

**Recursive Directory Processing:**

```powershell
function Process-DirectoryRecursive($path) {
    foreach ($item in Get-ChildItem $path) {
        if ($item.PSIsContainer) {
            Process-DirectoryRecursive $item.FullName
        } else {
            Write-Host "Processing file: $($item.FullName)"
        }
    }
}
```

**Key points**: Choose the appropriate loop type based on your data source and performance requirements. Use `ForEach-Object` for pipeline operations, `foreach` statements for collections, and traditional `for` loops when you need precise index control. Always consider memory usage and execution speed when working with large datasets.

---

