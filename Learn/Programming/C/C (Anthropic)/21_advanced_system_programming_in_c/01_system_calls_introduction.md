## System Calls Introduction


System calls are the interface between user-space programs and the operating system kernel. They provide controlled access to system resources and services that applications cannot directly access due to security and stability requirements.

**System Call Mechanism** When a program makes a system call, execution transfers from user mode to kernel mode through a software interrupt or trap instruction. The kernel validates the request, performs the operation, and returns results to the calling program.

**Categories of System Calls**

- **Process Control**: fork(), exec(), wait(), exit()
- **File Operations**: open(), read(), write(), close()
- **Device Management**: ioctl(), mmap()
- **Information Maintenance**: getpid(), time(), sysinfo()
- **Communication**: pipe(), socket(), msgget()

**Error Handling** System calls typically return -1 on error and set the global variable `errno` to indicate the specific error condition:

```c
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

int main() {
    int fd = open("nonexistent.txt", O_RDONLY);
    if (fd == -1) {
        printf("Error: %s\n", strerror(errno));
        // Or use perror() for simpler error reporting
        perror("open");
        return 1;
    }
    
    close(fd);
    return 0;
}
```

**Examples**

**Basic File Operations**

```c
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>

int copy_file(const char* source, const char* dest) {
    int src_fd, dest_fd;
    char buffer[4096];
    ssize_t bytes_read, bytes_written;
    
    // Open source file for reading
    src_fd = open(source, O_RDONLY);
    if (src_fd == -1) {
        perror("open source");
        return -1;
    }
    
    // Create destination file with permissions 0644
    dest_fd = open(dest, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (dest_fd == -1) {
        perror("open destination");
        close(src_fd);
        return -1;
    }
    
    // Copy data
    while ((bytes_read = read(src_fd, buffer, sizeof(buffer))) > 0) {
        bytes_written = write(dest_fd, buffer, bytes_read);
        if (bytes_written != bytes_read) {
            perror("write");
            break;
        }
    }
    
    if (bytes_read == -1) {
        perror("read");
    }
    
    close(src_fd);
    close(dest_fd);
    return (bytes_read == -1) ? -1 : 0;
}
```

**System Information Retrieval**

```c
#include <sys/utsname.h>
#include <sys/sysinfo.h>
#include <unistd.h>
#include <stdio.h>

void print_system_info() {
    struct utsname system_info;
    struct sysinfo sys_info;
    
    // Get system identification
    if (uname(&system_info) == 0) {
        printf("System: %s\n", system_info.sysname);
        printf("Node: %s\n", system_info.nodename);
        printf("Release: %s\n", system_info.release);
        printf("Version: %s\n", system_info.version);
        printf("Machine: %s\n", system_info.machine);
    }
    
    // Get system statistics (Linux-specific)
    if (sysinfo(&sys_info) == 0) {
        printf("Uptime: %ld seconds\n", sys_info.uptime);
        printf("Total RAM: %lu MB\n", sys_info.totalram / (1024 * 1024));
        printf("Free RAM: %lu MB\n", sys_info.freeram / (1024 * 1024));
        printf("Process count: %d\n", sys_info.procs);
    }
    
    // Get process ID information
    printf("PID: %d\n", getpid());
    printf("Parent PID: %d\n", getppid());
    printf("User ID: %d\n", getuid());
    printf("Group ID: %d\n", getgid());
}
```

**Directory Operations**

```c
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>
#include <stdio.h>
#include <string.h>

void list_directory(const char* path) {
    DIR* dir;
    struct dirent* entry;
    struct stat file_stat;
    char full_path[1024];
    
    dir = opendir(path);
    if (dir == NULL) {
        perror("opendir");
        return;
    }
    
    printf("Contents of %s:\n", path);
    while ((entry = readdir(dir)) != NULL) {
        // Skip . and .. entries
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }
        
        // Build full path for stat()
        snprintf(full_path, sizeof(full_path), "%s/%s", path, entry->d_name);
        
        if (stat(full_path, &file_stat) == 0) {
            char type = S_ISDIR(file_stat.st_mode) ? 'd' : 
                       S_ISREG(file_stat.st_mode) ? 'f' : '?';
            printf("%c %8ld %s\n", type, file_stat.st_size, entry->d_name);
        } else {
            printf("? %8s %s\n", "???", entry->d_name);
        }
    }
    
    closedir(dir);
}
```

**Key Points**

- System calls provide controlled kernel access
- Error checking is essential for robust programs
- System calls are platform-specific (POSIX provides portability)
- Performance considerations: system calls have overhead
- Some operations may be interrupted by signals (EINTR)

