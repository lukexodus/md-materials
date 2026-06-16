## Community, Ecosystem, and Resources

### The Fastify Organization on GitHub

Fastify's development is centered on the [`fastify` GitHub organization](https://github.com/fastify). This is the canonical source for the core framework, official plugins, and related tooling.

**Key Points:**
- The main framework lives at `github.com/fastify/fastify`
- Official plugins are published under the `@fastify/` npm scope and maintained in the same organization
- Issues, feature requests, and pull requests are managed through GitHub
- The organization uses GitHub Discussions for community questions alongside GitHub Issues for bugs and proposals

### Core Team and Governance

Fastify is maintained by a team of open-source contributors. The project follows a collaborative governance model.

**Key Points:**
- The project has a defined set of maintainers with merge rights
- Decisions about the roadmap, breaking changes, and policy are made through discussion in GitHub issues and pull requests
- A `CONTRIBUTING.md` guide in the repository defines the contribution process
- A `CODE_OF_CONDUCT.md` defines expected community behavior

[Inference: governance details may evolve over time; the above reflects the structure documented in the repository at the time of this writing and is not guaranteed to remain unchanged]

### The `@fastify/` Plugin Scope

The `@fastify/` npm scope contains officially maintained plugins. These are distinct from community plugins in that they are maintained by the Fastify core team or trusted contributors within the organization.

**Selected official plugins:**

| Package | Purpose |
|---|---|
| `@fastify/cors` | Cross-Origin Resource Sharing (CORS) headers |
| `@fastify/jwt` | JSON Web Token authentication |
| `@fastify/cookie` | Cookie parsing and serialization |
| `@fastify/static` | Serving static files |
| `@fastify/multipart` | Multipart form data and file uploads |
| `@fastify/rate-limit` | Request rate limiting |
| `@fastify/swagger` | OpenAPI/Swagger spec generation |
| `@fastify/swagger-ui` | Swagger UI served from a Fastify instance |
| `@fastify/helmet` | Security headers via `helmet` |
| `@fastify/postgres` | PostgreSQL connection plugin |
| `@fastify/redis` | Redis client plugin |
| `@fastify/sensible` | Useful HTTP utilities and error helpers |
| `@fastify/autoload` | Automatic plugin and route loading from filesystem |
| `@fastify/env` | Environment variable validation and loading |
| `@fastify/formbody` | `application/x-www-form-urlencoded` body parsing |

