## Indentation standards


Indentation provides a visual hierarchy to the code structure, mapping the logical nesting of blocks (loops, conditionals, functions) to the visual layout. It is crucial for understanding the scope and flow of execution.

**Key Points**

- **Tabs vs. Spaces:**
    
    - **Spaces:** The most common standard (typically 2 or 4). Spaces guarantee identical rendering across all environments and viewports.
        
    - **Tabs:** Allow developers to configure their own display width preference without changing the file content.
        
    - **Consensus:** The industry generally leans towards spaces for consistency, but the critical rule is to **never mix tabs and spaces** in the same file.
        
- **Standard Widths:**
    
    - **2 Spaces:** Common in JavaScript, Ruby, HTML, and CSS (reduces horizontal sprawl in deeply nested callbacks).
        
    - **4 Spaces:** Standard for Python (PEP 8), Java, C#, and PHP.
        
    - **8 Spaces:** Traditional standard for systems programming (e.g., Linux Kernel) to strongly discourage deep nesting.
        
- **Syntactic Indentation:** In languages like Python and YAML, indentation is significant and defines the block structure. Incorrect indentation results in syntax errors or logic bugs.
    

**Best Practices**

- **Visual Guides:** Enable indent guides in the IDE to draw vertical lines at each indentation level, aiding in identifying block start and end points.
    
- **Hanging Indents:** When a line continues to the next, indent the subsequent lines to distinctively separate them from the enclosed block content.
    

**Example**

_Python (Significant Indentation):_

Python

```
def process_data(data):
    if not data:
        return None
    # 4 spaces standard
    for item in data:
        if item.is_valid():
            save(item)
```

