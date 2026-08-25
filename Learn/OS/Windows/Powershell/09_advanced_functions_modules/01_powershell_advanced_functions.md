## PowerShell Advanced Functions


### Parameter Attributes and Validation

Advanced functions use the `[CmdletBinding()]` attribute to provide cmdlet-like functionality. Parameter attributes control how parameters behave and validate input data before function execution.

#### Basic Parameter Attributes

```powershell
function Get-UserInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$UserName,
        
        [Parameter(Mandatory = $false)]
        [string]$Domain = $env:USERDOMAIN,
        
        [Parameter(ParameterSetName = "Detailed")]
        [switch]$IncludeGroups,
        
        [Parameter(ParameterSetName = "Summary")]
        [switch]$SummaryOnly
    )
    
    Write-Verbose "Retrieving information for user: $UserName"
    # Function implementation
}
```

**Key points for parameter attributes:**

- `Mandatory` determines if the parameter is required
- `Position` allows positional parameter binding
- `ParameterSetName` creates mutually exclusive parameter groups
- `ValueFromPipeline` enables pipeline input processing

#### Validation Attributes

PowerShell provides extensive validation attributes to ensure parameter values meet specific criteria:

```powershell
function New-DatabaseConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ServerName,
        
        [Parameter()]
        [ValidateRange(1, 65535)]
        [int]$Port = 1433,
        
        [Parameter()]
        [ValidateSet("Integrated", "SqlServer", "Windows")]
        [string]$AuthenticationType = "Integrated",
        
        [Parameter()]
        [ValidatePattern("^[a-zA-Z][a-zA-Z0-9_]*$")]
        [string]$DatabaseName,
        
        [Parameter()]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$ConfigFile,
        
        [Parameter()]
        [ValidateLength(8, 128)]
        [string]$Password
    )
    
    # Function implementation
}
```

#### Custom Validation Attributes

Create custom validation logic using `ValidateScript`:

```powershell
function Set-ServiceConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({
            if (Get-Service $_ -ErrorAction SilentlyContinue) {
                $true
            } else {
                throw "Service '$_' does not exist"
            }
        })]
        [string]$ServiceName,
        
        [Parameter()]
        [ValidateScript({
            $validStates = @("Running", "Stopped", "Paused")
            if ($_ -in $validStates) {
                $true
            } else {
                throw "State must be one of: $($validStates -join ', ')"
            }
        })]
        [string]$DesiredState
    )
    
    # Function implementation
}
```

### Advanced Parameter Features

#### Parameter Aliases and Help Messages

```powershell
function Copy-Files {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, HelpMessage = "Enter the source directory path")]
        [Alias("Src", "From")]
        [string]$SourcePath,
        
        [Parameter(Mandatory, HelpMessage = "Enter the destination directory path")]
        [Alias("Dest", "To")]
        [string]$DestinationPath,
        
        [Parameter()]
        [Alias("R")]
        [switch]$Recursive
    )
    
    # Function implementation
}
```

#### Parameter Transformation

```powershell
function Get-FileSize {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.IO.FileInfo[]]$File
    )
    
    process {
        foreach ($f in $File) {
            [PSCustomObject]@{
                Name = $f.Name
                SizeBytes = $f.Length
                SizeMB = [math]::Round($f.Length / 1MB, 2)
                SizeGB = [math]::Round($f.Length / 1GB, 3)
            }
        }
    }
}
```

### Pipeline Input Handling

Advanced functions can process pipeline input efficiently using the `begin`, `process`, and `end` blocks.

#### Basic Pipeline Processing

```powershell
function Test-NetworkConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$ComputerName,
        
        [Parameter()]
        [int]$Port = 80,
        
        [Parameter()]
        [int]$TimeoutMs = 5000
    )
    
    begin {
        Write-Verbose "Starting network connectivity tests"
        $results = @()
    }
    
    process {
        foreach ($computer in $ComputerName) {
            try {
                $tcpClient = New-Object System.Net.Sockets.TcpClient
                $connection = $tcpClient.BeginConnect($computer, $Port, $null, $null)
                $success = $connection.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
                
                if ($success) {
                    $tcpClient.EndConnect($connection)
                    $status = "Connected"
                } else {
                    $status = "Timeout"
                }
                
                $tcpClient.Close()
            }
            catch {
                $status = "Failed: $($_.Exception.Message)"
            }
            
            $result = [PSCustomObject]@{
                ComputerName = $computer
                Port = $Port
                Status = $status
                TestDate = Get-Date
            }
            
            Write-Output $result
            $results += $result
        }
    }
    
    end {
        Write-Verbose "Completed testing $($results.Count) connections"
    }
}
```

