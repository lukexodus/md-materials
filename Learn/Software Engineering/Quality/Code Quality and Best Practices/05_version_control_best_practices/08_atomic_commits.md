## Atomic commits


Atomic commits are the practice of structuring version control history such that each commit represents a single, indivisible, and complete unit of work. Much like a database transaction, an atomic commit should leave the system in a stable state; the application must build and tests must pass at every single commit point.

**Key Points**

- **Single Responsibility Principle:** A commit should do one thing and one thing only. It should not mix refactoring with a bug fix, nor should it mix a new feature with a dependency update.
    
    - _Test:_ Can you describe the commit with a single, simple sentence without using "and"? If you have to say "Fixed the login bug AND reindented the header," it is not atomic.
        
- **Indivisibility and Revertability:** The primary operational benefit is the ability to revert specific changes with surgical precision. If a commit contains both a critical bug fix and a feature, and the feature causes a regression, you cannot revert the feature without also removing the bug fix. Atomic commits decouple these risks.
    
- **Bisectability:** `git bisect` is a powerful tool for finding the exact commit that introduced a bug. If commits are monolithic (large and complex), identifying the breaking commit only narrows the search down to a massive chunk of code. If commits are atomic, `git bisect` points to the exact logical change that caused the failure.
    
- **Code Review Cognitive Load:** Atomic commits allow reviewers to review "by commit" rather than "by file." This provides a narrative structure to the review. The reviewer can see the refactoring step, verify it is safe, and then see the feature implementation that relies on that refactoring.
    
- **The "Builds and Passes" Rule:** Atomicity does not justify breaking the build. Splitting a feature into three commits is only valid if the codebase is stable after _each_ of those three commits. You cannot have a commit that adds a function call followed by a commit that defines the function.
    
- **Logical vs. Physical Size:** An atomic commit is not defined by the number of lines changed.
    
    - _Small but not atomic:_ Changing a variable name in one file while changing a CSS style in another (2 lines, 2 unrelated contexts).
        
    - _Large but atomic:_ Renaming a class used in 500 files (1000+ lines, 1 single logical operation).
        

**Strategies for Achieving Atomicity**

- **Patch Staging (`git add -p`):** This is the most critical tool for atomic commits. It allows you to interactively stage specific chunks (hunks) of a file while leaving others unstaged. This enables you to separate a typo fix from a logic change within the same file.
    
- **Interactive Rebase (`git rebase -i`):** Developers often code in a "wip" (work in progress) flow. Before pushing, use interactive rebase to squash "fixup" commits into their parents or split monolithic commits into smaller logical units.
    
- **Branching Strategy:** Feature branches allow developers to make messy, non-atomic commits locally during exploration. The discipline of atomicity is applied during the "cleanup" phase before merging to the main branch.
    

**Example**

**Bad (Monolithic Commit):**

Plaintext

```
Commit: 8f3a12
Message: Update user profile and fix navigation bug

- Added 'Bio' field to User model
- Updated database schema migration
- Fixed CSS z-index issue on the navbar
- Refactored UserController to use new validation logic
- Fixed a typo in the README
```

_Critique:_ If the validation logic is flawed, reverting this commit destroys the database schema update and the CSS fix.

**Good (Atomic Series):**

Plaintext

```
Commit 1: 5b1d90
Message: docs: fix typo in README

Commit 2: 7a3c21
Message: fix(ui): correct z-index overlap in main navbar

Commit 3: 9e4f55
Message: refactor(user): modernize validation logic in controller

Commit 4: 1d2a88
Message: feat(user): add Bio field to User model and schema
```

_Critique:_ Each step is verifiable. If the validation refactor (Commit 3) fails, it can be reverted without affecting the UI fix (Commit 2) or the new Feature (Commit 4).

---

