## String Manipulation


### String Methods and Operators

PowerShell provides extensive string manipulation capabilities through .NET string methods and PowerShell-specific operators. Strings in PowerShell are immutable .NET String objects, meaning operations create new string instances rather than modifying existing ones.

#### Core String Methods

**Case manipulation methods:**

```powershell
$text = "Hello World"
$text.ToUpper()          # "HELLO WORLD"
$text.ToLower()          # "hello world"
$text.ToTitleCase()      # Not available - use [System.Globalization.TextInfo]
```

**Substring operations:**

```powershell
$text = "PowerShell Scripting"
$text.Substring(0, 5)    # "Power"
$text.Substring(11)      # "Scripting"
$text.Remove(5, 5)       # "PowerScripting"
$text.Insert(5, "ful ")  # "Powerful Shell Scripting"
```

**Search and replace methods:**

```powershell
$text = "PowerShell is powerful"
$text.Contains("Shell")           # True
$text.StartsWith("Power")         # True
$text.EndsWith("powerful")        # True
$text.IndexOf("Shell")            # 5
$text.LastIndexOf("power")        # 16 (case-sensitive)
$text.Replace("powerful", "awesome")  # "PowerShell is awesome"
```

**String trimming and padding:**

```powershell
$text = "  PowerShell  "
$text.Trim()                      # "PowerShell"
$text.TrimStart()                 # "PowerShell  "
$text.TrimEnd()                   # "  PowerShell"
$text.PadLeft(15)                 # "   PowerShell  "
$text.PadRight(15, '*')           # "  PowerShell***"
```

**String splitting and joining:**

```powershell
$text = "apple,banana,orange"
$fruits = $text.Split(',')        # ["apple", "banana", "orange"]
$text.Split(',', 2)               # ["apple", "banana,orange"]

# Join arrays back to strings
$fruits -join ' | '               # "apple | banana | orange"
[string]::Join(' - ', $fruits)    # "apple - banana - orange"
```

#### PowerShell String Operators

**Comparison operators** (case-insensitive by default):

```powershell
"Hello" -eq "hello"               # True
"Hello" -ceq "hello"              # False (case-sensitive)
"Hello" -ne "world"               # True
"PowerShell" -like "*Shell"       # True
"PowerShell" -notlike "Python*"   # True
"test123" -match '\d+'            # True (regex match)
"PowerShell" -in @("PowerShell", "Python", "Bash")  # True
```

**String replacement operators:**

```powershell
"Hello World" -replace "World", "PowerShell"     # "Hello PowerShell"
"test123test" -replace "test", "demo"             # "demo123demo"
"PowerShell" -creplace "POWER", "Super"          # "PowerShell" (case-sensitive, no match)
"PowerShell" -replace "POWER", "Super"           # "SuperShell" (case-insensitive)
```

**Split operator:**

```powershell
"apple,banana,orange" -split ','                 # ["apple", "banana", "orange"]
"one two  three   four" -split '\s+'             # ["one", "two", "three", "four"] (regex)
"a1b2c3d" -split '\d'                            # ["a", "b", "c", "d"]
"apple,banana;orange:grape" -split '[,;:]'       # ["apple", "banana", "orange", "grape"]
```

**Key points:**

- String methods create new string instances (immutability)
- PowerShell operators provide case-insensitive defaults with case-sensitive variants
- Split operations support both simple delimiters and regular expressions
- .NET string methods offer comprehensive manipulation capabilities

### Select-String for Text Searching

`Select-String` provides powerful text searching capabilities across strings, files, and command output, functioning as PowerShell's equivalent to grep with enhanced object-based output.

#### Basic Text Searching

**Simple pattern matching:**

```powershell
"PowerShell is awesome" | Select-String "Shell"
Get-Content file.txt | Select-String "error"
Get-Process | Out-String | Select-String "notepad"
```

**Case-sensitive searching:**

```powershell
"PowerShell" | Select-String "SHELL" -CaseSensitive    # No match
"PowerShell" | Select-String "Shell" -CaseSensitive    # Match
```

