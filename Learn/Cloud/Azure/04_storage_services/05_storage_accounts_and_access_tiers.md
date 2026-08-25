## Storage Accounts and Access Tiers


Storage accounts serve as the top-level namespace and management boundary for Azure Storage services, with access tiers providing cost optimization strategies based on data usage patterns.

**Key points:**

- Storage account types: General-purpose v2 (recommended), General-purpose v1 (legacy), Blob storage (legacy)
- Performance tiers: Standard (magnetic drives) and Premium (SSD-based)
- Replication options: LRS, ZRS, GRS (Geo-Redundant Storage), RA-GRS (Read-Access GRS), GZRS (Geo-Zone-Redundant Storage)
- Access tiers for blob data: Hot (frequently accessed), Cool (infrequently accessed, stored for at least 30 days), Cold (rarely accessed, stored for at least 90 days), Archive (rarely accessed, stored for at least 180 days)
- Account-level and blob-level tier assignment options
- Automatic tier management through lifecycle policies
- Cost implications vary significantly between tiers and access patterns

**Example:** A healthcare organization uses a General-purpose v2 storage account with GRS replication, storing active patient records in Hot tier, historical records in Cool tier, and long-term compliance data in Archive tier.

