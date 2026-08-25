## PowerShell Remoting Setup


### WinRM Configuration

Windows Remote Management (WinRM) serves as the foundation for PowerShell remoting, implementing the WS-Management protocol for secure communication between systems. WinRM configuration involves service settings, listener configuration, and firewall rules.

#### Basic WinRM Initialization

The `Enable-PSRemoting` cmdlet performs comprehensive WinRM setup, configuring the service, creating listeners, and establishing firewall exceptions.

```powershell
# Enable remoting with default settings
Enable-PSRemoting -Force

# Manual WinRM service configuration
Set-Service -Name WinRM -StartupType Automatic
Start-Service -Name WinRM

# Verify WinRM configuration
Get-WSManInstance -ResourceURI winrm/config
```

#### Advanced WinRM Service Configuration

WinRM service settings control memory allocation, connection limits, and timeout values for optimal performance and security.

```powershell
# Configure service settings
Set-WSManInstance -ResourceURI winrm/config/service -ValueSet @{
    MaxConcurrentOperationsPerUser = 100
    MaxConnections = 25
    MaxPacketRetrievalTimeSeconds = 120
    AllowUnencrypted = $false
}

# Set shell configuration
Set-WSManInstance -ResourceURI winrm/config/winrs -ValueSet @{
    MaxMemoryPerShellMB = 512
    MaxProcessesPerShell = 100
    MaxShellsPerUser = 5
}
```

#### WinRM Listener Management

Listeners define the endpoints where WinRM accepts connections, supporting HTTP and HTTPS protocols with configurable addresses and ports.

```powershell
# Create HTTPS listener with certificate
$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Subject -like "*$env:COMPUTERNAME*" }
New-WSManInstance -ResourceURI winrm/config/Listener -SelectorSet @{Transport="HTTPS"; Address="*"} -ValueSet @{
    Hostname = $env:COMPUTERNAME
    CertificateThumbprint = $cert.Thumbprint
}

# Configure HTTP listener with specific IP
New-WSManInstance -ResourceURI winrm/config/Listener -SelectorSet @{Transport="HTTP"; Address="192.168.1.100"} -ValueSet @{Port=5985}

# View existing listeners
Get-WSManInstance -ResourceURI winrm/config/listener -Enumerate
```

#### Firewall Configuration

PowerShell remoting requires specific firewall rules for WinRM traffic, with different configurations for domain and non-domain environments.

```powershell
# Enable firewall rules for remoting
Enable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"
Enable-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)"

# Create custom firewall rule
New-NetFirewallRule -DisplayName "PowerShell Remoting Custom" -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow

# Configure for non-domain networks
Set-NetConnectionProfile -NetworkCategory Private
```

### Authentication Methods

#### Kerberos Authentication

Kerberos provides the most secure authentication method for domain-joined computers, supporting delegation and mutual authentication without credential transmission.

```powershell
# Verify Kerberos configuration
Get-WSManCredSSP

# Test Kerberos authentication
Test-WSMan -ComputerName server01.domain.com -Authentication Kerberos

# Configure Kerberos delegation
Set-ADUser -Identity "COMPUTER$" -TrustedForDelegation $true
```

#### NTLM Authentication

NTLM authentication works across workgroup and domain boundaries but provides lower security than Kerberos, requiring careful configuration for non-domain scenarios.

```powershell
# Enable NTLM authentication
Set-WSManInstance -ResourceURI winrm/config/service/auth -ValueSet @{Basic=$false; Kerberos=$true; Negotiate=$true; Certificate=$false; CredSSP=$false}

# Test NTLM connectivity
Test-WSMan -ComputerName 192.168.1.100 -Authentication Negotiate
```

#### Certificate-Based Authentication

Certificate authentication provides strong security for non-domain environments, using client certificates for identity verification.

