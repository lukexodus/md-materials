## Serverless Patterns


Serverless computing abstracts infrastructure management, automatically scaling compute resources based on demand. Functions as a Service (FaaS) executes code in response to events without managing servers, while Backend as a Service (BaaS) provides managed services for common application needs.

**Function Patterns:** Trigger-based functions respond to events from various sources including HTTP requests, database changes, file uploads, or scheduled events. Chain functions create workflows by invoking other functions, though this can create tight coupling. Fan-out functions distribute work across multiple parallel executions.

**Cold Start Optimization:** Provisioned concurrency pre-warms function instances to reduce latency. Connection pooling reuses database connections across function invocations. Lightweight runtimes and minimal dependencies reduce initialization time. Function warming strategies periodically invoke functions to maintain warm instances.

**State Management:** External state stores like databases or caches maintain state between function invocations. Step functions orchestrate complex workflows with state transitions. Event sourcing patterns maintain state through event streams rather than traditional databases.

**Integration Patterns:** API Gateway patterns expose serverless functions as HTTP APIs with authentication, throttling, and request transformation. Event-driven patterns trigger functions from queue messages, file changes, or database events. Scheduled patterns execute functions on cron-like schedules for batch processing.

**Cost Optimization:** Right-sizing memory allocation balances performance and cost since CPU scales with memory. Execution time optimization reduces billable duration through efficient code and warm starts. Reserved capacity provides predictable pricing for consistent workloads.

