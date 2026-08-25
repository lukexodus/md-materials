## VMware Cloud on AWS


VMware Cloud on AWS provides VMware Software-Defined Data Center (SDDC) running on dedicated AWS infrastructure, enabling migration of VMware workloads without modification.

### Infrastructure Components

**SDDC Configuration:**

- VMware vSphere for compute virtualization
- VMware vSAN for software-defined storage
- VMware NSX for network virtualization
- VMware vCenter for management

**Host Specifications:**

- Dedicated bare metal EC2 instances (i3.metal) [Unverified - specific instance types may change]
- Minimum cluster size of 3 hosts
- Scaling capabilities up to 16 hosts per cluster [Unverified - scaling limits may vary]

### Hybrid Connectivity

**Network Integration:**

- Direct Connect for dedicated network connections
- VPN connectivity for secure communication
- AWS Transit Gateway integration
- Hybrid Linked Mode for unified vCenter management

**Data Migration:**

- VMware vMotion for live workload migration
- VMware HCX for bulk migration and disaster recovery
- Replication-based migration options

### Service Integration

**AWS Service Access:**

- Native access to AWS services from SDDC workloads
- Elastic Network Interface (ENI) connectivity
- AWS API integration for automation

**Disaster Recovery:**

- VMware Site Recovery Manager integration
- Cross-region disaster recovery capabilities
- Automated failover and failback procedures

**Key Points:**

- Consistent operational model across on-premises and cloud environments
- No application refactoring required for VMware workloads
- Shared responsibility model with VMware and AWS support
- Integration with AWS native services for enhanced capabilities
- Flexible consumption models including on-demand and reserved capacity

**Important Subtopics:** Consider exploring AWS Application Migration Service (CloudEndure successor), AWS Migration Evaluator for business case development, hybrid storage architectures using Storage Gateway, and advanced DataSync filtering and scheduling configurations for comprehensive migration strategy implementation.

---

