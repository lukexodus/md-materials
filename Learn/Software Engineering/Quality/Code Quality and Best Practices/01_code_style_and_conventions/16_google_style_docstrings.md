## Google Style Docstrings


Google style is widely adopted because it balances machine parsability with high human readability. It avoids the verbose markup of reStructuredText, making the source code easier to read directly. It is fully supported by the Napoleon extension for Sphinx.

**Key Points**

- **Section Headers:** Use specific headers like `Args:`, `Returns:`, `Raises:`, and `Attributes:` followed by a colon.
    
- **Indentation:** The content of a section must be indented relative to the section header.
    
- **Type Hinting:** Types can be specified in the docstring, though modern practices often prefer Type Hints in the function signature (PEP 484). If included in the docstring, they typically follow the argument name in parentheses.
    
- **Optional Arguments:** Optional arguments are denoted, often with their default values.
    

**Structure**

- **Args:** Lists parameters.
    
- **Returns:** (or **Yields** for generators): Describes the return value.
    
- **Raises:** Lists all exceptions that are relevant to the interface.
    
- **Attributes:** Used in class docstrings to document public attributes.
    

**Example**

Python

```
def fetch_user_data(user_id, include_history=False):
    """Fetches a user's profile and optional activity history.

    Args:
        user_id (int): The unique identifier of the user.
        include_history (bool, optional): Whether to include the user's
            login history in the response. Defaults to False.

    Returns:
        dict: A dictionary containing user details. Keys include 'id',
        'username', and optionally 'history'.

    Raises:
        ValueError: If user_id is negative.
        ConnectionError: If the database is unreachable.
    """
    pass
```

---

