## Remote Sessions


### Invoke-Command for Remote Execution

Invoke-Command serves as PowerShell's primary cmdlet for executing commands and scripts on remote computers. This cmdlet supports both one-time command execution and reusable session-based operations, enabling administrators to manage multiple systems efficiently.

**Key Points:**

- Executes commands on one or multiple remote computers simultaneously
- Supports both ad-hoc connections and persistent sessions
- Returns serialized objects from remote execution
- Handles authentication automatically through various methods

Invoke-Command establishes temporary connections by default, executing specified commands or script blocks on target machines. The cmdlet serializes results and returns them to the local session, maintaining object types where possible. Authentication occurs through current user credentials, stored credentials, or alternative authentication mechanisms.

The -ComputerName parameter accepts single computers, arrays of computer names, or computer objects from Active Directory. Script blocks contain the code to execute remotely, while -FilePath parameter enables remote script file execution. Results return as deserialized objects with remote system information preserved.

**Example:**

```powershell
# Execute command on single remote computer
Invoke-Command -ComputerName "Server01" -ScriptBlock { Get-Process }

# Execute on multiple computers
$servers = @("Server01", "Server02", "Server03")
Invoke-Command -ComputerName $servers -ScriptBlock { 
    Get-WmiObject -Class Win32_OperatingSystem | Select-Object Caption, TotalVisibleMemorySize 
}

# Execute script file remotely
Invoke-Command -ComputerName "Server01" -FilePath "C:\Scripts\SystemInfo.ps1"

# Pass parameters to remote script
Invoke-Command -ComputerName "Server01" -ScriptBlock { 
    param($ServiceName)
    Get-Service -Name $ServiceName
} -ArgumentList "Spooler"

# Use different credentials
$cred = Get-Credential
Invoke-Command -ComputerName "Server01" -Credential $cred -ScriptBlock { hostname }
```

Remote execution limitations include serialization constraints where complex objects may lose methods or properties, and certain cmdlets requiring interactive sessions may not function properly. Network connectivity and firewall configurations affect remote command success.

### New-PSSession and Enter-PSSession

PowerShell sessions provide persistent connections to remote computers, maintaining state between command executions. New-PSSession creates session objects for reuse, while Enter-PSSession establishes interactive remote shell sessions.

**Key Points:**

- New-PSSession creates reusable session objects
- Enter-PSSession provides interactive remote shells
- Sessions maintain variable state and loaded modules
- Session objects enable efficient multi-command operations

New-PSSession establishes authenticated connections without immediately executing commands, returning session objects for subsequent use. These sessions persist until explicitly closed or the PowerShell process terminates. Session objects store connection information, authentication details, and remote system state.

Enter-PSSession creates interactive command-line sessions where subsequent commands execute directly on the remote computer. The PowerShell prompt changes to indicate remote session status, and all commands run in the remote context until the session exits.

**Example:**

```powershell
# Create new session
$session = New-PSSession -ComputerName "Server01"

# Use session for multiple commands
Invoke-Command -Session $session -ScriptBlock { $env:COMPUTERNAME }
Invoke-Command -Session $session -ScriptBlock { Get-Date }

# Create multiple sessions
$sessions = New-PSSession -ComputerName @("Server01", "Server02", "Server03")

# Enter interactive session
Enter-PSSession -ComputerName "Server01"
# Commands now execute on Server01
Get-Process
Exit-PSSession

# Enter existing session
Enter-PSSession -Session $session
```

Session configuration affects available cmdlets, execution policies, and security settings. Default session configurations provide access to core PowerShell functionality, while custom configurations can restrict or extend available capabilities.

### Session Management and Cleanup

Proper session management prevents resource exhaustion and maintains system performance. PowerShell provides cmdlets for monitoring active sessions, managing session limits, and ensuring cleanup of unused connections.

**Key Points:**

- Get-PSSession lists active sessions
- Remove-PSSession closes and cleans up sessions
- Session limits prevent resource exhaustion
- Automatic cleanup occurs on PowerShell exit

Session objects consume memory and network resources on both local and remote systems. Each session maintains connection state, authentication tokens, and execution context. Excessive sessions can impact system performance and exhaust available connection limits.

Get-PSSession displays all active sessions with their connection status, computer names, and availability. Sessions in "Disconnected" state indicate network issues or remote system problems. Session cleanup should occur regularly in long-running scripts or interactive sessions.

**Example:**

```powershell
# List all active sessions
Get-PSSession

# List sessions by computer name
Get-PSSession -ComputerName "Server01"

# Check session state
Get-PSSession | Where-Object { $_.State -eq "Opened" }

# Remove specific session
$session = New-PSSession -ComputerName "Server01"
Remove-PSSession -Session $session

# Remove all sessions
Get-PSSession | Remove-PSSession

# Remove sessions by computer name
Get-PSSession -ComputerName "Server01" | Remove-PSSession

# Session cleanup function
function Clear-MySessions {
    $sessions = Get-PSSession
    if ($sessions) {
        Write-Host "Cleaning up $($sessions.Count) sessions"
        $sessions | Remove-PSSession
    }
}
```

