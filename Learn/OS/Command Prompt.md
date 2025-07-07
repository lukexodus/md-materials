## **Basic Commands**

1. **`cd`**  
    Change the current directory.
    
    - Example: `cd C:\Users`
2. **`dir`**  
    List the contents of a directory.
    
    - Example: `dir C:\Windows`
3. **`cls`**  
    Clear the Command Prompt screen.
    
    - Example: `cls`
4. **`exit`**  
    Close the Command Prompt.
    
    - Example: `exit`
5. **`help`**  
    Display a list of available commands or detailed help for a command.
    
    - Example: `help cd`

---

### **File and Directory Management**

6. **`mkdir` (or `md`)**  
    Create a new directory.
    
    - Example: `mkdir newfolder`
7. **`rmdir` (or `rd`)**  
    Remove a directory.
    
    - Example: `rmdir newfolder`
8. **`copy`**  
    Copy files from one location to another.
    
    - Example: `copy file.txt C:\Backup`
9. **`move`**  
    Move files or rename them.
    
    - Example: `move file.txt C:\Documents`
10. **`del` (or `erase`)**  
    Delete files.
    
    - Example: `del file.txt`
11. **`ren`**  
    Rename files or directories.
    
    - Example: `ren oldname.txt newname.txt`

---

### **System Information and Management**

12. **`echo`**  
    Display messages or turn command echoing on/off.
    
    - Example: `echo Hello World`
13. **`systeminfo`**  
    Display detailed information about the system.
    
    - Example: `systeminfo`
14. **`ipconfig`**  
    Show network configuration details.
    
    - Example: `ipconfig /all`
15. **`tasklist`**  
    Display a list of running processes.
    
    - Example: `tasklist`
16. **`taskkill`**  
    Kill a running process.
    
    - Example: `taskkill /IM notepad.exe /F`

---

### **Networking**

17. **`ping`**  
    Test network connectivity.
    
    - Example: `ping google.com`
18. **`tracert`**  
    Trace the route to a network address.
    
    - Example: `tracert google.com`
19. **`netstat`**  
    Display network statistics and connections.
    
    - Example: `netstat -an`
20. **`nslookup`**  
    Query DNS records.
    
    - Example: `nslookup google.com`

---

### **File System Navigation and Search**

