# Comprehensive Guide to pytest

## What Is pytest

pytest is a Python testing framework that makes it easy to write small, readable tests and scales to support complex functional testing for applications and libraries. It is distributed as a third-party package and is not part of the Python standard library.

It is widely used alongside the built-in `unittest` module but offers a more concise syntax, powerful introspection on failures, and a rich plugin ecosystem.

---

## Installation

Install pytest via pip:

```bash
pip install pytest
```

To confirm installation:

```bash
pytest --version
```

For project-based dependency management, add pytest to your `requirements.txt` or `pyproject.toml`:

```toml
# pyproject.toml
[tool.pytest.ini_options]
# configuration here

[project.optional-dependencies]
dev = ["pytest"]
```

---

## Project Layout

A conventional layout keeps tests separate from source code:

```
my_project/
├── src/
│   └── myapp/
│       ├── __init__.py
│       └── math_utils.py
├── tests/
│   ├── __init__.py
│   ├── test_math_utils.py
│   └── conftest.py
├── pyproject.toml
└── README.md
```

pytest discovers test files by looking for files matching `test_*.py` or `*_test.py` by default. Test functions must be named with a `test_` prefix.

---

## Writing Your First Test

A test is simply a Python function whose name starts with `test_`:

```python
# tests/test_math_utils.py

def add(a, b):
    return a + b

def test_add_two_positive_numbers():
    assert add(2, 3) == 5

def test_add_negative_number():
    assert add(-1, 1) == 0
```

Run the tests:

```bash
pytest tests/test_math_utils.py
```

Or run all discovered tests from the project root:

```bash
pytest
```

---

## The `assert` Statement

pytest rewrites Python's built-in `assert` statements at collection time, providing detailed introspection on failures without requiring any special assertion methods.

```python
def test_list_equality():
    result = [1, 2, 3]
    expected = [1, 2, 4]
    assert result == expected
    # pytest shows a diff-style breakdown on failure
```

On failure, pytest reports the exact values of both sides, including diffs for sequences and dicts.

---

## Test Discovery Rules

By default, pytest discovers tests by:

- Recursing into directories from the current working directory (or configured `testpaths`)
- Collecting files matching `test_*.py` or `*_test.py`
- Collecting functions prefixed `test_` inside those files
- Collecting methods prefixed `test_` inside classes prefixed `Test` (without an `__init__` method)

You can change these conventions in configuration.

---

## Running Tests

### Basic run

```bash
pytest
```

### Run a specific file

```bash
pytest tests/test_math_utils.py
```

### Run a specific test function

```bash
pytest tests/test_math_utils.py::test_add_two_positive_numbers
```

### Run a specific class method

```bash
pytest tests/test_models.py::TestUser::test_create_user
```

### Run by keyword expression

The `-k` flag selects tests whose names match the expression:

```bash
pytest -k "add or subtract"
pytest -k "not slow"
```

### Run by marker

```bash
pytest -m slow
```

### Verbose output

```bash
pytest -v
```

### Stop on first failure

```bash
pytest -x
```

### Stop after N failures

```bash
pytest --maxfail=3
```

### Show locals on failure

```bash
pytest -l
```

### Re-run only failed tests

```bash
pytest --lf        # last failed
pytest --ff        # failed first, then rest
```

### Quiet mode

```bash
pytest -q
```

---

## Test Classes

Group related tests inside a class. The class must start with `Test` and must not define `__init__`:

```python
class TestCalculator:

    def test_add(self):
        assert 1 + 1 == 2

    def test_subtract(self):
        assert 5 - 3 == 2

    def test_multiply(self):
        assert 3 * 4 == 12
```

Each test method receives a fresh instance of the class, unless overridden with fixtures.

---

## Fixtures

Fixtures are functions that provide test dependencies. They are a core pytest concept and replace setUp/tearDown patterns from `unittest`.

### Defining a fixture

```python
import pytest

@pytest.fixture
def user_data():
    return {"name": "Alice", "age": 30}

def test_user_name(user_data):
    assert user_data["name"] == "Alice"
```

pytest injects the fixture by matching the parameter name to a defined fixture name.

### Setup and teardown with yield

Use `yield` to separate setup from teardown:

```python
@pytest.fixture
def db_connection():
    conn = create_connection("sqlite:///:memory:")
    yield conn
    conn.close()  # teardown runs after the test
```

### Fixture scope

The `scope` parameter controls how often a fixture is created and destroyed:

|Scope|Lifetime|
|---|---|
|`function` (default)|Once per test function|
|`class`|Once per test class|
|`module`|Once per test module (file)|
|`package`|Once per package|
|`session`|Once per entire test session|

