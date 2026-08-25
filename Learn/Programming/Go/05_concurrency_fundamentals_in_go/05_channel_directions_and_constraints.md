## Channel Directions and Constraints


Go allows you to restrict channels to be send-only or receive-only, providing compile-time safety and clearer API contracts.

**Key Points:**

- Send-only channels: `chan<- Type`
- Receive-only channels: `<-chan Type`
- Bidirectional channels can be passed to functions expecting directional channels
- Directional channels cannot be converted back to bidirectional channels
- Attempting operations on wrong-direction channels results in compile-time errors

**Example:**

```go
func sender(ch chan<- string) {
    ch <- "Hello"
    // ch <- "World" // This would work
    // msg := <-ch    // This would cause compile error
}

func receiver(ch <-chan string) {
    msg := <-ch
    fmt.Println(msg)
    // ch <- "Hello" // This would cause compile error
}

func main() {
    ch := make(chan string)
    
    go sender(ch)
    go receiver(ch)
    
    time.Sleep(time.Second)
}
```

Channel directions serve as documentation and provide type safety, making it impossible to accidentally use a channel in the wrong direction within a function scope.

