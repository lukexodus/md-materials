## User Documentation


User documentation encompasses materials for anyone consuming the software, whether they are end-users (GUI applications) or other developers (libraries/APIs). High-quality user documentation reduces the support burden and drives adoption. It must be decoupled from implementation details; users care about _behavior_ and _outcomes_, not internal algorithms.

**Key Points**

- **The Diátaxis Framework:** Structure documentation into four distinct quadrants based on user needs:
    
    - _Tutorials:_ Learning-oriented lessons (e.g., "Build your first App").
        
    - _How-to Guides:_ Problem-oriented steps (e.g., "How to reset a password").
        
    - _Reference:_ Information-oriented technical descriptions (e.g., API endpoint parameters).
        
    - _Explanation:_ Understanding-oriented background knowledge (e.g., "How the consensus algorithm works").
        
- **API Documentation:** For developer-facing products, generate documentation automatically from code annotations (Javadoc, Swagger, Doxygen). Ensure every parameter, return value, and possible error code is documented with examples.
    
- **Versioning:** Documentation must be versioned alongside the software. Users on v1.0 must not see v2.0 instructions. Deprecated features must be clearly marked with migration paths.
    
- **Completeness vs. Conciseness:** Use "progressive disclosure." Show the most common use cases first. Hide advanced configuration options behind "Advanced" sections to avoid cognitive overload for new users.
    
- **Feedback Loops:** Integrate mechanisms for users to flag outdated or confusing documentation directly within the docs (e.g., "Edit this page" links or feedback widgets).
    

**Example**

_Differentiation between Reference and How-to:_

- **Reference (API):**
    
    > `POST /api/v1/users`
    
    > - `username` (string, required): Alphanumeric, 3-20 chars.
    >     
    > - `role` (enum): [ADMIN, USER, GUEST]. Default: USER.
    >     
    > - _Returns:_ 201 Created on success.
    >     
    
- **How-to Guide:**
    
    > **Creating a New Administrator**
    
    > 1. Authenticate using your root credentials.
    >     
    > 2. Send a POST request to `/api/v1/users`.
    >     
    > 3. Set the role parameter specifically to ADMIN.
    >     
    >     Note: This action triggers an audit log entry.

---

