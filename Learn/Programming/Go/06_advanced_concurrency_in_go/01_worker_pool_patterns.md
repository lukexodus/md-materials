## Worker Pool Patterns


Worker pools manage a fixed number of goroutines that process tasks from a shared queue, providing controlled resource utilization and predictable performance characteristics.

**Basic Worker Pool Implementation:**

```go
type Job struct {
    ID   int
    Data string
}

type Result struct {
    Job    Job
    Output string
    Error  error
}

func worker(id int, jobs <-chan Job, results chan<- Result) {
    for job := range jobs {
        // Process job
        output := process(job.Data)
        results <- Result{
            Job:    job,
            Output: output,
            Error:  nil,
        }
    }
}

func createWorkerPool(numWorkers int) (chan Job, chan Result) {
    jobs := make(chan Job, 100)
    results := make(chan Result, 100)
    
    for i := 0; i < numWorkers; i++ {
        go worker(i, jobs, results)
    }
    
    return jobs, results
}
```

**Dynamic Worker Pool:**

```go
type WorkerPool struct {
    jobs        chan Job
    results     chan Result
    workers     int
    maxWorkers  int
    quit        chan bool
    wg          sync.WaitGroup
}

func (wp *WorkerPool) AddWorker() {
    if wp.workers < wp.maxWorkers {
        wp.workers++
        wp.wg.Add(1)
        go wp.worker()
    }
}

func (wp *WorkerPool) worker() {
    defer wp.wg.Done()
    for {
        select {
        case job := <-wp.jobs:
            result := processJob(job)
            wp.results <- result
        case <-wp.quit:
            return
        }
    }
}
```

Worker pools excel in scenarios with:

- CPU-bound tasks requiring controlled parallelism
- I/O operations with rate limiting requirements
- Batch processing with memory constraints
- Load balancing across multiple resources

