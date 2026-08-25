## Functions


### Function Syntax and Structure

PowerShell functions provide a way to encapsulate reusable code blocks with defined inputs and outputs. Functions follow specific syntax patterns that determine their behavior and capabilities.

#### Basic Function Syntax

The simplest function structure uses the `function` keyword:

```powershell
function Get-Greeting {
    "Hello, World!"
}

# Alternative syntax
function Get-Greeting() {
    "Hello, World!"
}
```

#### Function Naming Conventions

PowerShell functions should follow the Verb-Noun naming convention:

```powershell
function Get-UserInfo {
    # Implementation
}

function Set-Configuration {
    # Implementation
}

function New-Report {
    # Implementation
}
```

#### Complete Function Structure

A comprehensive function includes multiple sections:

```powershell
function Get-ProcessInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ProcessName
    )
    
    begin {
        Write-Verbose "Starting process information retrieval"
        $startTime = Get-Date
    }
    
    process {
        try {
            $processes = Get-Process -Name $ProcessName -ErrorAction Stop
            foreach ($proc in $processes) {
                [PSCustomObject]@{
                    Name = $proc.Name
                    Id = $proc.Id
                    CPU = $proc.CPU
                    Memory = $proc.WorkingSet64
                }
            }
        }
        catch {
            Write-Error "Failed to get process information: $_"
        }
    }
    
    end {
        $endTime = Get-Date
        $duration = $endTime - $startTime
        Write-Verbose "Function completed in $($duration.TotalSeconds) seconds"
    }
}
```

#### Function Blocks

**Begin Block:** Executes once before pipeline processing begins **Process Block:** Executes once for each pipeline input object **End Block:** Executes once after all pipeline processing completes

```powershell
function Process-Items {
    param([Parameter(ValueFromPipeline=$true)]$InputObject)
    
    begin {
        $count = 0
        Write-Host "Starting processing..."
    }
    
    process {
        $count++
        Write-Host "Processing item $count: $InputObject"
        # Process the current pipeline object
        $InputObject
    }
    
    end {
        Write-Host "Processed $count items total"
    }
}
```

**Key Points:**

- Functions without explicit blocks have implicit process blocks
- Begin and end blocks execute only once per function call
- Process blocks enable pipeline processing capabilities
- Use descriptive Verb-Noun naming conventions

### Parameters and Parameter Validation

PowerShell provides extensive parameter definition and validation capabilities to ensure functions receive appropriate input.

#### Basic Parameter Declaration

```powershell
function Get-FileSize {
    param(
        [string]$Path,
        [string]$Unit = "KB"
    )
    
    if (Test-Path $Path) {
        $size = (Get-Item $Path).Length
        switch ($Unit) {
            "KB" { $size / 1KB }
            "MB" { $size / 1MB }
            "GB" { $size / 1GB }
            default { $size }
        }
    }
}
```

#### Parameter Attributes

**Mandatory Parameters:**

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$RequiredParameter,
    
    [Parameter(Mandatory=$false)]
    [string]$OptionalParameter = "DefaultValue"
)
```

**Pipeline Parameters:**

```powershell
param(
    [Parameter(ValueFromPipeline=$true)]
    [string]$PipelineInput,
    
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]$Name
)
```

**Parameter Position:**

```powershell
param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$FirstParameter,
    
    [Parameter(Position=1)]
    [string]$SecondParameter
)
```

#### Advanced Parameter Validation

**Type Validation:**

```powershell
param(
    [int]$Number,
    [datetime]$Date,
    [System.IO.FileInfo]$File
)
```

**Value Validation:**

```powershell
param(
    [ValidateRange(1, 100)]
    [int]$Percentage,
    
    [ValidateSet("Small", "Medium", "Large")]
    [string]$Size,
    
    [ValidateLength(1, 50)]
    [string]$Name,
    
    [ValidatePattern("^\d{3}-\d{2}-\d{4}$")]
    [string]$SSN,
    
    [ValidateScript({Test-Path $_})]
    [string]$FilePath
)
```

**Collection Validation:**

```powershell
param(
    [ValidateCount(1, 10)]
    [string[]]$Items,
    
    [ValidateNotNullOrEmpty()]
    [string]$RequiredString,
    
    [AllowEmptyString()]
    [string]$OptionalString,
    
    [AllowNull()]
    [string]$NullableString
)
```

#### Custom Validation

```powershell
function Test-ValidEmail {
    param([string]$Email)
    return $Email -match "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
}

