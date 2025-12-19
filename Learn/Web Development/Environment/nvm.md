# Syllabus

## Module 1: Fundamentals

- What is nvm
- Why use a Node version manager
- nvm vs other version managers (n, fnm, asdf, volta)
- System requirements
- Architecture overview
- nvm limitations and considerations

## Module 2: Installation

- Installing nvm on macOS
- Installing nvm on Linux
- Installing nvm on Windows (WSL)
- nvm-windows alternative
- Installation via curl
- Installation via wget
- Installation via git clone
- Verifying installation

## Module 3: Shell Integration

- Bash profile configuration
- Zsh profile configuration
- Fish shell configuration
- Adding nvm to PATH
- Shell startup performance
- Lazy loading nvm
- Custom shell prompts with Node version

## Module 4: Basic Commands

- nvm --version
- nvm --help
- nvm ls (list installed versions)
- nvm ls-remote (list available versions)
- nvm install
- nvm uninstall
- nvm use
- nvm current

## Module 5: Installing Node Versions

- Installing specific versions
- Installing latest LTS
- Installing latest stable
- Installing from .nvmrc file
- Installing with npm bundled
- Installing without npm
- Installing multiple versions simultaneously

## Module 6: Version Aliasing

- Creating custom aliases
- Default alias
- Stable alias
- System alias
- LTS aliases (lts/*, lts/iron, lts/hydrogen)
- Node version naming conventions
- Managing multiple aliases

## Module 7: Switching Node Versions

- Switching with nvm use
- Temporary vs persistent switching
- Switching to system Node
- Switching to aliased versions
- Switching to LTS versions
- Switching in different shell sessions

## Module 8: .nvmrc Files

- Creating .nvmrc files
- .nvmrc file format
- .nvmrc with specific versions
- .nvmrc with aliases
- .nvmrc with LTS versions
- Automatic version switching
- Project-level version management

## Module 9: Automatic Version Switching

- Shell integration for auto-switching
- Using nvm use automatically
- avn (Automatic Version Switching for Node)
- Calling nvm use on cd
- Zsh hook functions
- Bash hook functions
- Directory-based version switching

## Module 10: Default Node Version

- Setting default Node version
- nvm alias default
- System default vs nvm default
- Resetting to system default
- Default version across shell sessions

## Module 11: Global npm Packages

- Global package behavior with nvm
- Reinstalling global packages
- nvm reinstall-packages
- Migrating globals between versions
- Managing globals per Node version
- Default global packages

## Module 12: Version Resolution

- Version string patterns
- Partial version matching
- Wildcard usage
- Latest version resolution
- LTS version resolution
- Version sorting and selection

## Module 13: Remote Version Management

- Listing remote versions
- Filtering remote versions
- Searching for specific versions
- Remote LTS versions
- Remote version metadata
- Custom remote sources

## Module 14: Uninstalling and Cleanup

- Uninstalling specific versions
- Uninstalling multiple versions
- Cleanup unused versions
- Reclaiming disk space
- Removing nvm completely
- Cache management

## Module 15: nvm Configuration

- NVM_DIR environment variable
- Custom installation directory
- Configuration file options
- Mirror configuration
- Custom download sources
- Proxy configuration

## Module 16: Advanced Installation Options

- Installing from source
- Installing specific architectures (ARM, x64)
- Installing with custom flags
- Building from source
- Installing release candidates
- Installing nightly builds

## Module 17: Performance Optimization

- Lazy loading strategies
- Startup time optimization
- Reducing PATH pollution
- Caching strategies
- Faster shell initialization
- Alternative loading methods

## Module 18: Multi-User Environments

- System-wide installation considerations
- Per-user installations
- Shared nvm directories
- Permission management
- Team environment setup
- Docker container usage

## Module 19: CI/CD Integration

- Using nvm in CI pipelines
- GitHub Actions with nvm
- GitLab CI with nvm
- Travis CI with nvm
- CircleCI with nvm
- Jenkins with nvm
- Caching in CI

## Module 20: Docker Integration

- nvm in Dockerfiles
- Multi-stage builds with nvm
- Node version management in containers
- Base image alternatives
- Container optimization
- Production container patterns

## Module 21: Troubleshooting

- Common installation errors
- Shell configuration issues
- Permission errors
- Command not found errors
- Version switching failures
- PATH conflicts
- Network and download issues

## Module 22: Migration Strategies

- Migrating from system Node
- Migrating from other version managers
- Migrating between machines
- Exporting and importing configurations
- Team migration strategies
- Rollback procedures

## Module 23: Windows Considerations

- nvm-windows differences
- WSL vs native Windows
- PowerShell integration
- Command Prompt integration
- Windows-specific commands
- Path handling on Windows
- Permission issues on Windows

## Module 24: Alternative Version Managers

- Comparing with fnm (Fast Node Manager)
- Comparing with n
- Comparing with asdf-nodejs
- Comparing with volta
- Comparing with nodenv
- Migration between version managers
- Choosing the right tool

## Module 25: Best Practices

- Version pinning strategies
- Team collaboration patterns
- Documentation practices
- Semantic versioning adherence
- Security update practices
- Deprecation handling
- Long-term version support

## Module 26: Scripting and Automation

- Scripting with nvm commands
- Automated version switching scripts
- npm scripts with nvm
- Pre-commit hooks with nvm
- Automated testing across versions
- Deployment automation

## Module 27: Debugging nvm

- Verbose mode
- Debugging installation issues
- Tracing version resolution
- Logging and diagnostics
- Shell debugging techniques
- nvm internals understanding

## Module 28: Security Considerations

- Verifying downloaded binaries
- Checksum verification
- HTTPS vs HTTP downloads
- Trusted sources
- Security updates
- Vulnerability management

## Module 29: Custom Builds and Patches

- Building Node from source with nvm
- Applying custom patches
- Custom compilation flags
- Platform-specific optimizations
- Debug builds
- Development builds

## Module 30: Integration with Development Tools

- IDE integration (VS Code, WebStorm)
- Terminal integration
- Package manager integration
- Build tool integration
- Task runner compatibility
- Development workflow optimization

## Module 31: Maintenance and Updates

- Updating nvm itself
- Checking for nvm updates
- Upgrade procedures
- Backward compatibility
- Breaking changes handling
- Version lifecycle management

## Module 32: Community and Ecosystem

- nvm GitHub repository
- Contributing to nvm
- Issue reporting
- Community plugins
- Third-party tools
- Documentation resources