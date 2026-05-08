# Comprehensive Guide to uv

uv is a fast Python package and project manager written in Rust, built by Astral (the team behind Ruff). It replaces a fragmented set of tools — pip, pip-tools, pyenv, virtualenv, and pipx — with a single binary. It requires no prior Python installation and supports macOS, Linux, and Windows.

---

## What uv Replaces

Before uv, a typical Python setup required combining multiple tools:

- **pyenv** — managing Python versions
- **virtualenv / venv** — creating isolated environments
- **pip** — installing packages
- **pip-tools** — compiling and locking dependencies
- **pipx** — running and installing CLI tools

uv handles all of these in one CLI. It also introduces a universal cross-platform lockfile (`uv.lock`) that none of the above tools provided natively.

---

## Installation

### macOS and Linux

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Windows (PowerShell)

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### Via pip (if Python is already installed)

```bash
pip install uv
```

### Via Homebrew

```bash
brew install uv
```

uv ships as a standalone binary. You do not need Python or Rust installed to use it.

---

## Python Version Management

uv can download and manage Python versions independently of your system Python.

### Installing Python versions

```bash
uv python install 3.12
uv python install 3.12 3.13 3.14   # install multiple at once
```

Python distributions come from the Astral `python-build-standalone` project, since CPython does not publish official distributable binaries.

### Listing available and installed versions

```bash
uv python list
```

### Pinning a version for a project

```bash
uv python pin 3.11
```

This writes a `.python-version` file to the project root. uv uses this file when creating environments for the project.

### Using a specific version for a one-off command

```bash
uv run --python 3.10 -- python --version
uv run --python pypy@3.8 -- python --version
```

### Auto-download behavior

By default, uv automatically downloads the required Python version if one is not present. To disable this:

```bash
uv run --no-managed-python python script.py
```

Or set the environment variable `UV_PYTHON_DOWNLOADS=never`.

### Upgrading patch versions (preview feature)

```bash
uv python upgrade 3.12
```

> **Note:** Python upgrade support is listed as a preview feature in uv's documentation. Behavior may change in future releases.

---

## Project Management

### Initializing a project

```bash
uv init my-project
cd my-project
```

This creates:

```
my-project/
├── .gitignore
├── .python-version
├── README.md
├── main.py
└── pyproject.toml
```

The first time you run a project command (`uv run`, `uv sync`, or `uv lock`), uv also creates:

```
├── .venv/
└── uv.lock
```

### Project structure files

**`pyproject.toml`** — Contains project metadata and declared dependencies. Example:

```toml
[project]
name = "my-project"
version = "0.1.0"
description = "Add your description here"
readme = "README.md"
dependencies = []
```

**`.python-version`** — Specifies the Python version for the project environment.

**`uv.lock`** — A cross-platform lockfile with exact resolved versions. It is human-readable TOML but should not be edited manually.

---

## Managing Dependencies

### Adding a package

```bash
uv add requests
uv add 'requests==2.31.0'           # specific version
uv add git+https://github.com/psf/requests  # from Git
```

`uv add` updates both `pyproject.toml` and `uv.lock`, and installs into the project environment.

### Adding development dependencies

```bash
uv add --dev pytest
uv add --dev ruff black
```

### Removing a package

```bash
uv remove requests
```

### Syncing the environment from the lockfile

```bash
uv sync
```

This installs all dependencies declared in `uv.lock`. Use `--no-dev` to exclude development dependencies:

```bash
uv sync --no-dev
```

### Locking without syncing

```bash
uv lock
```

Resolves and writes `uv.lock` without modifying the environment.

### Upgrading dependencies

```bash
uv add --upgrade requests              # upgrade a specific package
uv lock --upgrade                      # upgrade all packages
```

### Importing from requirements.txt

```bash
uv add -r requirements.txt -c constraints.txt
```

### Exporting to requirements.txt

```bash
uv export --format requirements-txt > requirements.txt
```

### Viewing the dependency tree

```bash
uv tree
```

---

## Running Commands

### Running a script or command in the project environment

```bash
uv run python main.py
uv run pytest
uv run -- gunicorn app:app
```

uv automatically keeps the environment in sync before running.

### Running without syncing extraneous packages

By default, `uv run` does not remove packages absent from the lockfile. To force a clean sync first, use `uv sync` explicitly before running.

---

## Virtual Environments

### Creating a virtual environment manually

```bash
uv venv
uv venv --python 3.12
uv venv .my-env                  # custom path
```

### Activating

```bash
# macOS/Linux (bash/zsh)
source .venv/bin/activate

# Windows (PowerShell)
.venv\Scripts\Activate.ps1
```

