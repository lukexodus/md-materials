## Azure Disk Storage


Azure Disk Storage provides high-performance, durable block storage for Azure Virtual Machines, offering various disk types optimized for different workload requirements.

**Key points:**

- Four disk types: Ultra SSD (highest performance), Premium SSD v2 (balanced performance and cost), Premium SSD (production workloads), Standard SSD (cost-effective for lighter workloads)
- Managed and unmanaged disk options, with managed disks recommended for simplified management
- Built-in redundancy options: Locally Redundant Storage (LRS), Zone Redundant Storage (ZRS)
- Disk encryption using Azure Disk Encryption or Server-Side Encryption
- Snapshot capabilities for backup and disaster recovery
- Disk scaling and performance tuning options
- Integration with Azure Backup and Azure Site Recovery

**Example:** A database server uses Premium SSD managed disks for optimal IOPS performance, with automated snapshots taken daily and stored in a different region for disaster recovery purposes.

