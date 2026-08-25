## Ad-hoc Commands


Ad-hoc commands execute single tasks across multiple hosts without playbooks. They use the format: `ansible <pattern> -m <module> -a "<arguments>"`

### Command Structure and Options

**Basic Syntax:**

```bash
ansible <host-pattern> [options] -m <module_name> -a "<module_arguments>"
```

**Common Options:**

- `-i inventory`: Specify inventory file
- `-u username`: Connect as specific user
- `-b`: Become (use sudo)
- `-K`: Ask for sudo password
- `-f forks`: Set parallelism level
- `--check`: Dry run mode
- `-v`: Verbose output (-vvv for debug)

### Practical Ad-hoc Examples

**System Information:**

```bash
# Check uptime on all servers
ansible all -m command -a "uptime"

# Gather facts from web servers
ansible webservers -m setup

# Check disk space
ansible all -m command -a "df -h"
```

**Package Management:**

```bash
# Install package on Ubuntu/Debian
ansible webservers -m apt -a "name=nginx state=present" -b

# Update all packages on CentOS/RHEL
ansible centos -m yum -a "name=* state=latest" -b

# Remove package
ansible all -m package -a "name=telnet state=absent" -b
```

**Service Management:**

```bash
# Start and enable service
ansible webservers -m service -a "name=nginx state=started enabled=yes" -b

# Restart service
ansible databases -m service -a "name=mysql state=restarted" -b

# Check service status
ansible all -m service -a "name=sshd" --check
```

**File Operations:**

```bash
# Copy file to remote hosts
ansible all -m copy -a "src=/local/file dest=/remote/path mode=0644"

# Create directory
ansible webservers -m file -a "path=/var/www/html state=directory mode=0755" -b

# Remove file
ansible all -m file -a "path=/tmp/oldfile state=absent"

# Set file permissions
ansible all -m file -a "path=/etc/hosts mode=0644 owner=root group=root" -b
```

### Pattern Matching for Host Selection

**Basic Patterns:**

- `all` or `*`: All hosts
- `webservers`: All hosts in webservers group
- `web1.example.com`: Specific host
- `webservers[0]`: First host in group
- `webservers[0:2]`: First three hosts in group

**Advanced Patterns:**

- `webservers:databases`: Union (hosts in either group)
- `webservers:!databases`: Intersection (webservers not in databases)
- `webservers:&production`: Intersection (hosts in both groups)
- `~web.*`: Regular expression matching
- `webservers[0]:webservers[2:]`: Slice notation

