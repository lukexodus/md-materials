## Basic R Syntax and Operators


**Arithmetic Operators** R supports standard arithmetic operations: addition (+), subtraction (-), multiplication (*), division (\/), integer division (%/%), modulus (\%\%), and exponentiation (^ or **). Operations follow mathematical precedence rules, with parentheses for explicit grouping.

**Comparison Operators** Logical comparisons include equal (\=\=), not equal (!=), less than (<), greater than (>), less than or equal (<=), and greater than or equal (>=). These return logical values (TRUE/FALSE) and work element-wise on vectors.

**Logical Operators** Logical AND (&), OR (|), and NOT (!) operate element-wise on vectors. Double operators (&& and ||) evaluate only the first element, commonly used in control flow statements. The %in% operator tests membership in vectors or lists.

**Assignment Operators** Primary assignment uses <- (preferred) or = for creating objects. Right assignment (->) assigns values in reverse direction. Global assignment (<<-) creates variables in parent environments, though rarely recommended for general use.

**Special Values** R includes special values: NULL (empty object), NA (missing value), NaN (not a number), Inf (infinity), and -Inf (negative infinity). These values require specific handling functions like is.null(), is.na(), and is.finite().

**Operator Precedence** Operator precedence follows mathematical conventions: parentheses, exponentiation, multiplication/division, addition/subtraction, comparisons, logical operators. When in doubt, use parentheses for clarity.

