## PEP 8 Style Guide


PEP 8 is the de facto code style guide for Python, authored by Guido van Rossum, Barry Warsaw, and Nick Coghlan. It provides guidelines to write Python code that is readable and consistent across the wider Python community. Strict adherence to PEP 8 is critical for maintainability in collaborative environments.

### Code Layout

Indentation

Use 4 spaces per indentation level. Do not use tabs. Python 3 disallows mixing the use of tabs and spaces for indentation.

- **Continuation Lines:** Vertical alignment is required for wrapped lines. This can be achieved using Python's implicit line joining inside parentheses, brackets, and braces, or using a hanging indent.
    
- **Hanging Indents:** There should be no arguments on the first line, and further indentation should be used to clearly distinguish itself as a continuation line.
    

Maximum Line Length

Limit all lines to a maximum of 79 characters.

- For flowing long blocks of text with fewer structural restrictions (docstrings or comments), the line length should be limited to 72 characters.
    
- The preferred way of wrapping long lines is by using Python's implied line continuation inside parentheses, brackets, and braces. Backslashes may still be appropriate at times.
    

**Blank Lines**

- Surround top-level function and class definitions with two blank lines.
    
- Method definitions inside a class are surrounded by a single blank line.
    
- Extra blank lines may be used (sparingly) to separate groups of related functions.
    
- Use blank lines in functions, sparingly, to indicate logical sections.
    

**Imports**

- Imports should usually be on separate lines.
    
- Imports should be grouped in the following order:
    
    1. Standard library imports.
        
    2. Related third-party imports.
        
    3. Local application/library specific imports.
        
- Put a blank line between each group of imports.
    
- **Absolute imports** are recommended, as they are usually more readable and tend to be better behaved (or at least give better error messages) if the import system is incorrectly configured.
    

### String Quotes

In Python, single-quoted strings and double-quoted strings are the same. PEP 8 does not make a recommendation for this. However, the guide mandates that you pick a rule and stick to it. When a string contains single or double quote characters, use the other one to avoid backslashes; this improves readability.12

### Wh3itespace in Expressions and Statements4

**Avoid Extraneous Wh5itespace**

- Immediately inside parentheses, brackets, or braces.
    
- Between a trailing comma and a following close parenthesis.
    
- Immediately before a comma, semicolon, or colon.
    
- Immediately before the open parenthesis that starts the argument list of a function call.
    
- Immediately before the open bracket that starts an indexing or slicing.
    
- More than one space around an assignment (or other) operator to align it with another.
    

**Binary Operators**

- Always surround these binary operators with a single space on either side: assignment (`=`, `+=`, `-=`), comparisons (`==`, `<`, `>`, `!=`, `<>`, `<=`, `>=`, `in`, `is`, `is not`, `and`, `or`, `not`), and Booleans.
    
- If operators with different priorities are used, consider adding whitespace around the operators with the lowest priority(ies). Use your own judgment; however, never use more than one space, and always have the same amount of whitespace on both sides of a binary operator.
    
- Don't use spaces around the `=` sign when used to indicate a keyword argument or a default parameter value.
    

### Comments

Comments that contradict the code are worse than no comments. Always make a priority of keeping the comments up-to-date when the code changes. Comments should be complete sentences. The first word should be capitalized, unless it is an identifier that begins with a lower case letter.

Block Comments

Block comments generally apply to some (or all) code that follows them, and are indented to the same level as that code. Each line of a block comment starts with a # and a single space (unless it is indented text inside the comment).6

Inline Comments7

Use inline comments sparingly. An inline comment is a comment on the same line as a statement. Inline comments should be separated by at least two spaces fr8om the statement. They should start with a # and a single space.

**Documentation Strings (Docstrings)**

- Write docstrings for all public modules, functions, classes, and methods.
    
- Docstrings are not necessary for non-public methods, but you should have a comment that describes what the method does. This comment should appear after the `def` line.
    
- The `"""` that ends a multiline docstring should be on a line by itself.
    
- For one-liner docstrings, keep the closing `"""` on the same line.9
    

### Naming Conventions10

**Naming Styles11**

- `b` (single lowercase letter)12
    
- `B` (single uppercase letter)13
    
- `lowercase`14
    
- `lower_case_with_underscores`15
    
- `UPPER_CASE`16
    
- `CamelCase` (or C17apWords)
    
- `mixedCase` (differs from CamelCase by initial lowercase character)
    
- `_single_leading_underscore`: weak "internal use" indicator.
    
- `single_trailing_underscore_`: used by convention to avoid conflicts with Python keyword.18
    
- `__double_leading_underscore`: when naming a class attribute, invokes name mangling.192021
    
- `__double_leading_and_trailing_underscore__`: "magic" objects or attributes22 (e.g., `__init__`).2324
    

**Prescriptive Naming Conventions2526**

- **Class Names:** Use the CapWords convention.2728
    
- **Except29ion Names:** 30Because exceptions should be classes, the class naming convention applies here. Use the suffix "Error" on your exception names (if the exception actually is an error).
    
- **Function Names:** Function names should be lowercase, with words separated by underscores as necessary to improve readability.
    
- **Method Names and Instance Variables:** Use the function naming rules: lowercase with words separated by underscores as necessary.
    
- **Constants:** Constants are usually defined on a module level and written in all capital letters with underscores separating words.
    

### Programming Recommendations

- Comparisons to singletons like `None` should always be done with `is` or `is not`, never the equality operators.
    
- Use `is not` operator rather than `not ... is`. While both expressions are functionally identical, the former is more readable and preferred.
    
- When implementing ordering operations with rich comparisons (e.g., `__eq__`, `__lt__`), it is best to implement all six operations (`__eq__`, `__ne__`, `__lt__`, `__le__`, `__gt__`, `__ge__`) using the `functools.total_ordering` decorator to minimize effort.31
    
- Use `.startswith()` and `.endswith()` instead of string slicing to check for prefixes or suffixes. `startswith()` and `endswith()` are cleaner and less error prone.32
    
- Object type comparisons should always use `isinstance()` instead of comparing types directly.3334
    
- For sequences, (strings, lists, tuples), use the fact that empty sequences are false: `if not seq:` rather than `if len(seq) == 0:`.3536
    
- Don't compare 37boolean values to `True` or `False` using `==`. Use `if greeting:` instead of `if greeting == True:`.
    

**Key Points**

- **Consistency:** The primary goal of PEP 8 is consistency within a project.
    
- **Readability:** Code is read much more often than it is written.
    
- **Indentation:** 4 spaces, no tabs.
    
- **Line Length:** 79 characters max.
    
- **Naming:** `snake_case` for functions/variables, `CamelCase` for classes, `UPPER_CASE` for constants.
    

**Example**

Python

```
import os
import sys

from my_lib import Object  # Standard library first, then 3rd party

class MyClass(Object):
    """
    A class that demonstrates PEP 8 compliance.
    """

    CONSTANT_VAL = 42

    def __init__(self, name, value=None):
        self.name = name
        # Do not use spaces around = for default args
        self.value = value

    def display_info(self):
        # Use 'is' for None comparison
        if self.value is None:
            print(f"Name: {self.name}, Value: Not Set")
        else:
            print(f"Name: {self.name}, Value: {self.value}")

def calculate_total(a, b):
    # Binary operators get spaces around them
    return a + b

# Top level function call
if __name__ == "__main__":
    obj = MyClass("Test")
    obj.display_info()
```

Next Steps

Configure your IDE or text editor (VS Code, PyCharm) to auto-lint using flake8 or pylint to enforce these standards automatically.

---

