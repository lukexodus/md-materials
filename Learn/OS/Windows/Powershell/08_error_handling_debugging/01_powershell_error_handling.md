## PowerShell Error Handling


### Understanding PowerShell Errors

PowerShell errors are objects that contain detailed information about what went wrong during script execution. These error objects inherit from the `System.Management.Automation.ErrorRecord` class and provide comprehensive debugging information.

**Error Object Structure:** Every PowerShell error contains several key properties:

- `Exception`: The underlying .NET exception
- `ErrorDetails`: Additional error information
- `CategoryInfo`: Categorization of the error type
- `FullyQualifiedErrorId`: Unique identifier for the error
- `InvocationInfo`: Information about where the error occurred
- `ScriptStackTrace`: Call stack information
- `TargetObject`: The object that caused the error

**Error Categories:** PowerShell categorizes errors into specific types:

- `CloseError`: Issues closing resources
- `OpenError`: Issues opening resources
- `DeviceError`: Hardware-related problems
- `DeadlockDetected`: Threading conflicts
- `InvalidArgument`: Parameter validation failures
- `InvalidData`: Data format or content issues
- `InvalidOperation`: Operation not permitted in current state
- `InvalidResult`: Unexpected operation results
- `InvalidType`: Type conversion or casting errors
- `MetadataError`: Issues with object metadata
- `NotImplemented`: Feature not implemented
- `NotInstalled`: Required components missing
- `ObjectNotFound`: Referenced objects don't exist
- `OperationStopped`: User or system interruption
- `OperationTimeout`: Time limit exceeded
- `SyntaxError`: Code parsing errors
- `ParserError`: PowerShell parser issues
- `PermissionDenied`: Insufficient privileges
- `ResourceBusy`: Resource currently in use
- `ResourceExists`: Attempting to create existing resource
- `ResourceUnavailable`: Required resource not accessible
- `ReadError`: Data reading failures
- `WriteError`: Data writing failures
- `FromStdErr`: Standard error output
- `SecurityError`: Security policy violations

### Try, Catch, Finally Blocks

The try-catch-finally construct provides structured exception handling for robust error management.

**Basic Try-Catch Structure:**

```powershell
try {
    # Code that might throw an error
    $result = Get-Content "nonexistent.txt"
    Write-Host "File read successfully"
}
catch {
    # Error handling code
    Write-Error "Failed to read file: $($_.Exception.Message)"
}
```

**Multiple Catch Blocks:** Handle different exception types with specific responses:

```powershell
try {
    $number = [int]"not-a-number"
    $result = 10 / $number
}
catch [System.InvalidCastException] {
    Write-Host "Invalid number format provided"
}
catch [System.DivideByZeroException] {
    Write-Host "Cannot divide by zero"
}
catch {
    Write-Host "An unexpected error occurred: $($_.Exception.Message)"
}
```

**Finally Block:** Code in the finally block always executes, regardless of whether an error occurred:

```powershell
$file = $null
try {
    $file = [System.IO.File]::OpenRead("data.txt")
    $content = $file.ReadByte()
}
catch {
    Write-Error "File operation failed: $($_.Exception.Message)"
}
finally {
    if ($file) {
        $file.Close()
        Write-Host "File handle closed"
    }
}
```

**Nested Try-Catch Blocks:**

```powershell
try {
    Write-Host "Outer try block"
    try {
        Write-Host "Inner try block"
        throw "Inner exception"
    }
    catch {
        Write-Host "Inner catch: $($_.Exception.Message)"
        throw "Re-thrown from inner catch"
    }
}
catch {
    Write-Host "Outer catch: $($_.Exception.Message)"
}
```

**Advanced Exception Handling:**

```powershell
try {
    # Complex operation
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $result = $command.ExecuteScalar()
}
catch [System.Data.SqlClient.SqlException] {
    switch ($_.Exception.Number) {
        2 { Write-Host "Connection timeout" }
        18456 { Write-Host "Login failed" }
        default { Write-Host "SQL Error: $($_.Exception.Message)" }
    }
}
catch [System.InvalidOperationException] {
    Write-Host "Connection state error: $($_.Exception.Message)"
}
finally {
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}
```

### Error Variables

PowerShell maintains several automatic variables that track error information and execution status.

**$Error Automatic Variable:** The `$Error` variable is an array containing all errors from the current session, with the most recent error at index 0:

