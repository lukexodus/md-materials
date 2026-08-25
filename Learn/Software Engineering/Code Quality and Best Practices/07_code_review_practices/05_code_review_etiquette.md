## Code Review Etiquette


Code review is as much a social process as it is a technical one. High technical standards are unsustainable without a culture of respect, clarity, and psychological safety. Proper etiquette reduces friction, prevents "bikeshedding" (focusing on trivial details), and ensures that reviews speed up development rather than acting as a bottleneck.

**For the Reviewer**

- **Critique the Code, Not the Person:** Always frame comments around the artifact, not the author. Avoid "You" statements.
    
    - _Bad:_ "You broke the API here."
        
    - _Good:_ "This change appears to break backward compatibility in the API."
        
- **Ask Questions, Don't Make Demands:** Socratic questioning encourages the author to think about the solution and often reveals context the reviewer missed.
    
    - _Bad:_ "Move this into a separate function."
        
    - _Good:_ "Would it improve readability if this logic were extracted into a utility function?"
        
- **Distinguish Severity (Tiered Feedback):** Explicitly categorize your feedback to help the author prioritize.
    
    - **[BLOCKER]:** A bug, security flaw, or major design violation. The PR cannot merge.
        
    - **[OPTIONAL] / [SUGGESTION]:** A better way to do something, but not worth blocking the release.
        
    - **[NIT]:** Trivial issues (typos, formatting) that can be fixed later or ignored if time is tight.
        
- **Explain the "Why":** Never give a directive without a rationale. If you claim code is "inefficient" or "unreadable," provide the data or the specific principle (e.g., SOLID, DRY) that is being violated.
    
- **Praise Good Work:** Code review is a primary feedback loop. If you see a clever solution, excellent test coverage, or a great refactor, explicitly comment on it. This reinforces positive behaviors.
    

**For the Author**

- **Provide Context (The "Why"):** Do not open a Pull Request (PR) with an empty description. Include the goal, links to tickets (Jira/Trello), screenshots (for UI changes), and specific areas where you want feedback.
    
- **Self-Review First:** Never submit code you haven't reviewed yourself. Reviewers lose patience when they find obvious syntax errors, commented-out code, or console logs that should have been caught by the author.
    
- **Small, Atomic PRs:** Large reviews overwhelm reviewers, leading to "LGTM" (Looks Good To Me) fatigue where bugs are missed. Keep changes focused on a single task.
    
- **Respond to All Comments:** Acknowledge every piece of feedback. If you accept a change, say "Done." If you disagree, explain your reasoning politely. Do not resolve a conversation/thread until the reviewer is satisfied or a consensus is reached.
    
- **Detach Your Ego:** You are not your code. A critique of your logic is not a critique of your intelligence. Treat feedback as a free consulting session.
    

**The Stalemate Protocol**

Disagreements are inevitable. When a reviewer and author cannot agree:

1. **Move to Sync:** Stop typing. Text lacks tone. A 5-minute call often resolves a 2-day comment thread.
    
2. **Appeal to Authority/Standard:** Refer to the project's style guide or architecture documentation. If the standard doesn't exist, this is a trigger to create one.
    
3. **Disagree and Commit:** If the issue is subjective (e.g., variable naming preference) and not a blocker, the reviewer should yield to the author to maintain velocity.
    

**Example**

**Scenario:** An author uses a nested loop that looks inefficient.

- **Poor Etiquette:**
    
    > "This is O(N^2). Fix it." (Too blunt, demanding)
    > 
    > "Why did you write it this way?" (Accusatory)
    
- **Good Etiquette:**
    
    > "I noticed this nested loop iterates over the full user list twice. For large datasets, this might introduce latency. Could we optimize this using a Set look-up to bring it down to O(N)? Let me know if there's a constraint preventing that."

---

