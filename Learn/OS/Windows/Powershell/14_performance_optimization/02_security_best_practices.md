## Security Best Practices


### Execution Policies

PowerShell execution policies provide the first line of defense against unauthorized script execution by controlling which scripts can run on a system. These policies operate as safety mechanisms rather than security boundaries, preventing accidental execution of potentially harmful scripts.

**Key Points:**

- Execution policies control script execution permissions
- Policies apply at different scopes with inheritance rules
- Bypass methods exist for legitimate administrative needs
- Policies complement but don't replace proper security controls

Execution policies define rules for script execution based on script source, digital signatures, and system configuration. The Get-ExecutionPolicy cmdlet displays current policy settings, while Set-ExecutionPolicy modifies policy configuration. Policy enforcement occurs during script loading, not during individual command execution.

PowerShell supports multiple execution policy levels: Restricted (no scripts), AllSigned (only signed scripts), RemoteSigned (signed remote scripts, unsigned local scripts), Unrestricted (all scripts with prompts), and Bypass (no restrictions). Each policy level balances security with operational flexibility.

**Example:**

```powershell
# Check current execution policy
Get-ExecutionPolicy

# Check execution policy for all scopes
Get-ExecutionPolicy -List

# Set execution policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Set execution policy with force (no prompts)
Set-ExecutionPolicy -ExecutionPolicy AllSigned -Force

# Temporarily bypass execution policy
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Scripts\MyScript.ps1"

# Check if script would be allowed to run
Get-ExecutionPolicy -Scope LocalMachine
Test-Path "C:\Scripts\MyScript.ps1"

# Set different policies for different scopes
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope LocalMachine
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Policy scope hierarchy determines effective execution policy when multiple scopes have different settings. Group Policy settings override local machine settings, which override current user settings. The most restrictive applicable policy takes precedence in policy evaluation.

### Code Signing

Digital code signing provides cryptographic verification of script authenticity and integrity through certificate-based signatures. Signed scripts enable verification of publisher identity and detect unauthorized modifications after signing.

**Key Points:**

- Code signing uses digital certificates to verify script authenticity
- Authenticode signatures embed in PowerShell script files
- Certificate validation includes chain of trust verification
- Time-stamping preserves signature validity after certificate expiration

Code signing requires valid code signing certificates from trusted certificate authorities or self-signed certificates for internal use. The Set-AuthenticodeSignature cmdlet applies digital signatures to PowerShell scripts, modules, and other supported file types. Signature verification occurs automatically during script execution when execution policies require signed code.

Certificate management involves obtaining appropriate certificates, securing private keys, and maintaining certificate validity. Enterprise environments typically use internal certificate authorities for code signing, while public certificates may be required for external distribution.

**Example:**

```powershell
# Get code signing certificate from certificate store
$cert = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Select-Object -First 1

# Sign a PowerShell script
Set-AuthenticodeSignature -FilePath "C:\Scripts\MyScript.ps1" -Certificate $cert

# Verify script signature
$signature = Get-AuthenticodeSignature -FilePath "C:\Scripts\MyScript.ps1"
$signature.Status
$signature.SignerCertificate

# Sign multiple scripts
Get-ChildItem -Path "C:\Scripts\*.ps1" | ForEach-Object {
    Set-AuthenticodeSignature -FilePath $_.FullName -Certificate $cert
}

# Create self-signed certificate for testing [Unverified]
$cert = New-SelfSignedCertificate -Type CodeSigning -Subject "CN=PowerShell Code Signing" -CertStoreLocation Cert:\CurrentUser\My

# Time-stamp signature (requires internet connectivity)
Set-AuthenticodeSignature -FilePath "C:\Scripts\MyScript.ps1" -Certificate $cert -TimeStampServer "http://timestamp.digicert.com"

# Check if certificate is trusted
Test-Certificate -Cert $cert -Policy CodeSigning
```

Signature validation encompasses certificate chain verification, revocation checking, and time-stamp validation. Invalid signatures prevent script execution under AllSigned execution policy, while RemoteSigned policy only requires signatures for scripts downloaded from external sources.

### Credential Management

Secure credential handling prevents password exposure and enables automated authentication without hardcoding sensitive information. PowerShell provides multiple mechanisms for credential storage, retrieval, and secure transmission.

**Key Points:**

- PSCredential objects encapsulate usernames and secure passwords
- Get-Credential prompts for secure credential entry
- Credential storage requires additional security measures
- Alternative authentication methods reduce password dependencies

PowerShell credential objects combine usernames with SecureString password representations, protecting credentials in memory through encryption. The Get-Credential cmdlet prompts users for credentials without exposing passwords in command history or console output. Credential objects integrate seamlessly with cmdlets supporting authentication parameters.

Automated credential management requires secure storage solutions since PowerShell lacks built-in persistent credential storage. Solutions include Windows Credential Manager, encrypted configuration files, or enterprise credential management systems. [Inference] Each approach has different security implications and operational complexity.

**Example:**

```powershell
# Prompt for credentials
$credential = Get-Credential -Message "Enter domain credentials"

# Create credential object programmatically
$username = "domain\user"
$password = ConvertTo-SecureString -String "P@ssw0rd" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

# Use credentials with remote commands
Invoke-Command -ComputerName "Server01" -Credential $credential -ScriptBlock { Get-Process }

