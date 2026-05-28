# Playwright (Python) Comprehensive Guide

## Overview

Playwright is a browser automation library developed by Microsoft. The Python version provides a synchronous and an asynchronous API for automating Chromium, Firefox, and WebKit browsers.

Install it with:

```bash
pip install playwright
pytest install playwright  # if using pytest-playwright
playwright install          # downloads browser binaries
```

Install specific browsers only:

```bash
playwright install chromium
playwright install firefox
playwright install webkit
```

Import convention:

```python
from playwright.sync_api import sync_playwright
from playwright.async_api import async_playwright
```

---

## Sync vs Async API

Playwright provides two complete API surfaces. They are functionally equivalent — the difference is only in how they integrate with your code.

||Sync API|Async API|
|---|---|---|
|Import|`sync_playwright`|`async_playwright`|
|Use with|Regular Python scripts|`asyncio`, pytest-asyncio|
|`await` required|No|Yes|
|Suitable for|Scripts, simple tests|FastAPI, async test suites|

All examples below show the sync API first, with async equivalents where the pattern differs meaningfully.

---

## Getting Started

### Sync

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    print(page.title())
    browser.close()
```

### Async

```python
import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page()
        await page.goto("https://example.com")
        print(await page.title())
        await browser.close()

asyncio.run(main())
```

---

## Browsers

### Launching a Browser

```python
# Headless (default)
browser = p.chromium.launch()

# Headed (visible browser window)
browser = p.chromium.launch(headless=False)

# With slow motion (useful for debugging)
browser = p.chromium.launch(slow_mo=500)  # ms between actions

# With custom executable
browser = p.chromium.launch(executable_path="/usr/bin/chromium")
```

### Supported Browsers

```python
p.chromium.launch()   # Chromium / Chrome
p.firefox.launch()    # Firefox
p.webkit.launch()     # WebKit (Safari engine)
```

### Browser Channels

Use installed system browsers instead of Playwright's bundled binaries:

```python
p.chromium.launch(channel="chrome")         # Google Chrome
p.chromium.launch(channel="msedge")         # Microsoft Edge
p.chromium.launch(channel="chrome-beta")
```

---

## Browser Contexts

A browser context is an isolated session — separate cookies, storage, and cache. Equivalent to an incognito window.

```python
browser = p.chromium.launch()
context = browser.new_context()
page = context.new_page()
```

### Context Options

```python
context = browser.new_context(
    viewport={"width": 1280, "height": 720},
    locale="en-US",
    timezone_id="Asia/Manila",
    geolocation={"latitude": 14.5995, "longitude": 120.9842},
    permissions=["geolocation"],
    user_agent="Mozilla/5.0 ...",
    http_credentials={"username": "user", "password": "pass"},
    ignore_https_errors=True,
    record_video_dir="videos/",        # record video of all pages
    record_har_path="trace.har",       # record network HAR
)
```

### Saving and Reusing Auth State

```python
# Save auth state after login
context.storage_state(path="auth.json")

# Reuse in a new context (skips login)
context = browser.new_context(storage_state="auth.json")
```

---

## Pages

### Creating and Navigating Pages

```python
page = context.new_page()

page.goto("https://example.com")
page.goto("https://example.com", wait_until="networkidle")
page.go_back()
page.go_forward()
page.reload()
```

`wait_until` options:

|Value|Waits until|
|---|---|
|`"commit"`|Navigation committed|
|`"domcontentloaded"`|DOM ready|
|`"load"`|Load event fired|
|`"networkidle"`|No network requests for 500ms|

### Page Information

```python
page.url          # current URL
page.title()      # page title
page.content()    # full HTML content
```

### Multiple Pages / Tabs

```python
page2 = context.new_page()
pages = context.pages   # list of all open pages

# Handle new tab opened by a click
with context.expect_page() as new_page_info:
    page.click("a[target='_blank']")
