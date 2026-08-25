## Advanced Scripting Patterns


### Design Patterns in PowerShell

PowerShell supports several object-oriented and functional design patterns that enhance code maintainability and reusability. The language's pipeline-centric nature and .NET integration enable sophisticated architectural approaches.

The **Singleton Pattern** ensures only one instance of a class exists throughout the script's lifetime. PowerShell implements this through static variables or module-scoped variables:

```powershell
class DatabaseConnection {
    static [DatabaseConnection] $Instance
    hidden [string] $ConnectionString
    
    static [DatabaseConnection] GetInstance() {
        if ([DatabaseConnection]::Instance -eq $null) {
            [DatabaseConnection]::Instance = [DatabaseConnection]::new()
        }
        return [DatabaseConnection]::Instance
    }
    
    hidden DatabaseConnection() {
        $this.ConnectionString = "Server=localhost;Database=MyDB"
    }
}
```

The **Factory Pattern** creates objects without specifying exact classes, particularly useful for creating different types of output formatters or data processors:

```powershell
class LoggerFactory {
    static [object] CreateLogger([string] $Type) {
        switch ($Type) {
            'File' { return [FileLogger]::new() }
            'Event' { return [EventLogger]::new() }
            'Console' { return [ConsoleLogger]::new() }
            default { throw "Unknown logger type: $Type" }
        }
    }
}
```

The **Command Pattern** encapsulates requests as objects, enabling parameterization of clients with different requests, queuing operations, and supporting undo functionality:

```powershell
class Command {
    [void] Execute() { throw "Must override Execute method" }
    [void] Undo() { throw "Must override Undo method" }
}

class FileOperationCommand : Command {
    [string] $FilePath
    [string] $Operation
    [hashtable] $BackupData
    
    [void] Execute() {
        switch ($this.Operation) {
            'Delete' { 
                $this.BackupData = @{
                    Content = Get-Content $this.FilePath
                    Existed = $true
                }
                Remove-Item $this.FilePath
            }
            'Create' { New-Item $this.FilePath -ItemType File }
        }
    }
    
    [void] Undo() {
        if ($this.Operation -eq 'Delete' -and $this.BackupData.Existed) {
            $this.BackupData.Content | Set-Content $this.FilePath
        }
    }
}
```

The **Observer Pattern** defines one-to-many dependency between objects, implemented through PowerShell events and event subscribers:

```powershell
class EventPublisher {
    [System.Collections.ArrayList] $Subscribers = @()
    
    [void] Subscribe([scriptblock] $Handler) {
        $this.Subscribers.Add($Handler) | Out-Null
    }
    
    [void] Notify([object] $Data) {
        foreach ($subscriber in $this.Subscribers) {
            & $subscriber $Data
        }
    }
}
```

**Pipeline Patterns** leverage PowerShell's native pipeline architecture for data transformation chains. The Filter-Map-Reduce pattern processes collections efficiently:

```powershell
function Invoke-DataPipeline {
    param([array] $Data, [scriptblock] $Filter, [scriptblock] $Transform, [scriptblock] $Aggregate)
    
    $Data | 
        Where-Object $Filter | 
        ForEach-Object $Transform | 
        Measure-Object $Aggregate
}
```

### Configuration Management

Configuration management in PowerShell involves structured approaches to handle application settings, environment-specific parameters, and deployment configurations across different stages.

**Configuration Files** support multiple formats including JSON, XML, PSD1 (PowerShell Data), and YAML. PSD1 files provide native PowerShell syntax with validation capabilities:

```powershell
# config.psd1
@{
    DatabaseSettings = @{
        ConnectionString = "Server=prod-db;Database=MyApp"
        CommandTimeout = 30
        RetryCount = 3
    }
    
    LoggingSettings = @{
        Level = "Information"
        FilePath = "C:\Logs\MyApp.log"
        MaxFileSize = "10MB"
        RetentionDays = 30
    }
    
    FeatureFlags = @{
        EnableNewFeature = $true
        EnableDebugMode = $false
    }
}
```

**Environment-Specific Configurations** handle different deployment stages through hierarchical configuration loading:

```powershell
class ConfigurationManager {
    [hashtable] $Config
    [string] $Environment
    
    ConfigurationManager([string] $Environment) {
        $this.Environment = $Environment
        $this.LoadConfiguration()
    }
    
    [void] LoadConfiguration() {
        # Load base configuration
        $baseConfig = Import-PowerShellDataFile ".\config\base.psd1"
        
        # Load environment-specific overrides
        $envConfigPath = ".\config\$($this.Environment).psd1"
        if (Test-Path $envConfigPath) {
            $envConfig = Import-PowerShellDataFile $envConfigPath
            $this.Config = $this.MergeHashtables($baseConfig, $envConfig)
        } else {
            $this.Config = $baseConfig
        }
        
        # Apply environment variable overrides
        $this.ApplyEnvironmentVariables()
    }
    
    [hashtable] MergeHashtables([hashtable] $Base, [hashtable] $Override) {
        $result = $Base.Clone()
        foreach ($key in $Override.Keys) {
            if ($result.ContainsKey($key) -and $result[$key] -is [hashtable] -and $Override[$key] -is [hashtable]) {
                $result[$key] = $this.MergeHashtables($result[$key], $Override[$key])
            } else {
                $result[$key] = $Override[$key]
            }
        }
        return $result
    }
    
    [void] ApplyEnvironmentVariables() {
        # Override with environment variables using naming convention
        foreach ($envVar in [Environment]::GetEnvironmentVariables().GetEnumerator()) {
            if ($envVar.Key.StartsWith("MYAPP_")) {
                $configPath = $envVar.Key.Substring(6).Replace("_", ".")
                $this.SetNestedValue($configPath, $envVar.Value)
            }
        }
    }
}
```

**Configuration Validation** ensures settings meet requirements and constraints:

```powershell
class ConfigurationValidator {
    static [void] ValidateConfiguration([hashtable] $Config) {
        $requiredKeys = @('DatabaseSettings.ConnectionString', 'LoggingSettings.Level')
        
        foreach ($key in $requiredKeys) {
            if (-not (Test-ConfigurationPath -Config $Config -Path $key)) {
                throw "Required configuration key missing: $key"
            }
        }
        
        # Validate specific values
        if ($Config.LoggingSettings.Level -notin @('Debug', 'Information', 'Warning', 'Error')) {
            throw "Invalid logging level: $($Config.LoggingSettings.Level)"
        }
        
        if ($Config.DatabaseSettings.CommandTimeout -lt 1 -or $Config.DatabaseSettings.CommandTimeout -gt 300) {
            throw "CommandTimeout must be between 1 and 300 seconds"
        }
    }
}
```

**Secret Management** integrates with secure storage systems and credential providers:

```powershell
class SecretManager {
    [object] $VaultProvider
    
    SecretManager([string] $VaultType) {
        switch ($VaultType) {
            'AzureKeyVault' { $this.VaultProvider = [AzureKeyVaultProvider]::new() }
            'HashiCorpVault' { $this.VaultProvider = [HashiCorpVaultProvider]::new() }
            'WindowsCredentialStore' { $this.VaultProvider = [WindowsCredentialProvider]::new() }
        }
    }
    
    [string] GetSecret([string] $SecretName) {
        return $this.VaultProvider.RetrieveSecret($SecretName)
    }
    
    [hashtable] InjectSecrets([hashtable] $Config) {
        $result = $Config.Clone()
        $this.ProcessSecretsRecursively($result)
        return $result
    }
    
    hidden [void] ProcessSecretsRecursively([object] $Object) {
        if ($Object -is [hashtable]) {
            foreach ($key in $Object.Keys) {
                if ($Object[$key] -is [string] -and $Object[$key].StartsWith('{{secret:')) {
                    $secretName = $Object[$key] -replace '{{secret:(.+)}}', '$1'
                    $Object[$key] = $this.GetSecret($secretName)
                } elseif ($Object[$key] -is [hashtable]) {
                    $this.ProcessSecretsRecursively($Object[$key])
                }
            }
        }
    }
}
```

### Logging Frameworks

