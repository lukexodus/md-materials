## Commit Frequency


Commit frequency—the rate at which a developer saves changes to the version control system—is a critical metric for gauging development velocity and code manageability. While the ideal frequency varies by task complexity, the industry standard leans heavily toward high-frequency, atomic commits during development, often consolidated before merging to the main branch.

### Atomic Commits

The golden rule of commit frequency is the concept of the **Atomic Commit**. An atomic commit represents the smallest possible unit of change that leaves the codebase in a stable, buildable state.

- **Indivisible:** A commit should address a single logical change (e.g., "Add user validation," not "Add user validation and fix header typo").
    
- **Revertible:** If a commit introduces a bug, reverting it should remove _only_ the problematic feature without destroying unrelated work.
    
- **Testable:** Ideally, the test suite should pass at every commit point.
    

### The Case for High Frequency

Frequent commits serve as save points in a game. They reduce the cognitive load and risk associated with complex programming tasks.

Granular History & Debugging

High-frequency commits empower tools like git bisect. When a regression is introduced, a history containing small, frequent commits allows a developer to pinpoint the exact line of code that caused the failure. If commits are infrequent (e.g., one huge commit per week), bisect will only point to a massive chunk of code, making root cause analysis difficult.

Conflict Resolution

The longer code sits on a local machine without being integrated or updated against the upstream, the higher the probability of "Merge Hell." Frequent commits, coupled with frequent pulls/rebases from the main branch, ensure that conflicts are resolved incrementally and are manageable in size.

Code Review Velocity

Reviewers can process a series of small, logical commits much faster than a single monolithic file change. Small commits allow the reviewer to follow the narrative of the development process.

### Workflow Integration

Red-Green-Refactor

In Test-Driven Development (TDD), commit frequency is tied to the cycle:

1. **Red:** Write a failing test. (Optional Commit)
    
2. **Green:** Write just enough code to pass. (Commit: "Pass test for X")
    
3. **Refactor:** Clean up the code. (Commit: "Refactor X for readability")
    

Local vs. Public History

There is a distinction between local commit frequency and public commit history.

- **Local:** Commit as often as possible. Fix typos, save work-in-progress (WIP), and snapshot experimental changes. This is for the developer's safety.
    
- **Public (Upstream):** Before pushing to a shared branch (or merging a Pull Request), "messy" frequent commits should be squashed or interactively rebased into clean, atomic units. This preserves the signal-to-noise ratio of the project history.
    

### Strategic Commit Points

1. **Completion of a Logical Unit:** When a specific function, test, or interface is working.
    
2. **Context Switching:** Before moving from backend logic to frontend styling, or before taking a break.
    
3. **Refactoring:** Commit the refactor separately from behavioral changes. If a refactor breaks something, it should be isolated from feature logic.
    
4. **End of Day:** Always commit work before leaving, even if it is broken (mark it clearly as `WIP` or push to a private feature branch).
    

### Anti-Patterns

- **The "Save Game" Commit:** Committing broken code to the `main` or shared development branch just to save progress. This breaks the build for the team.
    
- **The "Megacommit":** A single commit covering days of work, touching dozens of files, and mixing refactoring with new features. The commit message is usually vague (e.g., "Update system").
    
- **Phantom Commits:** Committing whitespace changes or commented-out code.
    

**Key Points**

- **Granularity:** Aim for commits that do one thing only.
    
- **Safety:** Commit locally like you are saving a document; frequently and fearlessly.
    
- **Cleanliness:** Squash local WIP commits before sharing with the team.
    
- **Traceability:** Frequent commits enable precise `git blame` and `git bisect`.
    

**Example**

_Bad History (Low Frequency/Mixed Concerns):_

Plaintext

```
a1b2c3d Update user login, fix CSS bug, and refactor database connection
```

_Good History (High Frequency/Atomic):_

Plaintext

```
e5f6g7h Refactor: Extract database connection logic to service
i8j9k0l Feat: Implement user password hashing
m1n2o3p Fix: Resolve Z-index issue on login modal
```

Next Steps

Practice "Interactive Rebasing" (git rebase -i) to become comfortable with the workflow of committing frequently (every 10-20 minutes) and then curating those commits into a clean narrative before pushing.

---