**Multiple pattern matching:**

```powershell
Get-Content log.txt | Select-String "error", "warning", "critical"
"test line" | Select-String @("test", "demo", "sample")
```

#### Regular Expression Patterns

**Regex pattern matching:**

```powershell
"Phone: 555-1234" | Select-String '\d{3}-\d{4}'       # Match phone pattern
Get-Content file.txt | Select-String '^Error.*$'      # Lines starting with "Error"
"email@domain.com" | Select-String '\w+@\w+\.\w+'     # Email pattern
```

**Regex options:**

```powershell
$text = @"
Line 1: Error occurred
Line 2: Warning message
Line 3: Info statement
"@

$text | Select-String "line \d+" -AllMatches           # Find all line numbers
$text | Select-String "(?i)ERROR"                     # Case-insensitive regex
```

#### File-Based Searching

**Searching single files:**

```powershell
Select-String -Path "C:\logs\application.log" -Pattern "error"
Select-String -Path "*.txt" -Pattern "PowerShell"
Select-String -Path "config.xml" -Pattern '<setting.*>' -AllMatches
```

**Searching multiple files:**

```powershell
Select-String -Path "C:\logs\*.log" -Pattern "exception"
Select-String -Path "C:\scripts\*.ps1" -Pattern "function\s+\w+"
Get-ChildItem -Recurse -Filter "*.log" | Select-String "error"
```

**Context lines:**

```powershell
Select-String -Path "log.txt" -Pattern "error" -Context 2        # 2 lines before and after
Select-String -Path "log.txt" -Pattern "error" -Context 1,3      # 1 before, 3 after
```

#### Working with Match Objects

**Match object properties:**

```powershell
$matches = "PowerShell version 7.2.1" | Select-String '\d+\.\d+\.\d+'
$matches.Line           # Full matched line
$matches.Pattern        # Search pattern used
$matches.LineNumber     # Line number (for file searches)
$matches.Filename       # Source filename
$matches.Matches        # Regex match objects
```

**Accessing match details:**

```powershell
$result = "Server: web01, IP: 192.168.1.100" | Select-String '(\w+): ([\w.]+)'
$result.Matches[0].Groups[1].Value    # "Server"
$result.Matches[0].Groups[2].Value    # "web01"
$result.Matches[1].Groups[1].Value    # "IP"
$result.Matches[1].Groups[2].Value    # "192.168.1.100"
```

**Example** of log file analysis:

```powershell
# Find error patterns with context and extract timestamps
Select-String -Path "C:\logs\*.log" -Pattern "ERROR.*Exception" -Context 1 |
    ForEach-Object {
        [PSCustomObject]@{
            File = $_.Filename
            Line = $_.LineNumber
            Timestamp = ($_.Line | Select-String '\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}').Matches.Value
            Error = $_.Line
            Context = $_.Context.PostContext -join '; '
        }
    }
```

**Key points:**

- Select-String returns rich match objects with detailed information
- Regular expressions enable sophisticated pattern matching
- Context parameters provide surrounding line information
- File searching supports wildcards and pipeline input

### String Formatting and Interpolation

PowerShell offers multiple string formatting approaches, from simple interpolation to complex formatting operations using .NET formatting capabilities.

#### String Interpolation

**Double-quoted string expansion:**

```powershell
$name = "John"
$age = 30
"Hello, my name is $name and I am $age years old"
"Process count: $(Get-Process | Measure-Object | Select-Object -ExpandProperty Count)"
```

**Subexpression evaluation:**

```powershell
$services = Get-Service | Where-Object {$_.Status -eq "Running"}
"There are $($services.Count) running services"
"Current time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
"Free memory: $([math]::Round((Get-WmiObject Win32_OperatingSystem).FreePhysicalMemory/1MB, 2)) MB"
```

**Escape sequences in double quotes:**

