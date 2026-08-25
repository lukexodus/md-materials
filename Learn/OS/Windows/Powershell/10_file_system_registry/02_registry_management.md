## Registry Management


### Registry Providers and Navigation

PowerShell treats the Windows Registry as a hierarchical file system through registry providers. The Registry provider enables navigation using familiar cmdlets like Get-ChildItem, Set-Location, and Get-Item.

**Key Points:**

- Two default registry drives: HKLM: (HKEY_LOCAL_MACHINE) and HKCU: (HKEY_CURRENT_USER)
- Registry keys appear as containers, registry values as properties
- Path navigation uses standard PowerShell syntax with backslashes or forward slashes

The Registry provider maps registry hives to PowerShell drives. You can navigate registry structures using Set-Location (cd) and list contents with Get-ChildItem (dir, ls). Registry keys function as directories, while registry values act as properties of those keys.

**Example:**

```powershell
# Navigate to registry location
Set-Location HKLM:\SOFTWARE\Microsoft

# List subkeys
Get-ChildItem

# Access specific key
Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"

# View key properties (registry values)
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
```

Advanced navigation techniques include using wildcards, recursive searches, and filtering. The -Recurse parameter enables deep registry exploration, while -Include and -Exclude parameters filter results based on key names.

### Reading Registry Values

PowerShell provides multiple approaches for reading registry data, from single values to entire key structures. The Get-ItemProperty cmdlet retrieves specific registry values, while Get-Item returns the entire key object.

**Key Points:**

- Get-ItemProperty reads specific registry values
- Get-Item retrieves entire registry key objects
- Registry values have names, types, and data
- Default values use "(Default)" or empty string names

Reading single registry values requires specifying the full registry path and value name. When no value name is specified, Get-ItemProperty returns all values within the key. Registry value types include REG_SZ (string), REG_DWORD (32-bit integer), REG_BINARY (binary data), and REG_MULTI_SZ (multi-string).

**Example:**

```powershell
# Read specific registry value
$version = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductName"

# Read all values from a key
$allValues = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"

# Read default value
$defaultValue = Get-ItemProperty -Path "HKLM:\SOFTWARE\SomeKey" -Name "(Default)"

# Handle missing values with error control
try {
    $value = Get-ItemProperty -Path "HKLM:\SOFTWARE\NonExistent" -Name "Missing" -ErrorAction Stop
}
catch {
    Write-Host "Registry value not found"
}
```

Remote registry reading capabilities allow accessing registry data on remote computers using the -ComputerName parameter with appropriate cmdlets, though this requires proper permissions and network connectivity.

### Writing Registry Values

Creating and modifying registry entries involves New-Item for keys, New-ItemProperty for values, and Set-ItemProperty for modifications. PowerShell automatically handles registry value type conversions in many cases.

**Key Points:**

- New-Item creates registry keys
- New-ItemProperty creates new registry values
- Set-ItemProperty modifies existing values
- Remove-Item and Remove-ItemProperty delete keys and values respectively

Registry key creation requires specifying the parent path and new key name. Value creation needs the key path, value name, value data, and optionally the registry type. PowerShell attempts automatic type detection but explicit type specification ensures accuracy.

**Example:**

```powershell
# Create new registry key
New-Item -Path "HKLM:\SOFTWARE\MyApplication" -Force

# Create string value
New-ItemProperty -Path "HKLM:\SOFTWARE\MyApplication" -Name "Version" -Value "1.0.0" -PropertyType String

# Create DWORD value
New-ItemProperty -Path "HKLM:\SOFTWARE\MyApplication" -Name "Timeout" -Value 30 -PropertyType DWord

# Modify existing value
Set-ItemProperty -Path "HKLM:\SOFTWARE\MyApplication" -Name "Version" -Value "2.0.0"

# Create binary value
$binaryData = [byte[]](0x01, 0x02, 0x03, 0x04)
New-ItemProperty -Path "HKLM:\SOFTWARE\MyApplication" -Name "BinaryData" -Value $binaryData -PropertyType Binary
```