```powershell
# Configure certificate authentication
Set-WSManInstance -ResourceURI winrm/config/service/auth -ValueSet @{Certificate=$true}

# Map certificate to user account
New-WSManInstance -ResourceURI winrm/config/service/certmapping -ValueSet @{
    Subject = "CN=PowerShellUser"
    URI = "*"
    Issuer = "DC=company, DC=com"
    UserName = "domain\psuser"
    Password = "password"
}

# Create client certificate mapping
$cert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -eq "CN=PowerShellUser" }
Set-Item -Path WSMan:\localhost\ClientCertificate\ClientCertificate_1234567890 -Value @{
    Subject = "CN=PowerShellUser"
    URI = "https://server01:5986/wsman"
    Issuer = "DC=company, DC=com"
}
```

#### CredSSP Authentication

[Unverified] CredSSP authentication enables credential delegation for double-hop scenarios but introduces security risks by transmitting credentials to remote systems.

```powershell
# Enable CredSSP on client
Enable-WSManCredSSP -Role Client -DelegateComputer "server01.domain.com" -Force

# Enable CredSSP on server
Enable-WSManCredSSP -Role Server -Force

# Verify CredSSP configuration
Get-WSManCredSSP

# Use CredSSP in session
$cred = Get-Credential
New-PSSession -ComputerName server01 -Credential $cred -Authentication CredSSP
```

### Trusted Hosts and Certificates

#### Trusted Hosts Configuration

The TrustedHosts list specifies remote computers that can be accessed without Kerberos authentication, essential for workgroup and cross-domain scenarios.

```powershell
# View current trusted hosts
Get-Item WSMan:\localhost\Client\TrustedHosts

# Add specific hosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "server01,server02,192.168.1.100"

# Add all hosts (security risk)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*"

# Append to existing list
$current = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$current,newserver.domain.com"
```

#### Certificate Management for HTTPS

HTTPS listeners require properly configured certificates with appropriate subject names and usage extensions for secure communication.

```powershell
# Generate self-signed certificate for testing
$cert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My -KeyUsage DigitalSignature,KeyEncipherment -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1")

# Import certificate to trusted root
$rootStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "LocalMachine")
$rootStore.Open("ReadWrite")
$rootStore.Add($cert)
$rootStore.Close()

# Configure HTTPS listener with certificate
winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=$env:COMPUTERNAME; CertificateThumbprint=$cert.Thumbprint}
```

#### Certificate Validation Configuration

Certificate validation settings control how PowerShell remoting verifies server certificates, balancing security with operational requirements.

```powershell
# Disable certificate validation (testing only)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*"
$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck

# Configure certificate validation
Set-WSManInstance -ResourceURI winrm/config/client -ValueSet @{
    TrustedHosts = "server01.domain.com"
    AllowUnencrypted = $false
}

# Custom certificate validation
$sessionOption = New-PSSessionOption -ProxyAccessType NoProxyServer -ProxyAuthentication Basic
```

### PowerShell Remoting Security

#### Session Configuration Security

Session configurations define the PowerShell environment available to remote users, controlling available cmdlets, modules, and execution privileges.

```powershell
# Create restricted session configuration
Register-PSSessionConfiguration -Name RestrictedRemoting -StartupScript "C:\Scripts\RestrictedEnvironment.ps1" -ShowSecurityDescriptorUI

# Configure session with limited cmdlets
$sessionConfig = @{
    Name = "LimitedAccess"
    SessionType = "RestrictedRemoteServer"
    ModulesToImport = @("Microsoft.PowerShell.Management", "Microsoft.PowerShell.Utility")
    VisibleCmdlets = @("Get-Process", "Get-Service", "Get-EventLog")
    VisibleFunctions = @("Get-CustomInfo")
    RunAsCredential = Get-Credential "domain\serviceaccount"
}
Register-PSSessionConfiguration @sessionConfig

# View session configurations
Get-PSSessionConfiguration
```

#### Just Enough Administration (JEA)

JEA provides role-based access control for PowerShell remoting, defining precise capabilities and constraints for different user roles.