```powershell
"Line 1`nLine 2`nLine 3"              # Newlines
"Column1`tColumn2`tColumn3"            # Tabs
"Quote: `"PowerShell`" is great"       # Escaped quotes
"Backslash: C:`\Windows`\System32"     # Escaped backslashes
```

#### Format Operator (-f)

**Basic formatting:**

```powershell
"Hello {0}, you are {1} years old" -f "John", 30
"Process: {0}, PID: {1}, CPU: {2}" -f "notepad", 1234, 15.6
```

**Positional arguments:**

```powershell
"Today is {0:yyyy-MM-dd} and the time is {0:HH:mm:ss}" -f (Get-Date)
"{2} {1} {0}" -f "third", "second", "first"    # "first second third"
```

**Number formatting:**

```powershell
"{0:N2}" -f 1234.5678        # "1,234.57" (2 decimal places)
"{0:C}" -f 1234.56           # "$1,234.56" (currency)
"{0:P}" -f 0.1234            # "12.34%" (percentage)
"{0:F4}" -f 3.14159          # "3.1416" (4 decimal places)
"{0:D5}" -f 42               # "00042" (5-digit integer)
```

**Custom number formats:**

```powershell
"{0:#,##0.00}" -f 1234567.89     # "1,234,567.89"
"{0:000.00}" -f 42.5             # "042.50"
"{0:+#;-#;0}" -f -15             # "-15" (positive/negative/zero format)
```

**DateTime formatting:**

```powershell
$date = Get-Date
"{0:yyyy-MM-dd}" -f $date           # "2024-07-21"
"{0:dddd, MMMM dd, yyyy}" -f $date   # "Sunday, July 21, 2024"
"{0:HH:mm:ss}" -f $date             # "14:30:45"
"{0:yyyy-MM-dd HH:mm:ss}" -f $date   # "2024-07-21 14:30:45"
```

#### String Builder for Performance

For extensive string concatenation operations, StringBuilder provides better performance than repeated string concatenation:

```powershell
$sb = [System.Text.StringBuilder]::new()
1..1000 | ForEach-Object {
    $sb.AppendLine("Line $_") | Out-Null
}
$result = $sb.ToString()
```

#### Here-Strings for Complex Content

**Here-string syntax:**

```powershell
$htmlContent = @"
<html>
<head>
    <title>PowerShell Report</title>
</head>
<body>
    <h1>System Information</h1>
    <p>Generated on: $(Get-Date)</p>
</body>
</html>
"@
```

**Example** of formatted report generation:

```powershell
$processes = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5

$report = @"
System Performance Report
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Top 5 CPU Consumers:
$($processes | ForEach-Object {"  {0,-20} CPU: {1,8:F2}" -f $_.ProcessName, $_.CPU} | Out-String)

Memory Usage: $([math]::Round((Get-WmiObject Win32_OperatingSystem).TotalPhysicalMemory / 1GB, 2)) GB Total
"@
```

**Key points:**

- Double-quoted strings support variable expansion and subexpressions
- Format operator provides precise control over output formatting
- StringBuilder improves performance for extensive string building
- Here-strings handle multi-line content with embedded formatting

### Working with Multi-line Strings

Multi-line string handling requires specific techniques to manage content that spans multiple lines, preserve formatting, and handle line ending variations across different platforms.

#### Here-String Syntax

**Expandable here-strings** (double quotes) support variable expansion:

```powershell
$serverName = "WEB01"
$multiLine = @"
Server: $serverName
Status: Online
Last Check: $(Get-Date)
Configuration:
  - CPU Cores: 8
  - Memory: 16GB
  - Disk Space: 500GB
"@
```

**Literal here-strings** (single quotes) preserve exact content:

```powershell
$configTemplate = @'
<?xml version="1.0"?>
<configuration>
    <appSettings>
        <add key="ServerName" value="{0}" />
        <add key="DatabaseConnection" value="{1}" />
    </appSettings>
</configuration>
'@
```

#### Line Ending Management

**Cross-platform line endings:**

```powershell
$text = "Line 1`nLine 2`nLine 3"        # Unix-style LF
$text = "Line 1`r`nLine 2`r`nLine 3"    # Windows-style CRLF

