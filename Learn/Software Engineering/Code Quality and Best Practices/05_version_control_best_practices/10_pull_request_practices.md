## Pull Request Practices


Pull Requests (PRs) or Merge Requests (MRs) are the critical gateway between local development and the shared codebase. They serve as the primary mechanism for code review, knowledge sharing, and quality control. An effective PR workflow minimizes bugs, ensures architectural consistency, and maintains a clean commit history.

**Key Points**

- **Atomicity and Size:** A PR should focus on a single logical change (Single Responsibility Principle). Large PRs (e.g., >400 lines of code) fatigue reviewers, leading to "LGTM" (Looks Good To Me) rubber-stamping rather than genuine scrutiny. If a feature is large, break it into stacked PRs or smaller implementation steps.
    
- **Contextual Descriptions:** The PR description must stand on its own. It should answer three questions: _What_ was changed? _Why_ was it changed (linking to tickets/issues)? _How_ was it verified? Including screenshots, GIFs for UI changes, or console output for backend logic dramatically reduces the time reviewers spend understanding the context.
    
- **The "Self-Review" First:** Authors must review their own diffs before assigning peers. This catches obvious leftovers like commented-out code, debug print statements, or accidental file inclusions. A PR usually shouldn't be opened until the author is confident it is ready to ship.
    
- **Draft Mode:** Use "Draft" or "WIP" (Work In Progress) status for incomplete work that needs early architectural feedback. This signals to the CI/CD pipeline and the team that the code is not yet ready for a full line-by-line review.
    
- **CI/CD Gates:** PRs must pass automated checks (linting, unit tests, integration tests, build verification) before human review begins. Reviewers should not waste time pointing out style violations that a linter could catch automatically.
    
- **Reviewer Etiquette:** Feedback should be constructive and focused on the code, not the person. Use phrases like "This line might cause race conditions" rather than "You wrote this wrong." Distinguish between "blocking" issues (logic errors, security flaws) and "nitpicks" (variable naming preferences, optional refactors).
    
- **Responsiveness:** Code review is a synchronous blocking activity. Authors should prioritize addressing comments, and reviewers should prioritize reviewing assigned PRs (typically within 24 hours) to prevent "stale" branches and merge conflicts.
    

**Example**

**Poor PR Description:**

> Title: Fix bug
> 
> Description: Fixed the login issue.

**Strong PR Description:**

> **Title:** Fix Race Condition in User Session Initialization (Ticket #1234)
> 
> Summary:
> 
> Added a mutex lock to the session manager to prevent concurrent writes during login. Previously, rapid login requests could corrupt the session cache.
> 
> **Changes:**
> 
> - `SessionManager.ts`: Wrapped write operations in `AsyncLock`.
>     
> - `SessionTests.ts`: Added a new concurrency test case `test_concurrent_login`.
>     
> 
> **Verification:**
> 
> - Ran `npm test`. New concurrency test passed (previously failed).
>     
> - Manually tested login with network throttling enabled.
>     

---

