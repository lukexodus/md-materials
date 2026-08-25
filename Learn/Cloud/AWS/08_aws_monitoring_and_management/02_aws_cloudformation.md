## AWS CloudFormation


CloudFormation provides Infrastructure as Code (IaC) capabilities through JSON or YAML templates that define AWS resources and their configurations.

### Template Structure

**Core Sections:**

- **AWSTemplateFormatVersion:** Template format version
- **Description:** Template description
- **Parameters:** Input values for template customization
- **Mappings:** Static lookup tables for conditional values
- **Conditions:** Logic for conditional resource creation
- **Resources:** AWS resources to create (required section)
- **Outputs:** Values returned after stack creation

### Stack Management

**Stack Operations:**

- Create: Deploy new infrastructure from templates
- Update: Modify existing stacks with change sets
- Delete: Remove all stack resources
- Drift Detection: Identify configuration changes outside CloudFormation

**Change Sets:** Preview mechanism showing proposed changes before stack updates, enabling review of modifications, additions, and deletions.

**Stack Sets:** [Inference] Deploy stacks across multiple accounts and regions simultaneously

### Advanced Capabilities

**Nested Stacks:** Modular templates that reference other CloudFormation templates **Cross-Stack References:** Export values from one stack for use in another **Custom Resources:** Extend CloudFormation with Lambda-backed custom logic **Rollback Triggers:** Automatically rollback deployments based on CloudWatch alarms

