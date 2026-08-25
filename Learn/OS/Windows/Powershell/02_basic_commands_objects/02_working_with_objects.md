## Working with Objects


### Understanding Object Properties and Methods

PowerShell operates on .NET objects rather than text strings, making it fundamentally different from traditional command-line interfaces. Every piece of data in PowerShell represents an object containing properties (data attributes) and methods (actions the object can perform).

**Properties** store information about the object. These read-only or read-write attributes contain the object's data, such as a file's name, size, creation date, or a process's ID and memory usage. Properties appear as name-value pairs and can contain simple values like strings and numbers, or complex nested objects.

**Methods** define actions that objects can perform or operations that can be performed on objects. Methods may accept parameters and return values. Common examples include a string object's `.ToUpper()` method or a file object's `.Delete()` method.

**Object Types** determine which properties and methods are available. PowerShell objects inherit from .NET base types, with each type defining specific capabilities. The object's type information helps PowerShell determine how to format output and which operations are valid.

**Key points:**

- Objects contain both data (properties) and functionality (methods)
- Object types determine available properties and methods
- PowerShell preserves full object information throughout the pipeline
- Understanding object structure enables effective data manipulation

### Exploring Objects with Get-Member

The `Get-Member` cmdlet serves as the primary tool for discovering object structure, revealing all properties, methods, and other members available on objects.

**Basic Get-Member usage:**

```powershell
Get-Process | Get-Member
Get-ChildItem C:\ | Get-Member
"Hello World" | Get-Member
```

**Member types** displayed by Get-Member include:

- **Property**: Data attributes of the object
- **Method**: Functions that can be called on the object
- **ScriptProperty**: Properties implemented through PowerShell scripts
- **AliasProperty**: Alternative names for existing properties
- **NoteProperty**: Custom properties added to objects
- **ScriptMethod**: Methods implemented through PowerShell scripts

**Filtering member types:**

```powershell
Get-Process | Get-Member -MemberType Property
Get-Process | Get-Member -MemberType Method
Get-Service | Get-Member -MemberType *Property
```

**Static members** belong to the type itself rather than individual instances:

```powershell
[System.DateTime] | Get-Member -Static
[System.Math] | Get-Member -Static
```

**Member definitions** show the full signature including return types and parameter information. The Definition column provides crucial information about how to use each member.

**Example** exploring a process object:

```powershell
$process = Get-Process -Name "notepad" | Select-Object -First 1
$process | Get-Member

# Examine specific properties
$process.ProcessName
$process.Id
$process.WorkingSet

# Call methods
$process.ToString()
$process.GetType()
```

**Key points:**

- Get-Member reveals complete object structure
- Member types indicate how to interact with object components
- Static members belong to types rather than instances
- Definition column shows usage syntax and return types

### Selecting Properties with Select-Object

`Select-Object` controls which properties appear in command output and enables property transformation, making it essential for data filtering and presentation.

**Basic property selection:**

```powershell
Get-Process | Select-Object Name, Id, CPU
Get-Service | Select-Object Name, Status
Get-ChildItem | Select-Object Name, Length, LastWriteTime
```

**Wildcard property selection:**

```powershell
Get-Process | Select-Object Name, *Memory*
Get-Service | Select-Object Name, Status, Start*
```

**First and Last object selection:**

```powershell
Get-Process | Select-Object -First 5
Get-EventLog -LogName System | Select-Object -Last 10
Get-ChildItem | Select-Object -First 3 -Property Name, Length
```

**Unique value selection:**

```powershell
Get-Process | Select-Object -Property ProcessName -Unique
Get-EventLog -LogName System | Select-Object -Property Source -Unique
```

**Calculated properties** enable custom property creation and transformation:

```powershell
Get-Process | Select-Object Name, 
    @{Name='MemoryMB'; Expression={$_.WorkingSet / 1MB}},
    @{Name='CPUTime'; Expression={$_.TotalProcessorTime}}

Get-ChildItem | Select-Object Name,
    @{Name='SizeKB'; Expression={[math]::Round($_.Length / 1KB, 2)}},
    @{Name='Age'; Expression={(Get-Date) - $_.CreationTime}}
```

**Property exclusion:**

```powershell
Get-Process | Select-Object * -ExcludeProperty Handles, Threads
Get-Service | Select-Object * -ExcludeProperty ServicesDependedOn
```

**Index-based selection:**

```powershell
Get-Process | Select-Object -Index 0, 2, 4
Get-ChildItem | Select-Object -Skip 5 -First 10
```

**Key points:**

- Select-Object controls output property visibility
- Calculated properties enable data transformation
- Wildcard patterns simplify property selection
- Index-based selection provides precise object filtering

### Basic Object Manipulation