```powershell
# Create role capability file
New-PSRoleCapabilityFile -Path "C:\JEA\ServiceDesk.psrc" -ModulesToImport @("Microsoft.PowerShell.Management") -VisibleCmdlets @(
    @{Name="Get-Service"; Parameters=@{Name="Name"; ValidateSet=@("Spooler", "BITS", "Themes")}},
    @{Name="Restart-Service"; Parameters=@{Name="Name"; ValidateSet=@("Spooler", "BITS", "Themes")}}
)

# Create session configuration file
New-PSSessionConfigurationFile -Path "C:\JEA\ServiceDesk.pssc" -SessionType RestrictedRemoteServer -RoleDefinitions @{
    "DOMAIN\ServiceDesk" = @{ RoleCapabilities = "ServiceDesk" }
    "DOMAIN\ServerAdmins" = @{ RoleCapabilities = "ServiceDesk", "ServerManagement" }
}

# Register JEA endpoint
Register-PSSessionConfiguration -Name ServiceDesk -Path "C:\JEA\ServiceDesk.pssc"
```

#### Network Security Considerations

PowerShell remoting security extends beyond authentication to include network segmentation, monitoring, and access control.

```powershell
# Configure network security
Set-WSManInstance -ResourceURI winrm/config/service -ValueSet @{
    IPv4Filter = "192.168.1.0/24,10.0.0.0/8"
    IPv6Filter = ""
    EnableCompatibilityHttpListener = $false
}

# Monitor remoting sessions
Get-PSSession | Select-Object ComputerName, State, Availability, ConfigurationName

# Log remoting activities
Set-WSManInstance -ResourceURI winrm/config/service -ValueSet @{
    LoggingLevel = "Verbose"
}
```

#### Constrained Language Mode

[Inference] Constrained Language Mode restricts PowerShell language features to prevent potentially dangerous operations in remote sessions.

```powershell
# Configure constrained language mode
$sessionConfig = New-PSSessionConfigurationFile -SessionType RestrictedRemoteServer -LanguageMode ConstrainedLanguage -ExecutionPolicy Restricted

# Test language mode restrictions
Invoke-Command -ComputerName server01 -ScriptBlock { $ExecutionContext.SessionState.LanguageMode }

# Create custom constraint
$sessionConfig = New-PSSessionConfigurationFile -SessionType RestrictedRemoteServer -ScriptsToProcess "C:\Scripts\ConstraintScript.ps1"
```

#### Audit and Logging Configuration

Comprehensive logging captures remoting activities for security monitoring and compliance requirements.

```powershell
# Enable PowerShell logging
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Name EnableModuleLogging -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name EnableScriptBlockLogging -Value 1

# Configure WinRM logging
wevtutil sl Microsoft-Windows-WinRM/Operational /e:true /rt:true /ms:102400000

# Monitor remoting events
Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" | Where-Object { $_.Id -eq 4103 -or $_.Id -eq 4104 }
```

#### Advanced Security Hardening

Security hardening involves multiple layers of protection including endpoint security, network isolation, and monitoring integration.

```powershell
# Disable unused authentication methods
Set-WSManInstance -ResourceURI winrm/config/service/auth -ValueSet @{
    Basic = $false
    Digest = $false
    Certificate = $true
    Kerberos = $true
    Negotiate = $true
    CredSSP = $false
}

# Configure session timeouts
Set-WSManInstance -ResourceURI winrm/config/service -ValueSet @{
    MaxConcurrentOperations = 50
    EnumerationTimeoutms = 60000
    MaxPacketRetrievalTimeSeconds = 120
}

# Implement connection throttling
Set-WSManInstance -ResourceURI winrm/config/service -ValueSet @{
    MaxConnections = 10
    MaxConcurrentOperationsPerUser = 15
}
```

**Key points**: PowerShell remoting setup requires careful WinRM configuration, appropriate authentication method selection, proper certificate management, and comprehensive security hardening. Critical components include listener configuration, firewall rules, trusted hosts management, and session security through JEA and constrained language modes. Security considerations encompass authentication protocols, network access controls, audit logging, and endpoint hardening measures.

**Important related topics**: PowerShell Desired State Configuration (DSC) for remoting deployment, Group Policy management for enterprise remoting configuration, integration with identity management systems, PowerShell remoting troubleshooting techniques, and advanced session management strategies for large-scale environments.

---

