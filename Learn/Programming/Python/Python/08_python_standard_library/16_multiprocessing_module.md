## `multiprocessing` Module


### Overview

The multiprocessing module is Python's standard library solution for parallel processing that bypasses the Global Interpreter Lock (GIL) by using separate processes instead of threads. It provides a Process-like interface similar to threading but creates actual system processes, enabling true parallelism for CPU-intensive tasks. The module supports spawning processes, sharing data between processes, and synchronization primitives.

### Core Concepts

#### Process vs Thread Distinction

Unlike threading, multiprocessing creates separate Python interpreter processes, each with its own memory space and GIL. This enables genuine parallel execution of CPU-bound tasks but introduces overhead for process creation and inter-process communication. Each process runs independently and cannot directly access variables from other processes.

#### Memory Model

Processes have separate memory spaces, meaning variables are not shared by default. Data sharing requires explicit mechanisms like shared memory objects, pipes, or queues. This isolation provides safety but requires careful design for data exchange between processes.

#### Process Creation Methods

The module supports three process start methods:

- **spawn**: Creates a fresh Python interpreter (default on Windows/macOS)
- **fork**: Copies the parent process (default on Unix, faster but can cause issues)
- **forkserver**: Uses a server process to create new processes (Unix only, safer than fork)

### Basic Process Creation

#### Process Class

```python
import multiprocessing
import time

def worker_function(name, duration):
    print(f"Worker {name} starting")
    time.sleep(duration)
    print(f"Worker {name} finished")

# Create and start process
process = multiprocessing.Process(target=worker_function, args=('A', 2))
process.start()
process.join()  # Wait for completion
```

#### Process with Return Values

```python
import multiprocessing

def calculate_square(number, result_queue):
    result = number ** 2
    result_queue.put((number, result))

def main():
    queue = multiprocessing.Queue()
    processes = []
    
    for i in range(5):
        p = multiprocessing.Process(target=calculate_square, args=(i, queue))
        processes.append(p)
        p.start()
    
    # Collect results
    results = []
    for _ in range(5):
        results.append(queue.get())
    
    # Wait for all processes
    for p in processes:
        p.join()
    
    print(results)

if __name__ == '__main__':
    main()
```

### Process Pools

#### Pool Class

The Pool class provides a convenient way to parallelize function calls across multiple processes:

```python
import multiprocessing

def square_number(n):
    return n ** 2

def main():
    with multiprocessing.Pool(processes=4) as pool:
        numbers = [1, 2, 3, 4, 5]
        results = pool.map(square_number, numbers)
        print(results)  # [1, 4, 9, 16, 25]

if __name__ == '__main__':
    main()
```

#### Pool Methods

**map()**: Applies function to each element in iterable

```python
results = pool.map(function, iterable)
```

**imap()**: Lazy version of map, returns iterator

```python
for result in pool.imap(function, iterable):
    print(result)
```

**map_async()**: Asynchronous version of map

```python
async_result = pool.map_async(function, iterable)
results = async_result.get(timeout=10)
```

**apply()**: Applies function to single set of arguments

```python
result = pool.apply(function, args=(arg1, arg2))
```

**apply_async()**: Asynchronous version of apply

```python
async_result = pool.apply_async(function, args=(arg1, arg2))
result = async_result.get()
```

**starmap()**: Like map but unpacks arguments

```python
def add_numbers(a, b):
    return a + b

pairs = [(1, 2), (3, 4), (5, 6)]
results = pool.starmap(add_numbers, pairs)
```

### Inter-Process Communication

#### Queue

Thread-safe, process-safe queue for passing data between processes:

```python
import multiprocessing
import time

def producer(queue, items):
    for item in items:
        queue.put(item)
        time.sleep(0.1)
    queue.put(None)  # Sentinel value

def consumer(queue):
    while True:
        item = queue.get()
        if item is None:
            break
        print(f"Consumed: {item}")

def main():
    queue = multiprocessing.Queue()
    items = [1, 2, 3, 4, 5]
    
    p1 = multiprocessing.Process(target=producer, args=(queue, items))
    p2 = multiprocessing.Process(target=consumer, args=(queue,))
    
    p1.start()
    p2.start()
    
    p1.join()
    p2.join()

if __name__ == '__main__':
    main()
```

#### Pipe

Two-way communication channel between processes:

```python
import multiprocessing

def sender(conn):
    conn.send(['hello', 'world'])
    conn.close()

def receiver(conn):
    data = conn.recv()
    print(f"Received: {data}")
    conn.close()

def main():
    parent_conn, child_conn = multiprocessing.Pipe()
    
    p1 = multiprocessing.Process(target=sender, args=(child_conn,))
    p2 = multiprocessing.Process(target=receiver, args=(parent_conn,))
    
    p1.start()
    p2.start()
    
    p1.join()
    p2.join()

if __name__ == '__main__':
    main()
```

