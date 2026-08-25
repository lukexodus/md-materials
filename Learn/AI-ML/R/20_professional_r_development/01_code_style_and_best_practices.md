## Code Style and Best Practices


Consistent code style improves readability, reduces cognitive load, and minimizes errors across development teams. The tidyverse style guide provides widely-adopted conventions for R programming, though organizations may develop custom standards based on specific requirements.

**Key points:**

- Variable and function names use snake_case convention
- Line length limited to 80 characters for readability
- Consistent indentation (typically 2 spaces) throughout code
- Meaningful variable names that describe content and purpose
- Function definitions include clear parameter documentation

The `styler` package automatically formats code according to established conventions, while `lintr` identifies style violations and potential code issues. These tools integrate with IDEs to provide real-time feedback during development. Pre-commit hooks can enforce style standards before code enters version control.

Naming conventions should distinguish between different object types: functions use verbs, variables use nouns, and constants use SCREAMING_SNAKE_CASE. File names should be descriptive and use consistent patterns, such as prefixes for different script types (e.g., `01_data_import.R`, `02_data_cleaning.R`).

Code organization within files follows logical structures: library imports at the top, function definitions before their usage, and clear separation between different functional sections. Comments explain the "why" rather than the "what" of code operations, providing context for future maintainers.

