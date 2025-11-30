## Overview

mise (pronounced "meez") is a polyglot tool version manager that replaces tools like asdf, nvm, pyenv, and rbenv. The name "mise-en-place" refers to a French culinary phrase meaning "setup" or "put in place" - the idea that before cooking, you should have all utensils and ingredients ready.

mise was originally developed by Jeff Dickey under the name rtx (Rust ToolX) and was later renamed to mise. It's built in Rust as a single executable, which contributes to its performance.

## Core Functionality

mise provides three main categories of functionality:

### 1. **Tool Version Management**
mise installs and manages dev tools/runtimes like node, python, or terraform, allowing you to specify which version of these tools to use in different projects. It supports hundreds of dev tools and can manage multiple versions of Node.js, Python, Ruby, Go, etc. on the same machine.

### 2. **Environment Variable Management**
mise allows you to switch sets of environment variables in different project directories and can replace direnv. This lets you specify configuration like AWS_ACCESS_KEY_ID that may differ between projects.

### 3. **Task Runner**
mise is a task runner that can replace make or npm scripts. mise tasks are now out of experimental status and provide a way to define scripts for projects, serving as an alternative to Makefiles, shell scripts, or tools like just and Task.

## Configuration

Using its .mise.toml config file, you'll have a consistent way to setup and interact with your projects no matter what language they're written in. Example configuration:

```toml
[tools]
node = "20"
python = "3.11"
terraform = "1.5"
```

mise is also compatible with asdf .tool-versions files as well as idiomatic version files like .node-version and .ruby-version.

mise supports nested configuration that cascades from broad to specific settings across global defaults, work-specific tools, and project-specific overrides.

## Installation & Activation

After installation, you need to activate mise in your shell by adding an activation command to your shell configuration file:

```bash
# For bash
echo 'eval "$(mise activate bash)"' >> ~/.bashrc

# For zsh
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
```

After activating, mise will update env vars like PATH whenever the directory is changed or the prompt is displayed.

## Using Tools

### Installing Tools
mise install will download/build/compile the tool into ~/.local/share/mise/installs. Key commands:

- `mise install node` - install the node version specified in mise.toml
- `mise install` - install all plugins and tools specified in config files

[Inference] If you're migrating from asdf, mise appears to automatically install plugins when needed, unlike asdf which requires manual plugin installation first.

### Running Commands
mise x can be used for one-off commands using specific tools. For example: `mise x python@3.12 -- script.py` would run a script with Python 3.12.

mise supports shorthand syntax for running tasks - instead of `mise run build`, you can use `mise build`.

## Performance

The performance improvement is tangible, and mise has more automatic features with less configuration overhead than alternatives like nvm. mise modifies PATH ahead of time so the runtimes are called directly, meaning calling a tool has zero overhead.

mise uses caching for version lists, installation artifacts, environment resolution, and plugin metadata to add minimal latency to your development workflow.

## Integration Methods

mise provides several integration approaches:

1. **Automatic Activation**: With mise activate, mise hooks into your shell prompt and automatically updates your environment when you change directories

2. **On-Demand Execution**: Use mise exec to run commands with mise's environment without permanent activation

3. **Shims**: mise can create lightweight wrapper scripts that automatically use the correct tool versions

## Essential Commands

### Installation & Setup

After installing mise, you need to hook it into your shell by adding an activation command to your shell configuration file:

```bash
# For bash
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc

# For zsh
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc

# For fish
echo '~/.local/bin/mise activate fish | source' >> ~/.config/fish/config.fish
```

After activation, restart your terminal or source your shell configuration. You can run `mise dr|doctor` to verify that mise is correctly installed and activated.

---

## Managing Tools

### 1. **`mise use` - Install and Activate Tools**

`mise use` is the primary command for tool management, performing: version installation if not present, setting the version as active by updating PATH, and updating the current configuration file.

```bash
# Interactive tool selector
mise use

# Install and activate node 20.x in current project
mise use node@20

# Install globally (updates ~/.config/mise/config.toml)
mise use -g node@20

# Use latest version
mise use node@latest

# Install multiple tools at once
mise use node@20 python@3.11 terraform@1.5
```

**Version Specifications:**
- By default, mise uses loose versions (like `node = "22"`), which allows flexibility for other team members
- Use `--fuzzy` flag to save fuzzy versions (e.g., `20` instead of `20.0.0`), which is the default behavior unless `MISE_PIN=1`
- Use `--pin` flag to save exact versions (e.g., `20.0.0`)
- If you leave out the version, mise will default to `@latest`

**Configuration Files:**
By default, `mise use` updates `mise.toml` in the current directory. If `--global` is set, it uses the global config file. If `--env` is set, it uses `mise.<env>.toml`.

### 2. **`mise install` - Install Without Activating**

`mise install` will download/build/compile tools into `~/.local/share/mise/installs` but won't activate them without setting the version in a mise.toml or .tool-versions file.

