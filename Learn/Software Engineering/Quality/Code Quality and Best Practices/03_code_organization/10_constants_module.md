## Constants module


A Constants Module (or file) acts as a centralized repository for static values, configuration settings, and fixed literals used throughout an application. This practice eliminates "magic numbers" and "magic strings," creating a single source of truth for values that should remain invariant during execution.

**Key Points**

- **Elimination of Magic Values:** "Magic" values are raw numbers or strings embedded directly in logic (e.g., `if (status == 2)`). These obscure meaning and make updates difficult. Replacing them with named constants (e.g., `if (status == STATUS.ACTIVE)`) provides semantic meaning and safeguards against typos.
    
- **Single Source of Truth:** By defining a value in one place, updates (such as changing a standard tax rate or an API endpoint) propagate instantly across the entire application without requiring a "find and replace" hunt.
    
- **Immutability:** Constants should be immutable. In languages that support it, use features like `const`, `final`, `static readonly`, or `Object.freeze()` to prevent accidental runtime modification.
    
- **Categorization:** Large applications should not dump all constants into a single `constants.py` or `Config.java`. Instead, group them logically:
    
    - **Application-wide:** `GLOBAL_TIMEOUT`, `MAX_RETRY_ATTEMPTS`.
        
    - **Domain-specific:** `USER_ROLES`, `ORDER_STATUS`.
        
    - **Environment-specific:** API URLs, database credentials (often loaded via `.env` but referenced via a config module).
        

**Naming Conventions**

- **UPPER_SNAKE_CASE:** The universal standard for constant variables (e.g., `MAX_UPLOAD_SIZE_MB`).
    
- **Prefixing:** Use prefixes to group related constants naturally when sorting alphabetically or using autocomplete (e.g., `COLOR_RED`, `COLOR_BLUE` rather than `RED`, `BLUE`).
    

**Example**

_Bad Practice (Magic Strings/Numbers):_

JavaScript

```
// What does 86400 mean? What is 'admin'?
if (user.role === 'admin' && session.duration < 86400) {
  grantAccess();
}
```

_Good Practice (Centralized Constants):_

JavaScript

```
// constants/auth.js
export const ROLES = Object.freeze({
  ADMIN: 'admin',
  USER: 'user',
  GUEST: 'guest'
});

export const SESSION = Object.freeze({
  MAX_DURATION_SECONDS: 86400, // 24 hours
  TIMEOUT_MS: 3000
});

// usage.js
import { ROLES, SESSION } from './constants/auth';

if (user.role === ROLES.ADMIN && session.duration < SESSION.MAX_DURATION_SECONDS) {
  grantAccess();
}
```

