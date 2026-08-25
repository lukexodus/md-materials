## PowerShell Script Blocks


### Creating and Using Script Blocks

A script block is a collection of statements or expressions that can be treated as a single unit. Script blocks are enclosed in curly braces `{}` and can contain any valid PowerShell code. They serve as the foundation for functions, cmdlets, and various PowerShell constructs.

```powershell
# Basic script block creation
$scriptBlock = { Write-Host "Hello from script block" }

# Script block with multiple statements
$complexBlock = {
    $date = Get-Date
    Write-Host "Current time: $date"
    Get-Process | Select-Object -First 5
}
```

**Key points:**

- Script blocks are objects of type `[System.Management.Automation.ScriptBlock]`
- They can be stored in variables, passed as parameters, and executed later
- Script blocks don't execute when defined; they execute when invoked
- They can contain any PowerShell code including functions, variables, and cmdlets

### Executing Script Blocks

Script blocks can be executed using several methods:

**Using the Call Operator `&`:**

```powershell
$block = { Get-Date }
& $block
```

**Using the Dot Sourcing Operator `.`:**

```powershell
$block = { $message = "Hello World" }
. $block
Write-Host $message  # Variable is available in current scope
```

**Using the Invoke() Method:**

```powershell
$block = { param($name) "Hello, $name!" }
$result = $block.Invoke("PowerShell")
```

### Script Blocks with Parameters

Script blocks can accept parameters just like functions, making them more flexible and reusable.

```powershell
# Script block with parameters
$mathBlock = {
    param(
        [int]$Number1,
        [int]$Number2,
        [string]$Operation = "Add"
    )
    
    switch ($Operation) {
        "Add" { $Number1 + $Number2 }
        "Subtract" { $Number1 - $Number2 }
        "Multiply" { $Number1 * $Number2 }
        "Divide" { 
            if ($Number2 -ne 0) { $Number1 / $Number2 } 
            else { Write-Error "Division by zero" }
        }
    }
}

# Execute with parameters
$result = & $mathBlock -Number1 10 -Number2 5 -Operation "Multiply"
```

**Key points for parameterized script blocks:**

- Parameters are defined using the `param()` block at the beginning
- Parameters can have types, default values, and attributes
- Parameters can be passed positionally or by name
- Validation attributes like `[Parameter(Mandatory)]` can be used

### Invoke-Command with Script Blocks

`Invoke-Command` executes script blocks locally or on remote computers. It's a powerful cmdlet for running commands across multiple systems.

#### Local Execution

```powershell
# Execute script block locally
Invoke-Command -ScriptBlock { Get-Service | Where-Object Status -eq "Running" }

# Execute with parameters
$serviceBlock = {
    param($ServiceName)
    Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
}

Invoke-Command -ScriptBlock $serviceBlock -ArgumentList "Spooler"
```

#### Remote Execution

```powershell
# Execute on remote computer
$remoteBlock = {
    Get-WmiObject -Class Win32_OperatingSystem | 
    Select-Object Caption, Version, TotalVisibleMemorySize
}

Invoke-Command -ComputerName "Server01" -ScriptBlock $remoteBlock

# Execute on multiple computers
$computers = @("Server01", "Server02", "Workstation01")
Invoke-Command -ComputerName $computers -ScriptBlock $remoteBlock
```

#### Using Sessions with Invoke-Command

```powershell
# Create persistent session
$session = New-PSSession -ComputerName "Server01"

# Execute multiple commands in same session
Invoke-Command -Session $session -ScriptBlock { $env:COMPUTERNAME }
Invoke-Command -Session $session -ScriptBlock { Get-Location }

# Clean up session
Remove-PSSession $session
```

**Key points for Invoke-Command:**

- Use `-ArgumentList` to pass parameters to the script block
- Remote execution requires PowerShell remoting to be enabled
- Sessions maintain state between command executions
- Always clean up sessions when finished to free resources

### Advanced Script Block Usage

#### Script Blocks as Pipeline Input

```powershell
# Using script blocks with ForEach-Object
1..5 | ForEach-Object { "Number: $_; Square: $($_ * $_)" }

# Using script blocks with Where-Object
Get-Process | Where-Object { $_.WorkingSet -gt 50MB }
```

