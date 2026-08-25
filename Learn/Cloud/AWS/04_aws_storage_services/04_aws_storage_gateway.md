## AWS Storage Gateway


Storage Gateway connects on-premises environments to AWS cloud storage services through a hybrid cloud storage service deployed as a VM or hardware appliance.

### Gateway Types

**File Gateway:** Presents S3 buckets as NFS/SMB file shares **Volume Gateway:**

- Stored Volumes: Primary data on-premises with async backup to S3
- Cached Volumes: Primary data in S3 with frequently accessed data cached locally

**Tape Gateway:** Virtual Tape Library (VTL) interface for backup applications

