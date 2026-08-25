## Review scope


Definition and Objective

Review scope defines the boundaries of a code review session. It determines what changes are being examined (lines of code, specific files, affected modules) and which quality attributes are being assessed (functionality, security, maintainability, performance). Defining a clear scope is essential to prevent "review fatigue," ensure the reviewer can maintain high attention to detail, and avoid scope creep where unrelated issues block the deployment of critical fixes.

Optimal Sizing

Research consistently indicates an inverse relationship between the volume of code reviewed and the density of defects found.

- **Sweet Spot:** 200 to 400 lines of code (LOC) per review. At this size, reviewers can effectively find 70-90% of defects.
    
- **Upper Limit:** Reviews exceeding 500 LOC see a sharp drop in defect detection rates.
    
- **Time Limit:** A review session should generally not exceed 60 minutes. Beyond this, cognitive load increases, and the ability to spot subtle logical errors diminishes significantly.
    

Dimensions of Scope

The scope is not just physical (LOC) but also dimensional in terms of the layers of code quality being analyzed:

- **Functional Scope:** Does the code satisfy the specific business requirement or fix the bug as described in the ticket?
    
- **Architectural Scope:** Does the change fit within the existing system design? Does it introduce circular dependencies or violate separation of concerns?
    
- **Security Scope:** Are inputs sanitized? Are permissions checked? (Often requires a specialized review for high-risk changes).
    
- **Test Scope:** Are there accompanying unit and integration tests? Do they cover edge cases?
    

In-Scope vs. Out-of-Scope

Strictly delineating what is not part of a review is as important as defining what is.

- **In-Scope:**
    
    - Logic verification (algorithms, state management).
        
    - Error handling and edge cases.
        
    - Readability and naming conventions (if not automated).
        
    - Test completeness.
        
    - Security implications of the specific change.
        
- **Out-of-Scope (The "Bikeshedding" Trap):**
    
    - **Styling/Formatting:** Indentation, spacing, and brace placement should be enforced by automated linters (Prettier, ESLint, Black), not human reviewers.
        
    - **Unrelated Refactoring:** Requests to "cleanup" code in nearby files that were not touched by the feature implementation. This should be a separate task.
        
    - **Hypothetical Extensibility:** requesting changes for "future-proofing" features that are not currently planned (YAGNI - You Ain't Gonna Need It).
        

Scope Creep in Reviews

Scope creep occurs when a reviewer requests changes that are not pertinent to the immediate goal of the Pull Request (PR).

- **The "While You're At It" Anti-Pattern:** A reviewer notices legacy technical debt in a file being modified and asks the author to fix it. This bloats the PR, increases regression risk, and delays merging.
    
- **Mitigation:** If technical debt is found, file a separate ticket/issue for it. Do not hold the current PR hostage for unrelated legacy issues.
    

Example: Scoping a Bug Fix

Scenario: A developer submits a PR to fix a NullPointerException in a user login method.

- **Correct Scope:**
    
    - Verify the null check prevents the crash.
        
    - Verify the unit test reproduces the crash without the fix and passes with it.
        
    - Check if the null value propagates to other downstream functions.
        
- **Incorrect Scope (Scope Creep):**
    
    - Asking the developer to rewrite the entire authentication class to use a new dependency injection framework.
        
    - Asking to rename variables in the method that are not related to the fix.
        

Structuring Large Changes

When a feature naturally requires a scope larger than 400 LOC, it must be decomposed to maintain review quality:

1. **Stacked Diffs/PRs:** Break the feature into a series of dependent PRs (e.g., PR 1: Database Schema, PR 2: Backend API, PR 3: Frontend UI).
    
2. **Commit-by-Commit Review:** If the platform supports it, review the narrative of the code through individual atomic commits rather than the "Files Changed" view of the final state.

---

