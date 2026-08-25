## Code review process


The code review process is a systematic examination of source code by developers other than the author. It serves as the primary quality gate in software development, ensuring that no code enters the production codebase without validation. Beyond bug detection, it is a critical mechanism for knowledge transfer, architectural consistency, and team cohesion.

**Key Points**

- **Quality Assurance & Risk Mitigation:** The primary objective is to identify defects, security vulnerabilities, and logic errors before they reach the QA stage or production. It is significantly cheaper to fix a bug during review than after deployment.
    
- **Knowledge Sharing:** Reviews prevent knowledge silos. By reading the code, the reviewer learns about new features or refactoring, ensuring that multiple team members understand the system's evolution. It acts as a continuous mentorship loop where senior engineers guide juniors, and juniors question established patterns.
    
- **Atomic Changes:** Reviews are most effective when the Pull Request (PR) or Merge Request (MR) is small and focused (often cited as under 200-400 lines of code). Large, monolithic reviews lead to "review fatigue," where reviewers skim complex logic and miss critical issues.
    
- **Cultural Tone:** The focus must always be on the code, not the coder. Comments should be objective ("This variable name is ambiguous") rather than personal ("You named this badly"). The goal is a collaborative improvement, not an interrogation.
    
- **Separation of Concerns:**
    
    - **Automated Checks:** Style, formatting, and syntax errors should be handled by linters and CI pipelines. Humans should not waste time reviewing indentation.
        
    - **Manual Review:** Humans focus on logic, architecture, security, and maintainability.
        

**The Workflow Phases**

1. **Author Preparation (Self-Review):**
    
    - The author runs the code locally to ensure it compiles and passes tests.
        
    - The author performs a self-review of the diff, cleaning up commented-out code or debug statements.
        
    - The PR is opened with a descriptive title, a link to the relevant ticket/issue, and instructions on how to test the changes.
        
2. **CI/CD Validation:**
    
    - Automated pipelines run unit tests, linters, and security scanners. Reviewers should not begin their review until these checks pass to avoid reviewing broken code.
        
3. **The Review Loop:**
    
    - **Triage:** Reviewers scan the changes to understand the scope and high-level architecture.
        
    - **Line-by-Line Analysis:** Reviewers leave comments on specific lines. Comments are typically categorized as:
        
        - **Blocking (Must Fix):** Errors, bugs, or security risks.
            
        - **Non-Blocking (Nitpick/Suggestion):** Minor improvements or questions that do not prevent merging.
            
    - **Discussion:** The author responds to comments, either by pushing a fix or providing a rationale for the current implementation.
        
4. **Approval and Merge:**
    
    - Once all blocking issues are resolved, the reviewer grants approval (often signaled by "LGTM" - Looks Good To Me).
        
    - The code is merged into the target branch.
        

**Review Checklist**

Reviewers should systematically check the following dimensions:

- **Functionality:** Does the code actually solve the problem? Are there edge cases (null inputs, empty lists) that were missed?
    
- **Tests:** Are there new unit tests for the new features? Do the tests cover failure scenarios, not just the "happy path"?
    
- **Design:** Is the code adhering to the project's architectural patterns (e.g., MVC, SOLID principles)? Is it over-engineered?
    
- **Readability:** Is the code self-explanatory? Are variable names precise? Are complex logic blocks explained with comments?
    
- **Security:** Are there SQL injection risks? Is user input sanitized? Are secrets (API keys) hardcoded?
    

**Example**

Ineffective Review Comment:

"Fix this."

(Vague, directive, and lacks context.)

Effective Review Comment:

"This loop performs a database query in every iteration (N+1 problem), which will degrade performance on large datasets. Suggest fetching all required IDs first and performing a single batch query, or using the ORM's select_related method."

(Identifies the specific issue, explains the impact, and offers a concrete solution.)

---

