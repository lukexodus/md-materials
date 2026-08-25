## Overview


dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: ubuntu20
    image: quay.io/ansible/molecule-ubuntu:20.04
    pre_build_image: true
  - name: centos8
    image: quay.io/ansible/molecule-centos:8
    pre_build_image: true
provisioner:
  name: ansible
  config_options:
    defaults:
      interpreter_python: auto_silent
      callback_whitelist: profile_tasks, timer, yaml
    ssh_connection:
      pipelining: false
verifier:
  name: ansible
scenario:
  test_sequence:
    - dependency
    - lint
    - cleanup
    - destroy
    - syntax
    - create
    - prepare
    - converge
    - idempotence
    - side_effect
    - verify
    - cleanup
    - destroy
```

**Test Playbooks:**

```yaml
