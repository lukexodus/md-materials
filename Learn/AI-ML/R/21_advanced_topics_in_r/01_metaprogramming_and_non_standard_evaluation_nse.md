## Metaprogramming and Non-Standard Evaluation (NSE)


Metaprogramming in R enables code that manipulates, generates, or analyzes other code as data, while Non-Standard Evaluation allows functions to capture and manipulate expressions before they are evaluated, creating more intuitive user interfaces.

**Key points:**

- NSE captures unevaluated expressions, enabling domain-specific syntax patterns
- Quote and unquote mechanisms control when expressions are evaluated
- Tidy evaluation provides a principled framework for NSE in modern R packages
- Understanding expression objects and environments is fundamental to metaprogramming

Non-Standard Evaluation allows functions to access the actual expressions passed as arguments rather than their evaluated results. Base R functions like `subset()`, `with()`, and `library()` demonstrate NSE by accepting unquoted column names or package names. This creates more natural syntax but requires careful implementation to avoid scoping issues.

The `substitute()` function captures unevaluated expressions, returning them as language objects that can be manipulated or evaluated later. Combined with `eval()`, this enables functions to modify expressions before evaluation. The `deparse()` function converts expressions back to character strings for inspection or modification.

Quoting mechanisms include `quote()` for capturing expressions without evaluation, `bquote()` for partial evaluation using `.()` syntax, and `enquote()` for programmatic quoting. These functions create language objects that represent R code as data structures that can be analyzed and modified.

Expression objects are structured as nested lists where each element represents a function call, symbol, or literal value. The `str()` function reveals expression structure, while functions like `as.list()` and `[[]]` enable programmatic manipulation of expression components.

Environment manipulation is crucial for correct NSE implementation. The `parent.frame()` function accesses the calling environment where variables should be evaluated. Functions like `get()`, `exists()`, and `assign()` provide programmatic access to variables in specific environments.

Tidy evaluation, implemented in the `rlang` package, provides a modern framework for NSE that addresses many traditional pitfalls. The `enquo()` function captures arguments as quosures (quoted expressions with associated environments), while `!!` (bang-bang) operator enables unquoting for programmatic generation of expressions.

Data masking, used in `dplyr` and similar packages, allows column names to be used as variables within function calls. This creates intuitive syntax like `filter(data, column > 5)` but requires careful handling of scoping conflicts between data variables and environment variables.

