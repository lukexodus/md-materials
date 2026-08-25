## Design review


Key Points

A Design Review (often termed "Architecture Review" or "RFC Process") is the critical "Shift Left" quality gate where proposed system changes are evaluated before a single line of code is written. Its primary goal is to validate feasibility, scalability, and alignment with broader system patterns, reducing the cost of rework.

- **The Artifact (RFC/Design Doc):** The review centers on a written document, not a presentation. This document must articulate:
    
    - **Context:** Why are we doing this? (Business value).
        
    - **Proposed Solution:** High-level architecture, data models, and API contracts.
        
    - **Alternatives Considered:** Why were other approaches rejected? This prevents circular debates during the review.
        
    - **Cross-Cutting Concerns:** Explicit sections for Security, Privacy, Observability (metrics/logging), and Scalability.
        
- **Review Scope & Tiers:**
    
    - **Level 1 (Local):** Small refactors or isolated features. Reviewed by immediate peers.
        
    - **Level 2 (System):** New services, API changes, or schema modifications. Reviewed by Staff/Principal engineers and dependent teams.
        
    - **Level 3 (Cross-Organizational):** Fundamental architectural shifts (e.g., "Monolith to Microservices"). Reviewed by an Architecture Board.
        
- **Common Anti-Patterns:**
    
    - **Bikeshedding:** Focusing on trivial details (naming conventions) while ignoring structural flaws (data consistency issues).
        
    - **Design by Committee:** Trying to incorporate every reviewer's suggestion, resulting in a bloated, incoherent system.
        
    - **The "Big Reveal":** Keeping the design hidden until the review meeting. The document should be circulated for asynchronous comments _before_ any synchronous meeting occurs.
        
- **The "Disagree and Commit" Principle:** A design review is not a search for unanimity. Once risks are logged and the decision maker (usually the author or tech lead) acknowledges them, the team must commit to the path forward to avoid analysis paralysis.
    

Example

Below is a condensed structure of a high-quality Design Document (RFC) intended for review.

> **Title:** Async Notification Service for Order Events
> 
> 1. Problem Statement:
> 
> Synchronous email sending during checkout is causing latency spikes and lost orders if the SMTP provider times out.
> 
> 2. Proposed Solution:
> 
> Decouple checkout from notification using an event-driven architecture.
> 
> - **Producer:** Checkout Service publishes `OrderCreated` event to Kafka topic `orders-v1`.
>     
> - **Consumer:** New `NotificationService` subscribes to `orders-v1` and calls SendGrid.
>     
> 
> 3. Data Model Changes:
> 
> No core schema changes. New Redis cache for idempotency keys (msg_id) in NotificationService with 24h TTL.
> 
> **4. Failure Modes (The most critical section for review):**
> 
> - _Scenario:_ Kafka is down. _Mitigation:_ Checkout Service falls back to writing to a local outbox table (Outbox Pattern).
>     
> - _Scenario:_ Consumer crashes. _Mitigation:_ Kafka consumer group offsets ensure replay upon restart.
>     
> - _Scenario:_ Duplicate messages. _Mitigation:_ Idempotency check via Redis before sending email.
>     
> 
> **5. Alternatives Considered:**
> 
> - _Idea:_ Use Background Jobs (Sidekiq) on the same DB.
>     
> - _Rejection:_ This couples the load. High email volume shouldn't degrade Checkout DB performance.
>     

Output

The outcome of a design review is a decision record, not just a meeting.

- **Approved:** Proceed to implementation.
    
- **Approved with Comments:** Proceed, but address specific minor feedback (no re-review needed).
    
- **Changes Requested:** Significant flaws found (e.g., security risk, inability to scale). The design must be revised and re-reviewed.
    
- **Rejected:** The solution solves the wrong problem or the ROI is insufficient.
    

Conclusion

Design reviews are the most leverage-heavy activity in software engineering. Detecting a circular dependency or a data consistency race condition during the design phase takes minutes to fix (edit text). Detecting it in production requires database migrations, downtime, and weeks of refactoring. A culture of rigorous, written design reviews separates mature engineering organizations from chaotic ones.

Next Steps

Formalize your team's RFC template. Ensure it includes mandatory sections for "Security Implications" and "Testability Strategy" (how the design will be tested) to force consideration of these aspects during the planning phase.

---

