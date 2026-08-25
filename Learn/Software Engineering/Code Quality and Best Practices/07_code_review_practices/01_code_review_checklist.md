## Code Review Checklist


Concept

A code review checklist is a standardized set of criteria used during the peer review process to ensure code quality, consistency, and functional correctness. It reduces the cognitive load on reviewers by providing explicit verification points, minimizing subjectivity, and ensuring that critical aspects like security and performance are not overlooked in favor of simple syntax checking.

**Functionality and Correctness**

- **Requirements Fulfillment:** Does the code verifyably meet the specific requirements or user story?
    
- **Edge Case Handling:** Are boundaries (null, 0, negative numbers, max values) handled gracefully?
    
- **Concurrency:** Are there potential race conditions, deadlocks, or unthread-safe operations?
    
- **Logic Errors:** Are the loops terminating? Is the boolean logic sound? Are off-by-one errors present?
    

**Clean Code and Readability**

- **Naming Conventions:** Do variables, functions, and classes have descriptive, self-explanatory names (e.g., `calculateTax` vs `doIt`)?
    
- **Function Length:** Are methods short and focused on a single responsibility (SRP)?
    
- **Complexity:** Is the cyclomatic complexity low? Are there too many nested `if/else` blocks that could be flattened or guarded?
    
- **Comments:** Do comments explain the _why_ (intent) rather than the _what_ (syntax)? Is dead code (commented-out blocks) removed?
    
- **DRY (Don't Repeat Yourself):** Is there duplicated logic that should be extracted into a utility or shared function?
    

**Architecture and Design**

- **Separation of Concerns:** Is the business logic separated from the UI and data access layers?
    
- **Coupling:** Is the code loosely coupled? are dependencies injected rather than hardcoded?
    
- **Design Patterns:** Are patterns used correctly? Is there "pattern abuse" where a simple solution would suffice?
    
- **Extensibility:** Is the code open for extension but closed for modification (OCP)?
    

**Security**

- **Input Validation:** Is all external input (API parameters, user forms) validated and sanitized?
    
- **Data Exposure:** Is sensitive data (passwords, tokens, PII) logging avoided? Are secrets excluded from version control?
    
- **Vulnerabilities:** Does the code introduce SQL injection, XSS, or CSRF vulnerabilities?
    
- **Authorization:** Does the code correctly check user permissions before performing actions?
    

**Performance**

- **Database Queries:** Are there N+1 query problems? Are indexes being used effectively?
    
- **Resource Management:** Are file handles, sockets, and connections properly closed (e.g., using `using` or `try-with-resources`)?
    
- **Efficiency:** Are algorithms optimal for the expected data set size? Is there unnecessary object instantiation inside loops?
    

**Testability and Coverage**

- **Unit Tests:** Do tests exist for the new code? Do they pass?
    
- **Test Quality:** Do tests verify behavior, not implementation details? Are they readable and independent?
    
- **Coverage:** Are both the happy path and failure paths (exceptions) covered?
    

**Documentation**

- **API Documentation:** Are public interfaces (Swagger/OpenAPI, Javadoc) updated?
    
- **Changelogs:** Is the change log updated if the release is impacted?
    
- **README:** Do setup or run instructions need updating?
    

**Example: Review Comment Strategy**

- _Ineffective:_ "This is bad code." (Vague, subjective)
    
- _Effective:_ "This loop performs a database query on every iteration (N+1 problem). Consider fetching all IDs in a single query beforehand and mapping them in memory to improve performance." (Specific, actionable, explains _why_)
    

Next Steps

Integrate this checklist into the pull request template of the repository. This forces the author to self-review against these criteria before requesting a peer review, shifting the focus of the reviewer from trivial style nitpicks to deeper architectural and logical issues.

---

