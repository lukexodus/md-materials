## Versioning and Release Policy

### Semantic Versioning

Fastify follows [Semantic Versioning](https://semver.org/) (SemVer), using the `MAJOR.MINOR.PATCH` format.

| Version Component | Meaning |
|---|---|
| `MAJOR` | Breaking changes — not backwards compatible |
| `MINOR` | New features — backwards compatible |
| `PATCH` | Bug fixes — backwards compatible |

**Example:**

- `4.0.0` → `5.0.0` : Breaking change (major release)
- `4.26.0` → `4.27.0` : New feature added (minor release)
- `4.27.0` → `4.27.1` : Bug fix (patch release)

### Release Lines and Active Support

Fastify maintains multiple release lines simultaneously. At any given time, there is typically one **current major** receiving active feature development, and one or more **previous majors** receiving security and critical bug fixes only.

**Key Points:**
- The current major line receives new features, improvements, and bug fixes
- Previous major lines receive Long Term Support (LTS) — limited to security patches and critical fixes
- End-of-Life (EOL) lines receive no further updates

> **Note:** The exact dates and active lines change over time. Always check the official [Fastify LTS documentation](https://github.com/fastify/fastify/blob/main/docs/Reference/LTS.md) for current support status. The information below reflects the documented policy structure, not a guaranteed current state.

### Node.js Version Support Policy

Fastify's support for Node.js versions is tied directly to the [Node.js LTS schedule](https://nodejs.org/en/about/releases/).

**Key Points:**
- Fastify supports all Node.js versions that are in **Active LTS** or **Maintenance LTS** status
- When a Node.js version reaches End-of-Life, Fastify may drop support for it in a future release
- Dropping an EOL Node.js version is treated as a non-breaking change by Fastify's policy — it may occur in a minor release [Inference: based on documented policy; verify against current Fastify release notes for specific versions]

**Example:**

If Node.js 18 enters Maintenance LTS and Node.js 16 reaches EOL, Fastify may remove Node.js 16 support without incrementing the major version.

> **Disclaimer:** Policy decisions about Node.js version drops are at the maintainers' discretion and may not always align exactly with the stated policy. Actual behavior may vary.

### How Breaking Changes Are Handled

Fastify's maintainers distinguish between different categories of changes:

**Non-breaking (may appear in MINOR or PATCH):**
- New route options or plugin APIs
- New lifecycle hooks
- Performance improvements with no API surface change
- Dropping EOL Node.js versions (per stated policy)

**Breaking (requires MAJOR increment):**
- Changes to the public API — `fastify` instance methods, `Request`, `Reply`
- Changes to plugin or decorator contracts
- Modifications to hook execution order
- Alterations to default error response shape

### The Release Process

Fastify uses a structured release process managed through its GitHub repository.

**Key Points:**
- Releases are tagged on the `main` branch (or a dedicated release branch for older lines)
- Changelogs are maintained per release and published alongside GitHub releases
- Release candidates (`rc`) may be published before major versions for community testing

**Example version tag formats:**
```
v4.27.1       ← stable patch
v5.0.0-rc.1   ← release candidate for major version
v5.0.0        ← stable major
```

### Deprecation Policy

Before removing a feature or API, Fastify typically follows a deprecation cycle:

1. The feature is marked deprecated in documentation and may emit a runtime warning
2. The deprecated feature remains functional through at least one major version
3. Removal occurs in a subsequent major version

[Inference: this reflects the general open-source practice described in Fastify's contribution and governance documentation; specific deprecation timelines are not guaranteed and depend on maintainer decisions]

### Changelog and Upgrade Guides

For each major version, Fastify publishes migration and upgrade documentation.

**Key Points:**
- The `CHANGELOG.md` in the repository lists every change per release
- Major version upgrades are accompanied by a migration guide in the official docs
- The migration guide identifies removed APIs, changed defaults, and recommended replacements

**Where to find them:**
- Changelog: [`https://github.com/fastify/fastify/blob/main/CHANGELOG.md`](https://github.com/fastify/fastify/blob/main/CHANGELOG.md)
- LTS policy: [`https://github.com/fastify/fastify/blob/main/docs/Reference/LTS.md`](https://github.com/fastify/fastify/blob/main/docs/Reference/LTS.md)

### Plugin Versioning and Ecosystem Compatibility

Fastify's plugin ecosystem follows a peer dependency model tied to Fastify's major version.

**Key Points:**
- Official plugins (under the `@fastify/` npm scope) publish their own SemVer versions
- Each plugin declares a `fastify` peer dependency range specifying which major versions it supports
- A plugin built for Fastify v4 may not be compatible with Fastify v5 without an update

**Example `package.json` peer dependency declaration in a plugin:**

```json
{
  "peerDependencies": {
    "fastify": "^5.0.0"
  }
}
```

When upgrading Fastify's major version, all plugins must be checked for compatible versions. [Inference: compatibility depends on each individual plugin's release cadence and maintainer activity; not all plugins may have a compatible version available at the time of a Fastify major release]

### Practical Guidance When Upgrading

- Pin to a minor version range (e.g., `"fastify": "^4.0.0"`) in production to receive patches and minor features without accidental major upgrades
- Review the changelog and migration guide before any major version upgrade
- Check all `@fastify/*` plugin versions for compatibility with the target Fastify major
- Test against release candidates when they are published — this is the intended window for community feedback before a stable major release
- Subscribe to GitHub releases on the Fastify repository to receive notifications of new versions