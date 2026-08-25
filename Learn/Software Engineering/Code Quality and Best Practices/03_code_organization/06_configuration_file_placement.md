## Configuration File Placement


Proper configuration management separates code from the settings that vary across deployment environments (local, dev, stage, prod). The placement of these files directly impacts security, portability, and user experience. A robust strategy employs a hierarchical loading order and adheres to platform-specific conventions.

### Loading Hierarchy

Configurations should be loaded in a specific order of precedence, allowing granular overrides. A standard precedence hierarchy, from highest to lowest priority, is:

1. **Command Line Arguments (CLI Flags):** Runtime overrides for immediate execution changes (e.g., `--port 8080`).
    
2. **Environment Variables:** Essential for containerization (Docker/Kubernetes) and secret management (API keys, DB passwords). This aligns with the Twelve-Factor App methodology.
    
3. **Local/User Configuration Files:** Specific to the current user or development environment.
    
4. **System-wide Configuration Files:** Global settings applied to the machine.
    
5. **Application Defaults:** Hardcoded fallback values within the code to ensure the application can start with minimal setup.
    

### Standard Directory Locations

Adhering to operating system standards ensures the application behaves predictably.

Linux/Unix (XDG Base Directory Specification)

Modern Linux applications should follow the XDG Base Directory Specification rather than cluttering the home directory with dotfiles.

- **User Config:** `$XDG_CONFIG_HOME/app-name/` (defaults to `~/.config/app-name/`).
    
- **System Config:** `/etc/app-name/`.
    
- **Cache:** `$XDG_CACHE_HOME/app-name/` (defaults to `~/.cache/app-name/`).
    
- **Data:** `$XDG_DATA_HOME/app-name/` (defaults to `~/.local/share/app-name/`).
    

**Windows**

- **User Config:** `%APPDATA%\Vendor\AppName\` (Roaming) or `%LOCALAPPDATA%\Vendor\AppName\` (Local).
    
- **System Config:** `%PROGRAMDATA%\Vendor\AppName\`.
    

**macOS**

- **User Config:** `~/Library/Application Support/AppName/` or `~/Library/Preferences/com.company.appname.plist`.
    

### Project-Level Configuration

For development environments, configuration often resides within the project root.

- **`.env` files:** Used to simulate environment variables. These must **never** be committed to version control. Add `.env` to `.gitignore`.
    
- **Example Configuration:** Commit a `config.example.json` or `.env.example` file containing keys with dummy values to guide other developers.
    

### Security and Secrets

- **Never commit secrets:** API keys, database credentials, and cryptographic salts should never exist in static configuration files committed to Git.
    
- **Secret Management Systems:** In production, inject secrets via environment variables populated by vault services (HashiCorp Vault, AWS Secrets Manager, Azure Key Vault) rather than reading from a file on disk.
    

**Key Points**

- **Precedence:** CLI > Env Vars > User Config > System Config > Defaults.
    
- **Standardization:** Use XDG on Linux (`~/.config`) and AppData on Windows.
    
- **Security:** Decouple secrets from code; strictly use environment variables for sensitive data.
    
- **Version Control:** Ignore local config files; commit templates only.
    

**Example**

A Python application setup that respects precedence and XDG standards:

Python

```
import os
import argparse
from pathlib import Path

def load_config():
    # 5. Defaults
    config = {'host': 'localhost', 'port': 5000, 'debug': False}

    # 4. System Config (Linux example)
    sys_conf = Path('/etc/myapp/config.json')
    # ... load if exists and update config ...

    # 3. User Config (XDG Standard)
    xdg_config = os.getenv('XDG_CONFIG_HOME', str(Path.home() / '.config'))
    user_conf = Path(xdg_config) / 'myapp' / 'config.json'
    # ... load if exists and update config ...

    # 2. Environment Variables
    if os.getenv('MYAPP_PORT'):
        config['port'] = int(os.getenv('MYAPP_PORT'))

    # 1. CLI Arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int)
    args = parser.parse_args()
    if args.port:
        config['port'] = args.port

    return config
```

