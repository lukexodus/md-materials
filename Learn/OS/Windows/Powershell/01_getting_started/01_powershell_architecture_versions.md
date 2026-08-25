## PowerShell Architecture & Versions


### Windows PowerShell vs PowerShell Core vs PowerShell 7+

**Windows PowerShell** represents the original implementation built exclusively for Windows systems. Version 5.1, released in 2016, serves as the final major release of Windows PowerShell and comes pre-installed on Windows 10 and Windows Server 2016 or later. This version runs on the full .NET Framework and provides deep integration with Windows-specific APIs, COM objects, and WMI capabilities.

**PowerShell Core** emerged as Microsoft's cross-platform initiative, built on .NET Core framework. Versions 6.0 through 6.2 constituted this branch, designed to run on Windows, Linux, and macOS. However, PowerShell Core sacrificed some Windows-specific functionality to achieve cross-platform compatibility, creating a feature gap compared to Windows PowerShell.

**PowerShell 7+** represents the unified approach, combining the best aspects of both predecessors. Built on .NET Core (later .NET 5+), PowerShell 7 restored most Windows PowerShell compatibility while maintaining cross-platform support. The version numbering jumped from 6.2 to 7.0 to signal this convergence and the intent to replace both earlier branches.

**Key points:**

- Windows PowerShell 5.1: Windows-only, full .NET Framework, maximum Windows integration
- PowerShell Core 6.x: Cross-platform, .NET Core, reduced Windows functionality
- PowerShell 7+: Cross-platform, .NET Core/5+, restored Windows compatibility

### Installation and Setup

#### Windows Installation

Windows 10 and Windows Server 2016 or later include Windows PowerShell 5.1 by default. For PowerShell 7+, users must download and install it separately from Microsoft's GitHub releases or through package managers.

**Installation methods for PowerShell 7+ on Windows:**

- MSI installer from GitHub releases
- Windows Package Manager: `winget install Microsoft.PowerShell`
- Chocolatey: `choco install powershell-core`
- Scoop: `scoop install pwsh`

#### Linux Installation

Linux distributions require manual installation of PowerShell 7+. Microsoft provides packages for major distributions and maintains repositories for automatic updates.

**Ubuntu/Debian installation:**

```bash
# Download Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell
```

**Red Hat/CentOS/Fedora installation:**

```bash
# Register Microsoft repository
curl https://packages.microsoft.com/config/rhel/8/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
sudo dnf install powershell
```

#### macOS Installation

macOS users can install PowerShell 7+ through Homebrew or direct download from GitHub releases.

**Homebrew installation:**

```bash
brew install --cask powershell
```

**Key points:**

- Windows PowerShell 5.1 comes pre-installed on modern Windows
- PowerShell 7+ requires separate installation on all platforms
- Package managers provide the easiest installation method
- Microsoft maintains official repositories for Linux distributions

### PowerShell ISE vs Visual Studio Code

#### PowerShell Integrated Scripting Environment (ISE)

PowerShell ISE shipped as the official scripting environment for Windows PowerShell. This Windows-only application provided integrated script editing, debugging, and execution capabilities within a graphical interface.

**ISE features:**

- Built-in script editor with syntax highlighting
- Interactive console pane
- Commands pane showing available cmdlets
- Script debugging with breakpoints
- Help integration
- Profile support

**ISE limitations:**

- Windows PowerShell 5.1 only - no PowerShell 7+ support
- No cross-platform availability
- Limited extensibility compared to modern editors
- No longer under active development

#### Visual Studio Code with PowerShell Extension

Microsoft transitioned development focus to Visual Studio Code with the PowerShell extension as the recommended scripting environment. This combination provides superior functionality across all PowerShell versions and platforms.

**VS Code with PowerShell extension features:**

- Cross-platform support (Windows, Linux, macOS)
- Support for all PowerShell versions
- Advanced IntelliSense and code completion
- Integrated terminal with multiple PowerShell sessions
- Git integration
- Extensive extension ecosystem
- Remote development capabilities
- Advanced debugging features
- Code formatting and linting

**Key points:**

