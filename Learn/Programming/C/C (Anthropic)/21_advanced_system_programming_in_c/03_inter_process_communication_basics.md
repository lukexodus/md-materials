## Inter-process Communication Basics


Inter-process communication (IPC) enables processes to exchange data and coordinate activities. POSIX provides several IPC mechanisms with different characteristics and use cases.

**Pipes** Pipes provide unidirectional communication between processes:

```c
#include <unistd.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    int pipefd[2];
    pid_t pid;
    char write_msg[] = "Hello from parent";
    char read_msg[100];
    
    // Create pipe
    if (pipe(pipefd) == -1) {
        perror("pipe");
        exit(1);
    }
    
    pid = fork();
    if (pid == -1) {
        perror("fork");
        exit(1);
    }
    
    if (pid == 0) {
        // Child: read from pipe
        close(pipefd[1]);  // Close write end
        
        ssize_t bytes_read = read(pipefd[0], read_msg, sizeof(read_msg) - 1);
        if (bytes_read > 0) {
            read_msg[bytes_read] = '\0';
            printf("Child received: %s\n", read_msg);
        }
        
        close(pipefd[0]);
        exit(0);
    } else {
        // Parent: write to pipe
        close(pipefd[0]);  // Close read end
        
        write(pipefd[1], write_msg, strlen(write_msg));
        close(pipefd[1]);
        
        wait(NULL);  // Wait for child
    }
    
    return 0;
}
```

**Named Pipes (FIFOs)** Named pipes allow unrelated processes to communicate:

```c
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define FIFO_PATH "/tmp/myfifo"

// Writer process
void fifo_writer() {
    int fd;
    char* messages[] = {
        "First message",
        "Second message", 
        "Third message",
        NULL
    };
    
    // Create FIFO if it doesn't exist
    if (mkfifo(FIFO_PATH, 0666) == -1) {
        perror("mkfifo");
        // FIFO might already exist, continue
    }
    
    fd = open(FIFO_PATH, O_WRONLY);
    if (fd == -1) {
        perror("open");
        exit(1);
    }
    
    for (int i = 0; messages[i] != NULL; i++) {
        write(fd, messages[i], strlen(messages[i]) + 1);
        sleep(1);  // Delay between messages
    }
    
    close(fd);
}

// Reader process
void fifo_reader() {
    int fd;
    char buffer[256];
    ssize_t bytes_read;
    
    fd = open(FIFO_PATH, O_RDONLY);
    if (fd == -1) {
        perror("open");
        exit(1);
    }
    
    while ((bytes_read = read(fd, buffer, sizeof(buffer))) > 0) {
        printf("Received: %s\n", buffer);
    }
    
    close(fd);
    unlink(FIFO_PATH);  // Remove FIFO
}
```

**Examples**

**Message Queues**

```c
#include <sys/ipc.h>
#include <sys/msg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

struct message {
    long msg_type;
    char msg_text[256];
};

#define MSG_TYPE_1 1
#define MSG_TYPE_2 2

int create_message_queue() {
    key_t key = ftok("/tmp", 'M');  // Generate unique key
    if (key == -1) {
        perror("ftok");
        return -1;
    }
    
    int msgid = msgget(key, IPC_CREAT | 0666);
    if (msgid == -1) {
        perror("msgget");
        return -1;
    }
    
    return msgid;
}

void send_messages(int msgid) {
    struct message msg;
    
    // Send message type 1
    msg.msg_type = MSG_TYPE_1;
    strcpy(msg.msg_text, "Hello from sender!");
    
    if (msgsnd(msgid, &msg, strlen(msg.msg_text) + 1, 0) == -1) {
        perror("msgsnd");
        return;
    }
    
    // Send message type 2
    msg.msg_type = MSG_TYPE_2;
    strcpy(msg.msg_text, "Second message type");
    
    if (msgsnd(msgid, &msg, strlen(msg.msg_text) + 1, 0) == -1) {
        perror("msgsnd");
        return;
    }
    
    printf("Messages sent\n");
}

void receive_messages(int msgid) {
    struct message msg;
    
    // Receive message type 1
    if (msgrcv(msgid, &msg, sizeof(msg.msg_text), MSG_TYPE_1, 0) != -1) {
        printf("Received type 1: %s\n", msg.msg_text);
    }
    
    // Receive message type 2
    if (msgrcv(msgid, &msg, sizeof(msg.msg_text), MSG_TYPE_2, 0) != -1) {
        printf("Received type 2: %s\n", msg.msg_text);
    }
}

int main() {
    int msgid = create_message_queue();
    if (msgid == -1) {
        exit(1);
    }
    
    pid_t pid = fork();
    if (pid == -1) {
        perror("fork");
        exit(1);
    }
    
    if (pid == 0) {
        // Child: receive messages
        sleep(1);  // Ensure parent sends first
        receive_messages(msgid);
    } else {
        // Parent: send messages
        send_messages(msgid);
        wait(NULL);
        
        // Clean up message queue
        if (msgctl(msgid, IPC_RMID, NULL) == -1) {
            perror("msgctl");
        }
    }
    
    return 0;
}
```

