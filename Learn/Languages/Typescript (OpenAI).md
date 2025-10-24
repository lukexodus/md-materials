## TypeScript Mastery Syllabus  

### **Introduction to TypeScript**  
- What is TypeScript?  
- Benefits of TypeScript over JavaScript  
- Installing and setting up TypeScript  
- Compiling TypeScript to JavaScript  
- Configuring `tsconfig.json`  
- Running TypeScript with Node.js  

### **TypeScript Basics**  
- Type Annotations (`string`, `number`, `boolean`, `null`, `undefined`)  
- Type Inference and Type Checking  
- `let`, `const`, and variable scoping  
- Functions and Return Types  
- Type Aliases  
- Union and Intersection Types  

### **Advanced Types**  
- Tuples and Named Tuples  
- Enums (`numeric`, `string`, `heterogeneous`)  
- Literal Types (`string literals`, `numeric literals`, `boolean literals`)  
- Mapped Types  
- Conditional Types  
- Utility Types (`Partial`, `Required`, `Readonly`, `Record`, `Pick`, `Omit`, `Exclude`, `Extract`)  
- Template Literal Types  
- Type Assertions and `as` keyword  

### **Object-Oriented TypeScript**  
- Interfaces and Type Contracts  
- Implementing Interfaces  
- Readonly Properties  
- Index Signatures  
- Classes (`public`, `private`, `protected` access modifiers)  
- Abstract Classes  
- Inheritance and Method Overriding  
- Static Properties and Methods  
- Getters and Setters  

### **Functions and Functional Programming**  
- Function Overloading  
- Optional and Default Parameters  
- Rest Parameters  
- Arrow Functions and Lexical Scope  
- Function Types and Call Signatures  
- Higher-Order Functions  
- Generic Functions  

### **Generics in TypeScript**  
- Introduction to Generics  
- Generic Functions  
- Generic Classes  
- Generic Constraints  
- Using `extends` in Generics  
- Keyof Type Operator  
- Generic Utility Types  
- Infer Keyword in Generics  

### **Modules and Namespaces**  
- ES Modules vs. TypeScript Modules  
- Import and Export (`default`, `named`, `namespace`)  
- Re-exporting Modules  
- Dynamic Imports  
- Namespaces and `namespace` keyword  
- Using `declare module`  

### **TypeScript with JavaScript Ecosystem**  
- TypeScript with Node.js  
- Using TypeScript with Express.js  
- Integrating TypeScript with Frontend Frameworks (`React`, `Vue`, `Angular`)  
- TypeScript with Webpack and Babel  
- TypeScript in a Monorepo Setup  
- Using TypeScript with GraphQL  

### **TypeScript and Asynchronous Programming**  
- Promises and `async/await`  
- Handling Errors in Async Code  
- Using TypeScript with Fetch API  
- Working with WebSockets  
- RxJS and Observables  

### **Error Handling and Debugging**  
- TypeScript Compiler Errors (`TS` errors)  
- Common TypeScript Runtime Errors  
- Using `strict` Mode  
- Debugging TypeScript in VS Code  
- TypeScript with ESLint and Prettier  

### **TypeScript and Testing**  
- Unit Testing TypeScript Code  
- TypeScript with Jest  
- Type Assertions in Testing  
- TypeScript with Mocha and Chai  
- Mocking in TypeScript Tests  

### **TypeScript and Design Patterns**  
- Singleton Pattern  
- Factory Pattern  
- Dependency Injection in TypeScript  
- Decorators (`class decorators`, `method decorators`, `parameter decorators`)  
- Observer Pattern  
- Repository Pattern  

### **Working with Third-Party Libraries**  
- Using DefinitelyTyped (`@types` packages)  
- Writing Custom Type Definitions  
- Extending and Augmenting Types  
- Handling `any` and `unknown` Types  

### **Optimizing and Scaling TypeScript Projects**  
- Performance Considerations in TypeScript  
- Large-Scale TypeScript Project Structure  
- Advanced `tsconfig.json` Configuration  
- Strict Mode and Best Practices  
- Enforcing Type Safety in Large Projects  

