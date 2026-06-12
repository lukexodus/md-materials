# The Complete Playwright Handbook
## A Production-Oriented Reference for Web Developers

---

> **Who this guide is for:** Web developers already comfortable with TypeScript, modern frontend frameworks, and the basics of web APIs. This guide focuses on *why* and *when*, not just *how*.

---

# Table of Contents

1. [Introduction](#1-introduction)
2. [Installation and Project Setup](#2-installation-and-project-setup)
3. [Core Concepts](#3-core-concepts)
4. [Locators](#4-locators)
5. [Actions](#5-actions)
6. [Assertions](#6-assertions)
7. [Waiting Strategies](#7-waiting-strategies)
8. [Navigation and Routing](#8-navigation-and-routing)
9. [Network Features](#9-network-features)
10. [Test Runner](#10-test-runner)
11. [Fixtures](#11-fixtures)
12. [Page Object Model (POM)](#12-page-object-model-pom)
13. [Authentication](#13-authentication)
14. [API Testing](#14-api-testing)
15. [Debugging](#15-debugging)
16. [Trace Viewer](#16-trace-viewer)
17. [Visual Testing](#17-visual-testing)
18. [Accessibility Testing](#18-accessibility-testing)
19. [Multi-Browser Testing](#19-multi-browser-testing)
20. [Mobile Testing](#20-mobile-testing)
21. [CI/CD Integration](#21-cicd-integration)
22. [Performance and Reliability](#22-performance-and-reliability)
23. [Advanced Topics](#23-advanced-topics)
24. [Real-World Architecture](#24-real-world-architecture)
25. [Best Practices](#25-best-practices)
26. [Anti-Patterns](#26-anti-patterns)

---

# 1. Introduction

## What Playwright Is

Playwright is a modern, open-source end-to-end (E2E) browser automation library developed and maintained by Microsoft. It lets you write scripts that control real browsers — Chromium, Firefox, and WebKit — programmatically. Unlike older tools that drove the browser via the DOM or injected JavaScript, Playwright communicates with browsers using the **Chrome DevTools Protocol (CDP)** for Chromium and equivalent low-level protocols for Firefox and WebKit. This gives it deep, reliable control over browser behavior.

Playwright supports tests written in **TypeScript, JavaScript, Python, Java, and .NET**, but the TypeScript/JavaScript API is the most mature and most commonly used in web development teams.

## Why Playwright Exists

The Microsoft team that built Playwright previously built **Puppeteer** (the Chrome-only headless automation library). Playwright was created to solve Puppeteer's key limitations:

- **Cross-browser support** — Puppeteer only targets Chromium. Playwright supports three distinct browser engines.
- **Auto-waiting** — Puppeteer required manual waits everywhere. Playwright built smart waiting into every action.
- **Better isolation** — Playwright's `BrowserContext` model enables true test isolation without spawning a full browser per test.
- **First-class TypeScript support** — With complete type definitions and a mature test runner.
- **Parallel execution and sharding** out of the box.

## Differences from Selenium

| Dimension | Selenium | Playwright |
|---|---|---|
| Protocol | WebDriver (HTTP-based) | CDP / WebSocket (event-driven) |
| Speed | Slower (round-trip HTTP) | Faster (persistent WebSocket) |
| Auto-waiting | None (you must wait manually) | Built-in for every action |
| Browser support | All major browsers + IE | Chromium, Firefox, WebKit |
| Setup complexity | High (drivers, grid) | Low (`npx playwright install`) |
| Language support | Java, Python, C#, JS, Ruby | TS/JS, Python, Java, .NET |
| Network interception | Limited | First-class feature |
| Test runner | External (JUnit, pytest) | Built-in (Playwright Test) |
| Debugging | External tools | Trace Viewer, Inspector built-in |
| Accessibility testing | Basic | Built-in `aria` snapshots |

**When to still consider Selenium:** Legacy environments locked into specific WebDriver infrastructure, teams maintaining very large existing Selenium suites, or regulatory contexts requiring the standard WebDriver specification.

## Differences from Cypress

| Dimension | Cypress | Playwright |
|---|---|---|
| Architecture | Runs inside the browser | Runs outside the browser |
| Cross-browser | Chromium, Firefox (experimental) | Chromium, Firefox, WebKit |
| Multi-tab support | No | Yes |
| iframes | Limited | Full support |
| Network layer | JavaScript (fetch/XHR intercept only) | Full network layer intercept |
| Parallelism | Requires Cypress Cloud (paid) | Built-in, free |
| API testing | Plugin-dependent | Built-in `APIRequestContext` |
| Speed | Slower on large suites | Faster |
| Test isolation | Per-test by default | Per-test via `BrowserContext` |
| Selector model | Cypress-specific | Web-standard + ARIA-first |
| Learning curve | Easier initial onboarding | Moderate but well-documented |
| Debugging | Time-travel UI (excellent) | Trace Viewer (excellent) |

**When Cypress may still be preferred:** Teams who value Cypress's excellent DX for component testing, or teams already deeply invested in the Cypress ecosystem.

## Advantages and Tradeoffs

### Advantages

- **True cross-browser testing** with WebKit (approximates Safari) — critical for catching Safari-specific bugs without owning macOS/iOS devices.
- **Auto-waiting everywhere** eliminates the most common source of flaky tests.
- **Network interception** is a first-class API, not an afterthought.
- **Context isolation** allows multiple authenticated sessions in one test.
- **Built-in parallelism and sharding** reduces CI time without paid infrastructure.
- **Trace Viewer** provides the best test debugging experience in the ecosystem.
- **API testing** in the same framework, allowing hybrid tests.
- **No browser limitations** — multiple tabs, file downloads, popups, web workers, service workers.

### Tradeoffs

- **No built-in component testing** (Cypress has this natively; there's a Playwright CT mode but it's less mature).
- **More verbose setup** than Cypress's zero-config experience.
- **Requires Node.js** (or another supported runtime) — not embeddable in-browser.
- **WebKit emulation** is not real Safari. Bugs unique to Safari on iOS hardware may still be missed.

## Supported Browsers

Playwright bundles its own browser builds and installs them via a CLI command:

- **Chromium** — Based on Chromium open-source. Matches Chrome/Edge behavior closely.
- **Firefox** — Standard Firefox with some protocol extensions.
- **WebKit** — Based on WebKit, approximating Safari behavior. Runs on Linux, macOS, and Windows.

Each browser binary is versioned alongside the Playwright release to guarantee compatibility. You do **not** use your system's installed browsers by default (though you can opt in via `channel` config for branded browsers like Chrome or Edge).

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                  Your Test Code                      │
│              (TypeScript / Node.js)                  │
└──────────────────────┬──────────────────────────────┘
                       │  Playwright API
┌──────────────────────▼──────────────────────────────┐
│              Playwright Library                      │
│   Browser  │  BrowserContext  │  Page  │  Frame      │
└───┬──────────────┬───────────────┬──────────────────┘
    │              │               │
    ▼              ▼               ▼
Chromium       Firefox          WebKit
(CDP/WS)    (Marionette+)    (WebKit Remote)
```

Playwright spawns a browser process, connects to it via a protocol, and maintains a persistent connection. Actions are sent as protocol messages and the browser responds with events. This is fundamentally faster and more reliable than polling-based or HTTP round-trip approaches.

---

# 2. Installation and Project Setup

## Installation

```bash
# Initialize a new project with Playwright Test runner
npm init playwright@latest

# Or add to an existing project
npm install -D @playwright/test

# Install browsers after installing the package
npx playwright install

# Install only specific browsers
npx playwright install chromium firefox

# Install browsers with system dependencies (important for CI)
npx playwright install --with-deps
```

## Project Initialization

Running `npm init playwright@latest` launches an interactive CLI that asks:

- TypeScript or JavaScript?
- Test directory name (default: `tests` or `e2e`)
- Add GitHub Actions workflow?
- Install Playwright browsers?

This generates a ready-to-run project.

## Recommended Folder Structure

```
my-project/
├── playwright.config.ts          # Main configuration
├── tests/
│   ├── auth/
│   │   ├── login.spec.ts
│   │   └── registration.spec.ts
│   ├── checkout/
│   │   └── checkout.spec.ts
│   └── api/
│       └── products.api.spec.ts
├── pages/                        # Page Object Models
│   ├── BasePage.ts
│   ├── LoginPage.ts
│   └── CheckoutPage.ts
├── fixtures/                     # Custom fixtures
│   ├── index.ts
│   └── auth.fixture.ts
├── utils/                        # Helpers and utilities
│   ├── api-client.ts
│   └── test-data.ts
├── test-data/                    # JSON/seed data
│   └── users.json
├── .auth/                        # Saved authentication state (gitignored)
│   └── user.json
└── playwright-report/            # Generated HTML report
```

## Configuration File

The `playwright.config.ts` file is central to your entire setup.

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  // Directory where tests live
  testDir: './tests',

  // Run test files in parallel
  fullyParallel: true,

  // Fail the build if you accidentally left test.only in source
  forbidOnly: !!process.env.CI,

  // Retry failed tests on CI only
  retries: process.env.CI ? 2 : 0,

  // Limit parallel workers on CI to avoid resource exhaustion
  workers: process.env.CI ? 4 : undefined,

  // Reporter: HTML report for local, line + HTML for CI
  reporter: process.env.CI
    ? [['html', { open: 'never' }], ['github']]
    : [['html'], ['list']],

  // Shared settings for all projects
  use: {
    // Base URL so you can use relative paths: page.goto('/')
    baseURL: process.env.BASE_URL ?? 'http://localhost:3000',

    // Record traces on first retry of a failed test
    trace: 'on-first-retry',

    // Capture screenshots on failure
    screenshot: 'only-on-failure',

    // Capture video on failure
    video: 'on-first-retry',

    // Global timeout per action
    actionTimeout: 10_000,

    // Navigation timeout
    navigationTimeout: 30_000,
  },

  // Global test timeout
  timeout: 60_000,

  // Expect timeout (assertion retry window)
  expect: {
    timeout: 5_000,
  },

  // Test projects (browser/device configurations)
  projects: [
    // --- Setup project for authentication ---
    {
      name: 'setup',
      testMatch: /.*\.setup\.ts/,
    },

    // --- Main browser projects ---
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
      dependencies: ['setup'],
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
      dependencies: ['setup'],
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
      dependencies: ['setup'],
    },

    // --- Mobile projects ---
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'mobile-safari',
      use: { ...devices['iPhone 14'] },
    },
  ],

  // Start your local dev server before running tests
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
});
```

## Browser Installation

```bash
# Install all browsers
npx playwright install

# Install specific browsers
npx playwright install chromium

# Install with OS-level dependencies (required in CI/Docker)
npx playwright install --with-deps chromium

# List installed browsers
npx playwright install --dry-run
```

## Environment Setup

Use `.env` files with a library like `dotenv`:

```bash
# .env.local
BASE_URL=http://localhost:3000
API_URL=http://localhost:3001
TEST_USER_EMAIL=test@example.com
TEST_USER_PASSWORD=supersecret
```

Load in config:

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';
import dotenv from 'dotenv';
import path from 'path';

// Load .env.local for local dev; .env.ci for CI
dotenv.config({
  path: path.resolve(__dirname, process.env.CI ? '.env.ci' : '.env.local'),
});
```

## CI-Friendly Setup

```yaml
# .github/workflows/playwright.yml (basic example; see Section 21 for full CI/CD)
- name: Install Playwright browsers
  run: npx playwright install --with-deps chromium

- name: Run tests
  run: npx playwright test
  env:
    BASE_URL: https://staging.myapp.com
```

> **Key principle:** Never commit `.auth/` state files or `.env.local` to version control. Add them to `.gitignore`.

---

# 3. Core Concepts

Understanding Playwright's component model is the foundation of writing reliable tests.

## The Component Hierarchy

```
Browser
  └── BrowserContext (isolated session)
        └── Page (a single browser tab)
              └── Frame (iframe or main frame)
                    └── ElementHandle / Locator
```

## Browser

A `Browser` represents a single launched browser instance. It is typically created once per worker process.

```typescript
import { chromium, Browser } from '@playwright/test';

// Manual browser launch (outside the test runner)
const browser: Browser = await chromium.launch({
  headless: true,         // Run without UI
  slowMo: 100,            // Slow down by 100ms (useful for debugging)
  args: ['--no-sandbox'], // Extra browser args (useful in CI/Docker)
});

await browser.close();
```

In Playwright Test, the `browser` fixture is managed automatically — you rarely instantiate it yourself.

## BrowserContext

A `BrowserContext` is an **isolated browser session**. It is analogous to an incognito profile — it has its own:

- Cookies
- LocalStorage / SessionStorage
- Cache
- Authentication state
- Service workers

This is Playwright's primary isolation mechanism. Each test gets its own context by default, so one test's authentication state, cookies, or storage never bleeds into another.

```typescript
// Creating a context manually (less common with the test runner)
const context = await browser.newContext({
  // Simulate a logged-in user by loading saved state
  storageState: '.auth/user.json',

  // Override geolocation
  geolocation: { latitude: 14.5995, longitude: 120.9842 },
  permissions: ['geolocation'],

  // Override viewport
  viewport: { width: 1280, height: 720 },

  // Set HTTP credentials for basic auth
  httpCredentials: { username: 'user', password: 'pass' },

  // Accept or reject dialogs automatically
  acceptDownloads: true,

  // Set extra HTTP headers for all requests in this context
  extraHTTPHeaders: {
    'X-Custom-Header': 'playwright-test',
  },
});
```

**Why this matters:** If your tests share a browser context, you have test pollution. Playwright Test's default fixture creates a fresh context per test — do not fight this unless you have a very good reason.

## Page

A `Page` represents a **single browser tab**. It is the object you interact with most.

```typescript
const page = await context.newPage();

await page.goto('https://example.com');
await page.fill('#email', 'user@example.com');
await page.click('button[type="submit"]');

await page.close();
```

With Playwright Test, the `page` fixture is a fresh page in a fresh context:

```typescript
import { test, expect } from '@playwright/test';

test('homepage loads', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle('My App');
});
```

## Frames

A `Frame` represents a browsing context within a `<iframe>` or the main document frame. Every `Page` is actually a `Frame` (the "main frame").

```typescript
// Access a frame by name or URL
const frame = page.frame({ name: 'payment-iframe' });
const frame = page.frame({ url: /stripe\.com/ });

// Or by locator
const frameElement = page.frameLocator('#payment-frame');
await frameElement.getByRole('textbox', { name: 'Card number' }).fill('4242...');
```

> **Why `frameLocator` over `frame()`:** `frameLocator` returns a `FrameLocator` which participates in Playwright's retry/auto-waiting machinery. The older `page.frame()` returns a `Frame` directly, which doesn't. Prefer `frameLocator` for actions inside iframes.

## Workers

Web Workers and Service Workers run in separate JavaScript contexts. Playwright can intercept and listen to them.

```typescript
// Listen for service workers
const swPromise = page.waitForEvent('serviceworker');
await page.goto('/');
const sw = await swPromise;
console.log(sw.url());

// Test that service worker caches correctly
// by intercepting and checking requests after reload
```

## Events

Playwright is event-driven. Pages, contexts, and browsers emit events you can listen to.

```typescript
// Listen for new tabs opened by the page
page.on('popup', async (popup) => {
  await popup.waitForLoadState();
  console.log(popup.url());
});

// Listen for console messages from the page
page.on('console', (msg) => {
  if (msg.type() === 'error') {
    console.error(`Browser error: ${msg.text()}`);
  }
});

// Listen for page crashes
page.on('crash', () => {
  console.error('Page crashed!');
});

// Listen for uncaught exceptions
page.on('pageerror', (err) => {
  console.error(`Uncaught exception: ${err}`);
});

// Listen for network requests
page.on('request', (request) => {
  console.log(`>> ${request.method()} ${request.url()}`);
});

page.on('response', (response) => {
  console.log(`<< ${response.status()} ${response.url()}`);
});
```

## Auto-Waiting

Auto-waiting is Playwright's most impactful feature for reducing flakiness. Before performing any action, Playwright waits for the target element to satisfy a set of **actionability conditions**. You do not need to manually wait before clicking, filling, etc.

```typescript
// Playwright does NOT immediately click the button.
// It waits until the button is:
//   - Attached to the DOM
//   - Visible
//   - Stable (not animating)
//   - Enabled
//   - Receives events (not covered by another element)
await page.click('#submit-button');

// Same auto-wait applies to fill, check, hover, etc.
await page.fill('#email', 'test@example.com');
```

## Actionability Checks

Before executing an action, Playwright verifies all relevant conditions:

| Check | Applies to |
|---|---|
| **Attached** | All actions |
| **Visible** | Most actions (not `waitForSelector`) |
| **Stable** | `click`, `dblclick`, `check`, `uncheck` |
| **Enabled** | `click`, `fill`, `check`, `uncheck`, `selectOption` |
| **Receives events** | `click`, `dblclick` |
| **Editable** | `fill`, `type`, `press` |

If an element fails an actionability check, Playwright retries until the `actionTimeout` is reached, then throws.

## Isolation Model

```
Per Worker:   Browser (shared)
Per Test:     BrowserContext (fresh)  ←  Cookies, storage, auth
Per Test:     Page (fresh)            ←  Navigation, DOM state
```

This model means:

- Tests run in **parallel** across workers, each with their own browser instance.
- Each test gets a **fresh context** — no shared cookies or storage.
- No test can accidentally rely on state left by another test.

The exception: when you intentionally reuse `storageState` for authentication (Section 13), you pre-load an auth state but still get a fresh context per test.

---

# 4. Locators

Locators are Playwright's mechanism for finding elements. Unlike `ElementHandle` (which captures a reference to a DOM node at a point in time), a `Locator` is **lazy** — it re-queries the DOM each time an action is performed, enabling automatic retry.

## Why Locators Over ElementHandle

```typescript
// ❌ ElementHandle — captured once, goes stale if DOM changes
const button = await page.$('#submit');
await button.click(); // May fail if DOM re-rendered between lines

// ✅ Locator — re-queries every time, retry-safe
const button = page.locator('#submit');
await button.click(); // Re-finds element each time, retries on failure
```

## getByRole — The Preferred Strategy

`getByRole` queries elements by their **ARIA role** and optional accessible properties. This is the most resilient locator strategy because it ties tests to how assistive technologies (and users) perceive the UI.

```typescript
// Buttons
await page.getByRole('button', { name: 'Submit' }).click();

// Links
await page.getByRole('link', { name: 'Sign In' }).click();

// Text inputs (identified by their accessible label)
await page.getByRole('textbox', { name: 'Email address' }).fill('user@example.com');

// Checkboxes
await page.getByRole('checkbox', { name: 'Remember me' }).check();

// Headings
await expect(page.getByRole('heading', { name: 'Dashboard', level: 1 })).toBeVisible();

// Navigation landmark
await page.getByRole('navigation').getByRole('link', { name: 'Products' }).click();

// Table
const table = page.getByRole('table', { name: 'Order History' });
await expect(table.getByRole('row')).toHaveCount(5);

// Options in listbox
await page.getByRole('option', { name: 'Australia' }).click();
```

**Why this is best:** Role-based locators survive refactoring of CSS classes, IDs, and DOM structure. They also enforce accessible markup — if you can't write a `getByRole` locator for a control, your markup may not be accessible.

## getByText

Locates elements by their visible text content.

```typescript
// Exact match (default is exact: false for substring)
await page.getByText('Sign in').click();

// Substring match
await page.getByText('Welcome,').click();

// Exact match
await page.getByText('Submit Order', { exact: true }).click();

// With regex
await page.getByText(/order #\d{6}/i).click();
```

> **Caution:** `getByText` can match unintended elements if the text appears in multiple places. Prefer `getByRole` when possible, or chain locators to scope the search.

## getByLabel

Finds form controls associated with a `<label>`. Works with `for`/`id` association and `aria-label`.

```typescript
// Finds <input> with a label "Email"
await page.getByLabel('Email').fill('test@example.com');
await page.getByLabel('Password').fill('secret');

// Also works with aria-label
await page.getByLabel('Search products').fill('laptop');
```

**Best practice:** `getByLabel` is the second-best locator for form inputs (after `getByRole`). It also validates that your forms have proper label associations.

## getByPlaceholder

Locates inputs by their `placeholder` attribute.

```typescript
await page.getByPlaceholder('Enter your email').fill('user@example.com');
await page.getByPlaceholder('Search...').fill('playwright');
```

> **When to use:** When a form element has a placeholder but no visible label — though ideally your UI should have both for accessibility reasons.

## getByAltText

Locates images by their `alt` attribute.

```typescript
await page.getByAltText('Company logo').click();
await expect(page.getByAltText('Product photo')).toBeVisible();
```

## getByTitle

Locates elements by their `title` attribute.

```typescript
await page.getByTitle('Close dialog').click();
await expect(page.getByTitle('Help tooltip')).toBeVisible();
```

## getByTestId

Locates elements by a data attribute. By default, Playwright uses `data-testid`.

```typescript
// In your markup: <button data-testid="add-to-cart">Add to Cart</button>
await page.getByTestId('add-to-cart').click();
```

Configure the attribute name in `playwright.config.ts`:

```typescript
use: {
  testIdAttribute: 'data-pw', // Use data-pw="..." instead
},
```

> **When to use test IDs:** As a last resort when no accessible locator exists. Test IDs couple tests to implementation details. They're useful for non-semantic elements like container `<div>`s, but consider whether adding a test ID means you also need to improve accessibility.

## locator()

The generic CSS/XPath/attribute-based locator. Accepts CSS selectors and Playwright's extended selector syntax.

```typescript
// CSS selectors
page.locator('#submit-button');
page.locator('.btn.btn-primary');
page.locator('button[type="submit"]');

// Playwright text selector (inside locator)
page.locator('text=Submit');
page.locator(':text("Submit")');

// Playwright has-text filter
page.locator('.card', { hasText: 'Featured' });

// Attribute selectors
page.locator('[data-state="active"]');
page.locator('input[name="email"]');

// XPath (avoid if possible — brittle and hard to read)
page.locator('xpath=//button[@type="submit"]');

// Combining Playwright selector engines
page.locator('article >> text=Read more');
```

## filter()

Filters locators to narrow down a matched set.

```typescript
// Get all list items
const listItems = page.locator('li');

// Filter to those containing specific text
const activeItem = listItems.filter({ hasText: 'Active' });

// Filter to those that contain a specific sub-locator
const itemWithBadge = listItems.filter({
  has: page.locator('.badge'),
});

// Filter to those WITHOUT a specific sub-locator
const itemsWithoutBadge = listItems.filter({
  hasNot: page.locator('.badge'),
});

// Chain filters
const activeItemWithBadge = listItems
  .filter({ hasText: 'Active' })
  .filter({ has: page.locator('.badge') });
```

## nth(), first(), last()

Index into a matched set.

```typescript
const rows = page.getByRole('row');

await rows.first().click();
await rows.last().click();
await rows.nth(2).click(); // 0-indexed

// In assertions
await expect(rows).toHaveCount(5);
await expect(rows.first()).toContainText('January');
```

## Strict Mode

By default, Playwright throws if a locator matches more than one element when performing an action. This is **strict mode** and it prevents accidentally acting on the wrong element.

```typescript
// ❌ Throws if multiple elements match
await page.getByRole('button', { name: 'Delete' }).click();
// Error: strict mode violation: locator resolved to 3 elements

// ✅ Be more specific
await page.getByRole('row', { name: 'Order #12345' })
  .getByRole('button', { name: 'Delete' })
  .click();

// ✅ Or explicitly select one
await page.getByRole('button', { name: 'Delete' }).first().click();
```

Assertions on locators that match multiple elements work differently — they apply to all matched elements.

## Locator Chaining

Chain locators to scope searches within a parent element.

```typescript
// Find within a specific section
const sidebar = page.locator('aside[role="complementary"]');
await sidebar.getByRole('link', { name: 'Account' }).click();

// Navigation pattern
const nav = page.getByRole('navigation', { name: 'Primary' });
const activeLink = nav.getByRole('link', { name: 'Dashboard' });
await expect(activeLink).toHaveAttribute('aria-current', 'page');

// Table row interaction
const productRow = page.getByRole('row', { name: 'Wireless Keyboard' });
await productRow.getByRole('button', { name: 'Edit' }).click();
```

## Locator Best Practices and Selector Hierarchy

Use this priority order, from most to least preferred:

```
1. getByRole          ← Ties tests to user-visible semantics
2. getByLabel         ← Great for form fields
3. getByText          ← For static visible text
4. getByTestId        ← For elements with no accessible identity
5. locator(css)       ← When structural selectors are stable
6. locator(xpath)     ← Last resort; avoid
```

### Resilient Selectors Checklist

- ✅ Do not rely on auto-generated class names (`.css-1a2b3c`)
- ✅ Do not rely on DOM position (`:nth-child(3)`)
- ✅ Do not rely on specific element types when roles suffice (`button` vs `getByRole('button')`)
- ✅ Chain locators to provide context rather than writing overly specific CSS paths
- ✅ Test IDs should be stable — add them to semantic elements when needed, not layout containers

### Accessibility-Driven Testing

When you use `getByRole`, `getByLabel`, and `getByAltText`, you're testing the application the way screen reader users experience it. If you find yourself unable to locate elements accessibly, that's a signal your markup needs improvement — your tests are finding real accessibility gaps.

```typescript
// This test fails on your form if the input has no label:
await page.getByLabel('Email address').fill('test@example.com');

// This test fails if your button has no accessible name:
await page.getByRole('button', { name: 'Submit' }).click();

// These failures tell you to fix the markup, not the test.
```

---

# 5. Actions

Playwright actions perform user interactions on the page. Every action includes auto-waiting for actionability.

## click

```typescript
// Standard click
await page.getByRole('button', { name: 'Submit' }).click();

// Click with options
await page.getByRole('button').click({
  button: 'right',         // 'left' | 'right' | 'middle'
  clickCount: 1,
  delay: 50,               // Delay between mousedown and mouseup (ms)
  position: { x: 10, y: 5 }, // Click at specific offset within element
  modifiers: ['Shift'],    // Hold Shift while clicking
  force: false,            // Skip actionability checks (avoid this)
  noWaitAfter: false,      // Don't wait for navigation after click
  timeout: 5000,
  trial: false,            // Check actionability without performing action
});
```

## dblclick

```typescript
await page.getByRole('row', { name: 'Order 123' }).dblclick();
```

## check and uncheck

```typescript
// Check a checkbox
await page.getByRole('checkbox', { name: 'Accept terms' }).check();

// Uncheck
await page.getByRole('checkbox', { name: 'Subscribe to newsletter' }).uncheck();

// Assert state
await expect(page.getByRole('checkbox', { name: 'Remember me' })).toBeChecked();
await expect(page.getByRole('checkbox', { name: 'Terms' })).not.toBeChecked();
```

## fill

Clears the current value and sets a new one. This is the most common way to fill form fields.

```typescript
// Fill an input
await page.getByLabel('Email').fill('user@example.com');
await page.getByLabel('Password').fill('secret123');

// Fill a textarea
await page.getByRole('textbox', { name: 'Description' }).fill('A long description...');

// Clear a field
await page.getByLabel('Search').fill('');
```

> **`fill` vs `type`:** `fill` is preferred — it's faster, atomic (sets value directly), and works on all input types including contenteditable. Use `type` only when you need to simulate slow character-by-character typing (e.g., for autocomplete dropdowns that trigger on each keystroke).

## type

Types text character by character, firing keyboard events for each character. Slower but simulates real user typing.

```typescript
// Simulate typing (triggers keydown/keypress/keyup per character)
await page.getByLabel('Search').type('playwright', { delay: 50 });
```

## press

Sends a keyboard key press to a focused element.

```typescript
// Press Enter
await page.getByLabel('Search').press('Enter');

// Press keyboard shortcut
await page.getByRole('textbox').press('Control+a'); // Select all
await page.getByRole('textbox').press('Control+c'); // Copy

// Common keys
await page.keyboard.press('Escape');
await page.keyboard.press('Tab');
await page.keyboard.press('ArrowDown');
```

## hover

Moves the mouse over an element. Useful for triggering hover-based menus and tooltips.

```typescript
// Hover to reveal a dropdown
await page.getByRole('button', { name: 'User menu' }).hover();
await page.getByRole('menuitem', { name: 'Settings' }).click();

// Verify tooltip appears on hover
await page.getByRole('button', { name: 'Info' }).hover();
await expect(page.getByRole('tooltip')).toBeVisible();
```

## Drag and Drop

```typescript
// High-level drag and drop
await page.getByRole('listitem', { name: 'Task 1' }).dragTo(
  page.getByRole('list', { name: 'Done' })
);

// With fine-grained control
await page.getByTestId('drag-handle').hover();
await page.mouse.down();
await page.mouse.move(500, 300, { steps: 10 }); // steps for smooth drag
await page.mouse.up();
```

## selectOption

For `<select>` elements.

```typescript
// Select by visible text
await page.getByLabel('Country').selectOption('Philippines');

// Select by value attribute
await page.getByLabel('Country').selectOption({ value: 'PH' });

// Select by index
await page.getByLabel('Month').selectOption({ index: 1 });

// Multi-select
await page.getByLabel('Interests').selectOption(['sports', 'tech', 'art']);
```

## Upload Files

```typescript
// Single file upload
await page.getByLabel('Upload profile photo').setInputFiles('path/to/photo.jpg');

// Multiple files
await page.getByLabel('Upload documents').setInputFiles([
  'path/to/doc1.pdf',
  'path/to/doc2.pdf',
]);

// Clear file input
await page.getByLabel('Upload').setInputFiles([]);

// Upload from buffer (without a real file)
await page.getByLabel('Upload').setInputFiles({
  name: 'test.txt',
  mimeType: 'text/plain',
  buffer: Buffer.from('file content'),
});
```

## Keyboard Actions

```typescript
// Global keyboard (not tied to an element)
await page.keyboard.press('Tab');
await page.keyboard.press('Control+Shift+I');

// Type raw text
await page.keyboard.type('Hello, World!');

// Press and hold / release for complex shortcuts
await page.keyboard.down('Shift');
await page.keyboard.press('ArrowRight');
await page.keyboard.press('ArrowRight');
await page.keyboard.up('Shift');
// Result: two characters selected
```

## Mouse Actions

```typescript
// Move to coordinates
await page.mouse.move(100, 200);

// Click at coordinates
await page.mouse.click(100, 200);

// Drag between coordinates
await page.mouse.move(100, 100);
await page.mouse.down();
await page.mouse.move(300, 300, { steps: 5 });
await page.mouse.up();

// Wheel scroll
await page.mouse.wheel(0, 300); // Scroll down 300px
```

## Actionability and Auto-Waiting Details

When you call `click()`, Playwright goes through this sequence:

1. **Resolve** the locator to a DOM element.
2. **Wait** until the element is attached, visible, stable, enabled, and receives events.
3. **Scroll** the element into view if needed.
4. **Move** the mouse pointer to the element's center.
5. **Execute** the action (mousedown, mouseup, click).
6. **Wait** for any navigations triggered by the action to complete.

If any step fails within the `actionTimeout`, the test fails with a descriptive error message indicating which actionability check failed.

```typescript
// Understanding force: true — use sparingly
// Skips actionability checks — can cause false positives
// Legitimate use: hovering over elements obscured by other elements
await page.locator('#tooltip-trigger').hover({ force: true });
```

---

# 6. Assertions

Playwright's assertion library (`expect`) is built specifically for async browser testing. It differs fundamentally from standard assertion libraries because it **retries until the assertion passes or times out**.

## Why Playwright Assertions Are Different

```typescript
// ❌ Node.js assertion — runs once, fails immediately
import assert from 'assert';
const text = await page.locator('h1').textContent();
assert.strictEqual(text, 'Dashboard'); // Fails if page hasn't loaded yet

// ✅ Playwright assertion — retries until condition is met or timeout exceeded
await expect(page.locator('h1')).toHaveText('Dashboard'); // Polls for up to 5s
```

The retry window is set by `expect.timeout` in your config (default: 5000ms). This eliminates an entire class of timing-related flakiness.

## Core Locator Assertions

```typescript
// Visibility
await expect(locator).toBeVisible();
await expect(locator).toBeHidden();

// Text content
await expect(locator).toHaveText('Exact text');
await expect(locator).toHaveText(/regex/);
await expect(locator).toContainText('partial text');

// Attribute
await expect(locator).toHaveAttribute('href', 'https://example.com');
await expect(locator).toHaveAttribute('aria-expanded', 'true');

// CSS class
await expect(locator).toHaveClass('active');
await expect(locator).toHaveClass(/btn-/);

// Value (for form inputs)
await expect(locator).toHaveValue('user@example.com');
await expect(locator).toHaveValue(/\d{4}/);

// Count
await expect(locator).toHaveCount(3);

// State
await expect(locator).toBeEnabled();
await expect(locator).toBeDisabled();
await expect(locator).toBeChecked();
await expect(locator).toBeFocused();
await expect(locator).toBeEditable();
await expect(locator).toBeEmpty(); // No value/text

// CSS property
await expect(locator).toHaveCSS('color', 'rgb(255, 0, 0)');

// JavaScript property
await expect(locator).toHaveJSProperty('checked', true);

// Screenshot
await expect(locator).toMatchAriaSnapshot(`- heading "Dashboard" [level=1]`);
```

## Page Assertions

```typescript
// URL
await expect(page).toHaveURL('https://example.com/dashboard');
await expect(page).toHaveURL(/\/dashboard/);

// Title
await expect(page).toHaveTitle('My Dashboard - App');
await expect(page).toHaveTitle(/Dashboard/);
```

## Soft Assertions

Soft assertions collect failures without stopping test execution. Useful for checking multiple independent conditions.

```typescript
// Soft assertions don't stop the test
await expect.soft(page.getByRole('heading')).toHaveText('Dashboard');
await expect.soft(page.getByTestId('user-name')).toHaveText('Arya');
await expect.soft(page.getByTestId('badge-count')).toHaveText('3');

// The test fails at the end if any soft assertion failed,
// but all assertions above are evaluated regardless.
```

## Negation

```typescript
await expect(locator).not.toBeVisible();
await expect(locator).not.toHaveText('Error');
await expect(page).not.toHaveURL(/login/);
```

## Polling Assertions

For non-Playwright async conditions:

```typescript
// Poll a custom async function until it returns a passing value
await expect(async () => {
  const response = await fetch('/api/status');
  const data = await response.json();
  expect(data.status).toBe('ready');
}).toPass({
  timeout: 30_000,
  intervals: [1_000, 2_000, 5_000], // Backoff intervals
});
```

## Custom Expect Messages

```typescript
await expect(locator, 'The dashboard heading should be visible after login').toBeVisible();
```

Custom messages appear in the test failure output, making failures much easier to understand.

## Accessibility Assertions

```typescript
// Snapshot the ARIA tree for an element (see Section 18)
await expect(page.locator('nav')).toMatchAriaSnapshot(`
  - navigation:
    - list:
      - listitem:
        - link "Dashboard"
      - listitem:
        - link "Reports"
`);
```

## Retry Behavior

The `expect.timeout` (default 5000ms) controls how long Playwright retries assertions. You can override per-assertion:

```typescript
// Override timeout for one assertion
await expect(locator).toHaveText('Loaded', { timeout: 15_000 });

// Disable timeout (wait indefinitely — avoid in production)
await expect(locator).toBeVisible({ timeout: 0 });
```

> **Best practice:** Tune `expect.timeout` globally for your application's typical response time. Don't override per-assertion unless genuinely needed — if you're frequently overriding, your app is slow or your config default is wrong.

---

# 7. Waiting Strategies

Auto-waiting handles most timing issues automatically. Understanding when and how to use explicit waits is essential for the remaining edge cases.

## Auto-Waiting (Built-in)

Every action and every `expect` assertion retries automatically. You should not need explicit waits before most actions.

```typescript
// ✅ This implicitly waits for the button to be actionable
await page.getByRole('button', { name: 'Load More' }).click();

// ✅ This implicitly retries until the text appears
await expect(page.getByRole('status')).toHaveText('Saved!');
```

## waitForSelector

Waits for an element matching a CSS selector to be in a specific state. Prefer `expect(locator).toBeVisible()` for assertions, but `waitForSelector` has a role in imperative flows.

```typescript
// Wait until element is attached to DOM (default: 'attached')
await page.waitForSelector('.spinner', { state: 'detached' }); // Wait for spinner to disappear

// States: 'attached' | 'detached' | 'visible' | 'hidden'
await page.waitForSelector('#content', { state: 'visible', timeout: 10_000 });
```

## waitForURL

Waits for the page URL to match.

```typescript
// After a form submission that redirects
await page.getByRole('button', { name: 'Login' }).click();
await page.waitForURL('/dashboard', { timeout: 10_000 });

// With regex
await page.waitForURL(/\/orders\/\d+/);

// With waitUntil (default: 'load')
await page.waitForURL('/success', { waitUntil: 'networkidle' });
```

## waitForLoadState

```typescript
// 'load'         — fires when window.load event fires (default for goto)
// 'domcontentloaded' — fires when DOMContentLoaded fires
// 'networkidle'  — fires when no network requests for 500ms (fragile, avoid)

await page.waitForLoadState('domcontentloaded');

// Most reliable sequence after navigation:
await page.goto('/dashboard');
// Don't use networkidle unless necessary — it waits for ALL requests
// and can be very slow or never resolve on pages with polling
```

> **`networkidle` warning:** Avoid `networkidle` in most cases. Any page with analytics, polling, or WebSockets will trigger it unreliably. Use specific element assertions instead.

## waitForResponse

Waits for a network response matching a URL or predicate.

```typescript
// Wait for a specific API call to complete after an action
const [response] = await Promise.all([
  page.waitForResponse('/api/products'),
  page.getByRole('button', { name: 'Refresh' }).click(),
]);

const data = await response.json();
expect(data.products).toHaveLength(10);

// With predicate
const apiResponse = await page.waitForResponse(
  (resp) => resp.url().includes('/api/users') && resp.status() === 200
);
```

## waitForRequest

Waits for a network request to be made.

```typescript
const [request] = await Promise.all([
  page.waitForRequest('/api/analytics'),
  page.getByRole('button', { name: 'Track Event' }).click(),
]);

expect(request.method()).toBe('POST');
expect(await request.postDataJSON()).toMatchObject({
  event: 'button_click',
});
```

## Custom Waits with waitForFunction

Executes a function in the browser context and waits for it to return truthy.

```typescript
// Wait for a JavaScript condition in the browser
await page.waitForFunction(() => {
  return window.__appReady === true;
}, { timeout: 10_000 });

// Wait for a value to appear in the DOM
await page.waitForFunction(
  (selector) => document.querySelector(selector)?.textContent?.includes('Ready'),
  '#status',
  { polling: 'raf' } // Use requestAnimationFrame for performance
);
```

## When Waits Are Unnecessary

```typescript
// ❌ Unnecessary — page.goto already waits for load
await page.goto('/login');
await page.waitForLoadState('load'); // Redundant

// ❌ Unnecessary — click auto-waits for actionability
await page.waitForSelector('#submit'); // Redundant
await page.click('#submit');

// ❌ Unnecessary — expect retries until condition is met
await page.waitForTimeout(1000); // ← Anti-pattern (see Section 26)
await expect(page.getByRole('alert')).toBeVisible();
```

## Common Waiting Mistakes

```typescript
// ❌ Hard-coded sleep — flaky and slow
await page.waitForTimeout(3000);

// ❌ waitForLoadState('networkidle') on SPAs
// Pages with real-time data, polling, or analytics never go idle

// ❌ Waiting for the element, then acting (double-wait)
await page.waitForSelector('#btn');
await page.click('#btn'); // Already waited — now waits again

// ✅ Just act — auto-wait handles it
await page.click('#btn');
```

## Flaky Test Prevention

The most common sources of flakiness and their solutions:

| Problem | Wrong approach | Correct approach |
|---|---|---|
| Animation not done | `waitForTimeout(500)` | `expect(el).toHaveCSS(...)` or disable animations in test |
| Data not loaded | `waitForTimeout(2000)` | `expect(el).toHaveText(expectedData)` |
| Redirect not complete | `waitForTimeout(1000)` | `waitForURL(/target/)` |
| API not called yet | Check immediately | `waitForResponse` with action |
| Race with re-render | Re-query after action | Use locators (they re-query) |

---

# 8. Navigation and Routing

## page.goto

```typescript
// Navigate to a URL
await page.goto('https://example.com');

// Use baseURL from config — preferred for portability
await page.goto('/login');

// Control when navigation is considered complete
await page.goto('/app', {
  waitUntil: 'domcontentloaded', // Faster than 'load'
  timeout: 30_000,
});

// Get the response from the navigation
const response = await page.goto('/');
expect(response?.status()).toBe(200);
```

## Navigation Lifecycle

Each navigation goes through distinct events:

```
1. Request sent
2. Server responds (status code received)
3. DOM parsed → 'domcontentloaded' fires
4. Resources loaded (images, scripts) → 'load' fires
5. No network activity for 500ms → 'networkidle' fires (avoid)
```

```typescript
// For most SPAs, domcontentloaded is sufficient and faster
await page.goto('/dashboard', { waitUntil: 'domcontentloaded' });
// Then wait for a meaningful element to confirm the app rendered
await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
```

## Handling Redirects

```typescript
// goto follows redirects automatically
const response = await page.goto('/old-path');

// Check if a redirect occurred
if (response) {
  const chain = response.request().redirectedFrom();
  console.log('Redirected from:', chain?.url());
}

// Wait for final URL after a delayed redirect
await page.goto('/login');
await page.getByLabel('Email').fill('user@example.com');
await page.getByLabel('Password').fill('secret');
await page.getByRole('button', { name: 'Login' }).click();
await page.waitForURL('/dashboard');
```

## Route Interception

Route interception allows you to intercept and modify network requests made by the page. This is essential for mocking APIs, testing error states, and simulating slow networks.

```typescript
// Intercept and fulfill (mock) a request
await page.route('/api/products', async (route) => {
  await route.fulfill({
    status: 200,
    contentType: 'application/json',
    body: JSON.stringify([
      { id: 1, name: 'Laptop', price: 999 },
      { id: 2, name: 'Mouse', price: 29 },
    ]),
  });
});

await page.goto('/products');
await expect(page.getByRole('listitem')).toHaveCount(2);
```

```typescript
// Intercept and abort (simulate network error)
await page.route('/api/data', (route) => route.abort('failed'));

await page.goto('/');
await expect(page.getByRole('alert')).toContainText('Failed to load data');
```

```typescript
// Intercept and modify an existing response
await page.route('/api/user', async (route) => {
  const response = await route.fetch(); // Get the real response
  const body = await response.json();
  body.role = 'admin'; // Modify it
  await route.fulfill({ response, body: JSON.stringify(body) });
});
```

```typescript
// Intercept based on pattern
await page.route('**/api/**', (route) => {
  console.log('API call:', route.request().url());
  route.continue(); // Let it pass through
});

// Intercept by HTTP method
await page.route('/api/items', (route) => {
  if (route.request().method() === 'DELETE') {
    route.fulfill({ status: 403, body: 'Forbidden' });
  } else {
    route.continue();
  }
});
```

## Request Mocking

```typescript
// Context-level route — applies to all pages in context
await context.route('/api/**', async (route) => {
  const fixtures: Record<string, unknown> = {
    '/api/products': { products: [] },
    '/api/user': { name: 'Test User', role: 'admin' },
  };

  const url = new URL(route.request().url());
  const match = fixtures[url.pathname];

  if (match) {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify(match),
    });
  } else {
    await route.continue();
  }
});
```

## HAR Files

HAR (HTTP Archive) files record and replay network interactions.

```typescript
// Record network interactions to a HAR file
await page.routeFromHAR('./fixtures/api.har', {
  url: /api\.example\.com/,
  update: false, // true = update HAR with live responses
});
```

To record a HAR:

```bash
npx playwright open --save-har=api.har https://example.com
```

HAR replay is excellent for tests that depend on third-party APIs — record once, replay forever without hitting the real service.

---

# 9. Network Features

## Request Inspection

```typescript
// Listen for all requests
page.on('request', (request) => {
  console.log(`→ ${request.method()} ${request.url()}`);
  if (request.postData()) {
    console.log('  Body:', request.postData());
  }
});

// Inspect headers
page.on('request', (request) => {
  console.log('Headers:', request.headers());
});
```

## Response Inspection

```typescript
// Listen for all responses
page.on('response', async (response) => {
  if (response.url().includes('/api/')) {
    console.log(`← ${response.status()} ${response.url()}`);
    if (response.headers()['content-type']?.includes('json')) {
      const body = await response.json();
      console.log('Body:', body);
    }
  }
});

// Capture and inspect a specific response
const responsePromise = page.waitForResponse('/api/checkout');
await page.getByRole('button', { name: 'Place Order' }).click();
const response = await responsePromise;
expect(response.status()).toBe(200);
const order = await response.json();
expect(order.orderId).toMatch(/^ORD-\d+$/);
```

## Route Handlers (Advanced Patterns)

```typescript
// Simulate rate limiting
let requestCount = 0;
await page.route('/api/search', async (route) => {
  requestCount++;
  if (requestCount > 3) {
    await route.fulfill({ status: 429, body: 'Too Many Requests' });
  } else {
    await route.continue();
  }
});

// Simulate slow network response
await page.route('/api/heavy-data', async (route) => {
  await new Promise((resolve) => setTimeout(resolve, 2000)); // 2s delay
  await route.continue();
});

// Simulate partial content (streaming)
await page.route('/api/download', async (route) => {
  await route.fulfill({
    status: 200,
    headers: { 'Content-Type': 'text/plain' },
    body: 'Partial data...',
  });
});
```

## Network Stubbing Strategy

The best pattern for network stubbing is to define your mocks close to the test that uses them, not in global setup:

```typescript
// fixtures/api-mocks.ts
export const mockProducts = (page: Page, overrides = {}) =>
  page.route('/api/products', (route) =>
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        products: [
          { id: 1, name: 'Laptop', price: 999, ...overrides },
        ],
      }),
    })
  );

// In your test:
test('shows product list', async ({ page }) => {
  await mockProducts(page);
  await page.goto('/products');
  await expect(page.getByRole('listitem')).toHaveCount(1);
});

test('shows error when product is out of stock', async ({ page }) => {
  await mockProducts(page, { inStock: false });
  await page.goto('/products');
  await expect(page.getByText('Out of Stock')).toBeVisible();
});
```

## API Testing Within Network Layer

```typescript
// Validate outgoing requests from the page
test('analytics event is sent on button click', async ({ page }) => {
  const analyticsRequest = page.waitForRequest(
    (req) =>
      req.url().includes('/analytics') &&
      req.method() === 'POST'
  );

  await page.goto('/home');
  await page.getByRole('button', { name: 'Get Started' }).click();

  const request = await analyticsRequest;
  const payload = request.postDataJSON();

  expect(payload).toMatchObject({
    event: 'cta_click',
    page: '/home',
  });
});
```

## Authentication Flows

```typescript
// Intercept and inject auth headers
await context.route('/api/**', async (route) => {
  const request = route.request();
  await route.continue({
    headers: {
      ...request.headers(),
      'Authorization': `Bearer ${process.env.TEST_TOKEN}`,
    },
  });
});

// Mock OAuth token exchange
await page.route('/oauth/token', (route) =>
  route.fulfill({
    status: 200,
    contentType: 'application/json',
    body: JSON.stringify({
      access_token: 'mock-token-12345',
      token_type: 'Bearer',
      expires_in: 3600,
    }),
  })
);
```

---

# 10. Test Runner

Playwright ships with its own test runner (`@playwright/test`) that is deeply integrated with its browser automation layer.

## test()

The fundamental unit of work.

```typescript
import { test, expect } from '@playwright/test';

test('user can log in', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('secret');
  await page.getByRole('button', { name: 'Sign In' }).click();
  await expect(page).toHaveURL('/dashboard');
});
```

## describe()

Groups related tests. Supports nesting.

```typescript
test.describe('Checkout flow', () => {
  test.describe('Guest checkout', () => {
    test('adds item to cart', async ({ page }) => { /* ... */ });
    test('completes purchase', async ({ page }) => { /* ... */ });
  });

  test.describe('Authenticated checkout', () => {
    test.use({ storageState: '.auth/user.json' });

    test('shows saved addresses', async ({ page }) => { /* ... */ });
    test('applies stored payment method', async ({ page }) => { /* ... */ });
  });
});
```

## beforeEach / afterEach

Run before or after each test in the current scope.

```typescript
test.describe('Product management', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/admin/products');
    // Ensure we're on the right page before each test
    await expect(page.getByRole('heading', { name: 'Products' })).toBeVisible();
  });

  test.afterEach(async ({ page }, testInfo) => {
    // Clean up: delete any products created during the test
    if (testInfo.status === 'failed') {
      await page.screenshot({ path: `screenshots/${testInfo.title}.png` });
    }
  });

  test('creates a product', async ({ page }) => { /* ... */ });
  test('edits a product', async ({ page }) => { /* ... */ });
});
```

## beforeAll / afterAll

Run once before/after all tests in the scope. Note: these run in a **separate worker-level context**, not the same page as the tests.

```typescript
test.describe('Report generation', () => {
  let reportId: string;

  test.beforeAll(async ({ request }) => {
    // Create a report via API once for all tests in this group
    const response = await request.post('/api/reports', {
      data: { type: 'annual', year: 2024 },
    });
    const report = await response.json();
    reportId = report.id;
  });

  test.afterAll(async ({ request }) => {
    // Clean up the report after all tests
    await request.delete(`/api/reports/${reportId}`);
  });

  test('displays report summary', async ({ page }) => {
    await page.goto(`/reports/${reportId}`);
    // ...
  });
});
```

## Hooks

```typescript
// test.use() — override options for a describe block
test.describe('Admin area', () => {
  test.use({
    storageState: '.auth/admin.json',
    viewport: { width: 1920, height: 1080 },
  });

  test('manages users', async ({ page }) => { /* ... */ });
});
```

## Tags and Annotations

```typescript
// Tag tests for filtering
test('smoke test', {
  tag: '@smoke',
}, async ({ page }) => { /* ... */ });

test('regression test', {
  tag: ['@regression', '@checkout'],
}, async ({ page }) => { /* ... */ });

// Annotations
test('known bug', {
  annotation: {
    type: 'issue',
    description: 'https://github.com/my-org/app/issues/1234',
  },
}, async ({ page }) => { /* ... */ });
```

Run filtered by tag:

```bash
npx playwright test --grep @smoke
npx playwright test --grep-invert @slow
```

## Test Modifiers

```typescript
// Skip a test
test.skip('not implemented yet', async ({ page }) => { /* ... */ });

// Skip conditionally
test.skip(({ browserName }) => browserName === 'webkit', 'Safari not supported');

// Mark as "only" (runs exclusively — never commit this!)
test.only('debugging this test', async ({ page }) => { /* ... */ });

// Mark expected to fail (xfail)
test.fail('known bug in payments', async ({ page }) => { /* ... */ });

// Mark as "fixme"
test.fixme('TODO: implement checkout test', async ({ page }) => { /* ... */ });

// Slow test — triple the timeout
test.slow();
```

## Filtering Tests

```bash
# Run by file name
npx playwright test login

# Run by test title
npx playwright test --grep "user can log in"

# Run specific project
npx playwright test --project=chromium

# Run in a specific directory
npx playwright test tests/auth/

# Run a single file
npx playwright test tests/auth/login.spec.ts
```

## Retries

```typescript
// Global retry config (playwright.config.ts)
retries: process.env.CI ? 2 : 0,

// Per-test retry override
test('flaky external service test', {
  retries: 3,
}, async ({ page }) => { /* ... */ });
```

```typescript
// Know when you're in a retry
test('with retry awareness', async ({ page }, testInfo) => {
  if (testInfo.retry > 0) {
    console.log(`Retry #${testInfo.retry}`);
    // Maybe do extra cleanup
  }
});
```

> **Retry philosophy:** Retries should be a safety net, not a crutch. A test that needs 3 retries to pass is a flaky test that needs to be fixed. Track your retry rate in CI and treat high-retry tests as bugs.

## Parallel Execution

Playwright runs tests in parallel by default. Workers are separate Node.js processes, each running their own browser instance.

```typescript
// playwright.config.ts
fullyParallel: true,     // Each test file runs in parallel
workers: 4,              // Max 4 parallel workers

// Per-file parallelism — tests within a file run sequentially by default
// To parallelize tests within a file:
test.describe.configure({ mode: 'parallel' });

// Force sequential execution for a describe block
test.describe.configure({ mode: 'serial' });
```

## Sharding

Sharding splits the test suite across multiple CI machines.

```bash
# Machine 1 of 3
npx playwright test --shard=1/3

# Machine 2 of 3
npx playwright test --shard=2/3

# Machine 3 of 3
npx playwright test --shard=3/3
```

Merge shard reports:

```bash
npx playwright merge-reports --reporter html ./blob-reports
```

## Project Organization

Organize test files by feature domain, not by type:

```
tests/
├── auth/
│   ├── login.spec.ts
│   ├── register.spec.ts
│   └── password-reset.spec.ts
├── products/
│   ├── listing.spec.ts
│   ├── detail.spec.ts
│   └── search.spec.ts
├── checkout/
│   ├── cart.spec.ts
│   └── payment.spec.ts
└── api/
    ├── products.api.spec.ts
    └── orders.api.spec.ts
```

---

# 11. Fixtures

Fixtures are Playwright's dependency injection system for tests. They allow you to share setup and teardown logic across tests without inheritance or global state.

## Built-in Fixtures

Playwright Test provides these fixtures automatically:

| Fixture | Scope | Description |
|---|---|---|
| `browser` | Worker | Shared browser instance |
| `context` | Test | Fresh `BrowserContext` per test |
| `page` | Test | Fresh `Page` per test |
| `request` | Test | `APIRequestContext` per test |
| `browserName` | Worker | `'chromium'` \| `'firefox'` \| `'webkit'` |
| `isMobile` | Worker | Whether running with mobile device |
| `baseURL` | Worker | The configured `baseURL` |
| `playwright` | Worker | Playwright object for advanced use |
| `testInfo` | Test | Metadata about the current test |

## Custom Fixtures

Define custom fixtures by extending the base `test` object:

```typescript
// fixtures/index.ts
import { test as baseTest, expect } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';
import { ProductsPage } from '../pages/ProductsPage';

type MyFixtures = {
  loginPage: LoginPage;
  productsPage: ProductsPage;
};

export const test = baseTest.extend<MyFixtures>({
  // Page object fixtures — created fresh per test
  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page));
  },

  productsPage: async ({ page }, use) => {
    await use(new ProductsPage(page));
  },
});

export { expect };
```

Usage:

```typescript
// tests/auth/login.spec.ts
import { test, expect } from '../../fixtures';

test('user logs in successfully', async ({ loginPage }) => {
  await loginPage.goto();
  await loginPage.login('user@example.com', 'secret');
  await expect(loginPage.page).toHaveURL('/dashboard');
});
```

## Worker-Scoped Fixtures

Worker-scoped fixtures are created once per worker and shared across all tests in that worker. Suitable for expensive setup like database connections or admin API clients.

```typescript
type WorkerFixtures = {
  adminToken: string;
  dbConnection: DatabaseConnection;
};

export const test = baseTest.extend<{}, WorkerFixtures>({
  // Worker scope: second type parameter
  adminToken: [async ({}, use) => {
    const token = await fetchAdminToken(); // Run once per worker
    await use(token);
    // Teardown (optional)
  }, { scope: 'worker' }],
});
```

## Fixture Dependency Injection

Fixtures can depend on other fixtures:

```typescript
type Fixtures = {
  authenticatedPage: Page;
  adminPage: Page;
};

export const test = baseTest.extend<Fixtures>({
  // This fixture depends on the built-in 'page' and 'context' fixtures
  authenticatedPage: async ({ page, context }, use) => {
    // Load saved auth state into the context
    await context.addCookies(await getAuthCookies());
    await page.goto('/dashboard');
    await use(page);
    // Teardown: navigate away to clean up
    await page.goto('about:blank');
  },

  adminPage: async ({ browser }, use) => {
    // Create an entirely separate context for admin user
    const adminContext = await browser.newContext({
      storageState: '.auth/admin.json',
    });
    const adminPage = await adminContext.newPage();
    await use(adminPage);
    await adminContext.close();
  },
});
```

## Advanced Fixture Example: API + UI Combined

```typescript
// fixtures/full.ts
import { test as base, expect } from '@playwright/test';
import type { APIRequestContext } from '@playwright/test';

type Fixtures = {
  apiClient: APIRequestContext;
  testUser: { email: string; id: string };
  authenticatedPage: Page;
};

export const test = base.extend<Fixtures>({
  apiClient: async ({ request }, use) => {
    await use(request);
  },

  // Create a test user via API, provide it, then delete after test
  testUser: async ({ apiClient }, use) => {
    const response = await apiClient.post('/api/test/users', {
      data: {
        email: `test-${Date.now()}@example.com`,
        password: 'TestPass123!',
      },
    });
    const user = await response.json();

    await use(user);

    // Teardown: delete the user
    await apiClient.delete(`/api/test/users/${user.id}`);
  },

  // Log in as the test user, provide the authenticated page
  authenticatedPage: async ({ page, testUser }, use) => {
    await page.goto('/login');
    await page.getByLabel('Email').fill(testUser.email);
    await page.getByLabel('Password').fill('TestPass123!');
    await page.getByRole('button', { name: 'Sign In' }).click();
    await page.waitForURL('/dashboard');

    await use(page);
  },
});

export { expect };
```

## Reusable Test Architecture

The fixture pattern enables powerful composition:

```typescript
// tests/profile.spec.ts
import { test, expect } from '../fixtures/full';

// This test gets a real user created via API, logged in, with a page ready
test('user can update their profile', async ({ authenticatedPage, testUser }) => {
  await authenticatedPage.getByRole('link', { name: 'Profile' }).click();
  await authenticatedPage.getByLabel('Display Name').fill('New Name');
  await authenticatedPage.getByRole('button', { name: 'Save' }).click();

  await expect(authenticatedPage.getByRole('status')).toContainText('Profile updated');

  // Verify via API — the testUser fixture provides the ID
  const response = await authenticatedPage.request.get(`/api/users/${testUser.id}`);
  const user = await response.json();
  expect(user.displayName).toBe('New Name');
});
```

---

# 12. Page Object Model (POM)

## POM Fundamentals

The Page Object Model encapsulates the UI structure and interactions of a page into a class, exposing high-level methods that reflect user intentions.

```typescript
// pages/LoginPage.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly page: Page;

  // Locators as properties — evaluated lazily
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Sign In' });
    this.errorMessage = page.getByRole('alert');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(message: string) {
    await expect(this.errorMessage).toContainText(message);
  }
}
```

```typescript
// In tests:
const loginPage = new LoginPage(page);
await loginPage.goto();
await loginPage.login('user@example.com', 'wrong-password');
await loginPage.expectError('Invalid credentials');
```

## Benefits

- **Encapsulation:** UI details are hidden behind intent-revealing methods.
- **Reuse:** Login logic written once, used in dozens of tests.
- **Maintainability:** When the UI changes, update one class, not every test.
- **Readability:** Tests read like specifications, not HTML traversal.

## Drawbacks (and Mitigations)

- **Overgrowth:** Page objects can become huge god objects. Mitigation: split by feature area, not just by page.
- **Abstraction misalignment:** Page objects sometimes hide important test detail. Mitigation: keep methods at the right level of abstraction — not too granular (one method per element) and not too coarse.
- **Test coupling:** Tests depend on the page object implementation. Mitigation: keep page objects focused on UI interactions, not test assertions.

## Component Objects

For reusable UI components (nav, modals, tables), create component objects:

```typescript
// pages/components/DataTable.ts
import { Locator, Page } from '@playwright/test';

export class DataTable {
  private root: Locator;

  constructor(locator: Locator) {
    this.root = locator;
  }

  row(name: string): Locator {
    return this.root.getByRole('row', { name });
  }

  async getCell(rowName: string, columnName: string): Promise<string> {
    const row = this.row(rowName);
    const headerCells = this.root.getByRole('columnheader');
    const count = await headerCells.count();
    let colIndex = -1;

    for (let i = 0; i < count; i++) {
      const text = await headerCells.nth(i).textContent();
      if (text?.trim() === columnName) {
        colIndex = i;
        break;
      }
    }

    return (await row.getByRole('cell').nth(colIndex).textContent()) ?? '';
  }

  async sort(columnName: string) {
    await this.root.getByRole('columnheader', { name: columnName }).click();
  }
}
```

Usage:

```typescript
// pages/OrdersPage.ts
export class OrdersPage {
  readonly ordersTable: DataTable;

  constructor(page: Page) {
    this.ordersTable = new DataTable(
      page.getByRole('table', { name: 'Orders' })
    );
  }
}

// In test:
const orderStatus = await ordersPage.ordersTable.getCell('Order #123', 'Status');
expect(orderStatus).toBe('Shipped');
```

## Scalable Architecture

For large applications, use a directory structure that mirrors your application's routing:

```
pages/
├── BasePage.ts           ← Shared navigation, header, footer
├── auth/
│   ├── LoginPage.ts
│   └── RegisterPage.ts
├── products/
│   ├── ProductListPage.ts
│   └── ProductDetailPage.ts
├── checkout/
│   ├── CartPage.ts
│   └── CheckoutPage.ts
└── components/
    ├── DataTable.ts
    ├── Modal.ts
    ├── Toast.ts
    └── NavigationMenu.ts
```

```typescript
// pages/BasePage.ts
export abstract class BasePage {
  constructor(protected readonly page: Page) {}

  get header() {
    return new NavigationMenu(this.page.getByRole('banner'));
  }

  get toast() {
    return new Toast(this.page.getByRole('status'));
  }

  async waitForPageReady() {
    await this.page.waitForLoadState('domcontentloaded');
    // Wait for any loading spinners to disappear
    await this.page.locator('[aria-busy="true"]').waitFor({ state: 'hidden' }).catch(() => {});
  }
}
```

---

# 13. Authentication

Authentication is a critical challenge in E2E tests. Logging in before every test is slow and brittle. Playwright's `storageState` feature solves this elegantly.

## The Authentication Strategy

```
1. Run a setup project that logs in once and saves the session to a file.
2. Each test loads the saved session into a fresh BrowserContext.
3. Tests start already logged in — no login form needed.
```

## Creating the Setup Script

```typescript
// tests/auth/auth.setup.ts
import { test as setup, expect } from '@playwright/test';
import path from 'path';

const authFile = path.join(__dirname, '../../.auth/user.json');

setup('authenticate as standard user', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill(process.env.TEST_USER_EMAIL!);
  await page.getByLabel('Password').fill(process.env.TEST_USER_PASSWORD!);
  await page.getByRole('button', { name: 'Sign In' }).click();

  // Wait until we're on the dashboard — confirms login succeeded
  await page.waitForURL('/dashboard');
  await expect(page.getByRole('navigation')).toBeVisible();

  // Save session to file
  await page.context().storageState({ path: authFile });
});
```

## Configuring Projects with Authentication

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  projects: [
    // Setup runs first
    {
      name: 'setup',
      testMatch: /.*\.setup\.ts/,
    },

    // Tests depend on setup
    {
      name: 'authenticated',
      testDir: './tests',
      use: {
        storageState: '.auth/user.json',
      },
      dependencies: ['setup'],
    },

    // Unauthenticated tests don't need setup
    {
      name: 'public',
      testDir: './tests/public',
      // No storageState, no dependencies
    },
  ],
});
```

## Multiple Roles

```typescript
// tests/auth/auth.setup.ts
import { test as setup } from '@playwright/test';

setup('authenticate as admin', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill(process.env.ADMIN_EMAIL!);
  await page.getByLabel('Password').fill(process.env.ADMIN_PASSWORD!);
  await page.getByRole('button', { name: 'Sign In' }).click();
  await page.waitForURL('/admin');
  await page.context().storageState({ path: '.auth/admin.json' });
});

setup('authenticate as viewer', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill(process.env.VIEWER_EMAIL!);
  await page.getByLabel('Password').fill(process.env.VIEWER_PASSWORD!);
  await page.getByRole('button', { name: 'Sign In' }).click();
  await page.waitForURL('/dashboard');
  await page.context().storageState({ path: '.auth/viewer.json' });
});
```

```typescript
// playwright.config.ts — multiple authenticated projects
projects: [
  { name: 'setup', testMatch: /.*\.setup\.ts/ },
  {
    name: 'admin-tests',
    use: { storageState: '.auth/admin.json' },
    dependencies: ['setup'],
    testMatch: '**/admin/**/*.spec.ts',
  },
  {
    name: 'viewer-tests',
    use: { storageState: '.auth/viewer.json' },
    dependencies: ['setup'],
    testMatch: '**/viewer/**/*.spec.ts',
  },
],
```

## Role-Based Testing

```typescript
// Test that admins see controls viewers don't
test.describe('role-based access', () => {
  test('admin sees delete button', async ({ page }) => {
    // page already has .auth/admin.json loaded
    await page.goto('/products');
    await expect(page.getByRole('button', { name: 'Delete' })).toBeVisible();
  });
});

// Switch to viewer role in a different project / test file
test('viewer does not see delete button', async ({ page }) => {
  // page already has .auth/viewer.json loaded
  await page.goto('/products');
  await expect(page.getByRole('button', { name: 'Delete' })).toBeHidden();
});
```

## API-Based Authentication (Faster)

For applications with a public API, authenticate via API rather than the UI — it's faster and more reliable.

```typescript
// tests/auth/auth.setup.ts
setup('authenticate via API', async ({ request, page }) => {
  // Get token via API
  const response = await request.post('/api/auth/login', {
    data: {
      email: process.env.TEST_USER_EMAIL,
      password: process.env.TEST_USER_PASSWORD,
    },
  });

  expect(response.ok()).toBeTruthy();
  const { token } = await response.json();

  // Set cookies/localStorage directly
  await page.goto('/');
  await page.evaluate((t) => {
    localStorage.setItem('auth_token', t);
  }, token);

  // Or add cookies directly
  await page.context().addCookies([{
    name: 'session_token',
    value: token,
    domain: 'localhost',
    path: '/',
  }]);

  await page.context().storageState({ path: '.auth/user.json' });
});
```

---

# 14. API Testing

Playwright includes a first-class API testing capability via `APIRequestContext`. You can use it alongside UI tests or write pure API tests.

## APIRequestContext

```typescript
import { test, expect } from '@playwright/test';

test('creates a product via API', async ({ request }) => {
  const response = await request.post('/api/products', {
    data: {
      name: 'Test Laptop',
      price: 999.99,
      category: 'Electronics',
    },
    headers: {
      'Authorization': `Bearer ${process.env.API_TOKEN}`,
      'Content-Type': 'application/json',
    },
  });

  expect(response.status()).toBe(201);
  const product = await response.json();
  expect(product).toMatchObject({
    name: 'Test Laptop',
    price: 999.99,
  });
  expect(product.id).toBeDefined();
});
```

## All HTTP Methods

```typescript
// GET
const response = await request.get('/api/users', {
  params: { page: 1, limit: 10 }, // Query parameters
});

// POST
const created = await request.post('/api/items', {
  data: { name: 'Widget' },
});

// PUT (full replacement)
const updated = await request.put(`/api/items/${id}`, {
  data: { name: 'Widget v2', price: 49.99 },
});

// PATCH (partial update)
const patched = await request.patch(`/api/items/${id}`, {
  data: { price: 39.99 },
});

// DELETE
const deleted = await request.delete(`/api/items/${id}`);
expect(deleted.status()).toBe(204);

// HEAD
const head = await request.head('/api/health');
expect(head.status()).toBe(200);

// Fetch (raw)
const fetched = await request.fetch('/api/upload', {
  method: 'POST',
  multipart: {
    file: {
      name: 'test.csv',
      mimeType: 'text/csv',
      buffer: Buffer.from('id,name\n1,Alice'),
    },
  },
});
```

## Response Validation

```typescript
test('validates product list response', async ({ request }) => {
  const response = await request.get('/api/products');

  // Status
  expect(response.ok()).toBeTruthy();
  expect(response.status()).toBe(200);

  // Headers
  expect(response.headers()['content-type']).toContain('application/json');

  // Body
  const body = await response.json();
  expect(body).toMatchObject({
    products: expect.arrayContaining([
      expect.objectContaining({
        id: expect.any(Number),
        name: expect.any(String),
        price: expect.any(Number),
      }),
    ]),
    total: expect.any(Number),
    page: 1,
  });

  // All products have required fields
  for (const product of body.products) {
    expect(product).toHaveProperty('id');
    expect(product).toHaveProperty('name');
    expect(product.price).toBeGreaterThan(0);
  }
});
```

## Standalone API Request Context

For API testing outside of the `request` fixture, or when you need different base URLs:

```typescript
import { request } from '@playwright/test';

// Create an isolated API context
const apiContext = await request.newContext({
  baseURL: 'https://api.staging.myapp.com',
  extraHTTPHeaders: {
    'Accept': 'application/json',
    'Authorization': `Bearer ${process.env.API_TOKEN}`,
  },
});

const products = await apiContext.get('/products');
await apiContext.dispose(); // Always clean up
```

## Contract Verification

```typescript
// Verify the API contract matches what the UI expects
test('product API matches UI schema', async ({ request }) => {
  const response = await request.get('/api/products/1');
  const product = await response.json();

  // Verify all fields the UI relies on exist
  expect(product).toMatchObject({
    id: expect.any(Number),
    name: expect.any(String),
    description: expect.any(String),
    price: expect.any(Number),
    imageUrl: expect.any(String),
    inStock: expect.any(Boolean),
    category: {
      id: expect.any(Number),
      name: expect.any(String),
    },
  });
});
```

## Combining API and UI Tests

This is one of Playwright's most powerful capabilities — use the API to set up state, then test the UI:

```typescript
test('displays newly created product', async ({ request, page }) => {
  // 1. Create product via API (fast, reliable setup)
  const createResponse = await request.post('/api/products', {
    data: { name: 'Test Product', price: 49.99, inStock: true },
  });
  const { id } = await createResponse.json();

  // 2. Verify it appears in the UI
  await page.goto('/products');
  await expect(page.getByRole('listitem').filter({ hasText: 'Test Product' }))
    .toBeVisible();

  // 3. Interact via UI
  await page.getByRole('link', { name: 'Test Product' }).click();
  await expect(page).toHaveURL(`/products/${id}`);

  // 4. Clean up via API
  await request.delete(`/api/products/${id}`);
});
```

---

# 15. Debugging

Playwright provides multiple complementary debugging approaches.

## Headed Mode

Run tests with a visible browser window:

```bash
# Run all tests with a visible browser
npx playwright test --headed

# Run a specific test headed
npx playwright test login.spec.ts --headed

# Slow down actions for visibility
npx playwright test --headed --slowmo=500
```

```typescript
// playwright.config.ts
use: {
  headless: false, // Always headed (not recommended for CI)
  slowMo: process.env.SLOWMO ? parseInt(process.env.SLOWMO) : 0,
},
```

## Playwright Inspector

The Inspector is a visual debugging tool — a pause/step debugger for your tests.

```bash
# Launch inspector on a specific test
PWDEBUG=1 npx playwright test login.spec.ts

# Or in your test:
await page.pause(); // Pauses execution and opens Inspector
```

The Inspector lets you:
- Step through test actions
- Inspect and highlight elements
- Generate locators by clicking on elements
- View page source and accessibility tree
- Monitor network requests

## Debug Mode in VSCode

Install the **Playwright Test for VSCode** extension. It adds:

- Test gutter icons to run/debug tests
- Test explorer panel
- Embedded trace viewer
- Inline locator suggestions

Set a breakpoint in your test file, then right-click → **Debug Test**.

## Tracing

```typescript
// playwright.config.ts — record traces on CI failures
use: {
  trace: 'on-first-retry', // Options: 'off' | 'on' | 'on-first-retry' | 'retain-on-failure'
},
```

```typescript
// Manual trace control in a test
test('complex flow', async ({ page, context }) => {
  await context.tracing.start({
    screenshots: true,
    snapshots: true,
    sources: true,
  });

  // ... test actions ...

  await context.tracing.stop({ path: 'trace.zip' });
});
```

View a trace:

```bash
npx playwright show-trace trace.zip
```

## Screenshots

```typescript
// Automatic on failure (playwright.config.ts)
use: {
  screenshot: 'only-on-failure', // 'off' | 'on' | 'only-on-failure'
},

// Manual screenshot
await page.screenshot({ path: 'screenshot.png', fullPage: true });

// Element screenshot
await page.getByRole('dialog').screenshot({ path: 'dialog.png' });
```

## Videos

```typescript
// playwright.config.ts
use: {
  video: 'on-first-retry', // 'off' | 'on' | 'on-first-retry' | 'retain-on-failure'
},
```

## Console Log Capture

```typescript
// Capture and assert on console output
const consoleLogs: string[] = [];
page.on('console', (msg) => consoleLogs.push(`[${msg.type()}] ${msg.text()}`));

await page.goto('/');
await page.getByRole('button', { name: 'Submit' }).click();

// Check for errors in console
const errors = consoleLogs.filter((log) => log.startsWith('[error]'));
expect(errors).toHaveLength(0);
```

## Network Debugging

```typescript
// Log all requests and responses
page.on('request', (req) => console.log(`→ ${req.method()} ${req.url()}`));
page.on('response', (res) => console.log(`← ${res.status()} ${res.url()}`));

// Log failed requests
page.on('requestfailed', (req) => {
  console.error(`FAILED: ${req.method()} ${req.url()} — ${req.failure()?.errorText}`);
});

// Enable verbose logging
process.env.DEBUG = 'pw:api';
```

## Debugging Workflow

When a test fails:

1. **Read the error message** — Playwright errors are descriptive (e.g., "Timeout 5000ms exceeded while waiting for element `locator('button')` to be visible").
2. **Check the screenshot/video** from `playwright-report/`.
3. **Open the trace** in Trace Viewer — pinpoint the exact action that failed.
4. **Run headed with PWDEBUG=1** to interactively debug.
5. **Add `page.pause()`** before the failing line and use the Inspector.
6. **Check network requests** — was the API returning an error?
7. **Add console listener** to capture browser errors.

```typescript
// Quick debugging template — add before a failing action
await page.evaluate(() => {
  const el = document.querySelector('#my-element');
  console.log('Element:', el?.outerHTML);
  console.log('Visibility:', el ? window.getComputedStyle(el).visibility : 'N/A');
});
await page.screenshot({ path: 'debug.png', fullPage: true });
await page.pause();
```

---

# 16. Trace Viewer

The Trace Viewer is Playwright's most powerful debugging tool. It records a complete timeline of your test execution — every action, screenshot, network request, console message, and DOM snapshot.

## Generating Traces

```typescript
// playwright.config.ts — recommended settings
use: {
  trace: 'on-first-retry',  // Most practical: trace when a test fails and retries
},

// Other options:
// 'off'                    — No traces (fastest)
// 'on'                     — Always trace (slow, many files)
// 'retain-on-failure'      — Trace all, delete on success (storage intensive)
// 'on-first-retry'         — Trace only on first retry of a failed test ← recommended
```

```typescript
// Programmatic trace in a test
test('critical user journey', async ({ page, context }) => {
  await context.tracing.start({
    screenshots: true,  // Include page screenshots in trace
    snapshots: true,    // Include DOM snapshots (enables element inspection)
    sources: true,      // Include test source code
  });

  try {
    await page.goto('/checkout');
    // ... multi-step test ...
  } finally {
    await context.tracing.stop({
      path: `traces/checkout-${Date.now()}.zip`,
    });
  }
});

// Add a checkpoint (named snapshot) mid-test
await context.tracing.startChunk({ title: 'After login' });
// ... more actions ...
await context.tracing.stopChunk({ path: 'traces/login-chunk.zip' });
```

## Viewing Traces

```bash
# Open a trace file
npx playwright show-trace playwright-report/data/trace.zip

# Or use the online viewer:
# https://trace.playwright.dev (upload the zip)
```

## Trace Viewer Interface

The Trace Viewer provides:

- **Timeline bar** — Horizontal scrubber showing each action's duration
- **Action list** — Every action (click, fill, goto, assertions) with timestamps
- **Screenshots** — Before/after screenshots for each action
- **DOM Snapshot** — Interactive snapshot of the page at each step (inspect elements, check computed styles)
- **Network tab** — All requests/responses, status codes, headers, bodies
- **Console tab** — All console messages and errors
- **Source tab** — Your test code with the current line highlighted

## Debugging Failures with Trace Viewer

Workflow for a CI failure:

1. Download the `playwright-report` artifact from CI.
2. Run `npx playwright show-trace playwright-report/data/trace.zip`.
3. Click on the failing action in the action list.
4. Check the "Before" screenshot — was the page in the expected state?
5. Check the DOM snapshot — was the element there? Was it visible? Enabled?
6. Check the Network tab — was an API call slow or failing?
7. Check the Console tab — were there JavaScript errors?

## Production Troubleshooting

For intermittent production issues that are hard to reproduce:

```typescript
// Capture traces for a subset of tests in CI with special conditions
use: {
  trace: process.env.TRACE_ALL ? 'on' : 'on-first-retry',
},
```

```bash
# Enable full tracing temporarily
TRACE_ALL=true npx playwright test --project=chromium
```

---

# 17. Visual Testing

Visual testing captures screenshots and compares them against approved baselines to detect unintended UI changes.

## Screenshot Testing

```typescript
// Full-page screenshot comparison
test('homepage matches snapshot', async ({ page }) => {
  await page.goto('/');
  await expect(page).toMatchAriaSnapshot(); // Accessibility snapshot (preferred)
  await expect(page).toHaveScreenshot('homepage.png');
});

// Element-level screenshot
test('product card matches snapshot', async ({ page }) => {
  await page.goto('/products/1');
  const card = page.getByRole('article', { name: 'Product Card' });
  await expect(card).toHaveScreenshot('product-card.png');
});
```

## Generating and Updating Baselines

```bash
# First run — generates baseline snapshots
npx playwright test --update-snapshots

# Subsequent runs — compares against baselines
npx playwright test

# Update only specific test
npx playwright test visual.spec.ts --update-snapshots
```

Baseline files are stored alongside your test files:

```
tests/
├── visual.spec.ts
└── visual.spec.ts-snapshots/
    ├── homepage-chromium-linux.png
    ├── homepage-firefox-linux.png
    └── homepage-webkit-linux.png
```

> **Important:** Snapshots are platform-specific (OS + browser). Baselines generated on macOS will not match CI Linux renders. Always generate baselines in the same environment where tests will run — typically in Docker/CI.

## Threshold Tuning

```typescript
// Allow a small percentage of pixel differences
await expect(page).toHaveScreenshot('dashboard.png', {
  maxDiffPixelRatio: 0.01, // Allow 1% pixel difference
});

// Or by absolute pixel count
await expect(page).toHaveScreenshot('chart.png', {
  maxDiffPixels: 50,
});

// Animation threshold
await expect(page).toHaveScreenshot('animated.png', {
  threshold: 0.2, // Per-pixel color difference threshold (0-1)
});
```

## Stability Considerations

Visual tests are inherently fragile. Follow these practices to keep them stable:

```typescript
// 1. Disable animations globally in tests
// In playwright.config.ts:
use: {
  // Add to your global CSS
  contextOptions: {
    reducedMotion: 'reduce',
  },
},

// 2. Mask dynamic content
await expect(page).toHaveScreenshot('dashboard.png', {
  mask: [
    page.getByTestId('current-time'),
    page.getByTestId('user-avatar'),
    page.getByRole('status', { name: 'Last updated' }),
  ],
});

// 3. Wait for all images to load before screenshotting
await page.waitForLoadState('load');
await page.evaluate(() =>
  Promise.all(
    [...document.images].map((img) =>
      img.complete ? Promise.resolve() : new Promise((r) => (img.onload = r))
    )
  )
);

// 4. Scope to a stable container — not the full page
const stableSection = page.getByRole('main');
await expect(stableSection).toHaveScreenshot('main-content.png');
```

## Visual Regression Testing Strategy

- **Scope visual tests narrowly** — screenshot components, not full pages.
- **Store baselines in version control** — treat them like test code.
- **Run visual tests in a separate project** (they're slower and more prone to false positives).
- **Review diffs as part of PRs** — visual changes should be intentional.
- **Integrate with tools like Percy or Chromatic** for diff management at scale.

```typescript
// playwright.config.ts — separate visual project
projects: [
  {
    name: 'visual',
    testMatch: '**/*.visual.spec.ts',
    use: { ...devices['Desktop Chrome'] },
  },
],
```

---

# 18. Accessibility Testing

Playwright provides first-class tooling for testing accessibility through the ARIA tree.

## ARIA Role Queries

Using `getByRole` is itself an accessibility test — it verifies that elements have correct semantic roles.

```typescript
// These locators only succeed if the markup is semantically correct
await page.getByRole('navigation', { name: 'Primary' }); // Needs <nav aria-label="Primary">
await page.getByRole('banner');   // Needs <header>
await page.getByRole('main');     // Needs <main>
await page.getByRole('region', { name: 'Related Products' }); // Needs <section aria-label="...">
```

## Accessibility Snapshots

Playwright's `toMatchAriaSnapshot` captures the ARIA tree structure and lets you assert on it.

```typescript
// Capture and assert the ARIA tree
await expect(page.getByRole('navigation')).toMatchAriaSnapshot(`
  - navigation "Primary":
    - list:
      - listitem:
        - link "Home" [current=page]
      - listitem:
        - link "Products"
      - listitem:
        - link "Contact"
`);

// Generate the snapshot first (then commit it)
// npx playwright test --update-snapshots

// Heading structure
await expect(page).toMatchAriaSnapshot(`
  - heading "Product Catalog" [level=1]
  - heading "Electronics" [level=2]
  - heading "Laptops" [level=3]
`);
```

## Accessibility Assertions

```typescript
// Focus management
await page.getByRole('button', { name: 'Open Dialog' }).click();
await expect(page.getByRole('dialog')).toBeFocused(); // Dialog should receive focus

// Keyboard navigation
await page.keyboard.press('Tab');
await expect(page.getByRole('link', { name: 'Skip to content' })).toBeFocused();

// ARIA attributes
await expect(page.getByRole('button', { name: 'Menu' }))
  .toHaveAttribute('aria-expanded', 'false');

await page.getByRole('button', { name: 'Menu' }).click();
await expect(page.getByRole('button', { name: 'Menu' }))
  .toHaveAttribute('aria-expanded', 'true');

// Live region
await page.getByRole('button', { name: 'Save' }).click();
await expect(page.getByRole('status')).toContainText('Changes saved');
// role="status" is a live region — screen readers announce its content

// Alert
await expect(page.getByRole('alert')).toContainText('Error: Required field missing');
```

## Keyboard Navigation Testing

```typescript
test('modal is keyboard accessible', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: 'Open Modal' }).click();
  const modal = page.getByRole('dialog');

  // Focus should move into modal
  await expect(modal).toBeVisible();

  // Tab through all focusable elements
  await page.keyboard.press('Tab');
  await expect(modal.getByRole('button', { name: 'Cancel' })).toBeFocused();

  await page.keyboard.press('Tab');
  await expect(modal.getByRole('button', { name: 'Confirm' })).toBeFocused();

  // Escape closes modal
  await page.keyboard.press('Escape');
  await expect(modal).toBeHidden();

  // Focus returns to trigger button
  await expect(page.getByRole('button', { name: 'Open Modal' })).toBeFocused();
});
```

## Color Contrast and WCAG

Playwright doesn't natively check color contrast ratios. For comprehensive WCAG testing, combine Playwright with `axe-core`:

```typescript
// Install: npm install -D @axe-core/playwright
import { checkA11y } from 'axe-playwright';

test('homepage passes accessibility audit', async ({ page }) => {
  await page.goto('/');
  await checkA11y(page, undefined, {
    detailedReport: true,
    detailedReportOptions: { html: true },
    // Customize rules
    axeOptions: {
      rules: {
        'color-contrast': { enabled: true },
        'keyboard-navigation': { enabled: true },
      },
    },
  });
});
```

## Accessibility Testing Philosophy

- **Use role-based locators everywhere** — they are the first accessibility test.
- **Test keyboard navigation** for all interactive components.
- **Test focus management** — where does focus go after a modal opens/closes?
- **Test ARIA attribute changes** — `aria-expanded`, `aria-selected`, `aria-current`.
- **Test live regions** — `role="status"`, `role="alert"` announce changes to screen readers.
- **Complement with axe-core** for WCAG rule verification.

---

# 19. Multi-Browser Testing

## Running Tests Across Browsers

```typescript
// playwright.config.ts
projects: [
  { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
  { name: 'webkit', use: { ...devices['Desktop Safari'] } },
],
```

```bash
# Run only one browser
npx playwright test --project=chromium

# Run two browsers
npx playwright test --project=chromium --project=firefox

# Run all configured browsers
npx playwright test
```

## Browser-Conditional Logic

```typescript
// Skip a test on a specific browser
test.skip(({ browserName }) => browserName === 'webkit', 'Safari has known issue with X');

// Conditional assertion by browser
test('input type=date', async ({ page, browserName }) => {
  await page.goto('/form');

  if (browserName === 'webkit') {
    // Safari renders date inputs differently
    await page.getByLabel('Date').fill('2024-01-15');
  } else {
    await page.getByLabel('Date').fill('2024-01-15');
  }

  await expect(page.getByLabel('Date')).toHaveValue('2024-01-15');
});

// Use browserName in fixtures
export const test = baseTest.extend({
  page: async ({ page, browserName }, use) => {
    if (browserName === 'chromium') {
      await page.addInitScript(() => {
        // Chromium-specific setup
      });
    }
    await use(page);
  },
});
```

## Browser Differences and Compatibility Strategies

| Feature | Chromium | Firefox | WebKit |
|---|---|---|---|
| CSS Grid | Full | Full | Full |
| CSS `has()` | Full | Full | Partial (older) |
| `FileSystemAPI` | Full | Partial | No |
| `SharedArrayBuffer` | With COEP | With COEP | With COEP |
| `date` input | Custom UI | Custom UI | Native-ish |
| `dialog` element | Full | Full | Partial |
| Web Animations | Full | Full | Partial |

**Strategy for handling browser differences:**

1. **Prefer role/label/text locators** — they're browser-agnostic.
2. **Use `test.skip` with a clear reason** for known browser-specific bugs.
3. **File issues** when browser behavior diverges unexpectedly.
4. **Test critical paths on all three** — only skip when browsers truly can't support a feature.
5. **WebKit is not Safari** — it catches Safari-class bugs but isn't a substitute for real device testing.

## Using System Browsers (Chrome, Edge)

```typescript
// playwright.config.ts
projects: [
  {
    name: 'Google Chrome',
    use: {
      channel: 'chrome', // Use system-installed Chrome
      ...devices['Desktop Chrome'],
    },
  },
  {
    name: 'Microsoft Edge',
    use: {
      channel: 'msedge',
      ...devices['Desktop Chrome'],
    },
  },
],
```

> **When to use system browsers:** When you need to test browser extensions, or test behavior specific to branded Chrome/Edge (rather than open-source Chromium).

---

# 20. Mobile Testing

## Device Emulation

```typescript
import { devices } from '@playwright/test';

// playwright.config.ts
projects: [
  {
    name: 'mobile-chrome',
    use: { ...devices['Pixel 5'] },
  },
  {
    name: 'mobile-safari',
    use: { ...devices['iPhone 14'] },
  },
  {
    name: 'tablet',
    use: { ...devices['iPad Pro 11'] },
  },
],
```

`devices` objects include pre-configured:
- Viewport dimensions
- User agent string
- Device scale factor
- Mobile flag (`isMobile: true`)
- Touch support
- Default browser (Chromium for Android devices, WebKit for iOS)

## Available Devices

```typescript
// View all available device descriptors
import { devices } from '@playwright/test';
console.log(Object.keys(devices));

// Common options:
// 'Pixel 5', 'Pixel 7', 'Pixel 8 Pro'
// 'iPhone 12', 'iPhone 13', 'iPhone 14', 'iPhone 15'
// 'iPad Pro 11', 'iPad Mini'
// 'Galaxy S8', 'Galaxy Tab S4'
// 'Nexus 10'
```

## Custom Viewport and Device Configuration

```typescript
// Custom device configuration
test.use({
  viewport: { width: 390, height: 844 },
  userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X)',
  deviceScaleFactor: 3,
  isMobile: true,
  hasTouch: true,
});
```

## Touch Interactions

```typescript
// Tap (preferred over click on mobile)
await page.getByRole('button', { name: 'Add to Cart' }).tap();

// Swipe
await page.touchscreen.tap(200, 400);

// Multi-touch pinch (zoom)
// Use page.evaluate to simulate with touch events
await page.evaluate(() => {
  const target = document.getElementById('map');
  // Dispatch custom touch events
});

// Swipe by dragging
await page.getByTestId('carousel').dragTo(
  page.getByTestId('carousel'), // Same element, different position
  { sourcePosition: { x: 300, y: 200 }, targetPosition: { x: 50, y: 200 } }
);
```

## Responsive Testing

```typescript
// Test breakpoints
const breakpoints = [
  { name: 'mobile', width: 375, height: 812 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'desktop', width: 1440, height: 900 },
];

for (const bp of breakpoints) {
  test(`navigation at ${bp.name}`, async ({ page }) => {
    await page.setViewportSize({ width: bp.width, height: bp.height });
    await page.goto('/');

    if (bp.width < 768) {
      // Mobile: hamburger menu visible
      await expect(page.getByRole('button', { name: 'Menu' })).toBeVisible();
      await expect(page.getByRole('navigation')).toBeHidden();
    } else {
      // Desktop: full nav visible
      await expect(page.getByRole('navigation')).toBeVisible();
      await expect(page.getByRole('button', { name: 'Menu' })).toBeHidden();
    }
  });
}
```

---

# 21. CI/CD Integration

## GitHub Actions

```yaml
# .github/workflows/playwright.yml
name: Playwright Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Playwright Tests
    runs-on: ubuntu-latest
    timeout-minutes: 60

    strategy:
      fail-fast: false
      matrix:
        shard: [1, 2, 3, 4] # Run 4 shards in parallel

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps chromium

      - name: Run Playwright tests (shard ${{ matrix.shard }}/4)
        run: npx playwright test --shard=${{ matrix.shard }}/4
        env:
          BASE_URL: ${{ secrets.STAGING_URL }}
          TEST_USER_EMAIL: ${{ secrets.TEST_USER_EMAIL }}
          TEST_USER_PASSWORD: ${{ secrets.TEST_USER_PASSWORD }}
          CI: true

      - name: Upload blob report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: blob-report-${{ matrix.shard }}
          path: blob-report/
          retention-days: 7

  merge-reports:
    name: Merge Reports
    if: always()
    needs: [test]
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci

      - name: Download all blob reports
        uses: actions/download-artifact@v4
        with:
          path: all-blob-reports
          pattern: blob-report-*
          merge-multiple: true

      - name: Merge reports
        run: npx playwright merge-reports --reporter html ./all-blob-reports

      - name: Upload HTML report
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```

## GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - test
  - report

variables:
  BASE_URL: "https://staging.myapp.com"

.playwright_base:
  image: mcr.microsoft.com/playwright:v1.45.0-jammy
  before_script:
    - npm ci
  artifacts:
    when: always
    paths:
      - blob-report/
      - playwright-report/
    expire_in: 7 days

playwright-shard-1:
  extends: .playwright_base
  stage: test
  script:
    - npx playwright test --shard=1/3
  parallel:
    matrix:
      - SHARD: ["1/3", "2/3", "3/3"]
  script:
    - npx playwright test --shard=$SHARD

merge-reports:
  stage: report
  extends: .playwright_base
  needs: ["playwright-shard-1"]
  script:
    - npx playwright merge-reports --reporter html ./blob-report
  artifacts:
    paths:
      - playwright-report/
```

## Docker

```dockerfile
# Dockerfile.playwright
# Use Microsoft's official Playwright image (includes all browsers + deps)
FROM mcr.microsoft.com/playwright:v1.45.0-jammy

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy test files
COPY . .

# Default command
CMD ["npx", "playwright", "test"]
```

```bash
# Build and run tests in Docker
docker build -f Dockerfile.playwright -t playwright-tests .
docker run --rm \
  -e BASE_URL=https://staging.myapp.com \
  -e CI=true \
  -v $(pwd)/playwright-report:/app/playwright-report \
  playwright-tests
```

```yaml
# docker-compose.playwright.yml
version: '3.8'

services:
  playwright:
    build:
      context: .
      dockerfile: Dockerfile.playwright
    environment:
      - BASE_URL=http://app:3000
      - CI=true
    volumes:
      - ./playwright-report:/app/playwright-report
    depends_on:
      app:
        condition: service_healthy

  app:
    image: my-app:latest
    ports:
      - "3000:3000"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 5s
      timeout: 3s
      retries: 10
```

## CI Best Practices

```typescript
// playwright.config.ts — production CI config
export default defineConfig({
  // Strict settings for CI
  forbidOnly: !!process.env.CI,        // No test.only in CI
  retries: process.env.CI ? 2 : 0,    // Retry on CI only
  workers: process.env.CI ? 4 : undefined,

  reporter: [
    ['blob'],                           // For shard merging
    ['github'],                         // GitHub annotations
    ['html', { open: 'never' }],        // HTML report
  ],

  use: {
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on-first-retry',
    // Shorter timeouts in CI — long timeouts mask slow tests
    actionTimeout: 10_000,
    navigationTimeout: 30_000,
  },
});
```

---

# 22. Performance and Reliability

## Flaky Test Prevention

Flaky tests (tests that sometimes pass and sometimes fail without code changes) are the most damaging artifact in a test suite. They erode trust and slow down development.

**The root causes of flakiness, in order of frequency:**

```typescript
// 1. Race conditions — page not ready for action
// ❌ Flaky: assumes page is ready
await page.click('#button');

// ✅ Reliable: action auto-waits
await page.getByRole('button', { name: 'Submit' }).click();

// 2. Shared state between tests
// ❌ Flaky: depends on previous test creating a product
test('edits the first product', async ({ page }) => {
  await page.goto('/products');
  // Breaks if no products exist
});

// ✅ Reliable: creates its own data
test('edits a product', async ({ request, page }) => {
  const { id } = await createProduct(request, { name: 'Test' });
  await page.goto(`/products/${id}/edit`);
});

// 3. Time-dependent tests
// ❌ Flaky
test('shows recent orders', async ({ page }) => {
  const today = new Date().toLocaleDateString(); // Fails at midnight
  await expect(page.getByText(today)).toBeVisible();
});

// ✅ Reliable: mock or control the date
await page.addInitScript(() => {
  const fixedDate = new Date('2024-06-15');
  Date = class extends Date {
    constructor(...args: any[]) {
      if (args.length === 0) super(fixedDate);
      else super(...args);
    }
    static now() { return fixedDate.getTime(); }
  };
});

// 4. Animation timing
// ❌ Flaky: screenshot during animation
await page.goto('/');
await expect(page).toHaveScreenshot();

// ✅ Reliable: wait for animation to complete
await page.goto('/');
await page.waitForFunction(() =>
  document.querySelectorAll('[data-animating]').length === 0
);
await expect(page).toHaveScreenshot();
```

## Deterministic Testing Patterns

```typescript
// Freeze time
await page.addInitScript(() => {
  const now = new Date('2024-01-15T10:00:00Z').getTime();
  globalThis.Date = class extends Date {
    constructor(...a: any[]) { super(...(a.length ? a : [now])); }
    static now() { return now; }
  };
});

// Control random values
await page.addInitScript(() => {
  Math.random = () => 0.5; // Always returns 0.5
});

// Disable CSS animations
await page.addStyleTag({
  content: `
    *, *::before, *::after {
      animation-duration: 0s !important;
      animation-delay: 0s !important;
      transition-duration: 0s !important;
      transition-delay: 0s !important;
    }
  `,
});
```

## Test Isolation

```typescript
// ✅ Each test creates its own data
test.beforeEach(async ({ request }, testInfo) => {
  // Use unique identifiers to avoid data collision
  const unique = `test-${testInfo.testId}-${Date.now()}`;
  testInfo.annotations.push({ type: 'unique-id', description: unique });
});

// ✅ Clean up after each test
test.afterEach(async ({ request }, testInfo) => {
  // Clean up resources created in this test
  const ids = testInfo.annotations
    .filter((a) => a.type === 'created-item')
    .map((a) => a.description);

  for (const id of ids) {
    await request.delete(`/api/items/${id}`).catch(() => {});
  }
});
```

## Parallelization Strategies

```typescript
// Strategy 1: File-level parallelism (default)
// Each file runs in its own worker; tests within a file are sequential

// Strategy 2: Full parallelism — use when tests are fully independent
// playwright.config.ts
fullyParallel: true,

// Strategy 3: Serial groups — use for dependent tests
test.describe.configure({ mode: 'serial' });
test.describe('wizard flow', () => {
  test('step 1', async ({ page }) => { /* ... */ });
  test('step 2', async ({ page }) => { /* ... */ }); // Runs after step 1
  test('step 3', async ({ page }) => { /* ... */ }); // Runs after step 2
});

// Strategy 4: Worker-scoped fixtures for expensive shared setup
// (see Section 11)
```

## Runtime Optimization

```typescript
// 1. Skip redundant navigation
// ❌ Slow: navigates before every test even if already there
test.beforeEach(async ({ page }) => {
  await page.goto('/products'); // 300ms per test
});

// ✅ Fast: navigate once per worker for read-only pages
// Use worker-scoped fixture + serial mode for read-heavy test groups

// 2. Authenticate via API, not UI
// Login UI: ~1–2 seconds per setup
// Login API + storageState: ~100–200ms per setup (and only once per project)

// 3. Use route mocking for external dependencies
// External API: variable latency (50–500ms+)
// Mocked route: ~1ms
await page.route('/api/third-party/**', (route) =>
  route.fulfill({ status: 200, body: JSON.stringify(mockData) })
);

// 4. Scope assertions precisely
// ❌ Slow: asserts on full page
await expect(page).toHaveScreenshot();

// ✅ Fast: asserts on specific component
await expect(page.getByRole('main')).toHaveScreenshot();

// 5. Use expect.poll for custom async conditions
await expect.poll(() => getQueueLength(), {
  intervals: [500, 1000, 2000],
  timeout: 15_000,
}).toBe(0);
```

---

# 23. Advanced Topics

## Multiple Tabs

```typescript
test('opens product in new tab', async ({ page, context }) => {
  await page.goto('/products');

  // Listen for the new page before triggering the action
  const newTabPromise = context.waitForEvent('page');
  await page.getByRole('link', { name: 'Open in new tab' }).click();
  const newTab = await newTabPromise;

  await newTab.waitForLoadState();
  await expect(newTab).toHaveURL(/\/products\/\d+/);
  await expect(newTab.getByRole('heading', { level: 1 })).toBeVisible();
});

// Get all open pages
const pages = context.pages();
```

## Popups and Dialogs

```typescript
// Browser dialogs (alert, confirm, prompt)
page.on('dialog', async (dialog) => {
  console.log('Dialog message:', dialog.message());
  await dialog.accept();         // Click OK / confirm
  // await dialog.dismiss();     // Click Cancel
  // await dialog.accept('text'); // For prompt dialogs
});

await page.getByRole('button', { name: 'Delete' }).click();
// Dialog is handled automatically by the listener

// Expect a specific dialog message
const dialogPromise = new Promise<string>((resolve) => {
  page.once('dialog', async (dialog) => {
    resolve(dialog.message());
    await dialog.accept();
  });
});
await page.getByRole('button', { name: 'Delete' }).click();
expect(await dialogPromise).toBe('Are you sure you want to delete?');
```

## File Downloads

```typescript
// Wait for download to complete
const downloadPromise = page.waitForEvent('download');
await page.getByRole('button', { name: 'Export CSV' }).click();
const download = await downloadPromise;

// Get the path of the downloaded file
const path = await download.path();
const fileName = download.suggestedFilename();
console.log(`Downloaded: ${fileName} to ${path}`);

// Save to a specific path
await download.saveAs('./downloads/export.csv');

// Read and verify the content
import { readFileSync } from 'fs';
const content = readFileSync(await download.path()!, 'utf-8');
expect(content).toContain('id,name,price');
```

## File Uploads

```typescript
// Standard file input
await page.getByLabel('Upload file').setInputFiles('./test-data/document.pdf');

// Drag-and-drop file upload
const dataTransfer = await page.evaluateHandle(() => new DataTransfer());
await page.dispatchEvent('#dropzone', 'drop', { dataTransfer });

// Upload generated buffer (no real file needed)
await page.getByLabel('Upload').setInputFiles({
  name: 'report.json',
  mimeType: 'application/json',
  buffer: Buffer.from(JSON.stringify({ data: 'test' })),
});
```

## iframes

```typescript
// frameLocator — participates in auto-waiting (preferred)
const stripe = page.frameLocator('iframe[name="stripe"]');
await stripe.getByRole('textbox', { name: 'Card number' }).fill('4242424242424242');
await stripe.getByRole('textbox', { name: 'Expiry' }).fill('12/34');
await stripe.getByRole('textbox', { name: 'CVC' }).fill('123');

// Chain from a parent locator
const paymentSection = page.getByRole('region', { name: 'Payment' });
await paymentSection.frameLocator('iframe').getByLabel('Card number').fill('4242...');

// frame() for imperative use (older API)
const frame = page.frame({ url: /stripe\.com/ });
if (frame) {
  await frame.fill('#card-number', '4242424242424242');
}
```

## Shadow DOM

```typescript
// Playwright's locators pierce Shadow DOM automatically
// No special syntax needed for most cases
await page.getByRole('button', { name: 'Submit' }).click();
// Works even if the button is inside a web component's shadow root

// Explicit pierce selector (when needed)
const input = page.locator('my-input >> input');
await input.fill('value');

// Complex shadow DOM traversal
const shadowHost = page.locator('my-component');
const shadowButton = shadowHost.locator('button');
await shadowButton.click();
```

## Service Workers

```typescript
// Listen for service worker registration
const workerPromise = page.waitForEvent('serviceworker');
await page.goto('/');
const worker = await workerPromise;
console.log('Service worker URL:', worker.url());

// Intercept requests handled by service worker
// Note: page.route intercepts before the service worker
await page.route('/api/**', async (route) => {
  // This intercepts even requests the SW would have cached
  await route.continue();
});

// Bypass service worker for clean state
await context.setServiceWorkerPolicy('block'); // Prevent SW registration
```

## WebSockets

```typescript
// Intercept WebSocket connections
const wsPromise = page.waitForEvent('websocket');
await page.goto('/realtime');
const ws = await wsPromise;

console.log('WebSocket URL:', ws.url());

// Listen for messages sent by the server
ws.on('framereceived', (frame) => {
  console.log('Received:', frame.payload);
});

// Listen for messages sent by the client
ws.on('framesent', (frame) => {
  console.log('Sent:', frame.payload);
});

// Wait for a specific message
const messagePromise = ws.waitForEvent('framereceived', {
  predicate: (frame) => {
    const data = JSON.parse(frame.payload.toString());
    return data.type === 'order_update';
  },
});

await page.getByRole('button', { name: 'Place Order' }).click();
const message = await messagePromise;
expect(JSON.parse(message.payload.toString())).toMatchObject({
  type: 'order_update',
  status: 'processing',
});
```

## Geolocation

```typescript
// Set geolocation at context level
const context = await browser.newContext({
  geolocation: { latitude: 14.5995, longitude: 120.9842 }, // Manila
  permissions: ['geolocation'],
});

// Or override per-test
await context.setGeolocation({ latitude: 51.5074, longitude: -0.1278 }); // London

// Test location-based features
const page = await context.newPage();
await page.goto('/nearby-stores');
await expect(page.getByRole('listitem').first()).toContainText('London');
```

## Permissions

```typescript
// Grant permissions at context creation
const context = await browser.newContext({
  permissions: ['geolocation', 'notifications', 'camera', 'microphone'],
});

// Grant permissions after context creation
await context.grantPermissions(['clipboard-read', 'clipboard-write']);

// Clear permissions
await context.clearPermissions();

// Deny permissions (use a new context without granting them)
// Then test that your app handles the denial gracefully
test('handles geolocation denial', async ({ page }) => {
  // context has no geolocation permission
  await page.goto('/location-required');
  await expect(page.getByRole('alert')).toContainText('Location access denied');
});
```

## Browser Contexts — Advanced Usage

```typescript
// Multiple contexts in one test (multiple users)
test('two users chat in real time', async ({ browser }) => {
  const aliceContext = await browser.newContext({
    storageState: '.auth/alice.json',
  });
  const bobContext = await browser.newContext({
    storageState: '.auth/bob.json',
  });

  const alicePage = await aliceContext.newPage();
  const bobPage = await bobContext.newPage();

  await alicePage.goto('/chat/room-1');
  await bobPage.goto('/chat/room-1');

  // Alice sends a message
  await alicePage.getByRole('textbox', { name: 'Message' }).fill('Hello Bob!');
  await alicePage.keyboard.press('Enter');

  // Bob receives it
  await expect(bobPage.getByText('Hello Bob!')).toBeVisible();

  await aliceContext.close();
  await bobContext.close();
});
```

## Storage Management

```typescript
// Read localStorage
const token = await page.evaluate(() => localStorage.getItem('auth_token'));

// Write localStorage
await page.evaluate(() => {
  localStorage.setItem('feature_flags', JSON.stringify({ darkMode: true }));
});

// Clear all storage
await context.clearCookies();
await page.evaluate(() => {
  localStorage.clear();
  sessionStorage.clear();
});

// Read cookies
const cookies = await context.cookies();
const sessionCookie = cookies.find((c) => c.name === 'session');

// Set cookies
await context.addCookies([{
  name: 'session',
  value: 'abc123',
  domain: 'localhost',
  path: '/',
  httpOnly: true,
  secure: false,
  sameSite: 'Lax',
}]);
```

---

# 24. Real-World Architecture

## Recommended Enterprise Directory Structure

```
my-app-e2e/
├── playwright.config.ts
├── package.json
├── tsconfig.json
│
├── tests/                          # Test files only — no helpers here
│   ├── auth/
│   │   ├── auth.setup.ts           # Authentication setup
│   │   ├── login.spec.ts
│   │   └── register.spec.ts
│   ├── products/
│   │   ├── listing.spec.ts
│   │   ├── detail.spec.ts
│   │   └── search.spec.ts
│   ├── checkout/
│   │   ├── cart.spec.ts
│   │   └── payment.spec.ts
│   ├── admin/
│   │   └── user-management.spec.ts
│   └── api/
│       ├── products.api.spec.ts
│       └── orders.api.spec.ts
│
├── pages/                          # Page Object Models
│   ├── BasePage.ts
│   ├── auth/
│   │   ├── LoginPage.ts
│   │   └── RegisterPage.ts
│   ├── products/
│   │   ├── ProductListPage.ts
│   │   └── ProductDetailPage.ts
│   └── checkout/
│       ├── CartPage.ts
│       └── CheckoutPage.ts
│
├── components/                     # Reusable UI component objects
│   ├── DataTable.ts
│   ├── Modal.ts
│   ├── Toast.ts
│   ├── Pagination.ts
│   └── NavigationMenu.ts
│
├── fixtures/                       # Custom Playwright fixtures
│   ├── index.ts                    # Re-exports combined test object
│   ├── pages.fixture.ts            # Page object fixtures
│   ├── auth.fixture.ts             # Auth-related fixtures
│   └── api.fixture.ts              # API client fixtures
│
├── utils/                          # Utilities and helpers
│   ├── api-client.ts               # Typed API wrapper for setup/teardown
│   ├── dates.ts                    # Date manipulation helpers
│   ├── faker.ts                    # Test data generation
│   └── assertions.ts               # Custom assertion helpers
│
├── test-data/                      # Static test data
│   ├── products.json
│   ├── users.json
│   └── payment-methods.json
│
├── .auth/                          # Saved auth states (gitignored)
│   ├── admin.json
│   ├── user.json
│   └── viewer.json
│
├── playwright-report/              # Generated (gitignored)
└── blob-report/                    # Generated (gitignored)
```

## Directory Responsibilities

### `tests/`

Contains only test files (`.spec.ts`). No helpers, no utilities. Tests import from `fixtures/`, `pages/`, and `utils/`. Organized by feature domain.

**Rule:** A test file should read like a specification. If you can't understand what a test does from reading it, the abstraction level is wrong.

### `pages/`

Page Object Models. Each file maps to a page or major section of the application. Methods represent user intentions ("login", "addToCart"), not UI mechanics ("clickSubmitButton").

```typescript
// pages/checkout/CartPage.ts
export class CartPage extends BasePage {
  constructor(page: Page) {
    super(page);
  }

  async goto() {
    await this.page.goto('/cart');
    await this.waitForPageReady();
  }

  async addCoupon(code: string) {
    await this.page.getByLabel('Coupon code').fill(code);
    await this.page.getByRole('button', { name: 'Apply' }).click();
    await expect(this.page.getByRole('status')).toContainText('Coupon applied');
  }

  async getTotal(): Promise<number> {
    const text = await this.page.getByTestId('order-total').textContent();
    return parseFloat(text?.replace(/[^0-9.]/g, '') ?? '0');
  }

  async checkout() {
    await this.page.getByRole('button', { name: 'Proceed to Checkout' }).click();
    await this.page.waitForURL('/checkout');
  }
}
```

### `components/`

Reusable UI component objects that represent recurring UI patterns across multiple pages.

```typescript
// components/Toast.ts
export class Toast {
  constructor(private locator: Locator) {}

  async expectSuccess(message: string) {
    await expect(this.locator.getByRole('status')).toContainText(message);
  }

  async expectError(message: string) {
    await expect(this.locator.getByRole('alert')).toContainText(message);
  }

  async dismiss() {
    await this.locator.getByRole('button', { name: 'Dismiss' }).click();
    await expect(this.locator).toBeHidden();
  }
}
```

### `fixtures/`

All custom Playwright fixtures. The `index.ts` file assembles all fixtures into a single `test` export that tests use instead of importing from `@playwright/test` directly.

```typescript
// fixtures/index.ts
import { mergeTests } from '@playwright/test';
import { pageFixtures } from './pages.fixture';
import { authFixtures } from './auth.fixture';
import { apiFixtures } from './api.fixture';

export const test = mergeTests(pageFixtures, authFixtures, apiFixtures);
export { expect } from '@playwright/test';
```

### `utils/`

Pure utility functions — no Playwright imports. Data factories, date helpers, string formatters, custom matchers.

```typescript
// utils/faker.ts
import { faker } from '@faker-js/faker';

export const createUser = (overrides = {}) => ({
  email: faker.internet.email(),
  password: faker.internet.password({ length: 12, memorable: true }),
  firstName: faker.person.firstName(),
  lastName: faker.person.lastName(),
  ...overrides,
});

export const createProduct = (overrides = {}) => ({
  name: faker.commerce.productName(),
  price: parseFloat(faker.commerce.price({ min: 10, max: 500 })),
  description: faker.commerce.productDescription(),
  category: faker.commerce.department(),
  ...overrides,
});
```

### `test-data/`

Static JSON files for fixtures that don't need to be generated dynamically. Valid payment methods, country lists, product catalogs, etc.

### `.auth/`

Serialized `storageState` files from authentication setup. Must be gitignored — they may contain sensitive session tokens.

---

# 25. Best Practices

## Maintainability

- ✅ Use role-based and label-based locators; avoid CSS paths and XPath.
- ✅ Encapsulate UI interactions in Page Objects; keep tests at the intention level.
- ✅ Use custom fixtures for shared setup and teardown; avoid `beforeEach` for complex logic.
- ✅ Name tests as user stories: "user can place an order with a saved card".
- ✅ One logical assertion per test where possible; use soft assertions for multi-check tests.
- ✅ Extract shared test data into `test-data/` or factory functions in `utils/`.
- ✅ Document *why* non-obvious patterns exist, not just *what* they do.

## Scalability

- ✅ Use projects to separate concerns: setup, authenticated, unauthenticated, visual, mobile.
- ✅ Keep test files under 300 lines; split large files by sub-feature.
- ✅ Use sharding in CI to parallelize across machines without paid infrastructure.
- ✅ Maintain a test tag taxonomy (`@smoke`, `@regression`, `@visual`) and run subsets in CI pipelines.
- ✅ Design fixtures with reuse in mind; worker-scoped fixtures for expensive operations.
- ✅ Separate fast smoke tests (< 2 minutes) from full regression (10+ minutes).

## Reliability

- ✅ Never use `waitForTimeout` (hard waits); replace with assertions or `waitForResponse`.
- ✅ Create test-specific data; never rely on shared or pre-existing state.
- ✅ Clean up created data after tests in `afterEach` or teardown fixtures.
- ✅ Mock third-party services and unpredictable external APIs.
- ✅ Disable CSS animations in test environments to prevent screenshot flakiness.
- ✅ Use `Promise.all` when simultaneously triggering and waiting for an event.
- ✅ Set `retries: 2` in CI; treat a test that always needs retries as broken.

## Performance

- ✅ Authenticate once per role per project via `storageState`; never log in per test.
- ✅ Use API calls for test data setup/teardown — it's 10–100× faster than UI.
- ✅ Mock slow or unreliable third-party APIs with `page.route`.
- ✅ Use `fullyParallel: true` and sharding to maximize CI throughput.
- ✅ Scope `toHaveScreenshot` to specific components, not full pages.
- ✅ Use `waitForURL` after navigation instead of `waitForLoadState('networkidle')`.

## Readability

- ✅ Tests should read like user stories without needing to understand Playwright internals.
- ✅ Method names in Page Objects should be user-action verbs: `login()`, `addToCart()`, `checkout()`.
- ✅ Use `test.step()` to group and label phases of complex tests.
- ✅ Add custom error messages to assertions: `await expect(locator, 'message').toBeVisible()`.
- ✅ Avoid magic strings; define constants for repeated values.

```typescript
// Readable test example
test('returning customer completes checkout with saved address', async ({
  authenticatedPage,
  cartPage,
  checkoutPage,
}) => {
  await test.step('Add item to cart', async () => {
    await authenticatedPage.goto('/products/laptop-pro');
    await authenticatedPage.getByRole('button', { name: 'Add to Cart' }).click();
    await expect(authenticatedPage.toast).toContainText('Added to cart');
  });

  await test.step('Proceed to checkout', async () => {
    await cartPage.goto();
    await cartPage.checkout();
  });

  await test.step('Select saved address', async () => {
    await checkoutPage.selectSavedAddress('123 Main St');
    await checkoutPage.placeOrder();
  });

  await test.step('Confirm order created', async () => {
    await expect(authenticatedPage).toHaveURL(/\/orders\/\d+/);
    await expect(authenticatedPage.getByRole('heading')).toContainText('Order Confirmed');
  });
});
```

## Debugging

- ✅ Set `trace: 'on-first-retry'` in CI — you always want traces for CI failures.
- ✅ Set `screenshot: 'only-on-failure'` and `video: 'on-first-retry'`.
- ✅ Add `page.pause()` during local development to drop into the Inspector.
- ✅ Use `PWDEBUG=1` to start with the Inspector automatically.
- ✅ Log network requests in `beforeEach` when debugging network-related failures.
- ✅ Add `console` listener during debugging to catch browser-side errors.

## CI Execution

- ✅ Use `forbidOnly: !!process.env.CI` to prevent committing `test.only`.
- ✅ Set `retries: 2` in CI; do not retry locally (hide real failures).
- ✅ Use `--with-deps` when installing browsers in CI to get OS-level dependencies.
- ✅ Cache `~/.cache/ms-playwright` in CI to speed up browser installs.
- ✅ Use sharding for large suites (> 5 minutes) to maintain fast feedback loops.
- ✅ Upload blob reports as artifacts from each shard; merge in a separate job.
- ✅ Set a global `timeout` that is generous but not infinite — 60 seconds per test is appropriate for most apps.

---

# 26. Anti-Patterns

## 1. Hard-Coded Sleeps

```typescript
// ❌ Anti-pattern — hard sleep
await page.waitForTimeout(3000);

// Why it's bad:
// - Slows tests by a fixed amount regardless of actual readiness
// - Still flaky if the page takes longer than 3 seconds
// - Accumulates: 10 tests × 3s = 30 seconds wasted per run

// ✅ Fix: Assert on the condition you were waiting for
await expect(page.getByRole('status')).toHaveText('Saved!');
await expect(page.getByRole('progressbar')).toBeHidden();
await page.waitForURL('/success');
```

## 2. Brittle CSS Selectors

```typescript
// ❌ Anti-pattern — fragile selectors
await page.locator('.sc-fzqARb.fBTnLt button:nth-child(2)').click();
await page.locator('[class*="Button__StyledButton"]').click();
await page.locator('div > div > div:nth-child(3) > button').click();

// Why it's bad:
// - Generated class names change constantly
// - DOM structure changes break tests immediately
// - No indication of *which* button you intend to click
// - Impossible to understand test intent

// ✅ Fix: Use role and label based locators
await page.getByRole('button', { name: 'Submit Order' }).click();
await page.getByRole('button', { name: 'Cancel' }).click();
```

## 3. Duplicated Logic

```typescript
// ❌ Anti-pattern — login repeated in every test
test('views orders', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('secret');
  await page.getByRole('button', { name: 'Sign In' }).click();
  await page.waitForURL('/dashboard');
  // ... actual test
});

// Why it's bad:
// - Slow (login on every test)
// - Fragile (if login UI changes, every test breaks)
// - Pollutes test intent with setup noise

// ✅ Fix: storageState + authenticated project (Section 13)
// All tests in the authenticated project start already logged in
test('views orders', async ({ page }) => {
  await page.goto('/orders');
  // ... actual test
});
```

## 4. Oversized Page Objects

```typescript
// ❌ Anti-pattern — one page object for everything
export class AppPage {
  async login() { /* ... */ }
  async logout() { /* ... */ }
  async viewProducts() { /* ... */ }
  async addToCart() { /* ... */ }
  async checkout() { /* ... */ }
  async viewOrders() { /* ... */ }
  async cancelOrder() { /* ... */ }
  async updateProfile() { /* ... */ }
  // 50+ more methods...
}

// Why it's bad:
// - Single Responsibility Principle violated
// - Hard to navigate and maintain
// - High merge conflict probability
// - Methods from unrelated features mixed together

// ✅ Fix: One page object per page/section
class LoginPage { /* login-related */ }
class ProductsPage { /* product-related */ }
class CartPage { /* cart-related */ }
class OrdersPage { /* orders-related */ }
class ProfilePage { /* profile-related */ }
```

## 5. Poor Fixture Design

```typescript
// ❌ Anti-pattern — global beforeAll creates shared state
test.describe('user tests', () => {
  let userId: string;

  test.beforeAll(async ({ request }) => {
    const res = await request.post('/api/users', { data: { name: 'Shared User' } });
    userId = (await res.json()).id;
    // This user is shared across all tests in this suite
  });

  test('updates name', async ({ request }) => {
    await request.patch(`/api/users/${userId}`, { data: { name: 'New Name' } });
    // Mutates shared user — now test 2 breaks
  });

  test('checks original name', async ({ request }) => {
    const res = await request.get(`/api/users/${userId}`);
    const user = await res.json();
    expect(user.name).toBe('Shared User'); // Fails because test 1 mutated it
  });
});

// ✅ Fix: Create fresh data per test via fixture
const test = baseTest.extend({
  freshUser: async ({ request }, use) => {
    const res = await request.post('/api/users', { data: { name: 'Test User' } });
    const user = await res.json();
    await use(user);
    await request.delete(`/api/users/${user.id}`); // Clean up
  },
});

test('updates name', async ({ request, freshUser }) => {
  await request.patch(`/api/users/${freshUser.id}`, { data: { name: 'New Name' } });
  // This user belongs to this test only
});
```

## 6. State Leakage

```typescript
// ❌ Anti-pattern — test depends on previous test's side effects
test('creates a product', async ({ page }) => {
  await page.goto('/products/new');
  await page.getByLabel('Name').fill('Widget');
  await page.getByRole('button', { name: 'Save' }).click();
  // Product "Widget" now exists in the database
});

test('finds the product in search', async ({ page }) => {
  await page.goto('/products');
  await page.getByLabel('Search').fill('Widget');
  // Only passes if the previous test ran and succeeded
});

// Why it's bad:
// - Tests are not independent
// - Parallel execution breaks the order dependency
// - Test isolation is violated
// - A failure in test 1 breaks all dependent tests

// ✅ Fix: Each test owns its data
test('finds a product in search', async ({ request, page }) => {
  // Create the product this test needs
  const { id } = await createProduct(request, { name: 'TestWidget-' + Date.now() });

  await page.goto('/products');
  await page.getByLabel('Search').fill('TestWidget');
  await expect(page.getByRole('listitem').filter({ hasText: 'TestWidget' })).toBeVisible();

  // Clean up
  await request.delete(`/api/products/${id}`);
});
```

## 7. Ignoring Auto-Waiting

```typescript
// ❌ Anti-pattern — manual waits before actions
await page.waitForSelector('#email');
await page.fill('#email', 'test@example.com');

await page.waitForSelector('#password');
await page.fill('#password', 'secret');

await page.waitForSelector('button[type="submit"]');
await page.click('button[type="submit"]');

// Why it's bad:
// - Double-waiting (fill/click already auto-wait)
// - Verbose and noisy
// - False sense of "adding reliability"

// ✅ Fix: Trust auto-waiting
await page.getByLabel('Email').fill('test@example.com');
await page.getByLabel('Password').fill('secret');
await page.getByRole('button', { name: 'Sign In' }).click();
```

## 8. Asserting on Non-Playwright Promises

```typescript
// ❌ Anti-pattern — bypassing Playwright's retry logic
const text = await page.locator('h1').textContent();
expect(text).toBe('Dashboard'); // One-shot, no retry

// Why it's bad:
// - If the page hasn't loaded yet, this fails immediately
// - No retry window

// ✅ Fix: Use Playwright's expect for DOM assertions
await expect(page.locator('h1')).toHaveText('Dashboard'); // Retries until timeout
```

## 9. Hardcoding Environment URLs

```typescript
// ❌ Anti-pattern
await page.goto('https://app.mycompany.com/login');

// Why it's bad:
// - Tests only run against production
// - Cannot test staging or local dev

// ✅ Fix: Use baseURL from config
await page.goto('/login');
// baseURL: process.env.BASE_URL ?? 'http://localhost:3000'
```

## 10. Not Cleaning Up Test Data

```typescript
// ❌ Anti-pattern — creates data but never deletes it
test('creates an order', async ({ request, page }) => {
  // Creates order in the database
  await page.getByRole('button', { name: 'Place Order' }).click();
  // Test ends — order lives forever, polluting the test database
});

// Why it's bad:
// - Test database fills with stale data
// - Future tests may be affected by orphaned records
// - Repeated runs compound the problem

// ✅ Fix: Use fixture teardown
const test = baseTest.extend({
  page: async ({ page, request }, use) => {
    const createdOrderIds: string[] = [];

    // Intercept API responses to capture created IDs
    page.on('response', async (resp) => {
      if (resp.url().includes('/api/orders') && resp.request().method() === 'POST') {
        const data = await resp.json().catch(() => null);
        if (data?.id) createdOrderIds.push(data.id);
      }
    });

    await use(page);

    // Cleanup
    for (const id of createdOrderIds) {
      await request.delete(`/api/orders/${id}`).catch(() => {});
    }
  },
});
```

---

# Summary

Playwright is the most capable E2E testing framework available for web developers in 2025. Its combination of auto-waiting, true cross-browser support, first-class network interception, built-in parallelism, and the Trace Viewer makes it the pragmatic choice for teams building modern web applications.

The key principles to carry forward:

**Architecture:** Separate your test code from your infrastructure. Page Objects encapsulate the UI. Fixtures handle lifecycle. Tests express intent.

**Reliability:** Never use hard waits. Create isolated data. Trust auto-waiting. Mock external services. Clean up after yourself.

**Speed:** Authenticate once. Set up state via API. Run in parallel. Shard in CI.

**Debugging:** Traces are your best friend. Keep them enabled on retry. Use the Inspector for local debugging. Read errors carefully — Playwright's are excellent.

**Maintenance:** Locators tied to accessibility are tests tied to user experience. When a test breaks because the UI changed, update the Page Object — not every test file.

This handbook covers the full breadth of Playwright as of version 1.45+. The [official documentation](https://playwright.dev) is excellent and kept up to date with each release — bookmark it alongside this guide.