## Error Messages


### Canonical Error Definitions

Ad hoc string creation leads to inconsistent terminology and drift. Errors must be defined as immutable constants or types.

- **Centralized Registry:** Maintain a centralized repository (e.g., `errors.yaml` or a dedicated enum class) for all application errors. This registry dictates the Error Code, HTTP Status (if applicable), and the internal message template.
    
- **Immutability:** Error definitions must be immutable. Dynamic context (e.g., "File X not found") is injected at runtime into a template, but the core semantic meaning and code remain static.
    

### Internationalization (i18n) Strategy

Decouple the internal error representation from the display language.

- **Late Binding:** The backend should return a machine-readable error code (e.g., `AUTH_INVALID_CREDENTIALS`). The translation to a human-readable string (e.g., "Incorrect password" in English or Spanish) should occur at the **presentation layer** (Frontend/Mobile App) based on the user's locale settings. This reduces backend complexity and payload size.
    
- **Fallback Content:** Provide a default English message in the API response strictly for developer debugging, but ensure the UI client prefers its local translation table keyed by the Error Code.
    

