## TypeScript Namespaces


### Creating Namespaces

Namespaces in TypeScript provide a way to logically group related code, preventing name collisions and organizing your code structure. They create a scope for identifiers, helping avoid global namespace pollution.

**Key Points**

- Namespaces are declared using the `namespace` keyword
- They can contain classes, interfaces, functions, variables, and other namespaces
- Elements inside namespaces need to be explicitly exported to be accessible outside
- Namespaces generate JavaScript objects that contain the exported members

```typescript
namespace Validation {
  // Export makes this interface available outside the namespace
  export interface StringValidator {
    isValid(s: string): boolean;
  }
  
  // Not exported - only accessible within the namespace
  const lettersRegexp = /^[A-Za-z]+$/;
  
  // Exported class implementation
  export class LettersValidator implements StringValidator {
    isValid(s: string): boolean {
      return lettersRegexp.test(s);
    }
  }
  
  // Another exported class
  export class ZipCodeValidator implements StringValidator {
    isValid(s: string): boolean {
      return /^\d{5}(-\d{4})?$/.test(s);
    }
  }
}

// Using the namespace members
let validator: Validation.StringValidator = new Validation.LettersValidator();
console.log(validator.isValid("Hello")); // true
```

### Compiled JavaScript Output

When TypeScript namespaces are compiled to JavaScript, they become JavaScript objects or functions with properties.

**Key Points**

- The namespace becomes an IIFE (Immediately Invoked Function Expression) in JavaScript
- Exported members become properties of the namespace object
- Non-exported members remain private

**Example**

```typescript
// TypeScript namespace
namespace Geometry {
  export interface Point {
    x: number;
    y: number;
  }
  
  export class Circle {
    constructor(public center: Point, public radius: number) {}
    
    area(): number {
      return Math.PI * this.radius * this.radius;
    }
  }
}

// Compiled JavaScript (simplified)
var Geometry;
(function (Geometry) {
  var Circle = /** @class */ (function () {
    function Circle(center, radius) {
      this.center = center;
      this.radius = radius;
    }
    Circle.prototype.area = function () {
      return Math.PI * this.radius * this.radius;
    };
    return Circle;
  }());
  Geometry.Circle = Circle;
})(Geometry || (Geometry = {}));
```

### Nested Namespaces

TypeScript allows nesting namespaces within other namespaces, creating hierarchical organizations for complex applications.

**Key Points**

- Namespaces can be nested to any depth
- Each level needs its own export to be accessible
- Nested namespaces help organize related functionality into logical groups
- Accessing deeply nested elements requires dot notation through the hierarchy

```typescript
namespace Application {
  export namespace UI {
    export namespace Components {
      export class Button {
        constructor(public text: string, public action: () => void) {}
        
        render(): string {
          return `<button>${this.text}</button>`;
        }
      }
      
      export class Input {
        constructor(public placeholder: string) {}
        
        render(): string {
          return `<input placeholder="${this.placeholder}" />`;
        }
      }
    }
    
    export namespace Utilities {
      export function createElement(tag: string, content: string): string {
        return `<${tag}>${content}</${tag}>`;
      }
    }
  }
  
  export namespace Services {
    export class DataService {
      getData(): any {
        return { message: "Data loaded" };
      }
    }
  }
}

// Using nested namespace members
const button = new Application.UI.Components.Button("Click me", () => console.log("Clicked"));
console.log(button.render()); // "<button>Click me</button>"

const element = Application.UI.Utilities.createElement("div", "Hello, world!");
console.log(element); // "<div>Hello, world!</div>"
```

### Namespace Aliases

To simplify working with long namespace paths, TypeScript provides import aliases for namespaces.

**Key Points**

- Use the `import` keyword to create namespace aliases
- Aliases make code more readable and maintainable
- They don't create new objects, just alternative names

```typescript
namespace Shapes {
  export namespace TwoDimensional {
    export class Circle {
      constructor(public radius: number) {}
      
      area(): number {
        return Math.PI * this.radius * this.radius;
      }
    }
    
    export class Rectangle {
      constructor(public width: number, public height: number) {}
      
      area(): number {
        return this.width * this.height;
      }
    }
  }
}

// Without alias - long namespace path
const circle1 = new Shapes.TwoDimensional.Circle(5);

// With alias - shorter, more readable
import Circle = Shapes.TwoDimensional.Circle;
import Rectangle = Shapes.TwoDimensional.Rectangle;

const circle2 = new Circle(5);
const rectangle = new Rectangle(10, 20);

console.log(circle2.area()); // 78.54...
console.log(rectangle.area()); // 200
```

### Multi-File Namespaces

Namespaces can span multiple files, allowing modular development while maintaining logical grouping.

**Key Points**

