## PowerShell


### Core Concepts

#### Objects vs Text-Based Shells

PowerShell fundamentally differs from traditional command-line interfaces by working with .NET objects rather than plain text. When you run a command like `Get-Process`, PowerShell returns actual process objects with properties and methods, not formatted text strings. This object-oriented approach enables powerful data manipulation and eliminates the need for text parsing that characterizes shells like Bash or Command Prompt.

Traditional shells require tools like `grep`, `awk`, and `sed` to extract and manipulate text output. PowerShell instead allows direct access to object properties using dot notation and provides built-in filtering, sorting, and formatting capabilities that work seamlessly with the underlying data structures.

#### Cmdlet Structure (Verb-Noun)

PowerShell cmdlets follow a consistent Verb-Noun naming convention that makes commands predictable and discoverable. The verb describes the action (Get, Set, New, Remove, Start, Stop, etc.) while the noun identifies the target object or resource (Process, Service, Item, Content, etc.).

**Key points:**

- Verbs are standardized: `Get-Verb` shows all approved verbs
- Nouns can be singular or plural but cmdlets typically use singular forms
- Aliases exist for common cmdlets (`ls` for `Get-ChildItem`, `ps` for `Get-Process`)
- Tab completion works with partial cmdlet names

**Example:**

```powershell
Get-Process      # Retrieves process objects
Set-Location     # Changes current directory
New-Item         # Creates files, directories, or registry entries
Remove-Service   # Uninstalls services
```

#### Parameters and Parameter Sets

PowerShell cmdlets accept parameters that modify their behavior or specify targets. Parameters use a dash prefix and can be positional (order matters) or named (explicitly specified). Many cmdlets define multiple parameter sets - mutually exclusive groups of parameters that provide different ways to accomplish the same task.

Parameter binding occurs automatically based on type, position, and name. PowerShell supports mandatory parameters, default values, parameter validation, and dynamic parameters that appear based on other parameter values.

**Key points:**

- Parameter names can be abbreviated if unambiguous
- Some parameters accept pipeline input by value or property name
- Switch parameters don't require values (`-Recurse` vs `-Path "C:\Temp"`)
- Parameter sets prevent conflicting parameter combinations

**Example:**

```powershell
# Positional parameters
Get-ChildItem "C:\Windows" "*.exe"

# Named parameters
Get-ChildItem -Path "C:\Windows" -Filter "*.exe" -Recurse

# Parameter abbreviation
Get-ChildItem -Pa "C:\Windows" -Fi "*.exe" -Re
```

#### Pipeline Basics

The PowerShell pipeline connects cmdlets by passing objects from one command to the next. Unlike text-based shells that concatenate string output, PowerShell maintains object integrity throughout the pipeline chain. Each cmdlet in the pipeline can access all properties and methods of the objects it receives.

Pipeline input occurs through two mechanisms: ByValue (entire objects) and ByPropertyName (specific properties match parameter names). PowerShell automatically determines the appropriate binding method based on cmdlet parameter definitions and incoming object types.

**Key points:**

- Pipeline processes objects one at a time (streaming)
- Objects retain all properties and methods through pipeline stages
- `$_` or `$PSItem` represents the current pipeline object in script blocks
- Pipeline can be interrupted with `Ctrl+C` during processing

**Example:**

```powershell
# Basic pipeline - objects flow left to right
Get-Process | Where-Object {$_.CPU -gt 100} | Sort-Object CPU -Descending

# Pipeline with property access
Get-Service | Select-Object Name, Status, StartType | Format-Table -AutoSize

# Pipeline input by property name
"notepad","calculator" | Get-Process
```

### Advanced Pipeline Concepts

#### Pipeline Parameter Binding

PowerShell determines how to bind pipeline objects to cmdlet parameters through a sophisticated matching system. The process evaluates ByValue binding first (exact type matches), then ByPropertyName binding (property names match parameter names), and finally attempts type conversion.

Understanding parameter binding helps predict pipeline behavior and troubleshoot unexpected results. The `Trace-Command` cmdlet can reveal the binding process for complex scenarios.

#### Pipeline Variables

Special automatic variables provide pipeline context and control. `$_` represents the current object, while `$PSItem` serves as an alias in PowerShell 3.0+. These variables work within script blocks used by cmdlets like `Where-Object`, `ForEach-Object`, and `Sort-Object`.

### Cmdlet Categories

#### Data Retrieval Cmdlets

PowerShell includes numerous cmdlets for gathering system information and data. These form the foundation of most PowerShell operations and provide objects for further pipeline processing.

**Example:**

```powershell
Get-Process        # Running processes
Get-Service        # System services  
Get-EventLog       # Event log entries
Get-WmiObject      # WMI/CIM data
Get-ChildItem      # File system objects
```

