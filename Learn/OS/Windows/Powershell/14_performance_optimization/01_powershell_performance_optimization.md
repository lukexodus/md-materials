## PowerShell Performance Optimization


### Measuring Script Performance

#### Built-in Timing Methods

PowerShell provides several mechanisms for measuring execution time, from simple timing to detailed performance profiling. The `Measure-Command` cmdlet offers basic timing functionality while .NET Stopwatch provides precise measurements.

```powershell
# Basic timing with Measure-Command
$executionTime = Measure-Command {
    Get-Process | Where-Object { $_.CPU -gt 100 }
}
Write-Host "Execution time: $($executionTime.TotalMilliseconds) ms"

# Precise timing with Stopwatch
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
# Code to measure
$result = Get-ChildItem -Path "C:\" -Recurse -ErrorAction SilentlyContinue
$stopwatch.Stop()
Write-Host "Elapsed: $($stopwatch.Elapsed.TotalSeconds) seconds"

# Multiple iteration timing for accuracy
$times = 1..10 | ForEach-Object {
    (Measure-Command { Get-Service }).TotalMilliseconds
}
$averageTime = ($times | Measure-Object -Average).Average
Write-Host "Average execution time: $averageTime ms"
```

#### Performance Profiling and Analysis

Advanced performance analysis involves profiling memory usage, CPU consumption, and identifying bottlenecks in complex scripts.

```powershell
# Memory usage tracking
function Measure-MemoryUsage {
    param([ScriptBlock]$ScriptBlock)
    
    [System.GC]::Collect()
    $beforeMemory = [System.GC]::GetTotalMemory($false)
    
    $result = & $ScriptBlock
    
    [System.GC]::Collect()
    $afterMemory = [System.GC]::GetTotalMemory($false)
    
    [PSCustomObject]@{
        Result = $result
        MemoryUsed = $afterMemory - $beforeMemory
        MemoryUsedMB = [math]::Round(($afterMemory - $beforeMemory) / 1MB, 2)
    }
}

# CPU usage monitoring
function Measure-CPUUsage {
    param([ScriptBlock]$ScriptBlock)
    
    $process = Get-Process -Id $PID
    $startCPU = $process.CPU
    $startTime = Get-Date
    
    $result = & $ScriptBlock
    
    $endTime = Get-Date
    $endCPU = (Get-Process -Id $PID).CPU
    
    [PSCustomObject]@{
        Result = $result
        CPUTimeUsed = $endCPU - $startCPU
        WallClockTime = ($endTime - $startTime).TotalSeconds
        CPUPercentage = [math]::Round((($endCPU - $startCPU) / ($endTime - $startTime).TotalSeconds) * 100, 2)
    }
}
```

#### Benchmarking Frameworks

Systematic performance testing requires structured benchmarking approaches that account for variance and environmental factors.

```powershell
# Comprehensive benchmark function
function Invoke-Benchmark {
    param(
        [hashtable]$TestCases,
        [int]$Iterations = 10,
        [switch]$WarmUp
    )
    
    $results = @{}
    
    foreach ($testName in $TestCases.Keys) {
        Write-Host "Running benchmark: $testName" -ForegroundColor Yellow
        
        # Warm-up run
        if ($WarmUp) {
            & $TestCases[$testName] | Out-Null
        }
        
        $times = @()
        for ($i = 1; $i -le $Iterations; $i++) {
            [System.GC]::Collect()
            $time = (Measure-Command { & $TestCases[$testName] }).TotalMilliseconds
            $times += $time
            Write-Progress -Activity "Benchmarking $testName" -PercentComplete (($i / $Iterations) * 100)
        }
        
        $stats = $times | Measure-Object -Average -Minimum -Maximum -StandardDeviation
        $results[$testName] = [PSCustomObject]@{
            TestName = $testName
            Iterations = $Iterations
            AverageMs = [math]::Round($stats.Average, 2)
            MinMs = [math]::Round($stats.Minimum, 2)
            MaxMs = [math]::Round($stats.Maximum, 2)
            StdDevMs = [math]::Round($stats.StandardDeviation, 2)
        }
    }
    
    return $results
}
```

