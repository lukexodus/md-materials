## Low-level I/O Operations


Low-level I/O operations interact directly with the kernel's file system interface, providing fine-grained control over data transfer, buffering, and file manipulation that higher-level functions like fread() and fwrite() abstract away.

**File Descriptor Operations** File descriptors are small integers that identify open files in the kernel:

```c
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>

int main() {
    int fd;
    char buffer[1024];
    ssize_t bytes_read, bytes_written;
    
    // Open file for reading
    fd = open("input.txt", O_RDONLY);
    if (fd == -1) {
        perror("open");
        return 1;
    }
    
    // Read data
    bytes_read = read(fd, buffer, sizeof(buffer) - 1);
    if (bytes_read == -1) {
        perror("read");
        close(fd);
        return 1;
    }
    
    buffer[bytes_read] = '\0';  // Null terminate for printing
    printf("Read %zd bytes: %s\n", bytes_read, buffer);
    
    close(fd);
    
    // Open file for writing
    fd = open("output.txt", O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd == -1) {
        perror("open");
        return 1;
    }
    
    // Write data
    bytes_written = write(fd, buffer, bytes_read);
    if (bytes_written == -1) {
        perror("write");
        close(fd);
        return 1;
    }
    
    printf("Wrote %zd bytes\n", bytes_written);
    close(fd);
    
    return 0;
}
```

**File Control Operations** The `fcntl()` function provides advanced file control:

```c
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>

void demonstrate_fcntl() {
    int fd = open("testfile.txt", O_RDWR | O_CREAT, 0644);
    if (fd == -1) {
        perror("open");
        return;
    }
    
    // Get current file flags
    int flags = fcntl(fd, F_GETFL);
    if (flags == -1) {
        perror("fcntl F_GETFL");
        close(fd);
        return;
    }
    
    printf("Current flags: ");
    if (flags & O_RDONLY) printf("O_RDONLY ");
    if (flags & O_WRONLY) printf("O_WRONLY ");
    if (flags & O_RDWR) printf("O_RDWR ");
    if (flags & O_APPEND) printf("O_APPEND ");
    if (flags & O_NONBLOCK) printf("O_NONBLOCK ");
    printf("\n");
    
    // Add non-blocking flag
    if (fcntl(fd, F_SETFL, flags | O_NONBLOCK) == -1) {
        perror("fcntl F_SETFL");
    } else {
        printf("Added O_NONBLOCK flag\n");
    }
    
    // File locking
    struct flock lock;
    lock.l_type = F_WRLCK;      // Write lock
    lock.l_whence = SEEK_SET;   // From beginning of file
    lock.l_start = 0;           // Offset
    lock.l_len = 0;             // Lock entire file (0 = to EOF)
    
    if (fcntl(fd, F_SETLK, &lock) == -1) {
        if (errno == EACCES || errno == EAGAIN) {
            printf("File is already locked\n");
        } else {
            perror("fcntl F_SETLK");
        }
    } else {
        printf("File locked successfully\n");
        
        // Do work with locked file
        write(fd, "Locked data\n", 12);
        
        // Unlock file
        lock.l_type = F_UNLCK;
        fcntl(fd, F_SETLK, &lock);
        printf("File unlocked\n");
    }
    
    close(fd);
}
```

**Examples**

**Memory-mapped I/O**