new_page = new_page_info.value
new_page.wait_for_load_state()
```

---

## Locators

Locators are the primary way to find elements in Playwright. They are lazy — they do not query the DOM until an action is performed, and they automatically retry until the element is available or a timeout is reached.

### Creating Locators

```python
# By role (preferred — most resilient)
page.get_by_role("button", name="Submit")
page.get_by_role("heading", name="Welcome")
page.get_by_role("link", name="Sign in")
page.get_by_role("checkbox", name="Remember me")
page.get_by_role("textbox", name="Email")

# By label text
page.get_by_label("Email address")

# By placeholder
page.get_by_placeholder("Search...")

# By visible text
page.get_by_text("Forgot password?")
page.get_by_text("Submit", exact=True)

# By alt text (images)
page.get_by_alt_text("Company logo")

# By title attribute
page.get_by_title("Tooltip text")

# By test ID (data-testid attribute by default)
page.get_by_test_id("submit-button")

# By CSS selector
page.locator("button.primary")
page.locator("#main-content > p")

# By XPath
page.locator("xpath=//button[@type='submit']")
```

### Chaining and Filtering Locators

```python
# Scoped to a parent
form = page.locator("form#login")
form.get_by_label("Email")

# Filter by text
page.locator("li").filter(has_text="Alice")

# Filter by child locator
page.locator("li").filter(has=page.locator(".active"))

# Nth match
page.locator("button").nth(0)   # first
page.locator("button").last     # last
page.locator("button").first    # first (alias)
```

### Locator vs `page.query_selector`

Prefer locators over `page.query_selector()` and `page.query_selector_all()`. Those are immediate DOM queries with no retry logic. Locators automatically wait and retry, making tests more reliable.

---

## Actions

### Clicking

```python
page.get_by_role("button", name="Submit").click()

# Options
locator.click(button="right")          # right-click
locator.click(modifiers=["Shift"])     # shift+click
locator.click(position={"x": 10, "y": 5})
locator.dblclick()
locator.tap()                          # touch tap (mobile)
```

### Typing and Input

```python
locator.fill("hello@example.com")      # clears and types (recommended)
locator.type("hello")                  # types character by character
locator.press("Enter")
locator.press("Control+A")
locator.clear()                        # clears the field
```

### Select, Checkbox, Radio

```python
# Select dropdown
page.get_by_label("Country").select_option("Philippines")
page.get_by_label("Country").select_option(value="PH")
page.get_by_label("Size").select_option(["S", "M"])  # multi-select

# Checkbox / radio
page.get_by_label("Remember me").check()
page.get_by_label("Remember me").uncheck()
page.get_by_label("Remember me").set_checked(True)
```

### Hover, Focus, Drag

```python
locator.hover()
locator.focus()

# Drag and drop
page.drag_and_drop("#source", "#target")

# Or with locators
source = page.locator("#source")
target = page.locator("#target")
source.drag_to(target)
```

### File Upload

```python
page.get_by_label("Upload file").set_input_files("path/to/file.pdf")

# Multiple files
page.get_by_label("Upload").set_input_files(["file1.pdf", "file2.pdf"])

# Clear file input
page.get_by_label("Upload").set_input_files([])
```

---

## Waiting

Playwright's locators wait automatically for elements to be visible and actionable. Additional waiting is sometimes needed for specific conditions.

### Built-in Auto-Waiting

All locator actions (`click`, `fill`, `check`, etc.) automatically wait for the element to be:

- Attached to DOM
- Visible
- Stable (not animating)
- Enabled
- Not obscured

### Explicit Waits

```python
# Wait for a locator to reach a state
locator.wait_for()                         # default: visible
locator.wait_for(state="attached")
locator.wait_for(state="detached")
locator.wait_for(state="hidden")
locator.wait_for(state="visible")

# Wait for page load state
page.wait_for_load_state("networkidle")

# Wait for a URL
page.wait_for_url("**/dashboard")
page.wait_for_url(re.compile(r"/dashboard$"))

# Wait for a function to return true in the browser
page.wait_for_function("document.readyState === 'complete'")
```

### Avoid `page.wait_for_timeout()`

```python
# Avoid this — it always waits the full duration regardless of state
page.wait_for_timeout(3000)
```

Use explicit condition-based waits instead. `wait_for_timeout()` makes tests slower and fragile.

---

## Assertions

Playwright provides built-in async-aware assertions via `expect()`. These retry automatically until the condition is met or a timeout expires.

```python
from playwright.sync_api import expect