#### Pipeline Input by Property Name

```powershell
function Get-ProcessDetails {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int[]]$Id,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$Name
    )
    
    process {
        if ($Id) {
            foreach ($processId in $Id) {
                try {
                    $proc = Get-Process -Id $processId -ErrorAction Stop
                    Write-Output $proc
                }
                catch {
                    Write-Warning "Process with ID $processId not found"
                }
            }
        }
        
        if ($Name) {
            foreach ($processName in $Name) {
                Get-Process -Name $processName -ErrorAction SilentlyContinue
            }
        }
    }
}

# Usage examples
Get-Process | Select-Object Id | Get-ProcessDetails
@{Id=1234}, @{Name="notepad"} | Get-ProcessDetails
```

### Dynamic Parameters

Dynamic parameters are created at runtime based on other parameter values or system state. They provide flexible parameter sets that adapt to different scenarios.

#### Basic Dynamic Parameter Implementation

```powershell
function Get-ServiceInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName
    )
    
    DynamicParam {
        # Create parameter dictionary
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
        # Get services from remote computer
        try {
            $services = Get-Service -ComputerName $ComputerName -ErrorAction Stop | 
                       Select-Object -ExpandProperty Name | Sort-Object
            
            # Create dynamic parameter
            $paramAttribute = New-Object System.Management.Automation.ParameterAttribute
            $paramAttribute.Mandatory = $true
            
            $validateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($services)
            
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($paramAttribute)
            $attributeCollection.Add($validateSetAttribute)
            
            $serviceParam = New-Object System.Management.Automation.RuntimeDefinedParameter(
                'ServiceName', [string], $attributeCollection
            )
            
            $paramDictionary.Add('ServiceName', $serviceParam)
        }
        catch {
            Write-Warning "Could not retrieve services from $ComputerName"
        }
        
        return $paramDictionary
    }
    
    process {
        $serviceName = $PSBoundParameters['ServiceName']
        if ($serviceName) {
            Get-Service -Name $serviceName -ComputerName $ComputerName
        }
    }
}
```

#### Advanced Dynamic Parameters

```powershell
function Invoke-DatabaseQuery {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Server,
        
        [Parameter(Mandatory)]
        [string]$Database
    )
    
    DynamicParam {
        $paramDict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        
        # Create connection string and test connectivity
        $connectionString = "Server=$Server;Database=$Database;Integrated Security=true"
        
        try {
            $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
            $connection.Open()
            
            # Get table names for dynamic parameter
            $command = $connection.CreateCommand()
            $command.CommandText = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'"
            $reader = $command.ExecuteReader()
            
            $tables = @()
            while ($reader.Read()) {
                $tables += $reader["TABLE_NAME"]
            }
            $reader.Close()
            $connection.Close()
            
            # Create TableName parameter
            if ($tables.Count -gt 0) {
                $tableParam = New-Object System.Management.Automation.RuntimeDefinedParameter(
                    'TableName', [string], @(
                        New-Object System.Management.Automation.ParameterAttribute @{ Mandatory = $true }
                        New-Object System.Management.Automation.ValidateSetAttribute($tables)
                    )
                )
                $paramDict.Add('TableName', $tableParam)
            }
        }
        catch {
            Write-Warning "Could not connect to database: $($_.Exception.Message)"
        }
        
        return $paramDict
    }
    
    process {
        $tableName = $PSBoundParameters['TableName']
        if ($tableName) {
            # Execute query against selected table
            Write-Output "Querying table: $tableName on $Server.$Database"
        }
    }
}
```

### Comment-Based Help

Comment-based help provides documentation that integrates with PowerShell's help system using `Get-Help`.

#### Comprehensive Help Example