### **Advanced TypeScript Concepts**  
- Type Guards (`typeof`, `instanceof`, `in` operator)  
- Discriminated Unions  
- Recursive Types  
- Branded Types  
- Variance in TypeScript (`covariance`, `contravariance`)  
- TypeScript Compiler Internals  

### **Real-World Projects and Applications**  
- Building a REST API with TypeScript and Express  
- Developing a Full-Stack App with TypeScript, React, and Node.js  
- TypeScript with Serverless (AWS Lambda, Firebase Functions)  
- Creating a Type-Safe GraphQL API with TypeScript  
- Developing a CLI Tool with TypeScript  

### **Keeping Up with TypeScript**  
- Understanding TypeScript Release Cycles  
- Following TypeScript Roadmap and Community Discussions  
- Best TypeScript Resources (`blogs`, `docs`, `videos`, `books`)  
- Contributing to Open-Source TypeScript Projects  

---

# Introduction

## TypeScript  

### **What is TypeScript?**  
TypeScript is a **strongly typed, object-oriented, compiled superset of JavaScript** developed by Microsoft. It extends JavaScript by adding static types, enabling better tooling, and improving maintainability. TypeScript code is transpiled into plain JavaScript, making it compatible with all JavaScript environments, including browsers and Node.js.  

### **Key Features of TypeScript**  
- **Static Typing** – Helps catch errors at compile time rather than runtime.  
- **Type Inference** – Automatically infers types without explicit annotations.  
- **Interfaces** – Defines the structure of objects for better code organization.  
- **Generics** – Enables reusable, type-safe components and functions.  
- **Advanced Object-Oriented Features** – Supports `classes`, `inheritance`, `access modifiers`, `abstract classes`, and `interfaces`.  
- **ESNext Features** – Includes support for modern JavaScript features before they are widely adopted.  
- **Enhanced Tooling** – Works seamlessly with IDEs, providing better autocompletion, refactoring, and debugging.  

### **Why Use TypeScript Over JavaScript?**  
| Feature            | JavaScript | TypeScript |
|--------------------|-----------|-----------|
| Static Typing     | ❌ No    | ✅ Yes  |
| Type Inference    | ❌ Limited | ✅ Strong |
| Code Scalability  | ❌ Harder in large projects | ✅ Easier with types & interfaces |
| Tooling & Debugging | ❌ Less IDE support | ✅ Enhanced autocomplete & error checking |
| Object-Oriented Support | ✅ Limited | ✅ Full support |

### **How TypeScript Works**  
1. **Write TypeScript Code**  
   ```typescript
   function greet(name: string): string {
       return "Hello, " + name;
   }
   ```
2. **Compile to JavaScript**  
   Run `tsc filename.ts` to generate `filename.js`.  
3. **Run the JavaScript Output**  
   ```js
   function greet(name) {
       return "Hello, " + name;
   }
   ```

**Conclusion**  
TypeScript enhances JavaScript by providing type safety, improved tooling, and better maintainability, making it an excellent choice for modern web and backend development.

---

## Installing and Setting Up TypeScript  

### **Prerequisites**  
Before installing TypeScript, ensure that you have the following:  
- **Node.js** (required for package management)  
- **npm (Node Package Manager)** (comes with Node.js)  
- **A code editor** (VS Code is highly recommended for TypeScript)  

### **Installing TypeScript**  
You can install TypeScript globally or locally in a project.  

#### **1. Installing TypeScript Globally**  
To use TypeScript across all projects, install it globally using npm:  
```sh
npm install -g typescript
```  
After installation, verify the installation by checking the TypeScript version:  
```sh
tsc --version
```  

#### **2. Installing TypeScript Locally in a Project**  
For project-specific installations (recommended for team projects):  
```sh
npm install --save-dev typescript
```  
This will add TypeScript to your project’s `node_modules` and save it as a development dependency.  

### **Setting Up TypeScript in a Project**  

