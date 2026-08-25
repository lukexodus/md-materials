## Amazon EventBridge


Amazon EventBridge is a serverless event bus service that connects applications using events from AWS services, software-as-a-service applications, and custom applications. EventBridge enables event-driven architectures by routing events between event producers and consumers based on configurable rules.

### Event Buses and Architecture

EventBridge organizes event routing through event buses that serve as central channels for event distribution. The default event bus receives events from AWS services automatically. Custom event buses provide isolation for specific applications or organizational boundaries.

Partner event buses integrate with software-as-a-service providers, enabling applications to receive events from external systems without custom integration development. Partner integrations include services like Shopify, Auth0, PagerDuty, and numerous other third-party platforms.

Event buses support cross-account and cross-region event routing, enabling complex distributed architectures with centralized event management. Resource-based policies control access to event buses, supporting secure multi-tenant event distribution scenarios.

### Event Routing and Rules

Event routing rules determine which events are delivered to specific targets based on event content matching criteria. Rules evaluate event patterns using JSON syntax to match event attributes, enabling sophisticated event filtering and routing logic.

Event patterns support exact matching, prefix matching, numeric ranges, and existence checks across event attributes. Complex patterns can combine multiple conditions using logical operators, enabling precise event categorization and routing.

Multiple rules can process the same event, enabling fan-out scenarios where single events trigger multiple downstream processes. Rule evaluation occurs in parallel, ensuring consistent event processing performance regardless of rule complexity.

Content-based routing enables dynamic event distribution based on event payload content rather than static configuration. This capability supports flexible event-driven architectures that adapt to changing business requirements without infrastructure modifications.

### Event Targets and Integration

EventBridge supports over 15 AWS service targets including Lambda functions, SQS queues, SNS topics, Kinesis streams, and ECS tasks. Service integrations enable direct event processing without custom code development for common integration scenarios.

Input transformation capabilities modify event content before delivery to targets, enabling event format adaptation for different consuming services. Transformations support JSON path extraction, constant value injection, and template-based event reconstruction.

Dead letter queues capture events that cannot be delivered successfully after retry attempts. Failed events retain original content and metadata, enabling troubleshooting and potential reprocessing after resolving downstream issues.

Event replay functionality enables reprocessing historical events from event archives. This capability supports disaster recovery scenarios, testing new event processing logic, and debugging production issues with historical event data.

### Schema Discovery and Management

EventBridge Schema Registry automatically discovers and maintains schemas for events flowing through event buses. Schema discovery analyzes event structure and creates OpenAPI specifications for event payload formats.

Schema versioning tracks changes to event formats over time, enabling backward compatibility management and coordinated schema evolution across event producers and consumers. Version management supports gradual rollout of schema changes without service disruptions.

Code generation features create language-specific code artifacts from discovered schemas, accelerating development of event producers and consumers. Generated code includes data classes, serialization logic, and validation functions for multiple programming languages.

