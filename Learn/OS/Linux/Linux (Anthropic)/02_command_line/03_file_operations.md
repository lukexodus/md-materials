## File Operations


### File Manipulation

File manipulation commands form the foundation of Linux file system interaction, allowing users to copy, move, rename, and delete files efficiently.

#### Copy Command (`cp`)

The `cp` command creates copies of files and directories with extensive options for controlling copy behavior.

##### Basic File Copying

Copy a single file using `cp source destination`, where source is the original file and destination can be a filename or directory path. When copying to a directory, the original filename is preserved unless a new name is specified.

##### Directory Copying

Use `cp -r` or `cp -R` for recursive copying of directories and their contents. The recursive flag ensures all subdirectories and files within the source directory are copied to the destination location.

##### Advanced Copy Options

The `-p` flag preserves file attributes including timestamps, ownership, and permissions during copying. Use `-u` for update copying, which only copies files when the source is newer than the destination or when the destination doesn't exist. The `-v` verbose option displays detailed information about each file being copied.

**Key points**: Use `-i` for interactive mode to prompt before overwriting existing files. The `-a` archive option combines `-r`, `-p`, and `-l` flags for complete directory archiving while preserving all attributes and links.

##### Copy with Backup

The `--backup` option creates backup copies of destination files before overwriting them. Combine with `--suffix=SUFFIX` to specify a custom backup file extension.

#### Move Command (`mv`)

The `mv` command serves dual purposes: moving files between locations and renaming files within the same directory.

##### File Moving

Move files using `mv source destination` syntax. Unlike copying, moving transfers the file to the new location and removes it from the original location. Multiple files can be moved simultaneously using `mv file1 file2 file3 destination_directory`.

##### File Renaming

Rename files by specifying a new filename in the same directory: `mv oldname newname`. This operation changes the file's name while keeping it in the same location.

##### Directory Operations

Move entire directories using the same syntax as files. The `mv` command automatically handles directories recursively without requiring additional flags.

**Key points**: Use `-i` for interactive prompting before overwriting existing files. The `-u` update option only moves files when the source is newer than the destination. The `-v` verbose flag displays each move operation.

##### Atomic Operations

The `mv` command performs atomic operations when moving files within the same filesystem, ensuring data integrity during the operation. Cross-filesystem moves involve copying and deleting, which may not be atomic.

#### Remove Command (`rm`)

The `rm` command permanently deletes files and directories from the filesystem.

##### File Deletion

Delete single files using `rm filename` or multiple files with `rm file1 file2 file3`. The command permanently removes files without moving them to a trash or recycle bin.

##### Directory Deletion

Use `rm -r` or `rm -R` for recursive deletion of directories and their contents. This flag is required for removing non-empty directories.

##### Safety Options

The `-i` interactive flag prompts for confirmation before deleting each file. Use `-I` to prompt only when deleting more than three files or when deleting recursively. The `-f` force flag suppresses prompts and error messages, though it should be used cautiously.

**Key points**: There is no built-in undo functionality for `rm` operations. Consider using `rm -i` by default or creating aliases for safer deletion practices. The `--preserve-root` option prevents deletion of the root directory.

##### Secure Deletion

Use `shred` command for secure file deletion that overwrites file contents multiple times before deletion, making data recovery more difficult.

### Directory Operations

Directory operations manage the filesystem hierarchy through creation, deletion, and navigation commands.

#### Make Directory (`mkdir`)

The `mkdir` command creates new directories with various options for setting permissions and creating directory hierarchies.

##### Basic Directory Creation

Create single directories using `mkdir directory_name`. Multiple directories can be created simultaneously with `mkdir dir1 dir2 dir3`.

##### Parent Directory Creation

The `-p` or `--parents` flag creates parent directories as needed, allowing creation of nested directory structures in a single command. For example, `mkdir -p path/to/new/directory` creates all intermediate directories if they don't exist.

##### Permission Setting

Use `-m` or `--mode` to set directory permissions during creation: `mkdir -m 755 directory_name`. This sets permissions without requiring a separate `chmod` command.

**Key points**: Directory names should avoid spaces and special characters for easier command-line manipulation. Use quotes around directory names containing spaces: `mkdir "directory name"`.

##### Verbose Output

The `-v` verbose flag displays a message for each directory created, useful for confirming successful creation in scripts and batch operations.

#### Remove Directory (`rmdir`)

The `rmdir` command removes empty directories from the filesystem.

##### Basic Directory Removal

Remove empty directories using `rmdir directory_name`. The command fails if the directory contains any files or subdirectories.

##### Parent Directory Removal

The `-p` or `--parents` flag removes directory hierarchies, starting from the specified directory and moving up to parent directories as long as they become empty.

##### Error Handling

Use `--ignore-fail-on-non-empty` to suppress error messages when attempting to remove non-empty directories. The `-v` verbose flag displays information about each directory removal.

**Key points**: For removing non-empty directories, use `rm -r` instead of `rmdir`. The `rmdir` command provides safety by refusing to remove directories containing data.

### File Searching

File searching commands locate files and programs within the filesystem using different search methods and criteria.

#### Find Command (`find`)

The `find` command performs comprehensive file system searches with extensive filtering and action capabilities.

##### Basic Search Syntax

Use `find /path/to/search -name "filename"` for basic filename searches. The search path can be a specific directory or multiple directories. Use `.` for the current directory or `/` for system-wide searches.

##### Name-Based Searching

