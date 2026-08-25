## Serial and Batch Processing


### Serial Execution Control

Serial processing controls how many hosts execute tasks simultaneously, enabling rolling deployments, resource management, and dependency coordination. This is essential for maintaining service availability during updates.

### Basic Serial Configuration

**Fixed Number Serial:**

```yaml
- hosts: webservers
  serial: 2
  tasks:
    - name: Stop web service
      service:
        name: apache2
        state: stopped
        
    - name: Update application code
      git:
        repo: "{{ app_repo_url }}"
        dest: /var/www/html
        version: "{{ app_version }}"
        
    - name: Start web service
      service:
        name: apache2
        state: started
        
    - name: Verify service is responding
      uri:
        url: "http://{{ inventory_hostname }}"
        method: GET
      retries: 5
      delay: 10
```

**Percentage-Based Serial:**

```yaml
- hosts: database_cluster
  serial: "25%"  # Process 25% of hosts at a time
  max_fail_percentage: 10  # Fail if more than 10% of hosts fail
  tasks:
    - name: Stop database service
      service:
        name: mysql
        state: stopped
        
    - name: Update database configuration
      template:
        src: mysql.conf.j2
        dest: /etc/mysql/mysql.conf.d/mysqld.cnf
      notify: restart mysql
      
    - name: Start database service
      service:
        name: mysql
        state: started
        
    - name: Wait for database to be ready
      wait_for:
        port: 3306
        host: "{{ inventory_hostname }}"
        timeout: 300
```

### Progressive Serial Execution

**Increasing Batch Sizes:**

```yaml
- hosts: application_servers
  serial:
    - 1        # First host (canary)
    - 25%      # Then 25% of remaining hosts
    - 100%     # Finally, all remaining hosts
  tasks:
    - name: Deploy to canary first
      block:
        - name: Update application
          unarchive:
            src: "{{ app_package_url }}"
            dest: /opt/myapp
            remote_src: yes
          notify: restart myapp
          
        - name: Wait for application startup
          wait_for:
            port: 8080
            timeout: 120
            
        - name: Run smoke tests
          uri:
            url: "http://{{ inventory_hostname }}:8080/api/health"
            method: GET
          register: health_check
          retries: 3
          delay: 10
          
      when: inventory_hostname == ansible_play_hosts[0]  # Canary host
      
    - name: Deploy to remaining hosts
      block:
        - name: Update application
          unarchive:
            src: "{{ app_package_url }}"
            dest: /opt/myapp
            remote_src: yes
          notify: restart myapp
          
        - name: Health check
          uri:
            url: "http://{{ inventory_hostname }}:8080/api/health"
            method: GET
          retries: 5
          delay: 5
          
      when: inventory_hostname != ansible_play_hosts[0]  # Non-canary hosts
```

### Complex Serial Workflows

**Multi-Stage Serial Deployment:**

```yaml
- hosts: production_cluster
  serial:
    - 1    # Canary deployment
    - 2    # Small batch
    - 50%  # Half of remaining
    - 100% # All remaining
  max_fail_percentage: 5
  
  vars:
    deployment_stages:
      canary:
        health_check_retries: 10
        smoke_test_timeout: 300
      batch:
        health_check_retries: 5
        smoke_test_timeout: 120
      production:
        health_check_retries: 3
        smoke_test_timeout: 60
        
  tasks:
    - name: Determine deployment stage
      set_fact:
        current_stage: >-
          {%- if ansible_play_hosts.index(inventory_hostname) == 0 -%}
            canary
          {%- elif ansible_play_hosts.index(inventory_hostname) < 3 -%}
            batch
          {%- else -%}
            production
          {%- endif -%}
            
    - name: Pre-deployment health check
      uri:
        url: "http://{{ inventory_hostname }}:8080/health"
        method: GET
      register: pre_health
      ignore_errors: yes
      
    - name: Skip unhealthy hosts
      meta: host_disabled
      when: 
        - pre_health.failed
        - current_stage != "canary"
        
    - name: Remove from load balancer
      uri:
        url: "{{ load_balancer_api }}/servers/{{ inventory_hostname }}/disable"
        method: POST
      delegate_to: localhost
      
    - name: Wait for connection drain
      wait_for:
        timeout: "{{ 60 if current_stage == 'canary' else 30 }}"
      delegate_to: localhost
      
    - name: Deploy application
      unarchive:
        src: "{{ app_package_url }}"
        dest: /opt/myapp
        remote_src: yes
        backup: yes
      register: deployment_result
      notify: restart myapp
      
    - name: Post-deployment health check
      uri:
        url: "http://{{ inventory_hostname }}:8080/health"
        method: GET
      register: post_health
      retries: "{{ deployment_stages[current_stage].health_check_retries }}"
      delay: 10
      
    - name: Run smoke tests for canary
      include_tasks: smoke-tests.yml
      when: current_stage == "canary"
      
    - name: Add back to load balancer
      uri:
        url: "{{ load_balancer_api }}/servers/{{ inventory_hostname }}/enable"
        method: POST
      delegate_to: localhost
      when: post_health.status == 200
      
    - name: Rollback on failure
      block:
        - name: Stop failed service
          service:
            name: myapp
            state: stopped
            
        - name: Restore from backup
          command: /opt/scripts/restore-backup.sh
          register: restore_result
          
        - name: Start restored service
          service:
            name: myapp
            state: started
          when: restore_result.rc == 0
          
      when: post_health.failed
```

**Database Cluster Serial Maintenance:**

```yaml
- hosts: mysql_cluster
  serial: 1  # One node at a time for safety
  vars:
    maintenance_order:
      - "{{ groups['mysql_cluster'] | select('match', '.*slave.*') | list }}"  # Slaves first
      - "{{ groups['mysql_cluster'] | select('match', '.*master.*') | list }}" # Master last
      
  tasks:
    - name: Check replication status
      mysql_replication:
        mode: getreplica
      register: replication_status
      when: "'slave' in inventory_hostname"
      
    - name: Ensure replication is current
      fail:
        msg: "Replication lag too high: {{ replication_status.Seconds_Behind_Master }} seconds"
      when: 
        - "'slave' in inventory_hostname"
        - replication_status.Seconds_Behind_Master | int > 60
        
    - name: Stop MySQL service
      service:
        name: mysql
        state: stopped
        
    - name: Perform maintenance tasks
```

---

