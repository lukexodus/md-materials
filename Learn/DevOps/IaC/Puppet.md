# Syllabus

## Foundation Modules

### Module 1: Configuration Management Fundamentals

- What is configuration management
- Infrastructure as Code (IaC) concepts
- Declarative vs imperative approaches
- Idempotency principles
- Configuration drift and remediation

### Module 2: Puppet Architecture and Components

- Puppet agent-server architecture
- Puppet apply (standalone) mode
- Catalog compilation process
- Certificate management and PKI
- Puppet services and daemons

## Core Language and Syntax

### Module 3: Puppet Domain Specific Language (DSL)

- Resource abstraction layer
- Resource types and providers
- Resource declarations and syntax
- Resource relationships and dependencies
- Metaparameters

### Module 4: Variables and Data Types

- Variable declaration and scoping
- String, numeric, boolean, and array types
- Hash data structures
- Puppet data types system
- Variable interpolation

### Module 5: Control Structures and Logic

- Conditional statements (if/else, unless)
- Case statements and selectors
- Iteration with each and other functions
- Regular expressions in Puppet
- Comparison and logical operators

## Resource Management

### Module 6: Core Resource Types

- File resources
- Package resources
- Service resources
- User and group resources
- Exec resources and best practices

### Module 7: Advanced Resource Types

- Mount resources
- Cron resources
- Host resources
- Firewall resources
- Custom resource types

### Module 8: Resource Relationships

- Before and require metaparameters
- Notify and subscribe relationships
- Chaining arrows syntax
- Resource ordering strategies
- Dependency cycles troubleshooting

## Code Organization

### Module 9: Classes and Modules

- Class definition and declaration
- Class parameters and defaults
- Module structure and conventions
- Public vs private classes
- Class inheritance patterns

### Module 10: Defined Types

- Creating custom defined types
- Parameters and validation
- Multiple resource declarations
- Defined type vs class decisions
- Naming conventions

### Module 11: Module Development

- Module directory structure
- Metadata.json configuration
- Documentation standards
- Version control integration
- Puppet Forge publishing

## Data Management

### Module 12: Hiera Hierarchical Data

- Hiera configuration and backends
- Data hierarchy design
- Automatic parameter lookup
- Explicit Hiera lookups
- Data encryption with eyaml

### Module 13: External Node Classifiers

- ENC concepts and implementation
- LDAP integration
- Database-driven classification
- Custom ENC development
- Dashboard integration

### Module 14: Facts and Custom Facts

- Built-in Facter facts
- Custom fact development
- Structured vs flat facts
- External facts
- Fact troubleshooting

## Advanced Topics

### Module 15: Puppet Functions

- Built-in function library
- Custom function development
- Ruby vs Puppet language functions
- Function testing strategies
- Performance considerations

### Module 16: Templates and File Generation

- ERB template syntax
- EPP (Embedded Puppet) templates
- Template variables and logic
- File fragments and concat
- Sensitive data handling

### Module 17: Types and Providers

- Provider abstraction layer
- Built-in providers
- Custom type development
- Custom provider development
- Cross-platform considerations

## Testing and Quality

### Module 18: Unit Testing

- RSpec-puppet framework
- Test structure and organization
- Mocking and stubbing
- Coverage analysis
- Continuous integration

### Module 19: Integration Testing

- Beaker framework
- Test Kitchen integration
- Docker-based testing
- Multi-node testing scenarios
- Acceptance test patterns

### Module 20: Code Quality and Linting

- Puppet-lint configuration
- Style guide compliance
- Puppet parser validation
- Metadata-json-lint
- Pre-commit hooks

## Enterprise and Scale

### Module 21: Puppet Server Administration

- Installation and configuration
- JVM tuning and performance
- Certificate authority management
- Environment management
- Monitoring and logging

### Module 22: PuppetDB Integration

- PuppetDB architecture
- Query language (PQL)
- Report storage and analysis
- API usage patterns
- Performance tuning

### Module 23: Environments and Git Workflows

- Directory environments
- R10K deployment
- Git branching strategies
- Code promotion pipelines
- Environment isolation

## Security and Compliance

### Module 24: Security Best Practices

- Least privilege principles
- Certificate management
- Secure coding practices
- Sensitive data protection
- Access control patterns

### Module 25: Compliance Automation

- Compliance frameworks integration
- Reporting and auditing
- Policy as Code patterns
- Remediation workflows
- Evidence collection

## Operations and Troubleshooting

### Module 26: Monitoring and Reporting

- Puppet run reporting
- Performance metrics
- Error analysis
- Dashboard creation
- Alerting strategies

### Module 27: Troubleshooting and Debugging

- Log analysis techniques
- Catalog inspection
- Dependency resolution
- Performance profiling
- Common error patterns

### Module 28: Backup and Disaster Recovery

- Configuration backup strategies
- Certificate backup procedures
- Database backup approaches
- Recovery testing
- Business continuity planning

## Integration and Ecosystem

### Module 29: Tool Integration

- Jenkins/GitLab CI integration
- Monitoring system integration
- ITSM tool integration
- Cloud platform integration
- Container orchestration

### Module 30: Migration and Adoption

- Legacy system migration
- Gradual adoption strategies
- Team training approaches
- Change management
- Success measurement