### Memory Management

#### Garbage Collection Optimization

PowerShell relies on .NET garbage collection, but manual intervention can optimize memory usage for long-running scripts and large data processing.

```powershell
# Manual garbage collection
function Optimize-Memory {
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    [System.GC]::Collect()
    
    $memoryBefore = [System.GC]::GetTotalMemory($false)
    [System.GC]::Collect(2, [System.GCCollectionMode]::Forced)
    $memoryAfter = [System.GC]::GetTotalMemory($true)
    
    Write-Host "Memory freed: $([math]::Round(($memoryBefore - $memoryAfter) / 1MB, 2)) MB"
}

# Memory-conscious processing
function Process-LargeDataset {
    param([string[]]$FilePaths)
    
    foreach ($filePath in $FilePaths) {
        try {
            # Process file in chunks
            $reader = [System.IO.File]::OpenText($filePath)
            $lineCount = 0
            
            while (($line = $reader.ReadLine()) -ne $null) {
                # Process line
                ProcessLine $line
                $lineCount++
                
                # Periodic cleanup
                if ($lineCount % 10000 -eq 0) {
                    [System.GC]::Collect()
                }
            }
        }
        finally {
            if ($reader) { $reader.Dispose() }
        }
    }
}
```

#### Variable Scope and Disposal

Proper variable management and scope control prevent memory leaks and optimize resource usage in complex scripts.

```powershell
# Explicit variable cleanup
function Process-WithCleanup {
    param([string]$DataPath)
    
    try {
        $largeData = Import-Csv -Path $DataPath
        $processedData = $largeData | ForEach-Object {
            # Process each item
            [PSCustomObject]@{
                Name = $_.Name
                ProcessedValue = $_.Value * 2
            }
        }
        
        # Export results
        $processedData | Export-Csv -Path "processed.csv" -NoTypeInformation
    }
    finally {
        # Explicit cleanup
        if (Get-Variable -Name largeData -ErrorAction SilentlyContinue) {
            Remove-Variable -Name largeData -Force
        }
        if (Get-Variable -Name processedData -ErrorAction SilentlyContinue) {
            Remove-Variable -Name processedData -Force
        }
        [System.GC]::Collect()
    }
}

# Using statement pattern for disposables
function Use-DisposableResource {
    param([string]$ConnectionString)
    
    $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
    try {
        $connection.Open()
        # Use connection
        $command = $connection.CreateCommand()
        $command.CommandText = "SELECT * FROM Users"
        $reader = $command.ExecuteReader()
        
        while ($reader.Read()) {
            # Process data
        }
    }
    finally {
        if ($reader) { $reader.Dispose() }
        if ($command) { $command.Dispose() }
        if ($connection) { $connection.Dispose() }
    }
}
```

#### Memory-Efficient Data Structures

Choosing appropriate data structures and processing patterns significantly impacts memory consumption and performance.

```powershell
# ArrayList vs Array for dynamic data
function Compare-DataStructures {
    # Inefficient: Array resizing
    $slowArray = @()
    $time1 = Measure-Command {
        for ($i = 0; $i -lt 10000; $i++) {
            $slowArray += "Item $i"
        }
    }
    
    # Efficient: ArrayList
    $fastList = New-Object System.Collections.ArrayList
    $time2 = Measure-Command {
        for ($i = 0; $i -lt 10000; $i++) {
            $fastList.Add("Item $i") | Out-Null
        }
    }
    
    Write-Host "Array time: $($time1.TotalMilliseconds) ms"
    Write-Host "ArrayList time: $($time2.TotalMilliseconds) ms"
}

# Generic collections for type safety and performance
function Use-GenericCollections {
    # Generic List<T>
    $stringList = New-Object 'System.Collections.Generic.List[string]'
    $stringList.Add("Item 1")
    $stringList.AddRange(@("Item 2", "Item 3", "Item 4"))
    
    # Dictionary for fast lookups
    $lookup = New-Object 'System.Collections.Generic.Dictionary[string,object]'
    $lookup["key1"] = "value1"
    $lookup["key2"] = @{nested = "data"}
    
    return $stringList, $lookup
}
```

