## Inventory Plugins


Inventory plugins provide standardized interfaces for dynamic inventory sources, replacing custom scripts with maintainable, configuration-driven solutions. They integrate directly with Ansible's inventory system.

**Available Plugin Types:**

- Cloud providers (AWS EC2, Azure, GCP, OpenStack)
- Container platforms (Docker, Kubernetes)
- Virtualization (VMware vSphere, VirtualBox)
- Configuration management (Foreman, Cobbler)
- Custom plugins for specialized sources

**Plugin Configuration:**

```yaml
# inventory.aws_ec2.yml
plugin: amazon.aws.aws_ec2
regions:
  - us-east-1
  - us-west-2
keyed_groups:
  - key: tags
    prefix: tag
  - key: instance_type
    prefix: type
  - key: placement.region
    prefix: region
compose:
  ansible_host: public_ip_address
  ec2_state: state.name
filters:
  - tag:Environment: production
```

**Multiple Inventory Sources:**

```bash
# Directory-based inventory
inventory/
├── 01-static.yml
├── 02-aws.aws_ec2.yml
├── 03-azure.azure_rm.yml
└── group_vars/
    └── all.yml
```

**Plugin Development:** [Inference] Custom inventory plugins follow Ansible's plugin architecture, implementing specific methods for host discovery and variable assignment.

```python
from ansible.plugins.inventory import BaseInventoryPlugin

class InventoryModule(BaseInventoryPlugin):
    NAME = 'custom_inventory'
    
    def verify_file(self, path):
        return path.endswith('custom.yml')
    
    def parse(self, inventory, loader, path, cache=True):
        super(InventoryModule, self).parse(inventory, loader, path, cache)
        # Implementation logic
```

