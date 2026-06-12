# Amazon S3 Professional Mastery Curriculum

## Module 1: Foundations of Object Storage

### Section 1.1: Storage Paradigm Fundamentals

#### Topic 1.1.1: Storage Model Comparison
- Object storage model
- Block storage model
- File storage model
- Structural differences
- Metadata handling per paradigm
- Addressability models
- Hierarchical vs flat namespace
- Mutability characteristics
- Protocol differences (NFS, SMB, iSCSI, REST)
- Latency profiles per paradigm
- Throughput profiles per paradigm
- Concurrency models
- Use case mapping per paradigm

#### Topic 1.1.2: Object Storage Deep Concepts
- Flat namespace model
- Unique identifier (key) addressing
- Immutable object semantics
- Eventual vs strong consistency tradeoffs
- Horizontal scalability characteristics
- Metadata richness
- HTTP/REST native interface
- CRUD operations on objects
- Object atomicity
- Decoupling compute from storage

---

### Section 1.2: S3 Core Terminology

#### Topic 1.2.1: Buckets
- Definition and role
- Namespace uniqueness scope (global)
- Bucket as unit of configuration
- Bucket as billing boundary
- Bucket as replication unit
- Bucket as permission boundary

#### Topic 1.2.2: Objects
- Definition and components
- Key (name)
- Value (data payload)
- Metadata (system and user)
- Version ID
- Subresources
- Object size limits
- Zero-byte objects

#### Topic 1.2.3: Keys and Prefixes
- Key as full object path
- Prefix as logical directory emulation
- Delimiter behavior
- Prefix-based partitioning implications
- Prefix cardinality and performance
- Unicode support in keys
- URL encoding requirements

#### Topic 1.2.4: Object Ownership and Identity
- Bucket owner
- Object owner
- Canonical user ID
- Account ID vs canonical ID
- ACL-based ownership
- Bucket Owner Enforced mode

#### Topic 1.2.5: Regions and Availability Zones
- AWS Region definition
- AZ definition
- S3 regional scope
- Multi-AZ storage replication
- Region isolation model
- Data residency implications
- Region selection criteria

---

### Section 1.3: Durability, Availability, and Consistency

#### Topic 1.3.1: Durability Model
- 11 nines durability (99.999999999%)
- Durability calculation basis
- Annual expected object loss rate
- Erasure coding (conceptual)
- Redundant storage across facilities
- Checksums and data integrity
- Silent data corruption detection

#### Topic 1.3.2: Availability Model
- Standard availability (99.99%)
- SLA definitions
- Availability per storage class
- Failover behavior
- Reduced redundancy concepts
- Service disruption handling

#### Topic 1.3.3: Consistency Models
- Strong read-after-write consistency (post-December 2020)
- Consistency for new PUT (create)
- Consistency for overwrite PUT
- Consistency for DELETE
- LIST operation consistency
- Historical eventual consistency model
- Consistency implications for distributed applications
- Conditional writes behavior
- If-Match / If-None-Match semantics

#### Topic 1.3.4: CAP Theorem Considerations
- S3 as CP or AP system framing
- Partition tolerance guarantees
- Consistency guarantees
- Availability tradeoffs
- Design implications for application architects

---

### Section 1.4: Shared Responsibility Model

#### Topic 1.4.1: AWS Responsibilities
- Physical infrastructure
- Network infrastructure
- Storage hardware
- Hypervisor and virtualization layer
- Service availability
- Durability guarantees

#### Topic 1.4.2: Customer Responsibilities
- Data classification
- Encryption configuration
- Access control configuration
- Bucket policy management
- Versioning enablement
- Replication configuration
- Lifecycle policy management
- Monitoring and alerting
- Compliance enforcement

---

## Module 2: S3 Internal Architecture

### Section 2.1: Distributed Storage Architecture

#### Topic 2.1.1: Partitioning and Key-Space Distribution
- Hash-based partitioning
- Key prefix as partition determinant
- Hot partition problem
- Partition splitting behavior
- Sequential key anti-pattern
- Randomized prefix pattern
- Partition cardinality
- Partition-level throughput limits

#### Topic 2.1.2: Request Routing
- DNS-based routing
- Regional endpoint resolution
- Availability Zone routing
- Storage node selection
- Request load balancing
- Retry and failover routing

#### Topic 2.1.3: Storage Node Architecture
- Object sharding across nodes
- Replication across storage nodes
- Node failure handling
- Data reconstruction mechanisms
- Integrity verification at node level

#### Topic 2.1.4: Metadata Management
- Metadata service architecture
- Separation of metadata from data
- Metadata indexing
- Listing operation internals
- Metadata update propagation

---

### Section 2.2: Scaling and Throughput

#### Topic 2.2.1: Throughput Characteristics
- Per-prefix request rate limits
- 3,500 PUT/COPY/POST/DELETE per prefix per second
- 5,500 GET/HEAD per prefix per second
- Automatic scaling behavior
- Burst capacity
- Sustained throughput patterns

#### Topic 2.2.2: Multi-Tenant Design
- Tenant isolation model
- Noisy neighbor considerations
- Per-account limits
- Service quota framework
- Throttling behavior (503 Slow Down)
- Retry guidance for throttling

#### Topic 2.2.3: Replication Mechanisms
- Synchronous vs asynchronous replication
- Cross-AZ replication
- Cross-region replication pipeline
- Replication consistency guarantees
- RTC (Replication Time Control) internals

---

## Module 3: Buckets

### Section 3.1: Bucket Creation and Configuration

#### Topic 3.1.1: Bucket Naming Rules
- Globally unique namespace
- 3–63 character constraint
- Lowercase letters, numbers, hyphens only
- No underscores
- No IP address format
- No uppercase
- Bucket name DNS implications
- Transfer Acceleration naming constraints

#### Topic 3.1.2: Regional Placement
- Bucket region immutability
- Region selection at creation
- Latency-based region selection
- Data residency region selection
- Multi-region access patterns

#### Topic 3.1.3: Bucket Types
- General purpose buckets
- Directory buckets
- Express One Zone buckets
- Differences in consistency model
- Differences in performance
- Differences in availability
- Differences in API support

---

### Section 3.2: Bucket Ownership and Access

#### Topic 3.2.1: Bucket Policies
- JSON policy structure
- Principal element
- Action element
- Resource element (ARN)
- Condition element
- Effect: Allow / Deny
- Explicit deny precedence
- Policy size limits (20 KB)
- Cross-account policy patterns
- Service principal patterns

#### Topic 3.2.2: Public Access Settings
- Block Public Access (BPA) architecture
- BPA at account level
- BPA at bucket level
- Four BPA flags
  - BlockPublicAcls
  - IgnorePublicAcls
  - BlockPublicPolicy
  - RestrictPublicBuckets
- Interaction with existing ACLs
- Interaction with bucket policies

#### Topic 3.2.3: Object Ownership Modes
- BucketOwnerEnforced (ACL disabled)
- BucketOwnerPreferred
- ObjectWriter
- ACL behavior per mode
- Cross-account upload ownership
- Default setting (BucketOwnerEnforced)

#### Topic 3.2.4: Bucket Quotas and Limits
- Maximum buckets per account (default 100, soft limit)
- Quota increase process
- Object count (no hard limit)
- Total storage (no hard limit)
- Service quota console

#### Topic 3.2.5: Bucket Deletion
- Empty bucket requirement
- Versioning-aware deletion
- MFA Delete interaction
- Suspended versioning delete markers
- Bucket deletion audit trail

---

## Module 4: Objects

### Section 4.1: Object Lifecycle

#### Topic 4.1.1: Object Creation
- PutObject API
- CopyObject API
- CreateMultipartUpload → UploadPart → CompleteMultipartUpload
- Presigned URL upload
- POST form upload
- Object atomicity guarantee

#### Topic 4.1.2: Object Retrieval
- GetObject API
- HeadObject API
- Range GET requests
- Conditional GET (If-Modified-Since, If-Match)
- Partial object access

#### Topic 4.1.3: Object Deletion
- DeleteObject API
- DeleteObjects (batch delete)
- Versioning interaction with delete
- Delete markers
- Permanent deletion of versioned objects

---

### Section 4.2: Object Metadata

#### Topic 4.2.1: System Metadata
- Content-Type
- Content-Length
- Content-Encoding
- Content-Disposition
- Content-Language
- Cache-Control
- Expires
- Last-Modified
- ETag

#### Topic 4.2.2: User-Defined Metadata
- x-amz-meta- prefix
- Key-value pairs
- Metadata size limit (2 KB)
- Metadata immutability (requires copy to update)
- Metadata search limitations
- Tagging as metadata alternative

#### Topic 4.2.3: Object Tags
- Tag key-value pairs
- Up to 10 tags per object
- Tag-based IAM conditions
- Tag-based lifecycle rules
- Tag-based replication rules
- Cost allocation tags
- Tag modification without object copy

---

### Section 4.3: Object Integrity and Attributes

#### Topic 4.3.1: ETags
- MD5-based ETag for single-part uploads
- Multipart ETag format (-N suffix)
- ETag as conditional request basis
- ETag limitations for integrity validation
- Non-uniqueness of ETags

