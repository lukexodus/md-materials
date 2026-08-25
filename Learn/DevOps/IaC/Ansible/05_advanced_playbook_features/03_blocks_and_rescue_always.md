## Blocks and rescue/always


### Block Structure and Execution Flow

Blocks group related tasks and provide exception handling through rescue and always sections. When any task in a block fails, execution transfers to the rescue section, followed by the always section regardless of success or failure.

**Basic Block Structure:**

```yaml
- name: Application deployment block
  block:
    - name: Stop application service
      service:
        name: myapp
        state: stopped
    
    - name: Update application files
      unarchive:
        src: "{{ app_package_url }}"
        dest: /opt/myapp
        remote_src: yes
        owner: appuser
        group: appgroup
    
    - name: Update database schema
      command: /opt/myapp/bin/migrate-db.sh
      register: migration_result
    
    - name: Start application service
      service:
        name: myapp
        state: started
        
  rescue:
    - name: Log deployment failure
      debug:
        msg: "Deployment failed at {{ ansible_date_time.iso8601 }}"
    
    - name: Restore from backup
      command: /opt/scripts/restore-backup.sh
      register: restore_result
    
    - name: Start service after restore
      service:
        name: myapp
        state: started
      when: restore_result.rc == 0
        
  always:
    - name: Send deployment notification
      uri:
        url: "{{ notification_webhook }}"
        method: POST
        body_format: json
        body:
          status: "{{ 'success' if ansible_failed_task is not defined else 'failed' }}"
          timestamp: "{{ ansible_date_time.iso8601 }}"
          host: "{{ inventory_hostname }}"
```

### Nested Blocks and Complex Error Handling

**Multi-Level Error Handling:**

```yaml
- name: Database maintenance workflow
  block:
    - name: Primary database operations
      block:
        - name: Create database backup
          mysql_db:
            name: "{{ db_name }}"
            state: dump
            target: "/backup/{{ db_name }}-{{ ansible_date_time.epoch }}.sql"
        
        - name: Perform database optimization
          mysql_db:
            name: "{{ db_name }}"
            state: import
            target: /opt/sql/optimize.sql
            
      rescue:
        - name: Handle database operation failure
          debug:
            msg: "Database operations failed, attempting alternative approach"
        
        - name: Alternative optimization method
          command: mysqlcheck -o {{ db_name }} -u {{ db_user }} -p{{ db_password }}
          no_log: true
          
  rescue:
    - name: Critical failure handling
      block:
        - name: Send alert to administrators
          mail:
            to: "{{ admin_email }}"
            subject: "Critical database maintenance failure on {{ inventory_hostname }}"
            body: "Database maintenance failed with error: {{ ansible_failed_result.msg }}"
        
        - name: Create incident ticket
          uri:
            url: "{{ ticketing_api }}/incidents"
            method: POST
            body_format: json
            body:
              title: "Database maintenance failure"
              description: "Automated maintenance failed on {{ inventory_hostname }}"
              priority: "high"
              
      rescue:
        - name: Log to local file as last resort
          lineinfile:
            path: /var/log/ansible-failures.log
            line: "{{ ansible_date_time.iso8601 }}: Database maintenance failed on {{ inventory_hostname }}"
            create: yes
            
  always:
    - name: Cleanup temporary files
      file:
        path: "{{ item }}"
        state: absent
      loop:
        - /tmp/db-maintenance.lock
        - /tmp/optimization.tmp
      ignore_errors: yes
    
    - name: Update maintenance log
      lineinfile:
        path: /var/log/maintenance.log
        line: "{{ ansible_date_time.iso8601 }}: Maintenance attempt completed"
        create: yes
```

### Block Variables and Inheritance

**Block-Level Variables:**

```yaml
- name: Environment-specific deployment
  block:
    - name: Configure application for production
      template:
        src: app-config.j2
        dest: /etc/myapp/config.yml
      notify: restart myapp
    
    - name: Set production database connection
      lineinfile:
        path: /etc/myapp/database.conf
        regexp: '^host='
        line: "host={{ prod_db_host }}"
      notify: restart myapp
      
    - name: Enable production logging
      lineinfile:
        path: /etc/myapp/logging.conf
        regexp: '^level='
        line: "level=INFO"
        
  vars:
    environment: production
    prod_db_host: "{{ groups['databases'][0] }}"
    log_level: INFO
    
  when: deployment_environment == "production"
  tags: 
    - production
    - deployment
```

