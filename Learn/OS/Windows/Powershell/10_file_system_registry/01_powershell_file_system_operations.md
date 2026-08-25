## PowerShell File System Operations


### Advanced File and Folder Operations

PowerShell provides extensive capabilities for file system manipulation through cmdlets, .NET methods, and COM objects. The file system provider treats drives, folders, and files as objects with properties and methods.

#### Core File System Cmdlets

The fundamental cmdlets for file operations include `Get-Item`, `Get-ChildItem`, `New-Item`, `Remove-Item`, `Copy-Item`, `Move-Item`, and `Rename-Item`. These cmdlets work with the `-Path` and `-LiteralPath` parameters, supporting wildcards and pipeline input.

```powershell
# Get detailed file information
Get-Item -Path "C:\Example\file.txt" | Select-Object Name, Length, LastWriteTime, Attributes

# Recursive directory listing with filtering
Get-ChildItem -Path "C:\Logs" -Recurse -Filter "*.log" -File | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }

# Create directory structure
New-Item -Path "C:\Projects\NewProject\Src\Utils" -ItemType Directory -Force
```

#### Advanced Copy and Move Operations

PowerShell supports sophisticated copy operations with progress tracking, filtering, and error handling. The `-Recurse`, `-Force`, and `-WhatIf` parameters provide control over operation behavior.

```powershell
# Copy with progress and filtering
Copy-Item -Path "C:\Source\*" -Destination "C:\Backup" -Recurse -Include "*.txt", "*.log" -PassThru | 
    ForEach-Object { Write-Progress -Activity "Copying" -Status $_.Name }

# Move files based on date criteria
Get-ChildItem -Path "C:\Temp" -File | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
    Move-Item -Destination "C:\Archive" -WhatIf
```

#### File System Attributes and Properties

Files and folders contain extensive metadata accessible through properties and methods. The `Get-ItemProperty` and `Set-ItemProperty` cmdlets manage extended attributes.

```powershell
# Modify file attributes
Set-ItemProperty -Path "C:\Data\sensitive.txt" -Name Attributes -Value ([System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::ReadOnly)

# Check file version information
(Get-ItemProperty -Path "C:\Windows\System32\notepad.exe").VersionInfo
```

### Working with File Content

#### Get-Content Operations

`Get-Content` provides multiple methods for reading file content with streaming capabilities, encoding options, and filtering mechanisms.

```powershell
# Read specific lines with encoding
Get-Content -Path "C:\Logs\app.log" -Encoding UTF8 -TotalCount 100 -Tail 50

# Stream large files
Get-Content -Path "C:\BigFile.txt" -ReadCount 1000 | ForEach-Object {
    # Process batches of 1000 lines
    $_ | Where-Object { $_ -match "ERROR" }
}

# Monitor file in real-time
Get-Content -Path "C:\Logs\live.log" -Wait -Tail 10
```

#### Set-Content and Add-Content Operations

Content writing operations support various encoding formats, pipeline input, and atomic write operations for data integrity.

```powershell
# Write content with specific encoding
$data = @("Line 1", "Line 2", "Line 3")
$data | Set-Content -Path "C:\Output\data.txt" -Encoding UTF8

# Append content safely
Add-Content -Path "C:\Logs\audit.log" -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Process completed" -Encoding ASCII

# Create content from objects
Get-Process | ConvertTo-Json | Set-Content -Path "C:\Reports\processes.json"
```

#### Out-File vs Set-Content

The distinction between `Out-File` and `Set-Content` affects formatting and encoding. `Out-File` applies PowerShell's formatting system, while `Set-Content` writes raw strings.

```powershell
# Out-File with formatting
Get-Service | Out-File -FilePath "C:\Reports\services.txt" -Width 120

# Set-Content for raw data
"Raw string data" | Set-Content -Path "C:\Data\raw.txt" -NoNewline
```

### File Monitoring and Change Detection

#### FileSystemWatcher Implementation

PowerShell can implement real-time file system monitoring using the .NET `FileSystemWatcher` class for automated responses to file system changes.