Session timeout settings automatically close inactive sessions after specified periods. These settings help prevent abandoned sessions from consuming resources indefinitely. Manual cleanup remains important for immediate resource recovery.

### Persistent Connections

Persistent sessions maintain connectivity across network interruptions and PowerShell session closures. Disconnect-PSSession and Connect-PSSession enable session persistence, allowing long-running operations to continue despite temporary network issues.

**Key Points:**

- Disconnect-PSSession preserves sessions across network interruptions
- Connect-PSSession reattaches to disconnected sessions
- Persistent sessions survive PowerShell process termination
- Session data remains available after reconnection

Session disconnection preserves the remote PowerShell runspace while allowing local session closure. Disconnected sessions continue executing running commands and maintain variable state. Reconnection restores full session functionality and retrieves any command output generated during disconnection.

Persistent connections enable reliable execution of long-running remote operations, such as software installations, data migrations, or system maintenance tasks. These sessions provide fault tolerance against network instability and planned maintenance windows.

**Example:**

```powershell
# Create session and start long-running operation
$session = New-PSSession -ComputerName "Server01"
Invoke-Command -Session $session -ScriptBlock { 
    # Start long-running process
    Start-Job -ScriptBlock { 
        1..1000 | ForEach-Object { 
            Start-Sleep -Seconds 1
            Write-Output "Processing item $_"
        }
    }
} -AsJob

# Disconnect session
Disconnect-PSSession -Session $session

# List disconnected sessions
Get-PSSession -ComputerName "Server01" | Where-Object { $_.State -eq "Disconnected" }

# Reconnect to session
$reconnected = Connect-PSSession -ComputerName "Server01" -Name $session.Name

# Check job status after reconnection
Invoke-Command -Session $reconnected -ScriptBlock { Get-Job }

# Disconnect all sessions on computer
Get-PSSession -ComputerName "Server01" | Disconnect-PSSession
```

Session persistence requires proper network configuration and sufficient system resources on remote computers. Disconnected sessions consume memory and may be subject to automatic cleanup policies on the remote system.

### Fan-out Remoting to Multiple Machines

Fan-out remoting enables simultaneous command execution across multiple remote computers, dramatically reducing administrative overhead for large-scale operations. PowerShell's parallel processing capabilities optimize network utilization and execution time.

**Key Points:**

- Parallel execution across multiple target computers
- Configurable concurrency limits prevent resource exhaustion
- Aggregated results from all target systems
- Error handling for individual system failures

Fan-out operations execute identical commands across multiple systems simultaneously, collecting and aggregating results. The -ThrottleLimit parameter controls maximum concurrent connections, preventing network and system overload. Default throttling limits balance performance with resource consumption.

Result aggregation combines output from all target systems while preserving source computer identification. PowerShell adds computer name properties to returned objects, enabling result filtering and system-specific analysis. Error handling ensures individual system failures don't prevent overall operation completion.

**Example:**

```powershell
# Execute command on multiple servers
$servers = @("Server01", "Server02", "Server03", "Server04", "Server05")
$results = Invoke-Command -ComputerName $servers -ScriptBlock {
    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        Uptime = (Get-WmiObject -Class Win32_OperatingSystem).LastBootUpTime
        FreeMemory = (Get-WmiObject -Class Win32_OperatingSystem).FreePhysicalMemory
        DiskSpace = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    }
} -ThrottleLimit 10

# Process aggregated results
$results | Sort-Object ComputerName | Format-Table

# Fan-out with sessions for better performance
$sessions = New-PSSession -ComputerName $servers
$results = Invoke-Command -Session $sessions -ScriptBlock {
    Get-EventLog -LogName System -Newest 10 -EntryType Error
}

# Clean up sessions
$sessions | Remove-PSSession

# Advanced fan-out with error handling
$scriptBlock = {
    try {
        $services = Get-Service | Where-Object { $_.Status -eq "Stopped" }
        [PSCustomObject]@{
            ComputerName = $env:COMPUTERNAME
            StoppedServices = $services.Count
            Services = $services.Name -join "; "
            Success = $true
            Error = $null
        }
    }
    catch {
        [PSCustomObject]@{
            ComputerName = $env:COMPUTERNAME
            StoppedServices = 0
            Services = ""
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

$results = Invoke-Command -ComputerName $servers -ScriptBlock $scriptBlock -ErrorAction Continue
```

**Output:** Fan-out remoting produces consolidated results showing data from all target systems, with each object tagged with its source computer. Failed connections generate error records while successful operations return expected data, enabling administrators to quickly identify systems requiring attention.

Performance optimization for fan-out operations includes adjusting throttle limits based on network capacity and target system capabilities. Very large-scale deployments may require staged execution or specialized tools for optimal performance.

**Important related topics:** PowerShell Desired State Configuration (DSC) for large-scale configuration management, Windows Remote Management (WinRM) configuration and security, PowerShell remoting over SSH for cross-platform management, and Just Enough Administration (JEA) for secure remote access.

---

