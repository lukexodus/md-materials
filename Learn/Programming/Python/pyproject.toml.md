# Comprehensive Guide to pyproject.toml

## What Is pyproject.toml

`pyproject.toml` is a configuration file for Python projects, written in [TOML](https://toml.io/) (Tom's Obvious Minimal Language). It was introduced by [PEP 518](https://peps.python.org/pep-0518/) in 2016 and expanded by [PEP 621](https://peps.python.org/pep-0621/) and others to become the standard single-source configuration file for:

- Build system requirements
- Project metadata (name, version, dependencies, authors, etc.)
- Tool configuration (pytest, mypy, ruff, black, coverage, etc.)

It replaces and consolidates functionality previously spread across `setup.py`, `setup.cfg`, `MANIFEST.in`, `tox.ini`, `.flake8`, and other files.

---

## TOML Primer

`pyproject.toml` uses TOML syntax. Key concepts:

```toml
# This is a comment

# String
name = "my-package"

# Integer
version_major = 3

# Boolean
include_docs = true

# Array
keywords = ["web", "api", "rest"]

# Inline table
author = { name = "Alice", email = "alice@example.com" }

# Table (section header)
[section]
key = "value"

# Array of tables
[[section.items]]
name = "first"

[[section.items]]
name = "second"
```

---

## Top-Level Structure

A complete `pyproject.toml` is typically divided into three main areas:

```toml
[build-system]       # PEP 518: which build backend to use

[project]            # PEP 621: project metadata

[tool.<name>]        # tool-specific configuration
```

---

## `[build-system]`

Declares the build backend and its requirements. This section is read by pip and other installers before the build environment is created.

```toml
[build-system]
requires = ["setuptools>=68", "wheel"]
build-backend = "setuptools.build_meta"
```

### Common build backends

|Backend|`requires`|`build-backend`|
|---|---|---|
|setuptools|`["setuptools>=68", "wheel"]`|`"setuptools.build_meta"`|
|Hatchling|`["hatchling"]`|`"hatchling.build"`|
|Flit|`["flit_core>=3.4"]`|`"flit_core.buildapi"`|
|PDM|`["pdm-backend"]`|`"pdm.backend"`|
|Poetry|`["poetry-core"]`|`"poetry.core.masonry.api"`|
|Meson-python|`["meson-python"]`|`"mesonpy"`|

The choice of build backend affects which other sections (like `[tool.hatch]` or `[tool.poetry]`) are relevant.

---

## `[project]` — Core Metadata (PEP 621)

This section defines standardised project metadata understood by all compliant build backends.

### Name and version

```toml
[project]
name = "my-package"
version = "1.2.3"
```

`name` is the distribution name as it appears on PyPI. It is normalized (hyphens and underscores are equivalent). `version` must be a valid [PEP 440](https://peps.python.org/pep-0440/) version string.

### Dynamic fields

If the build backend should compute a field (e.g. version from a git tag), declare it in `dynamic` and omit it from `[project]`:

```toml
[project]
name = "my-package"
dynamic = ["version", "readme"]
```

### Description

A short one-line summary:

```toml
description = "A fast HTTP client library."
```

### README

```toml
readme = "README.md"
```

Or with explicit content type:

```toml
readme = { file = "README.rst", content-type = "text/x-rst" }
```

### License

```toml
license = { text = "MIT" }
# or
license = { file = "LICENSE" }
```

### Authors and maintainers

```toml
authors = [
    { name = "Alice Smith", email = "alice@example.com" },
    { name = "Bob Jones" },
]
maintainers = [
    { name = "Carol White", email = "carol@example.com" },
]
```

### Python version requirement

```toml
requires-python = ">=3.10"
```

### Keywords and classifiers

```toml
keywords = ["http", "client", "async"]

classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Topic :: Internet :: WWW/HTTP",
]
```

Full classifier list: https://pypi.org/classifiers/

### URLs

```toml
[project.urls]
Homepage = "https://example.com"
Documentation = "https://docs.example.com"
Repository = "https://github.com/alice/my-package"
"Bug Tracker" = "https://github.com/alice/my-package/issues"
Changelog = "https://github.com/alice/my-package/blob/main/CHANGELOG.md"
```

---

## Dependencies

### Runtime dependencies

```toml
[project]
dependencies = [
    "httpx>=0.25.0",
    "pydantic>=2.0",
    "click>=8.0,<9.0",
    "typing-extensions>=4.0; python_version < '3.11'",
]
```

Version specifiers follow [PEP 508](https://peps.python.org/pep-0508/):

| Specifier    | Meaning                           |
| ------------ | --------------------------------- |
| `>=1.0`      | At least 1.0                      |
| `\==1.2.3`   | Exactly 1.2.3                     |
| `~=1.4`      | Compatible with 1.4 (>=1.4, <2.0) |
| `!=1.3`      | Anything except 1.3               |
| `>=1.0,<2.0` | Between 1.0 and 2.0               |

### Environment markers

Markers let you specify conditions under which a dependency applies:

```toml
dependencies = [
    "importlib-metadata>=4.0; python_version < '3.10'",
    "pywin32; sys_platform == 'win32'",
    "uvloop>=0.17; sys_platform != 'win32'",
]
```

Common markers: `python_version`, `python_full_version`, `sys_platform`, `os_name`, `platform_machine`.

### Optional dependencies (extras)

```toml
[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "pytest-cov",
    "mypy",
    "ruff",
]
docs = [
    "sphinx>=7.0",
    "sphinx-rtd-theme",
]
async = [
    "anyio>=4.0",
]
all = [
    "my-package[async,docs]",
]
```

Install an extra:

```bash
pip install "my-package[dev]"
pip install "my-package[dev,docs]"
pip install -e ".[dev]"   # editable, local install
```

---

## Entry Points

Entry points expose Python callables as command-line scripts or plugin hooks.

### Console scripts

```toml
[project.scripts]
my-cli = "mypackage.cli:main"
greet = "mypackage.commands:greet_command"
```

After installation, `my-cli` becomes an executable on the system PATH that calls `mypackage.cli.main()`.

### GUI scripts

```toml
[project.gui-scripts]
my-app = "mypackage.app:launch"
```

On Windows, this launches without a console window.

### Plugin entry points

Entry points are the standard mechanism for plugin discovery (used by pytest, Sphinx, Flask extensions, etc.):

```toml
[project.entry-points."pytest11"]
my-plugin = "mypackage.pytest_plugin"

[project.entry-points."sphinx.builders"]
my-builder = "mypackage.sphinx_builder:MyBuilder"
```

---

## `[tool.*]` — Tool Configuration

Any tool can store its configuration under `[tool.<toolname>]`. There is no central registry; tools read their own sections.

---

## `[tool.setuptools]`

Setuptools-specific configuration when using setuptools as the build backend.

### Package discovery

```toml
[tool.setuptools.packages.find]
where = ["src"]         # look inside src/
include = ["mypackage*"]
exclude = ["tests*"]
```

For a flat layout (packages at root):

```toml
[tool.setuptools.packages.find]
exclude = ["tests*", "docs*"]
```

### Package data

```toml
[tool.setuptools.package-data]
"mypackage" = ["*.json", "templates/*.html", "py.typed"]
```

### Include/exclude specific files

```toml
[tool.setuptools]
include-package-data = true
```

---

## `[tool.hatch]`

Hatchling is a modern, standards-compliant build backend. When using Hatchling:

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.version]
path = "src/mypackage/__init__.py"   # reads __version__ from this file

[tool.hatch.build.targets.wheel]
packages = ["src/mypackage"]

[tool.hatch.build.targets.sdist]
include = ["src/", "tests/", "docs/"]
exclude = ["*.pyc", "__pycache__"]
```

### Hatch environments

```toml
[tool.hatch.envs.default]
dependencies = ["pytest", "pytest-cov"]

[tool.hatch.envs.default.scripts]
test = "pytest {args}"
cov = "pytest --cov=mypackage --cov-report=term-missing"

[tool.hatch.envs.lint]
dependencies = ["ruff", "mypy"]

[tool.hatch.envs.lint.scripts]
check = ["ruff check .", "mypy src/"]
fmt = "ruff format ."
```

Run with:

```bash
hatch run test
hatch run lint:check
```

---

## `[tool.pytest.ini_options]`

pytest reads its configuration from here:

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "-v",
    "--strict-markers",
    "--strict-config",
    "--tb=short",
]
markers = [
    "slow: marks tests as slow",
    "integration: marks integration tests",
    "unit: marks unit tests",
]
filterwarnings = [
    "error",
    "ignore::DeprecationWarning:third_party_lib",
]
log_cli = true
log_cli_level = "INFO"
```

---

## `[tool.coverage]`

Configuration for `coverage.py` (used with `pytest-cov`):

```toml
[tool.coverage.run]
source = ["src/mypackage"]
branch = true
omit = [
    "*/migrations/*",
    "*/tests/*",
    "*/__init__.py",
]

[tool.coverage.report]
show_missing = true
skip_covered = false
fail_under = 85
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
    "@overload",
]

[tool.coverage.html]
directory = "htmlcov"
```

---

## `[tool.mypy]`

Type checker configuration:

```toml
[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_any_generics = true
check_untyped_defs = true
no_implicit_optional = true
show_error_codes = true
pretty = true

[[tool.mypy.overrides]]
module = "third_party_lib.*"
ignore_missing_imports = true

[[tool.mypy.overrides]]
module = "tests.*"
disallow_untyped_defs = false
```

---

## `[tool.ruff]`

Ruff is a fast Python linter and formatter. It replaces flake8, isort, pyupgrade, and others:

```toml
[tool.ruff]
line-length = 88
target-version = "py311"
src = ["src", "tests"]

[tool.ruff.lint]
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # pyflakes
    "I",    # isort
    "B",    # flake8-bugbear
    "C4",   # flake8-comprehensions
    "UP",   # pyupgrade
    "N",    # pep8-naming
    "SIM",  # flake8-simplify
]
ignore = [
    "E501",   # line too long (handled by formatter)
    "B008",   # do not perform function calls in argument defaults
]
unfixable = ["F841"]  # unused variables: don't auto-remove

[tool.ruff.lint.per-file-ignores]
"tests/**/*.py" = ["S101"]   # allow assert in tests
"__init__.py" = ["F401"]     # allow unused imports in __init__

[tool.ruff.lint.isort]
known-first-party = ["mypackage"]
force-sort-within-sections = true

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
skip-magic-trailing-comma = false
```

---

## `[tool.black]`

Black is an opinionated code formatter:

```toml
[tool.black]
line-length = 88
target-version = ["py310", "py311", "py312"]
include = '\.pyi?$'
extend-exclude = '''
/(
  migrations
  | __pycache__
)/
'''
```

---

## `[tool.isort]`

Import sorter (commonly used alongside flake8; superseded by `ruff --select I` in many projects):

```toml
[tool.isort]
profile = "black"
line_length = 88
known_first_party = ["mypackage"]
skip_glob = ["*/migrations/*"]
```

---

## `[tool.pylint]`

```toml
[tool.pylint.main]
py-version = "3.11"
jobs = 4

[tool.pylint.messages_control]
disable = [
    "missing-docstring",
    "too-few-public-methods",
]

[tool.pylint.format]
max-line-length = 88
```

---

## `[tool.bandit]`

Security linter:

```toml
[tool.bandit]
targets = ["src"]
exclude_dirs = ["tests"]
skips = ["B101"]   # skip assert warnings
```

---

## `[tool.pydantic-mypy]`

For Pydantic v1 mypy plugin support:

```toml
[tool.pydantic-mypy]
init_forbid_extra = true
init_typed = true
warn_required_dynamic_aliases = true
```

---

## `[tool.poetry]`

Poetry manages the full project lifecycle (dependencies, virtualenvs, publishing). When using Poetry as the build backend, `[project]` is not used — metadata lives under `[tool.poetry]` instead.

```toml
[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

[tool.poetry]
name = "my-package"
version = "1.0.0"
description = "A short description."
authors = ["Alice <alice@example.com>"]
license = "MIT"
readme = "README.md"
packages = [{ include = "mypackage", from = "src" }]

[tool.poetry.dependencies]
python = "^3.10"
httpx = "^0.25"
pydantic = "^2.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.0"
mypy = "^1.0"
ruff = "^0.1"

[tool.poetry.scripts]
my-cli = "mypackage.cli:main"
```

**Note:** Poetry's `[tool.poetry]` table is not PEP 621 compliant. Projects using Poetry cannot use `[project]` for metadata at the same time.

---

## `[tool.pdm]`

PDM supports PEP 621 `[project]` metadata combined with its own section for extras:

```toml
[tool.pdm.dev-dependencies]
dev = [
    "pytest>=7.0",
    "ruff",
    "mypy",
]

[tool.pdm.scripts]
test = "pytest tests/"
lint = "ruff check src/"
```

---

## Version Management

### Static version in `__init__.py`

```toml
[project]
version = "1.2.3"
```

### Dynamic version from source file

With setuptools-scm (git tags as versions):

```toml
[build-system]
requires = ["setuptools>=68", "setuptools-scm"]
build-backend = "setuptools.build_meta"

[project]
dynamic = ["version"]

[tool.setuptools_scm]
write_to = "src/mypackage/_version.py"
version_scheme = "post-release"
```

With Hatchling:

```toml
[tool.hatch.version]
path = "src/mypackage/__init__.py"
```

The file must contain `__version__ = "x.y.z"` or similar.

---

## A Complete Minimal Example

A small library using setuptools, targeting PyPI:

```toml
[build-system]
requires = ["setuptools>=68", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my-library"
version = "0.1.0"
description = "Does something useful."
readme = "README.md"
license = { text = "MIT" }
requires-python = ">=3.10"
authors = [{ name = "Alice", email = "alice@example.com" }]
keywords = ["utility", "tools"]
classifiers = [
    "Programming Language :: Python :: 3",
    "License :: OSI Approved :: MIT License",
    "Operating System :: OS Independent",
]
dependencies = [
    "httpx>=0.25",
]

[project.optional-dependencies]
dev = ["pytest", "pytest-cov", "ruff", "mypy"]

[project.scripts]
my-tool = "my_library.cli:main"

[project.urls]
Repository = "https://github.com/alice/my-library"
"Bug Tracker" = "https://github.com/alice/my-library/issues"

[tool.setuptools.packages.find]
where = ["src"]

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --strict-markers"

[tool.coverage.run]
source = ["src/my_library"]
branch = true

[tool.coverage.report]
fail_under = 80

[tool.ruff.lint]
select = ["E", "F", "I", "B", "UP"]

[tool.mypy]
strict = true
```

---

## A Complete Modern Example (Hatchling)

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "my-app"
dynamic = ["version"]
description = "A web API service."
readme = "README.md"
requires-python = ">=3.11"
license = { text = "Apache-2.0" }
authors = [{ name = "Alice", email = "alice@example.com" }]
dependencies = [
    "fastapi>=0.110",
    "pydantic>=2.5",
    "sqlalchemy>=2.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4",
    "pytest-asyncio",
    "pytest-cov",
    "httpx",
    "ruff",
    "mypy",
]

[project.urls]
Repository = "https://github.com/alice/my-app"

[tool.hatch.version]
path = "src/my_app/__init__.py"

[tool.hatch.build.targets.wheel]
packages = ["src/my_app"]

[tool.hatch.envs.default]
dependencies = ["pytest", "pytest-asyncio", "pytest-cov", "httpx"]

[tool.hatch.envs.default.scripts]
test = "pytest {args:tests}"
cov = "pytest --cov=my_app --cov-report=term-missing"

[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
addopts = "--strict-markers"

[tool.coverage.run]
source = ["src/my_app"]
branch = true

[tool.coverage.report]
fail_under = 85

[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "B", "UP", "SIM"]

[tool.mypy]
python_version = "3.11"
strict = true
```

---

## Common Mistakes

### Mixing Poetry metadata with `[project]`

Poetry uses `[tool.poetry]` for metadata. Using `[project]` and `[tool.poetry]` together for metadata in the same file is not supported and leads to conflicts.

### Wrong package discovery

If pip installs your package but Python cannot import it, check that `[tool.setuptools.packages.find]` has the correct `where` value matching your layout (`src` layout vs flat layout).

### Missing `requires-python`

Omitting `requires-python` means your package can be installed on unsupported Python versions. Always set it.

### Forgetting `dynamic`

If your build backend reads `version` from a file or git, you must declare `dynamic = ["version"]` in `[project]`, otherwise the build will fail or ignore the dynamic value.

### Using `~=` without understanding it

`~=1.4.2` means `>=1.4.2, ==1.4.*` (patch-level compatible). `~=1.4` means `>=1.4, ==1.*` (minor-level compatible). These are not equivalent.

---

## Useful References

- [PEP 517](https://peps.python.org/pep-0517/) — Build backend interface
- [PEP 518](https://peps.python.org/pep-0518/) — `[build-system]` table
- [PEP 621](https://peps.python.org/pep-0621/) — `[project]` metadata standard
- [PEP 508](https://peps.python.org/pep-0508/) — Dependency specification syntax
- [PEP 440](https://peps.python.org/pep-0440/) — Version specifiers
- [TOML spec](https://toml.io/en/v1.0.0)
- [PyPI classifiers](https://pypi.org/classifiers/)
- [packaging.python.org](https://packaging.python.org/en/latest/guides/writing-pyproject-toml/)