```c
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int memory_mapped_io(const char* filename) {
    int fd;
    struct stat file_stat;
    char* mapped_data;
    
    // Open file
    fd = open(filename, O_RDWR);
    if (fd == -1) {
        perror("open");
        return -1;
    }
    
    // Get file size
    if (fstat(fd, &file_stat) == -1) {
        perror("fstat");
        close(fd);
        return -1;
    }
    
    // Map file into memory
    mapped_data = mmap(NULL, file_stat.st_size, PROT_READ | PROT_WRITE, 
                      MAP_SHARED, fd, 0);
    if (mapped_data == MAP_FAILED) {
        perror("mmap");
        close(fd);
        return -1;
    }
    
    printf("File size: %ld bytes\n", file_stat.st_size);
    printf("First 100 characters:\n%.100s\n", mapped_data);
    
    // Modify data in memory (automatically synced to file)
    if (file_stat.st_size > 10) {
        memcpy(mapped_data, "MODIFIED: ", 10);
        
        // Force synchronization to disk
        if (msync(mapped_data, file_stat.st_size, MS_SYNC) == -1) {
            perror("msync");
        }
    }
    
    // Unmap memory
    if (munmap(mapped_data, file_stat.st_size) == -1) {
        perror("munmap");
    }
    
    close(fd);
    return 0;
}

int main() {
    // Create test file
    int fd = open("mmap_test.txt", O_CREAT | O_WRONLY | O_TRUNC, 0644);
    if (fd != -1) {
        write(fd, "This is a test file for memory mapping operations.\n", 51);
        close(fd);
    }
    
    memory_mapped_io("mmap_test.txt");
    return 0;
}
```

**Asynchronous I/O**
```c
#include <aio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <time.h>

void demonstrate_async_io() {
    int fd;
    struct aiocb read_cb, write_cb;
    char read_buffer[1024];
    char write_data[] = "Asynchronous write operation data\n";
    
    // Open file for async operations
    fd = open("async_test.txt", O_RDWR | O_CREAT | O_TRUNC, 0644);
    if (fd == -1) {
        perror("open");
        return;
    }
    
    // Initialize write control block
    memset(&write_cb, 0, sizeof(struct aiocb));
    write_cb.aio_fildes = fd;
    write_cb.aio_buf = write_data;
    write_cb.aio_nbytes = strlen(write_data);
    write_cb.aio_offset = 0;
    
    // Start asynchronous write
    if (aio_write(&write_cb) == -1) {
        perror("aio_write");
        close(fd);
        return;
    }
    
    printf("Asynchronous write started...\n");
    
    // Do other work while write completes
    printf("Doing other work while I/O completes...\n");
    for (int i = 0; i < 3; i++) {
        printf("Working... %d\n", i + 1);
        sleep(1);
    }
    
    // Wait for write to complete
    while (aio_error(&write_cb) == EINPROGRESS) {
        printf("Write still in progress...\n");
        usleep(100000);  // 100ms
    }
    
    int write_result = aio_return(&write_cb);
    if (write_result == -1) {
        perror("aio_return write");
    } else {
        printf("Async write completed: %d bytes written\n", write_result);
    }
    
    // Initialize read control block
    memset(&read_cb, 0, sizeof(struct aiocb));
    read_cb.aio_fildes = fd;
    read_cb.aio_buf = read_buffer;
    read_cb.aio_nbytes = sizeof(read_buffer) - 1;
    read_cb.aio_offset = 0;
    
    // Start asynchronous read
    if (aio_read(&read_cb) == -1) {
        perror("aio_read");
        close(fd);
        return;
    }
    
    // Wait for read to complete
    while (aio_error(&read_cb) == EINPROGRESS) {
        printf("Read in progress...\n");
        usleep(100000);
    }
    
    int read_result = aio_return(&read_cb);
    if (read_result == -1) {
        perror("aio_return read");
    } else {
        read_buffer[read_result] = '\0';
        printf("Async read completed: %d bytes read\n", read_result);
        printf("Data: %s", read_buffer);
    }
    
    close(fd);
}
```

