## Fan-in and Fan-out Patterns


These patterns distribute work across multiple goroutines (fan-out) or consolidate results from multiple sources (fan-in).

**Fan-out Pattern:**

```go
func fanOut(input <-chan int, workers int) []<-chan int {
    outputs := make([]<-chan int, workers)
    
    for i := 0; i < workers; i++ {
        output := make(chan int)
        outputs[i] = output
        
        go func(out chan<- int) {
            defer close(out)
            for data := range input {
                // Process and send to specific worker
                processed := heavyComputation(data)
                out <- processed
            }
        }(output)
    }
    
    return outputs
}
```

**Fan-in Pattern:**

```go
func fanIn(inputs ...<-chan int) <-chan int {
    output := make(chan int)
    var wg sync.WaitGroup
    
    wg.Add(len(inputs))
    
    for _, input := range inputs {
        go func(in <-chan int) {
            defer wg.Done()
            for data := range in {
                output <- data
            }
        }(input)
    }
    
    go func() {
        wg.Wait()
        close(output)
    }()
    
    return output
}
```

**Pipeline with Fan-out/Fan-in:**

```go
func pipeline(input <-chan int) <-chan int {
    // Stage 1: Fan-out to multiple workers
    stage1Outputs := fanOut(input, 3)
    
    // Stage 2: Process each stream
    stage2Outputs := make([]<-chan int, len(stage1Outputs))
    for i, output := range stage1Outputs {
        stage2Outputs[i] = processStage2(output)
    }
    
    // Stage 3: Fan-in results
    return fanIn(stage2Outputs...)
}
```

