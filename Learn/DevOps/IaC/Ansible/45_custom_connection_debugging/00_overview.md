## Overview

def debug_connection(self, host, user, ssh_args):
    """Debug SSH connection establishment"""
    debug_info = {
        'host': host,
        'user': user,
        'ssh_args': ssh_args,
        'ssh_executable': self.ssh_executable,
        'connection_timeout': self.connection_timeout
    }
    
    self.logger.debug(f"SSH connection attempt: {json.dumps(debug_info)}")
    
    # Test basic connectivity
    try:
        test_cmd = [self.ssh_executable, '-o', 'BatchMode=yes', f"{user}@{host}", 'echo', 'connection_test']
        result = subprocess.run(test_cmd, capture_output=True, timeout=self.connection_timeout)
        
        if result.returncode == 0:
            self.logger.info(f"SSH connectivity confirmed for {host}")
        else:
            self.logger.error(f"SSH connection failed for {host}: {result.stderr.decode()}")
            
    except subprocess.TimeoutExpired:
        self.logger.error(f"SSH connection timeout for {host}")
    except Exception as e:
        self.logger.error(f"SSH connection error for {host}: {str(e)}")
```

**Variable and Template Debugging:**

**Variable Resolution Analysis** identifies scoping and precedence issues:

```yaml
---
- name: Debug variable resolution
  debug:
    msg: |
      Variable resolution analysis:
      hostvars: {{ hostvars[inventory_hostname] | to_nice_json }}
      group_vars: {{ group_names | map('extract', hostvars[inventory_hostname]) | list }}
      ansible_facts: {{ ansible_facts | to_nice_json }}
      play_vars: {{ vars | to_nice_json }}

- name: Template debugging with variable context
  template:
    src: debug_template.j2
    dest: /tmp/debug_output.txt
  vars:
    debug_mode: true
    template_context:
      current_user: "{{ ansible_user }}"
      system_info: "{{ ansible_system }}"
      custom_vars: "{{ custom_variables | default({}) }}"
```

**Template Debugging:**

```jinja2
{# debug_template.j2 #}
{% if debug_mode | default(false) %}
=== TEMPLATE DEBUG INFORMATION ===
Template Variables:
{% for key, value in template_context.items() %}
{{ key }}: {{ value | to_nice_json }}
{% endfor %}

Ansible Facts Summary:
- OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
- Architecture: {{ ansible_architecture }}
- Memory: {{ ansible_memtotal_mb }}MB
- CPU: {{ ansible_processor_count }} cores

Variable Precedence Test:
- test_var from different sources: {{ test_var | default('undefined') }}
- Override hierarchy demonstration: {{ override_test | default('no override') }}

Template Context:
{{ template_context | to_nice_yaml }}
=== END DEBUG INFORMATION ===
{% endif %}

{# Regular template content #}
Configuration for {{ inventory_hostname }}:
{% for item in configuration_items %}
{{ item.name }}: {{ item.value }}
{% endfor %}
```

**Performance Profiling:**

**Execution Time Analysis** identifies bottlenecks:

```python
import cProfile
import pstats
import functools

def profile_execution(func):
    """Decorator for profiling function execution"""
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        if os.environ.get('ANSIBLE_PROFILE_EXECUTION'):
            pr = cProfile.Profile()
            pr.enable()
            
            try:
                result = func(*args, **kwargs)
            finally:
                pr.disable()
                
                # Save profile data
                profile_file = f"/tmp/profile_{func.__name__}_{int(time.time())}.prof"
                pr.dump_stats(profile_file)
                
                # Generate readable report
                stats = pstats.Stats(pr)
                stats.sort_stats('cumulative')
                stats.print_stats(20)  # Top 20 functions
                
            return result
        else:
            return func(*args, **kwargs)
    
    return wrapper

@profile_execution
def main():
    """Main module function with profiling"""
    module = AnsibleModule(argument_spec=module_args)
    # Module logic here
```

**Error Analysis and Recovery:**

**Systematic Error Diagnosis** provides structured troubleshooting:

```python
class ErrorAnalyzer:
    """Comprehensive error analysis and recovery suggestions"""
    
    ERROR_PATTERNS = {
        'permission_denied': {
            'patterns': ['permission denied', 'access denied', 'operation not permitted'],
            'suggestions': [
                'Check file/directory permissions',
                'Verify user has required privileges',
                'Consider using become/sudo',
                'Examine SELinux/AppArmor policies'
            ],
            'commands': [
                'ls -la {path}',
                'id',
                'sudo -l',
                'getenforce'
            ]
        },
        'network_connectivity': {
            'patterns': ['connection refused', 'timeout', 'host unreachable', 'name resolution failed'],
            'suggestions': [
                'Verify network connectivity',
                'Check firewall rules',
                'Confirm DNS resolution',
                'Validate SSH configuration'
            ],
            'commands': [
                'ping {host}',
                'telnet {host} {port}',
                'nslookup {host}',
                'ssh -vvv {user}@{host}'
            ]
        },
        'resource_exhaustion': {
            'patterns': ['no space left', 'out of memory', 'resource temporarily unavailable'],
            'suggestions': [
                'Check disk space availability',
                'Monitor memory usage',
                'Review process limits',
                'Clean temporary files'
            ],
            'commands': [
                'df -h',
                'free -h',
                'ulimit -a',
                'du -sh /tmp'
            ]
        }
    }
    
    @classmethod
    def analyze_error(cls, error_message, context=None):
        """Analyze error and provide recovery suggestions"""
        error_message_lower = error_message.lower()
        context = context or {}
        
        analysis = {
            'error_message': error_message,
            'context': context,
            'matches': [],
            'suggestions': [],
            'diagnostic_commands': []
        }
        
        for error_type, error_info in cls.ERROR_PATTERNS.items():
            if any(pattern in error_message_lower for pattern in error_info['patterns']):
                analysis['matches'].append(error_type)
                analysis['suggestions'].extend(error_info['suggestions'])
                
                # Format diagnostic commands with context
                for cmd_template in error_info['commands']:
                    try:
                        formatted_cmd = cmd_template.format(**context)
                        analysis['diagnostic_commands'].append(formatted_cmd)
                    except KeyError:
                        analysis['diagnostic_commands'].append(cmd_template)
        
        return analysis
    
    @classmethod
    def format_error_report(cls, error_analysis):
        """Format error analysis as readable report"""
        report = [
            "=== ERROR ANALYSIS REPORT ===",
            f"Error: {error_analysis['error_message']}",
            ""
        ]
        
        if error_analysis['matches']:
            report.extend([
                "Identified Error Types:",
                *[f"  - {match}" for match in error_analysis['matches']],
                ""
            ])
        
        if error_analysis['suggestions']:
            report.extend([
                "Suggested Actions:",
                *[f"  - {suggestion