#### **1. Initializing a TypeScript Project**  
Run the following command in your project directory to create a `tsconfig.json` file:  
```sh
npx tsc --init
```  
This generates a `tsconfig.json` file, which controls the TypeScript compiler's behavior.  

#### **2. Understanding `tsconfig.json` (Basic Settings)**  
Some key configurations:  
```json
{
  "compilerOptions": {
    "target": "ES6", 
    "module": "CommonJS", 
    "strict": true, 
    "outDir": "./dist", 
    "rootDir": "./src"
  }
}
```  
- `"target"`: Specifies the ECMAScript version to compile into.  
- `"module"`: Defines the module system (e.g., `CommonJS` for Node.js, `ESNext` for modern browsers).  
- `"strict"`: Enables strict type checking.  
- `"outDir"`: Specifies the folder where compiled JavaScript files will be saved.  
- `"rootDir"`: Specifies the folder where TypeScript source files are located.  

#### **3. Writing and Compiling TypeScript Code**  
- Create a `src` folder and add a TypeScript file (`index.ts`):  
  ```typescript
  const message: string = "Hello, TypeScript!";
  console.log(message);
  ```
- Compile the TypeScript code:  
  ```sh
  npx tsc
  ```
- The compiled JavaScript file (`index.js`) appears in the `dist` folder (as configured).  
- Run the output file with Node.js:  
  ```sh
  node dist/index.js
  ```

### **Using TypeScript with VS Code**  
- Install the **TypeScript Extension** (comes built-in with VS Code).  
- Enable auto-compilation by adding a `watch` flag:  
  ```sh
  npx tsc --watch
  ```  
  This automatically recompiles files when changes are made.  

**Conclusion**  
Setting up TypeScript is straightforward and provides better code management. Using `tsconfig.json` helps configure the compiler for different project needs.

---

## Compiling TypeScript to JavaScript  

### **How TypeScript Compilation Works**  
TypeScript is a **transpiled language**, meaning it must be converted to JavaScript before execution. The TypeScript Compiler (`tsc`) takes `.ts` files as input and outputs `.js` files.  

### **Basic Compilation**  
#### **1. Compiling a Single File**  
Run the following command to compile a single TypeScript file (`index.ts`):  
```sh
tsc index.ts
```  
This generates an `index.js` file in the same directory.  

#### **2. Compiling Multiple Files**  
To compile all TypeScript files in a project:  
```sh
tsc
```  
This compiles all `.ts` files according to the settings in `tsconfig.json`.  

### **Configuring Compilation with `tsconfig.json`**  
A `tsconfig.json` file allows for project-wide settings for TypeScript compilation.  

#### **1. Generating `tsconfig.json`**  
Run:  
```sh
npx tsc --init
```  
This creates a default `tsconfig.json` file.  

#### **2. Key Compilation Options**  
Modify `tsconfig.json` to customize compilation behavior:  
```json
{
  "compilerOptions": {
    "target": "ES6", 
    "module": "CommonJS", 
    "strict": true, 
    "outDir": "./dist", 
    "rootDir": "./src",
    "sourceMap": true
  }
}
```  
- `"target"`: Specifies the ECMAScript version for the output (`ES6`, `ES5`, `ESNext`).  
- `"module"`: Defines the module system (`CommonJS`, `ESNext`, `AMD`).  
- `"strict"`: Enables strict type checking.  
- `"outDir"`: Directory where compiled JavaScript files will be stored.  
- `"rootDir"`: Directory where TypeScript source files are located.  
- `"sourceMap"`: Generates `.map` files for debugging in browsers.  

### **Compiling with Output Directory**  
If `tsconfig.json` has `"outDir": "./dist"`, compile with:  
```sh
tsc
```  
All compiled files will be placed inside the `dist/` folder.  

### **Automatic Compilation with Watch Mode**  
To automatically recompile TypeScript files when they change:  
```sh
tsc --watch
```  

### **Compiling TypeScript for Different JavaScript Versions**  
To compile to different ECMAScript versions:  
```sh
tsc --target ES5 index.ts
```  
This generates JavaScript compatible with older browsers.  