```bash
# Install specific version
mise install node@20.0.0

# Install version matching a prefix
mise install node@20

# Install the version specified in config
mise install node

# Install all tools from config files
mise install

# Install tools from different backends
mise install cargo:ripgrep
mise install npm:prettier
mise install github:BurntSushi/ripgrep
```

### 3. **`mise ls` - List Installed Tools**

`mise ls` lists all installed runtime versions.

```bash
# List all installed tools
mise ls

# List specific tool
mise ls node
```

To find out which configuration provides a tool or task, run `mise ls`.

### 4. **`mise ls-remote` - List Available Versions**

`mise ls-remote` displays versions available for installation, including stable releases, LTS versions, and nightly builds.

```bash
# List all available node versions
mise ls-remote node

# Filter results (example using grep)
mise ls-remote node | grep "20"
```

### 5. **`mise upgrade` - Update Tool Versions**

By default, `mise upgrade` respects the version prefix in mise.toml. If a lockfile exists, mise will update mise.lock to the latest version of the tool with the prefix from mise.toml.

```bash
# Upgrade tools respecting version prefix
mise upgrade

# Upgrade specific tool
mise upgrade node

# Upgrade to latest major version (ignoring prefix)
mise upgrade --bump node

# Interactive upgrade menu
mise up --interactive
```

### 6. **`mise exec` - Run Commands with Tools**

`mise exec` is a powerful way to load the current mise context (tools & environment variables) without modifying your shell session or running ad-hoc commands with mise tools set.

```bash
# Run Python 3 REPL
mise exec python@3 -- python

# Run command with specific node version
mise exec node@20 -- node app.js

# Run with tools from config (shorthand: mise x)
mise x -- npm install

# Run multiple commands with same context
mise x node@22 -- node -v
```

### 7. **`mise current` - View Active Environment**

`mise current` shows the current environment configuration.

```bash
# View currently active tool versions
mise current
```

### 8. **`mise prune` - Clean Up Unused Versions**

`mise prune` deletes unused versions of tools.

```bash
# Remove unused tool versions
mise prune
```

### 9. **`mise outdated` - Check for Updates**

`mise outdated` shows outdated tool versions.

```bash
# List outdated tools
mise outdated
```

---

## Configuration Files

### Configuration Hierarchy

mise supports nested configuration that cascades from broad to specific settings: `~/.config/mise/config.toml` for global defaults, `~/work/mise.toml` for work-specific tools, `~/work/project/mise.toml` for project-specific overrides, and `~/work/project/.tool-versions` for legacy asdf compatibility.

Configuration files are merged in order, with more specific (closer to your current directory) settings overriding broader ones, and environment-specific configs like `mise.dev.toml` are applied if `MISE_ENV` is set.

### File Types

**1. `mise.toml` (or `.mise.toml`)** - Main project configuration that should be committed to version control and contains the common toolset needed for your project.

**2. `mise.local.toml` (or `.mise.local.toml`)** - For tools or settings you want to keep private. This file should be added to .gitignore and is perfect for personal preferences or configurations.

**3. `mise.<env>.toml`** - Environment-specific config files like `.mise.staging.toml` are used if `MISE_ENV=staging`.

**4. `.tool-versions`** - asdf's config file that can be used in mise for compatibility, though mise.toml is recommended as it's more flexible.

### Example `mise.toml` Configuration

```toml
[tools]
node = "20"              # Fuzzy version
python = "3.11"
terraform = "1.5"
"cargo:ripgrep" = "latest"
"npm:prettier" = "3"

[env]
NODE_ENV = "development"
DATABASE_URL = "postgres://localhost/mydb"
AWS_REGION = "us-west-2"

[tasks.build]
description = "Build the project"
run = "npm run build"

[tasks.test]
description = "Run tests"
depends = ["build"]
run = "npm test"
```

### Configuration Commands

Use `mise config ls` to see the configuration files currently used by mise.

```bash
# List active config files
mise config ls

# View settings
mise settings

# Set a setting
mise settings key=value
```

---

## Environment Variables

You can set environment variables in mise.toml which will be set if mise is activated or if `mise x|exec` is used in a directory.

```toml
[env]
NODE_ENV = "production"
API_KEY = "secret123"
```

You can mark environment variables as required by setting `required = true`, ensuring the variable is defined either before mise runs or in a later config file like mise.local.toml:

```toml
[env]
DATABASE_URL = { required = "Set DATABASE_URL to your PostgreSQL connection string" }
API_KEY = { required = true }
```

Source an external bash script and pull exported environment variables from it:

```toml
[env]
_.source = "./scripts/env.sh"
```

---

## Tasks

You can define simple tasks in mise.toml and run them with `mise run`.

### Defining Tasks

Tasks are paired with usage which provides features for documenting and running tasks.