# Store credentials securely (requires additional encryption) [Unverified]
$credential | Export-Clixml -Path "C:\Secure\Credentials.xml"
$savedCredential = Import-Clixml -Path "C:\Secure\Credentials.xml"

# Use Windows Credential Manager [Inference]
# Note: Requires additional modules like CredentialManager
Install-Module -Name CredentialManager -Scope CurrentUser
New-StoredCredential -Target "PowerShellScript" -UserName "domain\user" -Password "P@ssw0rd"
$credential = Get-StoredCredential -Target "PowerShellScript"

# Service account authentication without passwords [Inference]
# Uses current user context or managed service identity
Invoke-Command -ComputerName "Server01" -Authentication Kerberos -ScriptBlock { Get-Process }
```

Credential security considerations include avoiding plaintext password storage, implementing proper access controls on credential files, and using time-limited credentials where possible. Multi-factor authentication integration requires specialized modules or external authentication providers.

### Secure String Handling

SecureString objects protect sensitive data in memory through encryption, preventing casual observation of passwords and other confidential information. These objects provide controlled access to encrypted data while maintaining operational functionality.

**Key Points:**

- SecureString encrypts sensitive data in memory
- ConvertTo-SecureString and ConvertFrom-SecureString handle conversions
- DPAPI integration provides user-specific encryption
- SecureString limitations include serialization constraints

SecureString encryption uses Windows Data Protection API (DPAPI) with user-specific keys, ensuring encrypted data remains accessible only to the creating user account. Memory protection mechanisms prevent casual access to sensitive data through debugging tools or memory dumps. SecureString objects automatically clear sensitive data during garbage collection.

Practical SecureString usage involves converting plaintext to SecureString for storage and converting back to plaintext only when necessary for system interactions. The encryption process ties SecureString data to specific user accounts and machines, preventing unauthorized access across different security contexts.

**Example:**

```powershell
# Convert plaintext to SecureString
$securePassword = ConvertTo-SecureString -String "MyPassword123" -AsPlainText -Force

# Read SecureString from console input
$secureInput = Read-Host -Prompt "Enter password" -AsSecureString

# Convert SecureString to encrypted standard string
$encryptedString = ConvertFrom-SecureString -SecureString $securePassword

# Convert encrypted string back to SecureString
$restoredSecure = ConvertTo-SecureString -String $encryptedString

# Convert SecureString to plaintext (use sparingly)
$plaintext = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))

# Use SecureString with credentials
$username = "domain\user"
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)

# Secure file storage with custom key [Inference]
$key = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43)
$encryptedWithKey = ConvertFrom-SecureString -SecureString $securePassword -Key $key
$decryptedWithKey = ConvertTo-SecureString -String $encryptedWithKey -Key $key
```

SecureString limitations include inability to serialize across PowerShell sessions and dependency on Windows DPAPI availability. Cross-platform scenarios may require alternative secure storage mechanisms. [Unverified] Some cmdlets may not accept SecureString objects directly, requiring careful plaintext conversion handling.

### PowerShell Security Features

PowerShell incorporates multiple security features designed to prevent malicious code execution and protect system integrity. These features work together to create defense-in-depth security architecture for PowerShell environments.

**Key Points:**

- Constrained Language Mode restricts potentially dangerous operations
- Application Control policies prevent unauthorized PowerShell usage
- Transcription and logging provide audit capabilities
- Module and script block logging enhance security monitoring

Constrained Language Mode limits PowerShell language features to prevent malicious script execution while maintaining basic administrative functionality. This mode disables features like Add-Type, direct .NET method calls, and COM object creation. [Inference] The mode activates automatically under certain security policies or can be configured manually.

PowerShell transcription creates detailed logs of PowerShell activity, recording commands, output, and session information. Script block logging captures the content of executed script blocks, including dynamically generated code. These logging features provide comprehensive audit trails for security monitoring and incident response.

**Example:**

```powershell
# Check current language mode
$ExecutionContext.SessionState.LanguageMode

# Enable PowerShell transcription
Start-Transcript -Path "C:\Logs\PowerShell-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

# Configure module logging (requires Group Policy or registry) [Inference]
# Registry path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Name "EnableModuleLogging" -Value 1 -PropertyType DWORD

# Configure script block logging [Inference]
# Registry path: HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1 -PropertyType DWORD

# Check for suspicious PowerShell activity in logs [Inference]
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-PowerShell/Operational'; ID=4104} | 
    Where-Object { $_.Message -match "Invoke-Expression|DownloadString|EncodedCommand" }

# Application Control integration [Unverified]
# Requires Windows Defender Application Control or AppLocker configuration
# Policy enforcement occurs at system level, not PowerShell level

# Secure PowerShell remoting configuration [Inference]
Enable-PSRemoting -Force
Set-PSSessionConfiguration -Name Microsoft.PowerShell -SecurityDescriptorSddl "O:NSG:BAD:P(A;;GA;;;BA)"
```

**Output:** PowerShell security features generate extensive logging data that requires proper storage, analysis, and retention policies. Security monitoring solutions should incorporate PowerShell logs to detect suspicious scripting activity and unauthorized system access.

Advanced security configurations include Just Enough Administration (JEA) for role-based access control, PowerShell Direct for secure VM management, and integration with enterprise security information and event management (SIEM) systems.

**Important related topics:** Just Enough Administration (JEA) implementation, Windows Defender Application Control integration, PowerShell Desired State Configuration (DSC) security considerations, and Azure PowerShell security best practices for cloud environments.

---

