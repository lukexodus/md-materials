## Overview


def format_bytes(value, format='human'):
    """Convert bytes to human-readable format"""
    try:
        bytes_val = int(value)
    except (ValueError, TypeError):
        return value
    
    if format == 'human':
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if bytes_val < 1024.0:
                return f"{bytes_val:.1f}{unit}"
            bytes_val /= 1024.0
        return f"{bytes_val:.1f}PB"
    
    return value

def extract_domain(email):
    """Extract domain from email address"""
    if '@' in email:
        return email.split('@')[1]
    return ''

def merge_dicts_recursive(dict1, dict2):
    """Recursively merge dictionaries"""
    result = dict1.copy()
    
    for key, value in dict2.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = merge_dicts_recursive(result[key], value)
        else:
            result[key] = value
    
    return result

def validate_ip_address(ip_string):
    """Validate IP address format"""
    import ipaddress
    try:
        ipaddress.ip_address(ip_string)
        return True
    except ValueError:
        return False

class FilterModule(object):
    """Custom filter plugin"""
    
    def filters(self):
        return {
            'format_bytes': format_bytes,
            'extract_domain': extract_domain,
            'merge_recursive': merge_dicts_recursive,
            'is_valid_ip': validate_ip_address,
        }
```

**Filter Plugin Usage:**

```yaml
---
- name: Use custom filters
  debug:
    msg: |
      Disk usage: {{ ansible_mounts[0].size_total | format_bytes }}
      Admin domain: {{ admin_email | extract_domain }}
      Config valid: {{ server_config | merge_recursive(override_config) }}
      IP validation: {{ server_ip | is_valid_ip }}
```

**Lookup Plugin Development:**

Lookup plugins retrieve external data during playbook execution:

```python
