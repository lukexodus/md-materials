## **Accessing the DOM**


JavaScript provides multiple methods to access and manipulate DOM elements:

#### **Common Methods to Select Elements**

1. **By ID**:
    
    ```javascript
    const element = document.getElementById("myId");
    ```
    
2. **By Class Name**:
    
    ```javascript
    const elements = document.getElementsByClassName("myClass");
    ```
    
3. **By Tag Name**:
    
    ```javascript
    const elements = document.getElementsByTagName("p");
    ```
    
4. **Using CSS Selectors (`querySelector` and `querySelectorAll`)**:
    
    - `querySelector` selects the first matching element.
    - `querySelectorAll` selects all matching elements.
    
    ```javascript
    const element = document.querySelector(".myClass");
    const elements = document.querySelectorAll("p");
    ```


---

