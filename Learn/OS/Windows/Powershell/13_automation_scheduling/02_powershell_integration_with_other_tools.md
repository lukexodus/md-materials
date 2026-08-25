## PowerShell Integration with Other Tools


### COM Objects and .NET Integration

PowerShell's integration capabilities with Component Object Model (COM) and .NET Framework provide extensive access to Windows applications and system functionality.

#### COM Object Interaction

COM objects enable PowerShell to interact with applications like Microsoft Office, Internet Explorer, and various Windows system components.

**Example:**

```powershell
# Excel automation
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $true
$workbook = $excel.Workbooks.Add()
$worksheet = $workbook.Worksheets.Item(1)
$worksheet.Cells.Item(1,1) = "Data"
$worksheet.Cells.Item(1,2) = "Value"
$worksheet.Cells.Item(2,1) = "Sales"
$worksheet.Cells.Item(2,2) = 15000

# Save and close
$workbook.SaveAs("C:\Reports\SalesData.xlsx")
$workbook.Close()
$excel.Quit()

# Release COM objects
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($worksheet) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
```

#### Word Document Automation

COM integration allows automated document creation and modification in Microsoft Word applications.

**Example:**

```powershell
# Create Word document
$word = New-Object -ComObject Word.Application
$word.Visible = $true
$document = $word.Documents.Add()
$selection = $word.Selection

# Add content
$selection.Font.Size = 14
$selection.Font.Bold = $true
$selection.TypeText("Automated Report")
$selection.TypeParagraph()
$selection.Font.Bold = $false
$selection.Font.Size = 12
$selection.TypeText("Generated on $(Get-Date)")

# Insert table
$range = $selection.Range
$table = $document.Tables.Add($range, 3, 2)
$table.Cell(1,1).Range.Text = "Item"
$table.Cell(1,2).Range.Text = "Quantity"
$table.Cell(2,1).Range.Text = "Laptops"
$table.Cell(2,2).Range.Text = "25"

# Save document
$document.SaveAs2("C:\Reports\AutomatedReport.docx")
$document.Close()
$word.Quit()
```

#### .NET Framework Integration

PowerShell provides direct access to .NET Framework classes and methods, enabling powerful programming capabilities.

**Example:**

```powershell
# File system operations using .NET
$fileInfo = New-Object System.IO.FileInfo("C:\Data\sample.txt")
Write-Verbose "File size: $($fileInfo.Length) bytes"
Write-Verbose "Created: $($fileInfo.CreationTime)"
Write-Verbose "Modified: $($fileInfo.LastWriteTime)"

# Regular expressions
$pattern = New-Object System.Text.RegularExpressions.Regex("\b\w+@\w+\.\w+\b")
$text = "Contact us at support@company.com or sales@company.com"
$matches = $pattern.Matches($text)
foreach ($match in $matches) {
    Write-Output "Found email: $($match.Value)"
}

# Web client for downloads
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile("https://example.com/data.json", "C:\Downloads\data.json")
$webClient.Dispose()
```

#### Advanced .NET Class Usage

Complex .NET operations can be performed directly within PowerShell scripts for specialized functionality.

**Example:**

```powershell
# XML processing with .NET
$xmlDoc = New-Object System.Xml.XmlDocument
$xmlDoc.Load("C:\Config\settings.xml")
$nodes = $xmlDoc.SelectNodes("//configuration/setting")
foreach ($node in $nodes) {
    Write-Output "Setting: $($node.GetAttribute('name')) = $($node.InnerText)"
}

# Cryptographic operations
$data = [System.Text.Encoding]::UTF8.GetBytes("Sensitive data")
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$hash = $sha256.ComputeHash($data)
$hashString = [System.Convert]::ToBase64String($hash)
Write-Debug "SHA256 Hash: $hashString"

# Directory operations
$directoryInfo = New-Object System.IO.DirectoryInfo("C:\Projects")
$subdirectories = $directoryInfo.GetDirectories()
$subdirectories | ForEach-Object {
    Write-Output "Directory: $($_.Name) - Files: $($_.GetFiles().Count)"
}
```

