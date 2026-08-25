## Jinja2 Templating Basics


Jinja2 templates integrate deeply into Ansible's variable system, providing powerful text processing, conditional logic, and data transformation capabilities that extend far beyond simple variable substitution.

Variable interpolation uses double curly braces `{{ variable_name }}` for basic substitution, with support for complex expressions, mathematical operations, and function calls. Template expressions can access nested data structures using dot notation or bracket syntax for dynamic key access.

Control structures include conditional blocks using `{% if condition %}`, loop constructs with `{% for item in list %}`, and macro definitions for reusable template components. These structures support complex logic patterns within template files while maintaining readability.

**Key points** for effective Jinja2 usage include understanding filter applications, whitespace control, and template inheritance patterns. Filters transform variable values using pipe syntax like `{{ variable | upper | trim }}`, while whitespace control manages template output formatting.

Built-in filters cover common transformation needs including string manipulation (`upper`, `lower`, `replace`), list operations (`join`, `unique`, `sort`), mathematical functions (`round`, `abs`), and data type conversions (`int`, `float`, `bool`).

Template inheritance allows creating base templates with extension points that child templates can customize, reducing duplication in configuration file generation while maintaining consistency across similar file types.

**Example** of advanced Jinja2 templating:

```jinja2
{% set environment = group_names | intersect(['prod', 'stage', 'dev']) | first %}
server {
    listen {{ ansible_default_ipv4.address }}:{{ http_port | default(80) }};
    server_name {{ inventory_hostname }};
    
    {% if environment == 'prod' %}
    access_log /var/log/nginx/{{ inventory_hostname }}.access.log;
    error_log /var/log/nginx/{{ inventory_hostname }}.error.log;
    {% endif %}
    
    {% for upstream in groups['backends'] %}
    upstream backend_{{ loop.index }} {
        server {{ hostvars[upstream]['ansible_default_ipv4']['address'] }}:8080;
    }
    {% endfor %}
}
```