#### Topic 4.3.2: Checksums
- CRC32
- CRC32C
- SHA-1
- SHA-256
- Full-object checksum
- Trailing checksum support
- Checksum validation on upload
- Checksum validation on download
- Multipart checksum modes
  - COMPOSITE
  - FULL_OBJECT

#### Topic 4.3.3: Object Attributes API
- GetObjectAttributes API
- ETag retrieval
- Checksum retrieval
- ObjectParts for multipart
- StorageClass
- ObjectSize

---

### Section 4.4: Object Locking

#### Topic 4.4.1: Object Lock Overview
- WORM (Write Once Read Many) model
- Bucket-level enablement (immutable)
- Object-level configuration
- Lock modes

#### Topic 4.4.2: Retention Modes
- COMPLIANCE mode
  - No deletion or modification by any user
  - No override including root
- GOVERNANCE mode
  - Override with s3:BypassGovernanceRetention
  - Auditable override
- Retention period configuration
- Default retention configuration
- RetainUntilDate semantics

#### Topic 4.4.3: Legal Hold
- Independent of retention period
- On/off toggle
- s3:PutObjectLegalHold permission
- Use cases (litigation, investigation)
- Interaction with retention modes

---

## Module 5: Data Consistency

### Section 5.1: Consistency Guarantees

#### Topic 5.1.1: Read-After-Write Consistency
- New object PUT → immediate consistent read
- GET after successful PUT
- HEAD after successful PUT
- Listing after PUT

#### Topic 5.1.2: Overwrite Consistency
- Overwrite PUT → strongly consistent
- No dirty reads on overwrite
- Ordering guarantees (last-writer-wins)
- Concurrent write behavior

#### Topic 5.1.3: Delete Consistency
- DELETE → strongly consistent read returns 404
- Versioned DELETE → strongly consistent
- List consistency after DELETE

#### Topic 5.1.4: List Consistency
- ListObjects / ListObjectsV2 consistency
- Paginated listing consistency
- Listing after batch delete
- Inventory as eventual alternative

#### Topic 5.1.5: Historical Consistency Behavior
- Pre-2020 eventual consistency model
- Read-after-write for new objects (historical)
- Eventual for overwrites and deletes (historical)
- Application design patterns from pre-2020 era
- Migration implications

#### Topic 5.1.6: Design Implications
- Removing read-after-write delays in code
- Removing consistency workarounds (DynamoDB lock tables)
- Application simplification post-2020
- Edge cases and conditional operations

---

## Module 6: Storage Classes

### Section 6.1: Frequently Accessed Storage

#### Topic 6.1.1: S3 Standard
- Use cases
- Millisecond retrieval latency
- 99.99% availability SLA
- 11 nines durability
- Multi-AZ redundancy
- Per-request pricing
- Per-GB-month pricing
- No minimum storage duration
- No retrieval fee
- Tradeoffs vs other classes

#### Topic 6.1.2: S3 Express One Zone
- Single AZ architecture
- Single-digit millisecond latency
- 10x faster than Standard (claimed performance characteristic)
- Directory bucket requirement
- Use cases: latency-sensitive workloads, ML training, HPC
- Availability (99.95%)
- Pricing model
- No cross-AZ redundancy tradeoff
- API differences from Standard
- CreateSession API

---

### Section 6.2: Infrequent Access Storage

#### Topic 6.2.1: S3 Standard-IA
- Use cases: backups, DR copies, infrequently accessed data
- 99.9% availability SLA
- 11 nines durability
- Millisecond retrieval
- Per-GB retrieval fee
- 30-day minimum storage duration
- 128 KB minimum object size billing
- Multi-AZ redundancy
- Tradeoffs vs Standard

#### Topic 6.2.2: S3 One Zone-IA
- Single AZ storage
- 99.5% availability
- 11 nines durability within AZ
- Use cases: reproducible data, secondary backups
- Lower storage cost than Standard-IA
- Per-GB retrieval fee
- 30-day minimum storage duration
- 128 KB minimum object size billing
- AZ failure exposure tradeoff

---

### Section 6.3: Intelligent Tiering

#### Topic 6.3.1: S3 Intelligent-Tiering
- Automated tiering model
- No retrieval fees
- Monitoring and automation fee per object
- Access tier model
  - Frequent Access tier
  - Infrequent Access tier (30-day threshold)
  - Archive Instant Access tier (90-day threshold)
  - Archive Access tier (optional, 90–730 days)
  - Deep Archive Access tier (optional, 180–730 days)
- Activation of archive tiers
- Use cases: unknown or changing access patterns
- Minimum object size (>1 KB for tiering logic)
- 99.9% availability SLA
- 11 nines durability
- Transition latency (archive tiers)
- Tradeoffs vs manual lifecycle policies

---

### Section 6.4: Archive Storage

#### Topic 6.4.1: S3 Glacier Instant Retrieval
- Millisecond retrieval latency
- Quarterly access pattern assumption
- Per-GB retrieval fee
- 90-day minimum storage duration
- 128 KB minimum object size billing
- 99.9% availability
- 11 nines durability
- Use cases: medical images, news media archives

#### Topic 6.4.2: S3 Glacier Flexible Retrieval
- Retrieval options
  - Expedited (1–5 minutes)
  - Standard (3–5 hours)
  - Bulk (5–12 hours)
- Bulk retrieval pricing
- 90-day minimum storage duration
- 40 KB minimum object size billing
- 99.99% availability (after restore)
- 11 nines durability
- Restore to S3 Standard-IA copy
- Use cases: annual backups, compliance archives

#### Topic 6.4.3: S3 Glacier Deep Archive
- Lowest cost storage class
- Retrieval options
  - Standard (12 hours)
  - Bulk (48 hours)
- 180-day minimum storage duration
- 40 KB minimum object size billing
- 99.99% availability (after restore)
- 11 nines durability
- Use cases: regulatory compliance, 7–10 year retention

---

### Section 6.5: Reduced Redundancy (Legacy)

#### Topic 6.5.1: S3 Reduced Redundancy Storage (RRS)
- Legacy class (not recommended)
- 99.99% durability (lower than Standard)
- Single-AZ-like redundancy
- Cost comparison
- Migration path to Standard or IA

---

### Section 6.6: Storage Class Selection Framework

#### Topic 6.6.1: Selection Decision Framework
- Access frequency analysis
- Retrieval latency requirements
- Cost sensitivity
- Compliance and retention requirements
- Data reproducibility
- Geographic redundancy requirements
- Lifecycle transition mapping

---

## Module 7: Data Management

### Section 7.1: Versioning

#### Topic 7.1.1: Versioning States
- Unversioned (default)
- Versioning-enabled
- Versioning-suspended
- State transition rules
- MFA Delete requirement

#### Topic 7.1.2: Versioning Behavior
- Version ID assignment (unique, system-generated)
- GET behavior (current vs specific version)
- DELETE behavior (delete marker creation)
- Overwrite behavior (new version creation)
- Version listing (ListObjectVersions API)
- Null version ID (pre-versioning objects)

#### Topic 7.1.3: MFA Delete
- MFA device requirement
- Operations requiring MFA
  - Changing versioning state
  - Permanently deleting a version
- Root account requirement
- Integration with hardware MFA

#### Topic 7.1.4: Versioning Cost Implications
- Storage cost accumulation
- Lifecycle policy for version expiration
- Noncurrent version expiration rules
- Delete marker cleanup

---

### Section 7.2: Lifecycle Policies

#### Topic 7.2.1: Lifecycle Rule Components
- Filter (prefix, tags, object size)
- Scope (entire bucket or filtered)
- Actions
  - Transition actions
  - Expiration actions
  - Abort incomplete multipart uploads
  - Noncurrent version expiration
  - Noncurrent version transitions

#### Topic 7.2.2: Transition Rules
- Minimum storage duration constraints per class
- Waterfall transition model
- Transition timing (days after creation)
- Noncurrent version transition
- Transition cost implications

#### Topic 7.2.3: Expiration Rules
- Object expiration (current version)
- Noncurrent version expiration
- Expired object delete marker cleanup
- Incomplete multipart upload abort rules

#### Topic 7.2.4: Lifecycle Rule Evaluation
- Policy evaluation order
- Interaction with versioning
- Minimum 1-day granularity
- Transition eligibility check

---

### Section 7.3: Replication (Overview)

#### Topic 7.3.1: Replication Configuration
- Replication rule structure
- Source bucket configuration
- Destination bucket configuration
- IAM role for replication
- Versioning prerequisite
- Replication scope (entire bucket, prefix, tags)

#### Topic 7.3.2: Replication Types
- CRR (Cross-Region Replication)
- SRR (Same-Region Replication)
- Multi-destination replication
- Bidirectional replication

#### Topic 7.3.3: Replication Metrics and Monitoring
- Replication latency metrics
- Bytes pending replication
- Operations pending replication
- CloudWatch replication metrics
- Replication Time Control (RTC) SLA (15 minutes)

---

### Section 7.4: Batch Operations