PowerShell logging frameworks provide structured, configurable, and performant logging capabilities for enterprise applications and automation scripts.

**PSFramework Logging** offers a comprehensive logging solution with multiple output targets and filtering capabilities:

```powershell
# Configure PSFramework logging
Set-PSFConfig -Module 'MyModule' -Name 'Logging.FileLoggerV2.FilePath' -Value 'C:\Logs\MyModule-%Date%.log'
Set-PSFConfig -Module 'MyModule' -Name 'Logging.FileLoggerV2.Enabled' -Value $true
Set-PSFConfig -Module 'MyModule' -Name 'Logging.FileLoggerV2.LogLevel' -Value 'Debug'

# Custom logging provider
Register-PSFLoggingProvider -Name 'DatabaseLogger' -RegistrationEvent {
    # Initialize database connection
} -BeginEvent {
    # Setup per-runspace resources
} -MessageEvent {
    param($Message)
    # Log to database
} -ErrorEvent {
    param($ErrorRecord, $Message)
    # Handle logging errors
}
```

**Custom Logging Framework** implementation with structured logging and performance optimization:

```powershell
enum LogLevel {
    Trace = 0
    Debug = 1
    Information = 2
    Warning = 3
    Error = 4
    Critical = 5
}

class LogEntry {
    [datetime] $Timestamp
    [LogLevel] $Level
    [string] $Message
    [string] $Category
    [hashtable] $Properties
    [string] $CallerName
    [int] $CallerLineNumber
    [System.Exception] $Exception
    
    LogEntry([LogLevel] $Level, [string] $Message, [string] $Category) {
        $this.Timestamp = [datetime]::UtcNow
        $this.Level = $Level
        $this.Message = $Message
        $this.Category = $Category
        $this.Properties = @{}
        
        # Capture caller information
        $caller = Get-PSCallStack | Select-Object -Skip 2 -First 1
        $this.CallerName = $caller.FunctionName
        $this.CallerLineNumber = $caller.ScriptLineNumber
    }
    
    [string] ToString() {
        $timestamp = $this.Timestamp.ToString('yyyy-MM-dd HH:mm:ss.fff')
        $level = $this.Level.ToString().ToUpper().PadRight(11)
        $caller = "$($this.CallerName):$($this.CallerLineNumber)"
        
        $message = "[$timestamp] [$level] [$($this.Category)] $($this.Message)"
        
        if ($this.Properties.Count -gt 0) {
            $props = ($this.Properties.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', '
            $message += " | Properties: {$props}"
        }
        
        if ($this.Exception) {
            $message += " | Exception: $($this.Exception.GetType().Name): $($this.Exception.Message)"
        }
        
        return $message
    }
}

class Logger {
    [LogLevel] $MinimumLevel
    [System.Collections.Generic.List[object]] $Providers
    [System.Collections.Concurrent.ConcurrentQueue[LogEntry]] $LogQueue
    [System.Threading.Timer] $FlushTimer
    [bool] $IsAsyncEnabled
    
    Logger() {
        $this.MinimumLevel = [LogLevel]::Information
        $this.Providers = [System.Collections.Generic.List[object]]::new()
        $this.LogQueue = [System.Collections.Concurrent.ConcurrentQueue[LogEntry]]::new()
        $this.IsAsyncEnabled = $true
        
        # Start background flush timer
        $this.StartAsyncFlushing()
    }
    
    [void] AddProvider([object] $Provider) {
        $this.Providers.Add($Provider)
    }
    
    [void] Log([LogLevel] $Level, [string] $Message, [string] $Category = 'General') {
        if ($Level -lt $this.MinimumLevel) { return }
        
        $entry = [LogEntry]::new($Level, $Message, $Category)
        
        if ($this.IsAsyncEnabled) {
            $this.LogQueue.Enqueue($entry)
        } else {
            $this.WriteToProviders($entry)
        }
    }
    
    [void] LogWithProperties([LogLevel] $Level, [string] $Message, [hashtable] $Properties, [string] $Category = 'General') {
        if ($Level -lt $this.MinimumLevel) { return }
        
        $entry = [LogEntry]::new($Level, $Message, $Category)
        $entry.Properties = $Properties
        
        if ($this.IsAsyncEnabled) {
            $this.LogQueue.Enqueue($entry)
        } else {
            $this.WriteToProviders($entry)
        }
    }
    
    [void] LogException([System.Exception] $Exception, [string] $Message = '', [string] $Category = 'Exception') {
        $entry = [LogEntry]::new([LogLevel]::Error, $Message, $Category)
        $entry.Exception = $Exception
        
        if ($this.IsAsyncEnabled) {
            $this.LogQueue.Enqueue($entry)
        } else {
            $this.WriteToProviders($entry)
        }
    }
    
    hidden [void] StartAsyncFlushing() {
        $flushAction = {
            while ($this.LogQueue.Count -gt 0) {
                $entry = $null
                if ($this.LogQueue.TryDequeue([ref] $entry)) {
                    $this.WriteToProviders($entry)
                }
            }
        }
        
        $this.FlushTimer = [System.Threading.Timer]::new(
            [System.Threading.TimerCallback] $flushAction,
            $null, 1000, 1000)
    }
    
    hidden [void] WriteToProviders([LogEntry] $Entry) {
        foreach ($provider in $this.Providers) {
            try {
                $provider.Write($Entry)
            } catch {
                # Handle provider errors without affecting other providers
                Write-Error "Logging provider error: $_"
            }
        }
    }
    
    [void] Flush() {
        while ($this.LogQueue.Count -gt 0) {
            $entry = $null
            if ($this.LogQueue.TryDequeue([ref] $entry)) {
                $this.WriteToProviders($entry)
            }
        }
    }
}
```

