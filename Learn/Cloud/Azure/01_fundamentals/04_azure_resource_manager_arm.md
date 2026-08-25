## Azure Resource Manager (ARM)


Azure Resource Manager serves as the deployment and management service for Azure, providing a unified management layer for all Azure resources. ARM enables consistent management operations across different Azure services and tools through a common API.

**Key Points**

ARM templates define infrastructure and configuration as code using JavaScript Object Notation (JSON) format. Templates describe Azure resources, their properties, dependencies, and configuration parameters in a declarative manner. This approach enables repeatable deployments, version control, and infrastructure automation.

Resource providers represent the services available through ARM, such as Microsoft.Compute for virtual machines, Microsoft.Storage for storage accounts, and Microsoft.Network for networking resources. Each resource provider offers specific resource types with defined properties and capabilities.

Deployment modes determine how ARM processes template deployments. Incremental mode adds or updates resources defined in the template without affecting existing resources not specified in the template. Complete mode ensures the resource group contains only resources defined in the template, removing any resources not specified.

ARM template structure includes several key sections:

The schema section specifies the template format version and resource provider versions. Parameters section defines input values that customize deployments for different environments. Variables section contains values computed from parameters or other template elements. Resources section declares the Azure resources to deploy with their configurations. Outputs section returns values from deployed resources for use in other templates or processes.

Template functions provide built-in capabilities for manipulating values, generating unique names, referencing other resources, and performing calculations within templates. Common functions include resourceGroup(), parameters(), variables(), and concat().

Linked and nested templates enable modular template design by referencing other templates. This approach promotes reusability, maintainability, and separation of concerns in complex deployments.

**Examples**

A basic ARM template might define a storage account with parameters for storage account name, location, and performance tier. The template would include parameter validation, generate a unique storage account name using template functions, and output the storage account's primary endpoint for use by other systems.

An enterprise application deployment might use a master template that links to separate templates for networking infrastructure, database services, application services, and monitoring components. Each linked template focuses on specific infrastructure aspects while the master template orchestrates the overall deployment.

