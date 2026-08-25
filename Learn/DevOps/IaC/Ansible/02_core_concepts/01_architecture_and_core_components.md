## Architecture and Core Components


Ansible follows a push-based model where the control node executes tasks on managed nodes without requiring agents. The control node contains the Ansible engine, inventory, playbooks, and modules, while managed nodes only need SSH access and Python (for most modules).

The execution flow begins when Ansible reads the inventory to identify target hosts, then generates Python modules based on playbook tasks. These modules are transferred to managed nodes, executed locally, and results are returned to the control node. This approach minimizes network overhead and eliminates the need for persistent agents.

