## Documentation Review


Documentation review is the quality assurance process for technical writing, ensuring that documentation is accurate, clear, and usable. It should be treated with the same rigor as code review, ideally occurring alongside the code changes that necessitated the documentation update.

**Technical Accuracy and Verifiability**

- **Execute Code Samples:** The most critical validation step. Never assume a snippet works. Copy, paste, and execute every command, script, and API call in the documentation. If the instructions fail during the review, they will fail for the user.
    
- **Verify Constraints:** Check if stated limits (e.g., "max file size 5MB", "supports only Python 3.8+") remain accurate against the current implementation.
    
- **Synchronization:** Ensure parameter names, return types, and endpoint URLs in the documentation match the exact signature in the codebase. Discrepancies here are the leading cause of developer friction.
    

**Audience and Clarity**

- **Target Persona:** Verify the tone and depth match the intended audience. An API reference for developers requires technical precision and edge cases, while a "Getting Started" guide for end-users should avoid internal jargon and implementation details.
    
- **Consistency:** Flag inconsistent terminology. Do not interchange terms like "service," "daemon," and "worker" if they refer to the same entity.
    
- **Action-Oriented Structure:** Documentation should guide the user to a result. Review for the presence of clear "How-to" steps rather than just passive descriptions of system behavior.
    

**Completeness and Context**

- **Prerequisites:** Ensure the document clearly lists all necessary tools, access rights, keys, and dependencies required before starting the task. A guide that fails at step 1 due to missing environment setup is functionally useless.
    
- **Error Handling:** A robust review checks for "What if?" scenarios. The documentation should anticipate common errors (e.g., 401 Unauthorized, Connection Timeout) and explain how to resolve them.
    
- **Visual Assets:** Verify that screenshots, architectural diagrams, and tables reflect the current state of the UI and system. Outdated visuals are often more confusing than having no visuals at all.
    

**Maintenance and Hygiene**

- **Link Validation:** Manually check all internal and external hyperlinks. "Link rot" (broken links) significantly degrades the authority and trustworthiness of the documentation.
    
- **Versioning:** Ensure the documentation version aligns with the software release. Features currently in a beta branch must be marked clearly if they are documented in the main branch, or kept in a separate documentation version.
    

**Docs-as-Code Integration**

- **Co-located Reviews:** Documentation changes should be included in the same Pull Request/Merge Request as the code feature they describe. This enforces the rule that a feature is not "done" until it is documented.
    
- **Automated Linting:** Utilize prose linters (e.g., Vale, textlint) to automate checks for style guide compliance, spelling, and headers. This allows human reviewers to focus on logic and accuracy rather than grammar.

---

