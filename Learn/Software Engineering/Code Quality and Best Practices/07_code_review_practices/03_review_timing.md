## Review timing


Review timing refers to the specific point in the software development lifecycle (SDLC) where the code review intervention occurs. The timing strategy fundamentally dictates the trade-off between development velocity, code quality, and the cost of remediation. Optimizing _when_ a review happens is often more critical than the mechanics of _how_ it happens.

**Phases of Review Intervention**

- **Shift-Left (Design/RFC Review):**
    
    - **Timing:** Before any code is written.
        
    - **Focus:** Architecture, API design, security implications, and feasibility.
        
    - **Value:** This is the highest leverage point. catching a structural flaw here costs minutes to fix, whereas catching it at the pull request (PR) stage might require a full rewrite. It prevents "sunk cost fallacy" where reviewers hesitate to reject fundamentally flawed code because the author has already spent days writing it.
        
- **Pre-Commit / Pre-Merge (The Standard Gate):**
    
    - **Timing:** After code is written but before it enters the main branch (e.g., GitHub Pull Requests, GitLab Merge Requests).
        
    - **Focus:** Correctness, style, maintainability, and security.
        
    - **Value:** Acts as a hard quality gate. It ensures that technical debt is not inadvertently introduced into the codebase. However, it introduces a blocking wait state for the author, potentially increasing context-switching costs.
        
- **Post-Commit / Post-Merge (Optimistic Review):**
    
    - **Timing:** After code has been merged and deployed (often behind a feature flag).
        
    - **Focus:** Audit trails, knowledge sharing, and long-term consistency.
        
    - **Value:** Maximizes velocity by removing blocking gates. It requires a high-trust environment, robust automated testing (CI/CD), and a culture of immediate remediation. The risk is that "fix it later" often becomes "fix it never."
        
- **Periodic Audit:**
    
    - **Timing:** Scheduled intervals (e.g., monthly).
        
    - **Focus:** Broad patterns, systemic issues, and adherence to evolving standards.
        
    - **Value:** Useful for identifying architectural drift or standardizing patterns across teams, but ineffective for catching bugs in specific features.
        

**The Economics of Turnaround Time (TAT)**

The duration between a review request and the feedback is a critical metric.

- **Context Decay:** The author's understanding of their own change degrades rapidly. A review response within 4 hours allows the author to fix issues while the logic is still fresh. A response after 3 days requires the author to "reload" the context, significantly increasing the cost of the fix.
    
- **Merge Conflict Probability:** The longer a branch remains unmerged while waiting for review, the higher the probability of merge conflicts arising from other concurrent changes, leading to "integration hell."
    

**Optimization Strategies**

- **Small Batch Sizes:** There is a non-linear relationship between review size and review time. A 200-line CL might take 15 minutes to review. A 2,000-line CL will not take 150 minutes; it will likely be postponed for days or "rubber-stamped" (LGTM) without genuine scrutiny due to cognitive overload.
    
- **Service Level Agreements (SLAs):** High-performing teams often implement internal SLAs (e.g., "All PRs receive a response within 24 hours"). This treats code review as a primary deliverable, not a secondary chore.
    
- **Synchronous vs. Asynchronous:** While most reviews are asynchronous comments, complex logic or architectural changes benefit from synchronous "over-the-shoulder" or pair-programming reviews to eliminate days of back-and-forth ping-pong.
    

**Example**

Consider a scenario involving an API change for a database schema.

- _Scenario A (Late Review):_ The developer spends 3 days implementing the schema, migration scripts, and API endpoints. On Day 4, the reviewer notes that the schema violates normalization rules. **Result:** 3 days of work are discarded.
    
- _Scenario B (Shift-Left + Rapid Review):_ The developer posts a 1-page design doc or a draft PR with just the SQL schema. The reviewer catches the normalization error in 30 minutes. **Result:** Minimal rework; the developer proceeds with the correct implementation.
    

**Key Points**

- **Cost of Change:** The cost to fix a defect rises explicitly the later it is found. Reviews should happen as early as possible (Shift Left).
    
- **Blocking vs. Non-Blocking:** Pre-merge reviews block progress to ensure quality; post-merge reviews prioritize speed but risk technical debt accumulation.
    
- **Velocity:** Slow review cycles are a primary bottleneck in Continuous Delivery. Optimizing review pickup time is often more effective than optimizing coding speed.
    
- **Social Contract:** Review timing is a team culture issue. If developers view reviewing as a distraction rather than part of their job, TAT increases and quality suffers.

---

