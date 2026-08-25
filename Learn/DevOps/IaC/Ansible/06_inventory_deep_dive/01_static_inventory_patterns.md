## Static Inventory Patterns


Static inventory files define hosts and groups in fixed configuration files using INI or YAML formats. These files provide explicit host definitions with associated variables and group memberships.

**INI Format Structure:**

```ini
# Basic host definitions
web1.example.com
web2.example.com
db1.example.com

# Grouped hosts
[webservers]
web1.example.com
web2.example.com
web3.example.com

[databases]
db1.example.com
db2.example.com

# Nested groups
[production:children]
webservers
databases

# Host variables
[webservers]
web1.example.com http_port=80 maxRequestsPerChild=808
web2.example.com http_port=8080 maxRequestsPerChild=909

# Group variables
[webservers:vars]
ntp_server=ntp.example.com
proxy=proxy.example.com
```

**YAML Format Structure:**

```yaml
all:
  children:
    webservers:
      hosts:
        web1.example.com:
          http_port: 80
          maxRequestsPerChild: 808
        web2.example.com:
          http_port: 8080
          maxRequestsPerChild: 909
      vars:
        ntp_server: ntp.example.com
        proxy: proxy.example.com
    databases:
      hosts:
        db1.example.com:
        db2.example.com:
      vars:
        mysql_port: 3306
    production:
      children:
        webservers:
        databases:
```

**Host Pattern Matching:**

```ini
# Range patterns
web[1:5].example.com
db[a:f].example.com
server[01:50].example.com

# Mixed patterns
[webservers]
web[1:3].prod.example.com
web[1:2].staging.example.com
```

**Connection Parameters:**

```ini
[targets]
host1.example.com ansible_host=192.168.1.10 ansible_port=2222
host2.example.com ansible_host=192.168.1.11 ansible_user=admin
host3.example.com ansible_connection=local
```