```powershell
# Generate some errors
Get-Content "nonexistent1.txt" -ErrorAction SilentlyContinue
Get-Content "nonexistent2.txt" -ErrorAction SilentlyContinue

# Examine error history
Write-Host "Total errors in session: $($Error.Count)"
Write-Host "Most recent error: $($Error[0].Exception.Message)"
Write-Host "Second most recent: $($Error[1].Exception.Message)"

# Clear error history
$Error.Clear()
```

**$? Automatic Variable:** The `$?` variable contains a Boolean value indicating whether the last operation succeeded:

```powershell
Get-Process "NonExistentProcess" -ErrorAction SilentlyContinue
if ($?) {
    Write-Host "Command succeeded"
} else {
    Write-Host "Command failed"
}

# Check after successful operation
Get-Date
Write-Host "Last command succeeded: $?"
```

**$LastExitCode Variable:** Contains the exit code of the last native application or script that was executed:

```powershell
# Run a command prompt command
cmd /c "exit 5"
Write-Host "Exit code: $LastExitCode"

# Run PowerShell script with exit code
powershell -Command "exit 10"
Write-Host "PowerShell exit code: $LastExitCode"

# Check Windows commands
ping "nonexistent-host.local"
if ($LastExitCode -eq 0) {
    Write-Host "Ping successful"
} else {
    Write-Host "Ping failed with code: $LastExitCode"
}
```

**$PSCmdlet.ThrowTerminatingError():** Used within advanced functions to generate terminating errors:

```powershell
function Test-CustomError {
    [CmdletBinding()]
    param([string]$InputData)
    
    if ([string]::IsNullOrEmpty($InputData)) {
        $errorRecord = New-Object System.Management.Automation.ErrorRecord(
            (New-Object System.ArgumentException("InputData cannot be null or empty")),
            "NullOrEmptyInput",
            [System.Management.Automation.ErrorCategory]::InvalidArgument,
            $InputData
        )
        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
}
```

### Terminating vs Non-Terminating Errors

Understanding the difference between terminating and non-terminating errors is crucial for effective error handling.

**Non-Terminating Errors:** These errors allow the cmdlet to continue processing remaining objects in the pipeline:

```powershell
# Non-terminating error - continues processing
Get-ChildItem "C:\", "D:\NonExistent", "C:\Windows"
# Will process C:\ and C:\Windows despite D:\NonExistent failing
```

**Converting Non-Terminating to Terminating:** Use `-ErrorAction Stop` to make non-terminating errors terminate:

```powershell
try {
    Get-ChildItem "C:\NonExistent" -ErrorAction Stop
    Write-Host "This won't execute if path doesn't exist"
}
catch {
    Write-Host "Caught terminating error: $($_.Exception.Message)"
}
```

**Terminating Errors:** These errors halt cmdlet execution immediately:

```powershell
try {
    # This will always be a terminating error
    $invalidNumber = [int]"not-a-number"
}
catch {
    Write-Host "Terminating error caught"
}
```

**ErrorAction Preference Values:**

- `Continue`: Display error and continue (default for non-terminating)
- `Ignore`: Suppress error display and continue
- `Inquire`: Prompt user for action
- `SilentlyContinue`: Continue without displaying error
- `Stop`: Treat as terminating error
- `Suspend`: Suspend workflow (workflows only)

```powershell
# Different error actions
Get-Process "NonExistent" -ErrorAction Continue      # Shows error, continues
Get-Process "NonExistent" -ErrorAction SilentlyContinue  # No error display
Get-Process "NonExistent" -ErrorAction Ignore       # Completely ignore
Get-Process "NonExistent" -ErrorAction Stop         # Throws terminating error
```

**$ErrorActionPreference Variable:** Sets the default error action for the session:

```powershell
# Save original preference
$originalPreference = $ErrorActionPreference

# Set to stop on all errors
$ErrorActionPreference = "Stop"

try {
    Get-Process "NonExistent"  # Now throws terminating error
}
catch {
    Write-Host "Error caught due to ErrorActionPreference"
}

# Restore original preference
$ErrorActionPreference = $originalPreference
```

### Custom Error Handling Strategies

Implementing robust error handling requires strategic planning and consistent patterns throughout your scripts.

**Centralized Error Handling Function:**

```powershell
function Write-ErrorLog {
    param(
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,
        [string]$LogPath = "C:\Logs\PowerShell_Errors.log",
        [switch]$IncludeStackTrace
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $errorMessage = "$timestamp - $($ErrorRecord.Exception.Message)"
    
    if ($IncludeStackTrace) {
        $errorMessage += "`nStack Trace: $($ErrorRecord.ScriptStackTrace)"
    }
    
    Add-Content -Path $LogPath -Value $errorMessage
    Write-Warning "Error logged to $LogPath"
}

