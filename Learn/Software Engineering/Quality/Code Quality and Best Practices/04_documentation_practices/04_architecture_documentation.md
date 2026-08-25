## Architecture documentation


Architecture documentation describes the high-level design of a software system. It focuses on the "macro" view: how components interact, how data flows, where the software is deployed, and the rationale behind critical design decisions. It serves as the map for the territory of the codebase.

**Key Points**

- **Architecture Decision Records (ADRs):** This is a critical best practice. An ADR captures a specific architectural decision (e.g., "Use Postgres instead of Mongo"), the context, the alternatives considered, and the consequences (pros/cons). This prevents the "Chesterton's Fence" problem where future developers don't know why a decision was made.
    
- **Docs-as-Code:** Treat architecture documentation like source code. Store it in the repository (e.g., in a `/docs` folder or `ARCHITECTURE.md`), write it in Markdown, and review it via Pull Requests. This ensures version control and accessibility.
    
- **Visual Standards (C4 Model):** Avoid ad-hoc "boxes and arrows." Adopt a standard like the C4 model (Context, Containers, Components, Code) to create diagrams that have a consistent level of abstraction.
    
- **Multiple Views:** A single diagram is rarely enough. Use different views for different stakeholders:
    
    - _Logical View:_ Functional requirements and class structures.
        
    - _Process View:_ Concurrency, threads, and synchronization.
        
    - _Physical/Deployment View:_ Hardware, cloud resources, and networking.
        
- **Living Documents:** Architecture docs tend to rot faster than code docs. Focus on documenting the invariants and high-level patterns rather than low-level implementation details that change weekly.
    

**Example**

Bad Practice

A shared folder containing files like SystemDesign_Final_v2.docx and Architecture_2022.vsdx. These are disjointed from the code, unsearchable, and likely outdated.

Good Practice (ADR Structure)

Title: ADR-005: Use Redis for Session Caching

**Status:** Accepted

Context:

We are experiencing high latency in the primary SQL database due to frequent session read/writes. We need a faster, volatile storage solution for session data.

Decision:

We will implement Redis as the session store.

**Consequences:**

- _Positive:_ Reduces load on SQL DB by 40%; sub-millisecond session retrieval.
    
- _Negative:_ Adds a new infrastructure dependency (Redis instance) that must be managed and backed up.

---

