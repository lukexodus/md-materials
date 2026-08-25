## PowerShell Debugging


### Debug Output Commands

PowerShell provides several cmdlets for generating debug information during script execution. These commands offer different levels of visibility and control over diagnostic output.

#### Write-Debug

The `Write-Debug` cmdlet outputs debug messages that are only visible when the `$DebugPreference` variable is set appropriately or when the `-Debug` parameter is used.

**Example:**

```powershell
Write-Debug "Entering function ProcessData"
Write-Debug "Variable value: $myVariable"

# To see debug output
$DebugPreference = "Continue"
# or run with -Debug parameter
./MyScript.ps1 -Debug
```

**Key points:**

- Debug messages are suppressed by default (`$DebugPreference = "SilentlyContinue"`)
- Setting `$DebugPreference = "Continue"` displays all debug messages
- Setting `$DebugPreference = "Inquire"` prompts the user for each debug message
- Debug output appears in a different color (typically yellow) to distinguish from regular output

#### Write-Verbose

The `Write-Verbose` cmdlet provides detailed operational information about script execution, controlled by the `$VerbosePreference` variable.

**Example:**

```powershell
Write-Verbose "Processing file: $fileName"
Write-Verbose "Current progress: $($processedCount)/$($totalCount)"

# Enable verbose output
$VerbosePreference = "Continue"
# or use -Verbose parameter
Get-Process -Verbose
```

**Key points:**

- Verbose messages provide operational details without being as granular as debug messages
- Default behavior suppresses verbose output (`$VerbosePreference = "SilentlyContinue"`)
- Verbose output typically appears in a distinct color (usually yellow or cyan)
- Commonly used in functions that support the `-Verbose` common parameter

#### Write-Warning

The `Write-Warning` cmdlet displays warning messages to alert users about potential issues or non-terminating errors.

**Example:**

```powershell
Write-Warning "File not found, using default configuration"
Write-Warning "Performance may be impacted with current settings"

# Controlling warning display
$WarningPreference = "SilentlyContinue"  # Suppress warnings
$WarningPreference = "Continue"          # Show warnings (default)
```

**Key points:**

- Warnings are displayed by default and appear in a warning color (typically yellow or orange)
- Warnings indicate potential problems but don't stop script execution
- Can be suppressed using `$WarningPreference` or `-WarningAction` parameters
- Different from errors as they don't trigger error handling mechanisms

### PowerShell Debugger

PowerShell includes a built-in interactive debugger that provides comprehensive debugging capabilities for scripts, functions, and modules.

#### Entering the Debugger

The debugger can be invoked through several methods:

**Example:**

```powershell
# Method 1: Set-PSBreakpoint cmdlet
Set-PSBreakpoint -Script "C:\Scripts\MyScript.ps1" -Line 15

# Method 2: Wait-Debugger cmdlet in script
function Test-Function {
    param($InputData)
    Wait-Debugger  # Breaks here when called
    Process-Data $InputData
}

# Method 3: Debug-Runspace for runspace debugging
Debug-Runspace -Runspace $runspace
```

#### Debugger Commands

Once in the debugger, several commands control execution flow:

**Key points:**

- `s` (Step Into): Execute the next statement, entering functions
- `v` (Step Over): Execute the next statement without entering functions
- `o` (Step Out): Continue until exiting the current function
- `c` (Continue): Resume normal execution
- `q` (Quit): Exit the debugger and stop script execution
- `k` (Get Call Stack): Display the current call stack
- `l` (List): Show the current location in the script

### Breakpoints and Step-Through Debugging

Breakpoints allow precise control over script execution by pausing at specific locations or conditions.

#### Line Breakpoints

Line breakpoints pause execution at specific line numbers in scripts.

**Example:**

```powershell
# Set breakpoint at line 25 of a script
Set-PSBreakpoint -Script "C:\Scripts\Process.ps1" -Line 25

# Set multiple line breakpoints
Set-PSBreakpoint -Script "C:\Scripts\Process.ps1" -Line 10,15,20

# View existing breakpoints
Get-PSBreakpoint

# Remove specific breakpoint
Remove-PSBreakpoint -Id 1
```

#### Variable Breakpoints

Variable breakpoints trigger when specified variables are read from or written to.

**Example:**

```powershell
# Break when variable is modified
Set-PSBreakpoint -Variable "criticalData" -Mode Write

# Break when variable is read
Set-PSBreakpoint -Variable "configPath" -Mode Read

# Break on both read and write
Set-PSBreakpoint -Variable "status" -Mode ReadWrite
```

#### Command Breakpoints

Command breakpoints pause execution when specific cmdlets or functions are called.

**Example:**

```powershell
# Break when specific cmdlet is called
Set-PSBreakpoint -Command "Remove-Item"

# Break when custom function is called
Set-PSBreakpoint -Command "Process-UserData"

# Break with additional conditions
Set-PSBreakpoint -Command "Get-ChildItem" -Script "C:\Scripts\FileProcessor.ps1"
```

#### Conditional Breakpoints

