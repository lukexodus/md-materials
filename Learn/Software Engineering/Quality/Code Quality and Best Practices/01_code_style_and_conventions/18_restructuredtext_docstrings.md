## reStructuredText Docstrings


reStructuredText (reST) is the default markup language used by Sphinx. While it is the most "native" format for Python documentation generation, the raw strings are often considered less readable than Google or NumPy styles due to the heavy use of markup tags.

**Key Points**

- **Field Lists:** Relies heavily on "fields" marked by colons, such as `:param name:`, `:type name:`, `:return:`, and `:rtype:`.
    
- **Formatting:** Supports rich text formatting within the descriptions (bold, italics, code blocks) using standard reST syntax.
    
- **Linking:** Allows easy cross-referencing to other classes or modules using roles like `:class:`, `:func:`, or `:mod:`.
    
- **Verbosity:** Requires separate lines for parameter descriptions and parameter types, which can clutter the visual flow of the code.
    

**Structure**

- `:param <name>:` Description of the parameter.
    
- `:type <name>:` The type of the parameter.
    
- `:return:` Description of the return value.
    
- `:rtype:` The type of the return value.
    
- `:raises <ExceptionType>:` Description of errors raised.
    

**Example**

Python

```
def send_email(recipient, subject, body):
    """
    Sends an email to the specified recipient.

    :param recipient: The email address of the receiver.
    :type recipient: str
    :param subject: The subject line of the email.
    :type subject: str
    :param body: The main content of the email.
    :type body: str
    :return: True if the email was sent successfully, False otherwise.
    :rtype: bool
    :raises ValueError: If the recipient address is invalid.
    """
    pass
```

---

