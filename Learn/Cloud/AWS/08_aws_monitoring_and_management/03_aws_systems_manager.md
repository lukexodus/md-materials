## AWS Systems Manager


Systems Manager provides unified interface for managing AWS and on-premises infrastructure at scale, offering operational insights and automation capabilities.

### Core Services

**Session Manager:** Browser-based shell access to EC2 instances without SSH keys or bastion hosts, with session logging and auditing capabilities.

**Parameter Store:** Centralized storage for configuration data, secrets, and application parameters with encryption and versioning support.

**Parameter Types:**

- String: Plain text values
- StringList: Comma-separated values
- SecureString: Encrypted parameters using KMS

**Systems Manager Patch Manager:** Automated patching for operating systems and applications across EC2 instances and on-premises servers.

**Patch Groups:** Logical groupings of instances for coordinated patching **Maintenance Windows:** Scheduled time periods for automated maintenance tasks **Patch Baselines:** Rules defining which patches to approve automatically

**Run Command:** Execute commands remotely across multiple instances simultaneously without SSH access.

**Automation Documents:** Predefined workflows for common administrative tasks like AMI creation, instance patching, and application deployment.

### Advanced Features

**State Manager:** Maintain consistent configuration across instances through association documents **Inventory:** Collect metadata about instances, installed software, and system configurations **Compliance:** Track system compliance against configuration baselines **OpsCenter:** Centralized location for investigating and resolving operational issues