### Efficient Data Processing Techniques

#### Pipeline Optimization

PowerShell pipelines can be optimized through proper cmdlet selection, filtering strategies, and avoiding unnecessary object creation.

```powershell
# Efficient filtering - filter early
# Slow: Process all, then filter
$slowResult = Get-Process | ForEach-Object { 
    [PSCustomObject]@{Name = $_.Name; CPU = $_.CPU; Memory = $_.WorkingSet64}
} | Where-Object { $_.CPU -gt 10 }

# Fast: Filter first, then process
$fastResult = Get-Process | Where-Object { $_.CPU -gt 10 } | ForEach-Object {
    [PSCustomObject]@{Name = $_.Name; CPU = $_.CPU; Memory = $_.WorkingSet64}
}

# Use -Filter parameter when available
$filteredFiles = Get-ChildItem -Path "C:\Temp" -Filter "*.log" -Recurse
# Instead of: Get-ChildItem -Path "C:\Temp" -Recurse | Where-Object { $_.Extension -eq ".log" }
```

#### Bulk Operations

Batch processing and bulk operations reduce overhead compared to individual item processing.

```powershell
# Bulk file operations
function Copy-FilesBulk {
    param([string[]]$SourcePaths, [string]$Destination)
    
    # Inefficient: Individual copy operations
    # $SourcePaths | ForEach-Object { Copy-Item -Path $_ -Destination $Destination }
    
    # Efficient: Bulk copy with robocopy
    $sourceDir = Split-Path $SourcePaths[0] -Parent
    $fileList = $SourcePaths | ForEach-Object { Split-Path $_ -Leaf }
    
    # Create temporary file list
    $listFile = [System.IO.Path]::GetTempFileName()
    $fileList | Set-Content -Path $listFile
    
    try {
        & robocopy $sourceDir $Destination /XF $listFile /MT:8 /R:3 /W:1
    }
    finally {
        Remove-Item -Path $listFile -Force
    }
}

# Bulk database operations
function Update-DatabaseBulk {
    param([object[]]$Records, [string]$ConnectionString)
    
    $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
    $connection.Open()
    
    try {
        $transaction = $connection.BeginTransaction()
        
        foreach ($batch in ($Records | Group-Object { [math]::Floor($_.Index / 1000) })) {
            $bulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($connection, [System.Data.SqlClient.SqlBulkCopyOptions]::Default, $transaction)
            $bulkCopy.DestinationTableName = "TargetTable"
            
            # Convert to DataTable and bulk insert
            $dataTable = ConvertTo-DataTable $batch.Group
            $bulkCopy.WriteToServer($dataTable)
        }
        
        $transaction.Commit()
    }
    catch {
        $transaction.Rollback()
        throw
    }
    finally {
        $connection.Close()
    }
}
```

#### Stream Processing

Stream processing handles large datasets without loading entire collections into memory.

```powershell
# Stream-based CSV processing
function Process-LargeCSVStream {
    param([string]$InputPath, [string]$OutputPath)
    
    $reader = [System.IO.StreamReader]::new($InputPath)
    $writer = [System.IO.StreamWriter]::new($OutputPath)
    
    try {
        # Write header
        $header = $reader.ReadLine()
        $writer.WriteLine($header + ",ProcessedColumn")
        
        # Process line by line
        while (($line = $reader.ReadLine()) -ne $null) {
            $fields = $line -split ','
            $processedValue = [int]$fields[2] * 2  # Example processing
            $newLine = "$line,$processedValue"
            $writer.WriteLine($newLine)
            
            # Periodic flush
            if ($writer.BaseStream.Position % 1000000 -eq 0) {
                $writer.Flush()
            }
        }
    }
    finally {
        $reader.Close()
        $writer.Close()
    }
}

# Streaming XML processing
function Process-XMLStream {
    param([string]$XmlPath)
    
    $settings = New-Object System.Xml.XmlReaderSettings
    $settings.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
    
    $reader = [System.Xml.XmlReader]::Create($XmlPath, $settings)
    
    try {
        while ($reader.Read()) {
            if ($reader.NodeType -eq [System.Xml.XmlNodeType]::Element -and $reader.Name -eq "Record") {
                $element = $reader.ReadOuterXml()
                # Process individual record without loading entire document
                Process-XMLRecord $element
            }
        }
    }
    finally {
        $reader.Close()
    }
}
```

