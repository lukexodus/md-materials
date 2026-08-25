## Azure Hybrid Benefit


Azure Hybrid Benefit enables organizations to use existing on-premises software licenses in Azure for significant cost reductions.

**Key points:**

- Windows Server licenses with active Software Assurance provide Azure VM discounts
- SQL Server licenses transfer to Azure SQL Database, SQL Managed Instance, and Azure SQL VM
- Up to 85% cost savings when combining with Reserved Instances
- License mobility rights preserve compliance with Microsoft licensing terms
- Dual-use rights allow simultaneous on-premises and cloud usage during migration
- Automatic license tracking and compliance reporting through Azure portal
- Exchange capabilities to optimize license utilization across different Azure services

**Eligible software licenses:**

- **Windows Server**: Standard and Datacenter editions with Software Assurance
- **SQL Server**: Standard and Enterprise editions with Software Assurance or subscription licenses
- **RedHat Enterprise Linux**: BYOL options through marketplace offerings [Unverified current RHEL hybrid benefit availability]
- **SUSE Linux Enterprise Server**: Hybrid benefit programs for enterprise subscriptions [Unverified current SUSE hybrid benefit availability]

**Implementation considerations:**

- License compliance requires maintaining Software Assurance coverage
- Core-to-vCore conversion ratios vary by SQL Server deployment option
- Windows Server hybrid benefit covers base compute costs but not additional services
- Monitoring tools track license utilization to prevent over-allocation

