# pytest-asyncio Comprehensive Guide

## Overview

pytest-asyncio is a pytest plugin that enables testing of `async` Python code. It provides fixtures, markers, and configuration to run coroutines as test functions using an event loop managed by the plugin.

Install it with:

```bash
pip install pytest-asyncio
```

It requires:

- Python 3.8+
- pytest 7.0+ (for recent versions)
- No mandatory async framework — works with asyncio from the standard library

---

## Modes of Operation

pytest-asyncio operates in one of three modes, configured globally or per test. This is one of the most important things to understand before writing any tests.

### Setting the Mode

In `pytest.ini`, `pyproject.toml`, or `setup.cfg`:

```ini
# pytest.ini
[pytest]
asyncio_mode = auto
```

```toml
# pyproject.toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
```

### Mode Descriptions

|Mode|Behavior|
|---|---|
|`strict`|Every async test must be explicitly marked with `@pytest.mark.asyncio`|
|`auto`|All async test functions are automatically treated as asyncio tests|
|`loose`|Deprecated — do not use in new projects|

`strict` is the default as of pytest-asyncio 0.21. `auto` reduces boilerplate but makes async behavior implicit.

---

## Writing Async Tests

### Basic Async Test

```python
import pytest

@pytest.mark.asyncio
async def test_simple():
    result = await some_coroutine()
    assert result == expected
```

In `auto` mode, the marker is optional:

```python
async def test_simple():
    result = await some_coroutine()
    assert result == expected
```

### Awaiting Multiple Coroutines

```python
import asyncio
import pytest

@pytest.mark.asyncio
async def test_concurrent():
    results = await asyncio.gather(
        fetch_a(),
        fetch_b(),
        fetch_c(),
    )
    assert len(results) == 3
```

### Testing Exceptions

```python
@pytest.mark.asyncio
async def test_raises():
    with pytest.raises(ValueError, match="invalid input"):
        await do_something_invalid()
```

---

## Async Fixtures

### Defining an Async Fixture

```python
import pytest_asyncio

@pytest_asyncio.fixture
async def db_connection():
    conn = await create_connection()
    yield conn
    await conn.close()
```

Use `pytest_asyncio.fixture` rather than `pytest.fixture` for async fixtures. Using `pytest.fixture` on an async function will not await it correctly.

### Fixture Scopes

```python
@pytest_asyncio.fixture(scope="function")   # default — new instance per test
async def client():
    ...

@pytest_asyncio.fixture(scope="module")     # shared across a module
async def client():
    ...

@pytest_asyncio.fixture(scope="session")    # shared across the entire session
async def client():
    ...
```

Wider scopes require the event loop to match or exceed that scope — see the event loop section below.

### Mixing Sync and Async Fixtures

Async tests can use both sync and async fixtures freely:

```python
@pytest.fixture
def base_url():
    return "http://localhost:8080"

@pytest_asyncio.fixture
async def client(base_url):
    async with httpx.AsyncClient(base_url=base_url) as c:
        yield c

@pytest.mark.asyncio
async def test_endpoint(client):
    response = await client.get("/health")
    assert response.status_code == 200
```

---

## Event Loop Configuration

### Default Behavior

By default, pytest-asyncio creates a new event loop per test function. Each test is isolated.

### `asyncio_mode` and Loop Scope

As of pytest-asyncio 0.23+, you can configure the event loop scope separately from the fixture scope:

```ini
[pytest]
asyncio_mode = auto
asyncio_default_fixture_loop_scope = session
```

This controls what scope the default event loop fixture uses.

### Custom Event Loop (Legacy Pattern)

In older versions of pytest-asyncio (pre-0.21), a common pattern was to override the event loop fixture:

```python
import asyncio
import pytest

@pytest.fixture(scope="session")
def event_loop():
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()
```

This pattern is deprecated as of 0.21 and produces a `DeprecationWarning`. The recommended replacement is to set `asyncio_default_fixture_loop_scope` in config, or use `loop_scope` on individual fixtures (see below).

### `loop_scope` on Fixtures

```python
@pytest_asyncio.fixture(loop_scope="session")
async def db():
    conn = await create_db_connection()
    yield conn
    await conn.close()
```

This is the current preferred approach for fixtures that need to persist across multiple tests.

---

## Markers

### `@pytest.mark.asyncio`

Marks an individual test as an asyncio coroutine test.

```python
@pytest.mark.asyncio
async def test_thing():
    ...
```

### Applying to a Whole Module

```python
pytestmark = pytest.mark.asyncio

async def test_one():
    ...

async def test_two():
    ...
```

### Applying to a Class

```python
@pytest.mark.asyncio
class TestMyFeature:
    async def test_one(self):
        ...

    async def test_two(self):
        ...
```

---

## Timeouts

pytest-asyncio does not provide built-in timeout support. Combine it with `pytest-timeout` or use `asyncio.wait_for()` directly.

### Using `asyncio.wait_for()`

```python
@pytest.mark.asyncio
async def test_with_timeout():
    result = await asyncio.wait_for(slow_coroutine(), timeout=5.0)
    assert result is not None
```

### Using `pytest-timeout`

```bash
pip install pytest-timeout
```

```python
@pytest.mark.asyncio
@pytest.mark.timeout(5)
async def test_thing():
    ...
```

Or globally in config:

```ini
[pytest]
timeout = 10
```

---

## Testing with Popular Async Libraries

### httpx (Async HTTP Client)