### REST API Consumption

PowerShell provides multiple methods for consuming RESTful web services, enabling integration with cloud services and web-based applications.

#### Basic REST API Calls

The `Invoke-RestMethod` and `Invoke-WebRequest` cmdlets provide foundational capabilities for API interaction.

**Example:**

```powershell
# GET request with JSON response
$apiUrl = "https://jsonplaceholder.typicode.com/posts"
$posts = Invoke-RestMethod -Uri $apiUrl -Method Get
$posts | Select-Object -First 5 | Format-Table id, title

# GET with parameters
$params = @{
    userId = 1
    _limit = 10
}
$userPosts = Invoke-RestMethod -Uri "$apiUrl" -Method Get -Body $params
Write-Verbose "Retrieved $($userPosts.Count) posts for user"

# POST request with JSON body
$newPost = @{
    title = "PowerShell Integration"
    body = "Demonstrating API integration"
    userId = 1
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $newPost -ContentType "application/json"
Write-Output "Created post with ID: $($response.id)"
```

#### Authentication and Headers

REST API calls often require authentication tokens, API keys, or custom headers for access control.

**Example:**

```powershell
# API with authentication header
$headers = @{
    'Authorization' = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
    'Content-Type' = 'application/json'
    'User-Agent' = 'PowerShell-Script/1.0'
}

$apiData = Invoke-RestMethod -Uri "https://api.example.com/data" -Headers $headers -Method Get

# API key authentication
$apiKey = "your-api-key-here"
$githubHeaders = @{
    'Authorization' = "token $apiKey"
    'Accept' = 'application/vnd.github.v3+json'
}

$repos = Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers $githubHeaders
$repos | Select-Object name, private, updated_at | Format-Table

# Basic authentication
$credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("username:password"))
$basicAuthHeaders = @{
    'Authorization' = "Basic $credentials"
}
```

#### Error Handling and Response Processing

Robust API integration requires proper error handling and response validation.

**Example:**

```powershell
function Invoke-ApiCall {
    param(
        [string]$Uri,
        [string]$Method = "Get",
        [hashtable]$Headers = @{},
        [object]$Body = $null
    )
    
    try {
        $params = @{
            Uri = $Uri
            Method = $Method
            Headers = $Headers
            ErrorAction = 'Stop'
        }
        
        if ($Body) {
            $params.Body = $Body | ConvertTo-Json
            $params.ContentType = 'application/json'
        }
        
        $response = Invoke-RestMethod @params
        Write-Verbose "API call successful: $Method $Uri"
        return $response
    }
    catch [Microsoft.PowerShell.Commands.HttpResponseException] {
        $statusCode = $_.Exception.Response.StatusCode
        $statusDescription = $_.Exception.Response.ReasonPhrase
        Write-Warning "API call failed: $statusCode - $statusDescription"
        
        if ($_.Exception.Response.Content) {
            $errorContent = $_.Exception.Response.Content | ConvertFrom-Json
            Write-Debug "Error details: $($errorContent | ConvertTo-Json)"
        }
        
        throw
    }
    catch {
        Write-Error "Unexpected error during API call: $_"
        throw
    }
}
```

#### Pagination and Bulk Operations

Many APIs implement pagination for large datasets, requiring iterative processing to retrieve complete data sets.

**Example:**

```powershell
function Get-AllApiData {
    param(
        [string]$BaseUri,
        [hashtable]$Headers,
        [int]$PageSize = 100
    )
    
    $allData = @()
    $page = 1
    
    do {
        $uri = "$BaseUri" + "?page=$page&per_page=$PageSize"
        Write-Verbose "Fetching page $page from $uri"
        
        $response = Invoke-RestMethod -Uri $uri -Headers $Headers
        $allData += $response.data  # [Inference] Assuming response has 'data' property
        
        $page++
        Start-Sleep -Milliseconds 200  # Rate limiting
        
    } while ($response.data.Count -eq $PageSize)
    
    Write-Output "Retrieved $($allData.Count) total records"
    return $allData
}
```

