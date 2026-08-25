## Delegation and Local Actions


### Task Delegation Concepts

Delegation executes tasks on different hosts than the current target, enabling centralized operations, load balancer management, and cross-host coordination. Local actions specifically execute tasks on the Ansible control node.

### Basic Delegation Patterns

**Delegate to Specific Host:**

```yaml
- hosts: webservers
  tasks:
    - name: Remove server from load balancer
      uri:
        url: "http://{{ load_balancer_host }}/api/servers/{{ inventory_hostname }}/disable"
        method: POST
      delegate_to: "{{ load_balancer_host }}"
      
    - name: Update application code
      git:
        repo: "{{ app_repo_url }}"
        dest: /opt/webapp
        version: "{{ app_version }}"
      notify: restart webapp
      
    - name: Add server back to load balancer
      uri:
        url: "http://{{ load_balancer_host }}/api/servers/{{ inventory_hostname }}/enable"
        method: POST
      delegate_to: "{{ load_balancer_host }}"
```

**Delegate to Load Balancer Group:**

```yaml
- hosts: webservers
  serial: 1  # One server at a time
  tasks:
    - name: Drain connections from server
      command: |
        curl -X POST "{{ item }}/api/drain/{{ inventory_hostname }}"
      delegate_to: localhost
      loop: "{{ groups['load_balancers'] }}"
      run_once: true
      
    - name: Wait for connection drain
      wait_for:
        timeout: 60
      delegate_to: localhost
      
    - name: Deploy new application version
      unarchive:
        src: "{{ app_package_url }}"
        dest: /opt/webapp
        remote_src: yes
      notify: restart webapp
      
    - name: Health check after deployment
      uri:
        url: "http://{{ inventory_hostname }}:8080/health"
        method: GET
      register: health_check
      retries: 5
      delay: 10
      
    - name: Re-enable server in load balancer
      command: |
        curl -X POST "{{ item }}/api/enable/{{ inventory_hostname }}"
      delegate_to: localhost
      loop: "{{ groups['load_balancers'] }}"
      when: health_check.status == 200
```

### Local Actions and Control Node Operations

**Local File Operations:**

```yaml
- hosts: databases
  tasks:
    - name: Create local backup directory
      file:
        path: "/backup/{{ inventory_hostname }}/{{ ansible_date_time.date }}"
        state: directory
      delegate_to: localhost
      run_once_per_host: true
      
    - name: Export database
      mysql_db:
        name: "{{ db_name }}"
        state: dump
        target: "/tmp/{{ db_name }}-export.sql"
        
    - name: Fetch database backup to control node
      fetch:
        src: "/tmp/{{ db_name }}-export.sql"
        dest: "/backup/{{ inventory_hostname }}/{{ ansible_date_time.date }}/"
        flat: yes
        
    - name: Compress backup locally
      archive:
        path: "/backup/{{ inventory_hostname }}/{{ ansible_date_time.date }}/{{ db_name }}-export.sql"
        dest: "/backup/{{ inventory_hostname }}/{{ ansible_date_time.date }}/{{ db_name }}-{{ ansible_date_time.epoch }}.tar.gz"
        remove: yes
      delegate_to: localhost
```

**Local API Integrations:**

```yaml
- hosts: application_servers
  tasks:
    - name: Register deployment start
      uri:
        url: "{{ deployment_api }}/deployments"
        method: POST
        body_format: json
        body:
          environment: "{{ environment }}"
          version: "{{ app_version }}"
          hosts: "{{ ansible_play_hosts }}"
          status: "started"
          timestamp: "{{ ansible_date_time.iso8601 }}"
      register: deployment_record
      delegate_to: localhost
      run_once: true
      
    - name: Deploy application
      include_tasks: app-deployment.yml
      
    - name: Update deployment status
      uri:
        url: "{{ deployment_api }}/deployments/{{ deployment_record.json.id }}"
        method: PATCH
        body_format: json
        body:
          status: "{{ 'completed' if ansible_failed_task is not defined else 'failed' }}"
          completed_at: "{{ ansible_date_time.iso8601 }}"
      delegate_to: localhost
      run_once: true
```

### Advanced Delegation Patterns

**Cross-Host Coordination:**

```yaml
- hosts: database_cluster
  tasks:
    - name: Check cluster status on primary
      command: mysql -e "SHOW STATUS LIKE 'wsrep_cluster_size'"
      register: cluster_status
      when: inventory_hostname == groups['database_cluster'][0]
      
    - name: Share cluster status across nodes
      set_fact:
        cluster_size: "{{ hostvars[groups['database_cluster'][0]]['cluster_status']['stdout_lines'][1].split()[1] }}"
      delegate_to: "{{ item }}"
      delegate_facts: true
      loop: "{{ groups['database_cluster'] }}"
      when: inventory_hostname == groups['database_cluster'][0]
      
    - name: Proceed only if cluster is healthy
      fail:
        msg: "Cluster size {{ cluster_size }} is below minimum threshold"
      when: cluster_size | int < 3
```

**Fact Delegation and Sharing:**

```yaml
- hosts: web_servers
  tasks:
    - name: Gather web server statistics
      shell: |
        echo "connections: $(netstat -an | grep :80 | wc -l)"
        echo "memory_used: $(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}')"
        echo "cpu_load: $(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')"
      register: server_stats
      
    - name: Process server statistics
      set_fact:
        processed_stats:
          hostname: "{{ inventory_hostname }}"
          connections: "{{ server_stats.stdout_lines[0].split(':')[1] | trim | int }}"
          memory_percent: "{{ server_stats.stdout_lines[1].split(':')[1] | trim | float }}"
          cpu_load: "{{ server_stats.stdout_lines[2].split(':')[1] | trim | float }}"
          
    - name: Aggregate statistics on monitoring server
      set_fact:
        all_server_stats: "{{ all_server_stats | default([]) + [hostvars[item]['processed_stats']] }}"
      delegate_to: "{{ groups['monitoring'][0] }}"
      delegate_facts: true
      loop: "{{ groups['web_servers'] }}"
      run_once: true
      
    - name: Generate monitoring report
      template:
        src: server-report.j2
        dest: "/var/www/html/server-status-{{ ansible_date_time.epoch }}.html"
      delegate_to: "{{ groups['monitoring'][0] }}"
      run_once: true
```

