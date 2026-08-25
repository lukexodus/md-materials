## User-facing Errors


### Security via Opacity

User-facing errors must never reveal infrastructure details, stack traces, or database schema information.

- **The Opaque Token Pattern:** When a system error occurs (500 Internal Server Error), display a generic message to the user: _"Something went wrong. Reference ID: [UUID]"_.
    
- **Internal Mapping:** The `[UUID]` corresponds to a specific entry in the secure server logs containing the full stack trace and details. This allows support staff to look up the specific error without exposing vulnerabilities to the end-user.
    

### Constructive and Non-Blaming UX

Error messages must be actionable and avoid technical jargon.

- **Actionability:** Every user error must propose a solution.
    
    - _Bad:_ "Validation Failed."
        
    - _Good:_ "The date format is incorrect. Please use YYYY-MM-DD."
        
- **State Preservation:** Errors triggered by form submission must **never** clear the user's input. The UI must retain the state to allow correction without reentry.
    
- **Heuristic Auto-Correction:** Where possible, accept ambiguous input and normalize it rather than erroring (e.g., stripping whitespace from phone numbers or auto-formatting credit card inputs) to reduce error friction.
    

