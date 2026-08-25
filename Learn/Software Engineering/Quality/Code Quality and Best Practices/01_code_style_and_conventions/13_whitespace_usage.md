## Whitespace usage


Whitespace usage refers to the strategic insertion of empty space (horizontal and vertical) to separate logical units of code. It acts as the punctuation of code, governing density and rhythm.

**Key Points**

- **Vertical Whitespace (Blank Lines):**
    
    - **Logical Separation:** Use blank lines to separate the "Arrange," "Act," and "Assert" phases in tests, or distinct steps in a function.
        
    - **Method Separation:** distinct definitions (classes, functions) should be separated by one or two blank lines.
        
- **Horizontal Whitespace:**
    
    - **Operators:** Surround binary operators (`=`, `+`, `==`) with spaces.
        
    - **Keywords:** Place a space after control flow keywords (`if`, `for`, `while`) before the opening parenthesis.
        
    - **Delimiters:** Place a space after commas in argument lists.
        
- **Trailing Whitespace:** Lines should not contain invisible spaces at the end. These cause unnecessary merge conflicts and git diff noise. Most editors can be configured to "Trim Trailing Whitespace on Save."
    

**Formatting Rules**

- **Block Opening:** One space before the opening brace `{`.
    
- **Parentheses:** Generally, no spaces inside parentheses `(arg)`, though some standards (like jQuery or specific React props) may differ.
    
- **Chains:** No space around the dot operator `.` in method calls.
    

**Example**

_Poor Whitespace:_

JavaScript

```
const x=y+z;if(x>10){doSomething(x,y);}
```

_Proper Whitespace:_

JavaScript

```
const x = y + z;

if (x > 10) {
  doSomething(x, y);
}
```

