## Azure Subscription and Resource Management


Azure subscriptions serve as logical containers for Azure resources and define billing boundaries, access control scopes, and resource organization structures. Understanding subscription management is fundamental to effective Azure governance and cost control.

**Key Points**

Azure subscriptions represent agreements with Microsoft to use Azure services, establishing billing relationships and access boundaries. Each subscription has associated limits and quotas for various Azure services. Organizations can maintain multiple subscriptions for different departments, projects, or environments to separate billing, access control, and resource management.

Subscription types include several options based on organizational needs:

Pay-As-You-Go subscriptions charge for actual usage without upfront commitments, ideal for development, testing, and variable workloads. Enterprise Agreement subscriptions provide volume licensing with negotiated rates for large organizations making significant Azure commitments. Free tier subscriptions offer limited free services for learning and experimentation. Student subscriptions provide free credits for educational purposes.

Azure Active Directory (Azure AD) tenants provide identity and access management for Azure subscriptions. A tenant represents an organization's instance of Azure AD, containing users, groups, and applications. Subscriptions are associated with Azure AD tenants, enabling identity-based access control across Azure resources.

Management groups provide a hierarchical structure above subscriptions, enabling policy and access management across multiple subscriptions. Organizations can create management group hierarchies reflecting their organizational structure, applying governance policies consistently across related subscriptions.

Resource groups act as logical containers for Azure resources within a subscription. All resources must belong to exactly one resource group, which defines their lifecycle, access control, and billing scope. Resource groups enable collective management of related resources and provide a natural boundary for role-based access control.

Billing and cost management capabilities include detailed usage tracking, budgets, alerts, and cost analysis tools. Azure Cost Management provides insights into spending patterns, enabling optimization recommendations and cost control measures.

**Examples**

A large enterprise might structure their Azure environment with a root management group containing separate management groups for Production, Development, and Sandbox environments. Each environment contains multiple subscriptions for different business units, with resource groups organizing related resources within each subscription.

A development team might use separate resource groups for different application components, such as web-app-rg for web application resources, database-rg for database resources, and monitoring-rg for application monitoring tools.

