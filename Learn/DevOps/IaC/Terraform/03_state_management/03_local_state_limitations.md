## Local State Limitations


Local state files (stored as `terraform.tfstate` in your working directory) have significant limitations:

- **No collaboration**: Multiple team members cannot safely work with the same infrastructure
- **No locking**: Concurrent operations can corrupt the state file
- **Security risks**: Sensitive data is stored in plain text locally
- **No versioning**: Limited ability to track changes or recover from corruption
- **Backup responsibility**: Manual backup management required

