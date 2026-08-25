## Amazon ECS (Elastic Container Service)


ECS orchestrates Docker containers on AWS infrastructure, managing container lifecycle, scaling, and service discovery.

**Task Definitions and Services** Task definitions specify container configurations including images, CPU and memory requirements, port mappings, and environment variables. Services maintain desired numbers of running tasks and integrate with load balancers for traffic distribution. Services support rolling updates and can automatically replace failed tasks.

**Launch Types** EC2 launch type runs containers on EC2 instances managed by users, providing control over underlying infrastructure. Fargate launch type runs containers on AWS-managed infrastructure without server management. Users can mix launch types within the same cluster based on workload requirements.

**Cluster Management** ECS clusters group compute resources for running tasks and services. Container Insights provides monitoring and logging for containerized applications. Service Connect enables service-to-service communication with built-in service discovery and load balancing.

