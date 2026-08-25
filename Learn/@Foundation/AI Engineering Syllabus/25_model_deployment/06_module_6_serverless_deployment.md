## Module 6: Serverless Deployment


### 6.1 Serverless Fundamentals

- Serverless computing concepts
- Function-as-a-Service (FaaS)
- Event-driven architecture
- Cold start vs warm start
- Stateless execution model
- Cost model analysis

### 6.2 AWS Lambda

- Lambda function structure
- Runtime environments
- Handler functions
- Event sources and triggers
- Lambda layers for dependencies
- Container image support
- Memory and timeout configuration
- Concurrency management

### 6.3 AWS Lambda for ML Models

- Model packaging strategies
- Lambda layers for ML libraries
- /tmp storage utilization
- EFS integration for large models
- Lambda container images for ML
- Inference optimization
- Cold start mitigation

### 6.4 Google Cloud Functions

- Function structure (HTTP, event-driven)
- Python runtime
- Dependency management
- Environment variables
- Timeout and memory settings
- Cloud Storage triggers

### 6.5 Azure Functions

- Function app structure
- Trigger types (HTTP, timer, queue)
- Bindings for input/output
- Durable Functions for workflows
- Premium plan for ML workloads

### 6.6 API Gateway Integration

- AWS API Gateway with Lambda
- Request/response transformation
- Authentication and authorization
- Rate limiting and throttling
- API versioning
- Custom domain setup

### 6.7 Serverless Frameworks

- Serverless Framework
    - serverless.yml configuration
    - Plugin ecosystem
    - Multi-provider support
- AWS SAM (Serverless Application Model)
    - Template specification
    - Local testing with SAM CLI
- Chalice for Python
    - Decorator-based routing
    - Automatic deployment

### 6.8 Serverless ML Platforms

- AWS SageMaker Serverless Inference
    - Automatic scaling
    - Pay-per-inference pricing
    - Memory configuration
- Google Cloud Run
    - Container-based serverless
    - Request-based scaling
    - Custom ML containers
- Azure Container Instances

### 6.9 Event-Driven ML Pipelines

- S3 triggers for batch inference
- SQS/SNS for async processing
- EventBridge for orchestration
- Step Functions for workflows
- Pub/Sub patterns

### 6.10 Serverless Optimization

- Memory optimization for cost
- Provisioned concurrency
- Function warming strategies
- Lazy loading of models
- Connection pooling
- Caching strategies (Redis, DynamoDB)

### 6.11 Limitations & Considerations

- Execution time limits
- Memory constraints
- Package size limitations
- Cold start latency
- Stateless constraints
- Debugging challenges
- When NOT to use serverless

---

