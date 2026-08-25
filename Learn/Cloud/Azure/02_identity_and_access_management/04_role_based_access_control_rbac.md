## Role-Based Access Control (RBAC)


Azure RBAC provides fine-grained access management for Azure resources through role assignments that combine security principals, role definitions, and scope. This system enables organizations to grant users only the access they need to perform their job functions, following the principle of least privilege.

RBAC operates on three fundamental components: security principals (users, groups, service principals, managed identities), role definitions (collections of permissions), and scope (resources where access applies). Role assignments create the relationship between these components, determining what actions principals can perform on specific resources.

Azure provides over 70 built-in roles covering common scenarios, including Owner, Contributor, Reader, and specialized roles for specific services like Virtual Machine Contributor or SQL Database Contributor. Custom roles enable organizations to create precise permission sets tailored to their specific requirements.

**Example:** A database administrator might have SQL Database Contributor role assigned at the resource group scope, allowing them to manage all SQL databases within that resource group but no access to virtual machines or storage accounts.

Scope inheritance flows from higher levels (management groups, subscriptions) to lower levels (resource groups, individual resources). Users can have multiple role assignments across different scopes, with permissions being additive rather than restrictive.