#### Topic 7.4.1: Batch Operations Architecture
- Job types
  - CopyObject
  - InvokeAWS Lambda function
  - RestoreObject
  - PutObjectACL
  - PutObjectTagging
  - DeleteObjectTagging
  - ReplicateObject
  - PutObjectLegalHold
  - PutObjectRetention
  - S3 Access Grants
- Manifest sources (S3 Inventory, custom CSV)
- IAM role requirement
- Job priority
- Job status tracking
- Completion report

#### Topic 7.4.2: Batch Operations Use Cases
- Bulk ACL remediation
- Bulk encryption migration
- Bulk tagging
- Large-scale copy operations
- Retroactive replication

---

### Section 7.5: S3 Inventory

#### Topic 7.5.1: Inventory Configuration
- Destination bucket
- Frequency (daily, weekly)
- Output format (CSV, ORC, Parquet)
- Optional fields
  - Size
  - Last modified
  - Storage class
  - ETag
  - Versioning status
  - Replication status
  - Encryption status
  - Object lock status
  - Checksum algorithm
  - Object access control
- Prefix filtering
- Encryption of inventory output

#### Topic 7.5.2: Inventory Use Cases
- Compliance auditing
- Storage class auditing
- Replication status reporting
- Encryption status auditing
- Batch Operations manifest source
- Cost analysis input

---

### Section 7.6: Storage Lens

#### Topic 7.6.1: Storage Lens Architecture
- Organization-level aggregation
- Account-level aggregation
- Region-level aggregation
- Bucket-level aggregation
- Dashboard configuration
- Metrics export (S3, CloudWatch)
- Free vs advanced tier metrics

#### Topic 7.6.2: Storage Lens Metrics
- Summary metrics
- Cost optimization metrics
- Data protection metrics
- Access management metrics
- Event metrics
- Performance metrics
- Activity metrics
- Detailed status code metrics (advanced)

#### Topic 7.6.3: Storage Lens Use Cases
- Organization-wide storage visibility
- Unused bucket identification
- Storage class optimization
- Data protection gap identification
- Incomplete multipart upload identification

---

### Section 7.7: Object Lambda

#### Topic 7.7.1: Object Lambda Architecture
- Object Lambda Access Point
- Lambda function invocation on GetObject
- WriteGetObjectResponse API
- Supporting Access Point requirement
- IAM configuration

#### Topic 7.7.2: Object Lambda Use Cases
- Dynamic data masking (PII redaction)
- Format conversion (XML to JSON)
- Image resizing/compression on-demand
- Data enrichment on retrieval
- Content validation on retrieval
- Watermarking

---

### Section 7.8: Event Notifications

#### Topic 7.8.1: Event Types
- s3:ObjectCreated:*
- s3:ObjectCreated:Put
- s3:ObjectCreated:Post
- s3:ObjectCreated:Copy
- s3:ObjectCreated:CompleteMultipartUpload
- s3:ObjectRemoved:*
- s3:ObjectRemoved:Delete
- s3:ObjectRemoved:DeleteMarkerCreated
- s3:ObjectRestore:Post
- s3:ObjectRestore:Completed
- s3:ReducedRedundancyLostObject
- s3:Replication:*
- s3:LifecycleExpiration:*
- s3:ObjectTagging:*
- s3:ObjectAcl:Put
- s3:IntelligentTiering
- s3:LifecycleTransition

#### Topic 7.8.2: Event Notification Destinations
- SNS
- SQS
- Lambda
- EventBridge (recommended pattern)
- Filtering (prefix and suffix)
- EventBridge advantages (rule-based routing, archiving, replay)

---

## Module 8: Security

### Section 8.1: IAM Fundamentals for S3

#### Topic 8.1.1: Identity-Based Policies
- User policies
- Group policies
- Role policies
- Inline vs managed policies
- Policy evaluation order
- Explicit allow, explicit deny, implicit deny

#### Topic 8.1.2: Resource-Based Policies
- Bucket policy as resource-based policy
- Principal specification
- Cross-account principal
- Service principal (e.g., CloudFront, Lambda)
- Anonymous principal ("*")

#### Topic 8.1.3: Policy Evaluation Logic
- Same-account evaluation
- Cross-account evaluation
- Organization SCP interaction
- Permission boundary interaction
- Session policy interaction

---

### Section 8.2: Bucket Policies

