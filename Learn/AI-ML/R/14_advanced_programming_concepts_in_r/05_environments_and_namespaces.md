## Environments and Namespaces


Environments are fundamental to R's scoping rules and function evaluation, while namespaces organize code and prevent naming conflicts.

**Understanding Environments**

```r
# Current environment
environment()

# Parent environment
parent.env(environment())

# Global environment
.GlobalEnv

# Create new environment
my_env <- new.env()
my_env$x <- 10
my_env$y <- 20

# List objects in environment
ls(envir = my_env)
```

**Environment Hierarchy** R maintains a hierarchy of environments:

1. Current/Local environment
2. Enclosing environments
3. Global environment
4. Package environments
5. Base environment
6. Empty environment

**Lexical Scoping**

```r
# Demonstration of lexical scoping
outer_function <- function(x) {
  inner_function <- function(y) {
    return(x + y)  # x comes from enclosing environment
  }
  return(inner_function)
}

add_five <- outer_function(5)
add_five(3)  # Returns 8
```

**Namespaces** Namespaces separate the internal and external interfaces of packages:

- Internal namespace: All objects defined in package
- External namespace: Exported objects available to users

```r
# Access internal functions
stats:::cor.test.default

# Check namespace
getNamespace("stats")
loadedNamespaces()
```

