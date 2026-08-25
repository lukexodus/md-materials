## `os` Module


The `os` module provides a portable way to interact with the operating system, offering functions for file and directory operations, process management, environment variables, and system-level operations. It serves as the primary interface between Python programs and the underlying operating system.

### Module Overview and Purpose

The `os` module abstracts operating system functionality, allowing Python programs to perform system operations in a platform-independent manner. It handles file system operations, process management, environment variables, and provides access to various operating system services.

### Importing and Basic Usage

```python
import os
# Access all os functionality
print(os.getcwd())

# Import specific functions
from os import getcwd, listdir, environ
from os.path import join, exists, dirname
```

### File and Directory Operations

#### Current Working Directory

```python
import os

# Get current working directory
current_dir = os.getcwd()
print("Current directory:", current_dir)

# Change working directory
os.chdir('/path/to/new/directory')

# Change to parent directory
os.chdir('..')

# Change to home directory
os.chdir(os.path.expanduser('~'))
```

#### Directory Listing and Navigation

```python
import os

# List directory contents
files = os.listdir('.')
print("Files in current directory:", files)

# List with full paths
for item in os.listdir('.'):
    full_path = os.path.join('.', item)
    print(f"{'DIR' if os.path.isdir(full_path) else 'FILE'}: {item}")

# Walk directory tree
for root, dirs, files in os.walk('/path/to/directory'):
    print(f"Directory: {root}")
    for file in files:
        print(f"  File: {file}")
    for dir in dirs:
        print(f"  Subdirectory: {dir}")
```

#### Directory Creation and Removal

```python
import os

# Create single directory
os.mkdir('new_directory')

# Create nested directories
os.makedirs('path/to/nested/directory', exist_ok=True)

# Remove empty directory
os.rmdir('empty_directory')

# Remove directory and all contents
import shutil
shutil.rmtree('directory_with_contents')

# Remove nested empty directories
os.removedirs('path/to/empty/nested/dirs')
```

### File Operations

#### File Creation and Removal

```python
import os

# Create empty file
with open('new_file.txt', 'w') as f:
    pass

# Remove file
os.remove('file_to_delete.txt')
os.unlink('another_file.txt')  # Same as remove

# Safe file removal
def safe_remove(filename):
    try:
        os.remove(filename)
        print(f"Removed: {filename}")
    except FileNotFoundError:
        print(f"File not found: {filename}")
    except PermissionError:
        print(f"Permission denied: {filename}")
```

#### File and Directory Information

```python
import os
import time

# Check if path exists
print("File exists:", os.path.exists('file.txt'))
print("Directory exists:", os.path.exists('directory'))

# Check path type
print("Is file:", os.path.isfile('file.txt'))
print("Is directory:", os.path.isdir('directory'))
print("Is symlink:", os.path.islink('symlink'))

# Get file statistics
stat_info = os.stat('file.txt')
print("File size:", stat_info.st_size)
print("Modified time:", time.ctime(stat_info.st_mtime))
print("Created time:", time.ctime(stat_info.st_ctime))
print("Permissions:", oct(stat_info.st_mode))
```

#### File Permissions and Attributes

```python
import os

# Change file permissions
os.chmod('file.txt', 0o644)  # rw-r--r--
os.chmod('script.py', 0o755)  # rwxr-xr-x

# Change file ownership (Unix/Linux only)
if os.name == 'posix':
    os.chown('file.txt', 1000, 1000)  # uid, gid

# Access and modification times
os.utime('file.txt', (access_time, modification_time))
```

### Path Operations with os.path

#### Path Construction and Manipulation

```python
import os

# Join paths (platform-independent)
path = os.path.join('directory', 'subdirectory', 'file.txt')
print("Joined path:", path)

# Split path components
directory, filename = os.path.split(path)
print("Directory:", directory)
print("Filename:", filename)

# Get file extension
name, ext = os.path.splitext('file.txt')
print("Name:", name)
print("Extension:", ext)

# Get directory name
print("Directory name:", os.path.dirname('/path/to/file.txt'))

# Get base name
print("Base name:", os.path.basename('/path/to/file.txt'))
```

#### Path Analysis

