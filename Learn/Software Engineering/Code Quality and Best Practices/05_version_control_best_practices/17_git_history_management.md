## Git History Management


A clean, meaningful Git history is a critical form of project documentation. It allows developers to understand the evolution of the codebase, revert specific changes without side effects, and utilize automated tools like `git bisect` to locate bugs efficiently. Poor history management results in a "forensic nightmare" where the intent of code changes is obscured by "WIP" commits and merge clutter.

**Key Points**

- **Atomic Commits:** Each commit should represent a single, indivisible logical change. A commit should not include both a bug fix and a formatting change, nor should it contain half-finished features. If a commit fails a test, it should be revertible without breaking unrelated functionality.
    
- **Conventional Commits:** Adhere to a strict convention for commit messages (e.g., the Conventional Commits specification). Use prefixes like `feat:`, `fix:`, `refactor:`, or `chore:` to categorize changes. The subject line should be imperative ("Add login feature" not "Added login feature") and under 50 characters. The body should explain _why_ the change was made, not _what_ changed (the diff shows that).
    
- **Squashing and Rebasing:** Use interactive rebase (`git rebase -i`) to clean up local history before pushing or merging. Squash "fix typo", "wip", and "save point" commits into the relevant logical commit. This presents a polished history to the team, hiding the messy trial-and-error process of development.
    
- **Linear History:** Prefer rebasing over merging when bringing feature branches up to date with the main branch. This avoids "merge bubbles" (non-linear history artifacts) that clutter the log and complicate history traversal.
    
- **Immutability of Public History:** Never rewrite history (rebase, squash, amend) on branches that have been pushed and are shared with other developers (like `develop` or `main`). Rewriting public history forces teammates to perform complex manual reconciliations and risks losing work.
    

**Example**

_Bad History (Cluttered and Vague):_

Plaintext

```
* 8a2b3c Merge branch 'master' into feature-login
* 7f9d1e fix
* 5c4a2b wip
* 3b1a9c fix typo in variable name
* 1a2b3c implemented login
```

_Refactored History (Linear and Atomic):_

Plaintext

```
* 9d8e7f feat(auth): implement JWT-based user login
* 6a5b4c test(auth): add unit tests for token validation
* 2f3e4d refactor(user): rename 'usr' var to 'userEntity' for clarity
```

---

