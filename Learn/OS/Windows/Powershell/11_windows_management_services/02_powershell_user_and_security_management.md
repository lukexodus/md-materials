## PowerShell User and Security Management


### User Account Management

PowerShell provides comprehensive cmdlets for managing local and domain user accounts, enabling administrators to create, modify, and maintain user accounts programmatically.

#### Local User Account Operations

Local user account management involves working with accounts stored on individual computers rather than in Active Directory.

**Example:**

```powershell
# Create new local user
$password = ConvertTo-SecureString "TempPassword123!" -AsPlainText -Force
New-LocalUser -Name "ServiceAccount01" -Password $password -Description "Application service account"

# Get user information
Get-LocalUser -Name "ServiceAccount01"
Get-LocalUser | Where-Object { $_.Enabled -eq $true }

# Modify user properties
Set-LocalUser -Name "ServiceAccount01" -Description "Updated service account" -PasswordNeverExpires $true

# Disable/Enable users
Disable-LocalUser -Name "ServiceAccount01"
Enable-LocalUser -Name "ServiceAccount01"
```

#### User Property Management

User accounts contain multiple properties that can be queried and modified through PowerShell commands.

**Example:**

```powershell
# View all user properties
Get-LocalUser -Name "TestUser" | Format-List *

# Check account status
$user = Get-LocalUser -Name "TestUser"
Write-Verbose "Account enabled: $($user.Enabled)"
Write-Verbose "Password expires: $($user.PasswordExpires)"
Write-Verbose "Last logon: $($user.LastLogon)"

# Reset user password
$newPassword = Read-Host "Enter new password" -AsSecureString
Set-LocalUser -Name "TestUser" -Password $newPassword
```

#### Bulk User Operations

PowerShell enables efficient management of multiple user accounts through pipeline operations and CSV import functionality.

**Example:**

```powershell
# Create multiple users from CSV
$users = Import-Csv "C:\Scripts\NewUsers.csv"
foreach ($user in $users) {
    $securePassword = ConvertTo-SecureString $user.Password -AsPlainText -Force
    New-LocalUser -Name $user.Username -Password $securePassword -FullName $user.FullName -Description $user.Description
    Write-Verbose "Created user: $($user.Username)"
}

# Disable multiple users
$inactiveUsers = @("User1", "User2", "User3")
$inactiveUsers | ForEach-Object {
    Disable-LocalUser -Name $_
    Write-Debug "Disabled user: $_"
}
```

### Group Membership and Permissions

Group management in PowerShell involves creating, modifying, and managing group memberships for both local and domain environments.

#### Local Group Management

Local groups provide access control for resources on individual computers and can be managed through dedicated PowerShell cmdlets.

**Example:**

```powershell
# Create new local group
New-LocalGroup -Name "DatabaseAdmins" -Description "Local database administrators"

# Add users to group
Add-LocalGroupMember -Group "DatabaseAdmins" -Member "User1", "User2"
Add-LocalGroupMember -Group "Administrators" -Member "ServiceAccount01"

# View group membership
Get-LocalGroupMember -Group "DatabaseAdmins"
Get-LocalGroup | ForEach-Object {
    Write-Output "Group: $($_.Name)"
    Get-LocalGroupMember -Group $_.Name | ForEach-Object {
        Write-Output "  Member: $($_.Name)"
    }
}

# Remove users from group
Remove-LocalGroupMember -Group "DatabaseAdmins" -Member "User1"
```

#### Permission Analysis

Understanding and analyzing permissions requires examining Access Control Lists (ACLs) and Security Descriptors on files, folders, and registry keys.

**Example:**

```powershell
# Get file/folder permissions
$acl = Get-Acl "C:\ImportantData"
$acl.Access | Format-Table IdentityReference, FileSystemRights, AccessControlType

# Check specific user permissions
$acl.Access | Where-Object { $_.IdentityReference -like "*User1*" }

# Get registry permissions
$regAcl = Get-Acl "HKLM:\Software\MyApplication"
$regAcl.Access | Select-Object IdentityReference, RegistryRights, AccessControlType

# Check service permissions [Inference]
$service = Get-Service "Spooler"
$serviceSecurity = Get-Acl "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)"
```

#### Advanced Permission Management

PowerShell provides capabilities for modifying permissions and ownership of filesystem and registry objects.

**Example:**

