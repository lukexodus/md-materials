## AWS X-Ray


X-Ray provides distributed tracing capabilities for applications, enabling analysis of performance bottlenecks and service dependencies across microservices architectures.

### Tracing Concepts

**Traces:** End-to-end request journey through distributed application components **Segments:** Individual service or resource interactions within a trace **Subsegments:** Granular operations within segments (database calls, HTTP requests) **Annotations:** Key-value pairs for filtering and indexing traces **Metadata:** Additional trace information not used for filtering

### Service Integration

**Supported Services:**

- Lambda functions (automatic tracing)
- API Gateway (request tracing)
- EC2 instances (X-Ray daemon required)
- ECS containers (daemon configuration)
- Elastic Beanstalk (configuration option)

**SDK Support:** SDKs available for Java, .NET, Node.js, Python, Ruby, and Go

### Analysis Capabilities

**Service Map:** Visual representation of application architecture and service dependencies **Trace Analysis:** Detailed breakdown of request latency and error rates **Performance Insights:** Identify slow services and error patterns **Sampling Rules:** Control trace collection volume and costs