```python
import os

# Absolute and relative paths
relative_path = 'file.txt'
absolute_path = os.path.abspath(relative_path)
print("Absolute path:", absolute_path)

# Normalize path
normalized = os.path.normpath('path//to/../file.txt')
print("Normalized:", normalized)

# Real path (resolve symlinks)
real_path = os.path.realpath('symlink_to_file')
print("Real path:", real_path)

# Check if path is absolute
print("Is absolute:", os.path.isabs('/absolute/path'))
```

#### Path Expansion

```python
import os

# Expand user home directory
home_path = os.path.expanduser('~/Documents')
print("Home path:", home_path)

# Expand environment variables
var_path = os.path.expandvars('$HOME/Documents')
print("Variable path:", var_path)

# Common path operations
print("Common prefix:", os.path.commonprefix(['/path/to/file1', '/path/to/file2']))
print("Common path:", os.path.commonpath(['/path/to/file1', '/path/to/file2']))
```

### Environment Variables

#### Reading Environment Variables

```python
import os

# Get all environment variables
print("All environment variables:")
for key, value in os.environ.items():
    print(f"{key}: {value}")

# Get specific environment variable
home_dir = os.environ.get('HOME')
path_var = os.environ.get('PATH')
print("Home directory:", home_dir)
print("PATH:", path_var)

# Get with default value
database_url = os.environ.get('DATABASE_URL', 'sqlite:///default.db')
print("Database URL:", database_url)
```

#### Setting Environment Variables

```python
import os

# Set environment variable
os.environ['MY_VARIABLE'] = 'my_value'

# Set multiple variables
os.environ.update({
    'API_KEY': 'secret_key',
    'DEBUG': 'true',
    'PORT': '8080'
})

# Remove environment variable
if 'TEMP_VAR' in os.environ:
    del os.environ['TEMP_VAR']

# Pop environment variable
old_value = os.environ.pop('OLD_VAR', 'default')
```

### Process Management

#### Running External Commands

```python
import os

# Execute system command
result = os.system('ls -l')
print("Exit code:", result)

# Execute and capture output (deprecated, use subprocess)
import subprocess

# Modern approach
result = subprocess.run(['ls', '-l'], capture_output=True, text=True)
print("Output:", result.stdout)
print("Error:", result.stderr)
print("Return code:", result.returncode)
```

#### Process Information

```python
import os

# Get process ID
print("Process ID:", os.getpid())

# Get parent process ID
print("Parent PID:", os.getppid())

# Get process group ID (Unix/Linux)
if os.name == 'posix':
    print("Process group ID:", os.getpgid(0))

# Get user and group IDs (Unix/Linux)
if os.name == 'posix':
    print("User ID:", os.getuid())
    print("Group ID:", os.getgid())
    print("Effective user ID:", os.geteuid())
    print("Effective group ID:", os.getegid())
```

#### Process Creation (Unix/Linux)

```python
import os

if os.name == 'posix':
    # Fork process
    pid = os.fork()
    
    if pid == 0:
        # Child process
        print("Child process")
        os._exit(0)
    else:
        # Parent process
        print(f"Parent process, child PID: {pid}")
        os.waitpid(pid, 0)  # Wait for child to complete
```

### System Information

#### Platform and OS Information

```python
import os

# Operating system name
print("OS name:", os.name)  # 'posix', 'nt', 'java'

# Detailed system information
if hasattr(os, 'uname'):
    uname_info = os.uname()
    print("System:", uname_info.sysname)
    print("Node:", uname_info.nodename)
    print("Release:", uname_info.release)
    print("Version:", uname_info.version)
    print("Machine:", uname_info.machine)

# CPU count
print("CPU count:", os.cpu_count())

# Load average (Unix/Linux)
if hasattr(os, 'getloadavg'):
    load1, load5, load15 = os.getloadavg()
    print(f"Load average: {load1:.2f}, {load5:.2f}, {load15:.2f}")
```

#### Memory and Resource Information

```python
import os

# Get terminal size
if hasattr(os, 'get_terminal_size'):
    size = os.get_terminal_size()
    print(f"Terminal size: {size.columns}x{size.lines}")

# Resource limits (Unix/Linux)
if hasattr(os, 'getrlimit'):
    import resource
    soft, hard = resource.getrlimit(resource.RLIMIT_NOFILE)
    print(f"File descriptor limits: soft={soft}, hard={hard}")
```

