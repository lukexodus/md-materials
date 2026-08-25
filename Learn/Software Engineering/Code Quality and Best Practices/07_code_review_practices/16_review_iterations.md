## Review iterations


Review iterations refer to the number of back-and-forth cycles a piece of code undergoes between the author and the reviewer(s) before it is approved and merged. This metric is a vital health indicator for both the engineering team's efficiency and the clarity of the codebase. A "single iteration" consists of the author submitting changes, the reviewer providing feedback, and the author addressing that feedback.

**The Anatomy of an Iteration**

1. **Submission (Round 0):** The author opens a Pull Request (PR) or Merge Request (MR).
    
2. **Review (Round 1):** The reviewer examines the code and leaves comments (blocking changes, questions, or nits).
    
3. **Revision:** The author modifies the code based on the comments and pushes updates.
    
4. **Re-review (Round 2+):** The reviewer checks the updates. If new issues are found or previous ones weren't addressed, the cycle repeats.
    
5. **Approval:** The reviewer signs off, ending the iterations.
    

**The "High Iteration" Anti-Pattern**

While some iteration is healthy and expected, a consistently high number of iterations (e.g., >3 rounds per PR) signals underlying process failures.

- **Ambiguous Requirements:** The author implemented the wrong solution because the task wasn't clear, forcing a rewrite during review.
    
- **Misalignment on Standards:** The team lacks an agreed-upon style guide or architectural pattern, leading to debates over subjectivity in the review comments.
    
- **"Throw-it-over-the-wall" Mentality:** The author did not perform a self-review or run local tests, using the reviewer as a spell-checker or debugger.
    
- **Reviewer Perfectionism:** The reviewer is shifting goalposts, adding new requirements in each round (Scope Creep) rather than stating all necessary changes upfront.
    

**Strategies for Minimizing Iterations**

Reducing review iterations requires effort from both the author and the reviewer.

**For the Author (Pre-Review Optimization)**

- **Self-Review:** Before tagging a reviewer, the author must read through their own diff. This catches 30-50% of low-level errors (typos, commented-out code, debug logs) that otherwise waste an iteration.
    
- **Atomic PRs:** Keep changes small and focused. A 200-line PR is often reviewed in 1 round; a 2,000-line PR usually requires 4+ rounds due to cognitive overload and missed edge cases.
    
- **Contextualize:** Provide a clear description, screenshots, or diagrams in the PR. If the reviewer understands _why_ the change exists, they ask fewer clarifying questions.
    

**For the Reviewer (Feedback Batching)**

- **Complete Reviews:** Provide all feedback in a single batch. Avoid "drip-feeding" comments where you point out a syntax error in Round 1, then a logic error in Round 2 that was visible in Round 1.
    
- **Clear Exit Criteria:** When requesting changes, state exactly what needs to happen for approval.
    
    - _Bad:_ "This logic is confusing." (Leads to the author guessing, potentially getting it wrong again).
        
    - _Good:_ "This logic is hard to follow. Please extract this conditional into a named helper function to clarify intent."
        
- **Distinguish Nits:** Explicitly label minor issues as non-blocking (e.g., "Nit: extra space here"). This allows the author to fix them without fearing another full review cycle is needed.
    

**Measuring Iteration Health**

**Key Points**

- **Target:** Aim for an average of 1.2 to 1.5 iterations per PR.
    
- **Cost:** Every iteration adds latency. If a review round takes 4 hours of turnaround time, 3 iterations add 1.5 days to the delivery time (Lead Time).
    
- **Social Impact:** High iterations cause "Review Fatigue." Authors become demoralized and may start blindly accepting changes just to get the code merged, or reviewers may rubber-stamp code just to stop seeing it.
    

**Example Scenario**

- **Round 1:** Reviewer finds a security flaw and a variable naming issue.
    
- **Author:** Fixes the naming issue but misunderstands the security flaw explanation.
    
- **Round 2:** Reviewer points out the security flaw again.
    
- **Author:** Fixes the security flaw.
    
- **Round 3:** Reviewer notices a new bug introduced by the security fix.
    
- **Author:** Fixes the new bug.
    
- **Round 4:** Approval.
    

_Analysis:_ This 4-round cycle indicates a failure in communication during Round 1. If the reviewer had provided a code snippet or a clearer explanation of the security risk, or if the author had asked for clarification before coding, the process could have been compressed into 2 rounds.

---