# Visibility
expect(locator).to_be_visible()
expect(locator).to_be_hidden()

# State
expect(locator).to_be_enabled()
expect(locator).to_be_disabled()
expect(locator).to_be_checked()
expect(locator).to_be_focused()
expect(locator).to_be_editable()
expect(locator).to_be_empty()

# Content
expect(locator).to_have_text("Hello")
expect(locator).to_have_text(re.compile(r"Hello\s+World"))
expect(locator).to_contain_text("ello")
expect(locator).to_have_value("alice@example.com")
expect(locator).to_have_attribute("href", "/home")
expect(locator).to_have_class("btn-primary")
expect(locator).to_have_id("submit-btn")
expect(locator).to_have_count(5)

# Page
expect(page).to_have_url("https://example.com/dashboard")
expect(page).to_have_url(re.compile(r"/dashboard$"))
expect(page).to_have_title("Dashboard")

# Custom timeout
expect(locator).to_be_visible(timeout=10_000)
```

---

## Handling Dialogs, Popups, and Frames

### Dialogs (alert, confirm, prompt)

```python
page.on("dialog", lambda dialog: dialog.accept())
page.on("dialog", lambda dialog: dialog.dismiss())
page.on("dialog", lambda dialog: dialog.accept(dialog.message))

# With prompt input
def handle_dialog(dialog):
    if dialog.type == "prompt":
        dialog.accept("my input")
    else:
        dialog.dismiss()

page.on("dialog", handle_dialog)
```

### Frames (iframes)

```python
# By name or URL
frame = page.frame("frame-name")
frame = page.frame_locator("iframe#chat").locator("button")

# Nested frames
page.frame_locator("iframe#outer").frame_locator("iframe#inner").locator("input")
```

### Popups and New Windows

```python
with page.expect_popup() as popup_info:
    page.get_by_role("button", name="Open popup").click()

popup = popup_info.value
popup.wait_for_load_state()
popup.get_by_role("button", name="Close").click()
```

---

## Network Interception

### Intercepting Requests

```python
def handle_route(route):
    if "analytics" in route.request.url:
        route.abort()
    else:
        route.continue_()

page.route("**/*", handle_route)
```

### Mocking Responses

```python
page.route("**/api/users", lambda route: route.fulfill(
    status=200,
    content_type="application/json",
    body='[{"id": 1, "name": "Alice"}]',
))
```

### Modifying Requests

```python
def modify_request(route):
    headers = {**route.request.headers, "X-Custom": "value"}
    route.continue_(headers=headers)

page.route("**/api/**", modify_request)
```

### Waiting for Requests and Responses

```python
# Wait for a specific request to complete
with page.expect_request("**/api/data") as req_info:
    page.get_by_role("button", name="Load").click()
request = req_info.value

with page.expect_response("**/api/data") as resp_info:
    page.get_by_role("button", name="Load").click()
response = resp_info.value
print(response.json())
```

---

## JavaScript Execution

```python
# Evaluate JS in the page context
result = page.evaluate("document.title")
result = page.evaluate("() => window.innerWidth")
result = page.evaluate("(x) => x * 2", 21)

# Pass Python objects to JS
data = {"key": "value"}
result = page.evaluate("(data) => JSON.stringify(data)", data)

# On a locator
text = locator.evaluate("el => el.textContent")

# Expose a Python function to the page
def log_message(msg):
    print("From browser:", msg)

page.expose_function("pyLog", log_message)
page.evaluate("pyLog('hello from JS')")
```

---

## Screenshots and Videos

### Screenshots

```python
# Full page screenshot
page.screenshot(path="screenshot.png", full_page=True)

# Element screenshot
locator.screenshot(path="element.png")

# To bytes (no file)
img_bytes = page.screenshot()

