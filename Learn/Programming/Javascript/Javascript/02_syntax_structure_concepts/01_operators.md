## **Operators**


Operators are used to perform operations on variables and values.

### **Types of Operators**:

1. **Arithmetic Operators (`+`, `-`, `*`, `/`, `%`, `**`)**: Perform mathematical operations.
    
    ```javascript
    let a = 10, b = 3;
    console.log(a + b); // 13
    console.log(a - b); // 7
    console.log(a * b); // 30
    console.log(a / b); // 3.3333
    console.log(a % b); // 1 (remainder)
    console.log(a ** b); // 1000 (exponentiation)
    ```
    
2. **Assignment Operators (`=`, `+=`, `-=`, `*=`, `/=`, `%=`, `**=`)**: Assign values to variables.
    
    ```javascript
    let x = 10;
    x += 5; // x = x + 5
    console.log(x); // 15
    ```
    
3. **Comparison Operators (`==`, `===`, `!=`, `!==`)**: Compare two values and return `true` or `false`.
    
    ```javascript
    console.log(5 > 3); // true
    console.log(5 == "5"); // true (loose equality)
    console.log(5 === "5"); // false (strict equality)
    ```
    
4. **Logical Operators**: Perform logical operations.
    
    ```javascript
    console.log(true && false); // false (AND)
    console.log(true || false); // true (OR)
    console.log(!true); // false (NOT)
    ```
    
5. **Ternary Operator**: A shorthand for `if-else`.
    
    ```javascript
    let age = 18;
    let result = age >= 18 ? "Adult" : "Minor";
    console.log(result); // "Adult"
    ```

6. **?? (Nullish Coalescing Operator)**
	- **Purpose**: Provides a way to assign default values **only when the left-hand operand is `null` or `undefined`**.
	- **Syntax**: `value1 ?? value2`
	- **Behavior**:
	    - If `value1` is `null` or `undefined`, the result is `value2`.
	    - Otherwise, the result is `value1`.
	**Example**
	
	```javascript
	let userInput = null;
	let defaultValue = "Default";
	let result = userInput ?? defaultValue; // "Default"
	```
	
	**Difference from `||` (Logical OR)**:
	
	- `||` checks for "falsy" values (`0`, `false`, `NaN`, `null`, `undefined`, `""`), whereas `??` checks **only** for `null` or `undefined`.
	
	**Example Comparing `??` and `||`**:
	```javascript
	let userInput = 0;
	console.log(userInput ?? "Default"); // 0
	console.log(userInput || "Default"); // "Default"
	```

7. **Optional Chaining Operator (?.)**
	- **Purpose**: Simplifies accessing nested properties without explicitly checking for `null` or `undefined`.
	- **Syntax**: `obj?.prop`, `obj?.[expr]`, `obj?.method()`
	- **Behavior**:
	    - If the left-hand operand is `null` or `undefined`, it short-circuits and returns `undefined` instead of throwing an error.
	**Example**
	```javascript
	let user = { profile: { name: "John" } };
	console.log(user.profile?.name); // "John"
	console.log(user.address?.city); // undefined (no error thrown)
	```

8. **Bitwise Operators (`&`, `|`, `^`, `~`, `<<`, `>>`)**
	- **Purpose**: Perform operations at the binary level.
	- Example:
	```javascript
	console.log(5 & 1); // 1 (binary AND)
	console.log(5 | 1); // 5 (binary OR)
	```

| Operator | Description                      | Example                            |
| -------- | -------------------------------- | ---------------------------------- |
| `<<`     | Left shift                       | `5 << 1` → `10`                    |
| `>>`     | Right shift (sign-preserving)    | `5 >> 1` → `2`                     |
| `>>>`    | Unsigned right shift (zero-fill) | `-5 >>> 1` → Large positive number |

9. **Spread Operator (`...`)**
	- **Purpose**: Expands an array, object, or iterable into individual elements.
	- **Uses**:
	    - **Array expansion**:
		```javascript
		let arr1 = [1, 2];
		let arr2 = [...arr1, 3, 4];
		console.log(arr2); // [1, 2, 3, 4]
		```
	    - **Object merging**:
		```javascript
		let obj1 = { a: 1 };
		let obj2 = { b: 2, ...obj1 };
		console.log(obj2); // { b: 2, a: 1 }
		```

10. **Destructuring Assignment Operators (`{}` and `[]`)**

- **Purpose**: Extract values from arrays or properties from objects into variables.
- **Syntax**:
	**Array destructuring**:
	```javascript
	let [a, b] = [1, 2];
	```
	**Object destructuring**:
	```javascript
	let { key } = { key: "value" };
	```

---

### **Increment (`++`) and Decrement (`--`) Operators**

These operators increase or decrease a variable’s value by `1`. They can be used in **two forms**:

1. **Pre-Increment (`++x`) / Pre-Decrement (`--x`)**: Increments/decrements the value **before** returning it.
2. **Post-Increment (`x++`) / Post-Decrement (`x--`)**: Returns the current value **before** incrementing/decrementing.

**Pre-Increment (`++x`)**

- Increases the value first, then returns the updated value.
- **Example**:
    
    ```javascript
    let x = 5;
    let y = ++x; // x becomes 6, then y is assigned 6
    console.log(x, y); // 6, 6
    ```

**Post-Increment (`x++`)**

- Returns the current value first, then increases the value.
- **Example**:
    
    ```javascript
    let x = 5;
    let y = x++; // y is assigned 5, then x becomes 6
    console.log(x, y); // 6, 5
    ```

**Pre-Decrement (`--x`)**

- Decreases the value first, then returns the updated value.
- **Example**:
    
    ```javascript
    let x = 5;
    let y = --x; // x becomes 4, then y is assigned 4
    console.log(x, y); // 4, 4
    ```

**Post-Decrement (`x--`)**

- Returns the current value first, then decreases the value.
- **Example**:
    
    ```javascript
    let x = 5;
    let y = x--; // y is assigned 5, then x becomes 4
    console.log(x, y); // 4, 5
    ```

---

### **Comma Operator (`,`)**

- **Purpose**: Evaluates multiple expressions and returns the last one.
- **Example**:
    
    ```javascript
    let a = (1, 2, 3);
    console.log(a); // 3
    ```

---

### **Unary Plus (`+`) and Unary Negation (`-`)**

- **Unary Plus (`+`)**: Converts a value to a number.
    
    ```javascript
    console.log(+"5"); // 5 (string converted to number)
    console.log(+true); // 1
    ```
    
- **Unary Negation (`-`)**: Converts a value to a number and negates it.
    
    ```javascript
    console.log(-"5"); // -5
    console.log(-true); // -1
    ```

---

### **Logical Assignment Operators**

These combine logical operations with assignment.

| Operator | Equivalent To  | Example    |
| -------- | -------------- | ---------- |
| `&&=`    | `x && (x = y)` | `x &&= y;` |
| `        |                | =`         |
| `??=`    | `x ?? (x = y)` | `x ??= y;` |

**Example**:
```javascript
let a = null;
a ??= 10;
console.log(a); // 10
```

---