### Parallel Processing with ForEach-Object -Parallel

#### Basic Parallel Processing

[Inference] The `-Parallel` parameter in `ForEach-Object` enables concurrent processing across multiple threads, significantly improving performance for CPU-intensive and I/O-bound operations.

```powershell
# Basic parallel processing
$urls = @("https://site1.com", "https://site2.com", "https://site3.com", "https://site4.com")

# Sequential processing
$sequentialTime = Measure-Command {
    $sequentialResults = $urls | ForEach-Object {
        try {
            $response = Invoke-WebRequest -Uri $_ -TimeoutSec 10
            [PSCustomObject]@{URL = $_; StatusCode = $response.StatusCode; Length = $response.Content.Length}
        }
        catch {
            [PSCustomObject]@{URL = $_; StatusCode = "Error"; Length = 0}
        }
    }
}

# Parallel processing
$parallelTime = Measure-Command {
    $parallelResults = $urls | ForEach-Object -Parallel {
        try {
            $response = Invoke-WebRequest -Uri $_ -TimeoutSec 10
            [PSCustomObject]@{URL = $_; StatusCode = $response.StatusCode; Length = $response.Content.Length}
        }
        catch {
            [PSCustomObject]@{URL = $_; StatusCode = "Error"; Length = 0}
        }
    } -ThrottleLimit 4
}

Write-Host "Sequential: $($sequentialTime.TotalSeconds)s, Parallel: $($parallelTime.TotalSeconds)s"
```

#### Advanced Parallel Processing Patterns

Parallel processing requires careful consideration of shared state, variable scope, and synchronization mechanisms.

```powershell
# Thread-safe collections for parallel processing
$threadSafeResults = [System.Collections.Concurrent.ConcurrentBag[object]]::new()

1..1000 | ForEach-Object -Parallel {
    # Access thread-safe collection
    $safeResults = $using:threadSafeResults
    
    # Perform processing
    $result = [PSCustomObject]@{
        ThreadId = [System.Threading.Thread]::CurrentThread.ManagedThreadId
        ProcessedValue = $_ * 2
        Timestamp = Get-Date
    }
    
    $safeResults.Add($result)
} -ThrottleLimit 8

# Variable passing to parallel blocks
$multiplier = 3
$baseValue = 100

$results = 1..100 | ForEach-Object -Parallel {
    # Use $using: to access outer scope variables
    $localMultiplier = $using:multiplier
    $localBase = $using:baseValue
    
    [PSCustomObject]@{
        Input = $_
        Result = ($_ + $localBase) * $localMultiplier
        ThreadId = [System.Threading.Thread]::CurrentThread.ManagedThreadId
    }
} -ThrottleLimit 4
```

#### File Processing with Parallel Execution

Parallel file processing demonstrates significant performance improvements for I/O-intensive operations.

```powershell
# Parallel file processing
function Process-FilesParallel {
    param([string[]]$FilePaths, [int]$ThrottleLimit = 4)
    
    $results = $FilePaths | ForEach-Object -Parallel {
        $filePath = $_
        
        try {
            $fileInfo = Get-Item -Path $filePath
            $content = Get-Content -Path $filePath -Raw
            
            # Simulate processing
            $wordCount = ($content -split '\s+').Count
            $lineCount = ($content -split '\n').Count
            
            [PSCustomObject]@{
                Path = $filePath
                SizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
                WordCount = $wordCount
                LineCount = $lineCount
                ProcessedBy = [System.Threading.Thread]::CurrentThread.ManagedThreadId
            }
        }
        catch {
            [PSCustomObject]@{
                Path = $filePath
                Error = $_.Exception.Message
                ProcessedBy = [System.Threading.Thread]::CurrentThread.ManagedThreadId
            }
        }
    } -ThrottleLimit $ThrottleLimit
    
    return $results
}

# Progress tracking in parallel processing
$files = Get-ChildItem -Path "C:\Logs" -Filter "*.log" -Recurse
$completed = 0
$total = $files.Count

$results = $files | ForEach-Object -Parallel {
    $file = $_
    $completedRef = $using:completed
    $totalRef = $using:total
    
    # Process file
    $hash = Get-FileHash -Path $file.FullName
    
    # Thread-safe progress update
    $newCompleted = [System.Threading.Interlocked]::Increment([ref]$completedRef)
    Write-Progress -Activity "Processing Files" -Status "Processing $($file.Name)" -PercentComplete (($newCompleted / $totalRef) * 100)
    
    [PSCustomObject]@{
        Name = $file.Name
        Hash = $hash.Hash
        Size = $file.Length
    }
} -ThrottleLimit 6
```