Registry operations require appropriate permissions. Writing to HKEY_LOCAL_MACHINE typically requires administrator privileges, while HKEY_CURRENT_USER modifications usually succeed with standard user permissions.

### Registry Security and Permissions

Registry security follows Windows Access Control List (ACL) model with specific permissions for keys and inheritance rules. PowerShell provides cmdlets for viewing and modifying registry permissions through the Security descriptor.

**Key Points:**

- Registry keys have ACLs similar to file system objects
- Permissions include Full Control, Read, Write, and special permissions
- Inheritance affects child keys automatically
- Owner rights and administrator privileges override standard permissions

Registry permissions control who can read, write, create, or delete registry keys and values. Each registry key has a security descriptor containing the owner information and discretionary access control list (DACL). Standard permissions include Read (query values and enumerate subkeys), Write (create values and subkeys), and Full Control (all operations).

**Example:**

```powershell
# Get registry key ACL
$acl = Get-Acl "HKLM:\SOFTWARE\MyApplication"

# Display current permissions
$acl.Access | Format-Table IdentityReference, RegistryRights, AccessControlType

# Create new permission rule
$accessRule = New-Object System.Security.AccessControl.RegistryAccessRule("DOMAIN\User", "ReadKey", "Allow")

# Add permission to ACL
$acl.SetAccessRule($accessRule)

# Apply modified ACL
Set-Acl -Path "HKLM:\SOFTWARE\MyApplication" -AclObject $acl

# Remove specific permission
$acl.RemoveAccessRule($accessRule)
Set-Acl -Path "HKLM:\SOFTWARE\MyApplication" -AclObject $acl
```

Special considerations include registry key ownership, inheritance behavior, and the difference between key permissions and value permissions. Some registry locations have additional protection mechanisms that prevent modification even with administrative rights.

### Backing Up and Restoring Registry Keys

Registry backup operations preserve key structures, values, and security settings for disaster recovery or system migration. PowerShell enables both manual backup through Export-RegistryKey functionality and automated backup scripting.

**Key Points:**

- Export operations create .reg files containing key data
- Import operations restore registry structure and values
- Backup scope can include single keys or entire hives
- Registry backups should include security settings when possible

Registry export creates human-readable .reg files containing registry keys, values, and data in a standardized format. These files can be imported on the same or different systems to restore registry settings. The reg.exe command-line utility provides export/import functionality, while PowerShell scripts can automate the process.

**Example:**

```powershell
# Export registry key to file
Start-Process -FilePath "reg.exe" -ArgumentList "export", "HKLM\SOFTWARE\MyApplication", "C:\Backup\MyApp.reg", "/y" -Wait

# Import registry file
Start-Process -FilePath "reg.exe" -ArgumentList "import", "C:\Backup\MyApp.reg" -Wait

# PowerShell-based backup function
function Backup-RegistryKey {
    param([string]$KeyPath, [string]$BackupPath)
    
    $regPath = $KeyPath -replace ":", ""
    $fileName = ($regPath -replace "\\", "_") + ".reg"
    $fullPath = Join-Path $BackupPath $fileName
    
    Start-Process -FilePath "reg.exe" -ArgumentList "export", $regPath, $fullPath, "/y" -Wait
}

# Backup multiple keys
$keysToBackup = @(
    "HKLM:\SOFTWARE\MyApplication",
    "HKCU:\SOFTWARE\MyApplication"
)

foreach ($key in $keysToBackup) {
    Backup-RegistryKey -KeyPath $key -BackupPath "C:\RegistryBackups"
}
```

**Output:** Registry backup operations create .reg files that can be version-controlled, transferred between systems, or stored as part of disaster recovery procedures. Regular automated backups help maintain system stability and enable quick recovery from registry corruption.

Advanced backup strategies include differential backups (only changed keys), scheduled backup tasks, and integration with system backup solutions. Registry restoration should be tested in non-production environments before applying to critical systems.

**Important related topics:** Registry monitoring and change detection, Group Policy registry management, Registry virtualization in modern Windows versions, and PowerShell Desired State Configuration (DSC) for registry management.

---

