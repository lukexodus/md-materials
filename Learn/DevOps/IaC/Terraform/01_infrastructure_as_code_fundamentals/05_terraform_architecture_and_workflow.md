## Terraform Architecture and Workflow


**Core Components:**

1. **Configuration Files:** Define desired infrastructure state using HCL
2. **Providers:** Plugins that interact with APIs (AWS, Azure, etc.)
3. **State File:** Tracks current infrastructure state and metadata
4. **Backend:** Stores state file (local, remote, or cloud storage)
5. **Modules:** Reusable configuration packages

**Terraform Workflow:**

1. **Write:** Create configuration files defining infrastructure
2. **Plan:** Run `terraform plan` to preview changes
3. **Apply:** Execute `terraform apply` to create/modify infrastructure
4. **Manage:** Use `terraform destroy`, `terraform import`, etc. for lifecycle management

**Key Commands:**
- `terraform init`: Initialize working directory and download providers
- `terraform plan`: Create execution plan showing proposed changes
- `terraform apply`: Execute planned changes
- `terraform destroy`: Remove all managed infrastructure
- `terraform validate`: Check configuration syntax
- `terraform fmt`: Format configuration files consistently

**State Management:**
Terraform maintains a state file that maps configuration to real-world resources. This state file is crucial for determining what changes need to be made during subsequent runs. For team environments, remote state storage (like AWS S3 with DynamoDB locking) prevents conflicts and ensures consistency.

The declarative nature means you describe what you want, not how to achieve it. Terraform figures out the necessary steps, handles dependencies, and can safely update infrastructure by comparing desired state with current state.

---

