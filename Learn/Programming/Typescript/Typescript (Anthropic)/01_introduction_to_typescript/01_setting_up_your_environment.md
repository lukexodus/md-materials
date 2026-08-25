## Setting Up Your Environment


### Installing TypeScript

TypeScript can be installed globally or locally in your project. The recommended approach is to install it locally to ensure version consistency across team members.

**Global installation:**

```bash
npm install -g typescript
```

**Local installation (recommended):**

```bash
# Initialize a new npm project if you haven't already
npm init -y
# Install TypeScript as a dev dependency
npm install typescript --save-dev
```

After installation, you can verify it by checking the version:

```bash
# For global installation
tsc --version
# For local installation
npx tsc --version
```

**Key points:**

- Local installation helps maintain consistent TypeScript versions across projects
- TypeScript is available through the Node.js package manager (npm)
- The TypeScript compiler is invoked using the `tsc` command

### Configuring tsconfig.json

The `tsconfig.json` file is central to TypeScript projects. It specifies compiler options and project settings.

To generate a basic configuration file:

```bash
npx tsc --init
```

This creates a well-documented `tsconfig.json` with common options. Here's a typical configuration:

```json
{
  "compilerOptions": {
    "target": "es2016",             /* JavaScript version for output */
    "module": "commonjs",           /* Module system for output JavaScript */
    "rootDir": "./src",             /* Source file directory */
    "outDir": "./dist",             /* Output directory */
    "esModuleInterop": true,        /* Enables import default from non-ES modules */
    "forceConsistentCasingInFileNames": true, /* Ensures consistent file naming */
    "strict": true,                 /* Enable all strict type-checking options */
    "skipLibCheck": true            /* Skip type checking of declaration files */
  },
  "include": ["src/**/*"],          /* Files to include */
  "exclude": ["node_modules"]       /* Files to exclude */
}
```

**Key points:**

- `target`: Specifies the ECMAScript version for output (ES6, ES2020, etc.)
- `module`: Defines the module system (CommonJS, ESNext, etc.)
- `rootDir`/`outDir`: Define source and output directories
- `strict`: Enables comprehensive type checking
- `include`/`exclude`: Control which files are processed

Common configurations:

```json
/* For modern web applications */
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "jsx": "react-jsx",
    "sourceMap": true
  }
}

/* For Node.js applications */
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist"
  }
}
```

### TypeScript with VS Code

Visual Studio Code provides excellent TypeScript support out of the box as it's built with TypeScript.

**Recommended setup:**

1. **Install VS Code Extensions:**
    
    - TypeScript Hero: Organizes imports
    - ESLint: Code quality
    - Prettier: Code formatting
2. **Configure VS Code settings.json**:
    
    ```json
    {
      "typescript.updateImportsOnFileMove.enabled": "always",
      "typescript.preferences.importModuleSpecifier": "relative",
      "typescript.suggest.completeFunctionCalls": true,
      "editor.codeActionsOnSave": {
        "source.organizeImports": true
      },
      "[typescript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "editor.formatOnSave": true
      }
    }
    ```
    
3. **IntelliSense features:**
    
    - Code completion
    - Type information on hover
    - Parameter hints
    - Go to definition
    - Find all references
4. **Debugging TypeScript:**
    
    - Set breakpoints directly in TypeScript files
    - Use the built-in debugger with proper source maps

**Key points:**

- VS Code provides native TypeScript language services
- Extensions can enhance the TypeScript development experience
- Automatic type checking happens in real-time
- Integrated debugging works with source maps

### First TypeScript Program

Let's create a simple TypeScript program to verify our setup.

1. **Create project structure:**
    
    ```
    my-typescript-project/
    ├── src/
    │   └── index.ts
    ├── package.json
    └── tsconfig.json
    ```
    
2. **Add basic TypeScript code in `src/index.ts`:**
    
    ```typescript
    // Define a simple interface
    interface User {
      id: number;
      name: string;
      email: string;
      isActive: boolean;
    }
    
    // Function with typed parameters and return type
    function createUser(name: string, email: string): User {
      const id = Math.floor(Math.random() * 1000);
      return {
        id,
        name,
        email,
        isActive: true
      };
    }
    
    // Use the function with proper types
    const newUser = createUser("John Doe", "john@example.com");
    console.log(`Created user: ${newUser.name} (ID: ${newUser.id})`);
    
    // Intentional type error (uncomment to see error)
    // const invalidUser = createUser(123, "invalid@example.com");
    ```
    
3. **Add scripts to package.json:**
    
    ```json
    {
      "scripts": {
        "build": "tsc",
        "start": "node dist/index.js",
        "dev": "tsc --watch"
      }
    }
    ```
    
4. **Compile and run:**
    
    ```bash
    npm run build   # Compiles TypeScript to JavaScript
    npm start       # Runs the compiled JavaScript
    ```
    

**Example:** Enhanced version with more TypeScript features

```typescript
// Using type aliases and union types
type UserRole = "admin" | "editor" | "viewer";

// Extended interface
interface User {
  id: number;
  name: string;
  email: string;
  isActive: boolean;
  role: UserRole;
  metadata?: Record<string, unknown>; // Optional property with index signature
}

// Class implementation
class UserManager {
  private users: User[] = [];
  
  constructor(initialUsers: User[] = []) {
    this.users = initialUsers;
  }
  
  createUser(name: string, email: string, role: UserRole = "viewer"): User {
    const id = Math.floor(Math.random() * 1000);
    const newUser: User = {
      id,
      name,
      email,
      isActive: true,
      role
    };
    
    this.users.push(newUser);
    return newUser;
  }
  
  getUserById(id: number): User | undefined {
    return this.users.find(user => user.id === id);
  }
  
  getAllUsers(): readonly User[] {
    return [...this.users]; // Return a copy to prevent mutation
  }
}

// Using the class
const userManager = new UserManager();
const admin = userManager.createUser("Admin User", "admin@example.com", "admin");
const editor = userManager.createUser("Editor User", "editor@example.com", "editor");

console.log("Created users:");
console.log(userManager.getAllUsers());
```

**Output:**

```
Created users:
[
  {
    id: 123,
    name: 'Admin User',
    email: 'admin@example.com',
    isActive: true,
    role: 'admin'
  },
  {
    id: 456,
    name: 'Editor User',
    email: 'editor@example.com',
    isActive: true,
    role: 'editor'
  }
]
```

**Conclusion:** Setting up a TypeScript development environment involves installing the TypeScript compiler, configuring your project with tsconfig.json, leveraging IDE features in VS Code, and creating your first program. This foundation allows you to take advantage of TypeScript's static typing, improved tooling, and enhanced developer experience.

### Recommended Next Steps

- Learn TypeScript basic types and type annotations
- Explore TypeScript interfaces and classes
- Understand TypeScript modules and namespaces
- Investigate advanced type features like generics and utility types

---

