# Sentry for Web Development — Complete Reference

> **Refined prompt for Claude:**
> *"You are a senior web engineer. Generate a comprehensive, well-structured Markdown reference guide on Sentry for web development. Cover: what Sentry is and why to use it, SDK setup for modern frameworks (React, Next.js, Vue, vanilla JS), error capturing (automatic vs manual), performance monitoring (transactions, spans, Web Vitals), session replay, source maps, environment/release management, alerting rules, integrations (GitHub, Slack, Jira), team workflows, cost/quota management, and common gotchas. Include real code examples. Format with clear H2/H3 headings, code blocks with language tags, and a quick-reference cheat sheet at the end."*

---

## Table of Contents

1. [What Is Sentry?](#1-what-is-sentry)
2. [Core Concepts](#2-core-concepts)
3. [Installation & SDK Setup](#3-installation--sdk-setup)
4. [Error Monitoring](#4-error-monitoring)
5. [Performance Monitoring](#5-performance-monitoring)
6. [Session Replay](#6-session-replay)
7. [Source Maps](#7-source-maps)
8. [Releases & Environments](#8-releases--environments)
9. [Alerting & Notifications](#9-alerting--notifications)
10. [Integrations](#10-integrations)
11. [Filtering, Sampling & Quotas](#11-filtering-sampling--quotas)
12. [Dashboards & Issue Management](#12-dashboards--issue-management)
13. [Team Workflows](#13-team-workflows)
14. [Common Gotchas](#14-common-gotchas)
15. [Cheat Sheet](#15-cheat-sheet)

---

## 1. What Is Sentry?

Sentry is an **application monitoring platform** that captures errors, performance bottlenecks, and user sessions in real time. Unlike logging tools that require you to manually hunt through files, Sentry:

- Automatically intercepts unhandled exceptions and promise rejections
- Groups duplicate errors into a single *Issue* (de-duplication via stack trace fingerprinting)
- Attaches user context, breadcrumbs, and environment data to every event
- Measures frontend performance (LCP, FID, CLS, TTFB) against real users
- Records session replays to reproduce bugs visually

**Self-hosted vs Cloud:** Sentry offers a managed cloud service at `sentry.io` and an open-source self-hosted option (`getsentry/self-hosted` on GitHub).

---

## 2. Core Concepts

| Concept | Description |
|---|---|
| **DSN** | Data Source Name — unique URL that routes events to your Sentry project |
| **Event** | A single captured occurrence (error, transaction, replay) |
| **Issue** | A grouped set of similar events sharing a fingerprint |
| **Transaction** | A performance event representing one operation (page load, API call) |
| **Span** | A timed segment inside a transaction (DB query, HTTP request, render) |
| **Breadcrumb** | A trail of user/system actions leading up to an error |
| **Release** | A deployable version of your code, used for regression tracking |
| **Environment** | Logical separation: `production`, `staging`, `development` |
| **Fingerprint** | The hash that groups events into the same Issue |
| **Quota** | Monthly event budget per plan (errors, transactions, replays, etc.) |

---

## 3. Installation & SDK Setup

### 3.1 Vanilla JavaScript

```bash
npm install @sentry/browser
```

```js
// src/index.js
import * as Sentry from "@sentry/browser";

Sentry.init({
  dsn: "https://<key>@oXXXXX.ingest.sentry.io/<project-id>",
  environment: import.meta.env.MODE,          // "production" | "development"
  release: import.meta.env.VITE_APP_VERSION,  // e.g. "my-app@1.2.3"
  tracesSampleRate: 0.2,      // 20% of transactions captured
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
  integrations: [
    Sentry.browserTracingIntegration(),
    Sentry.replayIntegration(),
  ],
});
```

### 3.2 React

```bash
npm install @sentry/react
```

```jsx
// src/main.jsx
import * as Sentry from "@sentry/react";
import { createBrowserRouter } from "react-router-dom";

Sentry.init({
  dsn: "YOUR_DSN",
  integrations: [
    Sentry.browserTracingIntegration(),
    Sentry.replayIntegration(),
  ],
  tracesSampleRate: 0.2,
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
});

// Wrap your router for automatic route transaction naming
const router = Sentry.wrapCreateBrowserRouter(createBrowserRouter)([
  { path: "/", element: <App /> },
]);
```

**Error Boundary (React 16+):**

```jsx
import { ErrorBoundary } from "@sentry/react";

function App() {
  return (
    <ErrorBoundary fallback={<p>Something went wrong.</p>} showDialog>
      <MyComponent />
    </ErrorBoundary>
  );
}
```

### 3.3 Next.js

```bash
npx @sentry/wizard@latest -i nextjs
```

The wizard auto-creates `sentry.client.config.ts`, `sentry.server.config.ts`, and `sentry.edge.config.ts`.

```ts
// sentry.client.config.ts
import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
  integrations: [Sentry.replayIntegration()],
});
```

```ts
// next.config.ts
import { withSentryConfig } from "@sentry/nextjs";

const nextConfig = { /* your config */ };

export default withSentryConfig(nextConfig, {
  org: "your-org",
  project: "your-project",
  silent: !process.env.CI,
  widenClientFileUpload: true,  // upload source maps for client bundle
  tunnelRoute: "/monitoring",   // proxy Sentry requests through your server
  hideSourceMaps: true,         // don't expose source maps to browser
  disableLogger: true,
  automaticVercelMonitors: true,
});
```

### 3.4 Vue 3

```bash
npm install @sentry/vue
```

```js
// main.js
import { createApp } from "vue";
import * as Sentry from "@sentry/vue";
import router from "./router";

const app = createApp(App);

Sentry.init({
  app,
  dsn: "YOUR_DSN",
  integrations: [
    Sentry.browserTracingIntegration({ router }),
    Sentry.replayIntegration(),
  ],
  tracesSampleRate: 0.2,
  tracePropagationTargets: ["localhost", /^https:\/\/api\.myapp\.com/],
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
});

app.use(router).mount("#app");
```

### 3.5 Environment Variables (best practice)

```bash
# .env.production
VITE_SENTRY_DSN=https://...@....ingest.sentry.io/...
VITE_APP_VERSION=1.4.2
SENTRY_AUTH_TOKEN=sntrys_... # server-side only, never expose to browser
SENTRY_ORG=my-org
SENTRY_PROJECT=my-project
```

---

## 4. Error Monitoring

### 4.1 Automatic Capture

Once `Sentry.init()` runs, these are captured without extra code:

- Unhandled `throw` / uncaught exceptions
- Unhandled promise rejections (`window.onunhandledrejection`)
- `console.error` calls (optional via `captureConsole` integration)
- Network errors (via `browserApiErrorsIntegration`)

### 4.2 Manual Error Capture

```js
// Capture an exception
try {
  riskyOperation();
} catch (err) {
  Sentry.captureException(err);
}

// Capture a plain message
Sentry.captureMessage("Checkout flow stalled", "warning");
// Levels: "fatal" | "error" | "warning" | "info" | "debug"
```

### 4.3 Enriching Events with Context

**Scope — global context attached to all events:**

```js
Sentry.setUser({ id: "42", email: "user@example.com", username: "jdoe" });
Sentry.setTag("subscription_plan", "pro");
Sentry.setExtra("cart_items", 3);
```

**withScope — context for a single event only:**

```js
Sentry.withScope((scope) => {
  scope.setTag("section", "payment");
  scope.setLevel("fatal");
  scope.setExtra("payload", orderPayload);
  Sentry.captureException(err);
});
```

**Breadcrumbs:**

```js
Sentry.addBreadcrumb({
  category: "auth",
  message: "User clicked login",
  level: "info",
  data: { method: "google-oauth" },
});
```

### 4.4 Custom Fingerprinting

Override Sentry's default grouping algorithm:

```js
Sentry.init({
  beforeSend(event) {
    if (event.exception?.values?.[0]?.type === "NetworkError") {
      event.fingerprint = ["network-error", event.request?.url ?? "unknown"];
    }
    return event;
  },
});
```

### 4.5 Filtering Events

```js
Sentry.init({
  beforeSend(event, hint) {
    const err = hint.originalException;

    // Drop third-party browser extension errors
    if (err?.stack?.includes("chrome-extension://")) return null;

    // Drop specific error messages
    if (err?.message?.match(/ResizeObserver loop/)) return null;

    return event;
  },
  ignoreErrors: [
    "Non-Error promise rejection captured",
    /^Script error\.?$/,
    "Network request failed",
  ],
  denyUrls: [
    /extensions\//i,
    /^chrome:\/\//i,
    /^moz-extension:\/\//i,
  ],
});
```

---

## 5. Performance Monitoring

### 5.1 Automatic Instrumentation

`browserTracingIntegration()` automatically creates transactions for:

- Page loads and navigations (single-page apps)
- `fetch` / `XMLHttpRequest` calls
- Browser Web Vitals (LCP, FID, CLS, TTFB, FCP, INP)

### 5.2 Custom Transactions & Spans

```js
// Start a transaction manually
const transaction = Sentry.startTransaction({
  name: "process-upload",
  op: "task",
});

Sentry.getCurrentHub().configureScope((scope) => scope.setSpan(transaction));

// Add child spans
const span = transaction.startChild({
  op: "file.compress",
  description: "Compressing image before upload",
});

try {
  await compressImage(file);
} finally {
  span.finish();
}

transaction.finish();
```

**Modern API (SDK v8+):**

```js
await Sentry.startSpan(
  { name: "compress-and-upload", op: "task" },
  async (span) => {
    await Sentry.startSpan({ name: "compress", op: "file.compress" }, () =>
      compressImage(file)
    );
    await Sentry.startSpan({ name: "upload", op: "http.client" }, () =>
      uploadToS3(file)
    );
  }
);
```

### 5.3 Web Vitals

Sentry captures Core Web Vitals automatically and surfaces them in the **Performance** tab. Target thresholds:

| Metric | Good | Needs Improvement | Poor |
|---|---|---|---|
| **LCP** | ≤ 2.5s | 2.5–4.0s | > 4.0s |
| **INP** | ≤ 200ms | 200–500ms | > 500ms |
| **CLS** | ≤ 0.1 | 0.1–0.25 | > 0.25 |
| **TTFB** | ≤ 800ms | 800ms–1.8s | > 1.8s |

### 5.4 Distributed Tracing

Connect frontend → backend spans by propagating trace headers:

```js
Sentry.init({
  tracePropagationTargets: [
    "localhost",
    /^https:\/\/api\.myapp\.com/,
  ],
  integrations: [Sentry.browserTracingIntegration()],
});
```

Sentry automatically injects `sentry-trace` and `baggage` headers into matching requests. Your backend SDK picks these up to continue the trace.

---

## 6. Session Replay

Session Replay records DOM mutations, network activity, console logs, and user interactions to let you *watch* what happened before an error.

```js
Sentry.init({
  integrations: [
    Sentry.replayIntegration({
      maskAllText: true,          // PII: mask all text by default
      blockAllMedia: true,        // PII: block images/video
      maskAllInputs: true,        // PII: mask form inputs
      // Unmask specific elements:
      unmask: [".sentry-unmask"],
      unblock: [".sentry-unblock"],
    }),
  ],
  replaysSessionSampleRate: 0.05,  // 5% of all sessions
  replaysOnErrorSampleRate: 1.0,   // 100% of sessions with errors
});
```

**Capture a replay for the current session manually:**

```js
const replay = Sentry.getReplay();
replay?.flush(); // force-send current session buffer
```

**Privacy classes (HTML):**

```html
<!-- Mask an element -->
<div class="sentry-mask">Sensitive content</div>

<!-- Block rendering of an element entirely -->
<img class="sentry-block" src="private.jpg" />

<!-- Ignore interactions on an element -->
<button class="sentry-ignore">Click me</button>
```

---

## 7. Source Maps

Without source maps, Sentry shows minified stack traces. With them, you get original file names and line numbers.

### 7.1 Upload via Sentry CLI

```bash
npm install --save-dev @sentry/cli

# In your CI/CD pipeline after build:
npx sentry-cli releases new "$VERSION"
npx sentry-cli releases files "$VERSION" upload-sourcemaps ./dist \
  --url-prefix "~/"                   \
  --rewrite                            # rewrites source map references
npx sentry-cli releases finalize "$VERSION"
```

### 7.2 Upload via Vite Plugin

```bash
npm install --save-dev @sentry/vite-plugin
```

```js
// vite.config.js
import { sentryVitePlugin } from "@sentry/vite-plugin";

export default {
  build: { sourcemap: true },
  plugins: [
    sentryVitePlugin({
      org: process.env.SENTRY_ORG,
      project: process.env.SENTRY_PROJECT,
      authToken: process.env.SENTRY_AUTH_TOKEN,
      release: { name: process.env.VITE_APP_VERSION },
    }),
  ],
};
```

### 7.3 Upload via Webpack Plugin

```bash
npm install --save-dev @sentry/webpack-plugin
```

```js
// webpack.config.js
const { SentryWebpackPlugin } = require("@sentry/webpack-plugin");

module.exports = {
  devtool: "hidden-source-map", // generate but don't link in bundle
  plugins: [
    new SentryWebpackPlugin({
      org: process.env.SENTRY_ORG,
      project: process.env.SENTRY_PROJECT,
      authToken: process.env.SENTRY_AUTH_TOKEN,
      include: "./dist",
      urlPrefix: "~/",
    }),
  ],
};
```

> **Security:** Use `hidden-source-map` (Webpack) or `sourcemap: true` + `hideSourceMaps: true` (Next.js) so maps are uploaded to Sentry but not served to users.

---

## 8. Releases & Environments

### 8.1 Releases

Releases tie issues to specific code versions, enabling:

- **Regression detection** — was this error introduced in this release?
- **Commit tracking** — see which commit caused the error
- **Deploy tracking** — know which version is live per environment

```js
Sentry.init({
  release: process.env.VITE_APP_VERSION, // e.g. "my-app@1.4.2"
});
```

**Semantic versioning convention:** `<project>@<semver>` (e.g. `frontend@2.1.0`)

**Creating a release via CLI:**

```bash
export VERSION=$(git describe --tags --always)

sentry-cli releases new "$VERSION"
sentry-cli releases set-commits "$VERSION" --auto   # links Git commits
sentry-cli releases deploy "$VERSION" -e production
sentry-cli releases finalize "$VERSION"
```

### 8.2 Environments

```js
Sentry.init({
  environment: process.env.NODE_ENV, // "production" | "staging" | "development"
});
```

Best practices:

- Only enable Sentry in `production` and `staging` (skip `development` or set `enabled: false`)
- Create separate Sentry **projects** for fundamentally different apps; use **environments** within one project for deployment stages

```js
Sentry.init({
  enabled: process.env.NODE_ENV === "production",
  dsn: "YOUR_DSN",
});
```

---

## 9. Alerting & Notifications

### 9.1 Issue Alerts

Configure in **Project Settings → Alerts → Issue Alerts**. Trigger rules:

| Condition | Example |
|---|---|
| A new issue is created | First time this error ever fires |
| An issue is seen more than N times | > 100 occurrences/hr |
| An issue affects more than N users | > 50 users impacted |
| An issue changes state to regression | Error reappears after being resolved |
| An issue goes unresolved for N minutes | Escalate if not fixed in 30 min |

### 9.2 Metric Alerts (Performance)

Trigger on aggregated metrics over a time window:

- Error rate > 1% in 5 minutes → page Slack
- P95 response time > 3s → notify team
- Apdex score < 0.8 → critical alert

### 9.3 Notification Channels

Connect under **Organization Settings → Integrations**:

- **Slack** — post to channels, tag users
- **PagerDuty** — on-call escalation
- **OpsGenie** — incident management
- **Email** — per-member or team-wide
- **Webhooks** — custom HTTP endpoints

---

## 10. Integrations

### 10.1 GitHub / GitLab

- **Commit tracking** — links errors to the exact commit that introduced them
- **Stack trace linking** — click a file in a stack trace → open in GitHub
- **Suspect commits** — Sentry shows the most likely offending commit
- **Auto-resolve** — close issues when a fixing commit is deployed

Setup: **Organization Settings → Integrations → GitHub → Add Installation**

### 10.2 Jira

Create Jira tickets directly from a Sentry issue. Configure field mappings (project, issue type, priority) per Sentry project.

### 10.3 Slack

```
/sentry link project <project-slug>   # associate Slack channel with project
```

### 10.4 Vercel

Sentry's Vercel integration automatically:

- Sets `SENTRY_AUTH_TOKEN`, `SENTRY_ORG`, `SENTRY_PROJECT` env vars
- Creates a release on each deploy
- Uploads source maps

### 10.5 OpenTelemetry (OTel)

```bash
npm install @sentry/opentelemetry
```

```js
import * as Sentry from "@sentry/node";
import { SentrySpanProcessor, SentryPropagator } from "@sentry/opentelemetry";

// Use Sentry as an OTel exporter
provider.addSpanProcessor(new SentrySpanProcessor());
provider.register({ propagator: new SentryPropagator() });
```

---

## 11. Filtering, Sampling & Quotas

### 11.1 Sample Rates

```js
Sentry.init({
  tracesSampleRate: 0.1,           // random 10% of transactions
  profilesSampleRate: 0.1,         // profiling (subset of traces)
  replaysSessionSampleRate: 0.05,  // 5% of sessions
  replaysOnErrorSampleRate: 1.0,   // 100% of error sessions
});
```

### 11.2 Dynamic Sampling (tracesSampler)

```js
Sentry.init({
  tracesSampler(samplingContext) {
    // Always trace checkout
    if (samplingContext.transactionContext.name.includes("/checkout")) {
      return 1.0;
    }
    // Drop health checks entirely
    if (samplingContext.transactionContext.name === "GET /health") {
      return 0;
    }
    // Default
    return 0.1;
  },
});
```

### 11.3 Inbound Filters (Sentry UI)

**Project Settings → Inbound Filters:**

- Filter known browser extension errors
- Filter localhost events
- Filter legacy browser errors
- Filter `localhost` transactions

### 11.4 Quota Management

Monitor usage at **Settings → Subscription → Usage Stats**. Strategies to stay within quota:

1. Lower `tracesSampleRate` first (transactions are costly)
2. Use `beforeSend` to drop noise
3. Enable **Spike Protection** — auto-rate-limits a sudden error flood
4. Set **Rate Limits** per project in project settings
5. Archive or ignore recurring noisy issues

---

## 12. Dashboards & Issue Management

### 12.1 Issue States

| State | Meaning |
|---|---|
| **Unresolved** | Active, needs attention |
| **Resolved** | Marked fixed (auto-reopens if it recurs) |
| **Ignored** | Snoozed indefinitely or for N occurrences |
| **Archived** | Hidden from default views, still captured |

### 12.2 Issue Search Operators

```
is:unresolved assigned:me                     # my open issues
is:unresolved !has:release                    # issues without a release
is:unresolved times_seen:>100 project:web    # high-frequency web errors
browser.name:Chrome level:error              # Chrome errors only
user.email:user@example.com                  # issues affecting specific user
```

### 12.3 Dashboards

Build custom dashboards (**Dashboards → Create Dashboard**) with widgets:

- Issues over time (line chart)
- Top errors by count (table)
- P75 LCP by page (chart)
- Apdex score trend
- Errors by release (bar chart)

### 12.4 Discover

Ad-hoc event querying with a SQL-like interface. Example:

```
event.type:transaction transaction:/checkout
| count(), p75(transaction.duration), p95(transaction.duration)
| orderby: -count()
```

---

## 13. Team Workflows

### 13.1 Ownership Rules

Auto-assign issues to teams or individuals based on file path or URL:

```
# .sentry/ownership-rules (or set in Project Settings → Ownership Rules)

# path:src/payment/**  → payment team
path:src/payment/*      team:payments-team

# URL-based ownership
url:*/checkout*         team:checkout-squad

# Codeowners-style
codeowners:src/auth/*   user:alice@example.com
```

### 13.2 Code Owners Integration

Sentry reads your `CODEOWNERS` file (GitHub/GitLab) to suggest owners based on which files appear in a stack trace.

### 13.3 Commit Blame

When GitHub integration is active, Sentry shows the commit and author closest to the erroring line in the stack trace.

---

## 14. Common Gotchas

### SDK Initialization Order
`Sentry.init()` must be called **before** any other imports that might throw. In Next.js, the `sentry.*.config.ts` files are loaded first automatically.

### DSN in Client Bundles
The DSN is intentionally public — it only accepts **inbound** events, not reads. However, rotate it if abused.

### `tracesSampleRate: 1.0` in Production
Never set this to `1.0` on high-traffic apps. Even 0.1 (10%) can exhaust your quota fast. Start at `0.01` and tune up.

### Source Maps Not Matching
Ensure the `release` string in `Sentry.init()` exactly matches the release name used during `sentry-cli releases new`. Mismatches break stack trace de-minification.

### `beforeSend` Returning `null`
Returning `null` silently drops the event. Use it intentionally for noise, not for accidentally swallowing real bugs.

### Replay PII Leakage
`replayIntegration()` defaults capture visible DOM content. Always configure `maskAllText`, `maskAllInputs`, and `blockAllMedia` in regulated or sensitive apps.

### Localhost Traffic Polluting Production Data
Set `environment: process.env.NODE_ENV` and filter the `development` environment in alert rules, or set `enabled: false` during development.

### Large Payloads
`setExtra()` with large objects can be truncated. Keep extras under 10 KB; for larger data, store it elsewhere and log a reference ID.

### Missing `async` Boundaries
Errors inside `setTimeout`, `setInterval`, or async callbacks are captured automatically. But errors inside Web Workers need the SDK initialized inside the worker too.

---

## 15. Cheat Sheet

```js
// ─── INIT ────────────────────────────────────────────────────────────────────
Sentry.init({ dsn, release, environment, tracesSampleRate });

// ─── CAPTURE ─────────────────────────────────────────────────────────────────
Sentry.captureException(new Error("boom"));
Sentry.captureMessage("heads up", "warning");

// ─── CONTEXT ─────────────────────────────────────────────────────────────────
Sentry.setUser({ id, email });
Sentry.setTag("key", "value");
Sentry.setExtra("key", value);
Sentry.addBreadcrumb({ category, message, level });

// ─── SCOPED CONTEXT ──────────────────────────────────────────────────────────
Sentry.withScope((scope) => {
  scope.setTag("feature", "payment");
  Sentry.captureException(err);
});

// ─── PERFORMANCE ─────────────────────────────────────────────────────────────
await Sentry.startSpan({ name: "my-task", op: "task" }, async () => {
  await doWork();
});

// ─── REPLAY ──────────────────────────────────────────────────────────────────
// maskAllText, blockAllMedia, maskAllInputs in replayIntegration()

// ─── FILTER ──────────────────────────────────────────────────────────────────
beforeSend(event) { return shouldDrop ? null : event; }
ignoreErrors: [/pattern/, "exact message"]
denyUrls: [/chrome-extension/]
tracesSampler(ctx) { return ctx.name.includes("/admin") ? 0 : 0.1; }

// ─── RELEASE ─────────────────────────────────────────────────────────────────
sentry-cli releases new "$VERSION"
sentry-cli releases set-commits "$VERSION" --auto
sentry-cli releases deploy "$VERSION" -e production
sentry-cli releases finalize "$VERSION"

// ─── SOURCE MAPS (Vite) ──────────────────────────────────────────────────────
sentryVitePlugin({ org, project, authToken, release: { name: VERSION } })
build: { sourcemap: true }
```

---

*Last updated for Sentry SDK v8.x — always check [docs.sentry.io](https://docs.sentry.io) for the latest API.*