```toml
[tasks.build]
description = "Build the project"
run = "npm run build"

[tasks.test]
description = "Run tests"
depends = ["build"]
run = "npm test"

[tasks.deploy]
description = "Deploy to production"
run = """
npm run build
rsync -av dist/ server:/var/www/
"""
dir = "{{config_root}}"
```

When you run `mise run test`, mise automatically executes `build` first due to the dependency.

### Running Tasks

`mise run` sets up the mise environment before running the task, including tools and environment variables, so even without activating mise in your shell, tasks will have the tools in PATH and environment variables from mise.toml set.

```bash
# Run a task
mise run build

# Shorthand (if task name doesn't conflict with command)
mise build

# Watch mode - run repeatedly when files change
mise watch build
```

### Task Arguments

Tasks can accept options passed as environment variables prefixed with `usage_`. Help is available with `mise run <task> --help` and completions work as expected.

---

## Common Workflows

### Project Setup

Place `.mise.toml` in the root of your Git repository to define tools and tasks for the entire repository. Add `mise install` instruction to README.md so teammates can run it to get the same toolset.

```bash
# In project directory with .mise.toml
cd ~/my-project

# Install all tools
mise install

# Tools are now available
node --version
python --version
```

### Multiple Projects with Different Versions

mise automatically switches environments based on the directory you're in, detecting the nearest `.mise.toml` file:

```bash
# Project 1 uses Node 18
cd ~/projects/app1
mise use node@18

# Project 2 uses Node 20
cd ~/projects/app2
mise use node@20

# Automatically switches when changing directories
cd ~/projects/app1
node --version  # v18.x.x

cd ~/projects/app2
node --version  # v20.x.x
```

### Global vs Local Configuration

```bash
# Set global default
mise use -g node@20

# Override in specific project
cd ~/my-project
mise use node@18

# Global setting is used unless overridden
cd ~
node --version  # v20.x.x

cd ~/my-project
node --version  # v18.x.x
```

---

## Tool Backends

Tools are installed with various backends like asdf, ubi, or vfox. You can also use other backends like npm or cargo which can install any package from their respective registries:

```bash
# Core tools (shorthand)
mise use node@20
mise use python@3.11

# Cargo packages
mise use cargo:ripgrep

# NPM packages
mise use npm:prettier

# GitHub releases
mise use github:BurntSushi/ripgrep

# Go packages
mise use go:github.com/containerscrew/tftools

# Pipx (Python tools)
mise use pipx:detect-secrets
```

See registry for the full list of shorthands you can use:

```bash
# List available tools in registry
mise registry
```

---

## Advanced Features

### Lockfiles

When lockfile setting is enabled, mise will update mise.lock files next to mise.toml files containing pinned versions. When installing tools, mise will reference this lockfile if it exists to resolve versions.

Lockfiles are not created automatically. To generate them, run: `touch mise.lock && mise install`.

### Environment-Specific Configs

`MISE_ENV` enables profile-specific config files like `.mise.development.toml`. Use this for different env vars or different tool versions in development/staging/production environments.

```bash
# Set environment
export MISE_ENV=staging

# Now mise will use .mise.staging.toml
mise use node@18
```

### Shims

Shims are symlinks to the mise binary that intercept commands and load the appropriate environment. For interactive shells, `mise activate` is recommended. In non-interactive sessions like CI/CD, IDEs, and scripts, shims might work best.

```bash
# Generate shims
mise reshim
```

---

## Important Commands Summary

Here are the most important commands available in mise: `mise completion` for shell completions, `mise cfg|config` for working with mise.toml files via CLI, `mise x|exec` to execute commands in the mise environment without activating mise, `mise g|generate` to generate things like git hooks and task documentation, `mise plugin` for managing plugins, `mise r|run` to run tasks, `mise self-update` to update mise, and `mise settings` for CLI access to get/set configuration settings.

### Quick Reference

```bash
# Check version
mise --version

# Get help
mise help
mise help <command>

# Shell completion setup
mise completion bash > ~/.bash_completion.d/mise

# Update mise itself (don't use if installed via package manager)
mise self-update

# Check mise health
mise doctor
```

---

## Settings

Settings can be configured via `mise settings key=value`, by directly modifying `~/.config/mise/config.toml` or local config, or via environment variables.

Key settings include:

`jobs` controls how many jobs to run concurrently such as tool installs, `lockfile` enables lockfile support, `not_found_auto_install` automatically installs missing tool versions, `task_output` controls task output formatting, `experimental` enables experimental features, and `env_file` loads env vars from a dotenv file.

Example global config:

```toml
# ~/.config/mise/config.toml
[settings]
jobs = 4
experimental = true
not_found_auto_install = true
lockfile = true

[tools]
# Global tools available everywhere
node = "20"
```

---

This guide covers the essential usage patterns of mise. For more detailed information about specific features, you can consult the official documentation at https://mise.jdx.dev.