```python
@pytest.fixture(scope="module")
def app_config():
    return load_config("test_config.yaml")
```

### Fixture dependencies

Fixtures can request other fixtures:

```python
@pytest.fixture
def db(app_config):
    return Database(app_config["db_url"])

@pytest.fixture
def user(db):
    return db.create_user("testuser")
```

### Autouse fixtures

A fixture with `autouse=True` is applied to every test in its scope automatically:

```python
@pytest.fixture(autouse=True)
def reset_environment(monkeypatch):
    monkeypatch.setenv("APP_ENV", "test")
```

### Parametrize a fixture

```python
@pytest.fixture(params=["sqlite", "postgres"])
def db_engine(request):
    return create_engine(request.param)
```

---

## conftest.py

`conftest.py` is a special file pytest reads automatically. It is the standard place to define fixtures shared across multiple test files.

- No import is needed; pytest discovers and injects them automatically.
- A `conftest.py` at the root affects all tests below it.
- You can have multiple `conftest.py` files at different directory levels.

```python
# tests/conftest.py
import pytest
from myapp import create_app

@pytest.fixture(scope="session")
def app():
    return create_app(testing=True)

@pytest.fixture
def client(app):
    return app.test_client()
```

---

## Parametrize

`@pytest.mark.parametrize` runs the same test with different inputs:

```python
import pytest

@pytest.mark.parametrize("a, b, expected", [
    (1, 2, 3),
    (0, 0, 0),
    (-1, 1, 0),
    (100, -50, 50),
])
def test_add(a, b, expected):
    assert a + b == expected
```

Each tuple becomes a separate test case with its own pass/fail status.

### Stacking parametrize

Multiple `parametrize` decorators produce the Cartesian product of parameters:

```python
@pytest.mark.parametrize("x", [1, 2])
@pytest.mark.parametrize("y", [10, 20])
def test_multiply(x, y):
    assert x * y > 0  # runs 4 times: (1,10), (1,20), (2,10), (2,20)
```

### IDs for parametrize

Use `ids` for readable test names:

```python
@pytest.mark.parametrize("value", [0, 1, -1], ids=["zero", "one", "negative"])
def test_sign(value):
    ...
```

---

## Markers

Markers tag tests for selective execution or behaviour change.

### Built-in markers

#### `skip`

```python
@pytest.mark.skip(reason="not implemented yet")
def test_future_feature():
    ...
```

#### `skipif`

```python
import sys

@pytest.mark.skipif(sys.platform == "win32", reason="does not run on Windows")
def test_unix_behavior():
    ...
```

#### `xfail`

Marks a test expected to fail. The test still runs; it is not skipped.

```python
@pytest.mark.xfail(reason="known bug #123")
def test_broken_feature():
    assert broken_function() == 42
```

- If it fails as expected: `xfailed` (not counted as failure)
- If it unexpectedly passes: `xpassed` (configurable whether this is a failure)

Use `strict=True` to make unexpected passes count as failures:

```python
@pytest.mark.xfail(strict=True)
def test_must_not_pass():
    ...
```

#### `parametrize`

Covered in its own section above.

#### `usefixtures`

Apply a fixture to a test or class without it appearing as a parameter:

```python
@pytest.mark.usefixtures("reset_db")
class TestOrders:
    def test_create_order(self):
        ...
```

### Custom markers

Define custom markers in `pyproject.toml` or `pytest.ini` to avoid warnings:

```toml
[tool.pytest.ini_options]
markers = [
    "slow: marks tests as slow (deselect with '-m not slow')",
    "integration: marks integration tests",
    "unit: marks unit tests",
]
```

Apply:

```python
@pytest.mark.slow
def test_large_dataset():
    ...
```

Run only marked tests:

```bash
pytest -m slow
pytest -m "not slow"
pytest -m "slow and integration"
```

---

## Testing Exceptions

Use `pytest.raises` as a context manager to assert that a specific exception is raised:

```python
import pytest

def divide(a, b):
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

def test_divide_by_zero():
    with pytest.raises(ValueError):
        divide(10, 0)
```

### Inspecting the exception

```python
def test_divide_by_zero_message():
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        divide(10, 0)
```

The `match` argument accepts a regex pattern tested against the string representation of the exception.

### Accessing the exception info

```python
def test_exception_type():
    with pytest.raises(ValueError) as exc_info:
        divide(10, 0)
    assert "zero" in str(exc_info.value).lower()
```

---

## Testing Warnings

