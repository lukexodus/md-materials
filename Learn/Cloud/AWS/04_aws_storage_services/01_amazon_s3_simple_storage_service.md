## Amazon S3 (Simple Storage Service)


Amazon S3 serves as AWS's foundational object storage service, offering virtually unlimited scalability and industry-leading durability of 99.999999999% (11 9's).

### Buckets and Objects

S3 organizes data using a flat namespace structure consisting of buckets and objects. Buckets function as containers that hold objects, with each bucket requiring a globally unique name across all AWS accounts. Objects represent individual files stored within buckets, identified by unique keys that can include prefixes to simulate folder-like organization.

**Key characteristics:**

- Maximum object size: 5 TB
- Bucket names must be DNS-compliant and globally unique
- Objects can include metadata and tags for organization
- Support for multipart uploads for large files
- Cross-Region Replication (CRR) and Same-Region Replication (SRR)

### Storage Classes

S3 provides multiple storage classes optimized for different access patterns and cost requirements:

**Frequently Accessed Data:**

- **S3 Standard**: Default storage class for frequently accessed data with low latency and high throughput
- **S3 Reduced Redundancy Storage (RRS)**: [Unverified] - This class may be deprecated in favor of other options

**Infrequently Accessed Data:**

- **S3 Standard-IA**: Lower storage cost with retrieval fees, minimum 30-day storage duration
- **S3 One Zone-IA**: Single availability zone storage with lower costs but reduced redundancy

**Archive Storage:**

- **S3 Glacier Instant Retrieval**: Archive storage with millisecond access times
- **S3 Glacier Flexible Retrieval**: Archive storage with retrieval times from minutes to hours
- **S3 Glacier Deep Archive**: Lowest-cost storage with 12-hour retrieval times

**Intelligent Storage:**

- **S3 Intelligent-Tiering**: Automatically moves objects between access tiers based on usage patterns

### Lifecycle Policies and Versioning

S3 lifecycle policies automate cost optimization by transitioning objects between storage classes or deleting them based on predefined rules. These policies can be configured based on object age, tags, or prefixes.

**Lifecycle Policy Capabilities:**

- Transition objects to different storage classes
- Delete current versions after specified periods
- Delete incomplete multipart uploads
- Apply rules to specific prefixes or tags

**Versioning** maintains multiple variants of objects within buckets, providing protection against accidental deletion or modification. When enabled, S3 assigns unique version IDs to each object variant.

**Versioning Features:**

- Preserve, retrieve, and restore every version of objects
- Protect against accidental deletion
- Suspend versioning without losing existing versions
- Integration with lifecycle policies for version management

