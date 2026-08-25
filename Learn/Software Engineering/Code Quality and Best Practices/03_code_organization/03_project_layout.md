## Project layout


A standardized and predictable project layout is the first line of defense against code entropy. It communicates the project's intent, tooling, and architectural boundaries before a single line of code is read. Uniformity across projects reduces context-switching costs for developers.

**Key Points**

- **Root-Level Standardization:** The root directory should contain meta-information and tooling configuration, not implementation logic.
    
    - `README.md`: Entry point documentation.
        
    - `LICENSE`: Legal definitions.
        
    - `CONTRIBUTING.md`: Guidelines for contributors.
        
    - `Makefile` / `package.json` / `build.gradle`: Build and task automation definitions.
        
    - `.gitignore` / `.dockerignore`: VCS and container exclusions.
        
    - `ci/` or `.github/`: CI/CD pipeline definitions.
        
- **The `src` Directory Pattern:** Encapsulating source code in a specific `src/` directory prevents import confusion and creates a clean separation between source code and project metadata. This prevents "pollution" of the root namespace and simplifies build script patterns (e.g., "compile everything in `src/`").
    
- **Documentation Separation:** Documentation that exceeds the scope of a README belongs in a dedicated `docs/` directory. This should include architecture decision records (ADRs), API specifications (OpenAPI/Swagger), and setup guides.
    
- **Configuration Management:** Configuration files that differ between environments (Dev, Stage, Prod) should be separated from code. Use a `config/` directory for template configurations, but strictly exclude secrets (use `.env` patterns or secret managers).
    
- **Scripts and Tooling:** Ad-hoc scripts for database migrations, data seeding, or local development utilities belong in `scripts/` or `tools/`, distinct from the application's core business logic.
    
- **Asset Segregation:** Static assets (images, fonts, compiled binaries) should be isolated in `assets/`, `static/`, or `dist/` (for build artifacts) directories to prevent cluttering logic directories.
    

**Example**

A robust, language-agnostic directory structure often looks like this:

Plaintext

```
project-root/
├── .github/              # CI/CD workflows
├── configs/              # Environment templates (no secrets)
├── docs/                 # ADRs, API specs
├── scripts/              # Maintenance and build scripts
├── src/                  # Application source code
├── tests/                # Test suite (if not co-located)
├── .gitignore
├── .editorconfig         # Editor coding style consistency
├── docker-compose.yml
├── LICENSE
├── Makefile              # Task runner
└── README.md
```

