## Mob Programming


Mob Programming is a software development approach where the entire team works on the same thing, at the same time, in the same space, and at the same computer. Unlike Pair Programming, which involves two developers, Mob Programming leverages the collective intelligence of the whole team (typically 3+ members) to optimize for flow efficiency, continuous code review, and elimination of knowledge silos.

### Operational Roles and Protocol

To prevent chaos and ensure engagement, Mob Programming enforces strict role definitions. The primary distinction lies in the separation of _thinking_ from _typing_.

- **The Driver:**
    
    - **Responsibility:** Acts purely as an intelligent input device. The Driver focuses on the mechanics of coding (syntax, shortcuts, typing) but contributes _zero_ tactical or strategic direction during their turn.
        
    - **Constraint:** The Driver must not write code that has not been explicitly verbalized by the Navigator.
        
- **The Navigator:**
    
    - **Responsibility:** Holds the tactical plan. The Navigator articulates the immediate coding intent to the Driver, translating abstract solutions into specific implementation instructions.
        
    - **Scope:** Focuses on the "what" and "how" of the current line of code.
        
- **The Mob (Rest of Team):**
    
    - **Responsibility:** Focuses on the strategic horizon, quality assurance, and edge-case analysis. They research documentation, propose refactoring opportunities, and prepare for the next logical step.
        
    - **Constraint:** Must not interrupt the Navigator with micro-optimization unless a critical error is imminent. Feedback is channeled to the Navigator to maintain a single stream of thought.
        

### Strong-Style Pairing

Mob Programming relies heavily on Llewellyn Falco’s "Strong-Style Pairing" rule: _"For an idea to go from your head into the computer, it must go through someone else's hands."_

This protocol forces high-bandwidth communication and ensures that the Driver (and by extension, the team) understands the code being written. If the Driver does not understand the instruction, the Navigator must refine their communication or explain the concept, effectively turning every coding session into a knowledge-transfer event.

### Rotation and Timeboxing

Sustaining high cognitive load requires frequent context switching for the Driver to prevent fatigue.

- **Micro-Rotations:** A strict timer (typically 5 to 15 minutes) dictates role rotation. When the timer expires, the Driver moves to the Mob, the Navigator becomes the Driver, and a new Navigator steps up.
    
- **Handover Protocol:** Code must be in a compilable (though not necessarily passing) state before rotation. Some teams enforce a "commit on green" rule where rotation occurs only after a passing test.
    

### Economic Model: Flow Efficiency vs. Resource Efficiency

Traditional management optimizes for **Resource Efficiency** (keeping every developer busy typing), which often leads to high Work In Progress (WIP), context switching, and merge conflicts. Mob Programming optimizes for **Flow Efficiency** (minimizing the time a work item takes to go from start to completion).

- **Elimination of Queues:** By combining development, testing, and review into a synchronous activity, the "waiting for code review" state is eliminated. The Pull Request lifecycle is effectively zero.
    
- **Reduction of WIP:** The team works on exactly one item at a time. This aligns with Lean principles, drastically reducing inventory (unmerged code).
    
- **Bus Factor Mitigation:** Knowledge is shared synchronously. The loss of a single team member does not halt progress or create a knowledge vacuum.
    

### Failure Modes and Anti-Patterns

- **The Dominator:** A senior developer monopolizes the Navigator role or overrides the current Navigator, reducing the rest of the mob to spectators. This reintroduces silos and disengages the team.
    
- **The Passive Driver:** A Driver who robotically types without understanding. While the Driver shouldn't design, they must comprehend the syntax to remain effective when they rotate into the Navigator role.
    
- **Traffic Jam:** When too many voices speak at once. The Driver should only listen to the designated Navigator. The Mob must filter their input through the Navigator or wait for a "discussion gap."
    
- **Local Optimization:** The Mob focuses intensely on a specific algorithm but loses sight of the architectural goal. Periodic "zoom out" breaks are required to realign with the broader design.

---

