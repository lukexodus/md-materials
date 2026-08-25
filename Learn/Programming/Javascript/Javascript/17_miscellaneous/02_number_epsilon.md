## `Number.EPSILON`


`Number.EPSILON` is a **smallest interval between two representable numbers** in JavaScript. It’s the difference between 1 and the next representable number **greater than 1** using 64-bit floating-point precision (IEEE 754 standard).

---

**Key Points**

- **Value:**  
  ```javascript
  Number.EPSILON === 2.220446049250313e-16
  ```

- **Purpose:**  
  To compare floating-point numbers for **"closeness"** rather than equality, since direct comparisons may fail due to rounding errors.

---

### **Why It Matters: Floating-Point Precision**

```javascript
0.1 + 0.2 === 0.3   // false
```

Due to binary floating-point rounding, the sum is **not exactly 0.3**.

---

### **Safe Comparison Using EPSILON**

```javascript
function nearlyEqual(a, b, epsilon = Number.EPSILON) {
  return Math.abs(a - b) < epsilon;
}

nearlyEqual(0.1 + 0.2, 0.3); // true
```

---

**Analogy**

Think of `Number.EPSILON` as the **finest scale on a ruler** that JavaScript can reliably measure. If two numbers are closer than this scale, they are **functionally equal** even if not bit-for-bit equal.

---

**Conclusion**

Use `Number.EPSILON`:
- To compare decimal values for **precision-safe equality**
- To write robust numerical code involving floating-point arithmetic

---

