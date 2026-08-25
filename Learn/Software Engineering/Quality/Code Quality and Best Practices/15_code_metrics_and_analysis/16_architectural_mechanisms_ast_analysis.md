## Architectural Mechanisms & AST Analysis


Bandit diverges from regex-based linters by utilizing Python's `ast` (Abstract Syntax Tree) module. It parses source code into a tree structure of syntax nodes, allowing for context-aware security assertions that are impossible with text matching.

- **Node Traversal:** Bandit iterates over AST nodes (e.g., `Call`, `Import`, `Str`). Plugins subscribe to specific node types. For instance, a plugin monitoring for `subprocess` usage subscribes to `Call` nodes and inspects the `func` attribute.
    
- **Contextual limitations:** Since Bandit performs static analysis on the AST, it lacks runtime context. It cannot determine the value of a variable derived from external input unless it is a literal within the scope of the AST being analyzed. This leads to a lack of _taint analysis_ capabilities (tracking data flow from source to sink).
    
- **Execution Flow:**
    
    1. **Manager Initialization:** Loads config, profiles, and plugins.
        
    2. **File Discovery:** recursively finds `.py` files, respecting exclusions.
        
    3. **AST Generation:** `ast.parse()` generates the tree.
        
    4. **Node Visiting:** The `BanditNodeVisitor` walks the tree.
        
    5. **Plugin Execution:** Registered checks run against matching nodes.
        
    6. **Aggregation:** Metrics (confidence/severity) are calculated and aggregated.
        