# Clip to region
page.screenshot(path="clip.png", clip={"x": 0, "y": 0, "width": 400, "height": 300})
```

### PDF (Chromium only)

```python
page.pdf(path="output.pdf", format="A4", print_background=True)
```

### Video Recording

Configure on the context:

```python
context = browser.new_context(record_video_dir="videos/")
page = context.new_page()
# ... do stuff ...
context.close()  # video is saved on close
print(page.video.path())
```

---

## Tracing

Traces capture a full recording of a test run: screenshots, network, console, and DOM snapshots. Useful for debugging failures in CI.

```python
context.tracing.start(screenshots=True, snapshots=True, sources=True)

page.goto("https://example.com")
page.get_by_role("button", name="Submit").click()

context.tracing.stop(path="trace.zip")
```

View the trace:

```bash
playwright show-trace trace.zip
```

---

## pytest-playwright

pytest-playwright is the official pytest plugin for Playwright. It provides fixtures for browser, context, and page management.

```bash
pip install pytest-playwright
playwright install
```

### Built-in Fixtures

|Fixture|Scope|Description|
|---|---|---|
|`playwright`|session|Playwright instance|
|`browser_type`|session|The browser type (chromium, etc.)|
|`browser`|session|Launched browser|
|`browser_context`|function|New browser context per test|
|`page`|function|New page per test|
|`context`|function|Alias for `browser_context`|

### Basic Test

```python
from playwright.sync_api import Page, expect

def test_title(page: Page):
    page.goto("https://example.com")
    expect(page).to_have_title("Example Domain")

def test_button(page: Page):
    page.goto("https://example.com")
    page.get_by_role("link", name="More information").click()
    expect(page).to_have_url(re.compile(r"iana.org"))
```

### Configuration via `pytest.ini` or `pyproject.toml`

```ini
[pytest]
# Base URL — enables page.goto("/path") shorthand
base_url = http://localhost:8000

# Browser to use
browser = chromium   # chromium | firefox | webkit

# Headed mode
headed = true

# Slow motion
slowmo = 500

# Viewport
viewport = 1280x720

# Screenshot on failure
screenshot = only-on-failure   # always | never | only-on-failure

# Video recording
video = retain-on-failure      # on | off | retain-on-failure

# Tracing
tracing = retain-on-failure    # on | off | retain-on-failure
```

### Command-Line Options

```bash
pytest --browser firefox
pytest --headed
pytest --slowmo 500
pytest --base-url http://localhost:8080
pytest --screenshot only-on-failure
pytest --video retain-on-failure
pytest --tracing on
```

### Custom Fixtures

```python
import pytest
from playwright.sync_api import Browser, BrowserContext

@pytest.fixture(scope="session")
def browser_context_args(browser_context_args):
    return {
        **browser_context_args,
        "viewport": {"width": 1920, "height": 1080},
        "locale": "en-PH",
    }

@pytest.fixture
def authenticated_page(page):
    page.goto("/login")
    page.get_by_label("Email").fill("admin@example.com")
    page.get_by_label("Password").fill("secret")
    page.get_by_role("button", name="Login").click()
    page.wait_for_url("**/dashboard")
    return page
```

### Parametrize Across Browsers

```python
# Run the same test across all three browsers
@pytest.mark.parametrize("browser_name", ["chromium", "firefox", "webkit"])
def test_cross_browser(browser_name, playwright):
    browser = getattr(playwright, browser_name).launch()
    page = browser.new_page()
    page.goto("https://example.com")
    assert page.title()
    browser.close()
```

Or via CLI:

```bash
pytest --browser chromium --browser firefox --browser webkit
```

---

## Page Object Model

The Page Object Model (POM) is a design pattern that encapsulates page interactions into classes. Playwright's locators work well with this pattern.

```python
# pages/login_page.py
from playwright.sync_api import Page, expect

class LoginPage:
    def __init__(self, page: Page):
        self.page = page
        self.email_input = page.get_by_label("Email")
        self.password_input = page.get_by_label("Password")
        self.submit_button = page.get_by_role("button", name="Login")
        self.error_message = page.get_by_role("alert")

    def navigate(self):
        self.page.goto("/login")

    def login(self, email: str, password: str):
        self.email_input.fill(email)
        self.password_input.fill(password)
        self.submit_button.click()

    def expect_error(self, message: str):
        expect(self.error_message).to_contain_text(message)
