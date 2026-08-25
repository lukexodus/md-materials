## Reference documentation


Reference documentation is technical descriptions of the code's machinery, functioning as a map for the codebase. It is strictly information-oriented, designed to serve users who need to know exactly how to use a specific function, class, or API endpoint without needing to understand the broader context or narrative. It is rigorous, complete, and often austere.

**Key Points**

- **Completeness over Narrative:** Reference documentation must cover every public interface, parameter, return type, and thrown exception. Omissions here are critical failures. It does not guide the user; it describes the facts.
    
- **Standardization and Structure:** Because users scan reference docs rather than reading them linearly, consistent formatting is mandatory. Every entry should follow the exact same layout (e.g., Description -> Parameters -> Return Value -> Errors).
    
- **Automation:** To maintain accuracy, reference documentation should be generated from the source code whenever possible (e.g., Swagger/OpenAPI for REST APIs, Javadoc for Java, TypeDoc for TypeScript). Manual maintenance almost inevitably leads to drift between the code and the docs.
    
- **Type Fidelity:** Precisely define data types. Ambiguities like "object" or "string" are insufficient; specify the shape of the object or the format of the string (e.g., ISO 8601 date).
    

**Example**

A standard reference entry for a utility function avoids discussing _why_ the function exists and focuses entirely on _how_ it behaves.

_Poor Reference:_

> "Calculates the total price. It adds tax too."

_Comprehensive Reference:_

> **`calculateTotal(subtotal, taxRate)`**
> 
> Calculates the final transaction amount including tax.
> 
> - **Parameters:**
>     
>     - `subtotal` (Decimal): The pre-tax amount. Must be non-negative.
>         
>     - `taxRate` (Float): The tax percentage expressed as a decimal (e.g., 0.15 for 15%).
>         
> - **Returns:**
>     
>     - (Decimal): The computed total rounded to two decimal places.
>         
> - **Throws:**
>     
>     - `InvalidInputError`: If `subtotal` < 0.
>         

**Conclusion**

High-quality reference documentation eliminates the need for developers to read the source code of a library to understand its inputs and outputs. It serves as the authoritative source of truth for the codebase's capabilities.

**Next Steps**

Implement an automated documentation generator (like Doxygen, Sphinx, or Swagger) in your CI/CD pipeline to fail the build if public API changes are undetected or undocumented.

