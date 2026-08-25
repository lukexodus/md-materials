## Azure Repos and Azure Boards


Azure Repos provides Git-based distributed version control with enterprise-grade security and collaboration features, while Azure Boards delivers flexible work item tracking and project management capabilities designed to support various development methodologies and team structures.

**Key Points**

Repository management in Azure Repos supports both Git distributed version control and Team Foundation Version Control (TFVC) centralized systems, though Git is the recommended approach for new projects. Git repositories provide complete version history, branching and merging capabilities, and distributed development workflows. Each project can contain multiple repositories with independent access control and branch policies.

Branch policies enforce code quality and collaboration standards through configurable rules including required pull request reviews, build validation requirements, comment resolution mandates, and merge strategy restrictions. Policies can require specific reviewers, automatic reviewer assignment based on file paths, and integration with external status checks from build systems or security scanning tools.

Pull request workflows facilitate code review and collaboration with features including inline commenting, file-level discussions, iteration tracking for multiple review cycles, and integration with work items for traceability. Advanced features include draft pull requests for work-in-progress sharing, auto-complete options for automated merging after policy satisfaction, and cherry-picking capabilities for selective change integration.

Work item tracking in Azure Boards utilizes customizable work item types with configurable fields, workflows, and business rules. Built-in types include User Stories, Tasks, Bugs, Features, Epics, and Issues with relationships supporting hierarchical organization and dependency tracking. Custom work item types can be created to match specific organizational processes and terminology.

Agile planning tools provide multiple views for project management including Kanban boards for visual workflow management, sprint backlogs for iterative planning, delivery plans for cross-team coordination, and burndown charts for progress tracking. Teams can configure board columns, swimlanes, and card customization to match their specific workflows.

Query system enables complex work item searches using Work Item Query Language (WIQL) with support for field-based filtering, relationship queries, and temporal conditions. Saved queries can be shared across teams and used to generate reports, dashboard widgets, and automated notifications.

Integration capabilities connect repositories and work items through commit linking, pull request associations, and automated work item state transitions based on code deployment success. This traceability supports compliance requirements and enables comprehensive change tracking throughout the development lifecycle.

**Examples**

A development team might configure branch policies requiring two reviewer approvals and successful build validation before merging to main branch, with automatic work item linking through commit messages following conventional commit standards.

A product management team could utilize Epic-Feature-User Story hierarchy in Azure Boards with custom fields for business value scoring, acceptance criteria tracking, and stakeholder approval workflows integrated with pull request completion triggers.

