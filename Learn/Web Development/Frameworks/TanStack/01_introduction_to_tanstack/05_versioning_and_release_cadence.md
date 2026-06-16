## Versioning and Release Cadence

### Overview

TanStack libraries follow **independent versioning** — each library has its own release schedule, version number, and changelog. There is no unified "TanStack version" that bumps across all libraries simultaneously. Understanding how TanStack versions its libraries, what each version tier signals, and how to manage upgrades safely is essential for maintaining a stable production application.

---

### Semantic Versioning

All TanStack libraries follow **Semantic Versioning (SemVer)**:

```
MAJOR.MINOR.PATCH
  │     │     └── Bug fixes, no API changes
  │     └──────── New features, backward compatible
  └────────────── Breaking changes
```

| Version Component | What It Signals in TanStack |
|---|---|
| **MAJOR** | Breaking API changes; migration guide required |
| **MINOR** | New features or capabilities; backward compatible |
| **PATCH** | Bug fixes, performance improvements, type fixes |

**Key Points:**
- A MAJOR bump in one library does not affect other TanStack libraries
- TypeScript type changes that break existing code are treated as breaking changes and warrant a MAJOR bump [Inference — behavior may vary by library maintainer decision]
- Patch releases may include type improvements that, in rare cases, surface previously hidden type errors in consuming code [behavior may vary]

---

### Release Channels

TanStack libraries use npm distribution tags to communicate release stability:

| Tag | Meaning | Example Install |
|---|---|---|
| `latest` | Stable, production-ready | `npm install @tanstack/react-query` |
| `beta` | Feature-complete, API may still change | `npm install @tanstack/react-query@beta` |
| `alpha` | Early access, expect breaking changes | `npm install @tanstack/react-query@alpha` |
| `rc` | Release candidate, near-stable | `npm install @tanstack/react-query@rc` |
| `next` | Bleeding-edge, used by some libraries | `npm install @tanstack/react-router@next` |

**Key Points:**
- The `latest` tag is what you get by default with `npm install` — no tag specification needed
- Pre-release versions (`alpha`, `beta`, `rc`) are not recommended for production use
- Some libraries use `next` during major development cycles instead of `beta` [Unverified for all libraries]

---

### Historical Major Versions

Understanding the major version history of key libraries contextualizes the pace and nature of breaking changes.

#### TanStack Query

| Version | Notable Changes |
|---|---|
| v1–v2 | Early React Query; established core caching model |
| v3 | Stable, widely adopted API; `useQuery` / `useMutation` pattern solidified |
| v4 | Package renamed from `react-query` to `@tanstack/react-query`; multi-framework support added; `status` field refined |
| v5 | Removed deprecated APIs; `useQuery` callback form removed; `onSuccess` / `onError` / `onSettled` callbacks moved off `useQuery`; `isLoading` renamed to `isPending` for mutations; object-only API enforced |

**Key Points:**
- The v3 → v4 migration required a package rename in all imports
- The v4 → v5 migration removed several convenience callbacks that had been discouraged for some time — applications using `onSuccess` inside `useQuery` required refactoring
- The v5 API is considered more predictable and less prone to closure-related bugs [Inference]

#### TanStack Router

| Version | Notable Changes |
|---|---|
| Pre-v1 (react-location) | Predecessor library; separate package, now deprecated |
| v0 (early TanStack Router) | Experimental; API changed frequently |
| v1 | Stable release; file-based routing stabilized; full TypeScript inference finalized |

**Key Points:**
- TanStack Router is a complete rewrite, not an evolution of `react-location` — migration between them is not incremental
- v1 is the first version recommended for production use

#### TanStack Table

| Version | Notable Changes |
|---|---|
| v7 | `react-table` package; widely used headless table primitive |
| v8 | Renamed to `@tanstack/react-table`; full rewrite in TypeScript; plugin system replaced with composable row models; multi-framework support added |

**Key Points:**
- v7 → v8 was a complete API rewrite; no automatic migration path exists
- v7 remains in wide use as of the knowledge cutoff due to the migration complexity [Unverified for current adoption figures]

