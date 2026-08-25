## Azure Artifacts


Azure Artifacts provides comprehensive package management capabilities supporting multiple package types and development workflows, enabling organizations to create, host, and share packages across development teams while maintaining version control and dependency management.

**Key Points**

Package feed architecture organizes artifacts into feeds representing logical containers with independent access control, retention policies, and upstream source configurations. Feeds can be scoped to individual projects for team-specific packages or organization-wide for shared components across multiple projects.

Supported package types encompass various development ecosystems including NuGet packages for .NET applications, npm packages for Node.js development, Maven packages for Java projects, Python packages for Python applications, and Universal Packages for any file type or artifact collection. Each package type includes metadata management, version semantics, and dependency resolution appropriate to the specific ecosystem.

Upstream sources enable hybrid package management by connecting feeds to public package repositories like nuget.org, npmjs.com, Maven Central, and PyPI. This configuration allows developers to access both internal packages and public packages through a single feed endpoint while providing caching and availability benefits for external dependencies.

Package versioning follows semantic versioning principles with support for pre-release versions, version ranges, and immutable package publication. Retention policies can automatically clean up old package versions based on configurable rules including version count limits, age-based cleanup, and usage-based retention.

Access control mechanisms integrate with Azure DevOps security model providing fine-grained permissions for feed management, package publication, and consumption. Permissions can be assigned to users, groups, and service accounts with different levels including Reader, Contributor, and Owner roles.

Package promotion workflows support quality gates through feed views representing different quality levels such as @Local for development versions, @Prerelease for testing versions, and @Release for production-ready packages. Promotion between views can be automated through pipeline integration or managed through manual approval processes.

Integration capabilities connect Azure Artifacts with build pipelines for automatic package publication, package restore operations, and dependency management. Pipeline tasks support package publishing, version stamping, and feed authentication across different package ecosystems.

**Examples**

A .NET development organization might create separate feeds for shared libraries, internal APIs, and third-party dependencies with upstream sources configured to proxy public NuGet packages, implementing automated package promotion through build pipeline success criteria.

A Node.js application team could utilize npm feed views for development, staging, and production package promotion with retention policies automatically cleaning development packages after 30 days while maintaining production packages indefinitely.