21. **`tree`**  
    Display a graphical representation of the directory structure.
    
    - Example: `tree C:\`
22. **`attrib`**  
    View or change file attributes.
    
    - Example: `attrib +r file.txt`
23. **`find`**  
    Search for a string in a file.
    
    - Example: `find "keyword" file.txt`
24. **`where`**  
    Locate the executable path of a command or program.
    
    - Example: `where notepad`

---

### **Disk Management**

25. **`chkdsk`**  
    Check and repair disk errors.
    
    - Example: `chkdsk C: /f`
26. **`diskpart`**  
    Manage disks, partitions, and volumes.
    
    - Example: `diskpart`
27. **`format`**  
    Format a disk or drive.
    
    - Example: `format D: /fs:NTFS`
28. **`vol`**  
    Display the volume label and serial number.
    
    - Example: `vol C:`
29. **`xcopy`**  
    Copy files and directories, including subdirectories.
    
    - Example: `xcopy C:\Source D:\Destination /E`
30. **`robocopy`**  
    Robust file copy for mirroring directories.
    
    - Example: `robocopy C:\Source D:\Destination /MIR`

---

### **Advanced and Administrative Commands**

31. **`fc`**  
    Compare files.
    
    - Example: `fc file1.txt file2.txt`
32. **`schtasks`**  
    Schedule a task to run at a specific time.
    
    - Example: `schtasks /create /tn MyTask /tr "notepad.exe" /sc once /st 12:00`
33. **`sfc`**  
    Scan and repair system files.
    
    - Example: `sfc /scannow`
34. **`shutdown`**  
    Shut down or restart the computer.
    
    - Example: `shutdown /r /t 0`
35. **`wmic`**  
    Run Windows Management Instrumentation (WMI) queries.
    
    - Example: `wmic process list brief`

---

### **Other Useful Commands**

36. **`powershell`**  
    Open PowerShell from the Command Prompt.
    
    - Example: `powershell`
37. **`set`**  
    Display or set environment variables.
    
    - Example: `set PATH`
38. **`pause`**  
    Pause execution in a script until a key is pressed.
    
    - Example: `pause`
39. **`title`**  
    Set the title of the Command Prompt window.
    
    - Example: `title My Custom CMD`
40. **`color`**  
    Change the text and background color of the Command Prompt.
    
    - Example: `color 0A`

## Common Variables

Here’s a list of common environment variables in Windows (used in Command Prompt) and their purposes:

---

### **System Variables**

1. **`%SYSTEMROOT%`**  
    Path to the Windows installation directory (e.g., `C:\Windows`).
    
    - Example: `cd %SYSTEMROOT%`
2. **`%WINDIR%`**  
    Another way to refer to the Windows installation directory.
    
    - Example: `cd %WINDIR%`
3. **`%COMSPEC%`**  
    Path to the command processor executable (`cmd.exe`).
    
    - Example: `%COMSPEC% /k`
4. **`%PATH%`**  
    A semicolon-separated list of directories where executable files are searched.
    
    - Example: `echo %PATH%`
5. **`%TEMP%` or `%TMP%`**  
    Path to the temporary files directory.
    
    - Example: `cd %TEMP%`
6. **`%PROGRAMFILES%`**  
    Path to the default "Program Files" directory.
    
    - Example: `cd %PROGRAMFILES%`
7. **`%PROGRAMFILES(X86)%`**  
    Path to the 32-bit "Program Files" directory on 64-bit systems.
    
    - Example: `cd %PROGRAMFILES(X86)%`
8. **`%APPDATA%`**  
    Path to the roaming application data directory for the current user.
    
    - Example: `cd %APPDATA%`
9. **`%LOCALAPPDATA%`**  
    Path to the local application data directory for the current user.
    
    - Example: `cd %LOCALAPPDATA%`
10. **`%HOMEPATH%`**  
    Relative path to the user’s home directory (from the root drive).
    
    - Example: `cd %HOMEPATH%`
11. **`%USERPROFILE%`**  
    Full path to the current user’s profile directory.
    
    - Example: `cd %USERPROFILE%`
12. **`%ALLUSERSPROFILE%`**  
    Path to the application data for all users.
    
    - Example: `cd %ALLUSERSPROFILE%`
13. **`%SYSTEMDRIVE%`**  
    The drive where Windows is installed (e.g., `C:`).
    
    - Example: `cd %SYSTEMDRIVE%`
14. **`%COMMONPROGRAMFILES%`**  
    Path to shared program files for 64-bit programs.
    
    - Example: `cd %COMMONPROGRAMFILES%`
15. **`%COMMONPROGRAMFILES(X86)%`**  
    Path to shared program files for 32-bit programs on 64-bit systems.
    
    - Example: `cd %COMMONPROGRAMFILES(X86)%`

---

### **User-Specific Variables**

16. **`%USERNAME%`**  
    Current user’s login name.
    
    - Example: `echo %USERNAME%`
17. **`%USERDOMAIN%`**  
    The domain of the current user.
    
    - Example: `echo %USERDOMAIN%`
18. **`%LOGONSERVER%`**  
    The domain controller that authenticated the user.
    
    - Example: `echo %LOGONSERVER%`
19. **`%COMPUTERNAME%`**  
    Name of the computer.
    
    - Example: `echo %COMPUTERNAME%`
20. **`%NUMBER_OF_PROCESSORS%`**  
    Number of logical processors.
    
    - Example: `echo %NUMBER_OF_PROCESSORS%`
21. **`%PROCESSOR_IDENTIFIER%`**  
    Description of the processor.
    
    - Example: `echo %PROCESSOR_IDENTIFIER%`
22. **`%PROCESSOR_ARCHITECTURE%`**  
    Processor architecture (`x86`, `AMD64`, etc.).
    
    - Example: `echo %PROCESSOR_ARCHITECTURE%`
23. **`%PROCESSOR_LEVEL%`**  
    Processor model number.
    
    - Example: `echo %PROCESSOR_LEVEL%`

---

### **Command Prompt-Specific Variables**

24. **`%CD%`**  
    Displays the current working directory.
    
    - Example: `echo %CD%`
25. **`%ERRORLEVEL%`**  
    Returns the exit code of the last executed command.
    
    - Example: `echo %ERRORLEVEL%`
26. **`%RANDOM%`**  
    Generates a random number between 0 and 32767.
    
    - Example: `echo %RANDOM%`
27. **`%DATE%`**  
    Current date.
    
    - Example: `echo %DATE%`
28. **`%TIME%`**  
    Current time.
    
    - Example: `echo %TIME%`

---

### **Network-Related Variables**

29. **`%USERDNSDOMAIN%`**  
    Fully qualified domain name of the current user.
    
    - Example: `echo %USERDNSDOMAIN%`
30. **`%PUBLIC%`**  
    Path to the public user profile directory.
    
    - Example: `cd %PUBLIC%`

---

### **Custom Environment Variables**

You can define your own variables for use in scripts or sessions using the `set` command.

- Example:
    
    ```cmd
    set MYVAR=HelloWorld
    echo %MYVAR%
    ```
    

---

These variables are widely used in batch scripts, system configuration, and troubleshooting in Command Prompt. Let me know if you'd like detailed examples or help using any of these variables!

## Services

### **Common Commands to Manage Services in Windows**

#### **1. View a List of Services**

- **Command**: `sc query`
    - Displays a list of all services and their statuses (running, stopped, etc.).
    - Example:
        
        ```cmd
        sc query
        ```
        

#### **2. Check the Status of a Specific Service**

- **Command**: `sc query <ServiceName>`
    - Displays detailed information about a specific service. Replace `<ServiceName>` with the actual service name.
    - Example:
        
        ```cmd
        sc query wuauserv
        ```
        
        _(This checks the Windows Update service.)_

#### **3. Start a Service**

- **Command**: `net start <ServiceName>`
    - Starts a specific service.
    - Example:
        
        ```cmd
        net start wuauserv
        ```
        

#### **4. Stop a Service**

- **Command**: `net stop <ServiceName>`
    - Stops a specific service.
    - Example:
        
        ```cmd
        net stop wuauserv
        ```
        

#### **5. Enable or Disable a Service**

- Use the `sc` command to change the startup type of a service.
    - **Enable (Automatic)**:
        
        ```cmd
        sc config <ServiceName> start= auto
        ```
        
    - **Disable**:
        
        ```cmd
        sc config <ServiceName> start= disabled
        ```
        

#### **6. Open Services GUI**

- **Command**: `services.msc`
    - Opens the graphical Services management console where you can view, start, stop, enable, or disable services.
    - Example:
        
        ```cmd
        services.msc
        ```
        

#### **7. Delete a Service**

- **Command**: `sc delete <ServiceName>`
    - Permanently removes a service from the system.
    - Example:
        
        ```cmd
        sc delete MyCustomService
        ```
        

#### **8. Create a New Service**

- **Command**: `sc create <ServiceName>`
    - Creates a new service. You need to specify the binary path and other parameters.
    - Example:
        
        ```cmd
        sc create MyService binPath= "C:\Path\to\myprogram.exe"
        ```
        

---

### **Common Service Names**

Here are some frequently encountered service names:

- **`wuauserv`**: Windows Update Service
- **`spooler`**: Print Spooler Service
- **`lanmanserver`**: Server Service
- **`dhcp`**: DHCP Client
- **`bits`**: Background Intelligent Transfer Service
- **`eventlog`**: Windows Event Log

---

Let me know if you need more detailed explanations or examples!****