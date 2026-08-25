## Declaration Files


### Understanding .d.ts Files

**Key Points**

- Declaration files (.d.ts) contain type information without implementation
- They define types for JavaScript libraries and external code
- Declaration files use a special syntax with `declare` keywords
- They allow TypeScript to understand code written in JavaScript

Declaration files (with the .d.ts extension) provide type information to TypeScript without including implementation details. These files are central to TypeScript's ability to work with existing JavaScript libraries:

```typescript
// Example of what might be in a declaration file
// No implementation, just type declarations
declare function calculateDistance(x1: number, y1: number, x2: number, y2: number): number;

declare const PI: number;

declare class Point {
  x: number;
  y: number;
  constructor(x: number, y: number);
  distanceTo(other: Point): number;
}

declare namespace Geometry {
  interface Rectangle {
    width: number;
    height: number;
    area(): number;
  }
  
  function createRectangle(width: number, height: number): Rectangle;
}
```

Declaration files can be generated automatically or written manually:

1. **Automatically Generated**
    
    - When compiling TypeScript with `declaration: true` in tsconfig.json
    - When using tools like `dts-gen` or `tsc --declaration`
2. **Manually Written**
    
    - For third-party libraries without existing type definitions
    - For global variables, functions, or objects

Common locations for declaration files:

```
├── node_modules/
│   └── @types/            // DefinitelyTyped declarations
│       └── lodash/
│           └── index.d.ts
├── src/
│   ├── types/             // Project-specific declarations
│   │   └── custom.d.ts
│   └── global.d.ts        // Global declarations for the project
└── tsconfig.json
```

TypeScript looks for declaration files in several places:

1. Alongside JavaScript files (same name with .d.ts extension)
2. In the `@types` directory in node_modules
3. In paths configured in the `typeRoots` and `types` options in tsconfig.json
4. In locations specified by the `/// <reference path="..." />` directive

The three main types of declaration files:

1. **Global declarations** - Add types to the global scope
    
    ```typescript
    // global.d.ts
    declare const API_KEY: string;
    declare function logError(message: string): void;
    ```
    
2. **Module declarations** - Declare types for imported modules
    
    ```typescript
    // jquery.d.ts
    declare module 'jquery' {
      function $(selector: string): any;
      // ... other jQuery definitions
      export = $;
    }
    ```
    
3. **Ambient module declarations** - Declare the existence of modules without specifying details
    
    ```typescript
    // modules.d.ts
    declare module 'some-untyped-module';
    ```
    

### Writing Declaration Files

**Key Points**

- Use `declare` keywords for ambient declarations
- Namespaces help organize related declarations
- Export statements define module exports
- Interface merging allows extending existing types

When writing declaration files, there are several important patterns to understand:

#### Global Variables and Functions:

```typescript
// For global variables
declare const VERSION: string;
declare let debugMode: boolean;

// For global functions
declare function log(message: string): void;
declare function ajax(url: string, options: AjaxOptions): Promise<any>;

// For global classes
declare class User {
  id: number;
  name: string;
  constructor(id: number, name: string);
  getFullName(): string;
}

// For global interfaces
interface AjaxOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
  headers?: Record<string, string>;
  data?: any;
  timeout?: number;
}
```

#### Namespaces (used for organizing):

```typescript
// Use namespaces to group related declarations
declare namespace API {
  function get(url: string): Promise<any>;
  function post(url: string, data: any): Promise<any>;
  
  interface Response<T> {
    data: T;
    status: number;
    headers: Record<string, string>;
  }
  
  namespace Auth {
    function login(username: string, password: string): Promise<string>;
    function logout(): Promise<void>;
  }
}

// Usage in TypeScript files:
// API.get('/users');
// API.Auth.login('user', 'pass');
```

#### Module Declarations:

```typescript
// For npm packages or ES modules
declare module 'my-library' {
  export function doSomething(): void;
  export class Helper {
    process(data: any): any;
  }
  export interface Options {
    debug?: boolean;
    timeout?: number;
  }
  
  // Default export
  export default function main(): void;
}

// Usage:
// import main, { doSomething, Helper } from 'my-library';
```

#### Module Augmentation:

```typescript
// Extending an existing module
declare module 'express' {
  interface Request {
    user?: {
      id: string;
      name: string;
      roles: string[];
    };
  }
}

// This allows you to use req.user safely when working with Express
```

#### Special Declarations:

```typescript
// For CSS/SCSS/Less modules
declare module '*.css' {
  const content: { [className: string]: string };
  export default content;
}

declare module '*.scss' {
  const content: { [className: string]: string };
  export default content;
}

// For images or other assets
declare module '*.png' {
  const value: string;
  export default value;
}

declare module '*.svg' {
  const content: React.FC<React.SVGProps<SVGSVGElement>>;
  export default content;
}

// For JSON files
declare module '*.json' {
  const value: any;
  export default value;
}
```

