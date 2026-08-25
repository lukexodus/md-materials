## PowerShell Modules


### Understanding Module Structure

PowerShell modules are packages that contain cmdlets, functions, variables, and other resources organized into reusable units. Understanding module architecture is essential for creating maintainable and distributable PowerShell code.

**Module Types:** PowerShell supports several module types, each serving different purposes:

- **Script Modules** (`.psm1`): Collections of PowerShell functions and scripts
- **Binary Modules** (`.dll`): Compiled .NET assemblies containing cmdlets
- **Manifest Modules** (`.psd1`): Metadata files describing module contents and requirements
- **Dynamic Modules**: Created programmatically in memory during runtime
- **Composite Modules**: Combinations of the above types

**Standard Module Directory Structure:**

```
MyModule/
├── MyModule.psd1          # Module manifest
├── MyModule.psm1          # Main module script
├── Public/                # Exported functions
│   ├── Get-Something.ps1
│   └── Set-Something.ps1
├── Private/               # Internal helper functions
│   ├── Test-Internal.ps1
│   └── Format-Data.ps1
├── Classes/               # PowerShell classes
│   └── CustomClass.ps1
├── Data/                  # Static data files
│   └── config.json
├── Localized/             # Localization resources
│   ├── en-US/
│   └── es-ES/
├── Tests/                 # Pester tests
│   └── MyModule.Tests.ps1
├── Docs/                  # Documentation
│   └── README.md
└── LICENSE.txt            # License information
```

**Module Scope and Isolation:** Modules create isolated execution contexts that protect the global environment:

```powershell
# Inside a module, variables are scoped to the module
$script:ModuleVariable = "Only accessible within module"
$global:GlobalVariable = "Accessible everywhere"

# Functions are private by default
function Private-Function {
    "This function is internal to the module"
}

# Export functions to make them public
function Public-Function {
    "This function is available to users"
}

# Explicit export in module manifest or Export-ModuleMember
Export-ModuleMember -Function Public-Function
```

**Module Loading Process:** PowerShell follows a specific sequence when loading modules:

1. Locates the module using `$env:PSModulePath`
2. Reads the manifest file (`.psd1`) if present
3. Processes module dependencies
4. Executes the module script (`.psm1`)
5. Imports specified functions, variables, and aliases
6. Registers the module in the session

### Creating Script Modules

Script modules contain PowerShell functions, workflows, variables, and aliases packaged for reusability and distribution.

**Basic Module Structure:**

