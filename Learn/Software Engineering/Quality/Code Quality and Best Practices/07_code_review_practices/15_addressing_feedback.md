## Addressing feedback


Feedback during code review is the primary mechanism for knowledge transfer and quality control within a development team. How an author receives, processes, and acts upon this feedback determines the efficiency of the development cycle and the health of the team dynamic. Effective feedback resolution transforms a critique into a collaborative design session rather than a gatekeeping exercise.

**The Ego and the Code**

The fundamental prerequisite for addressing feedback effectively is the separation of the author's self-worth from the code they produced. The philosophy of "Egoless Programming" dictates that a critique of the _code_ is not a critique of the _person_. When a reviewer points out a flaw, the immediate reaction must be analytical, not defensive. The objective is not to "win" the argument but to reach the optimal technical solution for the codebase.

**Taxonomy of Feedback**

Not all comments carry equal weight. An author must quickly categorize feedback to prioritize their response:

- **Blocking (Must-Fix):** Critical bugs, security vulnerabilities, architectural violations, or logic errors. The code cannot be merged until these are resolved.
    
- **Non-Blocking (Nitpicks/Polish):** Variable naming, minor stylistic choices, or preference-based suggestions. These should be addressed, but in high-urgency situations, teams may agree to defer these to a follow-up ticket.
    
- **Questions/Clarifications:** The reviewer does not understand the logic. This often indicates that the code is too complex or lacks comments, rather than the reviewer missing context. The fix is usually to improve code readability, not just explain it in the chat.
    
- **Praise:** Acknowledgement of a clever solution. While nice, these do not require action other than a brief acknowledgement.
    

**The Resolution Workflow**

1. **Read Completely:** Read all comments before responding to any. A comment later in the file might invalidate or explain a comment earlier in the file.
    
2. **Acknowledge:** Do not silently push a new commit. Mark comments as "Resolved" in the tool or reply with "Done" or "Fixed in [commit-hash]". This signals to the reviewer that their effort was respected and acted upon.
    
3. **Clarify:** If a comment is ambiguous ("This is weird"), ask for specifics immediately. "Can you elaborate on the risk you see here?" or "Do you have a preferred pattern for this?"
    
4. **Implement:**
    
    - **Small Fixes:** Address simple logic errors or style issues directly.
        
    - **Large Refactors:** If the feedback requires a complete rewrite, discuss it offline or in a meeting first to avoid another wasted coding cycle.
        
5. **Commit Structure:** Depending on team policy, either squash the fixes into the original commit (to keep history clean) or add them as "fixup" commits (to make it easier for the reviewer to see what changed since the last review).
    

**Managing Disagreements**

Disagreement is healthy and expected in engineering. When an author disagrees with feedback:

1. **Assume Positive Intent:** The reviewer is trying to improve the code, not block you.
    
2. **Provide Evidence:** Do not reply with "I think this is better." Reply with data, documentation, or benchmarks. "I chose this pattern because the documentation for library X recommends it for thread safety, see link..."
    
3. **The "Why" vs. "What":** Explain the constraints that led to the decision. Often, the reviewer is missing context about a legacy dependency or a specific business rule.
    
4. **Escalation/Tie-Breaking:** If a consensus cannot be reached after two rounds of comments, move the discussion to a synchronous channel (video call or desk). Text is a poor medium for nuance. If a stalemate persists, defer to the maintainer/architect of that specific module.
    

**Example**

_Reviewer Comment:_

> "This query `SELECT * FROM users` is dangerous. It fetches all columns, including the BLOB `profile_image`, which will kill performance on the listing page. Explicitly select the required columns."

_Bad Response:_

> "It's fine, the table is small right now. I'll optimize it later."
> 
> (Result: Technical debt is introduced; reviewer concerns are dismissed.)

_Good Response:_

> "Good catch. I didn't realize profile_image was in this table. I've updated the query to SELECT id, name, email FROM users in commit 8f9a0b."
> 
> (Result: Code is improved; reviewer feels validated.)

_Disagreement Response:_

> "I understand the concern about performance. However, this method is used by a dynamic serializer that relies on reflection to map all fields. If we hardcode columns here, the serializer will break when we add columns later. Given this constraint, do you have a suggestion for excluding the BLOB specifically, or should we refactor the serializer?"
> 
> (Result: Context is shared; problem is reframed as an architectural constraint.)

**Key Points**

- **Explicit Action:** Every comment needs a visible resolution—either a code change or a reply explaining why no change was made.
    
- **Responsiveness:** Addressing feedback promptly prevents "Reviewer's Fatigue" where the context is lost between cycles.
    
- **Gratitude:** A simple "Thanks for catching that" builds social capital and encourages reviewers to be thorough in the future.
    
- **Code over Commentary:** If you have to write a paragraph explaining why the code is correct, the code is likely not clear enough. Refactor the code to make the explanation unnecessary.

---

