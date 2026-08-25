## File System Operations in PHP


### Introduction to PHP File System Operations

PHP offers comprehensive capabilities for interacting with the file system, providing functions for file manipulation, directory management, and security control. These operations are essential for tasks such as configuration management, data storage, log handling, and content management systems.

### Reading and Writing Files

#### File Reading Functions

PHP provides several methods to read file content:

```php
// Read entire file into a string
$content = file_get_contents('example.txt');

// Read file line by line into an array
$lines = file('example.txt', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

// Read file using file handles
$handle = fopen('example.txt', 'r');
if ($handle) {
    while (($line = fgets($handle)) !== false) {
        echo $line;
    }
    fclose($handle);
}
```

#### Writing to Files

Similarly, PHP offers multiple approaches for writing to files:

```php
// Write string to file (overwrites existing content)
file_put_contents('output.txt', 'Hello, world!');

// Append content to existing file
file_put_contents('log.txt', "New log entry: " . date('Y-m-d H:i:s') . "\n", FILE_APPEND);

// Write using file handles
$handle = fopen('data.txt', 'w');
if ($handle) {
    fwrite($handle, "Line 1\n");
    fwrite($handle, "Line 2\n");
    fclose($handle);
}
```

#### File Reading/Writing Modes

When using `fopen()`, various modes control file access:

|Mode|Description|
|---|---|
|'r'|Read-only, starts at beginning|
|'r+'|Read/write, starts at beginning|
|'w'|Write-only, truncates file to zero length or creates new file|
|'w+'|Read/write, truncates file to zero length or creates new file|
|'a'|Write-only, append to end of file or creates new file|
|'a+'|Read/write, append to end of file or creates new file|
|'x'|Write-only, creates new file, fails if file exists|
|'x+'|Read/write, creates new file, fails if file exists|
|'c'|Write-only, creates new file or opens without truncation|
|'c+'|Read/write, creates new file or opens without truncation|

#### File Pointer Operations

Control the internal file pointer:

```php
$handle = fopen('example.txt', 'r+');

// Move pointer to specific position
fseek($handle, 10); // Move to 10th byte

// Get current position
$position = ftell($handle);

// Read specific number of bytes
$data = fread($handle, 50); // Read 50 bytes

// Rewind to beginning
rewind($handle);

fclose($handle);
```

#### Binary File Operations

PHP can also handle binary files:

```php
$handle = fopen('image.jpg', 'rb'); // 'b' for binary mode
$imageData = fread($handle, filesize('image.jpg'));
fclose($handle);

// Write binary data
$handle = fopen('output.jpg', 'wb');
fwrite($handle, $imageData);
fclose($handle);
```

#### CSV File Operations

PHP has special functions for CSV files:

```php
// Reading CSV
$handle = fopen('data.csv', 'r');
while (($data = fgetcsv($handle)) !== false) {
    // $data is an array with values from one row
    print_r($data);
}
fclose($handle);

// Writing CSV
$handle = fopen('output.csv', 'w');
$data = [
    ['Name', 'Email', 'Phone'],
    ['John Doe', 'john@example.com', '555-1234'],
    ['Jane Smith', 'jane@example.com', '555-5678']
];
foreach ($data as $row) {
    fputcsv($handle, $row);
}
fclose($handle);
```

**Key Points**:

- Use `file_get_contents()` and `file_put_contents()` for simple operations
- For more complex operations (line-by-line, chunked reading, etc.), use file handles
- Always close file handles with `fclose()` to free system resources
- Use binary modes ('b' suffix) when dealing with non-text files

### Directory Operations

#### Creating and Removing Directories

```php
// Create directory
if (!is_dir('uploads')) {
    mkdir('uploads', 0755);
}

// Create nested directories
mkdir('path/to/nested/directory', 0755, true);

// Remove directory (must be empty)
rmdir('old_directory');
```

#### Reading Directory Contents

```php
// List all files in directory
$files = scandir('documents');
print_r($files);

// Using directory handle
$dir = opendir('documents');
while (($file = readdir($dir)) !== false) {
    echo $file . "\n";
}
closedir($dir);

// Using DirectoryIterator (OOP approach)
$iterator = new DirectoryIterator('documents');
foreach ($iterator as $fileinfo) {
    if (!$fileinfo->isDot()) {
        echo $fileinfo->getFilename() . "\n";
    }
}
```

#### Recursive Directory Operations

For working with directory trees:

```php
// RecursiveDirectoryIterator example
$directory = new RecursiveDirectoryIterator('project');
$iterator = new RecursiveIteratorIterator($directory);

foreach ($iterator as $info) {
    if ($info->isFile()) {
        echo $info->getPathname() . "\n";
    }
}

// Find specific files recursively
$directory = new RecursiveDirectoryIterator('project');
$iterator = new RecursiveIteratorIterator($directory);
$phpFiles = new RegexIterator($iterator, '/\.php$/i');

foreach ($phpFiles as $phpFile) {
    echo $phpFile->getPathname() . "\n";
}
```

#### Copying and Moving Files/Directories

```php
// Copy file
copy('source.txt', 'destination.txt');

// Move/rename file
rename('oldname.txt', 'newname.txt');

// Move file to another directory
rename('file.txt', 'newdirectory/file.txt');
```

#### Getting File Information

```php
// Check if file/directory exists
if (file_exists('config.php')) {
    // File operations
}

// Check file type
if (is_file('document.txt')) {
    echo "Regular file";
} elseif (is_dir('documents')) {
    echo "Directory";
} elseif (is_link('shortcut')) {
    echo "Symbolic link";
}

// Get file size
$size = filesize('large_file.zip');
echo "Size: " . number_format($size / 1024, 2) . " KB";

// Get file modification time
$mtime = filemtime('document.txt');
echo "Last modified: " . date('Y-m-d H:i:s', $mtime);

// Get file owner and group
$owner = fileowner('document.txt');
$group = filegroup('document.txt');
echo "Owner ID: $owner, Group ID: $group";

// Get file information in one call
$info = stat('document.txt');
print_r($info);
```

