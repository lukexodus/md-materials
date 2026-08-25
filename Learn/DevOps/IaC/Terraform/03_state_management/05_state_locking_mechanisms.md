## State Locking Mechanisms


State locking prevents concurrent modifications that could corrupt the state file:

- **DynamoDB locking** (AWS S3 backend): Uses a DynamoDB table to store lock information
- **Blob leases** (Azure backend): Uses Azure Storage blob leases for locking
- **Native locking** (GCS backend): Built-in locking mechanism
- **Consul backend**: Distributed locking through Consul's key-value store

When a lock is acquired, other Terraform operations wait or fail depending on configuration.

