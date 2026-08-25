## Process Basics


Processes are independent execution units managed by the operating system. Each process has its own memory space, file descriptors, and execution context. Understanding process lifecycle and management is fundamental to system programming.

**Process Creation** The `fork()` system call creates a new process by duplicating the current process:

```c
#include <unistd.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
    pid_t pid;
    int status;
    
    printf("Before fork: PID = %d\n", getpid());
    
    pid = fork();
    
    if (pid == -1) {
        perror("fork");
        exit(1);
    } else if (pid == 0) {
        // Child process
        printf("Child: PID = %d, Parent PID = %d\n", getpid(), getppid());
        sleep(2);
        printf("Child exiting\n");
        exit(42);
    } else {
        // Parent process
        printf("Parent: PID = %d, Child PID = %d\n", getpid(), pid);
        
        // Wait for child to complete
        wait(&status);
        
        if (WIFEXITED(status)) {
            printf("Child exited with status: %d\n", WEXITSTATUS(status));
        }
    }
    
    return 0;
}
```

**Process Replacement** The `exec()` family of functions replaces the current process image:

```c
#include <unistd.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
    pid_t pid = fork();
    
    if (pid == -1) {
        perror("fork");
        exit(1);
    } else if (pid == 0) {
        // Child: execute 'ls' command
        printf("Child executing ls command\n");
        execl("/bin/ls", "ls", "-l", ".", NULL);
        
        // If exec succeeds, this line never executes
        perror("execl");
        exit(1);
    } else {
        // Parent: wait for child
        int status;
        wait(&status);
        printf("Child process completed\n");
    }
    
    return 0;
}
```

**Examples**

**Process Tree Creation**

```c
#include <unistd.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>

void create_child_processes(int count) {
    for (int i = 0; i < count; i++) {
        pid_t pid = fork();
        
        if (pid == -1) {
            perror("fork");
            exit(1);
        } else if (pid == 0) {
            // Child process
            printf("Child %d: PID = %d, Parent = %d\n", 
                   i, getpid(), getppid());
            sleep(i + 1);  // Different sleep times
            exit(i);
        }
        // Parent continues to create more children
    }
    
    // Parent waits for all children
    for (int i = 0; i < count; i++) {
        int status;
        pid_t child_pid = wait(&status);
        printf("Child %d (PID %d) exited with status %d\n", 
               i, child_pid, WEXITSTATUS(status));
    }
}

int main() {
    printf("Creating 3 child processes\n");
    create_child_processes(3);
    printf("All children completed\n");
    return 0;
}
```

**Process Monitoring**

```c
#include <unistd.h>
#include <sys/wait.h>
#include <sys/resource.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void monitor_child_process(const char* program, char* args[]) {
    pid_t pid;
    int status;
    struct rusage usage;
    struct timespec start_time, end_time;
    
    clock_gettime(CLOCK_MONOTONIC, &start_time);
    
    pid = fork();
    if (pid == -1) {
        perror("fork");
        return;
    } else if (pid == 0) {
        execvp(program, args);
        perror("execvp");
        exit(1);
    }
    
    // Parent monitors child
    if (wait4(pid, &status, 0, &usage) == -1) {
        perror("wait4");
        return;
    }
    
    clock_gettime(CLOCK_MONOTONIC, &end_time);
    
    double elapsed = (end_time.tv_sec - start_time.tv_sec) + 
                    (end_time.tv_nsec - start_time.tv_nsec) / 1e9;
    
    printf("Process Statistics:\n");
    printf("Exit status: %d\n", WEXITSTATUS(status));
    printf("Wall time: %.3f seconds\n", elapsed);
    printf("User CPU time: %ld.%06ld seconds\n", 
           usage.ru_utime.tv_sec, usage.ru_utime.tv_usec);
    printf("System CPU time: %ld.%06ld seconds\n", 
           usage.ru_stime.tv_sec, usage.ru_stime.tv_usec);
    printf("Maximum RSS: %ld KB\n", usage.ru_maxrss);
    printf("Page faults: %ld\n", usage.ru_majflt + usage.ru_minflt);
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("Usage: %s <program> [args...]\n", argv[0]);
        return 1;
    }
    
    monitor_child_process(argv[1], &argv[1]);
    return 0;
}
```

**Daemon Process Creation**

```c
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>

int daemonize() {
    pid_t pid;
    
    // Fork first child
    pid = fork();
    if (pid < 0) {
        return -1;  // Fork failed
    }
    if (pid > 0) {
        exit(0);    // Parent exits
    }
    
    // Child continues
    if (setsid() < 0) {
        return -1;  // Failed to become session leader
    }
    
    // Fork second child to prevent acquiring controlling terminal
    pid = fork();
    if (pid < 0) {
        return -1;
    }
    if (pid > 0) {
        exit(0);    // First child exits
    }
    
    // Change working directory to root
    chdir("/");
    
    // Set file permissions mask
    umask(0);
    
    // Close file descriptors
    for (int fd = sysconf(_SC_OPEN_MAX); fd >= 0; fd--) {
        close(fd);
    }
    
    // Redirect stdin, stdout, stderr to /dev/null
    int fd = open("/dev/null", O_RDWR);
    if (fd != -1) {
        dup2(fd, STDIN_FILENO);
        dup2(fd, STDOUT_FILENO);
        dup2(fd, STDERR_FILENO);
        if (fd > STDERR_FILENO) {
            close(fd);
        }
    }
    
    return 0;
}

int main() {
    if (daemonize() == -1) {
        perror("daemonize");
        exit(1);
    }
    
    // Daemon is now running
    openlog("mydaemon", LOG_PID, LOG_DAEMON);
    syslog(LOG_INFO, "Daemon started");
    
    // Main daemon work loop
    while (1) {
        // Do daemon work
        syslog(LOG_INFO, "Daemon is working");
        sleep(60);  // Work every minute
    }
    
    closelog();
    return 0;
}
```

**Key Points**

- fork() creates identical process copies
- exec() family replaces process image
- wait() family synchronizes parent-child processes
- Process IDs (PID) uniquely identify processes
- Zombie processes occur when parent doesn't wait for child
- Orphan processes are adopted by init process

