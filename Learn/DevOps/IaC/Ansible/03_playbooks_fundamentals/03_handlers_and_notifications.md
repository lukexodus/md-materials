## Handlers and Notifications


Handlers provide event-driven task execution, running only when triggered by notifications from other tasks. They execute at the end of a play and run only once, regardless of how many tasks notify them.

**Key Points:**

- Handlers run after all tasks complete
- Multiple notifications to the same handler result in single execution
- Handlers execute in the order they appear in the handlers section
- Failed tasks prevent handler execution unless `force_handlers: true` is set

**Handler Definition:**

```yaml
---
- name: Configure web server
  hosts: webservers
  tasks:
    - name: Update Apache configuration
      template:
        src: httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
      notify:
        - restart apache
        - reload firewall

  handlers:
    - name: restart apache
      service:
        name: httpd
        state: restarted
    
    - name: reload firewall
      command: firewall-cmd --reload
```

**Notification Mechanisms:**

- `notify` keyword triggers handlers by name
- `listen` keyword allows handlers to respond to topic-based notifications
- `meta: flush_handlers` forces immediate handler execution