**Vectored I/O (readv/writev)**
```c
#include <sys/uio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

void demonstrate_vectored_io() {
    int fd;
    struct iovec write_iov[3], read_iov[3];
    char buffer1[50], buffer2[50], buffer3[50];
    
    // Prepare data for vectored write
    char* data1 = "First part of data\n";
    char* data2 = "Second part of data\n";
    char* data3 = "Third part of data\n";
    
    write_iov[0].iov_base = data1;
    write_iov[0].iov_len = strlen(data1);
    write_iov[1].iov_base = data2;
    write_iov[1].iov_len = strlen(data2);
    write_iov[2].iov_base = data3;
    write_iov[2].iov_len = strlen(data3);
    
    // Open file for vectored I/O
    fd = open("vectored_test.txt", O_RDWR | O_CREAT | O_TRUNC, 0644);
    if (fd == -1) {
        perror("open");
        return;
    }
    
    // Perform vectored write
    ssize_t bytes_written = writev(fd, write_iov, 3);
    if (bytes_written == -1) {
        perror("writev");
        close(fd);
        return;
    }
    
    printf("Vectored write: %zd bytes written\n", bytes_written);
    
    // Reset file position for reading
    lseek(fd, 0, SEEK_SET);
    
    // Prepare buffers for vectored read
    read_iov[0].iov_base = buffer1;
    read_iov[0].iov_len = sizeof(buffer1) - 1;
    read_iov[1].iov_base = buffer2;
    read_iov[1].iov_len = sizeof(buffer2) - 1;
    read_iov[2].iov_base = buffer3;
    read_iov[2].iov_len = sizeof(buffer3) - 1;
    
    // Perform vectored read
    ssize_t bytes_read = readv(fd, read_iov, 3);
    if (bytes_read == -1) {
        perror("readv");
        close(fd);
        return;
    }
    
    printf("Vectored read: %zd bytes read\n", bytes_read);
    
    // Null terminate and print buffers
    buffer1[read_iov[0].iov_len] = '\0';
    buffer2[read_iov[1].iov_len] = '\0';
    buffer3[read_iov[2].iov_len] = '\0';
    
    printf("Buffer 1: %s", buffer1);
    printf("Buffer 2: %s", buffer2);
    printf("Buffer 3: %s", buffer3);
    
    close(fd);
}
```

**File Hole Creation (Sparse Files)**
```c
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/stat.h>

void create_sparse_file() {
    int fd;
    struct stat file_stat;
    char data[] = "Data at beginning";
    char end_data[] = "Data at end";
    
    // Create sparse file
    fd = open("sparse_test.txt", O_CREAT | O_WRONLY | O_TRUNC, 0644);
    if (fd == -1) {
        perror("open");
        return;
    }
    
    // Write data at beginning
    write(fd, data, sizeof(data) - 1);
    
    // Seek to create a hole (1MB gap)
    if (lseek(fd, 1024 * 1024, SEEK_CUR) == -1) {
        perror("lseek");
        close(fd);
        return;
    }
    
    // Write data after the hole
    write(fd, end_data, sizeof(end_data) - 1);
    
    close(fd);
    
    // Check file properties
    if (stat("sparse_test.txt", &file_stat) == 0) {
        printf("File size: %ld bytes\n", file_stat.st_size);
        printf("Disk blocks used: %ld\n", file_stat.st_blocks);
        printf("Block size: %ld bytes\n", file_stat.st_blksize);
        
        // Calculate actual disk usage
        long disk_usage = file_stat.st_blocks * 512;  // 512 is typical block size
        printf("Actual disk usage: %ld bytes\n", disk_usage);
        printf("Space saved: %ld bytes\n", file_stat.st_size - disk_usage);
    }
}
```