### Database Connectivity

PowerShell supports various database connection methods, enabling data retrieval, manipulation, and reporting from multiple database platforms.

#### SQL Server Connectivity

SQL Server databases can be accessed through multiple PowerShell approaches, including SqlServer module and direct .NET classes.

**Example:**

```powershell
# Using SqlServer module (if available)
# Import-Module SqlServer

# Direct connection using .NET classes
$connectionString = "Server=localhost;Database=SampleDB;Integrated Security=true;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)

try {
    $connection.Open()
    Write-Verbose "Connected to database successfully"
    
    # Execute query
    $query = "SELECT TOP 10 CustomerID, CompanyName, Country FROM Customers"
    $command = New-Object System.Data.SqlClient.SqlCommand($query, $connection)
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
    $dataset = New-Object System.Data.DataSet
    
    $adapter.Fill($dataset) | Out-Null
    $results = $dataset.Tables[0]
    
    $results | Format-Table -AutoSize
}
catch {
    Write-Error "Database operation failed: $_"
}
finally {
    if ($connection.State -eq 'Open') {
        $connection.Close()
        Write-Debug "Database connection closed"
    }
}
```

#### Parameterized Queries and Data Manipulation

Safe database operations require parameterized queries to prevent SQL injection and ensure data integrity.

**Example:**

```powershell
function Invoke-DatabaseQuery {
    param(
        [string]$ConnectionString,
        [string]$Query,
        [hashtable]$Parameters = @{}
    )
    
    $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
    
    try {
        $connection.Open()
        $command = New-Object System.Data.SqlClient.SqlCommand($Query, $connection)
        
        # Add parameters
        foreach ($param in $Parameters.GetEnumerator()) {
            $command.Parameters.AddWithValue("@$($param.Key)", $param.Value) | Out-Null
            Write-Debug "Added parameter: @$($param.Key) = $($param.Value)"
        }
        
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
        $dataset = New-Object System.Data.DataSet
        $adapter.Fill($dataset) | Out-Null
        
        return $dataset.Tables[0]
    }
    finally {
        $connection.Close()
    }
}

# Usage example
$params = @{
    Country = 'USA'
    MinOrderValue = 1000
}
$query = "SELECT CustomerID, CompanyName, Country FROM Customers WHERE Country = @Country AND TotalOrders > @MinOrderValue"
$results = Invoke-DatabaseQuery -ConnectionString $connectionString -Query $query -Parameters $params
```

#### Database Backup and Maintenance

PowerShell can automate database backup operations and maintenance tasks through SQL commands and server management objects.

**Example:**

```powershell
function Backup-Database {
    param(
        [string]$ServerName,
        [string]$DatabaseName,
        [string]$BackupPath
    )
    
    $connectionString = "Server=$ServerName;Database=master;Integrated Security=true;"
    $backupFile = Join-Path $BackupPath "$DatabaseName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').bak"
    
    $backupQuery = @"
BACKUP DATABASE [$DatabaseName] 
TO DISK = '$backupFile'
WITH FORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, STATS = 10
"@
    
    try {
        Invoke-DatabaseQuery -ConnectionString $connectionString -Query $backupQuery
        Write-Output "Database backup completed: $backupFile"
        
        # Verify backup
        $verifyQuery = "RESTORE VERIFYONLY FROM DISK = '$backupFile'"
        Invoke-DatabaseQuery -ConnectionString $connectionString -Query $verifyQuery
        Write-Verbose "Backup verification successful"
        
        return $backupFile
    }
    catch {
        Write-Error "Backup operation failed: $_"
        throw
    }
}
```

#### Alternative Database Platforms

PowerShell can connect to various database platforms using appropriate connection strings and drivers.

**Example:**

