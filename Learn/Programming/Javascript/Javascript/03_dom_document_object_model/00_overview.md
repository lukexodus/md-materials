## Overview


JavaScript's interaction with the DOM enables dynamic manipulation of web pages. The DOM represents the structure of a webpage as a tree of objects, and JavaScript provides the tools to read, modify, and manipulate it.

---

### **What is the DOM?**

The **Document Object Model (DOM)** is a programming interface for web documents. It:

- Represents the HTML structure as a tree of nodes (elements, attributes, and text).
- Allows programs (like JavaScript) to interact with the structure, style, and content of a webpage.
- Is dynamic, meaning changes in the DOM are reflected in the webpage immediately.

---

### **Key DOM Concepts**

#### **DOM Tree Structure**

- The DOM represents an HTML document as a **tree of nodes**.  
    Example HTML:
    
    ```html
    <html>
      <body>
        <h1>Hello World</h1>
        <p>This is a paragraph.</p>
      </body>
    </html>
    ```
    
    DOM Tree:
    
    ```
    - html
      - body
        - h1
        - p
    ```
    

#### **Types of Nodes**

1. **Element Nodes**: Represent HTML tags (e.g., `<div>`, `<p>`).
2. **Text Nodes**: Represent text inside elements.
3. **Attribute Nodes**: Represent attributes of elements (e.g., `class`, `id`).

---