Use `pytest.warns` to assert that code raises a specific warning:

```python
import warnings
import pytest

def legacy_function():
    warnings.warn("Use new_function instead", DeprecationWarning)

def test_deprecation_warning():
    with pytest.warns(DeprecationWarning, match="new_function"):
        legacy_function()
```

---

## Monkeypatching

The `monkeypatch` fixture modifies objects, environment variables, or sys.path for the duration of a test, then reverts the changes automatically.

### Patch an attribute or method

```python
def test_get_user(monkeypatch):
    def mock_fetch(user_id):
        return {"id": user_id, "name": "Mock User"}

    monkeypatch.setattr("myapp.api.fetch_user", mock_fetch)
    result = get_user(1)
    assert result["name"] == "Mock User"
```

### Patch environment variables

```python
def test_uses_env_var(monkeypatch):
    monkeypatch.setenv("DATABASE_URL", "sqlite:///:memory:")
    config = load_config()
    assert config.db_url == "sqlite:///:memory:"
```

### Delete an environment variable

```python
def test_missing_env_var(monkeypatch):
    monkeypatch.delenv("SECRET_KEY", raising=False)
    ...
```

### Patch dictionary items

```python
def test_config_override(monkeypatch):
    monkeypatch.setitem(app.config, "DEBUG", True)
    ...
```

### Patch sys.path

```python
def test_import_path(monkeypatch, tmp_path):
    monkeypatch.syspath_prepend(str(tmp_path))
    ...
```

---

## Temporary Files and Directories

### `tmp_path` fixture

Provides a `pathlib.Path` object pointing to a temporary directory unique to each test invocation:

```python
def test_write_file(tmp_path):
    file = tmp_path / "output.txt"
    file.write_text("hello")
    assert file.read_text() == "hello"
```

### `tmp_path_factory` fixture

For session-scoped or shared temporary directories:

```python
@pytest.fixture(scope="session")
def shared_dir(tmp_path_factory):
    return tmp_path_factory.mktemp("shared")
```

---

## Capturing Output

pytest captures stdout/stderr by default. Use the `capsys` or `capfd` fixtures to read captured output:

```python
def greet(name):
    print(f"Hello, {name}!")

def test_greet_output(capsys):
    greet("World")
    captured = capsys.readouterr()
    assert captured.out == "Hello, World!\n"
    assert captured.err == ""
```

Use `capfd` instead of `capsys` when capturing at the file descriptor level (e.g., output from C extensions).

### Disable capture for a test

```python
def test_debug(capsys):
    with capsys.disabled():
        print("this prints to terminal even in captured mode")
```

---

## Logging Capture

The `caplog` fixture captures log records emitted during a test:

```python
import logging

def process():
    logging.warning("Something happened")

def test_log_output(caplog):
    with caplog.at_level(logging.WARNING):
        process()
    assert "Something happened" in caplog.text
    assert caplog.records[0].levelname == "WARNING"
```

---

## The `request` Fixture

The `request` fixture provides information about the requesting test context inside a fixture:

```python
@pytest.fixture
def db(request):
    engine = request.param  # when used with parametrize
    conn = create_connection(engine)
    yield conn
    conn.close()
```

Useful attributes on `request`:

- `request.param` — the parametrize value for this invocation
- `request.node` — the test node
- `request.module` — the test module
- `request.function` — the test function
- `request.cls` — the test class (if any)
- `request.config` — the pytest config object
- `request.addfinalizer(fn)` — registers a teardown function

---

## Mocking with `unittest.mock`

pytest does not include a built-in mock library, but integrates seamlessly with Python's standard `unittest.mock`:

```python
from unittest.mock import patch, MagicMock

def test_api_call(monkeypatch):
    with patch("myapp.services.requests.get") as mock_get:
        mock_get.return_value = MagicMock(status_code=200, json=lambda: {"ok": True})
        result = fetch_data("https://example.com/api")
    assert result["ok"] is True
```

The `pytest-mock` plugin provides the `mocker` fixture as a more idiomatic pytest wrapper around `unittest.mock`:

```bash
pip install pytest-mock
```

```python
def test_with_mocker(mocker):
    mock_get = mocker.patch("myapp.services.requests.get")
    mock_get.return_value.status_code = 200
    ...
```

---

## Configuration

### `pyproject.toml`

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "-v --strict-markers"
markers = [
    "slow: slow tests",
    "integration: integration tests",
]
```

### `pytest.ini`

```ini
[pytest]
testpaths = tests
addopts = -v --strict-markers
markers =
    slow: slow tests
    integration: integration tests