- Declaration merging combines namespaces with the same name
- Use reference tags or module bundling to ensure all parts are included
- Compilation order matters for correct output

File: `validators.ts`

```typescript
namespace Validation {
  export interface StringValidator {
    isValid(s: string): boolean;
  }
}
```

File: `letters-validator.ts`

```typescript
/// <reference path="validators.ts" />
namespace Validation {
  const lettersRegexp = /^[A-Za-z]+$/;
  
  export class LettersValidator implements StringValidator {
    isValid(s: string): boolean {
      return lettersRegexp.test(s);
    }
  }
}
```

File: `zipcode-validator.ts`

```typescript
/// <reference path="validators.ts" />
namespace Validation {
  const zipCodeRegexp = /^\d{5}(-\d{4})?$/;
  
  export class ZipCodeValidator implements StringValidator {
    isValid(s: string): boolean {
      return zipCodeRegexp.test(s);
    }
  }
}
```

File: `app.ts`

```typescript
/// <reference path="validators.ts" />
/// <reference path="letters-validator.ts" />
/// <reference path="zipcode-validator.ts" />

// Some samples to validate
let strings = ["Hello", "98052", "101"];

// Validators to use
let validators: { [s: string]: Validation.StringValidator } = {};
validators["Letters"] = new Validation.LettersValidator();
validators["ZIP"] = new Validation.ZipCodeValidator();

// Show validation results
strings.forEach(s => {
  for (let name in validators) {
    console.log(`"${s}" - ${validators[name].isValid(s) ? "Matches" : "Does not match"} ${name}`);
  }
});
```

### Namespace Imports

TypeScript allows importing entire namespaces using the `import` syntax, providing an alternative to reference tags.

**Key Points**

- `import` can load an entire namespace from a module
- This is different from ES module imports
- Useful for legacy code integration

```typescript
// In Node.js environment with CommonJS
import * as Validation from "./validation";

let validators: { [s: string]: Validation.StringValidator } = {};
validators["Letters"] = new Validation.LettersValidator();
validators["ZIP"] = new Validation.ZipCodeValidator();
```

### Ambient Namespaces

Ambient namespaces declare the shape of libraries or modules without providing implementations.

**Key Points**

- Used in declaration files (.d.ts)
- Describe the structure of existing JavaScript code
- Typically used for third-party libraries without TypeScript definitions

```typescript
// In a .d.ts file
declare namespace JQuery {
  function ajax(settings: JQueryAjaxSettings): JQueryXHR;
  
  interface JQueryAjaxSettings {
    url?: string;
    method?: string;
    data?: any;
    dataType?: string;
  }
  
  interface JQueryXHR {
    statusText: string;
    responseText: string;
    done(callback: Function): JQueryXHR;
    fail(callback: Function): JQueryXHR;
  }
}

// Usage in TypeScript file
JQuery.ajax({
  url: "https://api.example.com/data",
  method: "GET",
  dataType: "json"
}).done(function(data) {
  console.log("Success:", data);
});
```

### Re-exporting Namespace Members

Namespaces can re-export members from other namespaces to create customized public APIs.

**Key Points**

- Useful for creating facade patterns
- Helps control what is exposed to consumers
- Simplifies interface for complex namespaces

```typescript
namespace Utilities {
  export namespace Math {
    export function add(x: number, y: number): number { return x + y; }
    export function subtract(x: number, y: number): number { return x - y; }
    export function multiply(x: number, y: number): number { return x * y; }
    export function divide(x: number, y: number): number { return x / y; }
  }
  
  export namespace Strings {
    export function capitalize(s: string): string {
      return s.charAt(0).toUpperCase() + s.slice(1);
    }
    
    export function reverse(s: string): string {
      return s.split("").reverse().join("");
    }
  }
}

// Re-export specific members to create a simplified API
namespace App {
  // Re-export only specific functions
  export import add = Utilities.Math.add;
  export import capitalize = Utilities.Strings.capitalize;
  
  // Add app-specific functions
  export function formatName(firstName: string, lastName: string): string {
    return `${capitalize(firstName)} ${lastName.toUpperCase()}`;
  }
}

// Usage
console.log(App.add(10, 20)); // 30
console.log(App.capitalize("hello")); // "Hello"
console.log(App.formatName("john", "doe")); // "John DOE"
```

### When to Use Modules vs. Namespaces

TypeScript offers both namespaces and ES modules, each with different use cases and benefits.

**Key Points**

- Modules (ES modules) are the preferred approach for modern TypeScript applications
- Namespaces are primarily for legacy code and specific organizational needs

#### Use Modules When:

- Building applications for modern JavaScript environments
- Working with bundlers like Webpack, Rollup, or Parcel
- Need for true encapsulation and dependency management
- Working on larger projects with complex dependencies
- Using modern frameworks like React, Angular, or Vue
- Tree-shaking (dead code elimination) is important
- Targeting ECMAScript 2015 (ES6) or higher

