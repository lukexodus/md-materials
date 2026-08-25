## **Strict Equality vs Loose Equality (`===` vs `==`)**


#### **1. Strict Equality (`===`)**

- Compares **both value and type**.
- No type conversion is performed.
- Use when you want precise comparisons.

**Examples**:

```javascript
console.log(5 === 5);       // true (same value and type)
console.log(5 === "5");     // false (different types)
console.log(null === undefined); // false (different types)
```

---

#### **2. Loose Equality (`==`)**

- Compares **values** but performs **type coercion** (converts one or both values to the same type before comparing).
- Use cautiously, as type coercion can lead to unexpected results.

**Examples**:

```javascript
console.log(5 == "5");       // true (string "5" is coerced to number 5)
console.log(null == undefined); // true (both are loosely equal)
console.log(true == 1);      // true (true is coerced to 1)
console.log(" " == 0);       // true (empty string is coerced to 0)
```

**Key Difference**:

- Use `===` for more predictable and safer comparisons.
- Avoid `==` unless you specifically need type coercion and know how it behaves.

---


### **Type Coercion in JavaScript**

Type coercion is the process where JavaScript automatically converts values from one data type to another to perform operations. It can occur **implicitly** (automatic by JavaScript) or **explicitly** (via manual conversion using methods).

---

#### **1. Types of Type Coercion**

##### **1.1 Implicit Coercion**

- Happens automatically during operations where different data types are involved.
- Examples:
    - **String + Number** → String
    - **Boolean to Number** → 1 (for `true`), 0 (for `false`)

```javascript
console.log("5" + 3);  // "53" (number 3 is coerced into a string)
console.log("5" - 3);  // 2 (string "5" is coerced into a number)
console.log(true + 1); // 2 (true is coerced to 1)
console.log(false + 10); // 10 (false is coerced to 0)
```

---

##### **1.2 Explicit Coercion**

- Happens when you manually convert a value using JavaScript functions or operators.
- Examples:

    ```javascript
    console.log(Number("42"));     // 42 (string to number)
    console.log(String(42));       // "42" (number to string)
    console.log(Boolean(1));       // true (number to boolean)
    console.log(parseInt("123px")); // 123 (string to integer)
    ```

---

#### **2. Rules for Type Coercion**

##### **2.1 To String**

When a value is coerced to a string (e.g., with `+`):

- Numbers are converted to their string representation.
    
    ```javascript
    console.log(42 + ""); // "42"
    ```
    
- Booleans: `true → "true"`, `false → "false"`.
    
    ```javascript
    console.log(String(false)); // "false"
    ```
    
- `null → "null"`, `undefined → "undefined"`.

---

##### **2.2 To Number**

When a value is coerced to a number (e.g., with `-`, `*`, `/`, or `Number()`):

- Strings are parsed as numbers if possible, otherwise `NaN`.
    
    ```javascript
    console.log("42" - 0); // 42
    console.log(Number("42.5")); // 42.5
    console.log(Number("hello")); // NaN
    ```
    
- Booleans: `true → 1`, `false → 0`.
    
    ```javascript
    console.log(true * 2); // 2
    ```
    
- `null → 0`, `undefined → NaN`.

---

##### **2.3 To Boolean**

When a value is coerced to a boolean (e.g., in conditions or `Boolean()`):

- **Falsy values**: `false`, `0`, `-0`, `""`, `null`, `undefined`, and `NaN`.
    
    ```javascript
    console.log(Boolean(0)); // false
    console.log(Boolean("")); // false
    console.log(Boolean(null)); // false
    ```
    
- **Truthy values**: All other values, including non-empty strings, objects, arrays, and `Infinity`.
    
    ```javascript
    console.log(Boolean(1)); // true
    console.log(Boolean("hello")); // true
    console.log(Boolean([])); // true
    ```
    

---

#### **3. Common Type Coercion Examples**

##### **3.1 Arithmetic Operations**

- **Addition (`+`)**:
    
    - If one operand is a string, the other is coerced to a string.
    
    ```javascript
    console.log("5" + 2); // "52"
    console.log(2 + "5"); // "25"
    ```
    
- Other operators (`-`, `*`, `/`, `%`) coerce both operands to numbers.
    
    ```javascript
    console.log("5" - 2); // 3
    console.log("10" * 2); // 20
    console.log("6" / "2"); // 3
    ```
    

##### **3.2 Logical Operations**

- **AND (`&&`)** and **OR (`||`)**:
    
    - Return the value of the first falsy or last truthy operand.
    
    ```javascript
    console.log(false || "hello"); // "hello" (false is falsy, returns the next truthy value)
    console.log(true && "world");  // "world" (true is truthy, returns the next value)
    ```
    
- **NOT (`!`)**:
    
    - Coerces the operand to a boolean, then inverts it.
    
    ```javascript
    console.log(!0); // true (0 is falsy, NOT makes it true)
    console.log(!"hello"); // false ("hello" is truthy, NOT makes it false)
    ```
    

##### **3.3 Comparisons**

- **Equality (`==`)**:
    
    - Converts values to the same type before comparing.
    
    ```javascript
    console.log("5" == 5); // true (string coerced to number)
    console.log(true == 1); // true (true coerced to 1)
    ```
    
- **Strict Equality (`===`)**:
    
    - No coercion; values must have the same type.
    
    ```javascript
    console.log("5" === 5); // false (different types)
    ```
    
- **Greater/Less Than (`>`, `<`)**:
    
    - Strings are compared lexicographically (dictionary order).
    
    ```javascript
    console.log("apple" > "banana"); // false
    console.log("5" > 2); // true ("5" coerced to number)
    ```
    

---

#### **4. Avoiding Unintended Type Coercion**

1. Use **strict equality (`===`)** instead of loose equality (`==`) to avoid unintended conversions.
    
    ```javascript
    console.log(5 === "5"); // false
    ```
    
2. Explicitly convert data types to avoid confusion.
    
    ```javascript
    let num = Number("42");
    console.log(num + 5); // 47
    ```
    
3. Be cautious with **truthy/falsy values** in conditions.
    
    ```javascript
    let input = "";
    if (input) {
      console.log("Input exists!"); // Won't run because "" is falsy
    }
    ```


---

#### **5. Summary of Coercion Table**

| **Value**          | **To String**       | **To Number** | **To Boolean** |
| ------------------ | ------------------- | ------------- | -------------- |
| `"123"`            | `"123"`             | `123`         | `true`         |
| `true`             | `"true"`            | `1`           | `true`         |
| `false`            | `"false"`           | `0`           | `false`        |
| `null`             | `"null"`            | `0`           | `false`        |
| `undefined`        | `"undefined"`       | `NaN`         | `false`        |
| `0`                | `"0"`               | `0`           | `false`        |
| `42`               | `"42"`              | `42`          | `true`         |
| `{}` (object)      | `"[object Object]"` | `NaN`         | `true`         |
| `[]` (empty array) | `""`                | `0`           | `true`         |

---

