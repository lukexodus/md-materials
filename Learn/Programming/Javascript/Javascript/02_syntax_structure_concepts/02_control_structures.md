## **Control Structures**


Control structures allow you to control the flow of your program.

### **Conditional Statements**:

1. `if-else`:
    
    ```javascript
    let score = 85;
    if (score > 90) {
      console.log("A grade");
    } else if (score > 80) {
      console.log("B grade");
    } else {
      console.log("C grade");
    }
    ```
    
2. `switch`: Useful for multiple cases.
    
    ```javascript
    let day = 3;
    switch (day) {
      case 1:
        console.log("Monday");
        break;
      case 2:
        console.log("Tuesday");
        break;
      case 3:
        console.log("Wednesday");
        break;
      default:
        console.log("Invalid day");
    }
    ```

### **Loops**:

1. `for` loop:
    
    ```javascript
    for (let i = 0; i < 5; i++) {
      console.log(i); // 0, 1, 2, 3, 4
    }
    ```
    
2. `while` loop:
    
    ```javascript
    let i = 0;
    while (i < 5) {
      console.log(i);
      i++;
    }
    ```
    
3. `do-while` loop: Executes the block at least once.
    
    ```javascript
    let i = 0;
    do {
      console.log(i);
      i++;
    } while (i < 5);
    ```
    
4. **`break` and `continue`**:
    
    - `break`: Exits the loop.
    - `continue`: Skips to the next iteration.

---

### **Switch vs If-Else**

#### **1. `switch` Statement**

- Best for comparing a single value against **multiple specific cases**.
- Executes the block of code that matches the case.
- Includes a `default` case if no match is found.
- **Syntax**:
    
    ```javascript
    let day = 3;
    switch (day) {
      case 1:
        console.log("Monday");
        break;
      case 2:
        console.log("Tuesday");
        break;
      case 3:
        console.log("Wednesday");
        break;
      default:
        console.log("Invalid day");
    }
    ```


**Key Features**:

- Good for **fixed comparisons** (e.g., matching a number or string).
- **`break`** is needed to stop execution after a case matches; otherwise, it "falls through" to the next case.

---

#### **2. `if-else` Statement**

- Best for **complex conditions** or comparisons involving multiple variables.
- Can handle ranges and logical expressions.
- **Syntax**:
    
    ```javascript
    let score = 85;
    if (score > 90) {
      console.log("A grade");
    } else if (score > 80) {
      console.log("B grade");
    } else {
      console.log("C grade");
    }
    ```

**Key Features**:

- More flexible for dynamic or logical conditions.
- Does not require `break`.

---

#### **Comparison Table**

|Feature|`switch`|`if-else`|
|---|---|---|
|**Purpose**|Fixed values or cases|Complex conditions or ranges|
|**Flexibility**|Limited to specific cases|Handles any boolean expression|
|**Code Readability**|Cleaner for multiple specific cases|Can get verbose with many conditions|
|**Performance**|Faster for a large number of cases|Slightly slower due to multiple evaluations|


---