```typescript
// math.ts - ES Module
export function add(x: number, y: number): number {
  return x + y;
}

export function subtract(x: number, y: number): number {
  return x - y;
}

// app.ts - ES Module import
import { add, subtract } from './math';

console.log(add(10, 5)); // 15
```

#### Use Namespaces When:

- Working with legacy TypeScript code
- Organizing a script-based application (no module bundler)
- Creating a library that needs to work in non-module environments
- Adding type declarations to existing JavaScript
- Developing for environments that don't support ES modules
- Need to merge declarations across multiple files

```typescript
// Using namespaces for script-based approach
namespace MathUtils {
  export function add(x: number, y: number): number {
    return x + y;
  }
  
  export function subtract(x: number, y: number): number {
    return x - y;
  }
}

// Usage directly in global scope
console.log(MathUtils.add(10, 5)); // 15
```

### Namespace Patterns and Best Practices

Regardless of whether you choose namespaces or modules, certain patterns help improve code organization.

**Key Points**

- Avoid deeply nested namespaces (more than 2-3 levels)
- Export only what's necessary
- Use consistent naming conventions
- Consider barrels for simplified imports

#### Barrel Pattern with Namespaces

```typescript
// components/button.ts
namespace UI.Components {
  export class Button {
    // Implementation
  }
}

// components/input.ts
namespace UI.Components {
  export class Input {
    // Implementation
  }
}

// components/index.ts (barrel)
/// <reference path="button.ts" />
/// <reference path="input.ts" />

namespace UI {
  // Re-export everything from Components
  export import Components = UI.Components;
}

// Usage
/// <reference path="components/index.ts" />
let button = new UI.Components.Button();
```

### Converting Between Namespaces and Modules

As projects evolve, you may need to convert between namespaces and modules.

**Key Points**

- Namespaces can be converted to modules by changing syntax and file structure
- Move namespace members to dedicated files as ES modules
- Update import/export syntax

#### From Namespace:

```typescript
// Before: app.ts with namespace
namespace Validation {
  export interface StringValidator {
    isValid(s: string): boolean;
  }
  
  export class LettersValidator implements StringValidator {
    isValid(s: string): boolean {
      return /^[A-Za-z]+$/.test(s);
    }
  }
}
```

#### To Modules:

```typescript
// After: types.ts
export interface StringValidator {
  isValid(s: string): boolean;
}

// After: letters-validator.ts
import { StringValidator } from './types';

export class LettersValidator implements StringValidator {
  isValid(s: string): boolean {
    return /^[A-Za-z]+$/.test(s);
  }
}
```

### Combining Namespaces and Modules

In some cases, you might need to use both namespaces and modules together during migration or when integrating with different code styles.

**Key Points**

- Export namespaces from modules for a hybrid approach
- Useful during incremental migration
- Can help when interfacing with legacy code

```typescript
// validators.ts - Module that exports a namespace
export namespace Validators {
  export interface StringValidator {
    isValid(s: string): boolean;
  }
  
  export class LettersValidator implements StringValidator {
    isValid(s: string): boolean {
      return /^[A-Za-z]+$/.test(s);
    }
  }
  
  export class ZipCodeValidator implements StringValidator {
    isValid(s: string): boolean {
      return /^\d{5}(-\d{4})?$/.test(s);
    }
  }
}

// app.ts
import { Validators } from './validators';

let letterValidator = new Validators.LettersValidator();
console.log(letterValidator.isValid("Hello")); // true
```

### Global Augmentation with Namespaces

TypeScript allows augmenting the global scope using namespaces, which can be useful for adding declarations to built-in objects.

**Key Points**

- Use `declare global` inside a module
- Useful for adding methods to built-in types
- Should be used sparingly to avoid polluting global scope

```typescript
// extensions.ts - Module file
export {};  // Ensure this is treated as a module

declare global {
  interface String {
    capitalize(): string;
    reverse(): string;
  }
  
  interface Array<T> {
    first(): T | undefined;
    last(): T | undefined;
  }
}

// Implement the extensions
String.prototype.capitalize = function(): string {
  return this.charAt(0).toUpperCase() + this.slice(1);
};

String.prototype.reverse = function(): string {
  return this.split("").reverse().join("");
};

Array.prototype.first = function<T>(): T | undefined {
  return this.length > 0 ? this[0] : undefined;
};

Array.prototype.last = function<T>(): T | undefined {
  return this.length > 0 ? this[this.length - 1] : undefined;
};

// Usage in another file
import './extensions';

console.log("hello".capitalize()); // "Hello"
console.log([1, 2, 3].last()); // 3
```

---