**Conclusion**  
The TypeScript compiler (`tsc`) provides flexible compilation options, allowing control over output format, strictness, and module compatibility. Using `tsconfig.json` simplifies project-wide settings.

---

## Configuring `tsconfig.json`  

### **What is `tsconfig.json`?**  
The `tsconfig.json` file is a configuration file for TypeScript projects. It defines how the TypeScript compiler (`tsc`) should behave when compiling TypeScript code into JavaScript.  

### **Generating `tsconfig.json`**  
To create a `tsconfig.json` file in your project, run:  
```sh
npx tsc --init
```  
This generates a default `tsconfig.json` file with several options.  

### **Key Sections in `tsconfig.json`**  
The file consists of multiple configuration options, categorized into:  
1. **Compiler Options** – Controls how TypeScript compiles code.  
2. **Files and Include/Exclude Options** – Specifies which files to compile.  
3. **Type Checking Options** – Enables/disables strict type checking.  

---

### **1. Compiler Options (`compilerOptions`)**  
These settings control how TypeScript compiles `.ts` files into `.js` files.  

#### **Basic Compiler Options**  
```json
{
  "compilerOptions": {
    "target": "ES6",
    "module": "CommonJS",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true
  }
}
```  
- `"target"`: Defines the ECMAScript version for output (`ES5`, `ES6`, `ESNext`).  
- `"module"`: Specifies the module system (`CommonJS`, `ES6`, `ESNext`, `AMD`).  
- `"outDir"`: Specifies where the compiled JavaScript files will be placed.  
- `"rootDir"`: Specifies the directory containing TypeScript source files.  
- `"strict"`: Enables strict type checking.  

#### **Advanced Compiler Options**  
```json
{
  "compilerOptions": {
    "sourceMap": true,
    "declaration": true,
    "removeComments": true,
    "noImplicitAny": true,
    "allowJs": true
  }
}
```  
- `"sourceMap"`: Generates `.map` files for easier debugging.  
- `"declaration"`: Generates `.d.ts` declaration files for TypeScript libraries.  
- `"removeComments"`: Removes comments from the compiled JavaScript.  
- `"noImplicitAny"`: Disallows implicit `any` type (ensures explicit typing).  
- `"allowJs"`: Allows compiling JavaScript files inside the project.  

---

### **2. Including & Excluding Files**  
You can specify which files TypeScript should include or ignore.  

#### **Including Specific Files**  
```json
{
  "include": ["src/**/*.ts"]
}
```  
This ensures that only TypeScript files inside the `src/` folder are compiled.  

#### **Excluding Files**  
```json
{
  "exclude": ["node_modules", "dist"]
}
```  
This prevents TypeScript from compiling files inside `node_modules` and `dist`.  

#### **Manually Specifying Files to Compile**  
```json
{
  "files": ["src/index.ts", "src/utils.ts"]
}
```  
This compiles only the specified files.  

---

### **3. Strict Type Checking Options**  
For better type safety, enable these options:  
```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictPropertyInitialization": true
  }
}
```  
- `"noImplicitAny"`: Ensures that variables without types are not implicitly assigned `any`.  
- `"strictNullChecks"`: Prevents `null` and `undefined` from being assigned to non-nullable types.  
- `"strictFunctionTypes"`: Ensures function parameters match expected types.  
- `"strictPropertyInitialization"`: Ensures class properties are initialized properly.  

---

### **4. Module Resolution & Aliases**  
TypeScript allows aliasing paths to simplify imports.  

#### **Enabling Path Aliases**  
```json
{
  "compilerOptions": {
    "baseUrl": "./",
    "paths": {
      "@models/*": ["src/models/*"],
      "@utils/*": ["src/utils/*"]
    }
  }
}
```  
Now, instead of:  
```typescript
import User from "../../models/User";
```  
You can write:  
```typescript
import User from "@models/User";
```

---