### Advanced File Operations

#### File Descriptors

```python
import os

# Open file with file descriptor
fd = os.open('file.txt', os.O_RDONLY)

# Read from file descriptor
data = os.read(fd, 1024)
print("Data:", data.decode())

# Close file descriptor
os.close(fd)

# Write to file descriptor
fd = os.open('output.txt', os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o644)
os.write(fd, b'Hello, World!')
os.close(fd)
```

#### File Locking (Unix/Linux)

```python
import os
import fcntl

if os.name == 'posix':
    # Exclusive lock
    with open('lockfile.txt', 'w') as f:
        fcntl.flock(f.fileno(), fcntl.LOCK_EX)
        f.write('Locked content')
        # Lock released when file is closed
```

#### Pipes and Communication

```python
import os

# Create pipe
if os.name == 'posix':
    read_fd, write_fd = os.pipe()
    
    # Write to pipe
    os.write(write_fd, b'Hello from pipe')
    
    # Read from pipe
    data = os.read(read_fd, 1024)
    print("Pipe data:", data.decode())
    
    # Close file descriptors
    os.close(read_fd)
    os.close(write_fd)
```

### Symbolic Links and Hard Links

#### Creating and Managing Links

```python
import os

# Create symbolic link
os.symlink('target_file.txt', 'link_to_file.txt')

# Create hard link (Unix/Linux)
if os.name == 'posix':
    os.link('original_file.txt', 'hard_link.txt')

# Read symbolic link
if os.path.islink('link_to_file.txt'):
    target = os.readlink('link_to_file.txt')
    print("Link target:", target)

# Check if path is a link
print("Is symbolic link:", os.path.islink('link_to_file.txt'))
```

### Temporary Files and Directories

#### Working with Temporary Files

```python
import os
import tempfile

# Get temporary directory
temp_dir = tempfile.gettempdir()
print("Temp directory:", temp_dir)

# Create temporary file
with tempfile.NamedTemporaryFile(mode='w', delete=False) as temp_file:
    temp_file.write('Temporary content')
    temp_filename = temp_file.name

print("Temporary file:", temp_filename)

# Clean up
os.unlink(temp_filename)

# Create temporary directory
with tempfile.TemporaryDirectory() as temp_dir:
    print("Temporary directory:", temp_dir)
    # Directory is automatically cleaned up
```

### Error Handling

#### Common OS Exceptions

```python
import os

def safe_file_operation(filename):
    try:
        with open(filename, 'r') as f:
            content = f.read()
            return content
    except FileNotFoundError:
        print(f"File not found: {filename}")
    except PermissionError:
        print(f"Permission denied: {filename}")
    except IsADirectoryError:
        print(f"Is a directory: {filename}")
    except OSError as e:
        print(f"OS error: {e}")

def safe_directory_operation(dirname):
    try:
        os.makedirs(dirname, exist_ok=True)
        files = os.listdir(dirname)
        return files
    except PermissionError:
        print(f"Permission denied: {dirname}")
    except NotADirectoryError:
        print(f"Not a directory: {dirname}")
    except OSError as e:
        print(f"OS error: {e}")
```

### Practical Examples

#### File System Monitor

```python
import os
import time

def monitor_directory(path, interval=1):
    """Monitor directory for changes"""
    previous_files = set()
    
    while True:
        try:
            current_files = set(os.listdir(path))
            
            # New files
            new_files = current_files - previous_files
            for file in new_files:
                print(f"New file: {file}")
            
            # Removed files
            removed_files = previous_files - current_files
            for file in removed_files:
                print(f"Removed file: {file}")
            
            previous_files = current_files
            time.sleep(interval)
            
        except KeyboardInterrupt:
            print("Monitoring stopped")
            break
        except OSError as e:
            print(f"Error monitoring directory: {e}")
            break
```

#### Disk Usage Calculator