- PowerShell ISE: Legacy Windows-only environment for Windows PowerShell
- VS Code: Modern, cross-platform, actively developed alternative
- Microsoft recommends VS Code for new PowerShell development
- PowerShell extension brings PowerShell-specific functionality to VS Code

### Understanding the PowerShell Execution Environment

#### Execution Policies

PowerShell implements execution policies as a security mechanism to control script execution. These policies apply primarily to Windows systems, with limited impact on Linux and macOS.

**Execution policy levels:**

- **Restricted**: No scripts allowed (Windows default)
- **AllSigned**: Only signed scripts from trusted publishers
- **RemoteSigned**: Local scripts unrestricted, remote scripts must be signed
- **Unrestricted**: All scripts allowed with prompts for remote scripts
- **Bypass**: No restrictions or prompts
- **Undefined**: No execution policy set

**Policy scope hierarchy:**

1. **MachinePolicy**: Group Policy computer configuration
2. **UserPolicy**: Group Policy user configuration
3. **Process**: Current PowerShell session only
4. **CurrentUser**: Current user profile
5. **LocalMachine**: All users on the computer

#### PowerShell Profiles

Profiles contain PowerShell code that executes automatically when starting a PowerShell session. Different profile types serve various scopes and use cases.

**Profile types:**

- **All Users, All Hosts**: Affects every user and every PowerShell host
- **All Users, Current Host**: Affects every user for specific host application
- **Current User, All Hosts**: Affects current user across all host applications
- **Current User, Current Host**: Affects current user in specific host application

**Profile locations** [Inference - based on standard PowerShell documentation patterns]:

- Windows PowerShell: Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
- PowerShell 7+: Documents\PowerShell\Microsoft.PowerShell_profile.ps1

#### Modules and Snap-ins

PowerShell extends functionality through modules (PowerShell 2.0+) and snap-ins (PowerShell 1.0 legacy).

**Modules** provide the modern extensibility mechanism, supporting:

- Script modules (.psm1 files)
- Binary modules (compiled .NET assemblies)
- Manifest modules (metadata and organization)
- Dynamic modules (created in memory)

**Module auto-loading** discovers and imports modules automatically when users invoke contained commands. PowerShell searches predefined paths in the PSModulePath environment variable.

**Key points:**

- Execution policies primarily affect Windows systems
- Profiles enable session customization and automation
- Modules provide the primary extensibility mechanism
- Auto-loading simplifies module discovery and usage

### PowerShell Host Applications

PowerShell operates through various host applications that provide different interfaces and capabilities.

**Console Host** (powershell.exe/pwsh.exe) provides the standard command-line interface with basic editing capabilities and command history.

**ISE Host** offers the graphical scripting environment with enhanced editing and debugging features for Windows PowerShell only.

**VS Code PowerShell Extension Host** integrates PowerShell sessions within the VS Code editor environment.

**Other Hosts** include Windows Terminal, third-party applications, and custom applications that embed PowerShell engines.

Each host may implement different features and limitations, affecting available functionality and user experience.

**Example** of checking the current host:

```powershell
$Host.Name
$Host.Version
```

**Key points:**

- Multiple host applications provide different PowerShell interfaces
- Host capabilities vary significantly
- PowerShell scripts should consider host compatibility when using advanced features

### .NET Integration Architecture

PowerShell's foundation on .NET Framework (.NET Core for cross-platform versions) enables direct access to .NET classes, methods, and objects. This integration distinguishes PowerShell from traditional text-based shells.

**Object Pipeline**: PowerShell passes .NET objects between commands rather than text, enabling rich data manipulation and preserving type information throughout command chains.

**.NET Class Access**: Direct instantiation and manipulation of .NET classes through PowerShell syntax:

```powershell
[System.DateTime]::Now
$regex = [System.Text.RegularExpressions.Regex]::new("pattern")
```

**Assembly Loading**: Dynamic loading of .NET assemblies expands available functionality beyond built-in types.

**Key points:**

- Object-based pipeline differentiates PowerShell from text-based shells
- Direct .NET integration provides extensive programming capabilities
- Type preservation maintains data fidelity across command chains

---