### Shared Memory Objects

#### Value and Array

Shared memory objects that can be accessed by multiple processes:

```python
import multiprocessing
import time

def worker(shared_value, shared_array, index):
    # Modify shared value
    with shared_value.get_lock():
        shared_value.value += 1
    
    # Modify shared array
    shared_array[index] = shared_array[index] * 2

def main():
    # Shared integer
    shared_value = multiprocessing.Value('i', 0)  # 'i' for integer
    
    # Shared array of integers
    shared_array = multiprocessing.Array('i', [1, 2, 3, 4, 5])
    
    processes = []
    for i in range(5):
        p = multiprocessing.Process(target=worker, args=(shared_value, shared_array, i))
        processes.append(p)
        p.start()
    
    for p in processes:
        p.join()
    
    print(f"Final shared value: {shared_value.value}")
    print(f"Final shared array: {list(shared_array)}")

if __name__ == '__main__':
    main()
```

#### Manager Objects

More flexible shared objects with higher overhead:

```python
import multiprocessing

def worker(shared_dict, shared_list, name):
    shared_dict[name] = multiprocessing.current_process().pid
    shared_list.append(name)

def main():
    with multiprocessing.Manager() as manager:
        shared_dict = manager.dict()
        shared_list = manager.list()
        
        processes = []
        for i in range(3):
            name = f"Process-{i}"
            p = multiprocessing.Process(target=worker, args=(shared_dict, shared_list, name))
            processes.append(p)
            p.start()
        
        for p in processes:
            p.join()
        
        print(f"Shared dict: {dict(shared_dict)}")
        print(f"Shared list: {list(shared_list)}")

if __name__ == '__main__':
    main()
```

### Synchronization Primitives

#### Lock

Prevents multiple processes from accessing shared resources simultaneously:

```python
import multiprocessing
import time

def worker_with_lock(lock, shared_resource, worker_id):
    for i in range(3):
        with lock:
            print(f"Worker {worker_id}: Accessing shared resource")
            shared_resource.value += 1
            time.sleep(0.1)
            print(f"Worker {worker_id}: Resource value is {shared_resource.value}")

def main():
    lock = multiprocessing.Lock()
    shared_resource = multiprocessing.Value('i', 0)
    
    processes = []
    for i in range(3):
        p = multiprocessing.Process(target=worker_with_lock, args=(lock, shared_resource, i))
        processes.append(p)
        p.start()
    
    for p in processes:
        p.join()

if __name__ == '__main__':
    main()
```

#### Semaphore

Controls access to a resource with limited capacity:

```python
import multiprocessing
import time

def worker(semaphore, worker_id):
    with semaphore:
        print(f"Worker {worker_id}: Acquired semaphore")
        time.sleep(2)
        print(f"Worker {worker_id}: Releasing semaphore")

def main():
    # Allow only 2 processes to access resource simultaneously
    semaphore = multiprocessing.Semaphore(2)
    
    processes = []
    for i in range(5):
        p = multiprocessing.Process(target=worker, args=(semaphore, i))
        processes.append(p)
        p.start()
    
    for p in processes:
        p.join()

if __name__ == '__main__':
    main()
```

#### Event

Simple signaling mechanism between processes:

```python
import multiprocessing
import time

def waiter(event, name):
    print(f"{name}: Waiting for event")
    event.wait()
    print(f"{name}: Event received!")

def setter(event):
    time.sleep(3)
    print("Setting event")
    event.set()

def main():
    event = multiprocessing.Event()
    
    processes = []
    for i in range(3):
        p = multiprocessing.Process(target=waiter, args=(event, f"Waiter-{i}"))
        processes.append(p)
        p.start()
    
    setter_process = multiprocessing.Process(target=setter, args=(event,))
    setter_process.start()
    
    for p in processes:
        p.join()
    setter_process.join()

if __name__ == '__main__':
    main()
```

#### Condition

More complex synchronization primitive combining lock and event functionality:

```python
import multiprocessing
import time
import random

def consumer(condition, items):
    with condition:
        condition.wait_for(lambda: len(items) > 0)
        item = items.pop(0)
        print(f"Consumed: {item}")

def producer(condition, items):
    for i in range(5):
        item = random.randint(1, 100)
        with condition:
            items.append(item)
            print(f"Produced: {item}")
            condition.notify_all()
        time.sleep(1)

def main():
    with multiprocessing.Manager() as manager:
        condition = multiprocessing.Condition()
        items = manager.list()
        
        consumers = [multiprocessing.Process(target=consumer, args=(condition, items)) for _ in range(2)]
        producer_process = multiprocessing.Process(target=producer, args=(condition, items))
        
        for c in consumers:
            c.start()
        producer_process.start()
        
        producer_process.join()
        for c in consumers:
            c.terminate()

if __name__ == '__main__':
    main()
```

