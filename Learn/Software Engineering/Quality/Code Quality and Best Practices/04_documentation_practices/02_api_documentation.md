## API documentation


API documentation is the primary interface for the "products" (APIs) developers build. High-quality API documentation treats the API as a product and the developer as the customer. It determines the Developer Experience (DX) and directly influences the adoption rate and ease of integration. In code quality terms, good documentation prevents misuse of endpoints and reduces support overhead.

**The Three Pillars of API Docs**

1. **Reference:** The dictionary of the API. Lists every endpoint, parameter, and response. (e.g., Swagger/OpenAPI).
    
2. **Guides:** "How-to" articles focusing on specific tasks (e.g., "How to Authenticate", "How to Search for Users").
    
3. **Tutorials:** Step-by-step lessons taking the user from zero to a complete integration.
    

Technical Standards: OpenAPI Specification (OAS)

Modern best practice dictates using the OpenAPI Specification (formerly Swagger) to define RESTful APIs.

- **Single Source of Truth:** The OAS file (`yaml` or `json`) defines the contract.
    
- **Automation:** Documentation UIs (Swagger UI, Redoc) are generated automatically from the spec.
    
- **Code Generation:** Client SDKs and server stubs can be generated directly from the documentation source, ensuring code and docs never drift.
    

**Key Components of an Endpoint Doc**

- **Method & URL:** `GET /users/{id}`
    
- **Description:** What the endpoint does and any side effects.
    
- **Authentication:** Specific scopes or tokens required.
    
- **Parameters:** Path, Query, Header, and Body parameters. Must distinguish between _required_ and _optional_.
    
- **Request Example:** A concrete snippet (cURL, Python, JS) showing a valid call.
    
- **Response Example:** The exact JSON/XML returned, including status codes (200, 400, 401, 500) and error structures.
    

Drift Prevention

A common quality issue is "Documentation Drift," where the code changes but the docs do not.

- **Docs as Code:** Store documentation source files in the Git repository with the code.
    
- **Contract Testing:** Use tools like Dredd or Schemathesis in the CI pipeline to validate that the running API matches the OpenAPI definition. If the response differs from the docs, the build fails.
    

**Example**

Endpoint: Get User Profile

Method: GET

Path: /api/v1/users/{userId}

**Parameters**

- `userId` (path, string, required): The UUID of the user.
    

**Responses**

**200 OK**

JSON

```
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "username": "jdoe",
  "email": "jdoe@example.com",
  "created_at": "2023-10-01T12:00:00Z"
}
```

**404 Not Found**

JSON

```
{
  "error": "UserNotFound",
  "message": "No user found with ID 123e4567..."
}
```

---

