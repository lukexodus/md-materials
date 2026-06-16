## Node.js Version Requirements

### Overview

Fastify's support for Node.js versions is formally defined and tied to the Node.js release schedule. Running Fastify on an unsupported Node.js version is not recommended and may produce unexpected behavior. [Inference: specific failure modes on unsupported versions are not documented exhaustively and may vary]

### Node.js Release Types

To understand Fastify's requirements, it helps to understand how Node.js versions are classified:

| Status | Meaning |
|---|---|
| **Current** | Latest Node.js release line; receives new features |
| **Active LTS** | Long Term Support — stable, receives fixes and security patches |
| **Maintenance LTS** | Security and critical fixes only; approaching end of life |
| **End of Life (EOL)** | No further updates; not supported by Node.js project |

The Node.js release schedule is published at [`https://nodejs.org/en/about/releases/`](https://nodejs.org/en/about/releases/).

### Fastify's Official Support Policy

Fastify's stated policy is to support all Node.js versions that are **Active LTS** or **Maintenance LTS** at the time of a given Fastify release.

**Key Points:**
- The **Current** Node.js release line may work with Fastify but is not guaranteed to be formally supported until it enters LTS
- EOL Node.js versions are not supported — Fastify may drop them without a major version bump, per its stated policy
- Dropping an EOL Node.js version is classified as a non-breaking change by Fastify's versioning policy

[Inference: "may work" does not constitute support; behavior on unsupported versions is not verified or guaranteed by the maintainers]

### Checking the Current Requirement

The authoritative source for the current Node.js version requirement is the Fastify repository itself — specifically:

- The `engines` field in `package.json`
- The LTS documentation at `docs/Reference/LTS.md`

**Example `engines` field (illustrative — verify against current source):**

```json
{
  "engines": {
    "node": ">=18.0.0"
  }
}
```

[Unverified: the specific version number above is illustrative only; always verify against the current published `package.json` in the Fastify repository]

The `engines` field is the definitive programmatic declaration. npm will emit a warning if your Node.js version does not satisfy this range, though it will not block installation by default.

### Fastify v4 and v5 Node.js Requirements

> [Unverified: the following reflects documented requirements as of the time this content was written. Requirements may have changed. Verify at [`https://github.com/fastify/fastify/blob/main/docs/Reference/LTS.md`](https://github.com/fastify/fastify/blob/main/docs/Reference/LTS.md)]

| Fastify Version | Minimum Node.js Version |
|---|---|
| v4.x | `>=14.6.0` |
| v5.x | `>=20.0.0` |

Fastify v5 raised the minimum Node.js requirement significantly, aligning with Node.js 20 entering LTS status and dropping support for older lines that had reached EOL.

### Why the Minimum Version Matters

Fastify's internals and its dependencies may use Node.js APIs that are not available in older versions. The minimum version requirement reflects:

- Use of modern `async`/`await` patterns and Promise-based APIs throughout the codebase
- Reliance on specific `http`, `stream`, and `buffer` APIs whose behavior or availability differs across versions
- Dependencies (such as Pino and Ajv) that may themselves declare minimum Node.js version requirements

[Inference: the specific APIs driving any particular minimum version requirement would need to be verified against Fastify's source and dependency tree for each release]

### ESM and CommonJS Support

Node.js's native ES Module (ESM) support stabilized across the v12–v14 range. Fastify supports both CommonJS and ESM module formats.

**CommonJS:**
```js
const fastify = require('fastify')
```

**ESM:**
```js
import Fastify from 'fastify'
```

**Key Points:**
- ESM support in Fastify depends on the Node.js version's own ESM stability
- Using ESM with older Node.js versions that have incomplete or experimental ESM support may produce issues [Inference: behavior depends on the specific Node.js minor version and module interop edge cases]
- Fastify's official plugin ecosystem increasingly supports both formats, but individual plugin compatibility should be verified per package

### The `--experimental-*` Flag Consideration

Some Node.js features used in the broader Fastify ecosystem (such as certain stream APIs or diagnostic channel support) moved from experimental to stable across Node.js versions. Running Fastify on a version where a required feature is still experimental means:

- The API may change in a future Node.js release
- Behavior may differ from the stable version

[Inference: whether Fastify itself or any given plugin relies on a feature that is experimental in a particular Node.js version must be verified against that plugin's documentation and Node.js version history]

### Checking Your Node.js Version

```bash
node --version
```

**Output:**
```
v20.11.0
```

To check whether your version satisfies a package's `engines` requirement:

```bash
node -e "const v = process.versions.node; console.log(v)"
```

Or use `npm`:

```bash
npm install fastify
```

npm will warn during install if your Node.js version does not satisfy the declared `engines` range.

### Version Management Tools

When working across multiple projects with different Node.js version requirements, a version manager is recommended:

| Tool | Description |
|---|---|
| [`nvm`](https://github.com/nvm-sh/nvm) | Node Version Manager — shell-based, widely used on Unix/macOS |
| [`fnm`](https://github.com/Schniz/fnm) | Fast Node Manager — Rust-based, cross-platform |
| [`volta`](https://volta.sh/) | JavaScript toolchain manager with per-project pinning |
| [`n`](https://github.com/tj/n) | Simple Node.js version manager |

**Pinning a Node.js version per project using `.nvmrc`:**

```
20.11.0
```

Place this file at the project root. Running `nvm use` in that directory switches to the specified version automatically (with shell integration configured).

### Practical Guidance

- Always verify the `engines` field in Fastify's `package.json` before starting a project or upgrading
- Do not assume that a version working today will continue to work after a Fastify minor or patch release if your Node.js version is near or past EOL
- When upgrading Fastify major versions, treat the Node.js minimum version requirement as a hard prerequisite — not an advisory
- In CI pipelines, test against the minimum supported Node.js version and the current Active LTS version at minimum to catch version-specific issues early

**Example GitHub Actions matrix for Node.js version coverage:**

```yaml
strategy:
  matrix:
    node-version: [20, 22]

steps:
  - uses: actions/setup-node@v4
    with:
      node-version: ${{ matrix.node-version }}
```

[Inference: specific Node.js versions to include in CI should reflect the versions Fastify currently supports; verify against the LTS documentation before configuring]