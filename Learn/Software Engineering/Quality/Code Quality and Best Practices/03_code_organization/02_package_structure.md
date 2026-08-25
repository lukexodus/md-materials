## Package Structure


Package structure refers to the macro-level organization of the codebase—how files and directories are arranged. The structure should communicate the intent of the system (Screaming Architecture) rather than just the framework tools being used.

**Key Points**

- **Group by Feature vs. Group by Type:**
    
    - _Group by Type (Layered):_ Separating files into `controllers/`, `models/`, `views/`. This works for small projects but scales poorly; changing a feature requires jumping between multiple folders.
        
    - _Group by Feature (Domain-Driven):_ Grouping files by the business domain (e.g., `orders/`, `users/`, `inventory/`). This keeps related code co-located (colocation), making it easier to modify, delete, or extract a feature into a microservice later.
        
- **The Barrel Pattern (Index Files):** Use `index` files (or `mod.rs`, `package-info.java`) at the root of a package directory to export the public API of that package. This allows consumers to import from the package root rather than specific internal files, decoupling the internal file structure from the external usage.
    
- **dependency Rule:** Dependencies should point inward or strictly between distinct layers. A high-level domain package should not depend on a low-level infrastructure package (like a specific HTTP client) directly; it should depend on an abstraction.
    
- **Test Colocation:** Place unit tests adjacent to the source file (e.g., `UserService.ts` and `UserService.test.ts`) rather than in a mirrored `tests/` directory tree. This increases visibility and ensures tests are updated when files are moved.
    

**Example**

_Layered Structure (Discouraged for complex systems):_

Plaintext

```
src/
├── controllers/
│   ├── UserController.ts
│   └── OrderController.ts
├── models/
│   ├── User.ts
│   └── Order.ts
└── services/
    ├── UserService.ts
    └── OrderService.ts
```

_Feature-Based Structure (Recommended):_

Plaintext

```
src/
├── users/
│   ├── index.ts           // Exports UserService and User type only
│   ├── UsersController.ts
│   ├── UserService.ts
│   ├── User.ts
│   └── __tests__/         // Or colocated files
├── orders/
│   ├── index.ts
│   ├── OrdersController.ts
│   └── OrderRepository.ts
└── shared/                // Utilities used across multiple features
    ├── logger.ts
    └── dates.ts
```

**Conclusion**

A feature-based package structure aligns the codebase with the business domain, reducing cognitive load when navigating the project. It enforces boundaries effectively when combined with strict import rules (e.g., forbidding imports from a sibling feature's internal files).

**Next Steps**

Evaluate the root directory of your project. If it primarily lists technical layers (components, hooks, utils), propose a migration plan to move files into domain-specific folders (auth, checkout, dashboard) to improve modularity.

---