When a virtual environment is active, standard Python commands (`python`, `pip`) use it directly, without needing `uv run`.

---

## The pip Interface

uv provides a drop-in pip-compatible interface for users who want faster package installation without changing their workflow.

```bash
uv pip install requests
uv pip install -r requirements.txt
uv pip uninstall requests
uv pip freeze
uv pip list
uv pip show requests
```

### Compiling a requirements file (pip-tools replacement)

```bash
uv pip compile requirements.in --universal --output-file requirements.txt
```

### Syncing from a compiled requirements file

```bash
uv pip sync requirements.txt
```

The `--universal` flag produces a platform-independent resolution — a capability that pip-tools did not offer by default.

---

## Inline Script Dependencies

uv can manage dependencies for single-file scripts using inline metadata (PEP 723).

### Adding metadata to a script

```bash
uv add --script example.py requests
```

This embeds a `[script]` metadata block into `example.py`.

### Running the script in an isolated environment

```bash
uv run example.py
```

uv reads the inline metadata and installs the declared dependencies into a temporary environment before running.

### Running with additional ad-hoc dependencies

```bash
uv run --with rich example.py
```

---

## Tools (pipx replacement)

uv can run and install Python CLI tools without polluting project environments.

### Running a tool in a temporary environment (uvx)

```bash
uvx ruff check .
uvx pycowsay 'hello'
```

`uvx` is an alias for `uv tool run`. The environment is created, used, and discarded.

### Installing a tool globally

```bash
uv tool install ruff
uv tool install black
```

Installed tools are available on `PATH` without activating any environment.

### Listing and upgrading tools

```bash
uv tool list
uv tool upgrade ruff
uv tool upgrade --all
```

### Uninstalling a tool

```bash
uv tool uninstall ruff
```

---

## Workspaces (Monorepos)

Workspaces let you manage multiple related packages under a single root with one shared lockfile. The concept is similar to Cargo workspaces in Rust.

### Defining a workspace

In the root `pyproject.toml`:

```toml
[tool.uv.workspace]
members = ["packages/*"]
```

Each member is a directory with its own `pyproject.toml`. uv locks and resolves all members together as a single unit.

### Running a command in a specific workspace member

```bash
uv run --package my-lib pytest
```

### Configuration scope

Configuration in workspace member `pyproject.toml` files is ignored; only the workspace root configuration applies.

---

## Building and Publishing

### Building distributions

```bash
uv build
```

This produces a wheel and a source distribution in `dist/`:

```
dist/
├── my-project-0.1.0-py3-none-any.whl
└── my-project-0.1.0.tar.gz
```

The default build backend (as of mid-2025) is `uv_build`. Earlier versions used Hatchling. Either way, the output is compatible with pip and any PEP 517-compliant tool.

### Publishing to PyPI

```bash
uv publish
```

You will be prompted for credentials, or you can set `UV_PUBLISH_TOKEN`.

### Reading and bumping the project version

```bash
uv version                   # print current version
uv version 1.2.0             # set version explicitly
uv version --bump minor      # bump minor component
```

---

## Configuration

### `pyproject.toml` (project-level)

uv reads configuration from `[tool.uv]` in `pyproject.toml`:

```toml
[tool.uv]
index-url = "https://pypi.org/simple"
```

### `uv.toml` (project-level override)

`uv.toml` uses the same keys but without the `[tool.uv]` prefix:

```toml
index-url = "https://pypi.org/simple"
```

If both `uv.toml` and `pyproject.toml` are present, `uv.toml` takes precedence and the `[tool.uv]` section in `pyproject.toml` is ignored.

### User-level configuration

A global config file can be placed at:

- **macOS/Linux:** `~/.config/uv/uv.toml`
- **Windows:** `%APPDATA%\uv\uv.toml`

### Environment variables

uv respects environment variables that mirror CLI flags. Key ones:

|Variable|Effect|
|---|---|
|`UV_PYTHON`|Python version to use|
|`UV_PYTHON_DOWNLOADS`|`auto` (default), `never`, `manual`|
|`UV_PROJECT_ENVIRONMENT`|Override virtual environment path|
|`UV_COMPILE_BYTECODE`|Pre-compile `.pyc` files on install|
|`UV_LINK_MODE`|How packages are linked (`copy`, `hardlink`, `symlink`)|
|`UV_CACHE_DIR`|Override cache location|
|`UV_NO_CACHE`|Disable cache|
|`UV_PUBLISH_TOKEN`|PyPI token for publishing|

---

## Caching

uv uses a global cache to deduplicate packages across projects. If two projects depend on the same package version, it is stored once on disk.

### Cache location

