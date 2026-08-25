## S3 Classes


S3 is R's original and most widely used object system, characterized by its informal structure and dynamic behavior.

**Creating S3 Objects**

```r
# Creating an S3 object
person <- list(name = "John", age = 30, occupation = "Data Scientist")
class(person) <- "Person"

# Constructor function approach
create_person <- function(name, age, occupation) {
  obj <- list(name = name, age = age, occupation = occupation)
  class(obj) <- "Person"
  return(obj)
}
```

**S3 Methods and Generic Functions**

```r
# Define a generic function
summary.Person <- function(object, ...) {
  cat("Name:", object$name, "\n")
  cat("Age:", object$age, "\n")
  cat("Occupation:", object$occupation, "\n")
}

# Print method
print.Person <- function(x, ...) {
  cat("Person: ", x$name, " (", x$age, " years old)\n", sep = "")
}
```

**Method Dispatch in S3** S3 uses function naming conventions (generic.class) to determine which method to call. The system looks for methods in order of class hierarchy.

```r
# Check method dispatch
methods(summary)  # Lists all summary methods
methods(class = "Person")  # Lists all methods for Person class
```

