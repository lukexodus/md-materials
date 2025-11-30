# Syllabus

## Module 1: Helm Fundamentals

- What is Helm and package management for Kubernetes
- Helm architecture and components
- Helm vs kubectl and native Kubernetes manifests
- Helm 2 vs Helm 3 differences
- Installation and setup across platforms
- Helm CLI basics and help system

## Module 2: Kubernetes Prerequisites

- Kubernetes cluster concepts and components
- YAML manifests and resource definitions
- Namespaces and resource organization
- ConfigMaps and Secrets
- Services, Deployments, and Pods
- Ingress and networking basics

## Module 3: Getting Started with Helm

- First Helm installation
- Working with public repositories
- Chart installation, upgrade, and rollback
- Release management concepts
- Helm status and history commands
- Uninstalling releases and cleanup

## Module 4: Helm Charts Structure

- Chart directory structure and conventions
- Chart.yaml metadata file
- values.yaml configuration file
- templates/ directory organization
- charts/ subdirectory for dependencies
- .helmignore file usage

## Module 5: Chart Repositories

- Adding and managing chart repositories
- Searching and discovering charts
- Repository index files
- Private repository setup
- Repository authentication
- Helm Hub and Artifact Hub

## Module 6: Templating Basics

- Go template syntax fundamentals
- Template functions and pipelines
- Variable assignment and scope
- Conditional statements (if/else)
- Loops and iteration
- Template comments and documentation

## Module 7: Values and Configuration

- Default values hierarchy
- values.yaml structure and organization
- Overriding values via CLI and files
- Environment-specific value files
- Value validation and schema
- Global vs chart-specific values

## Module 8: Built-in Template Functions

- String manipulation functions
- Date and time functions
- Mathematical operations
- List and dictionary functions
- Encoding and hashing functions
- Flow control functions

## Module 9: Helm Template Objects

- Release object properties
- Chart object metadata
- Values object access patterns
- Template object for file operations
- Capabilities object for cluster info
- Files object for chart file access

## Module 10: Advanced Templating

- Named templates and partials
- Template inheritance and inclusion
- Template debugging techniques
- Whitespace control
- Custom template functions
- Template testing strategies

## Module 11: Chart Dependencies

- Dependency declaration in Chart.yaml
- Dependency resolution and management
- helm dependency commands
- Local vs remote dependencies
- Version constraints and ranges
- Dependency value overrides

## Module 12: Hooks and Lifecycle

- Pre-install and post-install hooks
- Pre-upgrade and post-upgrade hooks
- Pre-delete and post-delete hooks
- Hook weights and execution order
- Hook failure policies
- Test hooks and validation

## Module 13: Chart Development

- Creating charts from scratch
- Chart scaffolding with helm create
- Best practices for chart structure
- Resource naming conventions
- Label and annotation standards
- Chart versioning strategies

## Module 14: Chart Testing

- Writing chart tests
- helm test command usage
- Test pod specifications
- Integration testing approaches
- Automated testing in CI/CD
- Test data management

## Module 15: Chart Packaging and Distribution

- Chart packaging with helm package
- Chart signing and verification
- Publishing to repositories
- Chart documentation generation
- Release notes and changelogs
- Semantic versioning for charts

## Module 16: Security and RBAC

- Helm security model
- Service accounts and permissions
- Role-based access control (RBAC)
- Pod security policies and contexts
- Secret management in charts
- Chart signing and provenance

## Module 17: Multi-Environment Deployments

- Environment-specific configurations
- Namespace management strategies
- Value file organization patterns
- Deployment promotion workflows
- Configuration drift detection
- Environment synchronization

## Module 18: Helm Plugins

- Installing and managing plugins
- Popular Helm plugins overview
- Plugin development basics
- Custom plugin creation
- Plugin distribution and sharing
- Plugin troubleshooting

## Module 19: Advanced Chart Patterns

- Library charts and shared templates
- Umbrella charts for microservices
- Multi-tier application deployment
- Database and stateful service patterns
- Monitoring and observability integration
- Backup and disaster recovery patterns

## Module 20: Helm with CI/CD

- GitOps workflows with Helm
- Automated chart testing
- Chart registry integration
- Release automation strategies
- Rollback and recovery procedures
- Continuous deployment patterns

## Module 21: Monitoring and Observability

- Helm release monitoring
- Chart deployment metrics
- Integration with Prometheus/Grafana
- Logging and troubleshooting
- Health checks and readiness probes
- Performance monitoring

## Module 22: Troubleshooting and Debugging

- Common Helm errors and solutions
- Debugging failed installations
- Template rendering issues
- Dependency resolution problems
- Resource conflicts and constraints
- Log analysis techniques

## Module 23: Helm Operators and Controllers

- Helm Operator concepts
- Custom Resource Definitions (CRDs)
- Operator SDK integration
- Chart-based operators
- Lifecycle management automation
- Operator deployment patterns

## Module 24: Migration and Upgrades

- Migrating from Helm 2 to Helm 3
- Chart version upgrade strategies
- Breaking changes handling
- Data migration patterns
- Rollback procedures
- Zero-downtime upgrades

## Module 25: Enterprise Helm Usage

- Multi-cluster deployment strategies
- Chart governance and policies
- Compliance and audit requirements
- Enterprise repository management
- Integration with enterprise tools
- Support and maintenance procedures

## Module 26: Performance and Optimization

- Chart rendering performance
- Large-scale deployment strategies
- Resource optimization techniques
- Network and storage considerations
- Scaling patterns and limitations
- Performance monitoring and tuning

## Module 27: Advanced Kubernetes Integration

- Custom Resource Definitions (CRDs)
- Operators and controller integration
- Service mesh integration
- Storage class and PV management
- Network policy integration
- Admission controllers

## Module 28: Helm Ecosystem Tools

- Helmfile for environment management
- Chart testing tools (ct, helm-unittest)
- Documentation generation tools
- Security scanning tools
- Chart validation and linting
- IDE and editor extensions

## Module 29: Real-World Projects

- Microservices application deployment
- Stateful application management
- Multi-environment CI/CD pipeline
- Chart library development
- Enterprise application migration
- Cloud-native application packaging

## Module 30: Future of Helm

- Helm roadmap and upcoming features
- OCI registry support
- Kubernetes evolution impact
- Community contributions
- Best practices evolution
- Emerging patterns and tools