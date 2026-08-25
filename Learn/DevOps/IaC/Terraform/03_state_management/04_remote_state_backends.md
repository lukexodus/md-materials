## Remote State Backends


Remote backends store state files in shared, centralized locations:

**AWS S3 Backend**: Stores state in S3 buckets with optional DynamoDB for locking

- Supports versioning and encryption
- Integrates with AWS IAM for access control
- Requires bucket and DynamoDB table configuration

**Azure Storage Backend**: Uses Azure Storage Accounts for state storage

- Supports blob versioning and access tiers
- Integrates with Azure AD for authentication
- Can use lease-based locking

**Google Cloud Storage (GCS) Backend**: Stores state in GCS buckets

- Supports object versioning and lifecycle management
- Integrates with Google Cloud IAM
- Provides built-in encryption

