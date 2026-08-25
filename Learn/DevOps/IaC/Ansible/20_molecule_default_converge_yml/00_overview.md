## Overview


---
- name: Converge
  hosts: all
  become: true
  
  tasks:
    - name: Test module with minimal parameters
      custom_service_manager:
        name: test_service
        state: started
      register: result
    
    - name: Verify service started
      assert:
        that:
          - result is changed
          - result.service_status.state == "started"
    
    - name: Test idempotence
      custom_service_manager:
        name: test_service
        state: started
      register: idempotent_result
    
    - name: Verify idempotence
      assert:
        that:
          - idempotent_result is not changed
    
    - name: Test service stop
      custom_service_manager:
        name: test_service
        state: stopped
      register: stop_result
    
    - name: Verify service stopped
      assert:
        that:
          - stop_result is changed
          - stop_result.service_status.state == "stopped"
```

**Property-Based Testing:**

**Hypothesis Framework** generates test cases for comprehensive coverage:

```python