**I/O Multiplexing with select()**
```c
#include <sys/select.h>
#include <sys/time.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>

void demonstrate_io_multiplexing() {
    int fd1, fd2;
    fd_set read_fds;
    struct timeval timeout;
    char buffer[256];
    
    // Open two files for reading
    fd1 = open("file1.txt", O_RDONLY | O_NONBLOCK);
    fd2 = open("file2.txt", O_RDONLY | O_NONBLOCK);
    
    if (fd1 == -1 || fd2 == -1) {
        perror("open");
        return;
    }
    
    printf("Monitoring multiple file descriptors...\n");
    
    while (1) {
        // Initialize file descriptor set
        FD_ZERO(&read_fds);
        FD_SET(fd1, &read_fds);
        FD_SET(fd2, &read_fds);
        FD_SET(STDIN_FILENO, &read_fds);  // Also monitor stdin
        
        // Set timeout
        timeout.tv_sec = 5;
        timeout.tv_usec = 0;
        
        int max_fd = (fd1 > fd2) ? fd1 : fd2;
        max_fd = (max_fd > STDIN_FILENO) ? max_fd : STDIN_FILENO;
        
        // Wait for activity on file descriptors
        int activity = select(max_fd + 1, &read_fds, NULL, NULL, &timeout);
        
        if (activity == -1) {
            perror("select");
            break;
        } else if (activity == 0) {
            printf("Timeout occurred\n");
            break;
        }
        
        // Check which file descriptors are ready
        if (FD_ISSET(fd1, &read_fds)) {
            ssize_t bytes = read(fd1, buffer, sizeof(buffer) - 1);
            if (bytes > 0) {
                buffer[bytes] = '\0';
                printf("fd1: %s", buffer);
            } else if (bytes == 0) {
                printf("fd1: EOF reached\n");
                FD_CLR(fd1, &read_fds);
            }
        }
        
        if (FD_ISSET(fd2, &read_fds)) {
            ssize_t bytes = read(fd2, buffer, sizeof(buffer) - 1);
            if (bytes > 0) {
                buffer[bytes] = '\0';
                printf("fd2: %s", buffer);
            } else if (bytes == 0) {
                printf("fd2: EOF reached\n");
                FD_CLR(fd2, &read_fds);
            }
        }
        
        if (FD_ISSET(STDIN_FILENO, &read_fds)) {
            ssize_t bytes = read(STDIN_FILENO, buffer, sizeof(buffer) - 1);
            if (bytes > 0) {
                buffer[bytes] = '\0';
                printf("stdin: %s", buffer);
                if (strncmp(buffer, "quit", 4) == 0) {
                    break;
                }
            }
        }
    }
    
    close(fd1);
    close(fd2);
}
```

**Direct I/O (Bypassing Page Cache)**
```c
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

void demonstrate_direct_io() {
    int fd;
    void* aligned_buffer;
    size_t buffer_size = 4096;  // Usually page size
    ssize_t bytes_written, bytes_read;
    
    // Allocate aligned buffer for direct I/O
    if (posix_memalign(&aligned_buffer, 512, buffer_size) != 0) {
        perror("posix_memalign");
        return;
    }
    
    // Fill buffer with test data
    memset(aligned_buffer, 'A', buffer_size);
    
    // Open file with direct I/O flag
    fd = open("direct_io_test.txt", O_RDWR | O_CREAT | O_DIRECT | O_SYNC, 0644);
    if (fd == -1) {
        perror("open with O_DIRECT");
        free(aligned_buffer);
        return;
    }
    
    printf("Performing direct I/O (bypassing page cache)\n");
    
    // Write data using direct I/O
    bytes_written = write(fd, aligned_buffer, buffer_size);
    if (bytes_written == -1) {
        perror("direct write");
    } else {
        printf("Direct write: %zd bytes written\n", bytes_written);
    }
    
    // Reset file position
    lseek(fd, 0, SEEK_SET);
    
    // Read data using direct I/O
    memset(aligned_buffer, 0, buffer_size);  // Clear buffer
    bytes_read = read(fd, aligned_buffer, buffer_size);
    if (bytes_read == -1) {
        perror("direct read");
    } else {
        printf("Direct read: %zd bytes read\n", bytes_read);
        printf("First 50 characters: %.50s\n", (char*)aligned_buffer);
    }
    
    close(fd);
    free(aligned_buffer);
}
```

**Key Points**
- Low-level I/O provides direct kernel interface access
- File descriptors are the fundamental abstraction for I/O
- Memory mapping can improve performance for large files
- Asynchronous I/O enables non-blocking operations [Inference]
- Vectored I/O reduces system call overhead for multiple buffers
- Direct I/O bypasses system caching for specialized applications [Inference]
- I/O multiplexing allows monitoring multiple file descriptors simultaneously
- Proper error handling is critical for robust system programming
- Buffer alignment requirements exist for some operations (like direct I/O)
- Understanding system call overhead helps optimize I/O-intensive applications [Inference]

**Next Steps**
Advanced system programming builds upon these fundamentals to create complex system software including device drivers, operating system components, network servers, and real-time applications. Mastery requires understanding memory management, synchronization primitives, signal handling, and platform-specific system interfaces.

---