```python
import httpx
import pytest
import pytest_asyncio

@pytest_asyncio.fixture
async def client():
    async with httpx.AsyncClient() as c:
        yield c

@pytest.mark.asyncio
async def test_get(client):
    response = await client.get("https://httpbin.org/get")
    assert response.status_code == 200
```

### aiohttp

```python
import aiohttp
import pytest_asyncio

@pytest_asyncio.fixture
async def session():
    async with aiohttp.ClientSession() as s:
        yield s
```

### SQLAlchemy Async

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
import pytest_asyncio

@pytest_asyncio.fixture
async def db_session():
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")
    async_session = sessionmaker(engine, class_=AsyncSession)
    async with async_session() as session:
        yield session
    await engine.dispose()
```

### FastAPI with TestClient

FastAPI's synchronous `TestClient` works without pytest-asyncio. For async testing of FastAPI apps, use `httpx.AsyncClient` with the ASGI transport:

```python
import pytest
import pytest_asyncio
import httpx
from myapp import app

@pytest_asyncio.fixture
async def async_client():
    async with httpx.AsyncClient(
        transport=httpx.ASGITransport(app=app),
        base_url="http://test"
    ) as client:
        yield client

@pytest.mark.asyncio
async def test_root(async_client):
    response = await async_client.get("/")
    assert response.status_code == 200
```

---

## Mocking Async Code

### `AsyncMock` from `unittest.mock`

Available in Python 3.8+. Use it to mock coroutines.

```python
from unittest.mock import AsyncMock, patch
import pytest

@pytest.mark.asyncio
async def test_service_call():
    with patch("mymodule.fetch_data", new_callable=AsyncMock) as mock_fetch:
        mock_fetch.return_value = {"status": "ok"}
        result = await my_service()
        mock_fetch.assert_called_once()
        assert result["status"] == "ok"
```

### Mocking Async Context Managers

```python
from unittest.mock import AsyncMock, MagicMock

mock_conn = AsyncMock()
mock_conn.__aenter__ = AsyncMock(return_value=mock_conn)
mock_conn.__aexit__ = AsyncMock(return_value=False)
```

### `pytest-mock` Integration

```python
@pytest.mark.asyncio
async def test_with_mocker(mocker):
    mock = mocker.patch("mymodule.fetch", new_callable=AsyncMock)
    mock.return_value = 42
    result = await my_function()
    assert result == 42
```

---

## Parametrize with Async Tests

```python
@pytest.mark.asyncio
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("world", "WORLD"),
])
async def test_transform(input, expected):
    result = await async_transform(input)
    assert result == expected
```

---

## Class-Based Async Tests

```python
class TestUserService:
    @pytest.mark.asyncio
    async def test_create_user(self, db_session):
        user = await create_user(db_session, name="Alice")
        assert user.id is not None

    @pytest.mark.asyncio
    async def test_delete_user(self, db_session):
        await delete_user(db_session, user_id=1)
        result = await get_user(db_session, user_id=1)
        assert result is None
```

Or apply the marker at class level to avoid repetition:

```python
@pytest.mark.asyncio
class TestUserService:
    async def test_create_user(self, db_session):
        ...

    async def test_delete_user(self, db_session):
        ...
```

---

## Common Errors and Fixes

### `ScopeMismatch` or `Event loop is closed`

Cause: A fixture with a wider scope (e.g., `session`) tries to use an event loop scoped narrower (e.g., `function`).

Fix: Align loop scope with fixture scope using `loop_scope`:

```python
@pytest_asyncio.fixture(loop_scope="session", scope="session")
async def db():
    ...
```

Or set globally:

```ini
[pytest]
asyncio_default_fixture_loop_scope = session
```

### `RuntimeWarning: coroutine was never awaited`

Cause: An async test function was collected but not recognized as an asyncio test — often because it's missing `@pytest.mark.asyncio` in `strict` mode, or `pytest.fixture` was used instead of `pytest_asyncio.fixture`.

Fix: Add the marker, or switch to `auto` mode, and use `pytest_asyncio.fixture` for async fixtures.

### `DeprecationWarning: There is no current event loop`

Cause: Code or fixtures call `asyncio.get_event_loop()` directly rather than using the pytest-asyncio-managed loop.

Fix: Use `asyncio.get_running_loop()` inside coroutines, or restructure to avoid grabbing the loop manually.

### Fixture Not Being Awaited

Cause: Decorated with `@pytest.fixture` instead of `@pytest_asyncio.fixture`.

Fix:

```python
# Wrong
@pytest.fixture
async def my_fixture():
    ...

# Correct
@pytest_asyncio.fixture
async def my_fixture():
    ...
```

---

## Configuration Reference

```ini
# pytest.ini

[pytest]
asyncio_mode = auto                          # auto | strict
asyncio_default_fixture_loop_scope = function  # function | module | session
```

```toml
# pyproject.toml

[tool.pytest.ini_options]
asyncio_mode = "auto"
asyncio_default_fixture_loop_scope = "function"
```

---

## Quick Reference

```python
# Mark a test (strict mode)
@pytest.mark.asyncio
async def test_thing(): ...

# Async fixture
@pytest_asyncio.fixture
async def resource():
    yield await setup()
    await teardown()

# Async fixture with scope
@pytest_asyncio.fixture(scope="session", loop_scope="session")
async def db(): ...

# Module-wide marker
pytestmark = pytest.mark.asyncio

# Mock a coroutine
from unittest.mock import AsyncMock
mock = AsyncMock(return_value=42)

# Timeout via asyncio
await asyncio.wait_for(coro(), timeout=5.0)

# Exception assertion
with pytest.raises(SomeError):
    await failing_coro()
```