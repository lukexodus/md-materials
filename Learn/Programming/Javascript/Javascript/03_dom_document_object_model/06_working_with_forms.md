## **Working with Forms**


JavaScript can access and manipulate form elements for interactive input handling.

1. **Access Input Values**:
    
    ```javascript
    const input = document.querySelector("input");
    console.log(input.value);
    ```
    
2. **Form Submission**:
    
    ```javascript
    const form = document.querySelector("form");
    form.addEventListener("submit", (event) => {
      event.preventDefault(); // Prevent page reload
      console.log("Form submitted!");
    });
    ```
    

---

**Performance Tips**

1. Minimize DOM access (e.g., avoid repeatedly querying the DOM).
2. Use `documentFragment` to batch DOM updates.
3. Avoid inline event handlers (e.g., `onclick`).

---

**Summary**

| **Action**         | **Method**                              |
| ------------------ | --------------------------------------- |
| Select Elements    | `getElementById`, `querySelector`       |
| Change Content     | `textContent`, `innerHTML`              |
| Modify Attributes  | `setAttribute`, `getAttribute`          |
| Change Styles      | `style`                                 |
| Add/Remove Classes | `classList.add`, `classList.remove`     |
| Create Elements    | `createElement`, `appendChild`          |
| Add Events         | `addEventListener`                      |
| DOM Navigation     | `parentNode`, `children`, `nextSibling` |

---

