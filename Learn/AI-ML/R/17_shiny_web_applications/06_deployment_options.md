## Deployment Options


Shiny applications can be deployed through various platforms and configurations, from local sharing to production-scale hosting with load balancing and security features.

**Key points:**

- Local deployment is suitable for personal use and small team sharing
- Cloud platforms provide scalable hosting with minimal infrastructure management
- Self-hosted solutions offer maximum control but require server administration expertise
- Production deployments require consideration of security, performance, and monitoring

Local deployment represents the simplest option, running applications directly from RStudio or R console using `runApp()`. This approach works for development and sharing with users who have R installed. Applications can be shared as R scripts or R packages for easy distribution and execution.

RStudio Connect provides enterprise-grade deployment with user authentication, scheduled execution, and administrative controls. It supports multiple R versions, package management, and integrates with RStudio IDE for streamlined deployment workflows. [Unverified] Pricing and feature availability may vary based on organization size and requirements.

Shinyapps.io offers cloud hosting managed by RStudio/Posit with free and paid tiers. The platform handles infrastructure management, provides usage analytics, and supports custom domains on paid plans. Deployment occurs directly from RStudio IDE or through the `rsconnect` package.

Docker containerization enables consistent deployment across different environments. The `rocker` project provides R-optimized base images, while custom Dockerfiles can specify exact application requirements including R version, packages, and system dependencies.

Cloud platforms like AWS, Google Cloud, and Azure support Shiny deployment through various services. Options include container services (ECS, Cloud Run, Container Instances), virtual machines with Shiny Server, or serverless functions for lightweight applications.

Self-hosted Shiny Server Open Source provides free deployment on Linux servers with basic features including application hosting and user authentication. Shiny Server Pro adds advanced features like scaling, SSL support, and administrative dashboards but requires licensing.

Load balancing becomes necessary for high-traffic applications. Multiple Shiny processes can be managed through reverse proxies like nginx or cloud load balancers, distributing user sessions across application instances for improved performance and reliability.