### Process Management

#### Process Properties and Methods

**Process Attributes:**

```python
import multiprocessing

def worker():
    print(f"PID: {multiprocessing.current_process().pid}")
    print(f"Name: {multiprocessing.current_process().name}")

process = multiprocessing.Process(target=worker, name="MyWorker")
print(f"Process name: {process.name}")
print(f"Process PID: {process.pid}")  # None until started
print(f"Is alive: {process.is_alive()}")

process.start()
print(f"Process PID: {process.pid}")
print(f"Is alive: {process.is_alive()}")

process.join()
print(f"Exit code: {process.exitcode}")
```

**Process Control:**

```python
import multiprocessing
import time

def long_running_task():
    for i in range(10):
        print(f"Working... {i}")
        time.sleep(1)

process = multiprocessing.Process(target=long_running_task)
process.start()

# Terminate after 3 seconds
time.sleep(3)
process.terminate()
process.join()

print(f"Process terminated with exit code: {process.exitcode}")
```

#### Process Monitoring

```python
import multiprocessing
import psutil  # External library for system monitoring

def monitor_processes(processes):
    while any(p.is_alive() for p in processes):
        for i, process in enumerate(processes):
            if process.is_alive():
                try:
                    proc_info = psutil.Process(process.pid)
                    cpu_percent = proc_info.cpu_percent()
                    memory_info = proc_info.memory_info()
                    print(f"Process {i}: CPU {cpu_percent}%, Memory {memory_info.rss / 1024 / 1024:.1f}MB")
                except psutil.NoSuchProcess:
                    pass
        time.sleep(1)
```

### Advanced Features

#### Custom Process Classes

```python
import multiprocessing
import time

class CustomProcess(multiprocessing.Process):
    def __init__(self, name, duration):
        super().__init__()
        self.name = name
        self.duration = duration
        self.result = None
    
    def run(self):
        print(f"Custom process {self.name} starting")
        time.sleep(self.duration)
        self.result = f"Completed {self.name}"
        print(f"Custom process {self.name} finished")

def main():
    processes = []
    for i in range(3):
        p = CustomProcess(f"Process-{i}", i + 1)
        processes.append(p)
        p.start()
    
    for p in processes:
        p.join()
        print(f"Result: {p.result}")

if __name__ == '__main__':
    main()
```

#### Process Context and Start Methods

```python
import multiprocessing

def worker(name):
    print(f"Worker {name} in process {multiprocessing.current_process().pid}")

def main():
    # Set start method (must be called before creating processes)
    multiprocessing.set_start_method('spawn', force=True)
    
    # Or use context for specific start method
    ctx = multiprocessing.get_context('spawn')
    
    processes = []
    for i in range(3):
        p = ctx.Process(target=worker, args=(f"Worker-{i}",))
        processes.append(p)
        p.start()
    
    for p in processes:
        p.join()

if __name__ == '__main__':
    main()
```

#### Error Handling in Processes

```python
import multiprocessing
import traceback

def worker_with_error(should_error):
    try:
        if should_error:
            raise ValueError("Intentional error")
        return "Success"
    except Exception as e:
        return f"Error: {str(e)}"

def error_callback(error):
    print(f"Error callback: {error}")

def success_callback(result):
    print(f"Success callback: {result}")

def main():
    with multiprocessing.Pool(processes=2) as pool:
        # Using error callbacks
        results = []
        for i, should_error in enumerate([False, True, False]):
            result = pool.apply_async(
                worker_with_error, 
                args=(should_error,),
                callback=success_callback,
                error_callback=error_callback
            )
            results.append(result)
        
        # Get results with timeout
        for i, result in enumerate(results):
            try:
                value = result.get(timeout=5)
                print(f"Result {i}: {value}")
            except multiprocessing.TimeoutError:
                print(f"Result {i}: Timeout")
            except Exception as e:
                print(f"Result {i}: Exception {e}")

if __name__ == '__main__':
    main()
```

### Performance Optimization

#### Choosing Optimal Process Count

