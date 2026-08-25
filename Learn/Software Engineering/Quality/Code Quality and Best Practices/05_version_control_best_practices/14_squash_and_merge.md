## Squash and merge


Squash and merge is a Git merge strategy often employed in Pull Request (PR) workflows where all commits from a feature branch are combined (squashed) into a single commit before being merged into the target branch (usually `main` or `master`). This approach prioritizes a linear, clean project history over preserving the granular development process.

**Key Points**

- **History Hygiene:** The primary motivation for squashing is to prevent "work in progress" (WIP) commits from polluting the main history. Commits like "fix typo", "update styles", "try again", or "wip" are useful for the developer during implementation but act as noise to anyone reading the history later. Squashing creates a timeline where every commit represents a complete, functional unit of work.
    
- **Atomicity and Revertability:** By condensing a feature into a single commit, the change becomes atomic. If a feature introduces a regression, reverting it requires undoing only one specific commit. In a non-squashed merge (merge commit), reverting a feature might require reverting the merge commit itself or identifying and reverting multiple specific commits interspersed with others.
    
- **Improved Bisecting:** `git bisect` is a powerful tool for finding the specific commit that introduced a bug. In a squashed history, every commit on the main branch is theoretically a stable, passing build (assuming CI gates are used). This makes bisecting faster and more reliable compared to traversing intermediate "broken" commits within a feature branch.
    
- **Loss of Granular Context:** The trade-off is the loss of the "micro-history." If the thought process, specific architectural decisions, or failed attempts contained valuable lessons, those are erased. Complex refactorings sometimes benefit from preserving individual steps to show the path of migration; squashing destroys this evidence.
    
- **Commit Message Curated:** When squashing, the resulting single commit message is critical. Default behaviors often concatenate all intermediate commit messages, resulting in a wall of text. Best practice dictates rewriting the final commit message to strictly follow the "Subject + Body" convention: a concise summary of the feature followed by a bulleted list of changes, rather than a log of "fixes."
    
- **Workflow Suitability:**
    
    - _Recommended:_ For short-lived feature branches, bug fixes, and routine tasks.
        
    - _Not Recommended:_ For long-lived branches (like `develop` merging into `main`) or massive architectural changes where the step-by-step evolution is necessary for audit or understanding.
        

**Example**

Before Squash (Feature Branch History):

The feature branch feature/user-auth has messy, granular commits:

Plaintext

```
* 7f3a1b - (feature/user-auth) Fix linter errors
* 6e2c9a - Add forgotten password logic
* 5d1b8f - Fix typos in login form
* 4c0a7e - WIP: Start implementation of auth
```

After Squash and Merge (Main Branch History):

Instead of adding those 4 commits plus a merge commit, the main branch receives exactly one commit containing all changes:

Plaintext

```
* 9g8h7i - (main) Feat: Implement User Authentication System
|
|    - Added login form with validation
|    - Implemented forgotten password logic
|    - Setup JWT handling
|
* 3b2a1c - Previous commit on main...
```

---

