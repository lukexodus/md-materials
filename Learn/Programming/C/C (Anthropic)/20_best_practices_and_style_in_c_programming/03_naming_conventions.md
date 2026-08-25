## Naming Conventions


**Variable Naming** Variable names should clearly indicate purpose and scope. Local variables can use shorter names when context is clear, while global variables and function parameters should use descriptive names. Common conventions include using lowercase with underscores (`my_variable`) or camelCase (`myVariable`), though consistency within a project is more important than the specific convention chosen.

**Function Naming** Function names should use verbs that clearly describe the operation performed. Functions that return boolean values often use `is_`, `has_`, or `can_` prefixes. Functions that modify state should indicate this through naming, while functions that only read data can use names that suggest querying or getting information.

**Constant and Macro Naming** Constants and macros traditionally use uppercase letters with underscores (`MAX_BUFFER_SIZE`). Enum constants may follow this convention or use a consistent prefix to indicate their enumeration membership. Macro names should clearly indicate their macro nature to prevent confusion with regular functions.

**Type Naming** Custom types benefit from descriptive names that indicate their purpose and usage. Many C codebases use suffixes like `_t` for typedef names (`user_account_t`) or prefixes that indicate the module or subsystem where the type is defined. Struct and enum names should be meaningful and avoid abbreviations that might be unclear.

