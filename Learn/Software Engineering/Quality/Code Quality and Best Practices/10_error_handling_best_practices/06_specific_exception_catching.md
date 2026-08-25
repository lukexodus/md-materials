## **Specific Exception Catching**


Catching exceptions should be as granular as possible. You should anticipate specific errors and handle only those.

- **Polymorphism in Exceptions:** Most languages organize exceptions in a hierarchy. Catching a specific exception (e.g., `FileNotFoundError`) is safer than catching its parent (`IOError`), which is safer than catching the root (`Exception`).
    
- **Intentionality:** Specific catching demonstrates that you foresaw a specific failure mode (e.g., a file might be missing) and have a plan for it.
    
- **Masking Logic Errors:** If you catch a general `Exception` when you only meant to handle a `KeyError`, you might accidentally mask a `NameError` (typo in variable name) or `ZeroDivisionError` inside your `try` block.
    

**Example (Python):**

Python

```
# GOOD: Specific catching
try:
    data = read_config_file()
    value = data['timeout']
except FileNotFoundError:
    print("Config file missing. Using defaults.")
    value = 30
except KeyError:
    print("Key 'timeout' missing in config. Using defaults.")
    value = 30

# BAD: General catching masks unrelated errors
try:
    data = read_config_file()
    valeu = data['timeout'] # TYPO: 'valeu' instead of 'value'
except Exception:
    # This block catches the NameError caused by the typo!
    # The developer will never know their code is buggy.
    print("Something went wrong.")
```

---