# Usage
try {
    Get-Content "nonexistent.txt"
}
catch {
    Write-ErrorLog -ErrorRecord $_ -IncludeStackTrace
}
```

**Retry Logic with Exponential Backoff:**

```powershell
function Invoke-WithRetry {
    param(
        [scriptblock]$ScriptBlock,
        [int]$MaxRetries = 3,
        [int]$BaseDelay = 1000
    )
    
    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        try {
            return & $ScriptBlock
        }
        catch {
            if ($attempt -eq $MaxRetries) {
                throw
            }
            
            $delay = $BaseDelay * [Math]::Pow(2, $attempt - 1)
            Write-Warning "Attempt $attempt failed. Retrying in $($delay)ms..."
            Start-Sleep -Milliseconds $delay
        }
    }
}

# Usage
$result = Invoke-WithRetry -ScriptBlock {
    # Potentially failing operation
    Invoke-RestMethod -Uri "https://api.example.com/data" -TimeoutSec 5
} -MaxRetries 3
```

**Validation and Early Error Detection:**

```powershell
function Test-Prerequisites {
    param([string[]]$RequiredPaths)
    
    $errors = @()
    
    foreach ($path in $RequiredPaths) {
        if (-not (Test-Path $path)) {
            $errors += "Required path not found: $path"
        }
    }
    
    if ($errors.Count -gt 0) {
        throw ("Prerequisites not met:`n" + ($errors -join "`n"))
    }
}

# Usage at script start
try {
    Test-Prerequisites -RequiredPaths @("C:\Data", "C:\Config\settings.json")
    # Continue with main script logic
}
catch {
    Write-Error "Script cannot continue: $($_.Exception.Message)"
    exit 1
}
```

**Context-Aware Error Handling:**

```powershell
function Process-DataFiles {
    param([string[]]$FilePaths)
    
    $results = @()
    $errors = @()
    
    foreach ($file in $FilePaths) {
        try {
            Write-Progress -Activity "Processing Files" -Status $file
            
            # File-specific error context
            if (-not (Test-Path $file)) {
                throw [System.IO.FileNotFoundException]"File not found: $file"
            }
            
            $data = Import-Csv $file -ErrorAction Stop
            $processed = $data | Where-Object { $_.Status -eq "Active" }
            
            $results += [PSCustomObject]@{
                FileName = $file
                RecordCount = $processed.Count
                Status = "Success"
            }
        }
        catch [System.IO.FileNotFoundException] {
            $errors += [PSCustomObject]@{
                FileName = $file
                Error = "File not found"
                Severity = "High"
            }
        }
        catch [System.UnauthorizedAccessException] {
            $errors += [PSCustomObject]@{
                FileName = $file
                Error = "Access denied"
                Severity = "Medium"
            }
        }
        catch {
            $errors += [PSCustomObject]@{
                FileName = $file
                Error = $_.Exception.Message
                Severity = "Unknown"
            }
        }
    }
    
    return @{
        Results = $results
        Errors = $errors
    }
}
```

**Error Aggregation and Reporting:**

```powershell
class ErrorCollector {
    [System.Collections.ArrayList]$Errors = @()
    
    [void]AddError([string]$Context, [System.Exception]$Exception) {
        $this.Errors.Add([PSCustomObject]@{
            Timestamp = Get-Date
            Context = $Context
            Message = $Exception.Message
            Type = $Exception.GetType().Name
        }) | Out-Null
    }
    
    [void]GenerateReport([string]$OutputPath) {
        if ($this.Errors.Count -eq 0) {
            Write-Host "No errors to report"
            return
        }
        
        $report = @"
Error Report Generated: $(Get-Date)
Total Errors: $($this.Errors.Count)

$($this.Errors | Format-Table -AutoSize | Out-String)
"@
        
        Set-Content -Path $OutputPath -Value $report
        Write-Host "Error report saved to: $OutputPath"
    }
}

# Usage
$errorCollector = [ErrorCollector]::new()

# Throughout your script
try {
    # Some operation
    Get-Content "file1.txt"
}
catch {
    $errorCollector.AddError("File Reading", $_.Exception)
}

# At script end
$errorCollector.GenerateReport("C:\Reports\ErrorReport_$(Get-Date -Format 'yyyyMMdd').txt")
```

**Key points**: Effective error handling combines understanding PowerShell's error types with strategic implementation patterns. Use try-catch-finally for structured handling, monitor error variables for script flow control, and implement custom strategies like retry logic and centralized logging for robust production scripts. Always consider whether errors should terminate execution or allow continued processing based on your specific use case.

---