> **Note:** Plugin availability, names, and scope may change. Always verify against the [official npm registry](https://www.npmjs.com/search?q=%40fastify) and the [Fastify GitHub organization](https://github.com/fastify).

### Community Plugins

Beyond the `@fastify/` scope, a broad ecosystem of community-maintained plugins exists. These are published by independent authors and are not officially maintained by the Fastify core team.

**Key Points:**
- Community plugins follow the same `fastify-plugin` encapsulation conventions as official plugins
- Quality, maintenance activity, and compatibility vary between community packages [Unverified for any specific package]
- The Fastify ecosystem page and npm search are the primary discovery mechanisms

**Evaluating a community plugin:**
- Check the declared `fastify` peer dependency version range
- Review the repository's issue tracker for open bugs and recent activity
- Check when the last release was published relative to the current Fastify major

### The Fastify Ecosystem Page

Fastify maintains a curated ecosystem listing in its official documentation:

[`https://fastify.dev/ecosystem/`](https://fastify.dev/ecosystem/)

This page lists both official and notable community plugins, organized by category. It is a useful starting point when looking for integrations before searching npm directly.

### Official Documentation

The official documentation is hosted at:

[`https://fastify.dev/docs/latest/`](https://fastify.dev/docs/latest/)

**Documentation structure:**
- **Reference** — API documentation for the core framework, decorators, hooks, lifecycle
- **Guides** — Practical how-to articles covering common patterns
- **Tutorials** — Step-by-step introductions for new users
- **Migration Guides** — Version-specific upgrade instructions

Versioned documentation for older major releases is also accessible through the documentation site.

### Community Channels

**Discord:**
Fastify operates an official Discord server, linked from the GitHub repository and documentation site. This is the primary real-time community space for questions, discussion, and support.

**GitHub Discussions:**
Longer-form questions, proposals, and community conversation are hosted in GitHub Discussions at `github.com/fastify/fastify/discussions`.

**Stack Overflow:**
Questions tagged [`fastify`](https://stackoverflow.com/questions/tagged/fastify) on Stack Overflow represent a searchable archive of community Q&A.

**Twitter / X:**
[Unverified: social media presence details change frequently; check the official documentation or GitHub organization page for current official accounts]

### `fastify-plugin` — The Foundation of the Ecosystem

Understanding `fastify-plugin` is essential for working with the ecosystem. It is a small utility that controls plugin encapsulation behavior.

**Key Points:**
- By default, Fastify plugins run in an encapsulated child scope — decorators, hooks, and routes defined inside do not leak to the parent
- Wrapping a plugin with `fastify-plugin` opts it out of encapsulation, making its additions visible to the wider application scope
- Most reusable plugins (database connectors, authentication layers) use `fastify-plugin` so their decorators are accessible application-wide

```js
const fp = require('fastify-plugin')

async function myPlugin(fastify, options) {
  fastify.decorate('db', createDatabaseConnection(options))
}

module.exports = fp(myPlugin, {
  fastify: '>=4.0.0',
  name: 'my-db-plugin'
})
```

The `fastify` field in the options object declares compatibility — this is the mechanism by which plugin authors communicate which Fastify major versions their plugin supports.

### Tooling and Related Projects

Several related projects exist within the Fastify ecosystem:

| Project | Purpose |
|---|---|
| `fastify-cli` | Scaffold, run, and manage Fastify projects from the command line |
| `fastify-plugin` | Encapsulation control utility for plugin authors |
| `find-my-way` | The underlying radix-tree router (usable independently) |
| `fast-json-stringify` | Schema-compiled JSON serializer (usable independently) |
| `light-my-request` | HTTP injection for testing Fastify apps without a live server |
| `pino` | Default logger (developed alongside Fastify, usable independently) |
| `mercurius` | GraphQL adapter for Fastify |
| `platformatic` | Higher-level application platform built on top of Fastify |

### `fastify-cli`

`fastify-cli` provides a command-line interface for working with Fastify projects.

**Key Points:**
- Scaffolds new projects with an opinionated directory structure
- Provides a `fastify start` command for running applications with watch mode
- Integrates with `@fastify/autoload` for filesystem-based plugin and route loading

```bash
npm install --global fastify-cli
fastify generate my-app
cd my-app
npm install
npm start
```

[Inference: CLI commands and scaffolded structure may differ across versions; verify against the current `fastify-cli` documentation]

### Testing Utilities

**`light-my-request`** is the recommended tool for testing Fastify applications. It injects HTTP requests directly into the Fastify instance without binding to a port.

```js
const fastify = require('./app')

test('GET /health returns 200', async (t) => {
  const response = await fastify.inject({
    method: 'GET',
    url: '/health'
  })

  t.equal(response.statusCode, 200)
})
```

**Key Points:**
- No network port is opened during tests — requests are passed in-process
- The full Fastify lifecycle (hooks, validation, serialization) executes normally
- Compatible with any Node.js test runner — Node's built-in `node:test`, `tap`, `jest`, `vitest`, and others

### Learning Resources

**Official:**
- [fastify.dev](https://fastify.dev) — primary documentation and guides
- [GitHub repository](https://github.com/fastify/fastify) — source, issues, changelogs, and discussions
- [YouTube — Fastify channel](https://www.youtube.com/@fastifyjs) — [Unverified: verify current availability and activity]

**Community and Third-Party:**
- Conference talks by core maintainers (Matteo Collina, Tomas Della Vedova, and others) are available on YouTube through Node.js conference recordings [Unverified: availability of specific talks should be verified directly]
- Blog posts and tutorials on platforms such as Dev.to and Medium exist for common Fastify patterns [Unverified: quality and currency of individual articles vary]

> For any third-party learning resource, verify that the Fastify version covered matches the version you are using, as API differences between major versions are significant.

### Contributing to Fastify

**Key Points:**
- All contributions go through pull requests on GitHub
- The `CONTRIBUTING.md` file in the repository defines code style, test requirements, and the review process
- First-time contributors are directed to issues labeled `good first issue`
- Plugin contributions to the `@fastify/` scope require following the organization's plugin template and review standards

**Contribution entry points:**
- Bug reports and reproductions via GitHub Issues
- Documentation improvements via pull requests to the `fastify/website` repository
- Plugin development and publishing as community packages