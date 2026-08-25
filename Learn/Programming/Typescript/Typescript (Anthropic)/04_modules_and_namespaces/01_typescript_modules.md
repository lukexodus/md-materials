## TypeScript Modules


### Introduction to TypeScript Modules

TypeScript modules provide a way to organize code by splitting it into separate files, each exporting declarations that can be imported by other modules. TypeScript fully supports the ES Modules standard, while also maintaining compatibility with CommonJS and other module systems. This modular approach helps manage complex applications by promoting code reusability, encapsulation, and maintainability.

### Import and Export Syntax

TypeScript offers a variety of ways to import and export code between modules, giving you flexibility in how you structure your application.

**Basic Exports**

```typescript
// math.ts
export const PI = 3.14159;

export function add(a: number, b: number): number {
  return a + b;
}

export function subtract(a: number, b: number): number {
  return a - b;
}

export class Calculator {
  multiply(a: number, b: number): number {
    return a * b;
  }
}
```

**Basic Imports**

```typescript
// app.ts
import { PI, add, subtract, Calculator } from './math';

console.log(PI);  // 3.14159
console.log(add(1, 2));  // 3

const calc = new Calculator();
console.log(calc.multiply(2, 3));  // 6
```

**Namespace Imports**

```typescript
// app.ts
import * as Math from './math';

console.log(Math.PI);  // 3.14159
console.log(Math.add(1, 2));  // 3

const calc = new Math.Calculator();
console.log(calc.multiply(2, 3));  // 6
```

**Re-exports**

```typescript
// index.ts
export { add, subtract } from './math';
export { default as Logger } from './logger';

// This makes the index.ts file act as a "barrel" export
```

**Export Statements**

```typescript
// user.ts
function validateEmail(email: string): boolean {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
}

class User {
  constructor(public name: string, public email: string) {}
  
  isValidEmail(): boolean {
    return validateEmail(this.email);
  }
}

// Export list
export { User, validateEmail };
```

**Export with Renaming**

```typescript
// utils.ts
function formatDate(date: Date): string {
  return date.toISOString().split('T')[0];
}

// Export with a different name
export { formatDate as formatDateISOString };

// Import with a different name
import { formatDateISOString as formatDate } from './utils';
```

### Default and Named Exports

TypeScript supports both default exports and named exports, giving you options for how modules expose their functionality.

**Default Exports**

Each module can have one default export, which is often used for the main class, function, or object that the module provides:

```typescript
// logger.ts
export default class Logger {
  log(message: string): void {
    console.log(`[LOG]: ${message}`);
  }
  
  error(message: string): void {
    console.error(`[ERROR]: ${message}`);
  }
}

// Alternatively, declare first then export
class Logger {
  // ... same as above
}

export default Logger;
```

**Importing Default Exports**

```typescript
// app.ts
import Logger from './logger';

const logger = new Logger();
logger.log('Application started');
```

**Combining Default and Named Exports**

```typescript
// api.ts
export const API_URL = 'https://api.example.com';

export function get(endpoint: string): Promise<any> {
  return fetch(`${API_URL}/${endpoint}`).then(res => res.json());
}

// Default export
export default class ApiClient {
  baseUrl: string;
  
  constructor(baseUrl: string = API_URL) {
    this.baseUrl = baseUrl;
  }
  
  async request(endpoint: string): Promise<any> {
    return fetch(`${this.baseUrl}/${endpoint}`).then(res => res.json());
  }
}
```

**Importing Both Default and Named Exports**

```typescript
// app.ts
import ApiClient, { API_URL, get } from './api';

console.log(API_URL);  // https://api.example.com
get('users').then(users => console.log(users));

const client = new ApiClient();
client.request('posts').then(posts => console.log(posts));
```

**Type-Only Imports and Exports**

TypeScript 3.8+ allows you to import and export types explicitly, which helps with tree-shaking and avoiding runtime dependencies:

```typescript
// types.ts
export interface User {
  id: number;
  name: string;
  email: string;
}

export type UserRole = 'admin' | 'user' | 'guest';

// app.ts
import type { User, UserRole } from './types';

const currentUser: User = {
  id: 1,
  name: 'John',
  email: 'john@example.com'
};

const role: UserRole = 'admin';
```

### Module Resolution Strategies

TypeScript offers multiple strategies for resolving module imports, which determine how the compiler looks for imported modules.

**Classic Resolution**

The original TypeScript resolution strategy that mimics how Node.js resolves modules:

```json
// tsconfig.json
{
  "compilerOptions": {
    "moduleResolution": "Classic"
  }
}
```

**Node Resolution**

The recommended strategy that replicates Node.js module resolution behavior:

```json
// tsconfig.json
{
  "compilerOptions": {
    "moduleResolution": "Node"
  }
}
```

With Node resolution, TypeScript will search for modules in the following order:

