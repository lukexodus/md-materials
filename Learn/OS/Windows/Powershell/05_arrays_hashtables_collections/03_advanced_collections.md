## Advanced Collections


### Generic Collections

PowerShell provides access to .NET's `System.Collections.Generic` namespace, offering type-safe collections with better performance than standard arrays for dynamic operations.

#### List\<T> Collections

The `List\<T>` type provides dynamic array functionality with methods for adding, removing, and searching elements:

```powershell
# Create a strongly-typed list
[System.Collections.Generic.List[string]]$stringList = @()
$stringList.Add("Item1")
$stringList.Add("Item2")
$stringList.AddRange(@("Item3", "Item4"))

# Access elements
$stringList[0]  # Returns "Item1"
$stringList.Count  # Returns 4

# Remove elements
$stringList.Remove("Item2")
$stringList.RemoveAt(0)
```

#### Dictionary<TKey, TValue> Collections

Dictionaries provide key-value pair storage with fast lookups:

```powershell
# Create a dictionary
[System.Collections.Generic.Dictionary[string,int]]$dict = @{}
$dict.Add("key1", 100)
$dict["key2"] = 200

# Check for keys
if ($dict.ContainsKey("key1")) {
    Write-Host "Found key1 with value: $($dict['key1'])"
}

# Iterate through dictionary
foreach ($kvp in $dict.GetEnumerator()) {
    Write-Host "$($kvp.Key): $($kvp.Value)"
}
```

#### HashSet\<T> Collections

HashSets store unique values with fast lookup and set operations:

```powershell
[System.Collections.Generic.HashSet[string]]$set1 = @("A", "B", "C")
[System.Collections.Generic.HashSet[string]]$set2 = @("B", "C", "D")

# Add elements
$set1.Add("E")

# Set operations
$set1.UnionWith($set2)  # Union
$set1.IntersectWith($set2)  # Intersection
$set1.ExceptWith($set2)  # Difference
```

#### Queue\<T> and Stack\<T> Collections

These provide FIFO (queue) and LIFO (stack) data structures:

```powershell
# Queue (First In, First Out)
[System.Collections.Generic.Queue[string]]$queue = @()
$queue.Enqueue("First")
$queue.Enqueue("Second")
$first = $queue.Dequeue()  # Returns "First"

# Stack (Last In, First Out)
[System.Collections.Generic.Stack[int]]$stack = @()
$stack.Push(1)
$stack.Push(2)
$top = $stack.Pop()  # Returns 2
```

**Key Points:**

- Generic collections provide type safety and better performance
- Use `List<T>` instead of arrays for dynamic collections
- Dictionaries offer O(1) average lookup time
- HashSets automatically handle uniqueness constraints

### Custom Objects with New-Object and PSCustomObject

PowerShell allows creation of custom objects to structure data in meaningful ways.

#### Using New-Object

The `New-Object` cmdlet creates instances of .NET objects or COM objects:

```powershell
# Create a generic object
$obj = New-Object -TypeName PSObject
$obj | Add-Member -MemberType NoteProperty -Name "Name" -Value "John"
$obj | Add-Member -MemberType NoteProperty -Name "Age" -Value 30
$obj | Add-Member -MemberType ScriptMethod -Name "GetInfo" -Value {
    return "$($this.Name) is $($this.Age) years old"
}

# Create .NET objects
$stringBuilder = New-Object System.Text.StringBuilder
$stringBuilder.Append("Hello")
$stringBuilder.Append(" World")
$result = $stringBuilder.ToString()
```

#### Using PSCustomObject

`[PSCustomObject]` provides a more concise syntax for creating custom objects:

```powershell
# Basic PSCustomObject
$person = [PSCustomObject]@{
    Name = "Jane"
    Age = 25
    Department = "IT"
    Skills = @("PowerShell", "C#", "Azure")
}

# Access properties
$person.Name
$person.Skills[0]

# Add properties dynamically
$person | Add-Member -MemberType NoteProperty -Name "Salary" -Value 75000

# Create arrays of custom objects
$employees = @(
    [PSCustomObject]@{Name="John"; Department="IT"; Salary=70000}
    [PSCustomObject]@{Name="Jane"; Department="HR"; Salary=65000}
    [PSCustomObject]@{Name="Bob"; Department="Finance"; Salary=80000}
)

# Filter and manipulate
$itEmployees = $employees | Where-Object {$_.Department -eq "IT"}
$avgSalary = ($employees | Measure-Object -Property Salary -Average).Average
```

#### Advanced Custom Object Techniques

**Nested Objects:**

```powershell
$company = [PSCustomObject]@{
    Name = "TechCorp"
    Address = [PSCustomObject]@{
        Street = "123 Tech St"
        City = "Seattle"
        State = "WA"
    }
    Employees = @(
        [PSCustomObject]@{Name="Alice"; Role="Developer"}
        [PSCustomObject]@{Name="Bob"; Role="Manager"}
    )
}
```