```powershell
# MyUtilities.psm1

# Module-scoped variable
$script:ModuleConfig = @{
    Version = "1.0.0"
    Author = "Your Name"
}

# Private helper function
function Get-InternalData {
    param([string]$Source)
    
    Write-Verbose "Processing internal data from $Source"
    return "Processed: $Source"
}

# Public function - will be exported
function Get-SystemInformation {
    <#
    .SYNOPSIS
    Retrieves comprehensive system information.
    
    .DESCRIPTION
    Collects CPU, memory, disk, and operating system information
    from the local or remote computer.
    
    .PARAMETER ComputerName
    Name of the computer to query. Defaults to local computer.
    
    .PARAMETER IncludeProcesses
    Include running processes in the output.
    
    .EXAMPLE
    Get-SystemInformation
    
    .EXAMPLE
    Get-SystemInformation -ComputerName "Server01" -IncludeProcesses
    #>
    
    [CmdletBinding()]
    param(
        [string]$ComputerName = $env:COMPUTERNAME,
        [switch]$IncludeProcesses
    )
    
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName
        $cpu = Get-CimInstance -ClassName Win32_Processor -ComputerName $ComputerName
        $memory = Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $ComputerName
        
        $result = [PSCustomObject]@{
            ComputerName = $ComputerName
            OperatingSystem = $os.Caption
            OSVersion = $os.Version
            TotalMemoryGB = [Math]::Round(($memory | Measure-Object Capacity -Sum).Sum / 1GB, 2)
            CPUModel = $cpu.Name
            CPUCores = $cpu.NumberOfCores
            CPULogicalProcessors = $cpu.NumberOfLogicalProcessors
            LastBootTime = $os.LastBootUpTime
        }
        
        if ($IncludeProcesses) {
            $processes = Get-Process -ComputerName $ComputerName | 
                         Sort-Object CPU -Descending | 
                         Select-Object -First 10
            $result | Add-Member -MemberType NoteProperty -Name "TopProcesses" -Value $processes
        }
        
        return $result
    }
    catch {
        Write-Error "Failed to retrieve system information: $($_.Exception.Message)"
    }
}

# Public function with parameter validation
function Test-NetworkConnectivity {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,
        
        [ValidateRange(1, 65535)]
        [int]$Port = 80,
        
        [ValidateRange(100, 30000)]
        [int]$TimeoutMilliseconds = 3000
    )
    
    process {
        foreach ($computer in $ComputerName) {
            try {
                $tcpClient = New-Object System.Net.Sockets.TcpClient
                $asyncResult = $tcpClient.BeginConnect($computer, $Port, $null, $null)
                $wait = $asyncResult.AsyncWaitHandle.WaitOne($TimeoutMilliseconds, $false)
                
                if ($wait) {
                    $tcpClient.EndConnect($asyncResult)
                    $connected = $tcpClient.Connected
                } else {
                    $connected = $false
                }
                
                [PSCustomObject]@{
                    ComputerName = $computer
                    Port = $Port
                    Connected = $connected
                    ResponseTime = if ($connected) { $TimeoutMilliseconds } else { $null }
                }
            }
            catch {
                [PSCustomObject]@{
                    ComputerName = $computer
                    Port = $Port
                    Connected = $false
                    Error = $_.Exception.Message
                }
            }
            finally {
                if ($tcpClient) { $tcpClient.Close() }
            }
        }
    }
}

# Export only the public functions
Export-ModuleMember -Function Get-SystemInformation, Test-NetworkConnectivity
```

**Advanced Module Features:**

```powershell
# Module initialization and cleanup
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    Write-Verbose "Cleaning up MyUtilities module"
    # Cleanup code here
}

# Module-scoped classes
class NetworkDevice {
    [string]$Name
    [string]$IPAddress
    [bool]$IsOnline
    
    NetworkDevice([string]$name, [string]$ip) {
        $this.Name = $name
        $this.IPAddress = $ip
        $this.TestConnectivity()
    }
    
    [void]TestConnectivity() {
        $this.IsOnline = Test-Connection $this.IPAddress -Count 1 -Quiet
    }
}

# Nested module loading
$nestedModules = @(
    "$PSScriptRoot\Private\DatabaseHelpers.psm1",
    "$PSScriptRoot\Private\LoggingHelpers.psm1"
)

foreach ($module in $nestedModules) {
    if (Test-Path $module) {
        . $module
    }
}
```

### Manifest Files (.psd1)

Module manifests are PowerShell data files that describe module metadata, dependencies, and export specifications.

**Complete Manifest Example:**