#### TanStack Form

| Version | Notable Changes |
|---|---|
| v0 | Experimental; API unstable |
| v1 | First stable release; field-level reactivity model stabilized |

**Key Points:**
- TanStack Form reached v1 stable relatively recently compared to Query and Table [Unverified for exact release date]
- Projects started during v0 should plan a migration to v1 [Inference]

---

### Release Cadence

TanStack does not follow a fixed release schedule (e.g., quarterly releases). Releases are driven by:

- Feature completion
- Bug accumulation
- Community feedback
- Ecosystem changes (React, TypeScript, or bundler updates)

**General observations** [Inference — based on historical patterns; actual cadence may vary]:

| Release Type | Approximate Frequency |
|---|---|
| Patch releases | Frequent — often weekly or bi-weekly for active libraries |
| Minor releases | Monthly to quarterly |
| Major releases | Infrequent — months to years between major versions |

TanStack Query v5, for example, remained in active patch and minor development for an extended period before any indication of a v6. TanStack Router reached v1 after a longer pre-release period than most libraries. These patterns suggest the maintainers prioritize API stability over rapid major version cycling [Inference].

---

### Identifying the Current Version

#### Check Installed Version

```bash
# Single package
npm list @tanstack/react-query

# All @tanstack packages
npm list | grep @tanstack
```

**Output:**
```
my-app@1.0.0
└── @tanstack/react-query@5.62.0
```

#### Check Latest Available Version

```bash
npm info @tanstack/react-query version
# Returns: 5.62.0

# See all available versions
npm info @tanstack/react-query versions --json

# See all dist-tags (latest, beta, alpha)
npm info @tanstack/react-query dist-tags
```

#### Check for Outdated Packages

```bash
npm outdated
```

**Output:**
```
Package                   Current   Wanted   Latest
@tanstack/react-query      5.50.0   5.50.0   5.62.0
@tanstack/react-table       8.9.0    8.9.0   8.21.0
```

---

### Version Pinning Strategy

How you specify versions in `package.json` determines your exposure to unintended updates.

```json
{
  "dependencies": {
    "@tanstack/react-query": "^5.62.0",
    "@tanstack/react-table": "~8.21.0",
    "@tanstack/react-router": "1.19.0"
  }
}
```

| Specifier | Meaning | Risk Level |
|---|---|---|
| `^5.62.0` | Accepts `5.x.x` where `x ≥ 62` | Low — MINOR and PATCH only |
| `~5.62.0` | Accepts `5.62.x` only | Very low — PATCH only |
| `5.62.0` | Exact version only | Zero — fully locked |
| `*` | Any version | High — never use in production |

**Key Points:**
- `^` (caret) is npm's default when you run `npm install` — it allows minor and patch updates
- For production applications, `~` (tilde) or exact pinning reduces the risk of unexpected behavior from minor version changes
- A lockfile (`package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`) pins exact versions at install time regardless of the range specifier — always commit your lockfile

---

### Managing Adapter Version Alignment

Many TanStack libraries ship a framework-agnostic core alongside framework-specific adapter packages. These must be kept in sync:

```json
{
  "dependencies": {
    "@tanstack/table-core": "8.21.0",
    "@tanstack/react-table": "8.21.0"
  }
}
```

[In practice, `@tanstack/react-table` depends on `@tanstack/table-core` internally and installs the correct version automatically — manual alignment is rarely needed unless you import from both directly. Behavior may vary across library structures.]

The following illustrates the core/adapter relationship:

<svg viewBox="0 0 680 320" xmlns="http://www.w3.org/2000/svg" font-family="ui-monospace, monospace" font-size="12">

  <rect width="680" height="320" fill="#0f1117" rx="12"/>

  <!-- Core package -->
  <rect x="240" y="30" width="200" height="44" rx="6" fill="#1e293b" stroke="#64748b" stroke-width="1.5"/>
  <text x="340" y="52" fill="#94a3b8" text-anchor="middle" font-weight="bold">@tanstack/query-core</text>
  <text x="340" y="67" fill="#475569" text-anchor="middle" font-size="11">Framework-agnostic logic</text>

  <!-- Adapters -->
  <rect x="30"  y="150" width="160" height="44" rx="6" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1"/>
  <text x="110" y="172" fill="#60a5fa" text-anchor="middle" font-weight="bold">react-query</text>
  <text x="110" y="187" fill="#1d4ed8" text-anchor="middle" font-size="11">React adapter</text>

  <rect x="210" y="150" width="160" height="44" rx="6" fill="#134e3a" stroke="#10b981" stroke-width="1"/>
  <text x="290" y="172" fill="#34d399" text-anchor="middle" font-weight="bold">vue-query</text>
  <text x="290" y="187" fill="#065f46" text-anchor="middle" font-size="11">Vue adapter</text>

  <rect x="390" y="150" width="160" height="44" rx="6" fill="#3b1f5e" stroke="#a855f7" stroke-width="1"/>
  <text x="470" y="172" fill="#c084fc" text-anchor="middle" font-weight="bold">solid-query</text>
  <text x="470" y="187" fill="#581c87" text-anchor="middle" font-size="11">Solid adapter</text>

  <rect x="210" y="240" width="160" height="44" rx="6" fill="#451f1f" stroke="#f59e0b" stroke-width="1"/>
  <text x="290" y="262" fill="#fbbf24" text-anchor="middle" font-weight="bold">svelte-query</text>
  <text x="290" y="277" fill="#92400e" text-anchor="middle" font-size="11">Svelte adapter</text>

  <!-- Lines from core to adapters -->
  <line x1="280" y1="74" x2="110" y2="150" stroke="#374151" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="320" y1="74" x2="290" y2="150" stroke="#374151" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="360" y1="74" x2="470" y2="150" stroke="#374151" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="340" y1="74" x2="290" y2="240" stroke="#374151" stroke-width="1" stroke-dasharray="4,3"/>

  <!-- Version note -->
  <text x="340" y="310" fill="#374151" text-anchor="middle" font-size="11">All adapters must match the core version they depend on</text>

</svg>

---

### Reading the Changelog

Before upgrading any TanStack library, review its changelog. All TanStack changelogs are maintained in the GitHub repository for each library.

| Library | Changelog Location |
|---|---|
| Query | `github.com/TanStack/query/blob/main/CHANGELOG.md` |
| Router | `github.com/TanStack/router/blob/main/CHANGELOG.md` |
| Table | `github.com/TanStack/table/blob/main/CHANGELOG.md` |
| Form | `github.com/TanStack/form/blob/main/CHANGELOG.md` |
| Virtual | `github.com/TanStack/virtual/blob/main/CHANGELOG.md` |

**Key Points:**
- Look specifically for entries marked `breaking`, `removed`, or `deprecated` before a MINOR or MAJOR upgrade
- Type-only changes are sometimes listed separately from runtime changes — both matter for TypeScript projects
- Migration guides for major versions are typically published as separate documents linked from the changelog or release notes

---

### Upgrade Workflow

The following workflow reduces risk when upgrading TanStack libraries in a production project:

**Step 1 — Identify current and target versions**
```bash
npm outdated | grep @tanstack
```

**Step 2 — Read the changelog for every version between current and target**

Pay attention to any `BREAKING CHANGE` entries.

**Step 3 — Upgrade in isolation**

Upgrade one library at a time, not all simultaneously:
```bash
npm install @tanstack/react-query@5.62.0
```

**Step 4 — Run TypeScript compilation**
```bash
npx tsc --noEmit
```

Type errors after an upgrade often surface API changes before runtime does.

**Step 5 — Run your test suite**
```bash
npm test
```

**Step 6 — Verify in a staging environment before deploying**

**Key Points:**
- Upgrading multiple TanStack libraries in a single commit makes it harder to isolate the source of a regression
- TypeScript errors after a patch upgrade may indicate that a previously hidden type issue has been corrected — evaluate whether the error reflects a real bug in your code [behavior may vary]
- Major version upgrades should be treated as a planned migration task, not a routine dependency bump

