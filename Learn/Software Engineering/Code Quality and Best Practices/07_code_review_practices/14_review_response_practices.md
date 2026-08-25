## Review response practices


Definition and Objectives

Review response practices encompass the behavioral and technical protocols a developer follows when addressing feedback on a Pull Request (PR) or Merge Request (MR). While the reviewer's job is to identify issues, the author's response determines the speed of resolution and the overall health of the team dynamic. Effective response practices minimize "ping-pong" (endless cycles of comments), reduce time-to-merge, and foster a collaborative rather than adversarial environment. The objective is to reach a consensus on quality standards efficiently while maintaining professional respect.

The Egoless Mindset

The foundation of effective response is the separation of self-worth from the code.

- **Code is an Asset, Not an Identity:** Critique of the code is not a critique of the author's intelligence or capability.
    
- **Assume Positive Intent:** View comments as attempts to improve the product, not as personal attacks or nitpicking.
    
- **Gratitude:** Acknowledge that the reviewer spent time understanding the logic. A simple "Good catch" builds significant rapport.
    

**Key Response Strategies**

1. Acknowledge Every Comment

Leaving comments "hanging" creates ambiguity. Did the author miss it? Did they disagree?

- **Actionable Comments:** If you fix an issue, reply with "Done" or "Fixed" (or use the platform's "Resolve" feature).
    
- **Non-Actionable Comments:** If you decide not to make a change, you must provide a reason. Silence is not an acceptable response to a critique.
    

2. Clarify vs. Defend

When a reviewer misunderstands the code, it often indicates the code itself is confusing, not that the reviewer is lacking.

- **Defensive (Avoid):** "You clearly didn't read the spec. It works fine."
    
- **Clarifying (Preferred):** "I see why that looks risky. The safety guarantee is actually handled in the `BaseClass`. I'll add a comment there to make it clearer."
    
- **The "Why" Rule:** Always explain the _why_ behind a decision, linking to documentation or tickets if necessary.
    

3. Handling Subjective Feedback

Reviewers sometimes offer opinions on style or preference that are not strictly bugs or violations of standards.

- **The "Nitpick" Label:** If a comment is trivial but valid, just do it. It costs less energy to rename a variable than to argue about it.
    
- **Defer to Standards:** If a disagreement persists, refer to the team's style guide. If the style guide is silent, the author's preference usually prevails, or the team should agree to update the guide later (offline).
    

4. Taking it Offline

Text-based communication lacks tone and nuance. If a specific thread goes back and forth more than three times, stop typing.

- **Synchronous Resolution:** Hop on a call or walk to their desk. Discuss the issue, reach a consensus, and then _post the summary of the decision back on the PR_ for the record. This ensures future maintainers understand why the decision was made.
    

**Technical Etiquette in Responses**

Batching Fixes

Avoid pushing a commit for every single typo fix unless required by the workflow. It triggers multiple CI/CD builds and notifies reviewers excessively.

- **Practice:** Address all comments locally, verify the build, and push one or two comprehensive update commits.
    
- **Notification:** Once the push is live, reply to the main thread or click "Re-request review" to signal you are ready.
    

Resolving Conversations

Most platforms (GitHub, GitLab, Bitbucket) allow marking threads as "Resolved."

- **Rule:** The person who started the thread (the reviewer) should usually be the one to mark it resolved. This confirms they are satisfied with the fix.
    
- **Exception:** If the team agrees, authors can resolve threads for trivial fixes (typos, formatting) to declutter the view, leaving complex logic discussions open for the reviewer to verify.
    

**Example Scenarios**

- **Scenario: The "Scope Creep" Request**
    
    - _Reviewer:_ "While you're touching this file, can you also refactor the legacy `UserAuth` module to use async/await?"
        
    - _Bad Response:_ "No, that's not my job."
        
    - _Good Response:_ "That definitely needs to be done, but I'd like to keep this PR focused on the login bug to ensure a safe revert if needed. I've created a ticket [link] for the refactor and will pick it up next."
        
- **Scenario: The "False Positive"**
    
    - _Reviewer:_ "This loop looks like O(n^2), it will crash production."
        
    - _Bad Response:_ "No it won't."
        
    - _Good Response:_ "It looks like O(n^2) because of the nested loop, but the inner loop only iterates over a fixed set of 5 enum values, so it's effectively O(n). I've added a comment explaining this constant time complexity."


---