```

### `setup.cfg`

```ini
[tool:pytest]
testpaths = tests
addopts = -v
```

### Common `addopts` options

|Option|Effect|
|---|---|
|`-v`|Verbose|
|`-q`|Quiet|
|`--tb=short`|Short tracebacks|
|`--tb=no`|No tracebacks|
|`--strict-markers`|Error on unregistered markers|
|`--strict-config`|Error on config warnings|
|`-p no:warnings`|Suppress warning summary|
|`--durations=10`|Show 10 slowest tests|

---

## Plugins

pytest has a large plugin ecosystem. Plugins are installed via pip and activate automatically.

### pytest-cov — Coverage

```bash
pip install pytest-cov
pytest --cov=myapp --cov-report=term-missing tests/
```

Generate an HTML report:

```bash
pytest --cov=myapp --cov-report=html
```

Configure in `pyproject.toml`:

```toml
[tool.coverage.run]
source = ["myapp"]
omit = ["*/migrations/*"]

[tool.coverage.report]
show_missing = true
fail_under = 80
```

### pytest-xdist — Parallel execution

```bash
pip install pytest-xdist
pytest -n auto          # use all available CPUs
pytest -n 4             # use 4 workers
```

### pytest-mock — Mock fixture

Already covered above. Wraps `unittest.mock` with a cleaner pytest fixture interface.

### pytest-asyncio — Async tests

```bash
pip install pytest-asyncio
```

```python
import pytest
import asyncio

@pytest.mark.asyncio
async def test_async_function():
    result = await some_async_function()
    assert result == expected
```

Configure the default mode to avoid repeating the marker:

```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
```

### pytest-django — Django integration

```bash
pip install pytest-django
```

```python
# pytest.ini or pyproject.toml
[tool.pytest.ini_options]
DJANGO_SETTINGS_MODULE = "myproject.settings.test"
```

```python
@pytest.mark.django_db
def test_user_creation():
    from django.contrib.auth.models import User
    user = User.objects.create_user("alice", password="pass")
    assert User.objects.count() == 1
```

### pytest-httpx / responses — HTTP mocking

For mocking `httpx` or `requests` calls at the HTTP level without patching Python objects.

### pytest-benchmark — Performance benchmarking

```bash
pip install pytest-benchmark
```

```python
def test_sort_performance(benchmark):
    data = list(range(10000, 0, -1))
    result = benchmark(sorted, data)
    assert result[0] == 1
```

---

## Fixtures: Advanced Patterns

### Fixture factories

A fixture that returns a factory function lets you create multiple instances:

```python
@pytest.fixture
def make_user():
    created = []
    def _make_user(name, role="viewer"):
        user = User(name=name, role=role)
        created.append(user)
        return user
    yield _make_user
    for user in created:
        user.delete()

def test_two_users(make_user):
    admin = make_user("Alice", role="admin")
    viewer = make_user("Bob")
    assert admin.role == "admin"
    assert viewer.role == "viewer"
```

### Overriding fixtures

A fixture in a lower-level `conftest.py` overrides one with the same name from a higher level:

```
tests/
├── conftest.py          # defines: db (scope="session")
└── unit/
    ├── conftest.py      # overrides: db (scope="function", in-memory)
    └── test_models.py
```

### Lazy fixture values with `pytest.lazy_fixture`

Requires the `pytest-lazy-fixture` plugin. Allows using fixture values inside `parametrize`:

```python
@pytest.mark.parametrize("user", [pytest.lazy_fixture("admin_user"), pytest.lazy_fixture("viewer_user")])
def test_user_permissions(user):
    ...
```

---

## Test Isolation Strategies

Good tests are independent and do not share mutable state. Common strategies:

- Use `scope="function"` (the default) for fixtures that mutate state.
- Use database transactions that roll back after each test (common in Django and SQLAlchemy fixtures).
- Use `monkeypatch` instead of modifying global state directly.
- Avoid module-level mutable variables in test files.

---

## Handling Slow Tests

Mark slow tests and exclude them during rapid development cycles:

```python
@pytest.mark.slow
def test_full_pipeline():
    ...