**Logging Providers** implement different output targets with specific formatting and filtering:

```powershell
class FileLoggingProvider {
    [string] $FilePath
    [LogLevel] $MinimumLevel
    [int] $MaxFileSizeMB
    [int] $RetentionDays
    [System.IO.StreamWriter] $Writer
    
    FileLoggingProvider([string] $FilePath, [LogLevel] $MinimumLevel = [LogLevel]::Information) {
        $this.FilePath = $FilePath
        $this.MinimumLevel = $MinimumLevel
        $this.MaxFileSizeMB = 10
        $this.RetentionDays = 30
        $this.InitializeWriter()
        $this.PerformMaintenance()
    }
    
    [void] Write([LogEntry] $Entry) {
        if ($Entry.Level -lt $this.MinimumLevel) { return }
        
        $this.CheckFileRotation()
        $this.Writer.WriteLine($Entry.ToString())
        $this.Writer.Flush()
    }
    
    hidden [void] InitializeWriter() {
        $directory = [System.IO.Path]::GetDirectoryName($this.FilePath)
        if (-not (Test-Path $directory)) {
            New-Item -Path $directory -ItemType Directory -Force | Out-Null
        }
        
        $this.Writer = [System.IO.StreamWriter]::new($this.FilePath, $true, [System.Text.Encoding]::UTF8)
    }
    
    hidden [void] CheckFileRotation() {
        $fileInfo = Get-Item $this.FilePath -ErrorAction SilentlyContinue
        if ($fileInfo -and $fileInfo.Length -gt ($this.MaxFileSizeMB * 1MB)) {
            $this.RotateFile()
        }
    }
    
    hidden [void] RotateFile() {
        $this.Writer.Close()
        $timestamp = [datetime]::Now.ToString('yyyyMMdd_HHmmss')
        $rotatedPath = $this.FilePath -replace '\.log$', "_$timestamp.log"
        Move-Item $this.FilePath $rotatedPath
        $this.InitializeWriter()
    }
}

class DatabaseLoggingProvider {
    [string] $ConnectionString
    [LogLevel] $MinimumLevel
    [System.Collections.Generic.Queue[LogEntry]] $BatchQueue
    [int] $BatchSize
    
    DatabaseLoggingProvider([string] $ConnectionString, [LogLevel] $MinimumLevel = [LogLevel]::Warning) {
        $this.ConnectionString = $ConnectionString
        $this.MinimumLevel = $MinimumLevel
        $this.BatchQueue = [System.Collections.Generic.Queue[LogEntry]]::new()
        $this.BatchSize = 100
    }
    
    [void] Write([LogEntry] $Entry) {
        if ($Entry.Level -lt $this.MinimumLevel) { return }
        
        $this.BatchQueue.Enqueue($Entry)
        
        if ($this.BatchQueue.Count -ge $this.BatchSize) {
            $this.FlushBatch()
        }
    }
    
    [void] FlushBatch() {
        if ($this.BatchQueue.Count -eq 0) { return }
        
        $entries = @()
        while ($this.BatchQueue.Count -gt 0) {
            $entries += $this.BatchQueue.Dequeue()
        }
        
        $this.WriteBatchToDatabase($entries)
    }
}
```