param(
    [ValidateScript({
        if (Test-ValidEmail $_) { 
            $true 
        } else { 
            throw "Invalid email format: $_" 
        }
    })]
    [string]$EmailAddress
)
```

#### Parameter Sets

Parameter sets allow functions to have different parameter combinations:

```powershell
function Get-Data {
    [CmdletBinding(DefaultParameterSetName="ByName")]
    param(
        [Parameter(ParameterSetName="ByName", Mandatory=$true)]
        [string]$Name,
        
        [Parameter(ParameterSetName="ById", Mandatory=$true)]
        [int]$Id,
        
        [Parameter(ParameterSetName="ByName")]
        [Parameter(ParameterSetName="ById")]
        [switch]$IncludeDetails
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        "ByName" { "Getting data for name: $Name" }
        "ById" { "Getting data for ID: $Id" }
    }
}
```

**Key Points:**

- Parameter validation occurs before function execution
- Custom validation scripts provide flexible validation logic
- Parameter sets enable multiple function signatures
- Use appropriate validation attributes to ensure data quality

### Return Values and Output

PowerShell functions can produce output through multiple mechanisms, each with different behaviors and use cases.

#### Implicit Output

PowerShell functions return all uncaptured output:

```powershell
function Get-Numbers {
    1
    2
    3
    "Done"
}

$result = Get-Numbers
# $result contains @(1, 2, 3, "Done")
```

#### Explicit Return Statements

The `return` statement immediately exits the function:

```powershell
function Test-Number {
    param([int]$Number)
    
    if ($Number -gt 0) {
        return "Positive"
    }
    elseif ($Number -lt 0) {
        return "Negative"
    }
    else {
        return "Zero"
    }
}
```

#### Write-Output vs Return

```powershell
function Compare-OutputMethods {
    # These produce the same result
    Write-Output "Using Write-Output"
    return "Using return"
    
    # This line never executes
    "This won't appear"
}
```

#### Controlling Output Types

**Returning Custom Objects:**

```powershell
function Get-SystemInfo {
    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        OS = (Get-WmiObject Win32_OperatingSystem).Caption
        TotalMemory = (Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory
        Timestamp = Get-Date
    }
}
```

**Returning Arrays:**

```powershell
function Get-EvenNumbers {
    param([int]$Max)
    
    $results = @()
    for ($i = 2; $i -le $Max; $i += 2) {
        $results += $i
    }
    return $results
}

# Alternative using pipeline
function Get-EvenNumbers {
    param([int]$Max)
    
    2..$Max | Where-Object { $_ % 2 -eq 0 }
}
```

#### Output Streams

PowerShell has multiple output streams:

```powershell
function Demonstrate-Streams {
    Write-Output "Success output"      # Success stream (1)
    Write-Error "Error message"        # Error stream (2)
    Write-Warning "Warning message"    # Warning stream (3)
    Write-Verbose "Verbose message"    # Verbose stream (4)
    Write-Debug "Debug message"        # Debug stream (5)
    Write-Information "Info message"   # Information stream (6)
}
```

#### Suppressing Output

```powershell
function Process-SilentOperation {
    # Suppress specific output
    $null = Get-Process
    
    # Suppress all output
    Get-Process | Out-Null
    
    # Suppress and capture
    $processes = Get-Process 2>$null
}
```

**Key Points:**

- Functions return all uncaptured output by default
- `return` immediately exits the function
- Use appropriate output streams for different message types
- Consider output type consistency for pipeline compatibility

### Function Scope and Variables

PowerShell uses a hierarchical scope system that determines variable visibility and lifetime within functions.

#### Variable Scopes

PowerShell has several scope levels:

- **Global:** Available throughout the session
- **Script:** Available throughout the current script
- **Local:** Available in the current scope (default)
- **Private:** Available only in the current scope, not child scopes

```powershell
$global:GlobalVar = "Global Value"
$script:ScriptVar = "Script Value"