#### Data Manipulation Cmdlets

These cmdlets filter, sort, group, and transform pipeline objects without modifying the original data sources. They excel at preparing data for output or further processing.

**Example:**

```powershell
Where-Object       # Filters objects based on criteria
Sort-Object        # Sorts objects by properties
Group-Object       # Groups objects by property values
Select-Object      # Selects specific properties or objects
Measure-Object     # Calculates statistics on object properties
```

#### Output and Formatting Cmdlets

PowerShell separates data processing from presentation through dedicated formatting cmdlets. These control how objects appear when displayed but don't modify the underlying data.

**Example:**

```powershell
Format-Table       # Tabular display
Format-List        # List format showing all properties
Format-Wide        # Multi-column display of single properties
Out-File          # Sends output to files
Out-GridView      # Interactive grid display
```

### Variables and Data Types

#### Variable Declaration and Scope

PowerShell variables don't require explicit declaration and automatically assume appropriate .NET types based on assigned values. Variable names use the `$` prefix and support various scoping rules that control visibility and lifetime.

Scope modifiers include `$global:`, `$script:`, `$local:`, and `$private:`. PowerShell searches scopes hierarchically, starting with the current scope and moving outward until finding a matching variable name.

**Example:**

```powershell
$string = "Hello World"           # String type
$number = 42                      # Int32 type
$array = @(1,2,3,4,5)            # Object array
$hash = @{Name="John"; Age=30}    # Hashtable
```

#### Type Acceleration and Casting

PowerShell supports explicit type casting using bracket notation before variable assignments or within expressions. Type accelerators provide shortcuts for common .NET types, making scripts more readable and concise.

**Example:**

```powershell
[string]$text = 123              # Forces string type
[datetime]$date = "2024-01-01"   # Converts to DateTime object
[int[]]$numbers = "1","2","3"    # Creates integer array
```

### Control Flow Structures

#### Conditional Logic

PowerShell supports standard conditional constructs with some unique features. The `if` statement works with any expression that can be evaluated as true or false, following .NET truthiness rules where empty collections, null values, and zero evaluate to false.

**Example:**

```powershell
if ($process = Get-Process "notepad" -ErrorAction SilentlyContinue) {
    "Notepad is running with PID: $($process.Id)"
} else {
    "Notepad is not running"
}

switch ($user.Department) {
    "IT" { Grant-AdminRights $user }
    "Finance" { Grant-FinanceAccess $user }
    default { Grant-BasicAccess $user }
}
```

#### Iteration Constructs

PowerShell provides multiple iteration methods, each suited for different scenarios. Traditional loops work alongside pipeline-based iteration for maximum flexibility.

**Example:**

```powershell
# ForEach loop
foreach ($file in Get-ChildItem "*.txt") {
    $content = Get-Content $file.FullName
    # Process content
}

# While loop
while ($processes.Count -gt 10) {
    $processes = Get-Process | Where-Object {$_.CPU -gt 100}
    Start-Sleep -Seconds 5
}

# Pipeline iteration
1..10 | ForEach-Object { "Processing item $_" }
```

### Error Handling

#### Error Types and Categories

PowerShell distinguishes between terminating and non-terminating errors. Terminating errors halt cmdlet execution and can be caught with try-catch blocks. Non-terminating errors allow cmdlets to continue processing remaining input objects.

Error records contain detailed information including exception details, category information, target objects, and script location data. The `$ErrorActionPreference` variable controls default error handling behavior globally.

#### Try-Catch-Finally Blocks

Structured error handling uses try-catch-finally blocks similar to other programming languages. Multiple catch blocks can handle specific exception types, providing granular error recovery options.

**Example:**

```powershell
try {
    $content = Get-Content "nonexistent.txt" -ErrorAction Stop
    # Process content
} catch [System.IO.FileNotFoundException] {
    Write-Warning "File not found, creating default content"
    $content = "Default content"
} catch {
    Write-Error "Unexpected error: $($_.Exception.Message)"
} finally {
    # Cleanup code always executes
    Remove-Variable -Name "content" -ErrorAction SilentlyContinue
}
```

### Functions and Modules

#### Function Definition and Parameters

PowerShell functions encapsulate reusable code blocks with optional parameters, return values, and help documentation. Advanced functions support parameter validation, pipeline input, and cmdlet-like behavior.

Function parameters can include default values, mandatory flags, validation scripts, and parameter sets. The `param` block defines parameters formally, while simple functions can access arguments through `$args`.

**Example:**