### Background Jobs and Workflows

#### PowerShell Background Jobs

Background jobs execute PowerShell commands asynchronously, enabling concurrent execution and non-blocking operations.

```powershell
# Basic background jobs
$job1 = Start-Job -ScriptBlock {
    Get-Process | Where-Object { $_.CPU -gt 10 } | Sort-Object CPU -Descending
}

$job2 = Start-Job -ScriptBlock {
    Get-Service | Where-Object { $_.Status -eq 'Running' } | Sort-Object Name
}

$job3 = Start-Job -ScriptBlock {
    Get-EventLog -LogName System -Newest 100 | Where-Object { $_.EntryType -eq 'Error' }
}

# Wait for jobs and collect results
$jobs = @($job1, $job2, $job3)
$results = $jobs | ForEach-Object {
    Wait-Job -Job $_
    $result = Receive-Job -Job $_
    Remove-Job -Job $_
    [PSCustomObject]@{
        JobName = $_.Name
        State = $_.State
        ResultCount = $result.Count
        Data = $result
    }
}

# Job management with timeout
function Invoke-JobWithTimeout {
    param(
        [ScriptBlock]$ScriptBlock,
        [int]$TimeoutSeconds = 300,
        [string]$JobName
    )
    
    $job = Start-Job -ScriptBlock $ScriptBlock -Name $JobName
    
    try {
        $completed = Wait-Job -Job $job -Timeout $TimeoutSeconds
        
        if ($completed) {
            $result = Receive-Job -Job $job
            return [PSCustomObject]@{
                Success = $true
                Result = $result
                JobName = $JobName
                State = $job.State
            }
        }
        else {
            Stop-Job -Job $job
            return [PSCustomObject]@{
                Success = $false
                Error = "Job timed out after $TimeoutSeconds seconds"
                JobName = $JobName
                State = "Timeout"
            }
        }
    }
    finally {
        Remove-Job -Job $job -Force
    }
}
```

#### Advanced Job Patterns

Complex job scenarios involve job dependencies, result aggregation, and error handling strategies.

```powershell
# Job pipeline with dependencies
function Invoke-JobPipeline {
    param([hashtable]$JobDefinitions)
    
    $jobResults = @{}
    $completedJobs = @{}
    
    foreach ($jobName in $JobDefinitions.Keys) {
        $jobConfig = $JobDefinitions[$jobName]
        
        # Check dependencies
        if ($jobConfig.DependsOn) {
            foreach ($dependency in $jobConfig.DependsOn) {
                if (-not $completedJobs.ContainsKey($dependency)) {
                    Write-Warning "Dependency $dependency not completed for job $jobName"
                    continue
                }
            }
        }
        
        # Start job with dependency data
        $dependencyData = $jobConfig.DependsOn | ForEach-Object { $jobResults[$_] }
        
        $job = Start-Job -ScriptBlock $jobConfig.ScriptBlock -ArgumentList $dependencyData
        
        # Wait and collect results
        Wait-Job -Job $job | Out-Null
        $jobResults[$jobName] = Receive-Job -Job $job
        $completedJobs[$jobName] = $true
        Remove-Job -Job $job
        
        Write-Host "Completed job: $jobName" -ForegroundColor Green
    }
    
    return $jobResults
}

# Parallel job execution with result aggregation
function Invoke-ParallelJobs {
    param(
        [ScriptBlock[]]$ScriptBlocks,
        [int]$MaxConcurrency = 4
    )
    
    $jobs = @()
    $results = @()
    
    # Start jobs in batches
    for ($i = 0; $i -lt $ScriptBlocks.Count; $i += $MaxConcurrency) {
        $batch = $ScriptBlocks[$i..([math]::Min($i + $MaxConcurrency - 1, $ScriptBlocks.Count - 1))]
        
        $batchJobs = $batch | ForEach-Object {
            Start-Job -ScriptBlock $_
        }
        
        # Wait for batch completion
        $batchJobs | Wait-Job | Out-Null
        
        # Collect results
        $batchResults = $batchJobs | ForEach-Object {
            $result = Receive-Job -Job $_
            Remove-Job -Job $_
            $result
        }
        
        $results += $batchResults
        Write-Progress -Activity "Processing Job Batches" -PercentComplete (($i / $ScriptBlocks.Count) * 100)
    }
    
    return $results
}
```