```powershell
# MySQL connection [Unverified - requires MySQL .NET connector]
$mysqlConnectionString = "Server=localhost;Database=testdb;Uid=username;Pwd=password;"
# $mysqlConnection = New-Object MySql.Data.MySqlClient.MySqlConnection($mysqlConnectionString)

# Oracle connection [Unverified - requires Oracle client]
$oracleConnectionString = "Data Source=localhost:1521/XE;User Id=username;Password=password;"
# $oracleConnection = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($oracleConnectionString)

# SQLite connection
$sqliteConnectionString = "Data Source=C:\Database\sample.db;Version=3;"
$sqliteConnection = New-Object System.Data.SQLite.SQLiteConnection($sqliteConnectionString)

# ODBC connection
$odbcConnectionString = "Driver={Microsoft Access Driver (*.mdb, *.accdb)};Dbq=C:\Database\sample.accdb;"
$odbcConnection = New-Object System.Data.Odbc.OdbcConnection($odbcConnectionString)
```

### Email Automation

PowerShell provides comprehensive email capabilities through the `Send-MailMessage` cmdlet and .NET mail classes, enabling automated notifications and reporting.

#### Basic Email Sending

Simple email operations can be performed using the built-in `Send-MailMessage` cmdlet with SMTP server configuration.

**Example:**

```powershell
# Basic email with SMTP server
$mailParams = @{
    To = "recipient@company.com"
    From = "automation@company.com"
    Subject = "Daily Report - $(Get-Date -Format 'yyyy-MM-dd')"
    Body = "Please find the daily system report attached."
    SmtpServer = "mail.company.com"
    Port = 587
    UseSsl = $true
}

# Add credentials if required
$credential = Get-Credential -Message "Enter SMTP credentials"
$mailParams.Credential = $credential

Send-MailMessage @mailParams
Write-Verbose "Email sent successfully"
```

#### HTML Email with Attachments

Rich email content can be created using HTML formatting and multiple file attachments.

**Example:**

```powershell
function Send-ReportEmail {
    param(
        [string[]]$Recipients,
        [string]$Subject,
        [string]$ReportData,
        [string[]]$AttachmentPaths = @()
    )
    
    $htmlBody = @"
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #4472C4; color: white; padding: 10px; text-align: center; }
        .content { padding: 15px; }
        .footer { font-size: 12px; color: #666; margin-top: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h2>Automated System Report</h2>
    </div>
    <div class="content">
        <p>Dear Administrator,</p>
        <p>Please find the system report details below:</p>
        $ReportData
        <div class="footer">
            <p>This is an automated message generated on $(Get-Date).</p>
            <p>Please do not reply to this email.</p>
        </div>
    </div>
</body>
</html>
"@
    
    $mailParams = @{
        To = $Recipients
        From = "system@company.com"
        Subject = $Subject
        Body = $htmlBody
        BodyAsHtml = $true
        SmtpServer = "smtp.company.com"
        Port = 587
        UseSsl = $true
    }
    
    if ($AttachmentPaths.Count -gt 0) {
        $mailParams.Attachments = $AttachmentPaths
        Write-Debug "Added $($AttachmentPaths.Count) attachments"
    }
    
    try {
        Send-MailMessage @mailParams
        Write-Output "Report email sent to $($Recipients -join ', ')"
    }
    catch {
        Write-Error "Failed to send email: $_"
        throw
    }
}
```

#### Advanced Email Operations with .NET Classes

Complex email scenarios require direct use of .NET mail classes for enhanced functionality and control.

**Example:**