```powershell
# Set file permissions
$acl = Get-Acl "C:\SecureFolder"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Domain\User1", "FullControl", "Allow")
$acl.SetAccessRule($accessRule)
Set-Acl "C:\SecureFolder" $acl

# Take ownership of file
$acl = Get-Acl "C:\LockedFile.txt"
$acl.SetOwner([System.Security.Principal.NTAccount]"Administrator")
Set-Acl "C:\LockedFile.txt" $acl

# Remove specific permissions
$acl = Get-Acl "C:\RestrictedFolder"
$acl.Access | Where-Object { $_.IdentityReference -eq "Domain\TempUser" } | ForEach-Object {
    $acl.RemoveAccessRule($_)
}
Set-Acl "C:\RestrictedFolder" $acl
```

### Working with Active Directory (Basics)

Active Directory integration requires the Active Directory PowerShell module, which provides cmdlets for managing domain users, groups, and organizational units.

#### Active Directory Module Installation

[Unverified] The Active Directory module typically comes with Remote Server Administration Tools (RSAT) or Active Directory management tools installation.

**Example:**

```powershell
# Check if AD module is available
Get-Module -Name ActiveDirectory -ListAvailable

# Import Active Directory module
Import-Module ActiveDirectory

# Verify cmdlets are available
Get-Command -Module ActiveDirectory | Measure-Object
```

#### Domain User Management

Active Directory user management involves creating, modifying, and querying user objects within the domain directory service.

**Example:**

```powershell
# Get domain user information
Get-ADUser -Identity "username" -Properties *
Get-ADUser -Filter "Department -eq 'IT'" -Properties Department, Title

# Create new domain user
New-ADUser -Name "John Smith" -GivenName "John" -Surname "Smith" -SamAccountName "jsmith" -UserPrincipalName "jsmith@company.com" -Path "OU=Users,DC=company,DC=com" -AccountPassword (ConvertTo-SecureString "TempPass123!" -AsPlainText -Force) -Enabled $true

# Modify user properties
Set-ADUser -Identity "jsmith" -Department "IT" -Title "Systems Administrator" -Description "IT Department staff member"

# Reset user password
Set-ADAccountPassword -Identity "jsmith" -NewPassword (ConvertTo-SecureString "NewPass123!" -AsPlainText -Force) -Reset
```

#### Domain Group Operations

Active Directory groups provide security and distribution capabilities across the domain environment.

**Example:**

```powershell
# Create new domain group
New-ADGroup -Name "IT-Administrators" -GroupCategory Security -GroupScope Global -Path "OU=Groups,DC=company,DC=com" -Description "IT Department Administrators"

# Add users to domain group
Add-ADGroupMember -Identity "IT-Administrators" -Members "jsmith", "anotheruser"

# Get group membership
Get-ADGroupMember -Identity "IT-Administrators" | Select-Object Name, SamAccountName

# Find groups user belongs to
Get-ADUser -Identity "jsmith" -Properties MemberOf | Select-Object -ExpandProperty MemberOf
```

#### Organizational Unit Management

Organizational Units (OUs) provide hierarchical structure for organizing Active Directory objects and applying Group Policy settings.

**Example:**

```powershell
# Create new OU
New-ADOrganizationalUnit -Name "IT Department" -Path "DC=company,DC=com" -Description "Information Technology Department"

# Get OU information
Get-ADOrganizationalUnit -Filter "Name -eq 'IT Department'" -Properties *

# Move user to different OU
Move-ADObject -Identity "CN=John Smith,OU=Users,DC=company,DC=com" -TargetPath "OU=IT Department,DC=company,DC=com"

# Find objects in specific OU
Get-ADObject -SearchBase "OU=IT Department,DC=company,DC=com" -Filter *
```

### Security Policies and Audit Logs

Security policy management and audit log analysis are critical components of system security monitoring and compliance.

#### Local Security Policy Management

Local security policies control various security settings on individual computers, including user rights assignments and security options.

**Example:**

```powershell
# Export current security policy
secedit /export /cfg C:\SecurityPolicy.inf

# View user rights assignments [Inference]
# Note: Direct PowerShell cmdlets for local security policy may be limited
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4672} | Select-Object -First 10

# Check password policy settings
Get-LocalUser | Select-Object Name, PasswordExpires, PasswordRequired, PasswordChangeableDate

# Account lockout information
net accounts
```

#### Audit Log Analysis

Windows Security logs contain detailed information about authentication, authorization, and system events that can be analyzed for security monitoring.

**Example:**

