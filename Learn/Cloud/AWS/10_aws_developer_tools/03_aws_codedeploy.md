## AWS CodeDeploy


AWS CodeDeploy is a deployment service that automates application deployments to Amazon EC2 instances, on-premises servers, AWS Lambda functions, and Amazon ECS services. CodeDeploy coordinates deployments across multiple instances while maintaining application availability during the deployment process.

**Deployment Platforms** support various compute platforms. EC2/On-premises deployments work with applications running on EC2 instances or on-premises servers. AWS Lambda deployments handle function updates with traffic shifting capabilities. Amazon ECS deployments manage containerized applications with blue/green deployment strategies.

**Deployment Configurations** define how deployments proceed across target instances. For EC2/On-premises deployments, configurations include CodeDeployDefault.AllAtOnce (deploy to all instances simultaneously), CodeDeployDefault.HalfAtATime (deploy to half the instances at a time), and CodeDeployDefault.OneAtATime (deploy to one instance at a time).

Lambda deployment configurations support canary deployments (shifting a percentage of traffic to the new version) and linear deployments (gradually shifting traffic over time). Custom deployment configurations can be created to meet specific requirements for deployment speed and risk tolerance.

**Application Specifications** are defined in appspec.yml files that describe deployment actions. For EC2/On-premises deployments, the AppSpec file specifies file locations, permissions, and lifecycle event hooks. Lifecycle events include ApplicationStop, DownloadBundle, BeforeInstall, Install, AfterInstall, ApplicationStart, and ValidateService.

Hook scripts can be written in any language and perform custom actions during deployment phases, such as stopping services, backing up data, or running health checks. Environment variables and deployment metadata are available to hook scripts during execution.

**Deployment Monitoring** provides real-time status updates through the AWS console, CLI, and APIs. CloudWatch alarms can be configured to monitor deployment health and trigger automatic rollbacks if issues are detected. Deployment history maintains records of all deployments for auditing and troubleshooting.

Rollback capabilities enable quick recovery from failed deployments by redeploying the previous application revision. Automatic rollbacks can be configured based on deployment failure thresholds or CloudWatch alarm states.

