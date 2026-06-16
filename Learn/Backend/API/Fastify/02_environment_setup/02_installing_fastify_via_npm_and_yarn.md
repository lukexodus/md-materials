## Installing Fastify via npm and yarn

### Prerequisites

Before installing Fastify, confirm your environment meets the minimum requirements:

```bash
node --version
npm --version
```

Ensure your Node.js version satisfies the `engines` field declared in Fastify's `package.json`. Refer to the Node.js version requirements topic for details on supported versions.

### Installing with npm

**New project:**

```bash
mkdir my-fastify-app
cd my-fastify-app
npm init -y
npm install fastify
```

`npm init -y` generates a `package.json` with defaults. The `-y` flag skips the interactive prompt.

**Install output (illustrative):**
```
added 15 packages in 3s
```

[Unverified: the exact number of packages installed depends on the Fastify version and its dependency tree at the time of installation]

**Verifying the installation:**

```bash
node -e "const f = require('fastify'); console.log(f.version)"
```

**Output:**
```
5.x.x
```

[Unverified: actual version output depends on the release available at install time]

### Installing with yarn

**Using Yarn Classic (v1):**

```bash
mkdir my-fastify-app
cd my-fastify-app
yarn init -y
yarn add fastify
```

**Using Yarn Berry (v2+):**

```bash
mkdir my-fastify-app
cd my-fastify-app
yarn init
yarn add fastify
```

**Key Points:**
- Yarn Classic and Yarn Berry handle lockfiles and node_modules differently
- Yarn Berry's Plug'n'Play (PnP) mode stores packages in a `.yarn/cache` directory rather than `node_modules` — this may affect module resolution in some edge cases [Inference: PnP compatibility with all Fastify plugins is not universally verified; check individual plugin behavior if using PnP mode]
- Yarn Berry projects should have a `.yarnrc.yml` at the root; Yarn Classic uses `.yarnrc`

### Saving as a Production Dependency

Both `npm install` and `yarn add` save Fastify as a production dependency in `package.json` by default.

**Resulting `package.json` entry:**

```json
{
  "dependencies": {
    "fastify": "^5.0.0"
  }
}
```

The `^` (caret) prefix means npm and yarn will install the latest compatible minor and patch releases within the declared major version. This is the standard and recommended range specifier for most projects.

### Pinning the Version

If your project requires reproducible installs with an exact version, remove the caret:

```json
{
  "dependencies": {
    "fastify": "5.1.0"
  }
}
```

Or install with the exact flag:

```bash
# npm
npm install --save-exact fastify

# yarn
yarn add --exact fastify
```

**Key Points:**
- Pinning prevents unintended updates during fresh installs
- Lockfiles (`package-lock.json`, `yarn.lock`) also serve this purpose when committed to version control — but they only guarantee exact versions when the lockfile is present and respected
- Exact pinning in `package.json` is a stronger constraint than relying on lockfiles alone

### Installing a Specific Version

```bash
# npm
npm install fastify@4.28.0

# yarn
yarn add fastify@4.28.0
```

This is useful when:
- Targeting a specific Fastify major line (e.g., v4 while v5 is current)
- Reproducing a bug reported against a specific release
- Maintaining a legacy project that has not been migrated to the current major

### Installing the Latest Version Explicitly

```bash
# npm
npm install fastify@latest

# yarn
yarn add fastify@latest
```

`@latest` resolves to the most recent stable release. It does not install release candidates or pre-release versions tagged separately.

### Installing a Pre-release or Release Candidate

Release candidates are published under a separate dist-tag:

```bash
# npm
npm install fastify@next

# yarn
yarn add fastify@next
```

[Unverified: the specific dist-tag used for Fastify pre-releases may vary; verify against the npm registry page at `https://www.npmjs.com/package/fastify` before using]

> Pre-release versions are not recommended for production use. They are intended for testing and community feedback before a stable major release.

### Lockfiles and Reproducible Installs

| File | Tool | Purpose |
|---|---|---|
| `package-lock.json` | npm | Locks exact resolved versions of all dependencies |
| `yarn.lock` | Yarn | Locks exact resolved versions of all dependencies |

**Key Points:**
- Lockfiles should be committed to version control for applications
- For published libraries and plugins, lockfiles are typically excluded from the published package (via `.npmignore` or the `files` field in `package.json`) but committed to the repository for development consistency
- Running `npm ci` instead of `npm install` in CI environments installs strictly from the lockfile, refusing to update it

```bash
# CI-safe install — fails if lockfile is out of sync with package.json
npm ci
```

### Installing Fastify Plugins

Official Fastify plugins follow the same installation pattern:

```bash
# npm
npm install @fastify/cors @fastify/jwt @fastify/sensible

# yarn
yarn add @fastify/cors @fastify/jwt @fastify/sensible
```

Each plugin is a separate npm package. Install only the plugins your project requires.

### Global Installation

Fastify itself is not designed to be installed globally — it is a framework dependency of your application, not a standalone CLI tool.

`fastify-cli`, however, is designed for global or `npx`-based use:

```bash
# Global install
npm install --global fastify-cli

# Or use without installing globally
npx fastify-cli generate my-app
```

[Inference: using `npx` avoids polluting the global npm prefix and ensures the latest version of `fastify-cli` is used at the time of execution; behavior depends on npm and npx versions installed]

### Verifying the Installed Package

After installation, confirm Fastify is present and accessible:

```bash
# Check installed version
npm list fastify

# Output (illustrative):
# my-fastify-app@1.0.0
# └── fastify@5.x.x
```

```bash
# Check for peer dependency warnings
npm install
```

npm will report any unmet peer dependencies during install. Review these before proceeding — unmet peer dependencies in plugins can cause runtime errors. [Inference: severity of peer dependency mismatches depends on what the plugin actually uses at runtime; npm warnings are advisory, not always blocking]

### Project Structure After Installation

A minimal project after `npm init -y` and `npm install fastify`:

```
my-fastify-app/
├── node_modules/
│   └── fastify/
│       └── ...
├── package.json
└── package-lock.json
```

A minimal entry point:

```js
// app.js
const fastify = require('fastify')({ logger: true })

fastify.get('/', async (request, reply) => {
  return { status: 'ok' }
})

fastify.listen({ port: 3000 }, (err) => {
  if (err) {
    fastify.log.error(err)
    process.exit(1)
  }
})
```

```bash
node app.js
```

**Output (illustrative):**
```
{"level":30,"time":...,"msg":"Server listening at http://127.0.0.1:3000"}
```

### Practical Guidance

- Commit your lockfile (`package-lock.json` or `yarn.lock`) to version control to produce consistent installs across environments
- Use `npm ci` in CI pipelines rather than `npm install` to enforce lockfile integrity
- Do not mix package managers within the same project — using both npm and yarn can produce conflicting lockfiles and inconsistent `node_modules` states
- After installing new plugins, run your test suite to verify compatibility with your current Fastify version before deploying