### **5. Enabling Watch Mode**  
To automatically compile files when they change, run:  
```sh
tsc --watch
```  
Or add this in `tsconfig.json`:  
```json
{
  "watch": true
}
```  

---

### **6. Extending `tsconfig.json`**  
To share common configurations across projects, use `"extends"`:  
```json
{
  "extends": "./tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist"
  }
}
```  

---

**Conclusion**  
The `tsconfig.json` file provides extensive control over how TypeScript compiles and checks code. Configuring it properly enhances maintainability, scalability, and debugging capabilities in TypeScript projects.

---

## Running TypeScript with Node.js  

### **Overview**  
Since Node.js only understands JavaScript, TypeScript files (`.ts`) must be compiled to JavaScript before execution. There are multiple ways to run TypeScript with Node.js, including manual compilation, using `ts-node`, and integrating with frameworks like `nodemon` for automatic compilation.  

---

### **1. Manually Compiling and Running TypeScript Files**  
#### **Step 1: Install TypeScript (if not installed)**  
```sh
npm install -g typescript
```
#### **Step 2: Create a TypeScript File (`index.ts`)**  
```typescript
const message: string = "Hello, TypeScript with Node.js!";
console.log(message);
```
#### **Step 3: Compile TypeScript to JavaScript**  
```sh
tsc index.ts
```
This generates an `index.js` file in the same directory.

#### **Step 4: Run the Compiled JavaScript File with Node.js**  
```sh
node index.js
```

---

### **2. Running TypeScript Directly with `ts-node` (Without Manual Compilation)**  
#### **Step 1: Install `ts-node` and TypeScript Locally**  
```sh
npm install -D ts-node typescript
```
#### **Step 2: Run TypeScript Code Directly**  
```sh
npx ts-node index.ts
```
This eliminates the need for manual compilation.

---

### **3. Using `nodemon` for Automatic Reloading**  
By default, Node.js does not watch for changes in TypeScript files. Using `nodemon` allows automatic reloading.  

#### **Step 1: Install `nodemon` and `ts-node`**  
```sh
npm install -D nodemon ts-node
```
#### **Step 2: Create a `nodemon.json` File (Optional but Recommended)**  
```json
{
  "watch": ["src"],
  "ext": "ts",
  "exec": "ts-node ./src/index.ts"
}
```
#### **Step 3: Run `nodemon`**  
```sh
npx nodemon
```
Now, changes in `.ts` files will trigger automatic reloading.

---

### **4. Running TypeScript with ES Modules in Node.js**  
By default, Node.js does not support ES modules (`import/export`) in `.ts` files.  

#### **Option 1: Enable ES Modules in `tsconfig.json`**  
Modify `tsconfig.json`:  
```json
{
  "compilerOptions": {
    "module": "ESNext",
    "moduleResolution": "Node",
    "target": "ES6"
  }
}
```
Now you can use:  
```typescript
import fs from "fs";
console.log(fs);
```
Run with:  
```sh
npx ts-node --loader ts-node/esm index.ts
```

#### **Option 2: Use `--loader ts-node/esm` Flag**  
Run TypeScript with ES modules:  
```sh
node --loader ts-node/esm index.ts
```

---

### **5. Running TypeScript as a Node.js Server (Express Example)**  
TypeScript is often used with frameworks like Express.js.  

#### **Step 1: Install Dependencies**  
```sh
npm install express
npm install -D @types/express ts-node nodemon
```
#### **Step 2: Create `server.ts`**  
```typescript
import express from "express";

const app = express();
const PORT = 3000;

app.get("/", (req, res) => {
  res.send("Hello, TypeScript with Express!");
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
```
#### **Step 3: Run the Server with `ts-node`**  
```sh
npx ts-node server.ts
```
Or use `nodemon` for automatic reloading:  
```sh
npx nodemon server.ts
```

---

**Conclusion**  
Running TypeScript with Node.js can be done manually via `tsc`, or more efficiently with `ts-node` and `nodemon`. ES module support can be enabled through `tsconfig.json` or the `--loader` flag.

---