#### Workflow Alternatives and Modern Patterns

[Unverified] While PowerShell Workflows have been deprecated, modern alternatives provide similar functionality with better performance and maintainability.

```powershell
# Runspace pools for high-performance parallel execution
function Invoke-RunspaceJobs {
    param(
        [object[]]$InputObjects,
        [ScriptBlock]$ScriptBlock,
        [int]$MaxThreads = 4
    )
    
    # Create runspace pool
    $runspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads)
    $runspacePool.Open()
    
    try {
        $jobs = @()
        
        foreach ($inputObject in $InputObjects) {
            $powershell = [powershell]::Create()
            $powershell.RunspacePool = $runspacePool
            $powershell.AddScript($ScriptBlock).AddArgument($inputObject) | Out-Null
            
            $jobs += [PSCustomObject]@{
                PowerShell = $powershell
                Handle = $powershell.BeginInvoke()
                InputObject = $inputObject
            }
        }
        
        # Collect results
        $results = @()
        foreach ($job in $jobs) {
            $result = $job.PowerShell.EndInvoke($job.Handle)
            $results += [PSCustomObject]@{
                Input = $job.InputObject
                Output = $result
                Errors = $job.PowerShell.Streams.Error
            }
            $job.PowerShell.Dispose()
        }
        
        return $results
    }
    finally {
        $runspacePool.Close()
        $runspacePool.Dispose()
    }
}

# Task-based asynchronous patterns
function Invoke-AsyncTasks {
    param(
        [string[]]$Urls,
        [int]$TimeoutSeconds = 30
    )
    
    $tasks = $Urls | ForEach-Object {
        $uri = $_
        [System.Threading.Tasks.Task]::Run({
            try {
                $client = New-Object System.Net.Http.HttpClient
                $client.Timeout = [TimeSpan]::FromSeconds($using:TimeoutSeconds)
                $response = $client.GetAsync($using:uri).Result
                
                [PSCustomObject]@{
                    Url = $using:uri
                    StatusCode = $response.StatusCode
                    ContentLength = $response.Content.Headers.ContentLength
                    Success = $true
                }
            }
            catch {
                [PSCustomObject]@{
                    Url = $using:uri
                    Error = $_.Exception.Message
                    Success = $false
                }
            }
            finally {
                if ($client) { $client.Dispose() }
            }
        })
    }
    
    # Wait for all tasks
    [System.Threading.Tasks.Task]::WaitAll($tasks)
    
    # Collect results
    return $tasks | ForEach-Object { $_.Result }
}
```

**Key points**: PowerShell performance optimization encompasses measurement techniques using `Measure-Command` and Stopwatch, memory management through garbage collection control and efficient data structures, data processing optimization via pipeline efficiency and bulk operations, parallel processing with `ForEach-Object -Parallel` for concurrent execution, and background job management for asynchronous operations. Advanced patterns include runspace pools, task-based asynchronous programming, and workflow alternatives for complex scenarios.

**Important related topics**: PowerShell Desired State Configuration (DSC) performance considerations, module loading optimization strategies, remote session performance tuning, advanced debugging and profiling techniques, and integration with performance monitoring systems for production environments.

---

