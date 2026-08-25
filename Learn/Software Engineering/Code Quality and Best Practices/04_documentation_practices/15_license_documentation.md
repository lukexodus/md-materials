## License Documentation


License documentation is the legal backbone of open-source and proprietary software. It defines how code can be used, modified, shared, and distributed. Proper licensing protects intellectual property, clarifies liability, and ensures compliance with third-party dependencies.

**Key Points**

- **The LICENSE File:** Every project root must contain a file named `LICENSE` or `LICENSE.txt` (case-insensitive, but uppercase is standard). This file contains the full text of the chosen license (e.g., MIT, Apache 2.0, GPLv3).
    
- **Source Code Headers:** For strict compliance (especially in enterprise or GPL projects), every source code file should include a header comment block. This block states the copyright holder, the year, and a brief reference to the license governing the file.
    
- **Third-Party Attribution:** If your project bundles or statically links code from other open-source projects, you must include a `NOTICE` file or a `ThirdPartyNotices.txt`. This file lists all dependencies and their respective licenses to comply with attribution clauses.
    
- **SPDX Identifiers:** Use SPDX (Software Package Data Exchange) identifiers in package manifests (like `package.json`, `Cargo.toml`, or `pom.xml`) and file headers. This machine-readable tag (e.g., `SPDX-License-Identifier: MIT`) allows automated tools to scan and verify license compliance.
    
- **Dual Licensing:** If a project offers different terms for different users (e.g., GPL for open source, commercial license for paid users), this must be explicitly documented in the `README` and `LICENSE` files to avoid ambiguity.
    

**Example**

- **File Header (SPDX style):**
    
    Python
    
    ```
    # SPDX-License-Identifier: MIT
    # Copyright (c) 2024 Company Name
    ```
    
- **Standard Header (Apache 2.0 style):**
    
    Java
    
    ```
    /*
     * Copyright 2024 Company Name
     *
     * Licensed under the Apache License, Version 2.0 (the "License");
     * you may not use this file except in compliance with the License.
     * You may obtain a copy of the License at ...
     */
    ```
    

---

