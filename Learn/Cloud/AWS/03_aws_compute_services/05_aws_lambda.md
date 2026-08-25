## AWS Lambda


Lambda provides serverless computing, executing code in response to events without provisioning or managing servers. It automatically scales applications by running code in parallel and charges only for compute time consumed.

**Function Architecture** Lambda functions consist of code and configuration. Supported runtimes include Python, Node.js, Java, C#, Go, Ruby, and custom runtimes. Functions can be up to 15 minutes in duration with configurable memory from 128 MB to 10,240 MB. CPU allocation scales proportionally with memory allocation.

**Event Sources and Triggers** Lambda functions respond to events from numerous AWS services including S3, DynamoDB, Kinesis, SNS, SQS, API Gateway, and CloudWatch. Event source mappings define how Lambda polls streaming data sources. Synchronous invocations return responses immediately, while asynchronous invocations queue events for processing.

**Deployment and Versioning** Functions can be deployed as ZIP files or container images up to 10 GB. Versions create immutable snapshots of function code and configuration. Aliases provide stable endpoints pointing to specific versions or weighted distributions across versions for blue/green deployments.

