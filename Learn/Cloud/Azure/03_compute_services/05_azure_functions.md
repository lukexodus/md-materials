## Azure Functions


Azure Functions offers serverless compute for event-driven applications, executing code in response to triggers without server management.

**Key Points:**

- Event-driven execution with automatic scaling to zero
- Multiple programming language support (C#, JavaScript, Python, Java, PowerShell)
- Pay-per-execution pricing model with generous free tier
- Integration with 200+ Azure services and external systems
- Stateless and stateful (Durable Functions) execution models
- Built-in authentication and authorization capabilities

**Hosting Plans:**

- **Consumption Plan**: Automatic scaling with pay-per-execution
- **Premium Plan**: Pre-warmed instances with enhanced performance
- **Dedicated Plan**: Run on App Service plans for predictable costs
- **Container Apps**: Functions running in containerized environments

**Trigger Types:**

- **HTTP triggers**: REST API endpoints and webhooks
- **Timer triggers**: Scheduled execution using cron expressions
- **Blob triggers**: File upload and modification events
- **Queue triggers**: Message processing from Storage Queues or Service Bus
- **Event Grid triggers**: Event-driven architectures
- **Cosmos DB triggers**: Database change notifications
- **IoT Hub triggers**: Device telemetry and commands

**Durable Functions Patterns:**

- Function chaining for sequential workflows
- Fan-out/fan-in for parallel processing
- Async HTTP APIs for long-running operations
- Monitoring patterns for recurring checks
- Human interaction workflows with approvals