#### Topic 8.2.1: Bucket Policy Syntax
- Version
- Statement array
- Sid
- Effect
- Principal
- Action (s3:*)
- Resource (arn:aws:s3:::bucket and arn:aws:s3:::bucket/*)
- Condition operators

#### Topic 8.2.2: Common Condition Keys
- aws:SourceIp
- aws:SourceVpc
- aws:SourceVpce
- aws:PrincipalOrgID
- aws:SecureTransport (enforce HTTPS)
- s3:prefix
- s3:delimiter
- s3:x-amz-server-side-encryption
- s3:x-amz-server-side-encryption-aws-kms-key-id
- aws:RequestedRegion
- aws:PrincipalAccount
- aws:PrincipalArn
- s3:DataAccessPointArn
- s3:DataAccessPointAccount

#### Topic 8.2.3: Common Bucket Policy Patterns
- Enforce HTTPS (deny HTTP)
- Enforce encryption on upload
- Restrict to VPC endpoint
- Restrict to organization
- Cross-account read access
- IP allowlist
- CloudFront OAC pattern
- Deny delete operations

---

### Section 8.3: Access Points

#### Topic 8.3.1: Access Point Architecture
- Access Point as network endpoint alias
- Access Point ARN
- Access Point policy (subset of bucket policy)
- Bucket delegation to Access Point
- VPC-only Access Points
- Access Point hostname

#### Topic 8.3.2: Access Point Policy
- Principal restriction
- Prefix restriction
- Network origin condition
- Delegated bucket policy requirement (s3:DataAccessPointArn)

#### Topic 8.3.3: Multi-Region Access Points
- Global ARN
- Routing to nearest region
- Replication prerequisite
- Failover routing
- Active-passive routing
- Active-active routing
- Routing configuration (100/0 vs weighted)
- Multi-Region Access Point policy

---

### Section 8.4: Access Grants

#### Topic 8.4.1: S3 Access Grants Architecture
- Instance-level permissions
- Grantee types (IAM principal, directory user, directory group)
- Location-scoped grants
- Integration with IAM Identity Center
- Integration with corporate identity providers
- GetDataAccess API (temporary credentials)
- Access Grants metadata IAM tags

#### Topic 8.4.2: Access Grants Use Cases
- Multi-tenant data access at scale
- Identity provider-based data permissions
- Attribute-based access control (ABAC) for S3
- Large organization data governance

---

### Section 8.5: VPC Endpoints and Private Access

#### Topic 8.5.1: Gateway Endpoints
- Route table-based routing
- No additional cost
- S3 gateway endpoint policy
- Private subnet access pattern
- DNS behavior with gateway endpoints

#### Topic 8.5.2: Interface Endpoints (PrivateLink)
- ENI-based endpoint
- Private IP in VPC
- DNS resolution for private endpoint
- Endpoint-specific DNS names
- Per-AZ interface endpoint
- Cost per hour and per GB
- Use cases: no internet gateway required

#### Topic 8.5.3: Private Access Patterns
- Access from on-premises via Direct Connect
- VPN + VPC endpoint pattern
- Hybrid DNS resolution for S3
- Endpoint policies (restrict to specific buckets/accounts)

---

### Section 8.6: ACLs (Legacy)

#### Topic 8.6.1: ACL Model
- Bucket ACL
- Object ACL
- Canned ACLs
  - private
  - public-read
  - public-read-write
  - authenticated-read
  - aws-exec-read
  - bucket-owner-read
  - bucket-owner-full-control
- Grantee types
- Permissions (READ, WRITE, READ_ACP, WRITE_ACP, FULL_CONTROL)
- ACL deprecation path (BucketOwnerEnforced mode)

---

### Section 8.7: Cross-Account Access

#### Topic 8.7.1: Cross-Account Patterns
- Bucket policy granting cross-account access
- IAM role in target account
- Role assumption flow
- Object ownership in cross-account copy
- bucket-owner-full-control canned ACL pattern
- S3 Access Points cross-account
- Access Grants cross-account

#### Topic 8.7.2: Federated Access
- SAML 2.0 federation
- Web Identity federation (OIDC)
- STS AssumeRoleWithSAML
- STS AssumeRoleWithWebIdentity
- Session tags for ABAC
- Temporary credential scope

---

## Module 9: Encryption

### Section 9.1: Server-Side Encryption

#### Topic 9.1.1: SSE-S3 (Amazon S3 Managed Keys)
- AES-256 encryption
- Key management by AWS
- No additional cost
- Default encryption setting
- x-amz-server-side-encryption: AES256 header
- Bucket default encryption configuration
- Enforcement via bucket policy

#### Topic 9.1.2: SSE-KMS (AWS KMS Managed Keys)
- KMS CMK (Customer Managed Key) or AWS Managed Key
- Data key generation by KMS
- Envelope encryption model
- KMS API calls (GenerateDataKey, Decrypt)
- KMS costs per API call
- KMS key policy + bucket policy interaction
- CloudTrail audit of KMS calls
- x-amz-server-side-encryption: aws:kms header
- KMS key ID in object metadata
- Cross-account KMS usage
- KMS throttling implications at scale

#### Topic 9.1.3: DSSE-KMS (Dual-Layer SSE with KMS)
- Two independent encryption layers
- Two separate KMS data key calls
- Use cases (regulatory dual-layer requirement)
- Performance implications
- Cost implications
- x-amz-server-side-encryption: aws:kms:dsse header

#### Topic 9.1.4: SSE-C (Customer-Provided Keys)
- Customer provides AES-256 key per request
- AWS uses key, then discards
- Customer retains key management responsibility
- Key hash verification (MD5)
- HTTPS requirement (enforced)
- Key management burden
- No KMS integration
- CLI and SDK usage patterns

---

### Section 9.2: Client-Side Encryption

#### Topic 9.2.1: Client-Side Encryption with KMS CMK
- Encryption before upload
- AWS Encryption SDK
- KMS GenerateDataKey call on client
- Encrypted data + encrypted data key stored
- Decrypt on retrieval
- Key hierarchy

#### Topic 9.2.2: Client-Side Encryption with Customer Key
- Customer manages key material
- No KMS dependency
- Full customer responsibility
- Use cases (air-gapped key management)

#### Topic 9.2.3: Envelope Encryption Architecture
- Master key (KMS CMK)
- Data encryption key (DEK)
- Encrypted DEK storage alongside data
- DEK never stored unencrypted
- Decrypt flow: decrypt DEK → decrypt data
- Key rotation impact

---

### Section 9.3: KMS Architecture for S3

#### Topic 9.3.1: KMS Key Types
- AWS Managed Keys (aws/s3)
- Customer Managed Keys (CMK)
- Key aliases
- Key policies
- Grants

#### Topic 9.3.2: Key Rotation
- Automatic key rotation (annual, CMK)
- On-demand key rotation
- Rotation impact on existing objects
- Key material origin (KMS vs external vs CloudHSM)

#### Topic 9.3.3: Encryption Context
- Key-value pairs passed to KMS
- Tied to specific encryption operation
- Required for decryption
- Audit trail in CloudTrail
- bucket + object key as context

#### Topic 9.3.4: KMS Throttling and S3 at Scale
- KMS request quota (default 5,500–30,000 req/s)
- S3 SSE-KMS request amplification
- KMS quota increase process
- Mitigation: S3 Bucket Keys

#### Topic 9.3.5: S3 Bucket Keys
- Reduces KMS API calls
- Bucket-level data key generated by KMS
- Envelope encryption at bucket level
- Cost reduction (fewer KMS API calls)
- Enabling on new vs existing objects
- Interaction with CloudTrail (fewer KMS events)
- Interaction with replication

---

## Module 10: Networking

### Section 10.1: DNS and URL Patterns

#### Topic 10.1.1: Virtual-Hosted-Style URLs
- Format: bucket.s3.region.amazonaws.com/key
- Default and recommended pattern
- HTTPS certificate validity
- Rationale for deprecating path-style

#### Topic 10.1.2: Path-Style URLs
- Format: s3.region.amazonaws.com/bucket/key
- Deprecation timeline
- Legacy SDK behavior
- Migration considerations

#### Topic 10.1.3: Endpoint Types
- Regional endpoints (recommended)
- Global endpoint (s3.amazonaws.com)
- Dual-stack endpoints (IPv4 and IPv6)
- FIPS endpoints
- Accelerated endpoints (Transfer Acceleration)

---

### Section 10.2: VPC Networking

#### Topic 10.2.1: Gateway Endpoints for S3
- Configuration
- Route table entries
- No additional cost
- Endpoint policy
- Limitation: only within VPC

#### Topic 10.2.2: Interface Endpoints (PrivateLink) for S3
- ENI creation per AZ
- Private DNS integration
- Endpoint-specific DNS resolution
- Per-endpoint policy
- Use from on-premises via Direct Connect/VPN

#### Topic 10.2.3: Route Table Configuration
- Prefix list for S3 (managed by AWS)
- Route priority
- Subnet-level routing

---

### Section 10.3: Hybrid and Edge Networking

#### Topic 10.3.1: Direct Connect Integration
- Private VIF to VPC + gateway endpoint
- Public VIF to S3 public endpoint
- Bandwidth provisioning for S3 workloads
- Latency characteristics

#### Topic 10.3.2: S3 Transfer Acceleration
- CloudFront edge network for uploads
- Accelerated endpoint format
- Speed comparison (standard vs accelerated)
- Cost model (per-GB surcharge)
- Use cases (global uploads, cross-continent transfers)
- Speed comparison tool

#### Topic 10.3.3: CloudFront Integration
- S3 as CloudFront origin
- Origin Access Control (OAC)
- Origin Access Identity (OAI) legacy
- Signed URLs and signed cookies via CloudFront
- Cache behavior configuration
- Custom error pages from S3

---

## Module 11: Performance Engineering

### Section 11.1: Request Optimization

#### Topic 11.1.1: Prefix Design for Performance
- Hash-based prefix randomization
- UUID prefixes
- Date-prefix anti-pattern
- Parallel prefix strategy
- Read/write workload prefix separation

#### Topic 11.1.2: Connection Management
- HTTP persistent connections (keep-alive)
- Connection pooling in SDKs
- TCP connection reuse
- HTTP/2 support

#### Topic 11.1.3: SDK Request Tuning
- Max connections configuration
- Timeout configuration
- Retry configuration
- Adaptive retry mode
- Connection pool sizing

---

### Section 11.2: Multipart Upload

#### Topic 11.2.1: Multipart Upload Architecture
- 3-phase protocol (Initiate, Upload Parts, Complete)
- Part size (5 MB min, 5 GB max per part)
- Maximum parts (10,000)
- Maximum object size (5 TB)
- Parallel part uploads
- Part ETag tracking
- Abort and retry mechanics

#### Topic 11.2.2: Multipart Upload Optimization
- Optimal part size calculation
- Concurrency tuning
- Retry at part level (not full object)
- Bandwidth utilization
- Checksum per-part vs full-object

#### Topic 11.2.3: Incomplete Multipart Upload Cleanup
- Lifecycle rule: abort incomplete multipart uploads
- Storage cost of incomplete parts
- ListMultipartUploads API

---

### Section 11.3: Parallelism and Throughput

#### Topic 11.3.1: Parallel Downloads
- Range GET for parallel download
- Byte-range specification
- Reassembly logic
- Concurrency management

#### Topic 11.3.2: Throughput Tuning
- Per-prefix throughput ceiling
- Multiple prefixes for horizontal scaling
- Worker thread tuning
- Async I/O patterns

#### Topic 11.3.3: Latency Optimization
- Object size optimization
- First-byte latency vs throughput
- Caching at application layer
- ElastiCache for S3 object metadata
- CloudFront for read latency
- S3 Express One Zone for ultra-low latency

---

### Section 11.4: Benchmarking

#### Topic 11.4.1: Benchmarking Methodology
- Baseline measurement
- Throughput benchmarks
- Latency benchmarks
- TTFB (Time to First Byte) measurement
- Multipart vs single-put comparison
- Tool selection (s3-benchmark, s5cmd, awscli)

#### Topic 11.4.2: Performance Monitoring Metrics
- RequestLatency CloudWatch metric
- TotalRequestLatency
- FirstByteLatency
- BytesDownloaded / BytesUploaded
- 4xxErrors / 5xxErrors
- BucketSizeBytes
- NumberOfObjects

---

## Module 12: Data Transfer

### Section 12.1: Upload Patterns

#### Topic 12.1.1: Single-Part Upload
- PutObject API
- 5 GB maximum
- Atomic operation
- Recommended for objects < 100 MB

#### Topic 12.1.2: Multipart Upload
- CreateMultipartUpload
- UploadPart
- CompleteMultipartUpload
- AbortMultipartUpload
- Parallel execution
- Part checksums

#### Topic 12.1.3: Presigned URL Uploads
- PUT presigned URL
- POST presigned policy (browser upload)
- Expiration configuration
- Conditions (size, content-type, key prefix)
- Signature V4

#### Topic 12.1.4: Browser-Based Upload
- POST policy document
- HTML form construction
- Field conditions
- Redirect on success
- CORS configuration

#### Topic 12.1.5: SDK Transfer Manager
- Automatic multipart threshold
- Concurrency configuration
- Progress callbacks
- Retry behavior

---

### Section 12.2: Download Patterns

#### Topic 12.2.1: GetObject API
- Full object retrieval
- Range GET (partial retrieval)
- Conditional GET
- Response header overrides (content-type, cache-control, etc.)

#### Topic 12.2.2: Presigned URL Downloads
- GET presigned URL
- Expiration window
- Signature V4 query string
- Use cases (temporary access, client-direct downloads)
- HTTPS enforcement

#### Topic 12.2.3: Multipart Copy
- CopyObject for objects <5 GB
- UploadPartCopy for objects >5 GB
- Source and destination specification
- Copy within bucket
- Copy across buckets
- Copy across regions
- Metadata preservation or replacement

---

### Section 12.3: Large-Scale Migration

#### Topic 12.3.1: AWS DataSync
- Agent-based (on-premises) or agentless (AWS)
- S3 as source or destination
- Scheduling
- Incremental transfers
- Bandwidth throttling
- Integrity verification

#### Topic 12.3.2: AWS Snow Family
- Snowcone (8 TB usable)
- Snowball Edge Storage Optimized
- Snowball Edge Compute Optimized
- Snowmobile (exabyte-scale)
- Import to S3 workflow
- Export from S3 workflow
- Encryption at rest
- Chain of custody

#### Topic 12.3.3: S3 Replication as Migration
- One-time replication using Batch Operations
- Existing object replication
- Cross-account migration via replication
- Cutover strategy

#### Topic 12.3.4: Third-Party Tools
- s5cmd
- rclone
- Cyberduck
- Comparison to AWS CLI sync

---

## Module 13: Replication (Deep Dive)

### Section 13.1: Replication Architecture

#### Topic 13.1.1: CRR (Cross-Region Replication)
- Use cases
  - Compliance and data residency
  - DR and business continuity
  - Latency reduction for global users
  - Aggregation from edge to central
- Configuration requirements
- IAM role configuration
- Versioning requirement on both buckets

#### Topic 13.1.2: SRR (Same-Region Replication)
- Use cases
  - Aggregation across accounts
  - Dev/test copy of production data
  - Log aggregation
  - Compliance within region
- Configuration
- Ownership overwrite

#### Topic 13.1.3: Multi-Destination Replication
- Multiple rules for multiple destinations
- Rule priority
- Rule filter (prefix or tag)
- Fan-out replication pattern

#### Topic 13.1.4: Bidirectional Replication
- Replica modification sync
- s3:ReplicaModifications replication action
- Deletion replication (optional)
- Loop prevention mechanism

---

### Section 13.2: Replication Configuration

#### Topic 13.2.1: Replication Rule Components
- Rule ID
- Status (enabled/disabled)
- Filter (prefix, tag, AND logic)
- Destination bucket ARN
- Storage class override
- Ownership override
- Replication Time Control
- Metrics configuration
- Delete marker replication

#### Topic 13.2.2: Replication Time Control (RTC)
- 15-minute SLA (99.99% of objects)
- Replication latency metric
- Replication pending metrics
- Additional cost
- Compliance use cases

#### Topic 13.2.3: Replication of Encrypted Objects
- SSE-S3 objects: replicated by default
- SSE-KMS objects: additional KMS config required
  - Source KMS key
  - Destination KMS key
  - IAM role KMS permissions
- SSE-C: not replicable (customer holds key)
- DSSE-KMS replication

#### Topic 13.2.4: Replication of Existing Objects
- Not replicated by default
- Batch Replication via Batch Operations
- S3 Inventory as manifest
- One-time replication job

---

## Module 14: Governance and Compliance

### Section 14.1: Object Lock (Deep Dive)

#### Topic 14.1.1: WORM Model
- Write Once Read Many concept
- Regulatory mandate examples (SEC 17a-4, FINRA, CFTC, HIPAA)
- Immutability guarantee
- Bucket-level Object Lock enablement (at creation)

#### Topic 14.1.2: Governance vs Compliance Mode Comparison
- Deletion prevention scope
- User override capability (Governance)
- Root override capability (Governance)
- Audit trail for overrides
- Compliance mode irreversibility

#### Topic 14.1.3: Retention Configuration
- Default bucket retention policy
- Object-level retention override
- RetainUntilDate semantics
- Retention period extension (forward only)
- Retention period reduction restrictions

#### Topic 14.1.4: Legal Hold
- Independent of retention
- PutObjectLegalHold API
- s3:PutObjectLegalHold IAM permission
- GetObjectLegalHold API
- Use in active litigation

---

### Section 14.2: Compliance Frameworks

#### Topic 14.2.1: Regulatory Requirements Mapping
- SEC Rule 17a-4(f)
- FINRA
- HIPAA data retention
- CFTC regulations
- SOX requirements
- PCI DSS requirements

#### Topic 14.2.2: Data Residency
- Region locking
- SCPs to prevent bucket creation outside approved regions
- Multi-region access without data movement
- Data sovereignty controls

#### Topic 14.2.3: Governance Models
- Coarse-grained governance (bucket-level policies)
- Fine-grained governance (object-level tagging + ABAC)
- Access Grants for large-scale governance
- AWS Organizations integration

---

## Module 15: Monitoring and Observability

### Section 15.1: CloudWatch Integration

#### Topic 15.1.1: S3 CloudWatch Metrics
- Storage metrics (daily)
  - BucketSizeBytes
  - NumberOfObjects
- Request metrics (1-minute, requires enablement)
  - AllRequests
  - GetRequests
  - PutRequests
  - DeleteRequests
  - HeadRequests
  - PostRequests
  - SelectRequests
  - ListRequests
  - 4xxErrors
  - 5xxErrors
  - FirstByteLatency
  - TotalRequestLatency
  - BytesDownloaded
  - BytesUploaded
  - SelectScannedBytes
  - SelectReturnedBytes

#### Topic 15.1.2: CloudWatch Alarms for S3
- Error rate alarms (4xx, 5xx)
- Latency alarms
- Bytes transferred alarms
- Replication latency alarms
- SNS integration for alerting

#### Topic 15.1.3: CloudWatch Metrics Filters
- Prefix-level metrics
- Access Point metrics
- Filtered metric configuration

---

### Section 15.2: CloudTrail Integration

#### Topic 15.2.1: CloudTrail Event Types for S3
- Management events (bucket-level operations)
- Data events (object-level operations: GetObject, PutObject, DeleteObject)
- Insight events

#### Topic 15.2.2: S3 Data Event Configuration
- Data event cost implications
- Selective logging (prefix filtering)
- Multi-account trail configuration
- Organization trail

#### Topic 15.2.3: CloudTrail Analysis
- Athena queries on CloudTrail logs
- Security investigation queries
- Access pattern analysis
- Anomaly detection via CloudTrail

---

### Section 15.3: Server Access Logging

#### Topic 15.3.1: Access Log Configuration
- Source bucket
- Target bucket (must be in same region)
- Target prefix
- Logging delivery best effort (not guaranteed)
- Log record format
- Fields: requester, bucket, key, status, error code, bytes, turn-around time

#### Topic 15.3.2: Access Log Analysis
- Athena table for S3 access logs
- Partitioning strategy for logs
- Query patterns
  - Top requester analysis
  - Error analysis
  - Bandwidth analysis
  - Referrer analysis

---

### Section 15.4: Troubleshooting via Observability

#### Topic 15.4.1: Operational Runbooks
- 4xx error investigation workflow
- 5xx error investigation workflow
- Replication lag investigation workflow
- KMS error investigation workflow
- Access denied investigation workflow

---

## Module 16: Cost Optimization

### Section 16.1: S3 Pricing Model

#### Topic 16.1.1: Storage Pricing
- Per-GB-month pricing per storage class
- Regional pricing variations
- Minimum storage duration billing
- Minimum object size billing

#### Topic 16.1.2: Request Pricing
- PUT, COPY, POST, LIST pricing (per 1,000)
- GET, SELECT, other requests pricing (per 1,000)
- Lifecycle transition request pricing
- DELETE request (free)
- Class-specific request pricing

#### Topic 16.1.3: Data Transfer Pricing
- Data transfer in (free)
- Data transfer out to internet (per GB)
- Data transfer between regions
- Data transfer to CloudFront (free)
- Data transfer within same region (free)
- Accelerated transfer surcharge

#### Topic 16.1.4: Feature-Specific Costs
- Replication (storage + request in destination)
- Object Lock (no additional cost)
- S3 Inventory (per object listed)
- S3 Storage Lens (advanced metrics)
- Batch Operations (per job + per object)
- Object Lambda (per request + Lambda invocation)
- KMS per-API costs with SSE-KMS
- S3 Bucket Keys cost reduction

---

### Section 16.2: Cost Optimization Strategies

#### Topic 16.2.1: Storage Class Optimization
- Intelligent-Tiering for unknown access patterns
- Lifecycle policies for known access patterns
- Identifying cold data via Storage Lens
- Inventory-based storage class audit

#### Topic 16.2.2: Lifecycle Policy Optimization
- Transition timing optimization
- Noncurrent version expiration
- Delete marker cleanup
- Incomplete multipart upload cleanup
- 30-day minimum duration awareness

#### Topic 16.2.3: Request Optimization
- Batching small objects
- LIST request minimization
- Inventory instead of repeated LIST
- Metadata caching to reduce HEAD requests

#### Topic 16.2.4: Data Transfer Optimization
- CloudFront for outbound reduction
- Same-region compute placement
- VPC endpoint (no data transfer charges)
- Compression before upload

#### Topic 16.2.5: FinOps Considerations
- Cost allocation tags
- AWS Cost Explorer S3 drill-down
- Budget alerts for S3 spend
- Storage Lens cost optimization recommendations
- Showback and chargeback by prefix/tag

---

## Module 17: Integration with AWS Services

### Section 17.1: Compute Integrations

#### Topic 17.1.1: EC2 Integration
- Instance profile IAM role for S3 access
- Metadata service credentials
- EBS vs S3 for application data patterns
- Instance store + S3 checkpoint pattern
- EC2 in same region for transfer cost optimization

#### Topic 17.1.2: EBS Integration
- EBS snapshot storage in S3 (opaque)
- EBS vs S3 decision criteria
- Backup patterns (EC2 data to S3)

#### Topic 17.1.3: EFS Integration
- EFS vs S3 decision criteria
- DataSync for EFS-to-S3 migration
- EFS as shared filesystem, S3 as object repository

#### Topic 17.1.4: Lambda Integration
- Lambda triggered by S3 events
- Lambda reading/writing S3 objects
- Lambda execution role S3 permissions
- S3 as Lambda deployment package source
- S3 Object Lambda integration
- Lambda cold start vs S3 latency

#### Topic 17.1.5: ECS/EKS Integration
- Task/pod IAM role for S3 (IAM Roles for Service Accounts)
- S3 as shared storage for containers
- S3 as artifact registry
- Persistent volume workarounds with S3

---

### Section 17.2: Content Delivery

#### Topic 17.2.1: CloudFront Integration
- S3 as origin
- OAC (Origin Access Control) configuration
- Signed URLs for private content
- Signed cookies for private content
- Cache invalidation
- CloudFront Functions for request manipulation
- Lambda@Edge for dynamic content
- Static website hosting via CloudFront + S3

#### Topic 17.2.2: API Gateway Integration
- API Gateway as S3 proxy
- Binary media types
- IAM auth for private uploads via API
- Presigned URL generation API pattern

---

### Section 17.3: Analytics Integrations

#### Topic 17.3.1: Athena Integration
- S3 as Athena data source
- Partitioning for query performance
- Glue Data Catalog integration
- SerDe formats (Parquet, ORC, JSON, CSV)
- Athena output to S3
- Partition projection
- CTAS (Create Table As Select)

#### Topic 17.3.2: AWS Glue Integration
- Glue Crawler for S3 catalog
- Glue ETL jobs reading/writing S3
- Glue Data Catalog as Athena metastore
- Lake Formation permissions on S3

#### Topic 17.3.3: EMR Integration
- EMR with S3 as storage (decoupled storage/compute)
- EMRFS (EMR File System) for S3
- EMRFS consistent view (DynamoDB for consistency — legacy)
- Spot Instance + S3 checkpoint pattern
- EMR Serverless with S3

#### Topic 17.3.4: Lake Formation Integration
- Lake Formation permissions on S3 locations
- Column and row-level security
- Data lake formation from S3 buckets
- LF-Tags (attribute-based access)
- Cross-account data sharing

#### Topic 17.3.5: Redshift Integration
- Redshift COPY command from S3
- Redshift UNLOAD to S3
- Redshift Spectrum (external tables on S3)
- Redshift data sharing with S3 Lake

#### Topic 17.3.6: S3 Tables (Preview/New Feature)
- Apache Iceberg table format
- Managed table storage
- Query via Athena, Redshift, EMR, Spark
- Automatic compaction
- Snapshot management
- ACID transactions

---

### Section 17.4: Database Integrations

#### Topic 17.4.1: DynamoDB Integration
- DynamoDB export to S3 (full and incremental)
- DynamoDB import from S3
- S3 as DynamoDB backup destination (Point-in-Time Recovery exports)
- Large attribute storage pattern (pointer to S3)

#### Topic 17.4.2: RDS Integration
- RDS snapshot export to S3 (Parquet)
- RDS backup to S3 (automated, opaque)
- RDS/Aurora bulk load from S3

---

### Section 17.5: Event and Workflow Integrations

#### Topic 17.5.1: EventBridge Integration
- S3 events to EventBridge
- Rule-based routing (vs direct SNS/SQS/Lambda)
- Event archive and replay
- Cross-account event routing
- S3 Object Created / Deleted / Restore rules

#### Topic 17.5.2: Step Functions Integration
- S3 as state input/output
- Parallel S3 operations via Map state
- Large payload (>256 KB) via S3 reference
- S3-triggered Step Functions execution

#### Topic 17.5.3: Kinesis Integration
- Kinesis Data Streams → Firehose → S3
- Kinesis Data Firehose S3 destination
- Dynamic partitioning in Firehose
- Buffer size and interval configuration
- Parquet/ORC conversion in Firehose
- Glue Schema Registry integration

#### Topic 17.5.4: SQS/SNS Integration
- S3 event → SQS queue
- S3 event → SNS topic → fan-out
- Fan-out: SNS → SQS + Lambda + Email
- Dead Letter Queue for failed processing
- SQS message visibility timeout tuning

---

### Section 17.6: Backup Integration

#### Topic 17.6.1: AWS Backup Integration
- S3 backup plans via AWS Backup
- Backup vault configuration
- Lifecycle within backup vault
- Cross-region backup copy
- Compliance reporting via AWS Backup

---

## Module 18: Data Lake Architectures

### Section 18.1: Data Lake Fundamentals

#### Topic 18.1.1: Data Lake vs Data Warehouse
- Schema-on-read vs schema-on-write
- Multi-format storage
- Scale economics
- Flexibility vs governance tradeoffs
- Lakehouse architecture (S3 + Iceberg/Delta)

#### Topic 18.1.2: Data Lake Zones
- Raw / Landing zone
- Cleansed / Staging zone
- Curated / Processed zone
- Consumption / Presentation zone
- Separate bucket vs prefix strategy
- IAM permissions per zone

---

### Section 18.2: Data Organization

#### Topic 18.2.1: Partitioning Strategies
- Hive-style partitioning (key=value)
- Date-based partitioning (year/month/day/hour)
- Entity-based partitioning
- Partition cardinality tradeoffs
- Small file problem
- Partition pruning in Athena and Spark
- Partition projection (Athena)

#### Topic 18.2.2: File Format Optimization
- Parquet (columnar, splittable)
- ORC (columnar, splittable)
- Avro (row-based, schema evolution)
- JSON (schema-less, larger)
- CSV (simplest, no schema)
- File size optimization (128 MB–1 GB target)
- Compression (Snappy, GZIP, ZSTD, LZO)
- Splittability requirements

#### Topic 18.2.3: Table Format Layer (Open Table Formats)
- Apache Iceberg
  - Hidden partitioning
  - Time travel
  - Schema evolution
  - ACID transactions
  - Compaction
- Apache Hudi
  - COW vs MOR table types
  - Upserts
  - Incremental processing
- Delta Lake
  - Delta log
  - ACID transactions
  - Unified batch + streaming

---

### Section 18.3: Query Optimization

#### Topic 18.3.1: Athena Query Performance
- Partition pruning
- Predicate pushdown
- Columnar format benefits
- Compression impact on scan
- Requester-pays model
- Query result caching
- Workgroup configuration

#### Topic 18.3.2: Glue Catalog Best Practices
- Crawler scheduling
- Schema evolution handling
- Table-level vs column-level statistics
- Partition management

---

## Module 19: Advanced S3 Features

### Section 19.1: S3 Select

#### Topic 19.1.1: S3 Select Architecture
- Server-side filtering
- SQL expression evaluation at S3
- Supported formats (CSV, JSON, Parquet)
- Supported compression (GZIP, BZIP2 for CSV/JSON)
- ScanRange parameter
- Cost model (per GB scanned + returned)
- Comparison to Athena

---

### Section 19.2: Multi-Region Access Points

#### Topic 19.2.1: Architecture
- Global S3 ARN
- AWS Global Accelerator backbone
- Bucket set per region
- Routing policy (active-active, active-passive)
- Failover configuration

#### Topic 19.2.2: Use Cases
- Active-active multi-region apps
- DR with automatic failover
- Global closest-region reads
- Replication prerequisite

---

### Section 19.3: S3 Express One Zone (Deep Dive)

#### Topic 19.3.1: Technical Characteristics
- Directory bucket type
- Single Availability Zone
- Consistent single-digit ms latency
- 10 directory buckets per AZ per account
- Unique naming format (--azid--x-s3)
- CreateSession API for temporary credentials
- Not all S3 features supported

#### Topic 19.3.2: Supported Operations
- PutObject, GetObject, DeleteObject
- CreateMultipartUpload, UploadPart, CompleteMultipartUpload
- HeadObject, ListObjectsV2
- CopyObject (within Express One Zone)

#### Topic 19.3.3: Use Cases
- ML training data loading
- High-frequency financial processing
- Interactive analytics
- Game leaderboard storage
- Real-time media processing

---

### Section 19.4: S3 Vectors (New Feature)

#### Topic 19.4.1: S3 Vectors Architecture
- Managed vector storage
- Bucket type for vectors
- Vector index configuration
- Dimension specification
- Distance metric (cosine, Euclidean, dot product)
- PutVectors API
- QueryVectors API (ANN search)
- DeleteVectors API
- GetVectors API
- ListVectors API

#### Topic 19.4.2: S3 Vectors Use Cases
- Semantic search
- RAG (Retrieval-Augmented Generation) pipeline
- Recommendation systems
- Image similarity search
- Document similarity
- ML embedding storage

#### Topic 19.4.3: S3 Vectors Pricing and Limits
- Per vector stored
- Per query pricing
- Vector dimension limits
- Vectors per index limits

---

### Section 19.5: Conditional Writes

#### Topic 19.5.1: Conditional Write Mechanics
- If-None-Match: * condition
- Atomic create-if-not-exists
- PUT with condition
- Use cases (distributed coordination, idempotent writes)
- Comparison to DynamoDB conditional expressions

---

## Module 20: Disaster Recovery

### Section 20.1: Recovery Objectives

#### Topic 20.1.1: RTO and RPO for S3
- RPO definition in S3 context
- RTO definition in S3 context
- RTC (Replication Time Control) for 15-min RPO
- Point-in-time versioning for RPO
- DR tiers (warm, cold, hot)

---

### Section 20.2: Backup Strategies

#### Topic 20.2.1: Versioning as Backup
- Version retention
- Noncurrent version lifecycle
- Delete marker management
- Restore workflow for versioned objects

#### Topic 20.2.2: Cross-Region Replication as DR
- Passive failover pattern
- Active-passive with Multi-Region Access Point
- Cutover workflow
- DNS failover

#### Topic 20.2.3: Cross-Account Backup
- Separate account for backup isolation
- Malicious deletion protection
- SCP preventing backup account from delete

#### Topic 20.2.4: AWS Backup for S3
- Policy-driven backup
- Backup vault isolation
- Cross-region backup copy
- Compliance and audit trail

---

### Section 20.3: Failure Scenarios

#### Topic 20.3.1: Regional Failure
- Multi-region replication readiness
- Multi-Region Access Point failover
- DNS failover procedure
- Replication lag at failure time (RPO gap)

#### Topic 20.3.2: Accidental Deletion
- Versioning recovery
- Delete marker removal
- Object Lock protection
- Batch Operations recovery

#### Topic 20.3.3: Ransomware Resilience
- Object Lock for ransomware protection
- Versioning + lifecycle for restore capability
- Separate backup account
- IAM privilege minimization

---

## Module 21: Architecture Patterns

### Section 21.1: Common Architecture Patterns

#### Topic 21.1.1: Static Website Hosting
- Bucket policy for public read
- Index document configuration
- Error document configuration
- Redirect rules
- Routing rules
- Custom domain (Route 53 + S3 + CloudFront)
- HTTPS via CloudFront
- SPA hosting pattern

#### Topic 21.1.2: Media Storage and Streaming
- Origin for CloudFront video distribution
- HLS/DASH segment storage
- Presigned URL media delivery
- Large file multipart upload
- Transcoding pipeline (MediaConvert → S3)
- Signed URL TTL for media assets

#### Topic 21.1.3: Log Aggregation
- Multi-account centralized logging
- CloudTrail → S3 aggregation
- ALB logs → S3
- CloudFront logs → S3
- Athena analysis layer
- Lifecycle policy for log retention

#### Topic 21.1.4: Backup Repository
- Lifecycle tiering (Standard → Glacier → Deep Archive)
- Object Lock for compliance
- Cross-region replication for DR
- AWS Backup integration
- Restore automation with Lambda

#### Topic 21.1.5: Data Lake Architecture
- Medallion architecture (Bronze/Silver/Gold)
- Raw → Curated → Consumption tiers
- Glue + Athena + Lake Formation stack
- Event-driven processing (EventBridge → Lambda/Glue)
- Schema registry integration

#### Topic 21.1.6: Machine Learning Datasets
- Feature store patterns
- Training/validation/test split organization
- Dataset versioning pattern
- SageMaker integration
- S3 Express One Zone for training
- Data labeling (Ground Truth) integration

#### Topic 21.1.7: Event-Driven Architecture
- S3 event → EventBridge → Step Functions
- S3 event → Lambda → downstream processing
- Fan-out pattern (SNS → multiple queues/functions)
- Dead letter queue for failed events
- Exactly-once processing pattern

#### Topic 21.1.8: Multi-Account Architecture
- Hub-and-spoke replication
- Organization-wide centralized S3 governance
- Cross-account Access Points
- Cross-account replication IAM
- AWS Organizations SCP for S3 guardrails
- Access Grants for cross-account data sharing

#### Topic 21.1.9: SaaS Architecture
- Per-tenant prefix isolation
- Per-tenant bucket isolation
- Access Points for tenant routing
- S3 Access Grants for tenant-level credentials
- Data tiering per tenant SLA
- Cost allocation per tenant

#### Topic 21.1.10: Global Application Storage
- Multi-Region Access Point
- Active-active multi-region replication
- Conflict resolution strategy
- Closest-region read optimization
- Global namespace with regional data placement

---

## Module 22: Operations

### Section 22.1: Day-2 Operations

#### Topic 22.1.1: Capacity Planning
- Storage growth projection
- Request rate growth projection
- Cost forecasting (S3 pricing model)
- Storage class review cadence
- Lifecycle policy review cadence

#### Topic 22.1.2: Runbooks
- Bucket provisioning runbook
- Encryption configuration runbook
- Replication setup runbook
- Access Point provisioning runbook
- DR test runbook
- Incident response runbook

#### Topic 22.1.3: Incident Response
- S3 data exposure incident (public bucket)
- Accidental deletion incident
- Performance degradation incident
- Replication failure incident
- KMS key deletion incident

#### Topic 22.1.4: Security Review
- Public access audit (AWS Config)
- Encryption compliance audit
- IAM policy least privilege review
- Bucket policy review
- CloudTrail data event review
- Access patterns anomaly detection

#### Topic 22.1.5: Governance Reviews
- Tagging compliance review
- Lifecycle policy effectiveness review
- Object Lock compliance audit
- Storage class distribution review
- Cost optimization review

---

## Module 23: Troubleshooting

### Section 23.1: Permission Errors

#### Topic 23.1.1: 403 Access Denied Debugging
- IAM policy evaluation flow
- Explicit deny identification
- Missing IAM permissions
- Bucket policy conflict
- BPA blocking access
- VPC endpoint policy conflict
- SCP blocking access
- KMS key policy blocking
- Cross-account permission gaps
- Access Point ARN vs bucket ARN mismatch

#### Topic 23.1.2: Tools for Permission Debugging
- IAM Policy Simulator
- AWS CloudTrail (s3:* events)
- S3 Server Access Logs
- IAM Access Analyzer

---

### Section 23.2: KMS Errors

#### Topic 23.2.1: KMS-Related S3 Errors
- KMS key disabled error
- KMS key deleted error
- KMS key policy insufficient permissions
- Cross-account KMS key access
- KMS throttling (429) causing S3 failures
- Bucket Key misconfiguration

---

### Section 23.3: Replication Failures

#### Topic 23.3.1: Replication Troubleshooting
- Replication status field (PENDING, COMPLETED, FAILED)
- GetObjectAttributes for replication status
- IAM role permission errors
- Destination bucket policy missing
- KMS replication permission errors
- Destination bucket versioning disabled
- Object older than replication rule (not retroactively replicated)
- Lifecycle-deleted object before replication

---

### Section 23.4: Lifecycle Rule Issues

#### Topic 23.4.1: Lifecycle Troubleshooting
- Object not transitioning (minimum duration)
- Object not expiring (versioning interaction)
- Delete markers not cleaned up (configuration)
- Incomplete multipart not aborting
- Rule filter not matching (tag case sensitivity)
- Rule conflict (multiple rules)

---

### Section 23.5: Networking and DNS

#### Topic 23.5.1: DNS Resolution Issues
- Path-style URL deprecation
- VPC DNS resolution for interface endpoints
- Split-horizon DNS configuration
- Private hosted zone for S3 endpoint
- DNS propagation delays

#### Topic 23.5.2: VPC Connectivity Issues
- Missing route table entry (gateway endpoint)
- Security group blocking interface endpoint
- NACL blocking interface endpoint
- Endpoint policy too restrictive

---

### Section 23.6: Performance Issues

#### Topic 23.6.1: Throughput Throttling (503)
- Hot prefix identification
- Prefix distribution strategy
- Exponential backoff tuning
- SDK adaptive retry mode

#### Topic 23.6.2: High Latency
- Region proximity analysis
- Object size optimization
- Transfer Acceleration evaluation
- CloudFront caching evaluation
- Multipart download evaluation

---

### Section 23.7: Multipart Upload Issues

#### Topic 23.7.1: Multipart Debugging
- ListMultipartUploads API
- Identifying stale incomplete uploads
- Storage cost from incomplete parts
- Abort incomplete multipart lifecycle rule
- Part number gap detection
- ETag mismatch on Complete

---

### Section 23.8: CloudFront + S3 Issues

#### Topic 23.8.1: CloudFront Origin Issues
- OAC permissions error (403)
- OAI legacy misconfiguration
- Signed URL expiration error
- Cache-Control header misconfiguration
- Geo-restriction blocking
- CORS error (CloudFront does not forward Origin header by default)

---

## Module 24: SDK and API Mastery

### Section 24.1: REST API

#### Topic 24.1.1: S3 REST API Fundamentals
- Request structure
- Authentication (Signature V4)
- Signature V4 signing process
- Virtual-hosted-style vs path-style
- Response structure
- Error response format
- Common HTTP status codes (200, 206, 304, 403, 404, 409, 503)

#### Topic 24.1.2: Key REST Operations
- GET / (ListBuckets)
- PUT / (CreateBucket)
- DELETE / (DeleteBucket)
- PUT /bucket?policy
- GET /bucket?policy
- PUT /object
- GET /object
- HEAD /object
- DELETE /object
- GET /bucket?list-type=2 (ListObjectsV2)
- POST /object?uploads (CreateMultipartUpload)
- PUT /object?partNumber=N&uploadId=X
- POST /object?uploadId=X (CompleteMultipartUpload)
- DELETE /object?uploadId=X (AbortMultipartUpload)

---

### Section 24.2: AWS CLI

#### Topic 24.2.1: AWS CLI S3 Commands
- aws s3 cp
- aws s3 mv
- aws s3 sync
- aws s3 rm
- aws s3 ls
- aws s3 mb
- aws s3 rb
- aws s3 presign
- --recursive
- --exclude / --include patterns
- --sse, --sse-kms-key-id
- --storage-class
- --acl
- --metadata
- --dryrun

#### Topic 24.2.2: AWS CLI S3API Commands
- aws s3api put-object
- aws s3api get-object
- aws s3api delete-object
- aws s3api list-objects-v2
- aws s3api create-bucket
- aws s3api put-bucket-policy
- aws s3api get-bucket-policy
- aws s3api put-bucket-versioning
- aws s3api put-bucket-lifecycle-configuration
- aws s3api create-multipart-upload
- aws s3api upload-part
- aws s3api complete-multipart-upload
- aws s3api put-object-lock-configuration
- aws s3api put-object-retention

---

### Section 24.3: SDK Concepts

#### Topic 24.3.1: SDK Architecture (Python Boto3)
- Client vs Resource API
- Session configuration
- Credential chain
- Region configuration
- S3 Client: low-level API
- S3 Resource: higher-level abstraction
- Transfer configuration (multipart threshold, concurrency)
- Paginator usage (list_objects_v2)
- Waiter usage (object_exists, bucket_exists)

#### Topic 24.3.2: SDK Architecture (JavaScript/TypeScript)
- @aws-sdk/client-s3
- @aws-sdk/lib-storage (managed multipart)
- @aws-sdk/s3-request-presigner
- Credential provider chain
- Middleware stack
- HTTP configuration

#### Topic 24.3.3: SDK Architecture (Java)
- S3Client (v2 SDK)
- S3TransferManager
- Credential providers
- Async client
- CRT-based client (performance)

---

### Section 24.4: Error Handling and Retry

#### Topic 24.4.1: S3 Error Codes
- NoSuchBucket
- NoSuchKey
- NoSuchUpload
- AccessDenied
- AllAccessDisabled
- BucketAlreadyExists
- BucketNotEmpty
- EntityTooSmall / EntityTooLarge
- InvalidPart
- InvalidPartOrder
- KeyTooLongError
- MalformedXML
- RequestTimeout
- SlowDown (503)
- ServiceUnavailable (503)
- BucketAlreadyOwnedByYou

#### Topic 24.4.2: Retry Strategies
- Exponential backoff formula
- Jitter (full jitter, equal jitter)
- Retry-able vs non-retry-able errors
- SDK retry modes (legacy, standard, adaptive)
- Max retry configuration
- Total request timeout vs attempt timeout

---

### Section 24.5: Pagination

#### Topic 24.5.1: Listing Pagination
- ListObjectsV2 pagination
- ContinuationToken
- MaxKeys (page size)
- IsTruncated indicator
- SDK Paginator abstraction
- Performance considerations for large buckets
- Prefix-based partition scanning

---

### Section 24.6: Presigned URLs

#### Topic 24.6.1: Presigned URL Generation
- Signature V4 presigning
- Expiration (max 7 days with IAM role; 12 hours recommended)
- Supported operations (GET, PUT, DELETE)
- IAM permission requirement at generation time
- Presigned URL sharing
- Presigned URL revocation limitation

#### Topic 24.6.2: Presigned POST Policy
- Policy document structure
- Conditions array
- Expiration
- Supported condition types (eq, starts-with, content-length-range)
- Browser upload flow
- Redirect on success configuration

---

## Module 25: Interview Preparation

### Section 25.1: Foundational Interview Questions

#### Topic 25.1.1: Core Concept Questions
- Explain S3 durability and how it is achieved
- What is the difference between S3 Standard and S3 Standard-IA
- How does S3 consistency work and what changed in December 2020
- What is the difference between a bucket policy and an IAM policy
- Explain the S3 shared responsibility model
- What is the maximum object size in S3 and how do you upload it
- What is the difference between versioning enabled and suspended
- Explain how delete markers work
- What is S3 Object Lock and what are the two retention modes
- How does SSE-KMS differ from SSE-S3

---

### Section 25.2: Senior-Level Architecture Questions

#### Topic 25.2.1: Architecture Design Questions
- Design a multi-account S3 logging architecture for 200 AWS accounts
- How would you design S3-based storage for a multi-tenant SaaS platform
- Design an S3 data lake with fine-grained access control per business unit
- How do you ensure RPO < 15 minutes for an S3-backed application
- Design an S3 encryption strategy for a financial services company
- How would you migrate 50 PB from on-premises NAS to S3 with minimum downtime
- Design an S3 architecture for PCI-DSS compliance
- How do you achieve per-user S3 access with 100,000 users without one IAM role per user
- Design a globally distributed S3 architecture for lowest-latency reads from 5 continents
- How do you protect an S3 data lake from a ransomware attack

---

### Section 25.3: System Design Questions

#### Topic 25.3.1: S3-Centric System Design
- Design YouTube video storage backend using AWS services
- Design a global content distribution system backed by S3
- Design a real-time data pipeline from IoT devices to S3 analytics
- Design a disaster recovery system with S3 as the backbone
- Design a document management system with versioning, audit trail, and fine-grained permissions

---

### Section 25.4: Troubleshooting Scenario Questions

#### Topic 25.4.1: Scenario-Based Questions
- Users report 403 errors accessing objects they should have access to—diagnose
- S3 replication is consistently 45 minutes behind—diagnose
- Costs spiked 300% last month with no new workloads—diagnose
- Lambda is failing to process S3 events—diagnose
- A bucket with Object Lock is preventing deletion of a version even with admin credentials—explain
- Multipart uploads are accumulating 10 TB of storage cost but no completed objects—diagnose
- CloudFront is returning 403 for private S3 content—diagnose
- An Athena query on S3 data is scanning 10 TB for a 10-minute window—optimize

---

## Module 26: Capstone Projects

### Section 26.1: Beginner Project

#### Topic 26.1.1: Secure Static Website with Versioning
- Create an S3 bucket with static website hosting
- Enable versioning
- Configure Block Public Access
- Create CloudFront distribution with OAC
- Apply HTTPS enforcement
- Configure lifecycle policy for old versions
- Deploy via AWS CLI

---

### Section 26.2: Intermediate Project

#### Topic 26.2.1: Event-Driven File Processing Pipeline
- S3 bucket with event notifications to EventBridge
- Lambda function triggered on object upload
- Lambda processes file, writes output to destination bucket
- SSE-KMS encryption on both buckets
- Dead letter queue for failed Lambda invocations
- CloudWatch alarm on Lambda error rate
- CloudTrail data events enabled
- IAM least-privilege roles
- Terraform or CDK IaC

---

### Section 26.3: Advanced Project

#### Topic 26.3.1: Multi-Tier Data Lake with Fine-Grained Access
- Multi-bucket medallion architecture (raw, curated, consumption)
- Glue Crawlers and Data Catalog
- Lake Formation column and row-level security
- Athena query layer with workgroup isolation
- S3 Inventory → Athena cost analysis layer
- CRR to DR region with RTC
- Object Lock on compliance tier
- Storage Lens dashboard
- Full IaC (Terraform)

---

### Section 26.4: Staff Engineer Level Project

#### Topic 26.4.1: Global Multi-Account S3 Governance Platform
- AWS Organizations with SCPs for S3 guardrails
- Centralized CloudTrail logging to security account S3
- Organization-level S3 Storage Lens
- S3 Access Grants for cross-account data sharing
- Multi-Region Access Points for global application
- Custom compliance auditing with Config Rules + Lambda
- Automated remediation for non-compliant buckets
- Cost allocation and chargeback report pipeline
- Full CI/CD pipeline for IaC deployment

---

### Section 26.5: Enterprise Architect Level Project

#### Topic 26.5.1: Petabyte-Scale Data Platform with Full Governance
- Multi-region active-active data lake
- S3 Tables (Iceberg) for transactional data layer
- S3 Vectors for semantic search on document corpus
- Object Lambda for runtime PII masking
- Lake Formation for enterprise-wide data governance
- Replication with RTC across 3 regions
- Full audit trail (CloudTrail + S3 Access Logs + Inventory)
- WORM compliance for 7-year retention tier
- DataSync integration for on-premises hybrid ingestion
- AWS Backup for recovery SLA compliance
- Multi-account architecture (landing zone) with full IaC
- Custom FinOps dashboard integrating Storage Lens + Cost Explorer
- Disaster recovery runbook with RTO/RPO validation testing