```

```python
# tests/test_login.py
from pages.login_page import LoginPage

def test_invalid_login(page):
    login = LoginPage(page)
    login.navigate()
    login.login("wrong@example.com", "badpassword")
    login.expect_error("Invalid credentials")
```

---

## Async API with pytest-asyncio

```python
import pytest
from playwright.async_api import async_playwright, Page, expect

@pytest.fixture
async def page():
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        context = await browser.new_context()
        page = await context.new_page()
        yield page
        await browser.close()

@pytest.mark.asyncio
async def test_title(page: Page):
    await page.goto("https://example.com")
    await expect(page).to_have_title("Example Domain")
```

Or use `pytest-playwright` with async mode by installing `anyio` and configuring accordingly — refer to the current pytest-playwright documentation for the latest async fixture setup, as this has evolved across versions.

---

## Mobile Emulation

```python
from playwright.sync_api import sync_playwright, devices

with sync_playwright() as p:
    iphone = devices["iPhone 13"]
    browser = p.webkit.launch()
    context = browser.new_context(**iphone)
    page = context.new_page()
    page.goto("https://example.com")
```

List available devices:

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    print(list(p.devices.keys()))
```

---

## Common Patterns

### Retry on Flakiness

Playwright's built-in auto-waiting handles most flakiness. For test-level retries with pytest-playwright:

```bash
pytest --retries 2
```

Or in config:

```ini
[pytest]
retries = 2
```

### Base URL Shorthand

When `base_url` is configured, `page.goto()` accepts relative paths:

```python
page.goto("/login")        # resolves to http://localhost:8000/login
page.goto("/dashboard")
```

### Download Handling

```python
with page.expect_download() as download_info:
    page.get_by_role("button", name="Export CSV").click()

download = download_info.value
download.save_as("report.csv")
print(download.suggested_filename)
```

### Keyboard and Mouse

```python
# Keyboard
page.keyboard.press("Tab")
page.keyboard.type("Hello, world")
page.keyboard.down("Shift")
page.keyboard.up("Shift")

# Mouse
page.mouse.move(100, 200)
page.mouse.click(100, 200)
page.mouse.wheel(0, 300)   # scroll
```

---

## Debugging

### Pause Execution (Inspector)

```python
page.pause()   # opens Playwright Inspector, pauses test
```

### `PWDEBUG` Environment Variable

```bash
PWDEBUG=1 pytest test_login.py
```

Opens the Inspector and runs in headed mode with slow motion automatically.

### Console and Page Errors

```python
page.on("console", lambda msg: print(f"[{msg.type}] {msg.text}"))
page.on("pageerror", lambda err: print(f"Page error: {err}"))
```

### Codegen — Record Actions as Code

```bash
playwright codegen https://example.com
playwright codegen --target python https://example.com
playwright codegen --target python-async https://example.com
```

This opens a browser and records your interactions, outputting Playwright Python code.

---

## Quick Reference

```python
# Launch
browser = p.chromium.launch(headless=False, slow_mo=200)
context = browser.new_context(storage_state="auth.json")
page = context.new_page()

# Navigate
page.goto("/path")
page.wait_for_url("**/dashboard")

# Locate
page.get_by_role("button", name="Submit")
page.get_by_label("Email")
page.get_by_text("Welcome")
page.get_by_test_id("my-widget")
page.locator("css=.my-class")

# Act
locator.click()
locator.fill("text")
locator.select_option("value")
locator.check()
locator.press("Enter")

# Assert
expect(locator).to_be_visible()
expect(locator).to_have_text("hello")
expect(page).to_have_url("https://...")

# Network
page.route("**/api/**", lambda r: r.fulfill(body="{}"))

# Debug
page.pause()
page.screenshot(path="debug.png", full_page=True)
context.tracing.stop(path="trace.zip")
```