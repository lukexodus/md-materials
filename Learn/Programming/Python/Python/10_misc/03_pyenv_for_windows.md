## `pyenv` for Windows


pyenv-win is the Windows port of pyenv. It provides similar functionality but is implemented differently due to Windows architecture differences.

### Installation

#### Method 1: Using Git (Recommended)
```cmd
git clone https://github.com/pyenv-win/pyenv-win.git %USERPROFILE%\.pyenv
```

#### Method 2: Using PowerShell (Alternative)
```powershell
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
```

#### Method 3: Using Chocolatey
```cmd
choco install pyenv-win
```

#### Method 4: Using Scoop
```cmd
scoop bucket add main
scoop install pyenv
```

### Environment Setup

After installation, you need to add pyenv to your PATH. You have several options:

#### Option 1: Automatic Setup (Recommended)
The installer usually adds these automatically, but if not:

**For Command Prompt, add to your system PATH:**
- `%USERPROFILE%\.pyenv\pyenv-win\bin`
- `%USERPROFILE%\.pyenv\pyenv-win\shims`

**For PowerShell, add to your PowerShell profile:**
```powershell
## Edit your PowerShell profile
notepad $PROFILE

## Add these lines:
$env:PYENV = "$env:USERPROFILE\.pyenv\pyenv-win\"
$env:PYENV_ROOT = "$env:USERPROFILE\.pyenv\pyenv-win\"
$env:PYENV_HOME = "$env:USERPROFILE\.pyenv\pyenv-win\"
$env:PATH = "$env:PYENV_HOME\bin;$env:PYENV_HOME\shims;$env:PATH"
```

#### Option 2: Manual PATH Setup
1. Open System Properties → Advanced → Environment Variables
2. Add to User PATH:
   - `%USERPROFILE%\.pyenv\pyenv-win\bin`
   - `%USERPROFILE%\.pyenv\pyenv-win\shims`

**Restart your terminal** after setting up the PATH.

### Core Commands (Windows)

The commands are mostly the same as Unix pyenv:

#### Installing Python versions
```cmd
## List available Python versions
pyenv install --list

## Install a specific version
pyenv install 3.11.5
pyenv install 3.12.0

## On Windows, you might see more detailed version numbers
pyenv install 3.11.5-amd64
```

#### Managing versions
```cmd
## List installed versions
pyenv versions

## Set global Python version
pyenv global 3.11.5

## Set local Python version (creates .python-version file)
pyenv local 3.12.0

## Check current Python version
pyenv version

## Refresh shims (sometimes needed on Windows)
pyenv rehash
```

### Windows-Specific Considerations

#### 1. Architecture-Specific Versions
Windows pyenv often shows architecture-specific versions:
```cmd
## You might see versions like:
3.11.5-amd64    ## 64-bit version
3.11.5-win32    ## 32-bit version
```

Use the 64-bit versions unless you specifically need 32-bit.

#### 2. Path Issues
If Python isn't found after switching versions:
```cmd
## Refresh the shims
pyenv rehash

## Check what pyenv thinks is the current Python
pyenv which python
```

#### 3. PowerShell Execution Policy
If you get execution policy errors in PowerShell:
```powershell
## Check current policy
Get-ExecutionPolicy

## Set policy to allow local scripts (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Working with Projects on Windows

#### Using Command Prompt
```cmd
## Navigate to your project
cd C:\Projects\my-project

## Set Python version for this project
pyenv local 3.11.5

## Create virtual environment
python -m venv venv

## Activate virtual environment
venv\Scripts\activate.bat

## Install packages
pip install requests flask
pip freeze > requirements.txt
```

#### Using PowerShell
```powershell
## Navigate to your project
cd C:\Projects\my-project

## Set Python version
pyenv local 3.11.5

## Create virtual environment
python -m venv venv

## Activate virtual environment
.\venv\Scripts\Activate.ps1

## If you get execution policy error:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Windows Terminal Integration

If you're using Windows Terminal, add this to your PowerShell profile for better integration:

```powershell
## Add to $PROFILE
function pyenv { 
    $command = $args[0]
    $args = $args[1..($args.length-1)]
    
    switch ($command) {
        "shell" { 
            if ($args.length -gt 0) {
                $env:PYENV_VERSION = $args[0]
            } else {
                Remove-Item env:PYENV_VERSION -ErrorAction SilentlyContinue
            }
        }
        default { 
            & "$env:PYENV_HOME\bin\pyenv.bat" $command @args
        }
    }
}
```

### Troubleshooting Windows-Specific Issues

#### 1. "pyenv is not recognized"
- Check that pyenv-win\bin is in your PATH
- Restart your terminal
- Try opening a new Command Prompt as Administrator

#### 2. Python version not switching
```cmd
## Refresh shims
pyenv rehash

## Check pyenv status
pyenv version
pyenv versions

## Check what executable is being used
where python
```

#### 3. Permission issues
- Run Command Prompt or PowerShell as Administrator
- Check if antivirus is blocking the installation
- Ensure you have write permissions to %USERPROFILE%\.pyenv

#### 4. SSL/TLS errors during installation
```cmd
## Try installing with verbose output
pyenv install -v 3.11.5

## If SSL errors persist, you might need to update certificates
```

#### 5. Long path issues
Windows has path length limitations. If you encounter issues:
- Enable long paths in Windows 10/11:
  ```cmd
  ## Run as Administrator
  reg add HKLM\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled /t REG_DWORD /d 1
  ```

### IDE Integration

#### Visual Studio Code
Add to your VS Code settings.json:
```json
{
    "python.defaultInterpreterPath": "python",
    "python.terminal.activateEnvironment": true
}
```

#### PyCharm
1. Go to File → Settings → Project → Python Interpreter
2. Click gear icon → Add
3. Select "System Interpreter"
4. Browse to: `%USERPROFILE%\.pyenv\pyenv-win\versions\3.11.5\python.exe`

### Best Practices for Windows

1. **Use Command Prompt or PowerShell consistently**: Don't mix different terminals in the same project

2. **Check architecture**: Always use 64-bit Python versions unless specifically needed
   ```cmd
   pyenv install 3.11.5-amd64
   ```

3. **Handle spaces in paths**: If your project path has spaces, use quotes:
   ```cmd
   cd "C:\My Projects\my-project"
   ```

4. **Virtual environment activation**: Remember Windows uses `Scripts\activate.bat` not `bin/activate`

5. **Antivirus considerations**: Add pyenv directory to antivirus exclusions if you experience slow installations

### Complete Windows Workflow Example

```cmd
## Create and navigate to project directory
mkdir C:\Projects\my-flask-app
cd C:\Projects\my-flask-app

## Set Python version for this project
pyenv local 3.11.5

## Verify Python version
python --version

## Create virtual environment
python -m venv venv

## Activate virtual environment
venv\Scripts\activate.bat

## Upgrade pip
python -m pip install --upgrade pip

## Install project dependencies
pip install flask requests python-dotenv

## Save dependencies
pip freeze > requirements.txt

## Create a simple app
echo from flask import Flask > app.py
echo app = Flask(__name__) >> app.py
echo @app.route('/') >> app.py
echo def hello(): return 'Hello World!' >> app.py

## Run the app
set FLASK_APP=app.py
flask run
```

This workflow ensures you have a consistent, isolated Python environment for your Windows projects using pyenv-win.