```powershell
function Get-SystemInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName,
        
        [switch]$IncludeDisks
    )
    
    foreach ($computer in $ComputerName) {
        $info = Get-WmiObject Win32_ComputerSystem -ComputerName $computer
        
        if ($IncludeDisks) {
            $disks = Get-WmiObject Win32_LogicalDisk -ComputerName $computer
            Add-Member -InputObject $info -MemberType NoteProperty -Name "Disks" -Value $disks
        }
        
        Write-Output $info
    }
}
```

#### Module Structure and Import

PowerShell modules organize related functions, variables, and cmdlets into reusable packages. Modules can be script-based (.psm1), binary (.dll), or manifest-defined (.psd1). The module system supports automatic loading, versioning, and dependency management.

Module scope isolates internal implementation details while exporting specific functions and variables for public use. Import-Module loads modules explicitly, while PowerShell can auto-load modules when calling exported commands.

### Remote Management

#### PowerShell Remoting Architecture

PowerShell Remoting enables command execution on remote computers through WinRM (Windows Remote Management) protocol. Remoting supports both interactive sessions and one-time command execution across multiple computers simultaneously.

Remote sessions maintain state between commands, allowing complex multi-step operations. Session configuration controls available cmdlets, execution policies, and resource constraints for remote connections.

**Example:**

```powershell
# One-time remote command
Invoke-Command -ComputerName "Server01","Server02" -ScriptBlock {
    Get-Service "Spooler" | Restart-Service
}

# Interactive remote session
$session = New-PSSession -ComputerName "Server01"
Enter-PSSession $session
# Commands execute on remote computer
Exit-PSSession
Remove-PSSession $session
```

#### Session Management

Persistent sessions optimize performance for multiple remote operations and maintain variable state between commands. Session objects can be reused, shared between scripts, and managed centrally for enterprise scenarios.

### Security Features

#### Execution Policy

PowerShell's execution policy provides a security layer that controls script execution permissions. Policies range from Restricted (no scripts) to Unrestricted (all scripts) with intermediate levels requiring digital signatures or local script creation.

Execution policy applies at multiple scopes (Process, CurrentUser, LocalMachine, GroupPolicy) with more restrictive policies taking precedence. The policy affects script files but not interactive commands or functions defined in the current session.

#### Code Signing and Certificates

PowerShell supports code signing using digital certificates to verify script authenticity and integrity. Signed scripts can execute under restricted execution policies, providing enterprise deployment flexibility while maintaining security controls.

### Performance Considerations

#### Pipeline Optimization

Efficient PowerShell scripts minimize object creation, leverage early filtering, and choose appropriate cmdlets for specific tasks. Placing filter operations early in pipelines reduces processing overhead by eliminating objects before expensive operations.

**Key points:**

- Use `Where-Object` early in pipelines to filter unnecessary objects
- Prefer specific cmdlets over generic ones (`Get-Process -Name "notepad"` vs `Get-Process | Where-Object Name -eq "notepad"`)
- Consider `ForEach-Object` vs `foreach` loops based on memory usage requirements

#### Memory Management

PowerShell automatically manages memory through .NET garbage collection, but large datasets or long-running scripts may require explicit cleanup. Disposing of objects, clearing variables, and managing session state helps prevent memory accumulation.

### Integration Capabilities

#### .NET Framework Integration

PowerShell provides direct access to .NET Framework classes, methods, and properties through type acceleration and object instantiation. This integration enables sophisticated programming capabilities beyond traditional shell scripting.

**Example:**

```powershell
# Creating .NET objects
$web = New-Object System.Net.WebClient
$html = $web.DownloadString("http://example.com")

# Static method calls
[System.Math]::Round(3.14159, 2)

# Type casting and acceleration
[datetime]::Now.AddDays(30)
```

#### COM Object Interaction

PowerShell can instantiate and control COM objects for interacting with applications like Microsoft Office, Internet Explorer, and Windows Management Instrumentation. COM integration enables automation scenarios and legacy system integration.

#### WMI and CIM Integration

Windows Management Instrumentation (WMI) and Common Information Model (CIM) provide standardized interfaces for system management. PowerShell includes dedicated cmdlets for WMI/CIM operations with improved performance and cross-platform compatibility in newer versions.

### **Key Points**

PowerShell's object-oriented nature, consistent cmdlet structure, and powerful pipeline system create a unified approach to system administration and automation. The shell's integration with .NET Framework and extensive remote management capabilities make it suitable for both simple tasks and enterprise-scale operations. Understanding core concepts like parameter binding, error handling, and module architecture enables effective PowerShell development and troubleshooting.

### **Related Topics**

PowerShell Desired State Configuration (DSC), PowerShell Classes, Advanced Function Development, Cross-Platform PowerShell (PowerShell Core), PowerShell Gallery and Package Management

---

