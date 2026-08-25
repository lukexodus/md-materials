## Azure Pipelines


Azure Pipelines delivers cloud-based continuous integration and continuous deployment capabilities supporting diverse technology stacks, deployment targets, and development workflows. The service provides both hosted agents and self-hosted agent options with extensive customization and scaling capabilities.

**Key Points**

Pipeline architecture supports two primary configuration approaches: Classic pipelines using visual designer interfaces with task-based configuration, and YAML pipelines defining build and deployment processes as code with version control integration. YAML pipelines are recommended for new implementations due to their version control benefits, code review capabilities, and enhanced flexibility.

Agent pools manage the compute resources executing pipeline jobs, with Microsoft-hosted agents providing pre-configured virtual machines with common development tools and self-hosted agents offering customized environments for specific requirements. Microsoft-hosted agents support Windows, Linux, and macOS environments with automatic scaling and maintenance, while self-hosted agents enable access to on-premises resources and specialized software configurations.

Build pipelines automate source code compilation, testing, and artifact generation with support for multiple programming languages, frameworks, and package managers. Pipeline stages can execute sequentially or in parallel with dependency management, conditional execution based on variables or previous stage results, and integration with external systems through service connections.

Deployment pipelines orchestrate application delivery across multiple environments with approval workflows, release gates, and rollback capabilities. Deployment strategies include blue-green deployments for zero-downtime releases, canary deployments for gradual rollouts with monitoring integration, and rolling deployments for sequential instance updates.

Variable management enables parameterization of pipeline configurations with support for pipeline variables, variable groups for shared values across multiple pipelines, and secure variables for sensitive information like connection strings and API keys. Variables can be scoped to specific environments, stages, or jobs with inheritance and override capabilities.

Service connections provide secure authentication mechanisms for external systems including Azure subscriptions, Docker registries, Kubernetes clusters, and third-party services. Connections utilize service principal authentication, managed identity integration, or other appropriate authentication methods with role-based access control for security.

Pipeline triggers control when pipelines execute including continuous integration triggers on code changes, scheduled triggers for regular execution, pull request triggers for validation, and manual triggers for on-demand execution. Complex trigger conditions can be configured based on branch patterns, file path changes, and variable values.

**Examples**

A microservices application might utilize multi-stage YAML pipelines with parallel build stages for each service, integration testing stages with Docker Compose environments, and deployment stages targeting different Kubernetes namespaces with environment-specific variable groups.

An enterprise web application could implement deployment pipelines with manual approval gates for production releases, automated testing in staging environments, blue-green deployment strategies for zero-downtime updates, and integration with monitoring systems for automatic rollback triggers.

