## **Creating and Removing Elements**


#### **Creating Elements**

- Use `document.createElement` to create new elements:
    
    ```javascript
    const newDiv = document.createElement("div");
    newDiv.textContent = "Hello, DOM!";
    ```
    

#### **Adding Elements to the DOM**

- Append the new element to an existing element:
    
    ```javascript
    const parent = document.querySelector("body");
    parent.appendChild(newDiv);
    ```
    

#### **Removing Elements**

- Use `removeChild` or `remove`:
    
    ```javascript
    const parent = document.querySelector("body");
    const child = document.querySelector("h1");
    parent.removeChild(child);
    
    // Alternative (modern):
    child.remove();
    ```
    

---