**Methods in Custom Objects:**

```powershell
$calculator = [PSCustomObject]@{
    Value = 0
} | Add-Member -MemberType ScriptMethod -Name "Add" -Value {
    param($number)
    $this.Value += $number
    return $this
} -PassThru | Add-Member -MemberType ScriptMethod -Name "GetResult" -Value {
    return $this.Value
} -PassThru
```

**Key Points:**

- `[PSCustomObject]` is generally preferred over `New-Object PSObject`
- Custom objects integrate seamlessly with PowerShell pipeline
- Properties can be added dynamically using `Add-Member`
- Methods can be added using `ScriptMethod` member type

### Working with .NET Collections

PowerShell provides direct access to the full range of .NET collection types, enabling sophisticated data manipulation scenarios.

#### Specialized Collections

**SortedDictionary:**

```powershell
[System.Collections.Generic.SortedDictionary[string,int]]$sortedDict = @{}
$sortedDict.Add("Zebra", 1)
$sortedDict.Add("Apple", 2)
$sortedDict.Add("Banana", 3)
# Keys are automatically sorted: Apple, Banana, Zebra
```

**ObservableCollection:**

```powershell
Add-Type -AssemblyName System.ObjectModel
[System.Collections.ObjectModel.ObservableCollection[string]]$observable = @()

# Add event handler for collection changes
$observable.add_CollectionChanged({
    param($sender, $e)
    Write-Host "Collection changed: $($e.Action)"
})

$observable.Add("Item1")  # Triggers event
```

**ConcurrentDictionary for Thread Safety:**

```powershell
[System.Collections.Concurrent.ConcurrentDictionary[string,int]]$concurrent = @{}
$concurrent.TryAdd("key1", 100)
$concurrent.AddOrUpdate("key1", 200, {param($key, $oldValue) $oldValue + 100})
```

#### Collection Performance Considerations

Different collection types have varying performance characteristics:

- **ArrayList vs List\<T>:** List\<T> provides better type safety and performance [Inference]
- **Hashtable vs Dictionary<TKey,TValue>:** Dictionary provides better type safety and similar performance [Inference]
- **Array vs List\<T>:** Arrays have fixed size; List\<T> is better for dynamic operations [Inference]

**Example** performance comparison:

```powershell
# Measure array expansion (slow for large datasets)
$array = @()
Measure-Command {
    1..10000 | ForEach-Object { $array += $_ }
}

# Measure List<T> addition (faster)
[System.Collections.Generic.List[int]]$list = @()
Measure-Command {
    1..10000 | ForEach-Object { $list.Add($_) }
}
```

#### Advanced Collection Operations

**LINQ with Collections:**

```powershell
Add-Type -AssemblyName System.Core
[System.Collections.Generic.List[int]]$numbers = @(1,2,3,4,5,6,7,8,9,10)

# Use LINQ methods
$evenNumbers = [System.Linq.Enumerable]::Where($numbers, [Func[int,bool]]{param($x) $x % 2 -eq 0})
$sum = [System.Linq.Enumerable]::Sum($numbers)
$doubled = [System.Linq.Enumerable]::Select($numbers, [Func[int,int]]{param($x) $x * 2})
```

**Collection Conversion:**

```powershell
# Convert between collection types
$hashtable = @{a=1; b=2; c=3}
$dictionary = [System.Collections.Generic.Dictionary[string,int]]::new($hashtable)

$array = @(1,2,3,4,5)
$list = [System.Collections.Generic.List[int]]::new($array)
$hashset = [System.Collections.Generic.HashSet[int]]::new($array)
```

**Custom Comparers:**

```powershell
# Create custom comparer for case-insensitive dictionary
$comparer = [System.StringComparer]::OrdinalIgnoreCase
[System.Collections.Generic.Dictionary[string,int]]$dict = [System.Collections.Generic.Dictionary[string,int]]::new($comparer)
$dict.Add("KEY", 1)
$dict.Add("key", 2)  # This will overwrite the first entry
```

**Key Points:**

- .NET collections offer specialized functionality beyond basic PowerShell arrays
- Consider thread safety requirements when choosing collection types
- Performance characteristics vary significantly between collection types
- LINQ methods can be used with .NET collections for advanced queries

**Conclusion**

Advanced collections in PowerShell provide powerful data management capabilities beyond basic arrays and hash tables. Generic collections offer type safety and performance benefits, custom objects enable structured data representation, and .NET collections provide specialized functionality for complex scenarios. Understanding when and how to use these different collection types is crucial for writing efficient and maintainable PowerShell scripts.

For complex data manipulation scenarios, consider exploring System.Data.DataTable, System.Collections.Immutable collections, and custom collection classes that implement IEnumerable\<T>.

---

