## Code formatting


Code formatting refers to the algorithmic application of style rules to source code, ensuring a consistent visual structure regardless of the author. It decouples the act of writing code from the visual presentation, prioritizing readability and maintainability.

**Key Points**

- **Consistency over Preference:** The primary goal of formatting is uniformity. A consistent codebase reduces cognitive load, allowing developers to focus on logic rather than style discrepancies.
    
- **Automated Tooling:** Modern development relies on automated formatters (e.g., Prettier, Black, gofmt, clang-format) rather than manual styling. These tools enforce a strict set of rules, often integrated into the IDE "on save" or via CI/CD pipelines to prevent unformatted code from entering the repository.
    
- **Syntactic vs. Stylistic:** Formatting handles stylistic concerns (spacing, line breaks) without altering the Abstract Syntax Tree (AST) or the runtime behavior of the code.
    
- **Diff Reduction:** Consistent formatting minimizes "noisy" diffs in version control. Changes reflect actual logic modifications rather than arbitrary whitespace adjustments.
    

**Implementation Strategies**

1. **Project-Level Configuration:** Use configuration files (e.g., `.prettierrc`, `pyproject.toml`) committed to the repository to enforce rules across the entire team.
    
2. **EditorConfig:** Implement an `.editorconfig` file to define coding styles (indentation, charset, end-of-line) universally across different editors and IDEs.
    
3. **Pre-commit Hooks:** Use tools like Husky or pre-commit to run formatters automatically before code is committed, ensuring the repository remains clean.
    

**Example**

_Unformatted Input (JavaScript):_

JavaScript

```
function  calculateTotal( price,tax){ let total=price+ (price*tax);
return total;}
```

_Formatted Output:_

JavaScript

```
function calculateTotal(price, tax) {
  let total = price + price * tax;
  return total;
}
```

