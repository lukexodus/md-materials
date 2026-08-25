## Variables and Assignment


**Object Assignment** Variables in R are objects that store data values. Assignment creates a binding between a name and a value in memory. The preferred assignment operator is <-, though = works equivalently in most contexts. Variable names must start with letters or dots, followed by letters, numbers, dots, or underscores.

**Naming Conventions** Valid variable names cannot start with numbers or special characters (except dots). Reserved words like TRUE, FALSE, NULL, if, for, and function names cannot be used as variable names. R is case-sensitive, so myVariable and myvariable are different objects.

**Object Types** R creates objects of different types automatically based on assigned values. Basic types include numeric (real numbers), integer (whole numbers with L suffix), character (text strings), logical (TRUE/FALSE), and complex (numbers with imaginary components).

**Environment and Scope** Variables exist within environments that define their scope and accessibility. The global environment contains user-created objects, while function environments create temporary local scopes. Understanding scope prevents naming conflicts and unintended variable access.

**Memory Management** R manages memory automatically through garbage collection, removing unreferenced objects. Large objects should be explicitly removed using rm() to free memory. The ls() function lists current workspace objects, while objects() provides detailed object information.

**Variable Inspection** Functions for examining variables include class() (object type), str() (structure), summary() (statistical summary), head() and tail() (first/last elements), and length() (number of elements).