```powershell
function Send-AdvancedEmail {
    param(
        [string[]]$ToAddresses,
        [string[]]$CcAddresses = @(),
        [string[]]$BccAddresses = @(),
        [string]$FromAddress,
        [string]$Subject,
        [string]$Body,
        [bool]$IsHtml = $false,
        [string[]]$AttachmentPaths = @(),
        [string]$SmtpServer,
        [int]$Port = 587,
        [bool]$EnableSsl = $true,
        [pscredential]$Credential
    )
    
    $mailMessage = New-Object System.Net.Mail.MailMessage
    $smtpClient = New-Object System.Net.Mail.SmtpClient($SmtpServer, $Port)
    
    try {
        # Configure message
        $mailMessage.From = New-Object System.Net.Mail.MailAddress($FromAddress)
        $ToAddresses | ForEach-Object { $mailMessage.To.Add($_) }
        $CcAddresses | ForEach-Object { $mailMessage.CC.Add($_) }
        $BccAddresses | ForEach-Object { $mailMessage.Bcc.Add($_) }
        
        $mailMessage.Subject = $Subject
        $mailMessage.Body = $Body
        $mailMessage.IsBodyHtml = $IsHtml
        
        # Add attachments
        foreach ($attachmentPath in $AttachmentPaths) {
            if (Test-Path $attachmentPath) {
                $attachment = New-Object System.Net.Mail.Attachment($attachmentPath)
                $mailMessage.Attachments.Add($attachment)
                Write-Debug "Added attachment: $attachmentPath"
            }
            else {
                Write-Warning "Attachment not found: $attachmentPath"
            }
        }
        
        # Configure SMTP client
        $smtpClient.EnableSsl = $EnableSsl
        if ($Credential) {
            $smtpClient.Credentials = $Credential.GetNetworkCredential()
        }
        
        # Send email
        $smtpClient.Send($mailMessage)
        Write-Output "Advanced email sent successfully"
    }
    catch {
        Write-Error "Failed to send advanced email: $_"
        throw
    }
    finally {
        # Cleanup
        if ($mailMessage.Attachments) {
            $mailMessage.Attachments | ForEach-Object { $_.Dispose() }
        }
        $mailMessage.Dispose()
        $smtpClient.Dispose()
    }
}
```

#### Email Template System

Automated email systems benefit from template-based approaches for consistent formatting and easy maintenance.

**Example:**

```powershell
function New-EmailFromTemplate {
    param(
        [string]$TemplatePath,
        [hashtable]$Variables,
        [string[]]$Recipients,
        [string]$Subject
    )
    
    if (-not (Test-Path $TemplatePath)) {
        throw "Email template not found: $TemplatePath"
    }
    
    $template = Get-Content $TemplatePath -Raw
    
    # Replace variables in template
    foreach ($variable in $Variables.GetEnumerator()) {
        $placeholder = "{{$($variable.Key)}}"
        $template = $template -replace [regex]::Escape($placeholder), $variable.Value
        Write-Debug "Replaced $placeholder with $($variable.Value)"
    }
    
    # Send templated email
    $mailParams = @{
        To = $Recipients
        From = "templates@company.com"
        Subject = $Subject
        Body = $template
        BodyAsHtml = $true
        SmtpServer = "smtp.company.com"
    }
    
    Send-MailMessage @mailParams
    Write-Verbose "Template-based email sent to $($Recipients.Count) recipients"
}

# Usage with template file
$templateVars = @{
    UserName = "John Doe"
    ReportDate = Get-Date -Format "MMMM dd, yyyy"
    SystemStatus = "All systems operational"
    TotalErrors = 0
}

New-EmailFromTemplate -TemplatePath "C:\Templates\SystemReport.html" -Variables $templateVars -Recipients @("admin@company.com") -Subject "System Status Report"
```

**Key points:**

- COM object references should be properly released to prevent memory leaks
- .NET integration provides access to extensive framework capabilities beyond PowerShell cmdlets
- REST API calls should include proper error handling and rate limiting considerations
- Database connections require appropriate security measures and connection string protection
- Email automation should implement proper SMTP authentication and encryption
- [Unverified] Some database connectors may require additional driver installations
- Template-based approaches improve maintainability of automated communication systems

**Conclusion:** PowerShell's integration capabilities enable comprehensive automation solutions that connect diverse technologies, from legacy COM applications to modern REST APIs, providing unified management and reporting across heterogeneous environments.

---