function Test-Scopes {
    $local:LocalVar = "Local Value"
    $private:PrivateVar = "Private Value"
    
    Write-Host "Global: $global:GlobalVar"
    Write-Host "Script: $script:ScriptVar"
    Write-Host "Local: $LocalVar"
    Write-Host "Private: $PrivateVar"
    
    # Call child function
    Test-ChildScope
}

function Test-ChildScope {
    Write-Host "From child - Global: $global:GlobalVar"
    Write-Host "From child - Script: $script:ScriptVar"
    Write-Host "From child - Parent Local: $LocalVar"  # Available
    Write-Host "From child - Parent Private: $PrivateVar"  # Not available
}
```

#### Variable Inheritance

Child scopes inherit variables from parent scopes:

```powershell
$outerVar = "Outer"

function Outer-Function {
    $outerVar = "Modified in Outer"
    $innerVar = "Inner"
    
    function Inner-Function {
        Write-Host "Outer var: $outerVar"  # "Modified in Outer"
        Write-Host "Inner var: $innerVar"  # "Inner"
        
        # Modify parent scope variable
        $script:outerVar = "Modified by Inner"
    }
    
    Inner-Function
}
```

#### Function Parameters and Scope

Parameters create local variables within function scope:

```powershell
function Process-Data {
    param(
        [string]$InputData
    )
    
    # $InputData is local to this function
    $InputData = $InputData.ToUpper()  # Modifies local copy
    
    # Access global variable with same name
    if ($global:InputData) {
        Write-Host "Global InputData exists: $global:InputData"
    }
}

$InputData = "original value"
Process-Data -InputData "function parameter"
Write-Host "Original value unchanged: $InputData"  # Still "original value"
```

#### Using Scope Modifiers

```powershell
function Modify-Variables {
    # Modify global variable
    $global:Counter++
    
    # Create script-level variable
    $script:LastProcessed = Get-Date
    
    # Create private variable (not inherited by child functions)
    $private:SecretValue = "Hidden"
    
    Test-Access
}

function Test-Access {
    Write-Host "Counter: $global:Counter"
    Write-Host "Last Processed: $script:LastProcessed"
    Write-Host "Secret: $SecretValue"  # Will be empty/null
}
```

#### Best Practices for Variable Scope

```powershell
function Get-Configuration {
    # Use local variables by default
    $configPath = "$env:USERPROFILE\.myconfig"
    $config = @{}
    
    # Explicitly modify global state when needed
    if ($SetGlobal) {
        $global:LastConfigLoad = Get-Date
    }
    
    # Return data instead of setting global variables
    return $config
}
```

**Key Points:**

- Local scope is the default for function variables
- Child functions inherit parent scope variables (except private)
- Use scope modifiers explicitly when needed
- Prefer returning values over modifying global state

### Advanced Functions with CmdletBinding

The `[CmdletBinding()]` attribute transforms simple functions into advanced functions with cmdlet-like behavior and capabilities.

#### Basic CmdletBinding

```powershell
function Get-AdvancedInfo {
    [CmdletBinding()]
    param(
        [string]$Name
    )
    
    Write-Verbose "Processing name: $Name"
    Write-Debug "Debug information available"
    
    "Hello, $Name"
}

# Usage with common parameters
Get-AdvancedInfo -Name "John" -Verbose -Debug
```

#### Common Parameters

CmdletBinding automatically adds common parameters:

```powershell
function Test-CommonParameters {
    [CmdletBinding()]
    param([string]$CustomParam)
    
    # Access automatic variables
    Write-Host "Verbose: $($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Verbose'))"
    Write-Host "Debug: $($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Debug'))"
    Write-Host "ErrorAction: $ErrorActionPreference"
    
    if ($PSBoundParameters.ContainsKey('WhatIf')) {
        Write-Host "WhatIf parameter was specified"
    }
}
```

#### SupportsShouldProcess

Enable -WhatIf and -Confirm parameters:

```powershell
function Remove-CustomFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    if (Test-Path $Path) {
        if ($PSCmdlet.ShouldProcess($Path, "Remove File")) {
            Remove-Item $Path
            Write-Verbose "File removed: $Path"
        }
    }
    else {
        Write-Warning "File not found: $Path"
    }
}