[Inference] Conditional breakpoints likely allow breaking only when specified conditions are met, though the exact syntax may vary.

**Example:**

```powershell
# Break when variable meets condition
Set-PSBreakpoint -Script "test.ps1" -Line 15 -Action {
    if ($counter -gt 100) { 
        break 
    }
}
```

### Debugging Remote Sessions

PowerShell supports debugging scripts and runspaces running on remote computers through several mechanisms.

#### Remote Script Debugging

Scripts running in remote PowerShell sessions can be debugged using Enter-PSSession and debugging cmdlets.

**Example:**

```powershell
# Establish remote session
$session = New-PSSession -ComputerName "RemoteServer01"

# Enter remote session
Enter-PSSession $session

# Set breakpoint in remote session
Set-PSBreakpoint -Script "C:\RemoteScripts\Process.ps1" -Line 10

# Run script with debugging
C:\RemoteScripts\Process.ps1
```

#### Remote Runspace Debugging

Background jobs and runspaces on remote systems can be debugged using specialized cmdlets.

**Example:**

```powershell
# Get remote runspaces
$runspaces = Get-Runspace -ComputerName "RemoteServer01"

# Debug specific remote runspace
Debug-Runspace -ComputerName "RemoteServer01" -Runspace $runspaces[0]

# Debug remote job
$job = Start-Job -ScriptBlock { Get-Process } -ComputerName "RemoteServer01"
Debug-Job $job
```

#### Remote Debugging Considerations

**Key points:**

- Network connectivity must be stable for effective remote debugging
- Appropriate permissions required on remote systems
- [Inference] Firewall rules may need configuration for remote debugging ports
- Performance may be impacted by network latency during step-through debugging
- Remote debugging sessions may time out based on PowerShell session configuration

### Best Practices for Troubleshooting Scripts

Effective PowerShell script troubleshooting requires systematic approaches and proper implementation of debugging techniques.

#### Error Handling Strategy

Implement comprehensive error handling to capture and diagnose issues effectively.

**Example:**

```powershell
try {
    $result = Get-Content $filePath -ErrorAction Stop
    Write-Verbose "Successfully read $($result.Count) lines from $filePath"
}
catch [System.IO.FileNotFoundException] {
    Write-Warning "File not found: $filePath"
    Write-Debug "Full path attempted: $(Resolve-Path $filePath -ErrorAction SilentlyContinue)"
}
catch {
    Write-Error "Unexpected error reading file: $_"
    Write-Debug "Error details: $($_.Exception.GetType().FullName)"
}
```

#### Logging Implementation

Establish consistent logging practices for long-term troubleshooting and monitoring.

**Example:**

```powershell
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info','Warning','Error','Debug')]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        'Warning' { Write-Warning $Message }
        'Error'   { Write-Error $Message }
        'Debug'   { Write-Debug $Message }
        'Info'    { Write-Verbose $Message }
    }
    
    Add-Content -Path $global:LogPath -Value $logEntry
}
```

#### Variable State Inspection

Use systematic approaches to examine variable states and object properties during debugging.

**Example:**

```powershell
# Inspect object structure
$myObject | Get-Member
$myObject | Format-List *

# Examine variable types and values
Write-Debug "Variable type: $($myVariable.GetType().FullName)"
Write-Debug "Variable value: $($myVariable | Out-String)"

# Check collection contents
Write-Verbose "Collection count: $($myCollection.Count)"
$myCollection | ForEach-Object { Write-Debug "Item: $_" }
```

#### Performance Debugging

Monitor script performance and identify bottlenecks during execution.

**Example:**

```powershell
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# Code section to measure
Process-LargeDataSet $data

$stopwatch.Stop()
Write-Verbose "Processing completed in $($stopwatch.ElapsedMilliseconds) ms"

# Memory usage monitoring
$beforeMemory = [System.GC]::GetTotalMemory($false)
Process-Data $inputData
$afterMemory = [System.GC]::GetTotalMemory($false)
Write-Debug "Memory used: $($afterMemory - $beforeMemory) bytes"
```

#### Testing and Validation Strategies

**Key points:**

- Use `Test-Path` for file system validation before operations
- Implement parameter validation using `[ValidateScript()]` and similar attributes
- Create unit tests for functions using Pester framework [Unverified - specific framework availability]
- Use `What-If` parameters in functions that make system changes
- Validate input data types and ranges before processing
- Implement dry-run modes for scripts that modify system state

#### Common Debugging Scenarios

**Key points:**

- Path-related issues: Use `Resolve-Path` and `Test-Path` for validation
- Permission problems: Check `Get-Acl` output and run with appropriate privileges
- Module loading failures: Verify module paths with `$env:PSModulePath`
- Pipeline issues: Examine object types at each stage using `Get-Member`
- Scope-related variable problems: Use explicit scope notation (`$global:`, `$script:`)
- Encoding issues with files: Specify encoding explicitly in file operations

**Conclusion:** PowerShell's debugging capabilities provide comprehensive tools for identifying and resolving script issues, from simple output commands to sophisticated breakpoint debugging and remote troubleshooting techniques.

---

