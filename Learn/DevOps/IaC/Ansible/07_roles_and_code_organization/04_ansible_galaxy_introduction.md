## Ansible Galaxy Introduction


Ansible Galaxy serves as the central repository and distribution platform for Ansible roles, providing a community-driven ecosystem of reusable automation content. Galaxy enables role discovery, installation, and sharing across the global Ansible community.

**Galaxy Platform Components:**

**Galaxy Hub** (galaxy.ansible.com) provides the web interface for browsing, searching, and discovering roles. The platform includes role ratings, download statistics, documentation, and metadata that assist in role selection and evaluation.

**Galaxy CLI** (`ansible-galaxy` command) enables command-line interaction with Galaxy services, including role installation, creation, publishing, and management operations.

**Collections** represent the evolution of Galaxy content distribution, packaging roles, modules, plugins, and documentation into cohesive, versioned bundles that simplify content management and distribution.

**Role Discovery and Search:**

Galaxy provides multiple mechanisms for role discovery:

**Web Interface Search** enables browsing by categories, platforms, tags, and popularity metrics. Advanced search filters help narrow results based on specific requirements like supported operating systems or role functionality.

**Command Line Search:**
```bash
ansible-galaxy search mysql
ansible-galaxy search --platforms EL --author geerlingguy nginx
ansible-galaxy search --galaxy-tags database
```

**Role Information:**
```bash
ansible-galaxy info geerlingguy.mysql
ansible-galaxy info --offline installed_role_name
```

**Role Installation:**

**Installing from Galaxy:**
```bash
ansible-galaxy install geerlingguy.mysql
ansible-galaxy install -p ./roles geerlingguy.nginx
ansible-galaxy install --force geerlingguy.apache  # Overwrite existing
```

**Installing Specific Versions:**
```bash
ansible-galaxy install geerlingguy.mysql,2.3.0
ansible-galaxy install 'geerlingguy.mysql:<2.0.0'  # Version constraints
```

**Installing from Git Repositories:**
```bash
ansible-galaxy install git+https://github.com/user/role.git
ansible-galaxy install git+https://github.com/user/role.git,v1.2.3
```

**Requirements File Management:**

Requirements files (`requirements.yml`) specify role dependencies and versions for reproducible installations:

```yaml
---
roles:
  - name: geerlingguy.mysql
    version: 2.3.0
  
  - name: common
    src: https://github.com/company/ansible-common.git
    version: main
  
  - name: custom_role
    src: https://galaxy.ansible.com/namespace/role_name
    version: ">=1.0.0,<2.0.0"

collections:
  - name: community.general
    version: ">=1.0.0"
  
  - name: ansible.posix
```

**Installing from Requirements:**
```bash
ansible-galaxy install -r requirements.yml
ansible-galaxy install -r requirements.yml --force
```

**Role Management:**

**List Installed Roles:**
```bash
ansible-galaxy list
ansible-galaxy list --show-version
```

**Remove Roles:**
```bash
ansible-galaxy remove geerlingguy.mysql
ansible-galaxy remove --all  # Remove all installed roles
```

**Role Publishing:**

Publishing roles to Galaxy requires GitHub integration and proper role structure:

**Prerequisites:**
- GitHub account with role repository
- Proper role directory structure
- `meta/main.yml` with required metadata
- Galaxy account linked to GitHub

**Publishing Process:**
1. Import role repository on Galaxy website
2. Configure webhook for automatic updates
3. Tag releases in GitHub for version management

**Galaxy Collections:**

Collections represent the modern approach to content distribution, superseding individual role distribution:

**Collection Installation:**
```bash
ansible-galaxy collection install community.general
ansible-galaxy collection install -r requirements.yml
```

**Collection Structure:**
```
collection_namespace.collection_name/
├── docs/
├── galaxy.yml
├── plugins/
│   ├── modules/
│   ├── inventory/
│   └── lookup/
├── roles/
├── playbooks/
└── tests/
```

**Using Collection Content:**
```yaml
---
- hosts: all
  tasks:
    - name: Use collection module
      community.general.timezone:
        name: America/New_York
```

**Galaxy Configuration:**

Galaxy behavior can be customized through configuration files:

**ansible.cfg:**
```ini
[galaxy]
server_list = galaxy, private_galaxy

[galaxy_server.galaxy]
url = https://galaxy.ansible.com/
username = galaxy_username
token = galaxy_api_token

[galaxy_server.private_galaxy]
url = https://private-galaxy.company.com/
username = private_username
token = private_api_token
```