#### Script Blocks in Hash Tables

```powershell
# Calculated properties using script blocks
Get-Process | Select-Object Name, 
    @{Name="WorkingSetMB"; Expression={[math]::Round($_.WorkingSet/1MB,2)}},
    @{Name="IsHighMemory"; Expression={$_.WorkingSet -gt 100MB}}
```

### Closures and Variable Capture

Closures occur when script blocks capture variables from their defining scope. This creates a persistent reference to those variables, even after the original scope ends.

#### Basic Variable Capture

```powershell
function New-Counter {
    $count = 0
    
    # Script block captures $count variable
    return {
        $script:count++
        return $script:count
    }
}

$counter1 = New-Counter
$counter2 = New-Counter

& $counter1  # Returns 1
& $counter1  # Returns 2
& $counter2  # Returns 1 (separate instance)
```

#### Variable Capture Behavior

```powershell
$multiplier = 10

# Script block captures current value of $multiplier
$block = { param($x) $x * $multiplier }

$result1 = & $block 5  # Returns 50

# Changing $multiplier affects the script block
$multiplier = 20
$result2 = & $block 5  # Returns 100
```

**Key points about closures:**

- Script blocks capture variables by reference, not by value
- Changes to captured variables affect the script block's behavior
- Closures maintain references to variables even after the defining scope ends
- This can lead to unexpected behavior if not understood properly

#### Avoiding Closure Issues

```powershell
# Problem: All script blocks reference the same variable
$blocks = @()
for ($i = 1; $i -le 3; $i++) {
    # This captures $i by reference
    $blocks += { "Value: $i" }
}

# All blocks output "Value: 4" because $i = 4 after loop
$blocks | ForEach-Object { & $_ }

# Solution: Capture by value using parameters
$blocks = @()
for ($i = 1; $i -le 3; $i++) {
    $blocks += { param($value) "Value: $value" }.GetNewClosure()
}

# Now each block has its own copy of the value
for ($i = 0; $i -lt $blocks.Count; $i++) {
    & $blocks[$i] ($i + 1)
}
```

### GetNewClosure() Method

The `GetNewClosure()` method creates a copy of a script block with its own copy of captured variables:

```powershell
$baseValue = 100

$originalBlock = { $baseValue * 2 }
$closureBlock = $originalBlock.GetNewClosure()

# Change the original variable
$baseValue = 200

& $originalBlock   # Returns 400 (uses current value)
& $closureBlock    # Returns 200 (uses captured value)
```

### Practical Applications

#### Event Handling

```powershell
# Register event with script block
$timer = New-Object System.Timers.Timer
$timer.Interval = 1000

$action = {
    Write-Host "Timer elapsed at $(Get-Date)"
}

Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action $action
```

#### Custom Validation

```powershell
# Custom validation script block
$validateEmail = {
    param($email)
    return $email -match '^[^@]+@[^@]+\.[^@]+$'
}

# Use in parameter validation
function Send-Email {
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ & $validateEmail $_ })]
        [string]$EmailAddress
    )
    
    Write-Host "Sending email to: $EmailAddress"
}
```

#### Configuration and Callbacks

```powershell
# Configuration using script blocks
$config = @{
    LogError = { param($message) Write-Error "ERROR: $message" }
    LogInfo = { param($message) Write-Host "INFO: $message" -ForegroundColor Green }
    ProcessData = { param($data) $data | ConvertTo-Json }
}

# Use configuration
& $config.LogInfo "Starting process"
$result = & $config.ProcessData @{Name="Test"; Value=123}
& $config.LogError "Something went wrong"
```

**Key points for advanced usage:**

- Script blocks enable powerful functional programming patterns
- Closures provide state management capabilities
- Use `GetNewClosure()` when you need isolated copies of captured variables
- Script blocks are essential for event handling and callback mechanisms
- They enable dynamic code execution and configuration patterns
- [Inference] Proper understanding of variable capture is crucial for avoiding subtle bugs
- Consider memory implications when using closures extensively

---

