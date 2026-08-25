## Overview


name: Cross-Platform Module Testing

on: [push, pull_request]

jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-20.04, ubuntu-22.04, centos-8, rhel-8, debian-11]
        python-version: [3.8, 3.9, 3.10, 3.11]
        ansible-version: [4.10, 5.10, 6.7]
        exclude:
          # Exclude incompatible combinations
          - python-version: 3.11
            ansible-version: 4.10
    
    runs-on: ${{ matrix.os }}
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Install Ansible ${{ matrix.ansible-version }}
        run: |
          pip install "ansible-core~=${{ matrix.ansible-version }}"
          pip install molecule[docker] pytest
      
      - name: Run unit tests
        run: python -m pytest tests/unit/
      
      - name: Run integration tests
        run: molecule test
      
      - name: Run performance benchmarks
        run: python -m pytest tests/performance/ --benchmark-only
```

## Contributing to Ansible Community

Contributing to the Ansible community involves following established processes, coding standards, and collaboration practices that maintain project quality and foster inclusive participation.

**Community Contribution Workflow:**

**GitHub Workflow** manages contributions through pull requests and issue tracking:

```bash