```powershell
# MyUtilities.psd1
@{
    # Module identity
    RootModule = 'MyUtilities.psm1'
    ModuleVersion = '2.1.0'
    GUID = '12345678-1234-1234-1234-123456789012'
    
    # Author and company information
    Author = 'Your Name'
    CompanyName = 'Your Company'
    Copyright = '(c) 2024 Your Company. All rights reserved.'
    
    # Module description
    Description = 'Comprehensive system utilities and network testing tools'
    
    # Minimum PowerShell version required
    PowerShellVersion = '5.1'
    
    # Supported PowerShell editions
    CompatiblePSEditions = @('Desktop', 'Core')
    
    # Required .NET Framework version
    DotNetFrameworkVersion = '4.7.2'
    
    # Required modules
    RequiredModules = @(
        @{ModuleName = 'Microsoft.PowerShell.Utility'; ModuleVersion = '3.1.0.0'}
    )
    
    # Required assemblies
    RequiredAssemblies = @()
    
    # Script files to run before importing
    ScriptsToProcess = @('Initialize-Module.ps1')
    
    # Type files to load
    TypesToProcess = @('MyUtilities.Types.ps1xml')
    
    # Format files to load
    FormatsToProcess = @('MyUtilities.Format.ps1xml')
    
    # Nested modules
    NestedModules = @(
        'Private\DatabaseHelpers.psm1',
        'Private\LoggingHelpers.psm1'
    )
    
    # Functions to export (use wildcards or explicit names)
    FunctionsToExport = @(
        'Get-SystemInformation',
        'Test-NetworkConnectivity',
        'New-*',
        'Set-*'
    )
    
    # Cmdlets to export
    CmdletsToExport = @()
    
    # Variables to export
    VariablesToExport = @('ModuleConfig')
    
    # Aliases to export
    AliasesToExport = @('gsi', 'tnc')
    
    # DSC resources to export
    DscResourcesToExport = @()
    
    # Module list (for information only)
    ModuleList = @('MyUtilities')
    
    # File list (for information only)
    FileList = @(
        'MyUtilities.psm1',
        'MyUtilities.psd1',
        'README.md'
    )
    
    # Private data
    PrivateData = @{
        # PowerShell Gallery metadata
        PSData = @{
            # Tags for PowerShell Gallery
            Tags = @('System', 'Network', 'Utilities', 'Administration')
            
            # License URI
            LicenseUri = 'https://github.com/yourrepo/MyUtilities/blob/main/LICENSE'
            
            # Project URI
            ProjectUri = 'https://github.com/yourrepo/MyUtilities'
            
            # Icon URI
            IconUri = 'https://github.com/yourrepo/MyUtilities/raw/main/icon.png'
            
            # Release notes URI
            ReleaseNotes = 'https://github.com/yourrepo/MyUtilities/blob/main/CHANGELOG.md'
            
            # Prerelease string
            Prerelease = ''
            
            # External module dependencies
            ExternalModuleDependencies = @()
            
            # Minimum PowerShell version for Gallery
            RequireLicenseAcceptance = $false
        }
        
        # Custom configuration
        Configuration = @{
            DefaultTimeout = 5000
            MaxRetries = 3
            LogLevel = 'Information'
        }
    }
    
    # Help info URI
    HelpInfoURI = 'https://github.com/yourrepo/MyUtilities/docs'
}
```

**Dynamic Manifest Generation:**

```powershell
# Generate manifest programmatically
$manifestParams = @{
    Path = '.\MyUtilities.psd1'
    RootModule = 'MyUtilities.psm1'
    ModuleVersion = '1.0.0'
    GUID = [System.Guid]::NewGuid()
    Author = 'Your Name'
    Description = 'Generated module manifest'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Get-SystemInformation', 'Test-NetworkConnectivity')
    Tags = @('Utilities', 'System')
    ProjectUri = 'https://github.com/yourrepo/project'
}

New-ModuleManifest @manifestParams
```

**Manifest Validation:**

```powershell
# Test manifest syntax and completeness
Test-ModuleManifest -Path '.\MyUtilities.psd1'

# Import and validate module structure
Import-Module '.\MyUtilities.psd1' -Force -Verbose

# Check exported members
Get-Module MyUtilities | Select-Object -ExpandProperty ExportedFunctions
Get-Module MyUtilities | Select-Object -ExpandProperty ExportedCmdlets
```

### Module Auto-loading

PowerShell automatically discovers and loads modules when commands are executed, improving user experience and performance.

**Module Discovery Paths:** PowerShell searches for modules in directories specified by `$env:PSModulePath`:

```powershell
# View current module paths
$env:PSModulePath -split [IO.Path]::PathSeparator

# Add custom module path
$customPath = "C:\CustomModules"
if ($env:PSModulePath -notlike "*$customPath*") {
    $env:PSModulePath += [IO.Path]::PathSeparator + $customPath
}

# Add to user profile for persistence
$profilePath = Split-Path $PROFILE -Parent
if (!(Test-Path $profilePath)) { New-Item -ItemType Directory -Path $profilePath -Force }
Add-Content -Path $PROFILE -Value "`$env:PSModulePath += `";C:\CustomModules`""
```

**Auto-loading Configuration:**

```powershell
# Check auto-loading preference
$PSModuleAutoLoadingPreference

