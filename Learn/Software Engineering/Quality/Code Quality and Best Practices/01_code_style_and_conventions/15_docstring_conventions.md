## Docstring Conventions


Docstrings (documentation strings) are the standard method for documenting modules, classes, functions, and methods in Python. Adherence to established conventions ensures consistency, readability, and compatibility with documentation generation tools like Sphinx or pdoc. The primary authority on docstring conventions is PEP 257.

**Key Points**

- **Placement:** A docstring must be the first statement in the object's definition (module, function, class, or method). It is accessible via the `__doc__` attribute.
    
- **Quotes:** Always use triple double quotes (`"""`) even if the string fits on a single line. This prevents issues when expanding the docstring later.
    
- **One-line Docstrings:** Used for obvious cases. The opening and closing quotes are on the same line. There should be no blank line before or after the docstring text within the quotes.
    
- **Multi-line Docstrings:** Consist of a summary line, followed by a blank line, and then a more detailed description. The closing quotes should be on a separate line.
    
- **Imperative Mood:** For functions and methods, the summary line should prescribe the function's effect as a command (e.g., "Do this," "Return that"), not as a description (e.g., "Does this," "Returns that").
    
- **Blank Lines:**
    
    - Insert a blank line after all docstrings that document a class or function.
        
    - Within the docstring, use blank lines to separate the summary from the description and to separate logical paragraphs.
        

**Example**

Python

```
def calculate_area(radius):
    """Calculate the area of a circle.

    This function assumes a perfect circle and uses the standard
    value of pi.

    """
    return 3.14 * radius ** 2
```

---