```

```bash
pytest -m "not slow"   # fast feedback loop
pytest -m slow         # CI or nightly run
```

---

## Organizing Large Test Suites

For large projects, consider:

- Separating `unit/`, `integration/`, and `e2e/` directories under `tests/`
- Using `conftest.py` at each level for scoped fixtures
- Using `pytest-xdist` for parallel runs
- Using `--ignore` to skip directories:

```bash
pytest --ignore=tests/e2e
```

- Using `testpaths` in config to restrict default discovery

---

## Useful Built-in Fixtures Reference

|Fixture|Purpose|
|---|---|
|`capsys`|Capture stdout/stderr|
|`capfd`|Capture at file descriptor level|
|`caplog`|Capture log records|
|`monkeypatch`|Patch attributes, envvars, dicts|
|`tmp_path`|Temporary directory (Path) per test|
|`tmp_path_factory`|Temporary directories for broader scopes|
|`request`|Info about the current test context|
|`pytestconfig`|Access to pytest config|
|`recwarn`|Record warnings|
|`cache`|Persist values across test runs|

---

## Debugging Failing Tests

### Drop into pdb on failure

```bash
pytest --pdb
```

### Drop into pdb at a specific point

```python
def test_something():
    result = compute()
    import pdb; pdb.set_trace()
    assert result == 42
```

Or use the built-in `breakpoint()` (Python 3.7+):

```python
def test_something():
    result = compute()
    breakpoint()
    assert result == 42
```

### Show full traceback

```bash
pytest --tb=long
```

### Show only the last N lines of traceback

```bash
pytest --tb=short
```

### Print all local variables in tracebacks

```bash
pytest -l
```

---

## Exit Codes

pytest returns standard exit codes:

|Code|Meaning|
|---|---|
|0|All tests passed|
|1|Some tests failed|
|2|Test execution interrupted|
|3|Internal error|
|4|Command-line usage error|
|5|No tests were collected|

---

## Writing a Plugin

pytest plugins are Python packages that hook into pytest's internal event system.

### A minimal local plugin in `conftest.py`

```python
# conftest.py

def pytest_runtest_logreport(report):
    if report.failed:
        print(f"\n[CUSTOM] FAILED: {report.nodeid}")
```

### Hook specification

Hooks are defined in `pytest_plugins` or via `conftest.py`. Common hooks:

|Hook|When it runs|
|---|---|
|`pytest_configure`|After command-line parsing|
|`pytest_collection_modifyitems`|After test collection, before running|
|`pytest_runtest_setup`|Before each test's setup phase|
|`pytest_runtest_call`|During test execution|
|`pytest_runtest_teardown`|After each test's teardown|
|`pytest_runtest_logreport`|After each test phase report|
|`pytest_terminal_summary`|At the end of the session|

### Distributable plugin

A distributable plugin is a regular Python package with a `setup.cfg` or `pyproject.toml` entry point:

```toml
[project.entry-points."pytest11"]
my_plugin = "my_plugin.plugin"
```

---

## Common Patterns and Recipes

### Assert approximate float equality

```python
def test_float():
    assert 0.1 + 0.2 == pytest.approx(0.3)
    assert 1.0 == pytest.approx(1.0, rel=1e-3)
    assert [0.1, 0.2] == pytest.approx([0.1, 0.2])
```

### Parametrize with `None` as a sentinel

```python
@pytest.mark.parametrize("value,expected", [
    (1, True),
    (0, False),
    (None, False),
])
def test_truthiness(value, expected):
    assert bool(value) == expected
```

### Run a test multiple times

Use `pytest-repeat`:

```bash
pip install pytest-repeat
pytest --count=5 tests/test_flaky.py
```

### Conditional xfail at runtime

```python
def test_feature(platform):
    if platform == "windows":
        pytest.xfail("not supported on Windows")
    assert feature_works()
```

### Skip a test at runtime

```python
def test_requires_network():
    if not network_available():
        pytest.skip("network unavailable")
    assert ping("8.8.8.8")
```

### Custom assertion messages

```python
def test_with_message():
    result = compute()
    assert result > 0, f"Expected positive value, got {result}"
```

---

## Performance Tips

- Use `scope="session"` or `scope="module"` for expensive fixtures (database setup, large file loads) where test isolation allows it.
- Use `pytest-xdist` to parallelize independent tests.
- Profile slow collections with `--collect-only` to count tests without running them.
- Use `--durations=20` to identify the slowest tests.
- Avoid unnecessary I/O in fixtures; prefer in-memory fakes where possible.

---

## Checklist for a Healthy Test Suite

- Tests are independent and do not rely on execution order.
- Fixtures clean up after themselves using `yield` + teardown or `addfinalizer`.
- Custom markers are registered in configuration (`--strict-markers` is set).
- Coverage is measured and a minimum threshold is enforced.
- Slow and integration tests are marked and excluded from the default run.
- `conftest.py` files are used for shared fixtures, not imports in test files.
- Tests have descriptive names that explain what is being tested and what the expected outcome is.