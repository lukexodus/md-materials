# Robocopy 

Robocopy (Robust File Copy) is a command-line file copying utility built into Windows that's far more powerful than the standard `copy` or `xcopy` commands.

## Basic Syntax

```
robocopy <source> <destination> [file(s)] [options]
```

**Example:**

```
robocopy C:\Source D:\Destination
```

## Essential Concepts

**What gets copied by default:**

- All files in the source directory
- Subdirectories are NOT copied unless you specify `/E` or `/S`
- File attributes and timestamps are preserved

**Exit codes:** Robocopy uses exit codes to report status (not just 0 for success):

- 0 = No files copied (no errors)
- 1 = Files copied successfully
- 2 = Extra files/directories detected
- 4 = Mismatched files/directories
- 8 = Copy failures occurred
- 16 = Fatal error

Exit codes can combine (e.g., 3 = 1 + 2).

## Most Useful Options

**Copy options:**

- `/E` - Copy subdirectories, including empty ones
- `/S` - Copy subdirectories, excluding empty ones
- `/MIR` - Mirror directory (copies everything, deletes files in destination that don't exist in source - **use carefully**)
- `/COPYALL` - Copy all file information (attributes, timestamps, security, owner, auditing)
- `/COPY:DAT` - Copy Data, Attributes, and Timestamps (default)
- `/DCOPY:T` - Copy directory timestamps

**File selection:**

- `*.txt` - Copy only specific file types
- `/MAX:n` - Maximum file size (n bytes)
- `/MIN:n` - Minimum file size
- `/MAXAGE:n` - Maximum file age (n days)
- `/MINAGE:n` - Minimum file age

**Filtering:**

- `/XF file1 file2` - Exclude specific files
- `/XD dir1 dir2` - Exclude specific directories
- `/XO` - Exclude older files
- `/XN` - Exclude newer files
- `/XC` - Exclude changed files

**Retry options:**

- `/R:n` - Number of retries (default is 1 million!)
- `/W:n` - Wait time between retries in seconds (default is 30)
- `/R:3 /W:5` - Common settings (3 retries, 5 seconds wait)

**Logging:**

- `/LOG:file.txt` - Write log to file (overwrites)
- `/LOG+:file.txt` - Append to existing log
- `/NP` - No progress (cleaner output)
- `/NDL` - No directory list
- `/NFL` - No file list
- `/TEE` - Output to console AND log file
- `/V` - Verbose output

**Performance:**

- `/MT[:n]` - Multi-threaded copying (default n=8, max 128)
- `/J` - Unbuffered I/O (better for large files)

## Common Use Cases

**1. Basic backup (mirror with logging):**

```
robocopy C:\Users\YourName\Documents D:\Backup\Documents /MIR /R:3 /W:5 /LOG:backup.log
```

**2. Copy directory structure with all subdirectories:**

```
robocopy C:\Source D:\Destination /E
```

**3. Fast copy of large files:**

```
robocopy C:\Source D:\Destination /MT:16 /J
```

**4. Copy only new or changed files:**

```
robocopy C:\Source D:\Destination /E /XO
```

**5. Exclude specific folders:**

```
robocopy C:\Source D:\Destination /E /XD "C:\Source\TempFiles" "C:\Source\Cache"
```

**6. Copy only specific file types:**

```
robocopy C:\Source D:\Destination *.docx *.xlsx /S
```

**7. Move files (copy then delete source):**

```
robocopy C:\Source D:\Destination /E /MOVE
```

## Important Warnings

**The `/MIR` flag is dangerous:**

- It deletes files in the destination that don't exist in the source
- If you accidentally reverse source/destination, you could lose data
- Always test with `/L` (list only) first

**Testing before execution:**

```
robocopy C:\Source D:\Destination /MIR /L
```

The `/L` flag lists what would happen without actually copying.

## Practical Tips

**1. Always specify retry limits:** The defaults (1 million retries, 30 seconds between) can hang your script for days. Use `/R:3 /W:5` or similar.

**2. Use quotes for paths with spaces:**

```
robocopy "C:\My Documents" "D:\My Backup" /E
```

**3. Network paths work:**

```
robocopy C:\Local \\Server\Share\Folder /E
```

**4. Schedule with Task Scheduler:** Create a `.bat` file with your robocopy command and schedule it with Windows Task Scheduler for automated backups.

**5. Check exit codes in scripts:**

```batch
robocopy C:\Source D:\Destination /E
if %ERRORLEVEL% GEQ 8 (
    echo Copy failed with errors
)
```

## Quick Reference Template

Here's a versatile template you can modify:

```
robocopy [source] [destination] /E /COPYALL /R:3 /W:5 /MT:8 /LOG+:robocopy.log /TEE
```

This copies everything, preserves all attributes, retries sensibly, uses multi-threading, logs to file, and shows progress on screen.

## Where to Practice

Create test folders to experiment:

```
mkdir C:\RoboTest\Source
mkdir C:\RoboTest\Dest
echo test > C:\RoboTest\Source\file.txt
robocopy C:\RoboTest\Source C:\RoboTest\Dest /E /L
```

The `/L` flag lets you see what would happen without risk.

## Getting Help

Type `robocopy /?` in Command Prompt to see all options. The built-in help is comprehensive and includes examples.