```python
import os

def calculate_directory_size(path):
    """Calculate total size of directory"""
    total_size = 0
    
    for root, dirs, files in os.walk(path):
        for file in files:
            file_path = os.path.join(root, file)
            try:
                total_size += os.path.getsize(file_path)
            except OSError:
                pass  # Skip files that can't be accessed
    
    return total_size

def format_bytes(bytes):
    """Format bytes in human-readable format"""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if bytes < 1024.0:
            return f"{bytes:.2f} {unit}"
        bytes /= 1024.0
    return f"{bytes:.2f} PB"

# Usage
directory = '/path/to/directory'
size = calculate_directory_size(directory)
print(f"Directory size: {format_bytes(size)}")
```

#### Configuration File Manager

```python
import os
import json

class ConfigManager:
    def __init__(self, config_dir=None):
        if config_dir is None:
            config_dir = os.path.expanduser('~/.myapp')
        
        self.config_dir = config_dir
        self.config_file = os.path.join(config_dir, 'config.json')
        
        # Create config directory if it doesn't exist
        os.makedirs(config_dir, exist_ok=True)
    
    def load_config(self):
        """Load configuration from file"""
        if os.path.exists(self.config_file):
            with open(self.config_file, 'r') as f:
                return json.load(f)
        return {}
    
    def save_config(self, config):
        """Save configuration to file"""
        with open(self.config_file, 'w') as f:
            json.dump(config, f, indent=4)
    
    def get_setting(self, key, default=None):
        """Get specific setting"""
        config = self.load_config()
        return config.get(key, default)
    
    def set_setting(self, key, value):
        """Set specific setting"""
        config = self.load_config()
        config[key] = value
        self.save_config(config)

# Usage
config = ConfigManager()
config.set_setting('api_key', 'secret_key')
api_key = config.get_setting('api_key')
```

#### File Backup System

```python
import os
import shutil
import time
from datetime import datetime

class BackupManager:
    def __init__(self, backup_dir):
        self.backup_dir = backup_dir
        os.makedirs(backup_dir, exist_ok=True)
    
    def backup_file(self, source_file):
        """Backup a single file"""
        if not os.path.exists(source_file):
            raise FileNotFoundError(f"Source file not found: {source_file}")
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = os.path.basename(source_file)
        backup_name = f"{timestamp}_{filename}"
        backup_path = os.path.join(self.backup_dir, backup_name)
        
        shutil.copy2(source_file, backup_path)
        return backup_path
    
    def backup_directory(self, source_dir):
        """Backup entire directory"""
        if not os.path.exists(source_dir):
            raise FileNotFoundError(f"Source directory not found: {source_dir}")
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        dir_name = os.path.basename(source_dir)
        backup_name = f"{timestamp}_{dir_name}"
        backup_path = os.path.join(self.backup_dir, backup_name)
        
        shutil.copytree(source_dir, backup_path)
        return backup_path
    
    def list_backups(self):
        """List all backups"""
        backups = []
        for item in os.listdir(self.backup_dir):
            item_path = os.path.join(self.backup_dir, item)
            stat_info = os.stat(item_path)
            backups.append({
                'name': item,
                'path': item_path,
                'size': stat_info.st_size,
                'created': time.ctime(stat_info.st_ctime)
            })
        return sorted(backups, key=lambda x: x['created'], reverse=True)
```

### Platform-Specific Features

#### Windows-Specific Operations

```python
import os

if os.name == 'nt':
    # Windows-specific environment variables
    print("Windows directory:", os.environ.get('WINDIR'))
    print("User profile:", os.environ.get('USERPROFILE'))
    print("Program files:", os.environ.get('PROGRAMFILES'))
    
    # Windows path operations
    drive, path = os.path.splitdrive(r'C:\Windows\System32')
    print("Drive:", drive)
    print("Path:", path)
```

#### Unix/Linux-Specific Operations

```python
import os

if os.name == 'posix':
    # Unix/Linux-specific operations
    print("Home directory:", os.environ.get('HOME'))
    print("Shell:", os.environ.get('SHELL'))
    
    # File permissions
    def get_file_permissions(filename):
        stat_info = os.stat(filename)
        mode = stat_info.st_mode
        
        permissions = []
        permissions.append('r' if mode & 0o400 else '-')
        permissions.append('w' if mode & 0o200 else '-')
        permissions.append('x' if mode & 0o100 else '-')
        permissions.append('r' if mode & 0o040 else '-')
        permissions.append('w' if mode & 0o020 else '-')
        permissions.append('x' if mode & 0o010 else '-')
        permissions.append('r' if mode & 0o004 else '-')
        permissions.append('w' if mode & 0o002 else '-')
        permissions.append('x' if mode & 0o001 else '-')
        
        return ''.join(permissions)
```