1. Look for a `.ts`, `.tsx`, or `.d.ts` file with the exact name
2. Look for an `index.ts`, `index.tsx`, or `index.d.ts` in a directory with the name
3. Look for a `package.json` with a `types` or `typings` field
4. Look for a `package.json` with a `main` field

**Node16/NodeNext Resolution**

For projects using Node.js's ESM support:

```json
// tsconfig.json
{
  "compilerOptions": {
    "module": "NodeNext",
    "moduleResolution": "NodeNext"
  }
}
```

This mode adds support for:

- Package exports and imports
- Import assertions
- Detection of whether `.js` files are CommonJS or ESM based on package.json

**Bundler Resolution**

Introduced in TypeScript 5.0 for bundlers like Webpack, Vite, esbuild, etc.:

```json
// tsconfig.json
{
  "compilerOptions": {
    "moduleResolution": "Bundler"
  }
}
```

This strategy helps TypeScript understand bundler-specific behaviors and optimizations.

**Module Resolution Examples**

Consider this import statement:

```typescript
import { something } from './utils';
```

With Node resolution, TypeScript will look for:

1. `./utils.ts`
2. `./utils.tsx`
3. `./utils.d.ts`
4. `./utils/index.ts`
5. `./utils/index.tsx`
6. `./utils/index.d.ts`
7. `./utils/package.json` (`types` or `main` field)

**Non-Relative Imports**

For non-relative imports like:

```typescript
import { useState } from 'react';
```

TypeScript will search in:

1. `node_modules/react` looking for types
2. `@types/react` for declaration files
3. Up the directory tree if not found in the current `node_modules`

### Path Mapping

Path mapping allows you to configure custom module paths in your TypeScript project, enabling shorter imports and more flexible project structures.