```powershell
# Get recent security events
Get-WinEvent -LogName Security -MaxEvents 100 | Where-Object { $_.Id -eq 4624 } | Select-Object TimeCreated, Id, LevelDisplayName, Message

# Analyze failed logon attempts
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625; StartTime=(Get-Date).AddDays(-1)} | ForEach-Object {
    $xml = [xml]$_.ToXml()
    [PSCustomObject]@{
        TimeCreated = $_.TimeCreated
        Account = $xml.Event.EventData.Data | Where-Object {$_.Name -eq 'TargetUserName'} | Select-Object -ExpandProperty '#text'
        Workstation = $xml.Event.EventData.Data | Where-Object {$_.Name -eq 'WorkstationName'} | Select-Object -ExpandProperty '#text'
        IPAddress = $xml.Event.EventData.Data | Where-Object {$_.Name -eq 'IpAddress'} | Select-Object -ExpandProperty '#text'
    }
}

# Monitor privilege escalation events
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4672} | Select-Object TimeCreated, @{Name='User'; Expression={($_ | Select-Object -ExpandProperty Message) -split "`n" | Where-Object {$_ -match 'Account Name:'} | ForEach-Object {$_.Split(':')[1].Trim()}}}
```

#### Group Policy Analysis

[Unverified] Group Policy settings can be analyzed and reported through PowerShell, though specific cmdlets may vary by Windows version.

**Example:**

```powershell
# Generate Group Policy report
gpresult /h C:\GPReport.html /f

# Get applied policies (if Group Policy module available)
# Import-Module GroupPolicy
# Get-GPOReport -All -ReportType Html -Path C:\AllGPOReport.html

# Check specific policy settings
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Select-Object EnableLUA, ConsentPromptBehaviorAdmin

# Audit policy settings
auditpol /get /category:*
```

#### Security Event Monitoring

Continuous monitoring of security events helps identify potential threats and policy violations.

**Example:**

```powershell
# Monitor real-time security events
Register-WinEvent -Query @{LogName='Security'; ID=4624,4625} -Action {
    $event = $Event.SourceEventArgs.NewEvent
    Write-Warning "Security Event: ID $($event.Id) at $($event.TimeCreated)"
}

# Create custom security monitoring function
function Monitor-SecurityEvents {
    param(
        [int[]]$EventIds = @(4624, 4625, 4648, 4672),
        [int]$Hours = 24
    )
    
    $startTime = (Get-Date).AddHours(-$Hours)
    $events = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=$EventIds; StartTime=$startTime}
    
    foreach ($event in $events) {
        $xml = [xml]$event.ToXml()
        Write-Output "Event ID: $($event.Id) - Time: $($event.TimeCreated)"
        Write-Debug "Full event data: $($event.Message)"
    }
}
```

#### Compliance Reporting

Generate reports for security compliance and audit requirements.

**Example:**

```powershell
# User account status report
$users = Get-LocalUser
$report = foreach ($user in $users) {
    [PSCustomObject]@{
        Username = $user.Name
        Enabled = $user.Enabled
        PasswordExpires = $user.PasswordExpires
        LastLogon = $user.LastLogon
        AccountExpires = $user.AccountExpires
        Groups = (Get-LocalGroup | Where-Object { (Get-LocalGroupMember -Group $_.Name -ErrorAction SilentlyContinue).Name -contains $user.Name }).Name -join "; "
    }
}
$report | Export-Csv "C:\UserAuditReport.csv" -NoTypeInformation

# Failed logon summary
$failedLogons = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625; StartTime=(Get-Date).AddDays(-7)} -ErrorAction SilentlyContinue
$summary = $failedLogons | Group-Object {($_.Message -split "`n" | Where-Object {$_ -match 'Account Name:'}).Split(':')[1].Trim()} | Select-Object Name, Count
Write-Output "Failed logon attempts in last 7 days:"
$summary | Format-Table -AutoSize
```

**Key points:**

- Always test security-related commands in non-production environments first
- Ensure proper permissions are in place before executing user and group management commands
- Regular backup of security policies and configurations is essential
- Audit log retention policies should align with organizational compliance requirements
- [Unverified] Some advanced security features may require specific Windows editions or additional licensing

**Conclusion:** PowerShell provides extensive capabilities for user and security management, from basic local account operations to complex Active Directory integration and comprehensive audit log analysis, enabling administrators to maintain secure and compliant Windows environments.

---