### Unit Testing with Pester

Pester 5.x provides advanced testing capabilities including parameterized tests, mocking, code coverage analysis, and continuous integration support for PowerShell modules and scripts.

**Test Structure and Organization** follows arrange-act-assert patterns with descriptive test names:

```powershell
Describe "UserManager" -Tag "Unit" {
    BeforeAll {
        # Import module under test
        Import-Module "$PSScriptRoot\..\src\UserManager.psm1" -Force
        
        # Setup test data
        $script:TestUsers = @(
            @{ Name = "John Doe"; Email = "john@example.com"; Department = "IT" }
            @{ Name = "Jane Smith"; Email = "jane@example.com"; Department = "HR" }
        )
    }
    
    Context "When creating new users" {
        It "Should create user with valid parameters" {
            # Arrange
            $userName = "test.user"
            $userEmail = "test.user@example.com"
            $department = "Engineering"
            
            # Act
            $result = New-User -Name $userName -Email $userEmail -Department $department
            
            # Assert
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $userName
            $result.Email | Should -Be $userEmail
            $result.Department | Should -Be $department
            $result.Id | Should -Match "^\d+$"
        }
        
        It "Should throw exception for invalid email format" {
            # Arrange
            $invalidEmail = "not-an-email"
            
            # Act & Assert
            { New-User -Name "Test" -Email $invalidEmail -Department "IT" } | 
                Should -Throw -ExpectedMessage "*Invalid email format*"
        }
        
        It "Should validate required parameters" -TestCases @(
            @{ ParameterName = "Name"; Value = $null }
            @{ ParameterName = "Email"; Value = $null }
            @{ ParameterName = "Department"; Value = $null }
        ) {
            param($ParameterName, $Value)
            
            $parameters = @{
                Name = "Test User"
                Email = "test@example.com"  
                Department = "IT"
            }
            $parameters[$ParameterName] = $Value
            
            { New-User @parameters } | Should -Throw
        }
    }
    
    Context "When retrieving users" {
        BeforeEach {
            # Setup mock data for each test
            Mock Get-DatabaseConnection { 
                return [PSCustomObject]@{ IsConnected = $true }
            }
            
            Mock Invoke-DatabaseQuery { 
                return $script:TestUsers
            } -ParameterFilter { $Query -like "*SELECT*" }
        }
        
        It "Should return all users when no filter specified" {
            # Act
            $result = Get-Users
            
            # Assert
            $result | Should -HaveCount 2
            $result[0].Name | Should -Be "John Doe"
            $result[1].Name | Should -Be "Jane Smith"
        }
        
        It "Should filter users by department" {
            # Arrange
            Mock Invoke-DatabaseQuery { 
                return $script:TestUsers | Where-Object { $_.Department -eq "IT" }
            } -ParameterFilter { $Query -like "*WHERE Department*" }
            
            # Act
            $result = Get-Users -Department "IT"
            
            # Assert
            $result | Should -HaveCount 1
            $result.Name | Should -Be "John Doe"
            $result.Department | Should -Be "IT"
        }
        
        It "Should call database with correct query" {
            # Act
            Get-Users -Department "HR"
            
            # Assert
            Should -Invoke Invoke-DatabaseQuery -Times 1 -ParameterFilter {
                $Query -like "*WHERE Department = 'HR'*"
            }
        }
    }
}
```

**Advanced Mocking Techniques** replace dependencies and external systems:

```powershell
Describe "EmailService Integration Tests" -Tag "Integration" {
    BeforeAll {
        Import-Module "$PSScriptRoot\..\src\EmailService.psm1" -Force
        
        # Create mock SMTP client
        $script:MockSmtpClient = [PSCustomObject]@{
            Host = ""
            Port = 0
            EnableSsl = $false
            Credentials = $null
            SendCallCount = 0
            LastMessage = $null
        }
        
        # Mock the SMTP client creation
        Mock New-Object -MockWith { $script:MockSmtpClient } -ParameterFilter {
            $TypeName -eq "System.Net.Mail.SmtpClient"
        }
        
        # Mock the Send method
        $script:MockSmtpClient | Add-Member -MemberType ScriptMethod -Name Send -Value {
            param($Message)
            $this.SendCallCount++
            $this.LastMessage = $Message
        }
    }
    
    Context "When sending emails" {
        It "Should configure SMTP client correctly" {
            # Arrange
            $emailSettings = @{
                SmtpServer = "smtp.example.com"
                Port = 587
                EnableSsl = $true
                Username = "test@example.com"
                Password = "password123"
            }
            
            # Act
            Initialize-EmailService @emailSettings
            
            # Assert
            $script:MockSmtpClient.Host | Should -Be "smtp.example.com"
            $script:MockSmtpClient.Port | Should -Be 587
            $script:MockSmtpClient.EnableSsl | Should -Be $true
        }
        
        It "Should send email with correct parameters" {
            # Arrange
            $emailParams = @{
                To = "recipient@example.com"
                Subject = "Test Email"
                Body = "This is a test email"
                From = "sender@example.com"
            }
            
            # Act
            Send-Email @emailParams
            
            # Assert
            $script:MockSmtpClient.SendCallCount | Should -Be 1
            $script:MockSmtpClient.LastMessage.To[0].Address | Should -Be "recipient@example.com"
            $script:MockSmtpClient.LastMessage.Subject | Should -Be "Test Email"
            $script:MockSmtpClient.LastMessage.Body | Should -Be "This is a test email"
        }
    }
}
```

**Parameterized Tests** enable data-driven testing scenarios:

```powershell
Describe "Data Validation Functions" -Tag "Unit" {
    Context "Email validation" {
        It "Should validate email format correctly" -TestCases @(
            @{ Email = "user@domain.com"; Expected = $true; Description = "valid standard email" }
            @{ Email = "user.name@domain.com"; Expected = $true; Description = "valid email with dot in name" }
            @{ Email = "user+tag@domain.com"; Expected = $true; Description = "valid email with plus sign" }
            @{ Email = "user@subdomain.domain.com"; Expected = $true; Description = "valid email with subdomain" }
            @{ Email = "invalid-email"; Expected = $false; Description = "invalid email without @ symbol" }
            @{ Email = "@domain.com"; Expected = $false; Description = "invalid email without username" }
            @{ Email = "user@"; Expected = $false; Description = "invalid email without domain" }
            @{ Email = ""; Expected = $false; Description = "empty string" }
            @{ Email = $null; Expected = $false; Description = "null value" }
        ) {
            param($Email, $Expected, $Description)
            
            # Act
            $result = Test-EmailFormat -Email $Email
            
            # Assert
            $result | Should -Be $Expected -Because $Description
        }
    }
    
    Context "Password strength validation" {
        It "Should evaluate password strength correctly" -TestCases @(
            @{ Password = "Password123!"; ExpectedStrength = "Strong"; MinLength = 8 }
            @{ Password = "password"; ExpectedStrength = "Weak"; MinLength = 8 }
            @{ Password = "PASSWORD"; ExpectedStrength = "Weak"; MinLength = 8 }
            @{ Password = "Password"; ExpectedStrength = "Medium"; MinLength = 8 }
            @{ Password = "Pass123"; ExpectedStrength = "Weak"; MinLength = 8 }
            @{ Password = "VeryLongPasswordWithMixedCase123!"; ExpectedStrength = "Strong"; MinLength = 12 }
        ) {
            param($Password, $ExpectedStrength, $MinLength)
            
            # Act
            $result = Test-PasswordStrength -Password $Password -MinimumLength $MinLength
            
            # Assert
            $result.Strength | Should -Be $ExpectedStrength
        }
    }
}
```