# Disable auto-loading
$PSModuleAutoLoadingPreference = 'None'

# Enable auto-loading (default)
$PSModuleAutoLoadingPreference = 'All'

# Auto-load only from module paths
$PSModuleAutoLoadingPreference = 'ModuleQualified'
```

**Module Discovery Process:** [Inference] When PowerShell encounters an unknown command, it follows these steps:

1. Searches module paths for matching command names
2. Examines manifest files for exported functions
3. Loads the appropriate module automatically
4. Executes the command

**Optimizing Auto-loading Performance:**

```powershell
# Create module with explicit exports for better discovery
# In module manifest
FunctionsToExport = @(
    'Get-SystemInformation',
    'Test-NetworkConnectivity'
    # Explicit list performs better than wildcards
)

# Use module qualification for faster loading
MyUtilities\Get-SystemInformation

# Pre-load frequently used modules
Import-Module MyUtilities, AnotherModule -Force
```

### Publishing to PowerShell Gallery

The PowerShell Gallery is the central repository for sharing PowerShell modules with the global community.

**Preparation for Publishing:**

```powershell
# Install PowerShellGet (if not present)
Install-Module -Name PowerShellGet -Force -AllowClobber

# Register for PowerShell Gallery API key
# Visit: https://www.powershellgallery.com/account/apikeys

# Set API key (run once)
$apiKey = "your-api-key-here"
```

**Pre-publication Validation:**

```powershell
# Validate module structure
Test-ModuleManifest -Path '.\MyUtilities.psd1'

# Run PSScriptAnalyzer for best practices
Install-Module -Name PSScriptAnalyzer
Invoke-ScriptAnalyzer -Path '.\MyUtilities.psm1' -Recurse

# Test module functionality
Import-Module '.\MyUtilities.psd1' -Force
Get-Command -Module MyUtilities
```

**Publishing Process:**

```powershell
# Publish module to PowerShell Gallery
Publish-Module -Path '.\MyUtilities' -NuGetApiKey $apiKey -Verbose

# Publish with additional parameters
Publish-Module -Path '.\MyUtilities' `
               -NuGetApiKey $apiKey `
               -Tags @('System', 'Network', 'Utilities') `
               -ProjectUri 'https://github.com/yourrepo/MyUtilities' `
               -LicenseUri 'https://github.com/yourrepo/MyUtilities/blob/main/LICENSE' `
               -ReleaseNotes 'Initial release with system and network utilities'
```

**Publishing Scripts:**

```powershell
# Publish standalone scripts
Publish-Script -Path '.\Get-SystemReport.ps1' `
               -NuGetApiKey $apiKey `
               -Description 'Generates comprehensive system reports'
```

**Publishing Best Practices:**

```powershell
# Include comprehensive metadata in manifest
@{
    # Semantic versioning
    ModuleVersion = '1.0.0'
    
    # Detailed description
    Description = 'Comprehensive description of module functionality and use cases'
    
    # Relevant tags for discoverability
    Tags = @('System', 'Network', 'Utilities', 'Windows', 'Linux', 'CrossPlatform')
    
    # Documentation links
    ProjectUri = 'https://github.com/yourrepo/MyUtilities'
    LicenseUri = 'https://github.com/yourrepo/MyUtilities/blob/main/LICENSE'
    ReleaseNotes = 'Detailed changelog and release notes'
    
    # Icon for visual identification
    IconUri = 'https://github.com/yourrepo/MyUtilities/raw/main/icon.png'
}
```

### Module Versioning and Dependencies

Proper versioning and dependency management ensure module compatibility and smooth upgrades.

**Semantic Versioning:** PowerShell Gallery follows semantic versioning (SemVer) principles:

