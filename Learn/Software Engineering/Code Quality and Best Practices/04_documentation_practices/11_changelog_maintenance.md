## Changelog maintenance


A changelog is a curated, chronologically ordered list of notable changes for each version of a project. Unlike a raw git commit history, which describes _how_ code changed line-by-line, a changelog describes _what_ changed from the perspective of the end-user or consumer. It serves as a critical communication bridge between maintainers and users, building trust and reducing upgrade friction.

**Key Points**

- **Audience-Centricity:** The primary reader is a human (user or developer), not a machine. Descriptions should focus on the impact of the change (e.g., "Fixed login crash on iOS 15") rather than the implementation detail (e.g., "Handled null pointer in AuthController").
    
- **The "Keep a Changelog" Standard:**
    
    - **Unreleased:** Keep a section at the top for changes that have merged to the main branch but haven't been tagged in a release yet. This prevents the "changelog scramble" at release time.
        
    - **Categorization:** Group changes within a version by type to improve scannability:
        
        - `Added`: New features.
            
        - `Changed`: Changes in existing functionality.
            
        - `Deprecated`: Features that will be removed in future releases.
            
        - `Removed`: Features deleted in this release.
            
        - `Fixed`: Bug fixes.
            
        - `Security`: Vulnerability patches.
            
- **Semantic Versioning Alignment:** The changelog must strictly mirror the versioning strategy (e.g., SemVer). Breaking changes must be highlighted prominently, as they dictate major version bumps.
    
- **Automation vs. Curation:**
    
    - **Automated:** Tools like `semantic-release` or `standard-version` can generate changelogs by parsing "Conventional Commits" (e.g., `feat:`, `fix:`). This ensures consistency but can lack context.
        
    - **Curated:** Manual editing is often required to summarize complex refactors into a single intelligible entry or to group related changes that span multiple commits.
        
- **Immutability:** Once a version is released and the changelog entry is finalized, it should not be altered. Corrections to history are rare and should be noted explicitly.
    

**Example**

A standard `CHANGELOG.md` following best practices:

Markdown

```
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- distinct_id support for server-side events.

## [1.0.0] - 2023-10-15
### Changed
- **BREAKING**: `init()` now returns a Promise instead of void.
- Migrated the internal database from SQLite to PostgreSQL.

### Fixed
- Fixed a race condition in the WebSocket reconnection logic.
```