**Shared Memory**

```c
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SHM_SIZE 1024

typedef struct {
    int counter;
    char data[256];
    int ready;
} shared_data_t;

int main() {
    key_t key = ftok("/tmp", 'S');
    if (key == -1) {
        perror("ftok");
        exit(1);
    }
    
    // Create shared memory segment
    int shmid = shmget(key, sizeof(shared_data_t), IPC_CREAT | 0666);
    if (shmid == -1) {
        perror("shmget");
        exit(1);
    }
    
    // Attach shared memory
    shared_data_t* shared = (shared_data_t*)shmat(shmid, NULL, 0);
    if (shared == (void*)-1) {
        perror("shmat");
        exit(1);
    }
    
    // Initialize shared data
    shared->counter = 0;
    shared->ready = 0;
    strcpy(shared->data, "Initial data");
    
    pid_t pid = fork();
    if (pid == -1) {
        perror("fork");
        exit(1);
    }
    
    if (pid == 0) {
        // Child: modify shared data
        sleep(1);
        shared->counter = 42;
        strcpy(shared->data, "Modified by child");
        shared->ready = 1;
        
        printf("Child: Set counter to %d\n", shared->counter);
        exit(0);
    } else {
        // Parent: wait for child to modify data
        while (!shared->ready) {
            usleep(100000);  // 100ms
        }
        
        printf("Parent: Counter is %d\n", shared->counter);
        printf("Parent: Data is '%s'\n", shared->data);
        
        wait(NULL);
        
        // Detach and remove shared memory
        shmdt(shared);
        if (shmctl(shmid, IPC_RMID, NULL) == -1) {
            perror("shmctl");
        }
    }
    
    return 0;
}
```

**Semaphores for Synchronization**

```c
#include <sys/ipc.h>
#include <sys/sem.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

// Semaphore operations
struct sembuf sem_lock = {0, -1, 0};    // P operation (wait)
struct sembuf sem_unlock = {0, 1, 0};   // V operation (signal)

int create_semaphore() {
    key_t key = ftok("/tmp", 'E');
    if (key == -1) {
        perror("ftok");
        return -1;
    }
    
    int semid = semget(key, 1, IPC_CREAT | 0666);
    if (semid == -1) {
        perror("semget");
        return -1;
    }
    
    // Initialize semaphore to 1 (binary semaphore)
    if (semctl(semid, 0, SETVAL, 1) == -1) {
        perror("semctl");
        return -1;
    }
    
    return semid;
}

void critical_section(int process_id, int semid) {
    // Acquire semaphore (enter critical section)
    if (semop(semid, &sem_lock, 1) == -1) {
        perror("semop lock");
        return;
    }
    
    printf("Process %d: Entering critical section\n", process_id);
    sleep(2);  // Simulate work in critical section
    printf("Process %d: Leaving critical section\n", process_id);
    
    // Release semaphore (exit critical section)
    if (semop(semid, &sem_unlock, 1) == -1) {
        perror("semop unlock");
    }
}

int main() {
    int semid = create_semaphore();
    if (semid == -1) {
        exit(1);
    }
    
    // Create multiple processes
    for (int i = 0; i < 3; i++) {
        pid_t pid = fork();
        if (pid == -1) {
            perror("fork");
            break;
        } else if (pid == 0) {
            // Child process
            critical_section(i, semid);
            exit(0);
        }
    }
    
    // Parent waits for all children
    for (int i = 0; i < 3; i++) {
        wait(NULL);
    }
    
    // Clean up semaphore
    if (semctl(semid, 0, IPC_RMID) == -1) {
        perror("semctl");
    }
    
    return 0;
}
```

**Key Points**

- Pipes provide simple parent-child communication
- Named pipes (FIFOs) allow unrelated process communication
- Message queues provide structured message passing
- Shared memory offers fastest IPC but requires synchronization
- Semaphores coordinate access to shared resources
- Each IPC mechanism has different performance and complexity trade-offs

