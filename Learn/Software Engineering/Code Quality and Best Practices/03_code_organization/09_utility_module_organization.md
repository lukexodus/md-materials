## Utility Module Organization


Utility modules house shared, reusable logic that does not belong to a specific core domain entity. Poor organization here leads to "God objects" or "Junk Drawers"—massive files named `utils.js` or `common.py` containing thousands of unrelated functions, creating tight coupling and circular dependencies.

**Key Points**

- **Categorization over Generalization:** Avoid generic filenames like `utils`, `common`, or `helpers` unless the project is extremely small. Instead, organize utilities by domain: `string_utils`, `date_helpers`, `file_system`, `math_ops`.
    
- **Statelessness (Pure Functions):** Utility functions should generally be "pure"—output is determined solely by input, with no side effects (no modifying global state, no database writes). This makes them easy to test and safe to import anywhere.
    
- **Dependency Minimization:** Utility modules should have zero or minimal dependencies on the core application. They should sit at the bottom of the dependency graph. If `string_utils` imports `UserContext`, you have created a circular dependency risk.
    
- **Single Responsibility:** If a utility file grows beyond a manageable size (e.g., >300 lines), it suggests it is handling too many responsibilities. Split it. A `formatters` module can be split into `date_formatter` and `currency_formatter`.
    
- **Namespace Grouping:** In languages that support it, group utilities under a namespace or a static class to prevent polluting the global namespace. E.g., `FileUtils.read()` rather than just `read()`.
    

**Example**

**Poor Structure (The "Junk Drawer"):**

Plaintext

```
/src
  /utils
    common.js  <-- Contains date formatting, regex, API fetchers, and math logic.
```

**Better Structure (Domain Separation):**

Plaintext

```
/src
  /utils
    /formatting
      currency.js
      dates.js
    /validation
      email.js
      password.js
    /io
      file_system.js
```

---

