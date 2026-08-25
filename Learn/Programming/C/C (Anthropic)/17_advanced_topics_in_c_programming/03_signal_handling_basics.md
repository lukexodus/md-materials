## Signal Handling Basics


Signals are software interrupts that provide asynchronous communication between processes or from the operating system to a process. Signal handling allows programs to respond to external events gracefully.

**Common Signals**

- `SIGINT` (2) - Interrupt from keyboard (Ctrl+C)
- `SIGTERM` (15) - Termination request
- `SIGSEGV` (11) - Segmentation violation
- `SIGFPE` (8) - Floating point exception
- `SIGALRM` (14) - Timer alarm
- `SIGUSR1`, `SIGUSR2` - User-defined signals

**Signal Handling Functions**

```c
#include <signal.h>

// Install signal handler
signal(int signum, void (*handler)(int));

// More advanced signal handling
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact);
```

**Basic Signal Handler**

```c
#include <stdio.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>

volatile sig_atomic_t keep_running = 1;

void signal_handler(int signum) {
    switch (signum) {
        case SIGINT:
            printf("\nReceived SIGINT (Ctrl+C)\n");
            keep_running = 0;
            break;
        case SIGTERM:
            printf("Received SIGTERM\n");
            keep_running = 0;
            break;
        default:
            printf("Received signal %d\n", signum);
    }
}

int main() {
    // Install signal handlers
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    
    printf("Program running. Press Ctrl+C to interrupt.\n");
    
    while (keep_running) {
        printf("Working...\n");
        sleep(1);
    }
    
    printf("Program terminating gracefully.\n");
    return 0;
}
```

**Examples**

**Advanced Signal Handling with sigaction()**

```c
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

void advanced_handler(int signum, siginfo_t *info, void *context) {
    printf("Signal %d received from PID %d\n", signum, info->si_pid);
    
    if (signum == SIGSEGV) {
        printf("Segmentation fault at address: %p\n", info->si_addr);
        exit(1);
    }
}

int main() {
    struct sigaction sa;
    
    // Configure signal handler
    sa.sa_sigaction = advanced_handler;
    sa.sa_flags = SA_SIGINFO;  // Use extended handler
    sigemptyset(&sa.sa_mask);
    
    // Install handler
    if (sigaction(SIGINT, &sa, NULL) == -1) {
        perror("sigaction");
        return 1;
    }
    
    pause();  // Wait for signal
    return 0;
}
```

**Timer-based Signals**

```c
#include <signal.h>
#include <unistd.h>
#include <stdio.h>

int timer_count = 0;

void alarm_handler(int signum) {
    timer_count++;
    printf("Timer tick %d\n", timer_count);
    
    if (timer_count < 5) {
        alarm(1);  // Set another 1-second alarm
    }
}

int main() {
    signal(SIGALRM, alarm_handler);
    
    printf("Starting timer...\n");
    alarm(1);  // Set 1-second alarm
    
    // Keep program alive
    while (timer_count < 5) {
        pause();  // Wait for signals
    }
    
    printf("Timer finished.\n");
    return 0;
}
```

**Signal-safe Functions** [Unverified] Only async-signal-safe functions should be called from signal handlers. Safe functions include write(), but not printf().

```c
#include <signal.h>
#include <unistd.h>
#include <string.h>

void safe_handler(int signum) {
    char msg[] = "Signal received\n";
    write(STDERR_FILENO, msg, strlen(msg));
}
```

**Key Points**

- Signal handlers execute asynchronously
- Only async-signal-safe functions should be used in handlers [Unverified]
- Use `volatile sig_atomic_t` for variables accessed in handlers
- Signals can be blocked and unblocked
- Some signals cannot be caught (SIGKILL, SIGSTOP)

