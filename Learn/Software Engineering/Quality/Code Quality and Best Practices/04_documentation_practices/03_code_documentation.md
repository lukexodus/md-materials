## Code documentation


Code documentation refers to the written text accompanying computer software source code. It ranges from inline comments within functions to comprehensive API references generated from the code itself. Effective documentation bridges the gap between the rigid logic of the machine and the intent of the developer.

**Key Points**

- **"Why", not "What":** The code itself demonstrates _what_ is being done (e.g., `i++`). Documentation should explain _why_ it is being done (e.g., "Incrementing retry counter to handle intermittent network failure"). Comments that duplicate the code are noise.
    
- **Public Interfaces vs. Private Implementation:** Public APIs require rigorous documentation (contracts, parameters, return values, exceptions) because consumers cannot easily see the implementation. Private methods generally require less documentation if the code is self-explanatory.
    
- **The "Stale" Risk:** Incorrect documentation is significantly worse than no documentation. It misleads developers and causes bugs. If code changes, documentation _must_ be updated immediately; otherwise, it should be deleted.
    
- **Standard Formats:** Use standard documentation generators (Javadoc for Java, JSDoc for JavaScript, Docstrings for Python, GoDoc for Go). These allow IDEs to display tooltips and can generate static HTML references.
    
- **Annotation over Explanation:** Use standard annotations (e.g., `@Deprecated`, `@Override`, `@ThreadSafe`) to communicate behavior and constraints programmatically rather than relying solely on free-text comments.
    

**Example**

_Bad Practice_

Python

```
# Function to get user
def get_user(id):
    # Check if id is valid
    if id < 0:
        return None
    # Return the user from db
    return db.find(id)
```

_Good Practice_

Python

```
def get_user(user_id):
    """
    Retrieves a user by their unique identifier.

    Args:
        user_id (int): The positive integer ID of the user.

    Returns:
        User: The user object if found.
        None: If the ID is invalid or the user does not exist.
    """
    if user_id < 0:
        return None
    
    return db.find(user_id) # Direct call, no comment needed
```

