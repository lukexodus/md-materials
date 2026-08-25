## Aliases


`typedef` and `using` are both C++ language features used to create aliases for existing data types, making code more readable, maintainable, and portable. 
### typedef

`typedef` is a keyword used to create an alias for an existing data type. It's particularly useful for defining custom names for complex data types or for making code more readable by providing descriptive aliases.

**Syntax:**
```cpp
typedef existing_type new_name;
```

**Example:**
```cpp
typedef int Int32; // Defines Int32 as an alias for int
typedef double Real; // Defines Real as an alias for double
```

### using

`using` is a newer C++ keyword which also creates aliases for existing data types. It offers some advantages over `typedef`, such as improved syntax for template aliases and compatibility with type inference.

**Syntax:**
```cpp
using new_name = existing_type;
```

**Example:**
```cpp
using Int32 = int; // Defines Int32 as an alias for int
using Real = double; // Defines Real as an alias for double
```

***

