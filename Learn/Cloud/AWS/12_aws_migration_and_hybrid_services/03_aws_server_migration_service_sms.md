## AWS Server Migration Service (SMS)


[Unverified - SMS service may be deprecated in favor of AWS Application Migration Service]

SMS automates live server migrations from on-premises environments to AWS, creating Amazon Machine Images (AMIs) from existing virtual machines with incremental replication capabilities.

### Migration Process

**Initial Replication:** Complete server image replication to AWS as baseline AMI **Incremental Updates:** Ongoing synchronization of changed data blocks to minimize cutover downtime **Testing and Validation:** AMI testing capabilities before production cutover

**Supported Hypervisors:**

- VMware vSphere
- Microsoft Hyper-V
- Azure Virtual Machines

