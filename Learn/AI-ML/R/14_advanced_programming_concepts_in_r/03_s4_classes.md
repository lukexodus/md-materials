## S4 Classes


S4 provides a more formal object system with explicit class definitions, slot validation, and stricter method dispatch.

**Defining S4 Classes**

```r
# Define S4 class with slots
setClass("Employee",
  slots = list(
    name = "character",
    age = "numeric",
    department = "character",
    salary = "numeric"
  ),
  validity = function(object) {
    if (object@age < 0) return("Age must be positive")
    if (object@salary < 0) return("Salary must be positive")
    return(TRUE)
  }
)

# Create S4 object
emp <- new("Employee", 
           name = "Alice", 
           age = 28, 
           department = "Engineering", 
           salary = 75000)
```

**S4 Methods**

```r
# Define S4 method
setMethod("show", "Employee", function(object) {
  cat("Employee:", object@name, "\n")
  cat("Department:", object@department, "\n")
  cat("Salary: $", object@salary, "\n")
})

# Generic function for S4
setGeneric("promote", function(x, increase) standardGeneric("promote"))

setMethod("promote", "Employee", function(x, increase) {
  x@salary <- x@salary + increase
  return(x)
})
```

**S4 Inheritance**

```r
# Define subclass
setClass("Manager",
  contains = "Employee",
  slots = list(
    team_size = "numeric",
    budget = "numeric"
  )
)
```

