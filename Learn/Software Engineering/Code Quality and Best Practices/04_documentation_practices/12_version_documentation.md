## Version documentation


Version documentation ensures that users can access accurate instructions corresponding to the specific version of the software they are currently using. As software evolves, documentation drift—where the manual describes features that don't exist yet or no longer exist—becomes a major source of technical debt and user frustration.

**Key Points**

- **Docs-as-Code:** Documentation should live in the same repository as the source code (e.g., inside a `/docs` directory). This ensures that documentation updates are reviewed in the same Pull Request as the code changes, enforcing the rule: "The feature is not done until it is documented."
    
- **Snapshotting/Versioning Strategy:**
    
    - **Branch-based:** Documentation is built from the specific git branch (e.g., `release/v1.0`, `release/v2.0`).
        
    - **Tag-based:** Documentation generators (like Docusaurus, MkDocs, or Javadoc) are configured to build static sites for each git tag.
        
- **Navigation and UX:**
    
    - The documentation UI must provide a clear "Version Switcher" dropdown.
        
    - Users landing on an old version (via search engine links) should see a prominent banner: _"You are viewing documentation for an older version. Click here for the latest release."_
        
- **Deprecation Lifecycle:**
    
    - Documentation for deprecated features should not just be removed immediately. It should be marked as **[Deprecated]** with a link to the migration guide or the replacement feature.
        
    - Only remove documentation when the feature is physically removed from the codebase (usually in a Major version bump).
        
- **API Specification Versioning:**
    
    - For REST/gRPC APIs, maintain versioned schemas (OpenAPI/Swagger definitions).
        
    - Use tools like `Swagger UI` or `ReDoc` that support selecting the API definition version (e.g., `/v1/swagger.json` vs `/v2/swagger.json`).
        
- **Long-Term Support (LTS):** Clearly define which documentation versions are actively maintained. Archived versions should be static and read-only.
    

**Example**

**Directory structure for versioned documentation (Docusaurus style):**

Plaintext

```
website/
├── docs/                   # Current (Next) version documentation
│   ├── intro.md
│   └── api.md
├── versioned_docs/
│   ├── version-1.0.0/      # Snapshot of 1.0.0 docs
│   │   ├── intro.md
│   │   └── api.md
│   └── version-1.1.0/      # Snapshot of 1.1.0 docs
├── versioned_sidebars/     # Navigation menus for each version
│   ├── version-1.0.0-sidebars.json
│   └── version-1.1.0-sidebars.json
└── versions.json           # List of available versions ["1.1.0", "1.0.0"]
```

---

