## Concurrency


### Pthreads

Pthreads, short for POSIX Threads, is a standard API (Application Programming Interface) for creating and manipulating threads in Unix-like operating systems such as Linux, macOS, and FreeBSD. Pthreads provides a set of functions and data types that allow programmers to create and manage multithreaded applications.

Here are some key aspects of Pthreads:

1. **Thread Creation and Management**:
    
    * Pthreads allows programmers to create and manage threads within a process.
    * Threads are lightweight processes that share the same memory space and resources of the parent process.
2. **Thread Functions**:
    
    * Pthreads provides functions for creating, joining, and detaching threads.
    * `pthread_create`: Used to create a new thread.
    * `pthread_join`: Waits for a thread to terminate.
    * `pthread_detach`: Detaches a thread, allowing it to terminate independently.
3. **Thread Synchronization**:
    
    * Pthreads provides synchronization primitives such as mutexes, condition variables, and barriers for coordinating access to shared resources and data between threads.
    * Mutexes: Used to protect critical sections of code from concurrent access by multiple threads.
    * Condition Variables: Used for signaling and waiting for specific conditions to occur.
    * Barriers: Used to synchronize a group of threads, forcing them to wait until all threads have reached a certain point in the code before continuing.
4. **Thread Safety**:
    
    * Pthreads functions and data structures are designed to be thread-safe, meaning they can be safely used by multiple threads concurrently.
    * However, it is the responsibility of the programmer to ensure proper synchronization and avoid data races and other concurrency issues.
5. **Portability**:
    
    * Pthreads is a POSIX standard, which means that applications written using Pthreads should be portable across different Unix-like operating systems that support POSIX threads.
6. **Example**:
    
    * Here's a simple example of using Pthreads to create and manage threads in a C program:
    
    ```c
    #include <pthread.h>
    #include <stdio.h>
    #include <stdlib.h>
    
    #define NUM_THREADS 5
    
    void *printHello(void *threadID) {
        long tid;
        tid = (long) threadID;
        printf("Hello World! It's me, thread #%ld!\n", tid);
        pthread_exit(NULL);
    }
    
    int main() {
        pthread_t threads[NUM_THREADS];
        int rc;
        long t;
    
        for (t = 0; t < NUM_THREADS; t++) {
            printf("Creating thread %ld\n", t);
            rc = pthread_create(&threads[t], NULL, printHello, (void *) t);
            if (rc) {
                printf("ERROR: return code from pthread_create() is %d\n", rc);
                exit(-1);
            }
        }
    
        pthread_exit(NULL);
    }
    ```
    
    * In this example, `pthread_create` is used to create multiple threads, each of which executes the `printHello` function. The `pthread_exit` function is used to exit the thread.

Pthreads is a powerful and widely used API for multithreading in Unix-like systems. It allows developers to write concurrent programs that take advantage of modern multi-core processors and improve performance through parallelism.