#### Declaration File for a Complex Library:

```typescript
// jquery.d.ts
declare namespace $ {
  function ajax(settings: JQueryAjaxSettings): JQueryXHR;
  
  interface JQueryAjaxSettings {
    url?: string;
    method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
    data?: any;
    dataType?: string;
    success?: (data: any, textStatus: string, jqXHR: JQueryXHR) => void;
    error?: (jqXHR: JQueryXHR, textStatus: string, errorThrown: string) => void;
  }
  
  interface JQueryXHR extends XMLHttpRequest {
    responseJSON?: any;
  }
  
  function get(url: string, success?: (data: any) => void): JQueryXHR;
  function post(url: string, data?: any, success?: (data: any) => void): JQueryXHR;
}

// Support both global variable and module
declare const jQuery: typeof $;
declare module 'jquery' {
  export = jQuery;
}
```

### Using DefinitelyTyped

**Key Points**

- DefinitelyTyped (@types) is a repository of declaration files for thousands of JavaScript libraries
- Most popular libraries have type definitions available via npm/@types
- Installation is simple with npm/yarn
- It's community-maintained with regular updates

DefinitelyTyped is a centralized repository that hosts TypeScript declaration files for thousands of JavaScript libraries. These declarations are published to npm under the `@types` scope:

#### Installing Type Definitions:

```bash
# Basic syntax
npm install --save-dev @types/library-name

# Examples
npm install --save-dev @types/react
npm install --save-dev @types/lodash
npm install --save-dev @types/express
```

Once installed, TypeScript automatically finds and uses these type definitions. No import is needed for the type definitions themselves (just import the library normally).

#### Finding Available Type Definitions:

1. Search the npm registry: [https://www.npmjs.com/search?q=%40types](https://www.npmjs.com/search?q=%40types)
2. Browse the DefinitelyTyped GitHub repository: [https://github.com/DefinitelyTyped/DefinitelyTyped](https://github.com/DefinitelyTyped/DefinitelyTyped)
3. Use the TypeSearch tool: [https://microsoft.github.io/TypeSearch/](https://microsoft.github.io/TypeSearch/)

#### Understanding Type Versions:

Type packages often have versioning that corresponds to the library version they support:

```bash
# For React 16.x
npm install --save-dev @types/react@16

# For a specific version
npm install --save-dev @types/react@16.9.34
```

#### Configuration in tsconfig.json:

```json
{
  "compilerOptions": {
    // Include all @types packages from node_modules/@types
    "typeRoots": ["./node_modules/@types", "./src/types"],
    
    // Only include specific @types packages
    "types": ["node", "jest", "express"]
  }
}
```

- `typeRoots`: Specifies directories where TypeScript looks for type definitions
- `types`: Limits which packages from `@types` are included

#### Contributing to DefinitelyTyped:

If you find a library without type definitions or discover issues with existing definitions:

1. Fork the DefinitelyTyped repository
2. Add or fix type definitions following the contribution guidelines
3. Submit a pull request

The basic structure for a new DefinitelyTyped package:

```
types/library-name/
├── index.d.ts            // Main declaration file
├── library-name-tests.ts // Test file showing usage
├── tsconfig.json         // Configuration for this specific package
├── tslint.json           // Linting rules
└── v1/                   // Optional directory for older versions
    └── index.d.ts
```

### Declaration Merging

**Key Points**

- Declaration merging combines multiple declarations with the same name
- Interfaces automatically merge when declared multiple times
- Namespaces can be merged to add new members
- Modules can be augmented to add new exports
- Classes can be merged with namespaces for static members

TypeScript's declaration merging allows multiple separate declarations with the same name to be combined into a single definition. This is one of TypeScript's most powerful features:

#### Interface Merging:

```typescript
// Original interface in a library
interface User {
  id: number;
  name: string;
}

// In your code, extend the interface
interface User {
  email: string;
  isActive: boolean;
}

// TypeScript merges these into:
// interface User {
//   id: number;
//   name: string;
//   email: string;
//   isActive: boolean;
// }

// Usage with all properties available
const user: User = {
  id: 1,
  name: "John",
  email: "john@example.com",
  isActive: true
};
```

When merging interfaces, later interfaces with the same property name must have a compatible type:

```typescript
interface Box {
  height: number;
  width: number;
}

interface Box {
  scale: number;
  // height: string; // Error: Subsequent property declarations must have the same type
}
```

Function overloads in interfaces are merged in declaration order:

```typescript
interface Document {
  createElement(tagName: string): Element;
}

interface Document {
  createElement(tagName: 'div'): HTMLDivElement;
  createElement(tagName: 'span'): HTMLSpanElement;
  createElement(tagName: 'canvas'): HTMLCanvasElement;
}

// Merged in order (specific overloads come before general ones)
```

#### Namespace Merging:

```typescript
// Original namespace
namespace Validation {
  export interface StringValidator {
    isValid(s: string): boolean;
  }
}

// Extended namespace
namespace Validation {
  export class RegexValidator implements StringValidator {
    constructor(private regex: RegExp) {}
    
    isValid(s: string): boolean {
      return this.regex.test(s);
    }
  }
}

// Additional extension
namespace Validation {
  export const emailRegex = /^[^@]+@[^@]+\.[^@]+$/;
  export const phoneRegex = /^\d{10}$/;
}

// Usage with all merged members
const emailValidator = new Validation.RegexValidator(Validation.emailRegex);
const isValid = emailValidator.isValid("user@example.com");
```

Non-exported members remain private to each namespace declaration.

#### Merging Namespaces with Classes:

```typescript
// Define a class
class Album {
  label: Album.AlbumLabel;
  
  constructor(public title: string, label: string) {
    this.label = new Album.AlbumLabel(label);
  }
}

// Augment with a namespace for static members/nested types
namespace Album {
  export class AlbumLabel {
    constructor(public label: string) {}
  }
  
  export function create(title: string, label: string): Album {
    return new Album(title, label);
  }
}

// Usage
const album = Album.create("Blue Train", "Blue Note");
console.log(album.label.label); // "Blue Note"
```

This pattern is often used to add static members to classes.

#### Merging Namespaces with Functions:

```typescript
// Define a function
function formatDate(date: Date): string {
  return date.toISOString();
}

// Augment with a namespace
namespace formatDate {
  export const defaultFormat = "YYYY-MM-DD";
  
  export function format(date: Date, format: string): string {
    // Implementation
    return "formatted date";
  }
}

// Usage
formatDate(new Date()); // Call the function
formatDate.format(new Date(), formatDate.defaultFormat); // Access namespace members
```

This pattern is used in many libraries like jQuery, where `$` is both a function and contains properties/methods.

#### Merging Namespaces with Enums:

```typescript
// Define an enum
enum Color {
  Red = "#FF0000",
  Green = "#00FF00",
  Blue = "#0000FF"
}

// Augment with a namespace
namespace Color {
  export function mix(c1: Color, c2: Color): Color {
    // Implementation
    return Color.Red;
  }
  
  export function isLight(color: Color): boolean {
    // Implementation
    return true;
  }
}

// Usage
const mixedColor = Color.mix(Color.Red, Color.Blue);
const isLight = Color.isLight(Color.Green);
```

#### Module Augmentation:

```typescript
// Original library export (e.g., in node_modules/some-lib/index.d.ts)
declare module "some-lib" {
  export function method1(): void;
  export interface Options {
    debug: boolean;
  }
}

// Augmenting in your code
declare module "some-lib" {
  // Add new function export
  export function method2(): void;
  
  // Extend existing interface
  export interface Options {
    timeout: number;
  }
}

// Usage
import { method1, method2, Options } from "some-lib";

const options: Options = {
  debug: true,
  timeout: 3000
};
```

This is commonly used to add types to third-party modules or extend existing ones.

#### Global Augmentation:

```typescript
// Original global declarations
interface Window {
  title: string;
}

// Augmenting the global scope
declare global {
  interface Window {
    analytics: {
      track(event: string, properties?: object): void;
      identify(userId: string, traits?: object): void;
    };
  }
  
  interface Array<T> {
    toCSV(): string;
  }
}

// Usage
window.analytics.track("Page View");

const items = [1, 2, 3];
const csv = items.toCSV();
```

Global augmentation must be inside a module (file with imports/exports).

**Conclusion**

TypeScript declaration files are essential for working with JavaScript libraries in a type-safe manner. They provide the bridge between untyped JavaScript code and TypeScript's static type system. Understanding how to read, write, and work with declaration files unlocks TypeScript's full potential in various scenarios:

1. **Using existing libraries**: By leveraging DefinitelyTyped and its extensive collection of type definitions, you can use thousands of JavaScript libraries with full TypeScript support.
    
2. **Extending types**: Through declaration merging, you can extend or customize existing type definitions to better match your usage patterns or add missing functionality.
    
3. **Creating custom libraries**: When developing libraries meant to be consumed by others, declaration files ensure that users get proper type information and IDE support.
    
4. **Working with untyped code**: For legacy code or libraries without types, writing your own declaration files enables gradual adoption of TypeScript without rewriting everything.
    

The flexibility of declaration files—from global definitions to module augmentation—makes TypeScript adaptable to virtually any JavaScript ecosystem. Whether you're working with modern ES modules, CommonJS libraries, or global browser scripts, declaration files provide the type safety and tooling support that make TypeScript development productive and robust.

---