```powershell
function Backup-Database {
    <#
    .SYNOPSIS
        Creates a backup of a SQL Server database.
    
    .DESCRIPTION
        The Backup-Database function creates a full backup of a specified SQL Server database
        to a designated location. It supports both local and remote SQL Server instances,
        with options for compression and verification.
    
    .PARAMETER ServerName
        The name or IP address of the SQL Server instance.
    
    .PARAMETER DatabaseName
        The name of the database to backup. Use tab completion to see available databases.
    
    .PARAMETER BackupPath
        The full path where the backup file will be created. The directory must exist.
    
    .PARAMETER Compress
        Enables backup compression to reduce file size. Available in SQL Server 2008 and later.
    
    .PARAMETER Verify
        Performs verification of the backup after creation to ensure integrity.
    
    .PARAMETER Credential
        Credentials to use for connecting to the SQL Server instance. If not specified,
        the current user's credentials will be used.
    
    .INPUTS
        String
        You can pipe database names to this function.
    
    .OUTPUTS
        PSCustomObject
        Returns an object containing backup information including file path, size, and duration.
    
    .EXAMPLE
        Backup-Database -ServerName "SQL01" -DatabaseName "MyApp" -BackupPath "C:\Backups\MyApp.bak"
        
        Creates a backup of the MyApp database from SQL01 server to the specified path.
    
    .EXAMPLE
        Get-Content "databases.txt" | Backup-Database -ServerName "SQL01" -BackupPath "C:\Backups"
        
        Backs up multiple databases listed in a text file.
    
    .EXAMPLE
        Backup-Database -ServerName "SQL01" -DatabaseName "MyApp" -BackupPath "C:\Backups\MyApp.bak" -Compress -Verify
        
        Creates a compressed backup with verification.
    
    .NOTES
        Author: Database Administrator
        Version: 2.1
        Last Modified: 2024-07-15
        
        Requires SQL Server Management Objects (SMO) to be installed.
    
    .LINK
        https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/
    
    .LINK
        Get-Help about_Functions_Advanced
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, HelpMessage = "Enter the SQL Server instance name")]
        [string]$ServerName,
        
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = "Enter the database name")]
        [string]$DatabaseName,
        
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path (Split-Path $_ -Parent) })]
        [string]$BackupPath,
        
        [Parameter()]
        [switch]$Compress,
        
        [Parameter()]
        [switch]$Verify,
        
        [Parameter()]
        [PSCredential]$Credential
    )
    
    process {
        if ($PSCmdlet.ShouldProcess($DatabaseName, "Backup database")) {
            # Implementation here
            Write-Output "Backing up $DatabaseName from $ServerName to $BackupPath"
        }
    }
}
```

#### Help Documentation Best Practices

**Key points for effective help documentation:**

- Always include SYNOPSIS and DESCRIPTION sections
- Provide parameter descriptions that explain purpose and valid values
- Include practical examples showing different usage scenarios
- Use INPUTS and OUTPUTS sections to document pipeline behavior
- Add NOTES section for version info, requirements, and important details
- Include LINK sections for related documentation

### Function Lifecycle and Cleanup

Advanced functions should handle initialization, execution, and cleanup phases properly to manage resources and maintain system state.

#### Resource Management Pattern