```python
import multiprocessing
import time
import math

def cpu_intensive_task(n):
    # Simulate CPU-intensive work
    result = 0
    for i in range(n):
        result += math.sqrt(i)
    return result

def benchmark_processes(task_count, max_processes=None):
    if max_processes is None:
        max_processes = multiprocessing.cpu_count()
    
    tasks = [100000] * task_count
    
    for process_count in range(1, max_processes + 1):
        start_time = time.time()
        
        with multiprocessing.Pool(processes=process_count) as pool:
            results = pool.map(cpu_intensive_task, tasks)
        
        end_time = time.time()
        print(f"Processes: {process_count}, Time: {end_time - start_time:.2f}s")

def main():
    print(f"CPU count: {multiprocessing.cpu_count()}")
    benchmark_processes(8)

if __name__ == '__main__':
    main()
```

#### Memory-Efficient Processing

```python
import multiprocessing
import sys

def process_chunk(chunk):
    # Process data in chunks to manage memory
    result = []
    for item in chunk:
        # Simulate processing
        result.append(item * 2)
    return result

def chunk_data(data, chunk_size):
    for i in range(0, len(data), chunk_size):
        yield data[i:i + chunk_size]

def main():
    # Large dataset
    large_data = list(range(1000000))
    chunk_size = 10000
    
    chunks = list(chunk_data(large_data, chunk_size))
    
    with multiprocessing.Pool() as pool:
        results = pool.map(process_chunk, chunks)
    
    # Flatten results
    final_result = []
    for chunk_result in results:
        final_result.extend(chunk_result)
    
    print(f"Processed {len(final_result)} items")

if __name__ == '__main__':
    main()
```

### Common Patterns and Best Practices

#### Producer-Consumer Pattern

```python
import multiprocessing
import time
import random

def producer(queue, num_items):
    for i in range(num_items):
        item = random.randint(1, 100)
        queue.put(item)
        print(f"Produced: {item}")
        time.sleep(0.1)
    
    # Send sentinel values to stop consumers
    queue.put(None)

def consumer(queue, consumer_id):
    while True:
        item = queue.get()
        if item is None:
            queue.put(None)  # Pass sentinel to other consumers
            break
        
        # Simulate processing time
        time.sleep(0.2)
        print(f"Consumer {consumer_id} processed: {item}")

def main():
    queue = multiprocessing.Queue(maxsize=10)
    
    # Start producer
    producer_process = multiprocessing.Process(target=producer, args=(queue, 20))
    producer_process.start()
    
    # Start consumers
    consumers = []
    for i in range(3):
        consumer_process = multiprocessing.Process(target=consumer, args=(queue, i))
        consumers.append(consumer_process)
        consumer_process.start()
    
    # Wait for completion
    producer_process.join()
    for consumer_process in consumers:
        consumer_process.join()

if __name__ == '__main__':
    main()
```

#### Map-Reduce Pattern

```python
import multiprocessing
from collections import defaultdict
import string

def mapper(text_chunk):
    """Map phase: count words in text chunk"""
    word_count = defaultdict(int)
    words = text_chunk.lower().translate(str.maketrans('', '', string.punctuation)).split()
    
    for word in words:
        word_count[word] += 1
    
    return dict(word_count)

def reducer(word_counts_list):
    """Reduce phase: combine word counts"""
    total_counts = defaultdict(int)
    
    for word_counts in word_counts_list:
        for word, count in word_counts.items():
            total_counts[word] += count
    
    return dict(total_counts)

def main():
    # Sample text data
    text_data = [
        "Hello world hello universe",
        "World of multiprocessing is great",
        "Hello great world of Python"
    ]
    
    # Map phase
    with multiprocessing.Pool() as pool:
        map_results = pool.map(mapper, text_data)
    
    # Reduce phase
    final_counts = reducer(map_results)
    
    print("Word counts:", final_counts)

if __name__ == '__main__':
    main()
```

### Debugging and Logging

#### Logging in Multiprocessing

```python
import multiprocessing
import logging
import sys

def setup_logging():
    # Configure logging for multiprocessing
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(processName)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(sys.stdout),
            logging.FileHandler('multiprocessing.log')
        ]
    )

def worker(name, shared_queue):
    logger = logging.getLogger()
    logger.info(f"Worker {name} starting")
    
    try:
        # Simulate work
        result = sum(range(1000000))
        shared_queue.put((name, result))
        logger.info(f"Worker {name} completed with result {result}")
    except Exception as e:
        logger.error(f"Worker {name} failed: {e}")
        shared_queue.put((name, None))

def main():
    setup_logging()
    logger = logging.getLogger()
    
    queue = multiprocessing.Queue()
    processes = []
    
    for i in range(3):
        p = multiprocessing.Process(target=worker, args=(f"Worker-{i}", queue))
        processes.append(p)
        p.start()
        logger.info(f"Started process {p.name}")
    
    # Collect results
    results = []
    for _ in range(3):
        results.append(queue.get())
    
    for p in processes:
        p.join()
        logger.info(f"Process {p.name} joined")
    
    logger.info(f"All results: {results}")

if __name__ == '__main__':
    main()
```

