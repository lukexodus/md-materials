## EC2 Pricing Models


AWS offers multiple pricing models to optimize costs based on usage patterns and requirements.

**On-Demand Pricing** On-Demand instances charge by the hour or second with no upfront costs or long-term commitments. This model suits applications with unpredictable workloads, short-term projects, or development and testing environments. Pricing varies by instance type, region, and operating system.

**Reserved Instances** Reserved Instances provide significant discounts (up to 75%) compared to On-Demand pricing in exchange for committing to use specific instance types in particular regions for one or three-year terms. Standard Reserved Instances offer the highest discount but cannot be modified. Convertible Reserved Instances allow changing instance family, size, or operating system during the term with slightly lower discounts. Scheduled Reserved Instances provide capacity reservations for specific time windows on recurring schedules.

**Spot Instances** Spot Instances utilize spare EC2 capacity at discounts up to 90% compared to On-Demand prices. AWS can terminate Spot Instances when demand increases, providing two minutes' notice. This model works well for fault-tolerant applications, batch processing, data analysis, and CI/CD pipelines. Spot Fleet requests can automatically launch multiple Spot Instances across different instance types and Availability Zones to maintain capacity.

**Dedicated Hosts and Dedicated Instances** Dedicated Hosts provide physical EC2 servers dedicated to single tenants, enabling use of existing server-bound software licenses and meeting compliance requirements. Dedicated Instances run on hardware dedicated to a single customer but may share hardware with other instances from the same account.