**Basic Path Mapping**

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@app/*": ["src/app/*"],
      "@core/*": ["src/core/*"],
      "@shared/*": ["src/shared/*"],
      "@environment": ["src/environments/environment"]
    }
  }
}
```

With these path mappings, you can import like this:

```typescript
// Instead of relative paths like "../../../../shared/models/user"
import { User } from '@shared/models/user';
import { environment } from '@environment';
import { AuthService } from '@core/services/auth.service';
```

**Base URL Configuration**

The `baseUrl` option changes the base directory for resolving non-relative module names:

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": "./src"
  }
}
```

This allows you to import from the `src` directory without relative paths:

```typescript
// Instead of "../../../models/user"
import { User } from 'models/user';
```

**Mapping for Libraries and Type Definitions**

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "lodash/*": ["node_modules/lodash-es/*"],
      "jquery": ["node_modules/jquery/dist/jquery"]
    }
  }
}
```

**Advanced Path Mapping Patterns**

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      // Map exact module name
      "crypto": ["src/crypto/index.ts"],
      
      // Map all files under a directory
      "lib/*": ["src/lib/*"],
      
      // Fallback paths (try first path, then second)
      "utils/*": ["src/utils/modern/*", "src/utils/legacy/*"],
      
      // Map a module name to multiple files
      "jquery": [
        "node_modules/jquery/dist/jquery.slim.min.js",
        "node_modules/jquery/dist/jquery.min.js"
      ]
    }
  }
}
```

**Path Mapping with Barrel Files**

A common pattern is to use "barrel" files (index.ts) that re-export components from a directory:

```typescript
// src/components/index.ts
export * from './Button';
export * from './Input';
export * from './Card';
export * from './Modal';

// Usage with path mapping
// tsconfig.json: "@components": ["src/components"]
import { Button, Input, Card } from '@components';
```

### Working with Different Module Systems

TypeScript can emit code for different module systems based on your project needs.

**Module Configuration**

```json
// tsconfig.json
{
  "compilerOptions": {
    "module": "ESNext", // Options: CommonJS, AMD, UMD, ESNext, etc.
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true
  }
}
```

**CommonJS Interoperability**

The `esModuleInterop` flag helps with CommonJS modules that don't properly conform to ES module specifications:

```typescript
// Without esModuleInterop
import * as React from 'react';

// With esModuleInterop
import React from 'react';
```

### Dynamic Imports

TypeScript supports dynamic imports for code splitting and lazy loading:

```typescript
// Normal static import
import { UserService } from './services/user.service';

// Dynamic import (returns a promise)
async function loadAdminModule() {
  const adminModule = await import('./admin/admin.module');
  return new adminModule.AdminModule();
}

// Type-safe dynamic imports
type AdminModuleType = typeof import('./admin/admin.module');
let modulePromise: Promise<AdminModuleType>;

function loadAdminFeatures() {
  if (!modulePromise) {
    modulePromise = import('./admin/admin.module');
  }
  return modulePromise.then(m => new m.AdminModule());
}
```

### Ambient Modules

Ambient modules declare the types for modules that may not have TypeScript declarations.

**Creating Declaration Files**

```typescript
// types/untyped-module/index.d.ts
declare module 'untyped-module' {
  export function doSomething(value: string): number;
  export const VERSION: string;
  export default class MainClass {
    constructor(options: { debug: boolean });
    process(data: any): void;
  }
}

// Now you can import it with type safety
import MainClass, { doSomething, VERSION } from 'untyped-module';
```

**Wildcard Module Declarations**

```typescript
// types/image-modules.d.ts
declare module '*.png' {
  const content: string;
  export default content;
}

declare module '*.json' {
  const content: any;
  export default content;
}

// Usage
import logoUrl from './assets/logo.png';
import configData from './config.json';
```

### Module Augmentation

TypeScript allows you to extend existing modules with new functionality:

```typescript
// original-module.ts
export interface User {
  id: number;
  name: string;
}

// augmentation.ts
import { User } from './original-module';

// Augment the original module
declare module './original-module' {
  interface User {
    email: string;
    role: string;
  }
  
  export function validateUser(user: User): boolean;
}

// Implementation of the augmented function
export function validateUser(user: User): boolean {
  return !!user.email && !!user.role;
}

// usage.ts
import { User } from './original-module';
import './augmentation'; // Important: must import the augmentation

const user: User = {
  id: 1,
  name: 'John',
  email: 'john@example.com', // Now valid because of augmentation
  role: 'admin'              // Now valid because of augmentation
};
```

### Best Practices for TypeScript Modules

**Organize by Feature**

Structure modules around features or domains rather than technical concerns:

```
/src
  /users
    /components
      user-list.component.ts
      user-detail.component.ts
    /services
      user.service.ts
    /models
      user.model.ts
    users.module.ts
  /products
    ...
```

**Use Barrel Files Strategically**

Barrel files simplify imports but can cause circular dependencies if overused:

```typescript
// features/user/index.ts
export * from './user.model';
export * from './user.service';
export * from './user-list.component';

// Import everything from one location
import { User, UserService, UserListComponent } from './features/user';
```

**Avoid Side Effects in Module Imports**

Keep module imports free from side effects:

```typescript
// BAD: Side effects during import
import './polyfills'; // runs code immediately

// GOOD: Explicit side effect execution
import { setupPolyfills } from './polyfills';
setupPolyfills();
```

**Use Type-Only Imports When Possible**

```typescript
// Only import types, not implementation
import type { User, UserRole } from './models';

// Instead of
import { User, UserRole } from './models';
```

**Use Consistent Naming Conventions**

```typescript
// model.ts for interfaces, types
export interface User {...}
export type UserRole = 'admin' | 'user';

// service.ts for services
export class UserService {...}

// utils.ts for utility functions
export function formatDate(date: Date): string {...}
```

**Module Resolution Configuration Check**

Verify your module resolution settings match your project's needs:

```json
// tsconfig.json for modern web app
{
  "compilerOptions": {
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "baseUrl": "src",
    "paths": {
      "@app/*": ["app/*"],
      "@core/*": ["core/*"],
      "@shared/*": ["shared/*"]
    }
  }
}
```

### Common Module Patterns

**API Module Pattern**

```typescript
// api/users.api.ts
import { httpClient } from '@core/http';
import type { User, CreateUserDto } from '@app/models';

export const usersApi = {
  getAll: (): Promise<User[]> => 
    httpClient.get('/users'),
  
  getById: (id: number): Promise<User> => 
    httpClient.get(`/users/${id}`),
  
  create: (user: CreateUserDto): Promise<User> => 
    httpClient.post('/users', user)
};

// Usage
import { usersApi } from '@app/api/users.api';
const users = await usersApi.getAll();
```

**Services Pattern**

```typescript
// services/auth.service.ts
import { User } from '@app/models';
import { usersApi } from '@app/api';

export class AuthService {
  private currentUser: User | null = null;
  
  async login(username: string, password: string): Promise<User> {
    // Implementation
    return {} as User;
  }
  
  logout(): void {
    this.currentUser = null;
  }
  
  getCurrentUser(): User | null {
    return this.currentUser;
  }
}

export const authService = new AuthService();

// Usage
import { authService } from '@app/services';
await authService.login('user', 'pass');
```

**Feature Module Pattern**

```typescript
// feature-module.ts
export interface FeatureConfig {
  enabled: boolean;
  apiEndpoint: string;
}

export class FeatureModule {
  constructor(private config: FeatureConfig) {}
  
  initialize(): void {
    // Setup code
  }
  
  // Feature specific methods
}

// Re-export from index.ts
export * from './feature-module';
export * from './feature-components';
export * from './feature-services';
```

**Recommended Related Topics**

- TypeScript Project Configuration
- TypeScript Declaration Files (.d.ts)
- Webpack and TypeScript Integration
- ESLint Configuration for TypeScript Projects
- TypeScript in Monorepo Architectures

---