PowerShell provides numerous techniques for modifying, extending, and transforming objects to meet specific requirements.

#### Adding Properties and Methods

**Add-Member** extends objects with custom properties and methods:

```powershell
$object = Get-Process -Name "notepad" | Select-Object -First 1

# Add custom property
$object | Add-Member -MemberType NoteProperty -Name "CustomField" -Value "Custom Value"

# Add calculated property
$object | Add-Member -MemberType ScriptProperty -Name "MemoryMB" -Value {$this.WorkingSet / 1MB}

# Add custom method
$object | Add-Member -MemberType ScriptMethod -Name "GetInfo" -Value {"Process: $($this.Name), PID: $($this.Id)"}

# Use added members
$object.CustomField
$object.MemoryMB
$object.GetInfo()
```

#### Property Modification

Direct property assignment modifies writable properties:

```powershell
$service = Get-Service -Name "Spooler"
# Note: Most system object properties are read-only

# Custom objects allow property modification
$customObject = [PSCustomObject]@{
    Name = "John"
    Age = 30
    Department = "IT"
}

$customObject.Age = 31
$customObject.Department = "Engineering"
```

#### Object Conversion and Casting

**Type conversion** transforms objects between different .NET types:

```powershell
# String to integer
$number = [int]"42"

# DateTime conversion
$date = [DateTime]"2024-01-15"

# Array conversion
$stringArray = @("1", "2", "3")
$intArray = [int[]]$stringArray
```

**Object creation** builds custom objects with specific structures:

```powershell
# PSCustomObject creation
$employee = [PSCustomObject]@{
    Name = "Jane Smith"
    EmployeeId = 12345
    Department = "Sales"
    Salary = 75000
}

# Hashtable to object conversion
$hash = @{Server = "SQL01"; Database = "Production"; Port = 1433}
$connectionInfo = [PSCustomObject]$hash
```

#### Object Comparison and Filtering

**Where-Object** filters objects based on property values:

```powershell
Get-Process | Where-Object {$_.CPU -gt 10}
Get-Service | Where-Object {$_.Status -eq "Running"}
Get-ChildItem | Where-Object {$_.Length -gt 1MB}
```

**Compare-Object** identifies differences between object collections:

```powershell
$runningServices = Get-Service | Where-Object {$_.Status -eq "Running"}
$startupServices = Get-Service | Where-Object {$_.StartType -eq "Automatic"}

Compare-Object $runningServices.Name $startupServices.Name
```

#### Object Grouping and Sorting

**Group-Object** organizes objects by property values:

```powershell
Get-Process | Group-Object ProcessName
Get-Service | Group-Object Status
Get-EventLog -LogName System -Newest 100 | Group-Object Source
```

**Sort-Object** arranges objects by specified criteria:

```powershell
Get-Process | Sort-Object CPU -Descending
Get-ChildItem | Sort-Object Length, Name
Get-Service | Sort-Object Status, Name
```

**Example** of comprehensive object manipulation:

```powershell
# Get processes, add custom properties, filter, and sort
Get-Process | 
    Add-Member -MemberType ScriptProperty -Name "MemoryGB" -Value {[math]::Round($this.WorkingSet / 1GB, 2)} -PassThru |
    Where-Object {$_.CPU -gt 1} |
    Sort-Object CPU -Descending |
    Select-Object Name, Id, CPU, MemoryGB, @{Name='Status'; Expression={'Running'}} |
    Format-Table -AutoSize
```

**Key points:**

- Add-Member extends objects with custom properties and methods
- Object conversion enables type transformation
- Filtering and sorting organize data effectively
- Method chaining combines multiple object operations
- Custom objects provide flexible data structures

### Object Pipeline Behavior

The PowerShell pipeline passes complete objects between commands, preserving all properties and methods throughout the command chain. This object-based approach enables sophisticated data manipulation while maintaining type safety and information fidelity.

**Pipeline object flow:**

```powershell
# Each command receives full objects from previous command
Get-Process | 
    Where-Object {$_.ProcessName -like "s*"} | 
    Sort-Object CPU -Descending | 
    Select-Object Name, CPU, WorkingSet
```

**Object enumeration** occurs automatically when collections pass through the pipeline:

```powershell
# Get-Process returns a collection, pipeline processes each process individually
Get-Process | ForEach-Object {"Process: $($_.Name)"}
```

**Type preservation** maintains object integrity:

```powershell
# Objects retain original type information
$processes = Get-Process | Where-Object {$_.Name -like "p*"}
$processes[0].GetType().FullName  # Still System.Diagnostics.Process
```

**Key points:**

- Pipeline preserves complete object information
- Automatic enumeration processes collection items individually
- Object types remain intact throughout pipeline operations
- Full .NET capabilities remain available at each pipeline stage

---

