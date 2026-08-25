## Dynamic Inventory Sources


Dynamic inventory generates host information programmatically from external sources such as cloud providers, databases, or configuration management systems. This approach maintains current infrastructure state without manual inventory updates.

**Cloud Provider Integration:** Dynamic inventory scripts query cloud APIs to retrieve instance information, automatically populating groups based on instance metadata, tags, or other attributes.

**Key Points:**

- Scripts return JSON-formatted inventory data
- Groups and variables populate automatically from source systems
- Caching mechanisms improve performance for large infrastructures
- Multiple dynamic sources can combine through inventory plugins

**Example Script Output:**

```json
{
  "webservers": {
    "hosts": ["web1.example.com", "web2.example.com"],
    "vars": {
      "http_port": 80,
      "environment": "production"
    }
  },
  "databases": {
    "hosts": ["db1.example.com"],
    "vars": {
      "mysql_port": 3306
    }
  },
  "_meta": {
    "hostvars": {
      "web1.example.com": {
        "ansible_host": "10.0.1.10",
        "instance_type": "t3.medium"
      },
      "web2.example.com": {
        "ansible_host": "10.0.1.11",
        "instance_type": "t3.large"
      }
    }
  }
}
```

**Custom Dynamic Inventory Script:**

```python
#!/usr/bin/env python3
import json
import sys

def get_inventory():
    inventory = {
        'webservers': {
            'hosts': [],
            'vars': {'http_port': 80}
        },
        '_meta': {
            'hostvars': {}
        }
    }
    
    # Query external source (database, API, etc.)
    # Populate inventory structure
    
    return inventory

if __name__ == '__main__':
    if len(sys.argv) == 2 and sys.argv[1] == '--list':
        print(json.dumps(get_inventory()))
    elif len(sys.argv) == 3 and sys.argv[1] == '--host':
        print(json.dumps({}))
```