# Usage
Remove-CustomFile -Path "test.txt" -WhatIf
Remove-CustomFile -Path "test.txt" -Confirm
```

#### Advanced CmdletBinding Features

**ConfirmImpact:**

```powershell
function Reset-SystemConfiguration {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact='High'
    )]
    param()
    
    if ($PSCmdlet.ShouldProcess("System Configuration", "Reset")) {
        # Perform reset operation
        Write-Host "Configuration reset completed"
    }
}
```

**DefaultParameterSetName:**

```powershell
function Get-UserData {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    param(
        [Parameter(ParameterSetName='ByName')]
        [string]$Name,
        
        [Parameter(ParameterSetName='ById')]
        [int]$Id
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'ByName' { "Processing user: $Name" }
        'ById' { "Processing user ID: $Id" }
    }
}
```

#### Pipeline Processing with CmdletBinding

```powershell
function Process-InputObjects {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [string]$Name,
        
        [string]$Prefix = "Processed"
    )
    
    begin {
        Write-Verbose "Starting pipeline processing"
        $processedCount = 0
    }
    
    process {
        $processedCount++
        Write-Progress -Activity "Processing Items" -Status "Item $processedCount" -PercentComplete ($processedCount * 10)
        
        [PSCustomObject]@{
            OriginalName = $Name
            ProcessedName = "$Prefix-$Name"
            ProcessedAt = Get-Date
        }
    }
    
    end {
        Write-Verbose "Processed $processedCount items"
        Write-Progress -Activity "Processing Items" -Completed
    }
}
```

#### Error Handling in Advanced Functions

```powershell
function Get-SafeData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Source
    )
    
    try {
        Write-Verbose "Attempting to retrieve data from: $Source"
        
        # Simulated operation that might fail
        if ($Source -eq "invalid") {
            throw "Invalid source specified"
        }
        
        Write-Debug "Data retrieval successful"
        return "Data from $Source"
    }
    catch {
        $errorMessage = "Failed to get data from $Source : $_"
        
        # Write terminating error
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                $_.Exception,
                "DataRetrievalError",
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $Source
            )
        )
    }
}
```

#### Dynamic Parameters

[Inference] Dynamic parameters can be added based on runtime conditions:

```powershell
function Get-ConditionalParameters {
    [CmdletBinding()]
    param(
        [string]$BaseParameter
    )
    
    DynamicParam {
        if ($BaseParameter -eq "Advanced") {
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            
            $advancedParam = New-Object System.Management.Automation.RuntimeDefinedParameter(
                "AdvancedOption", 
                [string], 
                @()
            )
            
            $paramDictionary.Add("AdvancedOption", $advancedParam)
            return $paramDictionary
        }
    }
    
    process {
        if ($PSBoundParameters.ContainsKey("AdvancedOption")) {
            Write-Host "Advanced option: $($PSBoundParameters.AdvancedOption)"
        }
    }
}
```

**Key Points:**

- CmdletBinding enables cmdlet-like behavior and common parameters
- SupportsShouldProcess adds -WhatIf and -Confirm capabilities
- Advanced functions support pipeline processing with begin/process/end blocks
- Error handling can use cmdlet-style error records
- Dynamic parameters provide runtime parameter flexibility [Inference]

**Conclusion**

PowerShell functions provide a robust framework for creating reusable, maintainable code. From basic function syntax to advanced cmdlet-like behavior with CmdletBinding, understanding these concepts enables creation of professional-quality PowerShell modules and scripts. Proper parameter validation, scope management, and output handling are essential for reliable function behavior.

Key areas for further exploration include dynamic parameters, custom formatting and type data, and function-based DSL (Domain Specific Language) implementations.

---