# Normalize line endings
$normalizedText = $text -replace '\r\n', "`n"     # Convert to LF
$windowsText = $text -replace '\n', "`r`n"        # Convert to CRLF
```

**Environment-specific line endings:**

```powershell
$newLine = [System.Environment]::NewLine
$content = "First Line$newLine" + "Second Line$newLine" + "Third Line"
```

#### Multi-line String Operations

**Line-by-line processing:**

```powershell
$multiLineText = @"
apple
banana  
orange
grape
"@

# Split into individual lines
$lines = $multiLineText -split "`n"
$lines | ForEach-Object { "Fruit: $($_.Trim())" }

# Process non-empty lines
$lines | Where-Object { $_.Trim() -ne "" } | Sort-Object
```

**Line counting and analysis:**

```powershell
$content = Get-Content "script.ps1" -Raw
$lineCount = ($content -split "`n").Count
$nonEmptyLines = ($content -split "`n" | Where-Object { $_.Trim() -ne "" }).Count
$commentLines = ($content -split "`n" | Where-Object { $_.Trim().StartsWith("#") }).Count

"Total lines: $lineCount"
"Non-empty lines: $nonEmptyLines"  
"Comment lines: $commentLines"
```

**Multi-line search and replace:**

```powershell
$source = @"
function Get-Data {
    param($Path)
    # Old implementation
    return Get-Content $Path
}
"@

# Replace multi-line patterns
$updated = $source -replace '(?ms)# Old implementation.*?return Get-Content \$Path', 
    '# New implementation
    $content = Get-Content $Path -Raw
    return $content'
```

#### Indentation and Formatting

**Removing common indentation:**

```powershell
$indentedText = @"
    First line with indent
    Second line with indent
    Third line with indent
"@

# Remove leading whitespace from each line
$cleaned = ($indentedText -split "`n" | ForEach-Object { $_.TrimStart() }) -join "`n"
```

**Adding consistent indentation:**

```powershell
$plainText = @"
function Test {
write-output "test"
}
"@

# Add 4-space indentation
$indented = ($plainText -split "`n" | ForEach-Object { "    $_" }) -join "`n"
```

#### Handling Special Characters in Multi-line Strings

**Escaping in expandable here-strings:**

```powershell
$script = @"
`$variable = "value"
Write-Output "`$variable contains: `$variable"
# Use backticks to escape `$ when you want literal `$ characters
"@
```

**Preserving quotes and special characters:**

```powershell
$jsonTemplate = @'
{
    "name": "{0}",
    "value": "{1}",
    "settings": {
        "enabled": true,
        "path": "C:\Program Files\App"
    }
}
'@

$json = $jsonTemplate -f "ConfigName", "ConfigValue"
```

**Example** of multi-line log processing:

```powershell
$logContent = @"
2024-07-21 10:30:15 INFO Application started
2024-07-21 10:30:16 DEBUG Loading configuration
2024-07-21 10:30:17 ERROR Database connection failed
    at DatabaseManager.Connect()
    at Application.Initialize()
2024-07-21 10:30:18 WARN Retrying connection
2024-07-21 10:30:20 INFO Connection restored
"@

# Extract error entries with stack traces
$lines = $logContent -split "`n"
$errorEntries = for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'ERROR') {
        $entry = $lines[$i]
        $stackTrace = @()
        
        # Collect subsequent indented lines as stack trace
        for ($j = $i + 1; $j -lt $lines.Count; $j++) {
            if ($lines[$j] -match '^\s+at\s') {
                $stackTrace += $lines[$j].Trim()
            } else {
                break
            }
        }
        
        [PSCustomObject]@{
            Timestamp = ($lines[$i] -split ' ')[0..1] -join ' '
            Message = ($lines[$i] -split ' ', 4)[3]
            StackTrace = $stackTrace
        }
    }
}
```

**Key points:**

- Here-strings handle complex multi-line content effectively
- Line ending normalization ensures cross-platform compatibility
- String splitting enables line-by-line processing
- Indentation management preserves code structure
- Special character handling varies between expandable and literal here-strings

---

