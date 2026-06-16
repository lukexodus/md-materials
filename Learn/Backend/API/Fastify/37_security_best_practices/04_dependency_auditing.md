## Dependency Auditing

Fastify applications depend on a supply chain of npm packages — Fastify core, official plugins, community plugins, and transitive dependencies of all of the above. Dependency auditing is the practice of systematically identifying, tracking, and responding to known vulnerabilities in that supply chain. It spans tooling, workflow integration, policy decisions, and operational response procedures.

---

### Why Dependency Auditing Matters for Fastify Projects

Fastify's plugin ecosystem is a core architectural feature — most non-trivial applications register several official and third-party plugins. Each registered plugin extends the attack surface:

- A vulnerability in `@fastify/multipart` affects file upload endpoints.
- A vulnerable version of `ajv` (Fastify's validator) could affect request validation behavior.
- A compromised transitive dependency (supply chain attack) may introduce malicious code regardless of the direct dependency's integrity.

[Inference] The density of the plugin ecosystem means Fastify applications tend to have deeper and wider dependency trees than minimal Node.js HTTP servers — systematic auditing is correspondingly more important, not less.

---

### `npm audit` — Baseline Tooling

`npm audit` queries the npm advisory database for known vulnerabilities in the installed dependency tree. It is the minimum baseline — not a complete auditing strategy.

```bash
# Run audit and display results
npm audit

# Output as JSON for programmatic processing
npm audit --json

# Audit only production dependencies (exclude devDependencies)
npm audit --omit=dev

# Attempt automatic remediation
npm audit fix

# Remediate including semver-breaking upgrades (review carefully)
npm audit fix --force
```

**Sample output interpretation:**

```
# npm audit output
found 3 vulnerabilities (1 low, 1 moderate, 1 high)

high severity vulnerability in fast-xml-parser
  Package: fast-xml-parser
  Dependency of: @fastify/multipart
  Path: your-app > @fastify/multipart > fast-xml-parser
  More info: https://github.com/advisories/GHSA-xxxx
```

**Key Points:**
- `npm audit` reports vulnerabilities by severity: critical, high, moderate, low, and informational.
- Transitive vulnerabilities (dependencies of dependencies) are reported — these are often the majority of findings.
- `npm audit fix` only upgrades within the semver range specified in `package.json`. Breaking-change upgrades require `--force` or manual intervention.
- [Inference] `npm audit fix --force` may introduce breaking API changes in upgraded packages — treat it as a manual upgrade requiring testing, not an automated safe operation.
- False positives exist — a vulnerability may be present in a code path the application does not use. Evaluate applicability before treating every finding as critical.

---

### `pnpm audit` and `yarn audit`

If the project uses pnpm or Yarn, the audit command differs slightly:

```bash
# pnpm
pnpm audit
pnpm audit --prod          # production dependencies only
pnpm audit --json          # machine-readable output

# Yarn (v1)
yarn audit
yarn audit --json

# Yarn Berry (v2+)
yarn npm audit
yarn npm audit --all       # include devDependencies
```

**Key Points:**
- Advisory databases differ slightly between registries — [Unverified] pnpm and Yarn may surface different sets of advisories than `npm audit` for the same dependency tree. Cross-verify against the GitHub Advisory Database for completeness.
- Yarn Berry does not have a built-in `audit fix` equivalent — remediation is manual.

---

### `better-npm-audit` — Enhanced CLI Auditing

`npm audit` has limitations: it cannot filter by severity threshold or ignore specific advisories from the command line. `better-npm-audit` extends it:

```bash
npm install --save-dev better-npm-audit
```

```json
// package.json scripts
{
  "scripts": {
    "audit:prod": "better-npm-audit audit --omit=dev --level high",
    "audit:all": "better-npm-audit audit --level moderate"
  }
}
```

```bash
# Fail only on high or critical vulnerabilities
npx better-npm-audit audit --level high

# Ignore specific advisory IDs (with documented justification)
npx better-npm-audit audit --ignore 1234 5678
```

**Key Points:**
- `--level` sets the minimum severity that causes a non-zero exit code — useful for CI gates.
- `--ignore` suppresses specific advisory IDs. Document each ignored advisory with a justification and review date.
- [Inference] Blanket ignoring of advisories without documented justification defeats the purpose of auditing — treat each suppression as a conscious, time-bounded decision.

---

### `audit-ci` — CI-Optimized Auditing

`audit-ci` is designed for CI pipelines. It supports allowlisting specific advisories by ID, severity thresholds, and outputs structured results:

```bash
npm install --save-dev audit-ci
```

**`audit-ci.json` configuration:**

```json
{
  "moderate": true,
  "allowlist": [
    "GHSA-xxxx-yyyy-zzzz"
  ],
  "report-type": "summary",
  "skip-dev": true
}
```

```bash
# Run in CI — exits non-zero on moderate or above (excluding allowlisted)
npx audit-ci --config audit-ci.json
```

**GitHub Actions integration:**

```yaml
# .github/workflows/audit.yml
name: Dependency Audit

on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 6 * * 1'   # Weekly on Monday at 06:00 UTC

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - name: Run dependency audit
        run: npx audit-ci --config audit-ci.json
```

**Key Points:**
- The `schedule` trigger runs the audit on a cadence independent of code changes — new advisories are published continuously and may affect unchanged code.
- `skip-dev: true` limits the gate to production dependencies — devDependency vulnerabilities may warrant separate handling.
- Allowlisted advisory IDs should be stored in version control with comments explaining the justification.

---

### Snyk — Continuous Vulnerability Monitoring

`npm audit` queries a point-in-time snapshot. Snyk provides continuous monitoring, alerting when new advisories are published against the current dependency tree:

```bash
npm install --save-dev snyk

# Authenticate
npx snyk auth

# One-time test
npx snyk test

# Test production dependencies only
npx snyk test --prod-only

# Monitor — registers the project with Snyk for continuous alerting
npx snyk monitor
```

**Snyk in CI:**

```yaml
- name: Snyk vulnerability scan
  uses: snyk/actions/node@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    args: --severity-threshold=high --prod-only
```

**Key Points:**
- `snyk monitor` registers the dependency manifest with Snyk's service — new advisories trigger alerts without requiring a new scan.
- Snyk's advisory database [Unverified] may include vulnerabilities not yet in the npm advisory database — the two are not identical.
- Snyk provides remediation advice and, in some cases, automated pull requests for upgrades.
- The free tier has scan limits — [Unverified] verify current plan restrictions at snyk.io.

---

### `npm-check-updates` — Proactive Dependency Freshness

Vulnerability remediation often requires upgrading packages. `npm-check-updates` identifies available upgrades:

```bash
npm install --save-dev npm-check-updates

# Show all available upgrades
npx ncu

# Upgrade all dependencies in package.json (does not install)
npx ncu --upgrade

# Upgrade only patch versions
npx ncu --target patch

# Upgrade only Fastify-related packages
npx ncu --filter '/fastify/'

# Interactive mode — select which packages to upgrade
npx ncu --interactive
```

**Key Points:**
- `ncu --upgrade` modifies `package.json` only — run `npm install` afterward.
- `--target patch` limits upgrades to patch versions, which are lower-risk but do not resolve vulnerabilities that require a minor or major bump.
- [Inference] Minor and major upgrades should be tested against the full integration test suite before merging — Fastify plugin APIs sometimes change between minor versions.

---

### Lockfile Integrity

The `package-lock.json` (or `pnpm-lock.yaml` / `yarn.lock`) records the exact resolved versions and integrity hashes of every installed package. It is a security artifact, not just a reproducibility convenience.

**Key practices:**

```bash
# Use npm ci in CI — installs exactly from lockfile, fails if lockfile is out of sync
npm ci

# Never use npm install in CI — it may update the lockfile
# npm install  ← do not use in CI
```

**Detecting lockfile tampering:**

```bash
# Verify integrity of installed packages against lockfile hashes
npm ci --audit
```

**Key Points:**
- Commit `package-lock.json` to version control. An uncommitted lockfile means every `npm install` resolves to the latest compatible versions — advisory coverage varies with what gets installed.
- A pull request that modifies `package-lock.json` without a corresponding `package.json` change warrants scrutiny — it may indicate a dependency confusion attack or an unintended transitive upgrade.
- [Inference] Reviewing lockfile diffs in code review is an underutilized practice — significant changes in transitive dependencies may not be visible from `package.json` alone.

---

### Dependency Confusion and Supply Chain Attacks

Dependency confusion attacks exploit the resolution order of package registries. If an internal package name (e.g., `@myorg/utils`) is published to the public npm registry by an attacker with a higher version number, `npm install` may resolve to the malicious public package instead of the private internal one.

**Mitigations:**

```bash
# .npmrc — scope packages to the internal registry
@myorg:registry=https://registry.internal.example.com/

# Alternatively, set the public registry as fallback only
# and prefer private registry for scoped packages
```

```json
// package.json — lock internal package versions explicitly
{
  "dependencies": {
    "@myorg/utils": "1.2.3"
  }
}
```

**Key Points:**
- Scoping all internal packages under a private organization name (`@myorg/`) and configuring `.npmrc` to resolve that scope from the private registry is the primary mitigation.
- [Unverified] npm's current handling of scoped packages and registry resolution — verify against current npm documentation for the version in use.
- Subresource Integrity (SRI) for CDN-loaded scripts is a browser-side analog — not directly applicable to npm dependencies but relevant for frontend asset loading.

---

### `socket.dev` — Supply Chain Risk Analysis

Socket analyzes npm packages for supply chain risk signals beyond known CVEs: new maintainers, install scripts, obfuscated code, network access from a package that should not require it, and newly published versions that differ significantly from previous ones.

```bash
npx @socket.dev/cli check

# Check a specific package before installing
npx @socket.dev/cli npm install fastify-some-new-plugin
```

**Key Points:**
- Socket catches risks that the npm advisory database does not — a newly compromised package may not have a CVE yet.
- [Unverified] Socket's free tier limits and current feature set — verify at socket.dev.
- [Inference] This tool is particularly useful for evaluating community Fastify plugins before adopting them, where the maintenance history and publisher reputation may be less established than official `@fastify/*` packages.

---

### Severity Triage Policy

Not every advisory warrants immediate action. A documented triage policy prevents alert fatigue and prioritizes effort:

| Severity | Response SLA (example) | Notes |
|---|---|---|
| Critical | Immediate — same day | Assess exploitability; patch or mitigate within 24h |
| High | 72 hours | Assess exploitability; schedule patch |
| Moderate | Next sprint | Address in planned maintenance cycle |
| Low | Quarterly review | Track; address opportunistically |
| Informational | Backlog | Review at major version upgrades |

**Exploitability assessment checklist:**
- Does the vulnerable code path execute in this application?
- Is the vulnerable input reachable from an unauthenticated request?
- Does the application use the affected feature of the package?
- Is there a workaround (configuration, middleware) that mitigates without upgrading?

[Inference] A critical severity advisory in a package the application imports but whose vulnerable code path is never reachable may be lower actual risk than a moderate advisory in a heavily used code path. Severity rating is a starting point, not a complete risk assessment.

---

### Integrating Auditing into the Development Lifecycle

```
Developer workflow:
  npm ci → [pre-commit hook: npm audit --omit=dev]

Pull Request:
  CI runs audit-ci → blocks merge on high/critical

Merge to main:
  CI runs snyk monitor → registers current state for continuous monitoring

Weekly scheduled:
  GitHub Actions runs audit-ci → alerts on new advisories for unchanged code

Quarterly:
  Manual review of allowlisted advisories
  ncu --interactive for planned upgrades
  Review of all third-party Fastify plugins for maintenance activity
```

**Pre-commit hook with `husky`:**

```bash
npm install --save-dev husky
npx husky init
```

```bash
# .husky/pre-commit
npm audit --omit=dev --audit-level=high
```

**Key Points:**
- Pre-commit auditing catches issues before they reach CI — faster feedback loop.
- [Inference] Pre-commit hooks can be bypassed with `git commit --no-verify` — they are a convenience, not a security boundary. The CI gate is the authoritative enforcement point.

---

### Fastify-Specific Considerations

**Official `@fastify/*` plugins** — Maintained by the Fastify team. Advisories are typically patched promptly. Monitor the [Fastify GitHub organization](https://github.com/fastify) for security advisories.

**Community plugins** — Variable maintenance quality. Before adopting:
- Check last publish date and open issue/PR velocity.
- Review the package's own dependency tree with `npm audit`.
- Prefer packages with a published security policy.

**Fastify core advisories** — Subscribe to GitHub Security Advisories for the `fastify/fastify` repository to receive notifications of core vulnerabilities.

**`ajv` dependency** — Fastify depends on Ajv for schema compilation. Ajv vulnerabilities directly affect Fastify's request validation pipeline. Monitor Ajv advisories independently.

---

### Generating an SBOM (Software Bill of Materials)

An SBOM is a machine-readable inventory of all dependencies. It enables vulnerability scanning against the dependency list without running `npm install`:

```bash
# Generate SBOM in CycloneDX format using cdxgen
npm install --save-dev @cyclonedx/cdxgen

npx cdxgen -o sbom.json -t nodejs .

# Generate SBOM in SPDX format using npm
npm sbom --sbom-format spdx --output-file sbom.spdx.json
```

**Key Points:**
- SBOMs are increasingly required by enterprise customers and regulated industries as part of procurement and compliance processes.
- The generated SBOM can be scanned by tools like Grype or Trivy independently of the npm audit infrastructure.
- [Unverified] `npm sbom` was introduced in npm v8.x — verify availability in the npm version in use.

---

### Responding to a Discovered Vulnerability

1. **Assess exploitability** — Is the vulnerable code path reachable? From authenticated or unauthenticated requests?
2. **Check for a patch** — Is a fixed version available? Does upgrading require API changes?
3. **Apply the fix** — `npm install package@fixed-version`, update `package-lock.json`, run full test suite.
4. **If no patch exists** — Consider a temporary workaround (disable the affected feature, add input validation upstream, switch to an alternative package).
5. **If not exploitable** — Document the assessment with justification, add to the allowlist in `audit-ci.json`, set a review date.
6. **Deploy** — Follow normal deployment process; treat security patches as high priority.
7. **Document** — Record the advisory ID, assessment, action taken, and resolution date in a security log.

---

**Related Topics:**
- `@fastify/helmet` — HTTP security headers reducing exploit impact
- `@fastify/rate-limit` — limiting attack surface exposure
- Input sanitization and SQL injection prevention — complementary application-layer controls
- GitHub Dependabot — automated dependency update pull requests
- Dependabot security alerts — GitHub-native advisory notification
- Renovate Bot — alternative to Dependabot with more granular configuration
- OWASP Dependency-Check — alternative advisory scanner with broader language support
- Grype and Trivy — SBOM-based vulnerability scanners