---

### Deprecation Policy

TanStack does not publish a formal deprecation policy document [Unverified]. Based on observed patterns [Inference]:

- APIs are typically marked deprecated in a MINOR release before being removed in the next MAJOR
- Deprecated APIs often emit console warnings at runtime to assist with discovery
- The gap between deprecation and removal varies — TanStack Query v5 removed APIs that had been deprecated in v4, giving developers one major version cycle to migrate

**Example — TanStack Query v4 to v5 deprecation pattern:**

```ts
// Deprecated in v4, removed in v5:
useQuery(['key'], fetchFn, {
  onSuccess: (data) => console.log(data),  // ← removed in v5
})

// v5 equivalent — handle side effects in the component:
const { data } = useQuery({ queryKey: ['key'], queryFn: fetchFn })
useEffect(() => {
  if (data) console.log(data)
}, [data])
```

---

### Lockfile Hygiene

The lockfile is the definitive record of what is actually installed. It should always be committed to version control.

```bash
# Reproduce exact installed versions from lockfile
npm ci          # npm
pnpm install --frozen-lockfile   # pnpm
yarn install --immutable         # yarn
```

**Key Points:**
- `npm ci` installs from the lockfile exactly, ignoring version ranges in `package.json` — use this in CI/CD pipelines
- `npm install` updates the lockfile when ranges allow newer versions — use this intentionally, not automatically in CI
- Deleting and regenerating the lockfile (`rm package-lock.json && npm install`) can inadvertently upgrade packages — avoid this unless deliberately refreshing all dependencies

---

### Monitoring for New Releases

Options for staying informed of TanStack releases:

| Method | How |
|---|---|
| **GitHub Watch** | Watch the repository with "Releases only" notifications |
| **npm notifications** | Some registries support release notifications |
| **Dependabot / Renovate** | Automate PR creation for dependency updates |
| **RSS** | GitHub releases pages expose an RSS/Atom feed |

A Renovate or Dependabot configuration targeting `@tanstack/*` packages allows automated PRs for each new release without manual `npm outdated` checks.

**Example Renovate config targeting TanStack packages:**

```json
{
  "packageRules": [
    {
      "matchPackagePrefixes": ["@tanstack/"],
      "groupName": "TanStack libraries",
      "automerge": false,
      "minimumReleaseAge": "3 days"
    }
  ]
}
```

**Key Points:**
- `minimumReleaseAge` delays the PR until a release has been live for a few days — reduces exposure to yanked or immediately re-released patches [Inference]
- `automerge: false` ensures a human reviews TanStack updates before they reach production

---

### Pre-release Adoption Considerations

Some teams adopt pre-release versions to access new features earlier. The tradeoffs:

| Factor | Stable (`latest`) | Pre-release (`beta` / `rc`) |
|---|---|---|
| API stability | High | Not guaranteed |
| Bug density | Lower | Higher |
| Documentation | Complete | May lag behind code |
| Community support | Broad | Limited |
| Migration path | Documented | May change before final |

[Speculation: adopting a `beta` release in production may be justifiable for greenfield projects where locking in a new API early is preferable to migrating later — but this depends heavily on the library and the team's risk tolerance.]

---

**Conclusion**

TanStack libraries version independently using SemVer, with MAJOR versions signaling breaking changes, MINOR versions adding backward-compatible features, and PATCH versions delivering fixes. Release cadence is need-driven rather than schedule-driven, with patch releases being frequent and major versions infrequent. The most important practices for managing TanStack versions in production are: committing lockfiles, upgrading one library at a time, reading changelogs before every MAJOR upgrade, and running TypeScript compilation immediately after any upgrade to surface API changes early.

**Next Steps:**
- Set up Dependabot or Renovate to monitor `@tanstack/*` packages automatically
- Audit your current installed versions with `npm list | grep @tanstack`
- Review the changelog for any library currently behind its latest stable release