- **Major version** (X.0.0): Breaking changes
- **Minor version** (0.X.0): New features, backward compatible
- **Patch version** (0.0.X): Bug fixes, backward compatible
- **Prerelease** (1.0.0-alpha): Pre-production versions

```powershell
# Version progression examples
'1.0.0'        # Initial release
'1.0.1'        # Bug fix
'1.1.0'        # New feature
'2.0.0'        # Breaking change
'2.0.0-beta'   # Prerelease version
```

**Dependency Management:**

```powershell
# Specify required modules in manifest
RequiredModules = @(
    'Microsoft.PowerShell.Utility',
    @{ModuleName = 'ImportExcel'; ModuleVersion = '7.0.0'},
    @{ModuleName = 'Pester'; ModuleVersion = '5.0.0'; MaximumVersion = '5.9.9'}
)

# External dependencies
ExternalModuleDependencies = @('AzureRM', 'AWS.Tools.Common')

# Runtime dependency checking
function Test-ModuleDependencies {
    param([string[]]$RequiredModules)
    
    $missing = @()
    foreach ($module in $RequiredModules) {
        if (!(Get-Module -ListAvailable -Name $module)) {
            $missing += $module
        }
    }
    
    if ($missing.Count -gt 0) {
        throw "Missing required modules: $($missing -join ', ')"
    }
}

# Check dependencies on module import
Test-ModuleDependencies -RequiredModules @('ImportExcel', 'Pester')
```

**Version Compatibility:**

```powershell
# Check PowerShell version compatibility
if ($PSVersionTable.PSVersion -lt '5.1') {
    throw "This module requires PowerShell 5.1 or later"
}

# Edition compatibility
if ($PSVersionTable.PSEdition -eq 'Core' -and $PSVersionTable.PSVersion -lt '6.0') {
    Write-Warning "Some features may not work correctly on PowerShell Core versions below 6.0"
}

# Cross-platform considerations
if ($IsWindows) {
    # Windows-specific functionality
} elseif ($IsLinux) {
    # Linux-specific functionality
} elseif ($IsMacOS) {
    # macOS-specific functionality
}
```

**Automated Version Management:**

```powershell
# Build script for version increment
param(
    [ValidateSet('Major', 'Minor', 'Patch')]
    [string]$VersionBump = 'Patch'
)

# Read current version from manifest
$manifest = Import-PowerShellDataFile -Path '.\MyUtilities.psd1'
$currentVersion = [Version]$manifest.ModuleVersion

# Increment version based on bump type
switch ($VersionBump) {
    'Major' { $newVersion = [Version]::new($currentVersion.Major + 1, 0, 0) }
    'Minor' { $newVersion = [Version]::new($currentVersion.Major, $currentVersion.Minor + 1, 0) }
    'Patch' { $newVersion = [Version]::new($currentVersion.Major, $currentVersion.Minor, $currentVersion.Build + 1) }
}

# Update manifest with new version
Update-ModuleManifest -Path '.\MyUtilities.psd1' -ModuleVersion $newVersion.ToString()
Write-Host "Version updated from $currentVersion to $newVersion"
```

**Installation and Update Management:**

```powershell
# Install specific version
Install-Module -Name MyUtilities -RequiredVersion '1.2.0'

# Install prerelease version
Install-Module -Name MyUtilities -AllowPrerelease

# Update to latest version
Update-Module -Name MyUtilities

# Side-by-side version installation
Install-Module -Name MyUtilities -RequiredVersion '2.0.0' -Force

# Version cleanup
Get-Module -ListAvailable MyUtilities | 
    Where-Object Version -lt '2.0.0' | 
    Uninstall-Module -Force
```

**Key points**: Modules provide the foundation for organizing and distributing PowerShell code. Create well-structured modules with comprehensive manifests, implement proper versioning strategies, and leverage auto-loading for optimal user experience. When publishing to PowerShell Gallery, follow best practices for metadata, documentation, and dependency management to ensure broad compatibility and ease of use.

---

