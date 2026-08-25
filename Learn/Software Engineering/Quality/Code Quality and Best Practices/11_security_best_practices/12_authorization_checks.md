## Authorization Checks


Effective authorization implementation requires a defense-in-depth approach, moving beyond simple role checks to granular, context-aware enforcement mechanisms. High-quality code decouples authorization logic from business logic to ensure maintainability, auditability, and consistent enforcement across distributed systems.

### Architectural Models and Granularity

Selecting the correct authorization model dictates the complexity and flexibility of the codebase.

- **Role-Based Access Control (RBAC):** Suitable for coarse-grained access (e.g., `Admin`, `User`). Often implemented via bitmasks or database lookup tables. Inadequate for complex domain logic where ownership matters.
    
- **Attribute-Based Access Control (ABAC):** Evaluates attributes of the subject (user), resource (data), action (verb), and environment (time/location). This allows for dynamic policies (e.g., "Managers can approve expenses only below $5000 during business hours").
    
- **Relationship-Based Access Control (ReBAC):** crucial for social graphs or hierarchical data (e.g., Google Zanzibar model). Authorization is derived from the graph relationship between the subject and the object (e.g., "User is a `member` of `Group X` which `owns` `Document Y`").
    

### Enforcement Layers

Authorization code must exist at multiple layers to prevent "confused deputy" attacks and ensure data integrity.

#### 1. The Gateway / Interface Layer (Vertical Authorization)

This layer acts as the first line of defense, filtering requests based on high-level scopes or roles.

- **Implementation:** Middleware or Interceptors.
    
- **Responsibility:** Validate that the identity token (JWT) contains the necessary scopes (e.g., `read:reports`) to access the endpoint.
    
- **Limitation:** Cannot assess data ownership or specific business rules.
    

#### 2. The Domain / Service Layer (Horizontal Authorization)

The critical layer for preventing Broken Object Level Authorization (BOLA) and Insecure Direct Object References (IDOR).

- **Implementation:** AOP (Aspect-Oriented Programming) annotations, Decorators, or explicit service calls.
    
- **Responsibility:** Verify that the _specific_ user has rights to the _specific_ resource ID requested.
    
- **Code Quality Standard:** Never blindly trust an ID passed in the URL or body. Always cross-reference the ID with the authenticated user's context.
    

C#

```
// Anti-Pattern: Trusting client input for ownership
public void UpdateProfile(int targetUserId, ProfileDto data) {
    // SECURITY RISK: No check if CurrentUser == targetUserId
    _repo.Update(targetUserId, data); 
}

// Best Practice: Context-aware verification
public void UpdateProfile(int targetUserId, ProfileDto data) {
    var requester = _context.CurrentUser;
    
    // Explicit Horizontal Check
    if (requester.Id != targetUserId && !requester.HasPermission("users.write_any")) {
        throw new ForbiddenException("Insufficient privileges to modify this profile.");
    }
    
    _repo.Update(targetUserId, data);
}
```

#### 3. The Data Layer (Row-Level Security)

As a fail-safe, the database itself should enforce visibility rules.

- **Technique:** PostgreSQL Row-Level Security (RLS) or similar database features.
    
- **Benefit:** Even if the application code fails to filter a query correctly, the database session ensures the user only retrieves rows they are authorized to see.
    

### Decoupling Policy: Policy as Code

Hardcoding complex authorization rules (complex `if/else` blocks) inside business logic violates the Single Responsibility Principle and makes auditing difficult.

- **Externalize Logic:** Use engines like **Open Policy Agent (OPA)** (Rego language). The application queries the policy engine with inputs (Subject, Action, Resource), and the engine returns a decision (`Allow`/`Deny`).
    
- **Internal Abstraction:** If not using OPA, encapsulate rules in distinct `Policy` or `Voter` classes (e.g., Symfony Voters or ASP.NET Authorization Handlers).
    

TypeScript

```
// Example: Decoupled Policy Handler (Pseudo-code)
class DocumentEditPolicy implements Policy {
    isSatisfiedBy(user: User, resource: Document): boolean {
        if (user.isSuperAdmin) return true;
        if (resource.isArchived) return false; // Business rule
        return resource.ownerId === user.id;   // Ownership rule
    }
}

// Usage in Controller
if (!policyService.evaluate(CurrentUser, targetDocument, 'EDIT')) {
    throw new AuthorizationException();
}
```

### Common Anti-Patterns and Risks

1. Fail-Open Logic:
    
    Authorization checks must be "Deny by Default." If an error occurs during the permission check (e.g., database timeout fetching roles), the system must reject the request, not allow it.
    
    - _Bad:_ `if (error) return true;`
        
    - _Good:_ `if (error) throw new AuthorizationException();`
        
2. Time-of-Check to Time-of-Use (TOCTOU):
    
    A race condition where permissions change between the check and the execution.
    
    - _Mitigation:_ Use database transactions with appropriate isolation levels or optimistic locking to ensure the resource state (and ownership) hasn't changed during the operation.
        
3. Leaking Existence:
    
    Returning 403 Forbidden for a resource that typically returns 404 Not Found can leak information about the existence of sensitive records.
    
    - _Best Practice:_ If a user is not authorized to view a resource, and that resource's existence is sensitive, return `404 Not Found` instead of `403`.
        
4. Implicit Authorization:
    
    Assuming that because a user is authenticated, they are authorized. Or assuming that because a UI element is hidden, the API endpoint is secure.
    
    - _Rule:_ The API must validate permissions independently of the UI state.
        

### Testing Strategies

Quality assurance for authorization requires rigorous matrix testing.

- **Negative Testing:** The majority of tests should verify that unauthorized users get rejected (`401`/`403`).
    
- **Role Matrix Testing:** Automated tests should cycle through every defined role against every endpoint to ensure no privilege escalation paths exist.
    
- **BOLA Automation:** Use dynamic analysis tools (DAST) to attempt accessing Resource B with User A's credentials.
    

### Auditing and Logging

Authorization failures are high-signal security events.

- **Log Denials:** Every failed authorization attempt must be logged with:
    
    - User ID
        
    - Resource ID
        
    - Attempted Action
        
    - Timestamp
        
    - IP Address
        
- **Do Not Log Data:** Never log the content of the record the user tried to access, only the metadata.
    

Related Topics:

Identity Management (IdM), OAuth 2.0 and OpenID Connect (OIDC), Role-Based Access Control (RBAC) Implementation, Broken Object Level Authorization (BOLA) Prevention, Zero Trust Architecture.

---

