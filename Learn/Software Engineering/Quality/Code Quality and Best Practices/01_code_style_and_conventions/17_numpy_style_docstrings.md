## NumPy Style Docstrings


The NumPy style is the standard for scientific Python libraries (NumPy, SciPy, pandas). It is verbose and highly structured, designed to handle complex functions with many parameters and detailed mathematical explanations. Like Google style, it is supported by Sphinx via the Napoleon extension.

**Key Points**

- **Section Headers:** Headers are underlined with dashes (e.g., `Parameters`, `-------`) rather than using colons.
    
- **Vertical Spacing:** It uses more vertical space than Google style, making it distinct and easy to scan for complex data structures.
    
- **Type Specifications:** Types are placed on the same line as the parameter name, separated by a colon, but without parentheses.
    
- **Extended Sections:** Frequently includes `See Also`, `Notes` (for mathematical implementation details), and `References`.
    

**Structure**

- **Parameters:** Description of arguments.
    
- **Returns:** Description of output.
    
- **See Also:** Links to related functions.
    
- **Notes:** Mathematical algorithms or implementation details.
    
- **Examples:** Usage examples formatted as doctests.
    

**Example**

Python

```
def normalize_vector(v, method='l2'):
    """
    Normalize a vector using the specified norm.

    Parameters
    ----------
    v : array_like
        Input vector to be normalized.
    method : {'l1', 'l2', 'max'}, optional
        The norm to use. 'l2' is the Euclidean norm.
        Default is 'l2'.

    Returns
    -------
    ndarray
        The normalized vector.

    See Also
    --------
    scipy.linalg.norm : Computes the norm of a matrix or vector.

    Notes
    -----
    The L2 norm is defined as $\sqrt{\sum |x_i|^2}$.
    """
    pass
```

---

