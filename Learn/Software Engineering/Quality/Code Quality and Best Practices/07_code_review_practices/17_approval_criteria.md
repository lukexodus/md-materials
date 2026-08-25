## Approval Criteria


Approval criteria define the specific conditions that a Pull Request (PR) or Merge Request (MR) must satisfy before it can be merged into the main codebase. These criteria act as the quality gatekeeper, preventing regressions, technical debt, and security vulnerabilities from entering production. Establishing clear, objective approval criteria removes ambiguity and reduces friction between authors and reviewers.

**Key Points**

- **Automation First:** Whenever possible, criteria should be verified by the CI/CD pipeline. If a machine can check it (linting, formatting, test pass/fail), a human should not waste time reviewing it.
    
- **Granularity:** Criteria should apply at different levels—some are mandatory blockers (e.g., failing build), while others are subjective but required (e.g., readability).
    
- **Traceability:** Every code change should trace back to a requirement, ticket, or issue ID.
    
- **Security & Performance:** Approval is not just about logic; it must include checks for introduced vulnerabilities or performance degradation (e.g., N+1 queries).
    

**The Criteria Pyramid**

**1. Automated Gates (The Baseline)**

- **Build Status:** The application must compile and build successfully.
    
- **Test Execution:** All unit, integration, and end-to-end tests must pass.
    
- **Static Analysis:**
    
    - **Linting:** No violations of the defined style guide (e.g., ESLint, Pylint, Checkstyle).
        
    - **Security Scans:** No high-severity vulnerabilities detected by SAST (Static Application Security Testing) tools (e.g., SonarQube, Snyk).
        
- **Coverage Thresholds:** New code must meet the minimum code coverage percentage (e.g., 80% line coverage, 100% branch coverage for critical paths).
    

**2. Manual Review Gates (The Human Element)**

- **Functional Correctness:** Does the code actually solve the problem described in the ticket?
    
- **Architectural Compliance:** Does the change respect the system's layering (e.g., Controller not calling DB directly)?
    
- **Readability & Maintainability:**
    
    - Variable and method names are descriptive.
        
    - Complex logic is documented or simplified.
        
    - No commented-out code or debug print statements.
        
- **Error Handling:** Are exceptions caught appropriately? Are user-facing errors localized and helpful?
    
- **Database Impact:** Are migrations reversible? Are indexes added for new queries?
    

**3. Documentation & Process**

- **Changelog:** Is the `CHANGELOG.md` updated?
    
- **API Docs:** If an API was modified, is the Swagger/OpenAPI definition updated?
    
- **Ticket Link:** Is the PR linked to the tracking system (Jira/Trello/Linear)?
    

**Conditional Approvals**

It is critical to define how "soft" approvals are handled:

- **Approve:** The code is ready to merge immediately.
    
- **Approve with Suggestions:** The reviewer is okay with the logic but suggests minor refactors (nits). The author can merge after addressing them without a re-review.
    
- **Request Changes:** Blockers exist. The PR cannot be merged until the author fixes the issues and requests a re-review.
    

**Example Checklist**

Teams often embed this checklist directly into the PR description template.

> **Automated Checks**
> 
> - [x] CI Build Passed
>     
> - [x] SonarQube Quality Gate Passed (A Rating)
>     
> - [x] No new compiler warnings
>     
> 
> **Functionality**
> 
> - [ ] Edge cases (null inputs, empty lists) handled
>     
> - [ ] UI changes match the Figma design (if applicable)
>     
> - [ ] Backward compatibility maintained for public APIs
>     
> 
> **Code Quality**
> 
> - [ ] No magic numbers or hardcoded strings
>     
> - [ ] Classes respect Single Responsibility Principle
>     
> - [ ] Third-party libraries are necessary and vetted
>     

**Output**

The outcome of applying these criteria is a **Mergeable State**. If _any_ mandatory criterion is unmet, the "Merge" button should be physically disabled by the repository settings (e.g., GitHub Branch Protection Rules).

---

