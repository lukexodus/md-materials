## Class Naming


Classes define objects and blueprints. They should be named using nouns or noun phrases that describe the entity or the responsibility of the object.

**Key Points**

- **PascalCase:** Most languages (Java, C#, Python, TypeScript) use PascalCase (UpperCamelCase) for classes.
    
- **Avoid Noise Words:** Avoid suffixes like `Info`, `Data`, or `Manager` if they add no specific meaning. `CustomerInfo` is rarely distinct from `Customer`.
    
- **Specific vs. Generic:** Be specific. `AddressParser` is better than `Parser`. `WikiPage` is better than `Page` if the context is a wiki system.
    
- **Design Patterns:** If a class strictly implements a design pattern, it is acceptable to include it in the name (e.g., `UserFactory`, `PaymentObserver`, `RequestAdapter`).
    

**Example**

- **Poor:** `MyFunctions`, `Utility`, `DoStuff`
    
- **Better:** `CustomerRepository`, `WikiPageScraper`, `EmailValidator`
    

---

