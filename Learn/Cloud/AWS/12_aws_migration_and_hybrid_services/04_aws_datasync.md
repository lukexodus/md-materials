## AWS DataSync


DataSync provides secure, efficient data transfer service for moving large amounts of data between on-premises storage systems and AWS storage services.

### Transfer Capabilities

**Supported Sources:**

- Network File System (NFS) shares
- Server Message Block (SMB) shares
- Hadoop Distributed File System (HDFS)
- Object storage systems with S3 API compatibility

**AWS Destinations:**

- Amazon S3 (all storage classes)
- Amazon EFS
- Amazon FSx for Windows File Server
- Amazon FSx for Lustre

### Performance and Features

**Transfer Optimization:**

- Multi-threaded transfers with automatic bandwidth throttling
- Data compression and encryption in transit
- Network optimization with connection pooling
- Resume capability for interrupted transfers

**Data Integrity:** Built-in data validation ensuring transferred data matches source data through checksum verification.

**Scheduling:** Automated data transfer scheduling with hourly, daily, or weekly frequencies.

**Filtering:** File and folder filtering based on patterns, modification times, and other criteria.

