# Syllabus

## Module 1: Foundations

- Infrastructure as Code (IaC) concepts
- CloudFormation overview and benefits
- AWS CLI and Console basics for CloudFormation
- Template anatomy and structure
- YAML vs JSON formats
- Basic resource definitions

## Module 2: Core Template Components

- Parameters and parameter types
- Mappings and conditional logic
- Outputs and cross-stack references
- Metadata sections
- Template validation
- Intrinsic functions (Ref, GetAtt, Join, etc.)

## Module 3: Resource Management

- Resource properties and attributes
- Resource dependencies (DependsOn vs implicit)
- Deletion policies and update behaviors
- Custom resource names vs auto-generated
- Resource import and drift detection
- Stack policies

## Module 4: Advanced Template Features

- Conditions and conditional resource creation
- Nested stacks and stack composition
- Cross-stack references (Exports/Imports)
- Template macros and transforms
- Dynamic references and parameter store integration
- Pseudo parameters

## Module 5: Stack Operations

- Stack creation, updates, and deletion
- Change sets and preview functionality
- Stack rollbacks and failure handling
- Stack termination protection
- Stack events and monitoring
- Troubleshooting failed deployments

## Module 6: Security and Access Control

- IAM roles and policies for CloudFormation
- Service roles vs execution roles
- Resource-level permissions
- Stack-level permissions
- Secure parameter handling
- Cross-account deployments

## Module 7: Organization and Best Practices

- Template organization strategies
- Modular template design
- Naming conventions and tagging
- Environment-specific configurations
- Version control integration
- Documentation standards

## Module 8: Advanced Patterns

- Blue-green deployments
- Canary deployments
- Multi-region deployments
- Disaster recovery patterns
- Cost optimization strategies
- Performance considerations

## Module 9: Integration and Automation

- CI/CD pipeline integration
- AWS CDK interoperability
- Third-party tool integration
- Custom resource development
- Lambda-backed custom resources
- API Gateway integration patterns

## Module 10: Monitoring and Maintenance

- CloudWatch integration
- Stack drift monitoring
- Cost tracking and allocation
- Compliance and governance
- Backup and recovery strategies
- Lifecycle management

## Module 11: Enterprise Features

- StackSets for multi-account management
- Service Catalog integration
- Organizations integration
- Control Tower patterns
- Centralized logging and monitoring
- Enterprise governance models

## Module 12: Troubleshooting and Optimization

- Common error patterns and solutions
- Performance optimization techniques
- Template size limitations and workarounds
- Debugging failed resources
- Stack update strategies
- Migration patterns