## Module Versioning Strategies


[Inference] Effective versioning is crucial for maintaining stable infrastructure:

**Semantic Versioning**: Follow semver (MAJOR.MINOR.PATCH) principles

- MAJOR: Breaking changes that require configuration updates
- MINOR: New features that are backward compatible
- PATCH: Bug fixes and small improvements

**Git Tagging Strategy**:

```bash
git tag -a v1.2.3 -m "Release version 1.2.3"
git push origin v1.2.3
```

**Version Constraints** in module calls:

```hcl
module "example" {
  source  = "company/example/aws"
  version = "~> 1.2"  # Allow 1.2.x, but not 1.3.x
}
```

**Branch-based Development**:

- Use `main` or `master` for stable releases
- Feature branches for development
- Release branches for preparing new versions

