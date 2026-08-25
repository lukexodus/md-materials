## State File Structure and Contents


The Terraform state file is a JSON document containing several key sections:

- **Version**: The state file format version
- **Serial**: A counter that increments with each state change
- **Lineage**: A unique identifier for the state file's history
- **Resources**: An array of all managed resources with their attributes and metadata
- **Outputs**: Values from output blocks in your configuration
- **Dependencies**: Resource dependency information for proper ordering

Each resource entry includes the resource type, name, provider information, current attributes, and metadata like creation timestamps.

