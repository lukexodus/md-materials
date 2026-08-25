## **Synchronous vs Asynchronous Execution**


- **Synchronous**: Code executes line by line; the next task waits for the current one to complete.
    
    ```javascript
    console.log("Start");
    console.log("End");
    // Output: Start, End
    ```
    
- **Asynchronous**: Code can pause and resume, allowing other tasks to run in the meantime.
    
    ```javascript
    console.log("Start");
    setTimeout(() => console.log("Async task"), 1000);
    console.log("End");
    // Output: Start, End, Async task (after 1 second)
    ```
    

---

