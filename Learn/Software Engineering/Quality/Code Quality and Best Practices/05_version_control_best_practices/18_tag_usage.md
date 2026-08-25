## Tag usage


In the context of version control and release management, tags are immutable references to specific points in a project's history. Unlike branches, which are mobile pointers intended for ongoing development, tags are static anchors used to mark release points, significant milestones, or stable states. Proper tag usage is critical for Semantic Versioning (SemVer), traceability, and automated deployment pipelines (CI/CD).

**Key Points**

- **Annotated vs. Lightweight:** Always prefer **Annotated Tags** for public releases. Annotated tags are stored as full objects in the Git database; they contain the tagger name, email, date, and a tagging message. Lightweight tags are merely pointers (like a bookmark) and are best reserved for temporary local markers.
    
- **Semantic Versioning (SemVer):** Tags should strictly follow SemVer formats (e.g., `v1.0.0`, `v2.1.0-beta`). This allows automated tools and package managers to resolve dependencies and understand the impact of updates (Major/Breaking, Minor/Feature, Patch/Fix).
    
- **Immutability:** Once a tag is pushed to a shared repository, it should never be moved or mutated. "Retagging" a release creates chaos for downstream dependencies that have already cached the original artifact. If a release is flawed, issue a new patch tag (e.g., `v1.0.1`), do not overwrite `v1.0.0`.
    
- **Cryptographic Signing:** For high-integrity projects, use GPG-signed tags. This provides cryptographic proof that the release was created by a trusted maintainer and has not been altered, protecting against supply chain attacks.
    
- **CI/CD Triggers:** Modern DevOps pipelines should rely on tags to trigger production deployments. Pushing a tag like `v1.0.0` should automatically trigger the build, test, and publish workflows, ensuring that the deployed artifact exactly matches the tagged commit.
    

**Example**

_Bad (Lightweight/Ambiguous):_

Bash

```
# Creates a simple pointer, no metadata, no message
git tag stable
git push origin stable
```

_Good (Annotated/SemVer):_

Bash

```
# Creates a full object with message and author info
git tag -a v1.2.0 -m "Release v1.2.0: Added payment gateway support"

# Or signed tag (Best Practice)
git tag -s v1.2.0 -m "Release v1.2.0"

# Push specific tag to remote
git push origin v1.2.0
```

---