Search by exact filename using `-name "filename"` or case-insensitive searches with `-iname "filename"`. Use wildcards with quotes: `find . -name "*.txt"` finds all text files in the current directory and subdirectories.

##### Type-Based Filtering

Filter results by file type using `-type` followed by a type identifier: `f` for regular files, `d` for directories, `l` for symbolic links, `b` for block devices, and `c` for character devices.

##### Size-Based Searching

Search by file size using `-size` with size specifications: `+100M` for files larger than 100 megabytes, `-1G` for files smaller than 1 gigabyte, or exact sizes like `512k` for 512 kilobytes.

##### Time-Based Searching

Find files by modification time using `-mtime`: `-mtime +7` finds files modified more than 7 days ago, `-mtime -1` finds files modified within the last day. Use `-atime` for access time and `-ctime` for change time.

**Key points**: Use `-exec` to perform actions on found files: `find . -name "*.tmp" -exec rm {} \;` deletes all temporary files. The `{}` placeholder represents each found file, and `\;` terminates the command.

##### Permission-Based Searching

Search by file permissions using `-perm`: `-perm 644` finds files with exact permissions, `-perm -644` finds files with at least these permissions, and `-perm /644` finds files with any of these permissions.

##### Advanced Options

Combine multiple criteria with logical operators: `-and`, `-or`, and `-not`. Use parentheses for grouping complex expressions. The `-maxdepth` option limits search depth, while `-mindepth` sets minimum depth requirements.

#### Locate Command (`locate`)

The `locate` command provides fast filename searches using a pre-built database of file locations.

##### Database-Based Searching

The `locate` command searches a database typically updated daily by the `updatedb` command. This approach provides much faster searches compared to `find` but may not reflect recent filesystem changes.

##### Basic Usage

Search for files using `locate filename` or `locate pattern`. The command returns all paths containing the search term, making it effective for partial filename matches.

##### Case Sensitivity

Use `-i` for case-insensitive searches. The `--regex` option enables regular expression pattern matching for complex search patterns.

**Key points**: Update the locate database manually using `sudo updatedb` to include recent file changes. The database may not include files in certain directories like `/tmp` or user home directories depending on system configuration.

##### Limiting Results

Use `-n` or `--limit` to restrict the number of results returned: `locate -n 10 filename` returns only the first 10 matches.

#### Which Command (`which`)

The `which` command locates executable programs in the system PATH.

##### Executable Location

Use `which program_name` to find the full path of executable programs. This command searches directories listed in the PATH environment variable and returns the first match found.

##### Multiple Matches

The `-a` or `--all` flag displays all matching executables in PATH rather than just the first match. This helps identify multiple versions of the same program installed in different locations.

**Key points**: The `which` command only finds executable files in PATH directories. Use `whereis` to locate binary files, source code, and manual pages for programs.

##### Shell Built-ins

The `which` command may not locate shell built-in commands. Use `type` command instead to identify built-ins, aliases, and functions in addition to executable files.

### File Linking

File linking creates connections between files using hard links and symbolic links, each with distinct characteristics and use cases.

#### Hard Links

Hard links create multiple directory entries pointing to the same inode, effectively creating multiple names for the same file data.

##### Creating Hard Links

Create hard links using `ln source_file link_name`. The original file and hard link are indistinguishable at the filesystem level, both pointing to identical data.

##### Hard Link Characteristics

Hard links share the same inode number, file size, permissions, and timestamps. Modifying content through any hard link affects all links since they reference the same data. Deleting one hard link doesn't affect others until all links are removed.

##### Limitations

Hard links cannot cross filesystem boundaries and cannot link to directories (except by root in some filesystems). They only work within the same partition or mounted filesystem.

**Key points**: Use `ls -li` to display inode numbers and link counts. Files with link counts greater than 1 have multiple hard links. Hard links provide data redundancy without consuming additional disk space.

##### Link Count Management

The link count displayed by `ls -l` shows the number of hard links to a file. When the link count reaches zero, the filesystem reclaims the file's storage space.

#### Symbolic Links (Soft Links)

Symbolic links create pointer files that reference other files or directories by pathname.

##### Creating Symbolic Links

Create symbolic links using `ln -s target link_name`. The target can be an absolute or relative path to a file or directory.

##### Symbolic Link Characteristics

Symbolic links have their own inode and contain the path to the target file. They can cross filesystem boundaries and link to directories. If the target is deleted, the symbolic link becomes broken but continues to exist.

##### Absolute vs Relative Links

Absolute symbolic links contain full pathnames starting from the root directory: `ln -s /home/user/file.txt link`. Relative symbolic links use paths relative to the link's location: `ln -s ../file.txt link`.

**Key points**: Use `ls -l` to identify symbolic links, which display as `link_name -> target_path`. Broken symbolic links appear in different colors or styles in most terminal configurations.

##### Link Management

Use `readlink` to display the target of symbolic links: `readlink link_name` shows where the link points. The `-f` flag resolves the complete path by following all symbolic links in the chain.

##### Directory Linking

Symbolic links to directories enable flexible filesystem organization. Commands like `cd` follow symbolic directory links, but `pwd` may show the link path or actual path depending on shell settings.

**Conclusion**: File operations form the core of Linux system administration and daily usage. Mastering these commands enables efficient file management, system maintenance, and automation through shell scripting.

**Next steps**: Practice combining these commands in shell scripts, explore advanced options and flags for each command, and learn about file permissions and ownership to complement file operation skills.

---