**Code Coverage Analysis** measures test effectiveness and identifies untested code paths:

```powershell
# Configure code coverage collection
$coverageConfiguration = New-PesterConfiguration
$coverageConfiguration.Run.Path = "$PSScriptRoot\Tests"
$coverageConfiguration.CodeCoverage.Enabled = $true
$coverageConfiguration.CodeCoverage.Path = "$PSScriptRoot\src\*.psm1"
$coverageConfiguration.CodeCoverage.OutputPath = "$PSScriptRoot\coverage.xml"
$coverageConfiguration.CodeCoverage.OutputFormat = "JaCoCo"
$coverageConfiguration.TestResult.Enabled = $true
$coverageConfiguration.TestResult.OutputPath = "$PSScriptRoot\testresults.xml"
$coverageConfiguration.TestResult.OutputFormat = "NUnitXml"

# Run tests with coverage analysis
$testResults = Invoke-Pester -Configuration $coverageConfiguration

# Generate coverage report
if ($testResults.CodeCoverage) {
    $coveragePercent = [math]::Round(($testResults.CodeCoverage.NumberOfCommandsExecuted / $testResults.CodeCoverage.NumberOfCommandsAnalyzed) * 100, 2)
    Write-Host "Code Coverage: $coveragePercent%" -ForegroundColor Green
    
    # Identify uncovered lines
    $uncoveredCommands = $testResults.CodeCoverage.MissedCommands
    if ($uncoveredCommands) {
        Write-Host "Uncovered code found in:" -ForegroundColor Yellow
        $uncoveredCommands | Group-Object File | ForEach-Object {
            Write-Host "  $($_.Name)" -ForegroundColor Yellow
            $_.Group | ForEach-Object {
                Write-Host "    Line $($_.LineNumber): $($_.Command)" -ForegroundColor Gray
            }
        }
    }
}
```

**Integration Testing** validates interactions between components:

```powershell
Describe "UserService Integration Tests" -Tag "Integration" {
    BeforeAll {
        # Setup test database
        $script:TestDatabasePath = "$TestDrive\test.db"
        Initialize-TestDatabase -Path $script:TestDatabasePath
        
        # Configure service with test database
        $connectionString = "Data Source=$script:TestDatabasePath"
        Initialize-UserService -ConnectionString $connectionString
    }
    
    AfterAll {
        # Cleanup test database
        if (Test-Path $script:TestDatabasePath) {
            Remove-Item $script:TestDatabasePath -Force
        }
    }
    
    Context "User lifecycle operations" {
        It "Should create, retrieve, update, and delete user successfully" {
            # Create user
            $newUser = @{
                Name = "Integration Test User"
                Email = "integration@test.com"
                Department = "QA"
            }
            $userId = New-User @newUser
            $userId | Should -Not -BeNullOrEmpty
            
            # Retrieve user
            $retrievedUser = Get-User -Id $userId
            $retrievedUser.Name | Should -Be $newUser.Name
            $retrievedUser.Email | Should -Be $newUser.Email
            
            # Update user
            $updatedData = @{ Department = "Engineering" }
            Update-User -Id $userId @updatedData
            
            $updatedUser = Get-User -Id $userId
            $updatedUser.Department | Should -Be "Engineering"
            
            # Delete user
            Remove-User -Id $userId
            { Get-User -Id $userId } | Should -Throw -ExpectedMessage "*User not found*"
        }
    }
}
```

**Key points** include understanding that advanced PowerShell scripting patterns leverage object-oriented principles, functional programming concepts, and pipeline-centric architectures to create maintainable and scalable automation solutions. Configuration management requires hierarchical approaches with environment-specific overrides, secure secret handling, and comprehensive validation. Logging frameworks should provide structured output, asynchronous processing capabilities, multiple providers, and performance optimization. Unit testing with Pester demands comprehensive test coverage, effective mocking strategies, parameterized test cases, and integration testing approaches that validate component interactions while maintaining test isolation and repeatability.

---