#### Exception Handling and Debugging

```python
import multiprocessing
import traceback
import sys

def problematic_worker(x):
    if x == 3:
        raise ValueError(f"Problem with value {x}")
    return x * x

def safe_worker(x):
    try:
        return problematic_worker(x)
    except Exception as e:
        # Return error information instead of raising
        return {
            'error': str(e),
            'traceback': traceback.format_exc(),
            'input': x
        }

def main():
    data = [1, 2, 3, 4, 5]
    
    with multiprocessing.Pool() as pool:
        results = pool.map(safe_worker, data)
    
    for i, result in enumerate(results):
        if isinstance(result, dict) and 'error' in result:
            print(f"Error in item {i}: {result['error']}")
            print(f"Traceback: {result['traceback']}")
        else:
            print(f"Result {i}: {result}")

if __name__ == '__main__':
    main()
```

### Platform-Specific Considerations

#### Windows Considerations

On Windows, the entire script is re-imported when starting new processes, which can cause issues if not properly protected with `if __name__ == '__main__'`. The spawn start method is default and required.

#### Unix/Linux Considerations

Fork start method is default but can cause issues with threads or certain libraries. Consider using spawn or forkserver for better compatibility.

#### macOS Considerations

Recent versions default to spawn method. Fork method may cause crashes with certain GUI frameworks.

### Integration with Other Libraries

#### NumPy and Scientific Computing

```python
import multiprocessing
import numpy as np

def process_array_chunk(chunk):
    # Perform computation on numpy array chunk
    return np.sum(chunk ** 2)

def main():
    # Large numpy array
    large_array = np.random.rand(1000000)
    
    # Split into chunks
    num_processes = multiprocessing.cpu_count()
    chunks = np.array_split(large_array, num_processes)
    
    with multiprocessing.Pool() as pool:
        results = pool.map(process_array_chunk, chunks)
    
    total_result = sum(results)
    print(f"Total result: {total_result}")

if __name__ == '__main__':
    main()
```

#### Database Operations

```python
import multiprocessing
import sqlite3
import os

def init_worker():
    # Initialize database connection per process
    global db_conn
    db_conn = sqlite3.connect('worker.db')

def process_data_batch(batch):
    # Use the process-local database connection
    cursor = db_conn.cursor()
    results = []
    for item in batch:
        cursor.execute("SELECT * FROM table WHERE id = ?", (item,))
        results.append(cursor.fetchone())
    return results

def main():
    # Create database and table (simplified example)
    with sqlite3.connect('worker.db') as conn:
        conn.execute("CREATE TABLE IF NOT EXISTS table (id INTEGER, value TEXT)")
        conn.execute("INSERT INTO table VALUES (1, 'one'), (2, 'two'), (3, 'three')")
        conn.commit()
    
    data_batches = [[1, 2], [2, 3], [1, 3]]
    
    with multiprocessing.Pool(initializer=init_worker) as pool:
        results = pool.map(process_data_batch, data_batches)
    
    print("Results:", results)

if __name__ == '__main__':
    main()
```

### Memory Management and Resource Cleanup

#### Proper Resource Management

```python
import multiprocessing
import time
import resource

def memory_intensive_worker(size):
    # Allocate large amount of memory
    data = [0] * size
    
    # Get memory usage
    memory_usage = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
    
    # Process data
    result = sum(data)
    
    # Explicitly delete large objects
    del data
    
    return result, memory_usage

def monitor_memory():
    """Monitor system memory usage"""
    import psutil
    process = psutil.Process()
    return process.memory_info().rss / 1024 / 1024  # MB

def main():
    print(f"Initial memory: {monitor_memory():.1f} MB")
    
    with multiprocessing.Pool(processes=2) as pool:
        sizes = [1000000, 2000000, 1500000]
        results = pool.map(memory_intensive_worker, sizes)
    
    print(f"Final memory: {monitor_memory():.1f} MB")
    print("Results:", results)

if __name__ == '__main__':
    main()
```

**Key points**: The multiprocessing module enables true parallelism by creating separate processes, bypassing Python's GIL. Use Process class for basic parallel execution, Pool for easy function mapping, and various IPC mechanisms (Queue, Pipe, shared memory) for data exchange. Always protect main code with `if __name__ == '__main__'` and choose appropriate start methods based on platform requirements.


---