```powershell
# Create FileSystemWatcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = "C:\Monitor"
$watcher.Filter = "*.txt"
$watcher.EnableRaisingEvents = $true

# Register event handlers
Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action {
    $path = $Event.SourceEventArgs.FullPath
    Write-Host "File created: $path" -ForegroundColor Green
}

Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action {
    $path = $Event.SourceEventArgs.FullPath
    Write-Host "File modified: $path" -ForegroundColor Yellow
}
```

#### Hash-Based Change Detection

File integrity monitoring uses hash calculations to detect modifications without continuous monitoring overhead.

```powershell
# Calculate and store file hashes
function Get-FileHash {
    param([string]$Path)
    Get-ChildItem -Path $Path -Recurse -File | ForEach-Object {
        [PSCustomObject]@{
            Path = $_.FullName
            Hash = (Get-FileHash -Path $_.FullName -Algorithm SHA256).Hash
            LastModified = $_.LastWriteTime
        }
    }
}

# Compare against baseline
$baseline = Get-FileHash -Path "C:\Important"
$current = Get-FileHash -Path "C:\Important"
Compare-Object -ReferenceObject $baseline -DifferenceObject $current -Property Hash, Path
```

### Permissions and Security

#### Access Control List (ACL) Management

PowerShell provides comprehensive ACL management through `Get-Acl`, `Set-Acl`, and related security cmdlets for fine-grained permission control.

```powershell
# Get current ACL
$acl = Get-Acl -Path "C:\SecureFolder"

# Create new access rule
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "DOMAIN\User", 
    "FullControl", 
    "ContainerInherit,ObjectInherit", 
    "None", 
    "Allow"
)

# Apply permissions
$acl.SetAccessRule($accessRule)
Set-Acl -Path "C:\SecureFolder" -AclObject $acl
```

#### Security Descriptor Operations

Advanced security operations involve working with security descriptors, trustees, and inheritance patterns.

```powershell
# Disable inheritance and copy permissions
$acl = Get-Acl -Path "C:\Data\sensitive.txt"
$acl.SetAccessRuleProtection($true, $true)
Set-Acl -Path "C:\Data\sensitive.txt" -AclObject $acl

# Audit permissions recursively
Get-ChildItem -Path "C:\Shares" -Recurse | ForEach-Object {
    $permissions = Get-Acl -Path $_.FullName
    [PSCustomObject]@{
        Path = $_.FullName
        Owner = $permissions.Owner
        AccessRules = $permissions.AccessRuleProtection
    }
}
```

#### Effective Permissions Analysis

[Inference] PowerShell can analyze effective permissions by combining explicit and inherited permissions, though this requires understanding the Windows security model.

```powershell
# Analyze effective permissions
function Get-EffectivePermissions {
    param([string]$Path, [string]$Identity)
    
    $acl = Get-Acl -Path $Path
    $relevantRules = $acl.Access | Where-Object { 
        $_.IdentityReference -eq $Identity -or 
        $_.IdentityReference -in (Get-GroupMembership -Identity $Identity)
    }
    
    return $relevantRules | Group-Object FileSystemRights | 
           Select-Object Name, Count, @{n="Rules"; e={$_.Group}}
}
```

### Working with Structured Data Files

#### CSV File Operations

PowerShell's CSV handling supports custom delimiters, headers, and encoding for data interchange and reporting.

```powershell
# Import with custom delimiter and encoding
$data = Import-Csv -Path "C:\Data\export.csv" -Delimiter ";" -Encoding UTF8

# Export with selected properties
Get-Process | Select-Object Name, CPU, WorkingSet | 
    Export-Csv -Path "C:\Reports\processes.csv" -NoTypeInformation -Encoding UTF8

# Merge multiple CSV files
$combined = Get-ChildItem -Path "C:\MonthlyReports\*.csv" | ForEach-Object {
    Import-Csv -Path $_.FullName | Add-Member -MemberType NoteProperty -Name "Source" -Value $_.BaseName -PassThru
}
$combined | Export-Csv -Path "C:\Reports\annual.csv" -NoTypeInformation
```

#### Advanced CSV Processing

Complex CSV operations involve data transformation, validation, and conditional processing.

