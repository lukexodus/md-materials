## Auto Scaling


Auto Scaling automatically adjusts compute capacity to maintain application availability and optimize costs. It monitors applications and adjusts capacity based on defined policies.

**Auto Scaling Groups** Auto Scaling Groups define collections of EC2 instances treated as logical units for scaling and management. Groups specify minimum, maximum, and desired capacity levels. Instances are distributed across multiple Availability Zones for high availability. Health checks monitor instance status, automatically replacing unhealthy instances.

**Scaling Policies** Target tracking scaling adjusts capacity to maintain specific metrics like CPU utilization or request count per target. Step scaling applies different scaling adjustments based on alarm breach size. Simple scaling adds or removes capacity based on single metrics crossing thresholds. Predictive scaling uses machine learning to forecast demand and proactively adjust capacity.

**Launch Templates and Configurations** Launch templates specify instance configuration including AMI, instance type, key pairs, security groups, and user data. They support versioning and can include multiple instance types and purchase options. Launch configurations provide similar functionality but are legacy and cannot be modified after creation.

