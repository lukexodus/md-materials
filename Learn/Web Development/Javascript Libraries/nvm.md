Node Version Manager (nvm) is an essential tool for JavaScript developers that lets you install, manage, and switch between multiple Node.js versions on the same machine. Here's everything you need to know to use it effectively.

## Installation

**On macOS/Linux:**

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
# or
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

**On Windows:** Use nvm-windows instead: download the installer from the nvm-windows GitHub releases page.

After installation, restart your terminal or run:

```bash
source ~/.bashrc
```

## Core Commands

**Installing Node versions:**

```bash
nvm install node          # Install latest version
nvm install 18            # Install latest Node 18.x
nvm install 18.17.0       # Install specific version
nvm install --lts         # Install latest LTS version
```

**Switching between versions:**

```bash
nvm use 18                # Switch to Node 18.x
nvm use 18.17.0           # Switch to specific version
nvm use node              # Switch to latest installed version
nvm use --lts             # Switch to latest LTS version
```

**Listing versions:**

```bash
nvm list                  # Show installed versions
nvm ls                    # Same as above (shorthand)
nvm list-remote           # Show all available versions online
nvm ls-remote --lts       # Show only LTS versions available
```

**Setting defaults:**

```bash
nvm alias default 18      # Set Node 18 as default for new shells
nvm alias default node   # Set latest installed as default
```

## Practical Workflow Tips

**Project-specific Node versions:** Create a `.nvmrc` file in your project root containing just the Node version:

```
18.17.0
```

Then use:

```bash
nvm use                   # Automatically uses version from .nvmrc
```

**Automatic version switching:** Add this to your shell profile to auto-switch when entering directories with `.nvmrc`:

```bash
# Add to ~/.bashrc or ~/.zshrc
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
```

## Managing npm Packages

**Understanding package isolation:** Each Node version has its own npm and global packages. When you switch Node versions, your globally installed packages don't carry over.

**Migrating packages between versions:**

```bash
nvm install 18 --reinstall-packages-from=16  # Install Node 18 and copy global packages from Node 16
```

**Checking current environment:**

```bash
nvm current               # Show currently active version
which node               # Show path to current Node executable
which npm                # Show path to current npm executable
```

## Advanced Usage

**Using specific versions temporarily:**

```bash
nvm exec 16 node app.js   # Run a command with Node 16 without switching
nvm run 16 app.js         # Same as above
```

**Uninstalling versions:**

```bash
nvm uninstall 16.14.0     # Remove specific version
```

**Working with different shells:**

```bash
nvm use 18                # Only affects current shell session
```

Each terminal window/tab maintains its own Node version until you explicitly switch or set a default.

## Common Scenarios

**Starting a new project:**

1. Check project requirements for Node version
2. Install required version: `nvm install 18.17.0`
3. Create `.nvmrc` file with the version
4. Switch to it: `nvm use`

**Working on multiple projects:**

1. Navigate to project directory
2. Run `nvm use` (reads from `.nvmrc`)
3. Verify with `node --version`

**Updating Node versions:**

1. Check for new releases: `nvm ls-remote --lts`
2. Install newer version: `nvm install 18.18.0`
3. Test your applications
4. Update `.nvmrc` files in projects
5. Optionally uninstall old versions

## Troubleshooting

**Command not found after installation:**

- Restart terminal or source your shell profile
- Check if nvm is in your PATH
- Verify installation with `command -v nvm`

**Slow nvm commands:**

- Use `nvm use --silent` to reduce output
- Consider using faster alternatives like `fnm` for large teams

**npm permission issues:**

- Don't use `sudo` with npm when using nvm
- nvm handles permissions automatically for each Node version

This workflow makes managing Node.js versions seamless across different projects and ensures your development environment matches production requirements. The key is consistently using `.nvmrc` files and understanding that each Node version is completely isolated from others.