- **macOS:** `~/Library/Caches/uv`
- **Linux:** `~/.cache/uv`
- **Windows:** `%LOCALAPPDATA%\uv\cache`

### Cache commands

```bash
uv cache dir          # print cache path
uv cache clean        # remove all cached data
uv cache prune        # remove unused entries only
```

---

## Docker Integration

### Minimal Dockerfile

```dockerfile
FROM python:3.12-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project

COPY . /app

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked
```

### Recommended environment variables in Docker

```dockerfile
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON=python3.12 \
    UV_PROJECT_ENVIRONMENT=/app
```

- `UV_COMPILE_BYTECODE=1` — pre-compiles `.pyc` files for faster startup
- `UV_LINK_MODE=copy` — uses copies instead of hard links (required in some container filesystems)
- `UV_PYTHON_DOWNLOADS=never` — prevents uv from downloading Python inside the container

### Workspace Docker considerations

When using workspaces, the initial sync should use `--frozen` (skips lockfile validation) and `--no-install-workspace` (excludes workspace members until their source is copied):

```dockerfile
RUN uv sync --frozen --no-install-workspace
COPY . /app
RUN uv sync --locked
```

### Installing into system Python (no venv)

In containers, you can skip creating a virtual environment by targeting the system environment:

```bash
uv pip install --system .
```

Or by setting `UV_PROJECT_ENVIRONMENT` to the system prefix (e.g. `/usr/local`).

---

## CI Integration

### GitHub Actions

```yaml
- name: Install uv
  uses: astral-sh/setup-uv@v5

- name: Install dependencies
  run: uv sync --locked

- name: Run tests
  run: uv run pytest
```

The `--locked` flag causes uv to fail if `uv.lock` is out of date, catching drift between the lockfile and `pyproject.toml`.

### General CI principles

Always commit `uv.lock` to version control. This ensures every CI run and deployment uses the exact same resolved versions. Use `uv sync --locked` (fails on mismatch) rather than `uv sync --frozen` (skips the check) unless you have a specific reason.

---

## Migration from Other Tools

### From pip + requirements.txt

```bash
# Create a project
uv init

# Import existing requirements
uv add -r requirements.txt

# Run your code
uv run python app.py
```

### From pip-tools

Replace `pip-compile` with:

```bash
uv pip compile requirements.in --universal -o requirements.txt
```

Replace `pip-sync` with:

```bash
uv pip sync requirements.txt
```

### From Poetry

Poetry projects use `pyproject.toml` with Poetry-specific sections. Migration steps:

1. Run `uv init` (or skip if `pyproject.toml` already exists).
2. Ensure your `pyproject.toml` uses standard `[project]` metadata (PEP 621). Poetry 2.0 added this; earlier versions used `[tool.poetry]` only.
3. Run `uv add` for each dependency, or manually move them to `[project].dependencies`.
4. Run `uv lock` to generate `uv.lock`.
5. Remove `poetry.lock` and `[tool.poetry]` sections once satisfied.

### From pyenv

`uv python install` and `uv python pin` replace `pyenv install` and `pyenv local`. The `.python-version` file format is compatible.

---

## Common Errors and Fixes

### "No project table found"

Occurs when running `uv add` or `uv sync` in a directory without a valid `[project]` section in `pyproject.toml`.

Fix: Run `uv init` first, or add a `[project]` table manually.

### "Lockfile is out of date"

Occurs with `uv sync --locked` when `pyproject.toml` has changed but `uv.lock` has not been regenerated.

Fix: Run `uv lock` to update the lockfile, then commit it.

### "No virtual environment found" (in Docker)

Occurs when uv commands are run in a container before a virtual environment exists.

Fix: Run `uv venv` explicitly first, or use `uv pip install --system` to bypass the venv requirement.

### Python version not found

Occurs when a `.python-version` file specifies a version uv has not downloaded.

Fix: Run `uv python install <version>`, or set `UV_PYTHON_DOWNLOADS=auto` to allow automatic downloads.

---

## Quick Reference

```bash
# Installation
curl -LsSf https://astral.sh/uv/install.sh | sh

# Python versions
uv python install 3.12
uv python pin 3.11
uv python list

# Projects
uv init my-project
uv add requests
uv add --dev pytest
uv remove requests
uv sync
uv sync --locked
uv lock
uv run pytest
uv tree
uv version --bump minor

# pip interface
uv pip install requests
uv pip compile requirements.in -o requirements.txt
uv pip sync requirements.txt

# Scripts
uv run script.py
uv run --with requests script.py

# Tools
uvx ruff check .
uv tool install ruff
uv tool list
uv tool upgrade --all

# Cache
uv cache clean
uv cache prune

# Build and publish
uv build
uv publish
```