**Key Points**:

- Always check return values of directory functions for error handling
- Use iterators for better memory usage with large directories
- Consider using SPL iterators for complex directory operations

### File Permissions and Security Considerations

#### Understanding File Permissions

PHP uses Unix-style permission system, even on Windows servers:

```php
// Change file permissions
chmod('script.php', 0755); // rwxr-xr-x
chmod('private.key', 0600); // rw-------

// Get current permissions
$perms = fileperms('script.php');
$perms_octal = substr(sprintf('%o', $perms), -4);
echo "Permissions: $perms_octal";

// Change file owner/group (requires appropriate system privileges)
chown('file.txt', 'www-data');
chgrp('file.txt', 'www-data');
```

#### Common Permission Values

|Octal|Permission|Meaning|
|---|---|---|
|0644|rw-r--r--|Owner can read/write, others can read|
|0755|rwxr-xr-x|Owner can read/write/execute, others can read/execute|
|0600|rw-------|Owner can read/write, no access for others|
|0777|rwxrwxrwx|Everyone can read/write/execute (avoid using)|

#### Security Best Practices

##### File Path Validation

Always validate and sanitize file paths:

```php
// Prevent directory traversal attacks
$filename = basename($_GET['file']); // Strip directory components
$safePath = '/var/www/uploads/' . $filename;

// Validate file is in allowed directory
$realPath = realpath($safePath);
$uploadsDir = realpath('/var/www/uploads');
if ($realPath === false || strpos($realPath, $uploadsDir) !== 0) {
    die('Invalid file access attempted');
}
```

##### File Upload Security

When handling file uploads:

```php
// Basic upload handling with validation
if ($_FILES['userfile']['error'] === UPLOAD_ERR_OK) {
    // Validate file type
    $finfo = new finfo(FILEINFO_MIME_TYPE);
    $type = $finfo->file($_FILES['userfile']['tmp_name']);
    
    $allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
    if (!in_array($type, $allowedTypes)) {
        die('Invalid file type');
    }
    
    // Use a safe filename
    $filename = bin2hex(random_bytes(16)) . '.jpg';
    $destination = '/var/www/uploads/' . $filename;
    
    // Move uploaded file to destination
    if (!move_uploaded_file($_FILES['userfile']['tmp_name'], $destination)) {
        die('Failed to move uploaded file');
    }
}
```

##### Configuration File Security

```php
// Store config files outside web root
// /var/www/config/database.php instead of /var/www/html/config/database.php

// Use restrictive permissions
chmod('/var/www/config/database.php', 0600);

// Prevent direct access with .htaccess (Apache)
// Place in config directory:
// <Files *>
//   Order deny,allow
//   Deny from all
// </Files>
```

##### Temporary Files

```php
// Create secure temporary file
$tempFile = tempnam(sys_get_temp_dir(), 'prefix_');
file_put_contents($tempFile, 'Sensitive data');

// Process data...

// Clean up
unlink($tempFile);
```

##### Open_basedir Restriction

In php.ini or virtual host configuration:

```
open_basedir = /var/www/:/tmp/
```

This restricts PHP file operations to specified directories.

#### Advanced File Operations

##### File Locking

Prevent race conditions with file locks:

```php
$handle = fopen('counter.txt', 'r+');
if (flock($handle, LOCK_EX)) { // Exclusive lock
    // Read current value
    $count = (int) fread($handle, 10);
    $count++;
    
    // Move back to start of file and write new value
    rewind($handle);
    fwrite($handle, $count);
    
    // Release lock
    flock($handle, LOCK_UN);
} else {
    echo "Couldn't lock the file!";
}
fclose($handle);
```

##### Stream Wrappers

PHP supports various stream wrappers:

```php
// HTTP stream
$content = file_get_contents('https://example.com/data.json');

// FTP operations
$handle = fopen('ftp://user:pass@ftp.example.com/file.txt', 'r');

// ZIP archives
$zip = new ZipArchive();
if ($zip->open('archive.zip') === true) {
    $content = $zip->getFromName('file.txt');
    $zip->close();
}

// Custom stream wrapper
stream_wrapper_register('custom', 'MyStreamWrapper');
file_put_contents('custom://identifier', 'data');
```

**Key Points**:

- Never trust user input for file operations
- Keep sensitive files outside web root
- Use minimal necessary permissions
- Implement proper error handling for all file operations
- Consider using dedicated libraries for complex file operations

### Error Handling for File Operations

```php
// Using exceptions for file operations (PHP 7+)
try {
    $content = @file_get_contents('missing.txt');
    if ($content === false) {
        throw new Exception('Failed to read file: ' . error_get_last()['message']);
    }
} catch (Exception $e) {
    error_log($e->getMessage());
    echo "An error occurred while reading the file.";
}

// Check for specific error conditions
if (!is_readable('config.php')) {
    die('Configuration file is not readable');
}

if (!is_writable('logs/app.log')) {
    error_log('Log directory is not writable');
    // Fallback behavior
}
```

**Conclusion**: PHP's file system functions provide powerful capabilities for handling files and directories in web applications. However, these operations also introduce security risks that must be carefully managed. Always validate user input, use proper permission settings, and follow security best practices to build robust and secure file handling routines. Remember that file operations can fail for various reasons (permissions, disk space, locks), so proper error handling is essential for production applications.


---