```powershell
function Invoke-RemoteCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$ComputerName,
        
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,
        
        [Parameter()]
        [PSCredential]$Credential,
        
        [Parameter()]
        [switch]$KeepAlive
    )
    
    begin {
        Write-Verbose "Initializing remote command execution"
        $sessions = @()
        $results = @()
        
        # Initialize any required modules or assemblies
        if (-not (Get-Module PSRemoting -ListAvailable)) {
            Write-Warning "PSRemoting module not available"
        }
    }
    
    process {
        foreach ($computer in $ComputerName) {
            try {
                Write-Verbose "Connecting to $computer"
                
                $sessionParams = @{
                    ComputerName = $computer
                    ErrorAction = 'Stop'
                }
                
                if ($Credential) {
                    $sessionParams.Credential = $Credential
                }
                
                $session = New-PSSession @sessionParams
                $sessions += $session
                
                Write-Verbose "Executing script block on $computer"
                $result = Invoke-Command -Session $session -ScriptBlock $ScriptBlock
                
                $output = [PSCustomObject]@{
                    ComputerName = $computer
                    Result = $result
                    Success = $true
                    Error = $null
                    Timestamp = Get-Date
                }
                
                Write-Output $output
                $results += $output
                
            }
            catch {
                $errorOutput = [PSCustomObject]@{
                    ComputerName = $computer
                    Result = $null
                    Success = $false
                    Error = $_.Exception.Message
                    Timestamp = Get-Date
                }
                
                Write-Output $errorOutput
                $results += $errorOutput
            }
        }
    }
    
    end {
        Write-Verbose "Cleaning up sessions"
        
        if (-not $KeepAlive) {
            foreach ($session in $sessions) {
                if ($session.State -eq 'Opened') {
                    try {
                        Remove-PSSession $session -ErrorAction SilentlyContinue
                        Write-Verbose "Closed session to $($session.ComputerName)"
                    }
                    catch {
                        Write-Warning "Failed to close session to $($session.ComputerName): $($_.Exception.Message)"
                    }
                }
            }
        }
        
        Write-Verbose "Processed $($results.Count) computers"
        $successCount = ($results | Where-Object Success).Count
        $failCount = $results.Count - $successCount
        
        Write-Verbose "Success: $successCount, Failed: $failCount"
        
        # Clean up any temporary files or resources
        if (Test-Path $env:TEMP\RemoteCommand_*.tmp) {
            Remove-Item $env:TEMP\RemoteCommand_*.tmp -Force -ErrorAction SilentlyContinue
        }
    }
}
```

#### Error Handling and Logging

```powershell
function Process-DataFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$FilePath,
        
        [Parameter()]
        [string]$LogPath = "$env:TEMP\ProcessDataFile.log"
    )
    
    begin {
        # Initialize logging
        function Write-Log {
            param($Message, $Level = "INFO")
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logEntry = "[$timestamp] [$Level] $Message"
            Add-Content -Path $LogPath -Value $logEntry
            
            switch ($Level) {
                "ERROR" { Write-Error $Message }
                "WARNING" { Write-Warning $Message }
                default { Write-Verbose $Message }
            }
        }
        
        Write-Log "Starting data file processing"
        $processedCount = 0
        $errorCount = 0
    }
    
    process {
        foreach ($file in $FilePath) {
            try {
                Write-Log "Processing file: $file"
                
                if (-not (Test-Path $file)) {
                    throw "File not found: $file"
                }
                
                # Process file (example implementation)
                $content = Get-Content $file -ErrorAction Stop
                $lineCount = $content.Count
                
                Write-Log "Successfully processed $file ($lineCount lines)"
                $processedCount++
                
                # Return result
                [PSCustomObject]@{
                    FilePath = $file
                    LineCount = $lineCount
                    Status = "Success"
                    ProcessedAt = Get-Date
                }
            }
            catch {
                $errorMessage = "Failed to process $file`: $($_.Exception.Message)"
                Write-Log $errorMessage "ERROR"
                $errorCount++
                
                [PSCustomObject]@{
                    FilePath = $file
                    LineCount = 0
                    Status = "Error"
                    Error = $_.Exception.Message
                    ProcessedAt = Get-Date
                }
            }
        }
    }
    
    end {
        Write-Log "Processing complete. Processed: $processedCount, Errors: $errorCount"
        
        # Cleanup temporary resources if any were created
        # [Implementation specific cleanup code]
        
        if ($errorCount -gt 0) {
            Write-Warning "Processing completed with $errorCount errors. Check log: $LogPath"
        }
    }
}
```

**Key points for function lifecycle management:**

- Use `begin` block for initialization and resource allocation
- Use `process` block for main processing logic
- Use `end` block for cleanup and summary operations
- Always clean up resources like sessions, file handles, and temporary files
- Implement proper error handling with meaningful error messages
- Consider logging for troubleshooting and audit purposes
- [Inference] Proper resource cleanup prevents memory leaks and connection exhaustion
- Use `try-catch-finally` blocks when dealing with disposable resources
- Consider implementing timeout mechanisms for long-running operations

---

