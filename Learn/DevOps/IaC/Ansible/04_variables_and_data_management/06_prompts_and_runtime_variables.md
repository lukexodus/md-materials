## Prompts and Runtime Variables


Interactive prompts and runtime variable collection enable dynamic playbook execution where user input, environmental conditions, or external data sources determine variable values at execution time rather than through static definition.

The `vars_prompt` directive creates interactive prompts that request user input during playbook execution, supporting password masking, input validation, and default value specification. These prompts work well for sensitive information that shouldn't be stored in version control or for deployment-specific parameters.

Survey functionality in Ansible Tower/AWX extends prompt capabilities with web-based forms, input validation, and integration with approval workflows. Surveys support multiple input types including text fields, dropdown selections, and boolean toggles.

Runtime variable injection through the `--extra-vars` command line option provides powerful override capabilities for CI/CD integration, where pipeline variables can influence playbook behavior without modifying source code.

**Example** of prompt configuration:

```yaml
vars_prompt:
  - name: deployment_version
    prompt: "Enter the version to deploy"
    default: "latest"
    private: false
  
  - name: database_password
    prompt: "Enter database password"
    private: true
    encrypt: "sha256_crypt"
    confirm: true
```

External variable loading through `lookup` plugins enables integration with external systems like credential management platforms, configuration databases, or cloud metadata services. These lookups execute at runtime and can adapt to changing external conditions.

**Key points** for runtime variables include understanding execution timing, implementing proper validation, and designing fallback strategies for automated execution scenarios where interactive prompts aren't available.

Variable registration captures task output for use in subsequent tasks, enabling dynamic decision-making based on command execution results, file content, or external system responses. Registered variables support complex workflow patterns and error handling strategies.

**Output** from well-designed variable management includes predictable configuration deployment, reduced manual intervention, improved security through proper secret handling, and maintainable automation that scales with infrastructure growth.

**Conclusion**

Mastering Ansible's variable system requires understanding the interplay between precedence rules, scoping mechanisms, and templating capabilities. Effective variable management strategies reduce configuration complexity while maintaining flexibility and security.

**Next steps** should focus on implementing variable validation patterns, establishing organizational conventions for variable file structure, and integrating external data sources through lookup plugins and dynamic inventory systems.

Related topics that build upon variable management include advanced inventory patterns, role development best practices, and integration with external configuration management systems.

---

