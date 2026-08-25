## Module Naming


Modules (or files in many languages) serve as physical containers for code. Naming should map clearly to the filesystem and the logical grouping of the internal code.

**Key Points**

- **Lowercase:** Modules are typically named in all lowercase to avoid issues with case-sensitive filesystems (Linux vs. Windows/macOS).
    
- **Snake_case:** In languages like Python or Ruby, underscores are used to separate words (e.g., `data_processing.py`).
    
- **Short and Concise:** Module names should be shorter than class names but still descriptive.
    
- **Reflect Contents:** If a module contains a single class, name the module after the class (e.g., `User.js` containing class `User`). If it contains utilities, name it by the domain (e.g., `math_utils`).
    

**Example**

- **Poor:** `NewFile1.ts`, `Stuff.py`, `Class1.java`
    
- **Better:** `user_controller.py`, `http_client.js`, `string_extensions.rb`
    

---

