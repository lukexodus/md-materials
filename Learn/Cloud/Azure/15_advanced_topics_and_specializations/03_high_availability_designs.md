## High Availability Designs


High availability on Azure requires architecting systems to minimize downtime through redundancy, fault tolerance, and automated recovery mechanisms.

**Availability Zones:** Azure Availability Zones are physically separated datacenters within Azure regions, each with independent power, cooling, and networking. Deploying resources across multiple zones provides protection against datacenter-level failures. Zone-redundant services automatically replicate across zones without additional configuration.

**Virtual Machine Availability:** Availability Sets distribute VMs across multiple fault domains and update domains within a single datacenter. VM Scale Sets provide automatic scaling and built-in load balancing across instances. Proximity Placement Groups can co-locate resources for low-latency communication while maintaining fault tolerance.

**Load Balancing Strategies:** Azure Load Balancer provides Layer 4 load balancing with high throughput and low latency. Application Gateway offers Layer 7 load balancing with SSL termination, Web Application Firewall, and URL-based routing. Traffic Manager enables DNS-based global load balancing across regions.

**Database High Availability:** Azure SQL Database provides 99.995% availability SLA with built-in high availability architecture. Always On availability groups in SQL Server VMs enable synchronous and asynchronous replication. Azure Cosmos DB offers 99.999% availability with multi-region writes and automatic failover.

**Application-Level Resilience:** Circuit breaker patterns prevent cascading failures by stopping requests to failed services. Retry policies with exponential backoff handle transient failures gracefully. Bulkhead patterns isolate critical resources from non-critical workloads. Health check endpoints enable automated failure detection and recovery.

**Monitoring and Alerting:** Azure Monitor collects telemetry from all Azure resources with customizable alerting rules. Application Insights provides application performance monitoring with dependency tracking. Log Analytics enables complex queries across multiple data sources for root cause analysis.

