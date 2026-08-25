## Explanation documentation


Explanation documentation (often called "Discussions", "Background", or "topic guides") focuses on understanding-oriented content. While reference documentation describes the code, explanation documentation clarifies the context, design decisions, and the "why" behind the implementation. It provides the bigger picture that allows a developer to reason about the system.

**Key Points**

- **Context and Rationale:** This documentation elucidates the problem domain. It answers why a specific architecture was chosen, why a certain library was adopted, or why a specific trade-off was made (e.g., favoring consistency over availability in a database choice).
    
- **Discursive Style:** Unlike the terse nature of reference docs, explanation docs are written in prose. They connect disparate parts of the system, explaining how module A interacts with module B to achieve a business goal.
    
- **Lifecycle Independence:** Explanations should not include code snippets that are likely to rot quickly. Instead of explaining _how to call_ a function (which belongs in Reference or How-to guides), it explains the logic or algorithm _inside_ the function.
    
- **Architecture Decision Records (ADRs):** A specific subset of explanation documentation that captures important architectural decisions, the context at the time, and the consequences. This prevents the "Chesterton's Fence" problem where future developers remove code they don't understand.
    

**Example**

Consider a system using a complex caching strategy.

_Reference (What it does):_

> `Cache.set(key, value, ttl)` sets a value with a time-to-live.

_Explanation (Why it works that way):_

> **Caching Strategy and Eviction Policies**
> 
> Our system uses a Write-Through caching strategy to ensure strong consistency between the cache and the primary database. We selected this over Write-Back because our financial reporting requirements cannot tolerate data loss in the event of a cache node failure.
> 
> While this introduces higher write latency, we mitigate this by using a high-availability Redis cluster. We assume a read-to-write ratio of 95:5. If this ratio shifts significantly, we may need to revisit this decision.

**Conclusion**

Explanation documentation is the institutional memory of a project. It ensures that the knowledge of the system's design principles survives the departure of the original authors, preventing the codebase from becoming "legacy" code that no one dares to touch.

**Next Steps**

Create an `docs/architecture` folder or a wiki section specifically for "Design Docs" and "ADRs". Start by writing one explanation doc for the most complex or non-intuitive part of your current system.

---