### Performance Considerations

#### Efficient File Operations

```python
import os

def efficient_file_search(directory, pattern):
    """Efficiently search for files matching pattern"""
    matches = []
    
    # Use os.scandir for better performance than os.listdir
    with os.scandir(directory) as entries:
        for entry in entries:
            if entry.is_file() and pattern in entry.name:
                matches.append(entry.path)
    
    return matches

def batch_file_operations(file_list, operation):
    """Perform batch operations on multiple files"""
    results = []
    
    for file_path in file_list:
        try:
            result = operation(file_path)
            results.append((file_path, result, None))
        except OSError as e:
            results.append((file_path, None, str(e)))
    
    return results
```

### Security Considerations

#### Safe Path Operations

```python
import os

def safe_path_join(base_path, *paths):
    """Safely join paths to prevent directory traversal"""
    result = os.path.join(base_path, *paths)
    normalized = os.path.normpath(result)
    
    # Ensure the result is within the base path
    if not normalized.startswith(os.path.normpath(base_path)):
        raise ValueError("Path traversal detected")
    
    return normalized

def validate_filename(filename):
    """Validate filename for security"""
    # Check for dangerous characters
    dangerous_chars = ['..', '/', '\\', ':', '*', '?', '"', '<', '>', '|']
    
    for char in dangerous_chars:
        if char in filename:
            raise ValueError(f"Dangerous character in filename: {char}")
    
    # Check for reserved names (Windows)
    reserved_names = ['CON', 'PRN', 'AUX', 'NUL'] + [f'COM{i}' for i in range(1, 10)] + [f'LPT{i}' for i in range(1, 10)]
    
    if filename.upper() in reserved_names:
        raise ValueError(f"Reserved filename: {filename}")
    
    return filename
```

### Best Practices

**Example** of comprehensive file management:

```python
import os
import logging
import tempfile
from contextlib import contextmanager

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class FileManager:
    def __init__(self, base_path):
        self.base_path = os.path.abspath(base_path)
        os.makedirs(base_path, exist_ok=True)
    
    @contextmanager
    def temporary_file(self, suffix='.tmp'):
        """Context manager for temporary files"""
        temp_fd, temp_path = tempfile.mkstemp(suffix=suffix, dir=self.base_path)
        try:
            yield temp_path
        finally:
            os.close(temp_fd)
            if os.path.exists(temp_path):
                os.unlink(temp_path)
    
    def safe_write(self, filename, content):
        """Safely write content to file"""
        full_path = os.path.join(self.base_path, filename)
        
        # Write to temporary file first
        with self.temporary_file() as temp_path:
            with open(temp_path, 'w') as f:
                f.write(content)
            
            # Atomically move to final location
            os.rename(temp_path, full_path)
            logger.info(f"Successfully wrote to {filename}")
    
    def safe_read(self, filename):
        """Safely read file content"""
        full_path = os.path.join(self.base_path, filename)
        
        if not os.path.exists(full_path):
            raise FileNotFoundError(f"File not found: {filename}")
        
        with open(full_path, 'r') as f:
            return f.read()
    
    def list_files(self, pattern=None):
        """List files with optional pattern matching"""
        files = []
        
        for item in os.listdir(self.base_path):
            item_path = os.path.join(self.base_path, item)
            if os.path.isfile(item_path):
                if pattern is None or pattern in item:
                    files.append(item)
        
        return sorted(files)
```

**Conclusion:** The `os` module is fundamental for system programming in Python, providing comprehensive access to operating system functionality. It enables file and directory operations, process management, environment variable manipulation, and system information retrieval. Understanding its capabilities is essential for writing robust, cross-platform applications that interact with the file system and operating system services. Always consider security implications when working with file paths and system operations, and use appropriate error handling for robust applications.

---