```powershell
# Process large CSV with validation
Import-Csv -Path "C:\Data\large.csv" | Where-Object {
    # Validate required fields
    $_.Name -and $_.Email -match "^[^@]+@[^@]+\.[^@]+$"
} | ForEach-Object {
    # Transform data
    $_.Name = (Get-Culture).TextInfo.ToTitleCase($_.Name.ToLower())
    $_.Email = $_.Email.ToLower()
    $_
} | Export-Csv -Path "C:\Data\cleaned.csv" -NoTypeInformation
```

#### JSON File Operations

JSON handling in PowerShell supports nested objects, arrays, and type preservation for modern data formats.

```powershell
# Import and process nested JSON
$config = Get-Content -Path "C:\Config\settings.json" | ConvertFrom-Json

# Modify configuration
$config.database.connectionString = "Server=newserver;Database=mydb"
$config.features.logging.enabled = $true

# Export with formatting
$config | ConvertTo-Json -Depth 10 | Set-Content -Path "C:\Config\settings.json"

# Process JSON arrays
$users = Get-Content -Path "C:\Data\users.json" | ConvertFrom-Json
$activeUsers = $users | Where-Object { $_.status -eq "active" } | 
                Select-Object name, email, lastLogin
```

#### XML File Operations

XML processing leverages PowerShell's XML capabilities with XPath queries and namespace support.

```powershell
# Load and query XML
[xml]$config = Get-Content -Path "C:\Config\app.config"
$connectionStrings = $config.configuration.connectionStrings.add

# Modify XML elements
$config.configuration.appSettings.add | Where-Object { $_.key -eq "debug" } | 
    ForEach-Object { $_.value = "false" }

# Save XML with formatting
$config.Save("C:\Config\app.config")

# XPath queries
$nodes = $config.SelectNodes("//add[@key='database']")
```

#### Advanced XML Processing

Complex XML operations involve namespace handling, validation, and transformation.

```powershell
# Handle namespaces
[xml]$xml = Get-Content -Path "C:\Data\document.xml"
$nsManager = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$nsManager.AddNamespace("ns", "http://example.com/namespace")

# XPath with namespaces
$nodes = $xml.SelectNodes("//ns:element[@attribute='value']", $nsManager)

# Transform XML with XSLT
$xslt = New-Object System.Xml.Xsl.XslCompiledTransform
$xslt.Load("C:\Transforms\transform.xsl")
$xslt.Transform("C:\Data\input.xml", "C:\Data\output.html")
```

### Performance Optimization

#### Streaming and Memory Management

Large file operations require memory-conscious approaches using streaming and batch processing techniques.

```powershell
# Stream processing for large files
function Process-LargeFile {
    param([string]$Path, [int]$BatchSize = 1000)
    
    $reader = [System.IO.File]::OpenText($Path)
    $batch = @()
    
    try {
        while (($line = $reader.ReadLine()) -ne $null) {
            $batch += $line
            
            if ($batch.Count -ge $BatchSize) {
                # Process batch
                Process-Batch -Data $batch
                $batch = @()
            }
        }
        
        # Process remaining items
        if ($batch.Count -gt 0) {
            Process-Batch -Data $batch
        }
    }
    finally {
        $reader.Close()
    }
}
```

#### Pipeline Optimization

Efficient pipeline design minimizes memory usage and maximizes throughput for file operations.

```powershell
# Optimized pipeline processing
Get-ChildItem -Path "C:\Logs" -Filter "*.log" | 
    Where-Object { $_.Length -gt 1MB } |
    ForEach-Object -Begin { $totalSize = 0 } -Process {
        $totalSize += $_.Length
        [PSCustomObject]@{
            Name = $_.Name
            SizeMB = [math]::Round($_.Length / 1MB, 2)
            Path = $_.FullName
        }
    } -End {
        Write-Host "Total size processed: $([math]::Round($totalSize / 1GB, 2)) GB"
    }
```

**Key points**: PowerShell file system operations provide comprehensive capabilities for file manipulation, content processing, monitoring, security management, and structured data handling. Advanced techniques include streaming for large files, real-time monitoring with FileSystemWatcher, ACL management for security, and efficient processing of CSV, JSON, and XML formats. Performance optimization requires understanding pipeline behavior and memory management for large-scale operations.

**Important related topics**: PowerShell remoting for distributed file operations, module development for reusable file functions, error handling and logging strategies, integration with version control systems, and automation frameworks for file processing workflows.

---

