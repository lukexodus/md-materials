## Git Workflow


A defined Git workflow is the backbone of collaborative software development. It dictates how code moves from a developer's local environment to production, ensuring stability, traceability, and conflict resolution. A chaotic workflow leads to regression, lost work, and "merge hell."

**Key Points**

- **Branching Strategy:** Adopting a formal model (Trunk-Based vs. Git Flow) is non-negotiable for teams.
    
- **Atomic Commits:** Each commit must represent a single, complete unit of work that passes tests.
    
- **Pull Requests (PRs):** The primary gatekeeping mechanism for code quality, peer review, and CI automation.
    
- **Linear History:** Prefer rebasing or squashing over merge commits for feature branches to maintain a readable project history.
    

**Branching Models**

1. **Trunk-Based Development (Modern Standard):**
    
    - **Structure:** A single long-lived branch (`main` or `trunk`). Developers push small, frequent updates directly to trunk or via very short-lived feature branches.
        
    - **Use Case:** High-velocity teams, CI/CD pipelines, daily deployments.
        
    - **Pros:** Minimizes "merge hell," encourages frequent integration, forces feature flags for incomplete work.
        
    - **Cons:** Requires rigorous automated testing; breaking `main` halts the entire team.
        
2. **Git Flow (Legacy/Release-Based):**
    
    - **Structure:** Uses two long-lived branches: `main` (production history) and `develop` (integration). Supporting branches include `feature/*`, `release/*`, and `hotfix/*`.
        
    - **Use Case:** Software with scheduled release cycles (e.g., mobile apps, desktop software) or strictly versioned artifacts.
        
    - **Pros:** Strict control over releases; clearly defined staging area.
        
    - **Cons:** Complex history; encourages long-lived branches which lead to difficult merge conflicts.
        
3. **GitHub/GitLab Flow:**
    
    - **Structure:** A middle ground. `main` is deployable. Feature branches are created from `main` and merged back into `main` after review. Deployments happen from `main`.
        
    - **Use Case:** Web applications and SaaS.
        

**Commit Discipline**

- **Conventional Commits:** Adopting a standard structure allows for automated semantic versioning and changelog generation.
    
    - Format: `<type>(<scope>): <subject>`
        
    - Types: `feat` (new feature), `fix` (bug fix), `refactor` (code change that neither fixes a bug nor adds a feature), `chore` (build process, aux tools), `docs`.
        
    - Example: `feat(auth): implement JWT token rotation`
        
- **Imperative Mood:** Write the subject line as if it completes the sentence "If applied, this commit will..." (e.g., "Add user logging," not "Added user logging").
    
- **Atomic Changes:** Do not mix formatting changes (linting) with logic changes in the same commit. This makes reverting specific changes impossible without side effects.
    

**Pull Request (PR) / Merge Request (MR) Etiquette**

- **Context:** Every PR must include a description explaining _why_ the change is made, not just _what_ changed. Link to relevant issue tickets (Jira/Trello).
    
- **Size:** Keep PRs small (< 400 lines of code). Large PRs result in "LGTM" (Looks Good To Me) fatigue, where reviewers skim rather than analyze.
    
- **Draft Mode:** Open PRs as "Draft" or "WIP" early to get feedback on the architectural approach before the code is finalized.
    
- **Self-Review:** The author must review their own diff before requesting peer review. Remove debugging statements and commented-out code.
    

**Managing History: Merge vs. Rebase**

- **Rebase (`git rebase main`):** Rewrites the local feature branch history to start from the current tip of `main`.
    
    - _Benefit:_ Creates a linear history. It appears as if the feature was written sequentially after the latest updates.
        
    - _Risk:_ Never rebase a public/shared branch. Rewriting history breaks other developers' environments.
        
- **Squash Merge:** Combines all commits from a feature branch into a single commit upon merging to `main`.
    
    - _Benefit:_ Hides the messy "work in progress" commits (e.g., "fix typo", "try again") from the permanent history.
        
    - _Best Practice:_ Use "Squash and Merge" for feature branches in the remote repository settings.
        
- **Standard Merge (`git merge`):** Creates a "merge bubble" in the graph. Useful for preserving the context that a group of commits belonged to a specific feature branch, often preferred in Git Flow.
    

**Protection Rules**

- **Branch Protection:** Configure the repository to block direct pushes to `main`.
    
- **Status Checks:** Require CI pipelines (tests, linting, build) to pass before a merge is allowed.
    
- **Code Owners:** Require approval from specific subject matter experts for sensitive paths (e.g., anyone changing `/security` or `/db-migrations` must get approval from the Security Team).

---

