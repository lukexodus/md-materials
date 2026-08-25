## Build Performance in TypeScript


### Understanding TypeScript Build Performance

TypeScript provides powerful static type checking and IDE support, but as projects grow, build times can become a bottleneck in the development workflow. Efficient build configuration is essential for maintaining developer productivity in large TypeScript projects.

**Key Points**

- Build performance directly impacts developer productivity
- TypeScript compilation involves several stages: parsing, type checking, transformation, and emitting JavaScript
- Different strategies address different parts of the build pipeline
- Modern TypeScript provides multiple optimization techniques

### TypeScript Compiler Internals

To optimize TypeScript build performance, it's helpful to understand how the TypeScript compiler (tsc) works:

1. **Parsing**: Source files are parsed into an Abstract Syntax Tree (AST)
2. **Type Checking**: The compiler creates a type system representation and validates it
3. **Transformation**: The AST is transformed according to configuration options
4. **Emitting**: JavaScript code, source maps, and declaration files are generated

The most time-consuming phase is typically type checking, especially in projects with complex type relationships.

### Incremental Compilation

Incremental compilation is one of the most effective ways to improve build performance by reusing information from previous compilations.

**Key Points**

- Enabled with the `incremental` flag in tsconfig.json
- Creates a `.tsbuildinfo` file to track dependency graphs and file changes
- Only recompiles files that have changed or are affected by changes
- Can significantly reduce build times in large projects

Enable incremental compilation in your tsconfig.json:

```json
{
  "compilerOptions": {
    "incremental": true,
    "tsBuildInfoFile": "./buildcache/.tsbuildinfo",
    // Other options...
  }
}
```

The `tsBuildInfoFile` option lets you specify where the build information is stored, which is useful for avoiding source control conflicts.

**Example** A project with 500 TypeScript files might take 10-15 seconds for a full build. With incremental compilation, subsequent builds after small changes might take only 1-2 seconds.

### Project References

Project references allow you to structure your TypeScript project into smaller, interconnected subprojects, each with its own tsconfig.json file.

**Key Points**

- Enables better code organization in large codebases
- Allows partial builds of only affected projects
- Enforces logical boundaries between components
- Works well with incremental compilation

Setting up project references involves:

1. Dividing your codebase into logical projects
2. Creating a tsconfig.json for each project
3. Using the `references` array to define dependencies between projects
4. Using the `composite` flag in referenced projects

```typescript
// Root tsconfig.json
{
  "files": [],
  "references": [
    { "path": "./packages/core" },
    { "path": "./packages/utils" },
    { "path": "./packages/api" }
  ]
}

// packages/core/tsconfig.json
{
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src",
    // Other options...
  },
  "include": ["src/**/*"]
}

// packages/api/tsconfig.json
{
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src",
    // Other options...
  },
  "references": [
    { "path": "../core" },
    { "path": "../utils" }
  ],
  "include": ["src/**/*"]
}
```

Building with project references:

```bash
# Build all projects
tsc -b

# Build specific project and dependencies
tsc -b packages/api

# Clean and build
tsc -b --clean packages/api
```

### Optimizing tsconfig.json

Your TypeScript configuration can significantly impact build performance. Here are the most important settings to consider:

**Key Points**

- Include only necessary files
- Use appropriate lib and target settings
- Disable unnecessary type checking options for development builds
- Consider separate configs for development and production

```json
{
  "compilerOptions": {
    // Performance-related options
    "incremental": true,
    "skipLibCheck": true,
    "sourceMap": false,
    "inlineSourceMap": false,

    // Limit type checking scope
    "types": ["node", "jest"],
    "skipDefaultLibCheck": true,
    
    // Essential type checking for development
    "noImplicitAny": true,
    "strictNullChecks": true,
    
    // Disable expensive checks during development
    "strict": false,
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    
    // Output settings
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "node",
    "outDir": "./dist"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.test.ts", "**/*.spec.ts"]
}
```

For production builds, you might want a separate, stricter configuration:

```json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "sourceMap": true
  }
}
```

### Build Caching Strategies

Beyond TypeScript's built-in incremental compilation, you can implement additional caching strategies:

**Key Points**

- Use build tools with caching capabilities
- Implement file-based caching for expensive operations
- Consider distributed caching for CI environments

Example using a build cache with ts-loader in webpack:

```javascript
// webpack.config.js
module.exports = {
  // ...
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: [
          {
            loader: 'ts-loader',
            options: {
              transpileOnly: true, // Skip type checking for faster builds
              experimentalWatchApi: true, // Use filesystem watching
              compilerOptions: {
                // Can override tsconfig options here
              }
            }
          }
        ],
        exclude: /node_modules/
      }
    ]
  },
  // Optional: Use cache for faster rebuilds
  cache: {
    type: 'filesystem',
    buildDependencies: {
      config: [__filename]
    }
  }
};
```

### TypeScript Watch Mode Optimizations

TypeScript's watch mode (`tsc --watch` or `tsc -w`) can be optimized for faster incremental builds during development.

**Key Points**

- Use the `watchOptions` in tsconfig.json to configure watch behavior
- Configure appropriate polling settings based on your development environment
- Optimize filesystem watching to reduce unnecessary rebuilds

```json
{
  "compilerOptions": {
    // Standard options...
  },
  "watchOptions": {
    "watchFile": "useFsEvents",
    "watchDirectory": "useFsEvents",
    "fallbackPolling": "dynamicPriority",
    "synchronousWatchDirectory": true,
    "excludeDirectories": ["**/node_modules", "dist"]
  }
}
```

### Parallelizing TypeScript Builds

For very large projects, parallelizing the build process can lead to significant performance improvements.

**Key Points**

- Project references inherently support parallel builds
- Use thread pools for parallelizing type checking
- Consider worker threads for CPU-intensive operations

Example using fork-ts-checker-webpack-plugin with multiple workers:

```javascript
// webpack.config.js
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin');

module.exports = {
  // ...
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: [
          {
            loader: 'ts-loader',
            options: {
              transpileOnly: true // Skip type checking in loader
            }
          }
        ],
        exclude: /node_modules/
      }
    ]
  },
  plugins: [
    new ForkTsCheckerWebpackPlugin({
      typescript: {
        diagnosticOptions: {
          semantic: true,
          syntactic: true
        },
        mode: 'write-references'
      },
      issue: {
        include: [
          { file: '../src/**/*.{ts,tsx}' }
        ],
        exclude: [
          { file: '**/*.spec.{ts,tsx}' }
        ]
      },
      // Run type checking in multiple processes
      async: true
    })
  ]
};
```

### Transpile-Only Mode

For the fastest possible builds during development, you can use transpile-only mode, which skips type checking entirely.

**Key Points**

- Significantly faster builds at the cost of type safety
- Best used in watch mode with a separate type checking process
- Can be combined with IDE type checking for real-time feedback

Example with ts-node for development:

```json
// package.json
{
  "scripts": {
    "start": "ts-node --transpile-only src/index.ts",
    "type-check": "tsc --noEmit",
    "build": "tsc"
  }
}
```

### Measuring and Profiling Build Performance

To effectively optimize build performance, you need to measure it first:

**Key Points**

- Use TypeScript's `--diagnostics` and `--extendedDiagnostics` flags
- Implement timing hooks in build scripts
- Profile memory usage to identify potential bottlenecks

```bash
# Get basic timing information
tsc --diagnostics

# Get detailed timing for compiler phases
tsc --extendedDiagnostics

# Generate a trace file for analysis
tsc --generateTrace trace_output_dir
```

Custom build timing script:

```typescript
// build-timer.ts
import { execSync } from 'child_process';
import * as fs from 'fs';

const startTime = Date.now();
console.log('Starting TypeScript build...');

try {
  execSync('tsc -p tsconfig.prod.json', { stdio: 'inherit' });
  const endTime = Date.now();
  const duration = (endTime - startTime) / 1000;
  
  console.log(`Build completed in ${duration.toFixed(2)} seconds`);
  
  // Append to build history
  fs.appendFileSync(
    'build-times.log',
    `${new Date().toISOString()},${duration.toFixed(2)}\n`
  );
} catch (error) {
  console.error('Build failed:', error);
  process.exit(1);
}
```

### Type-Checking in CI Pipelines

Continuous Integration (CI) pipelines can become bottlenecked by TypeScript compilation. Here are strategies to improve CI performance:

**Key Points**

- Cache TypeScript compilation artifacts between CI runs
- Run type checking in parallel with other CI tasks
- Use project references for partial builds in monorepos

Example GitHub Actions workflow with caching:

```yaml
name: TypeScript Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    
    - name: Use Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        
    - name: Cache node modules
      uses: actions/cache@v3
      with:
        path: ~/.npm
        key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
        restore-keys: |
          ${{ runner.os }}-node-
          
    - name: Cache TypeScript incremental build
      uses: actions/cache@v3
      with:
        path: '**/buildcache'
        key: ${{ runner.os }}-tsbuild-${{ github.sha }}
        restore-keys: |
          ${{ runner.os }}-tsbuild-
          
    - name: Install dependencies
      run: npm ci
      
    - name: Build TypeScript
      run: npm run build
```

### Optimizing TypeScript in Monorepos

Monorepos present unique challenges for TypeScript build performance due to their size and interdependencies.

**Key Points**

- Leverage project references for clear dependency boundaries
- Use Nx, Rush, or Turborepo for intelligent caching and task orchestration
- Implement workspace-aware TypeScript configurations

Example using Nx for optimized TypeScript builds:

```typescript
// nx.json
{
  "npmScope": "my-org",
  "tasksRunnerOptions": {
    "default": {
      "runner": "@nrwl/nx-cloud",
      "options": {
        "cacheableOperations": ["build", "test", "lint"],
        "accessToken": "your-access-token"
      }
    }
  },
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"]
    }
  }
}

// workspace.json
{
  "version": 2,
  "projects": {
    "core": {
      "root": "packages/core",
      "sourceRoot": "packages/core/src",
      "projectType": "library",
      "targets": {
        "build": {
          "executor": "@nrwl/js:tsc",
          "outputs": ["{options.outputPath}"],
          "options": {
            "outputPath": "dist/packages/core",
            "tsConfig": "packages/core/tsconfig.lib.json",
            "packageJson": "packages/core/package.json",
            "main": "packages/core/src/index.ts"
          }
        }
      }
    },
    "api": {
      "root": "packages/api",
      "sourceRoot": "packages/api/src",
      "projectType": "application",
      "targets": {
        "build": {
          "executor": "@nrwl/node:webpack",
          "outputs": ["{options.outputPath}"],
          "options": {
            "outputPath": "dist/packages/api",
            "tsConfig": "packages/api/tsconfig.app.json",
            "main": "packages/api/src/main.ts"
          }
        }
      }
    }
  }
}
```

### Real-World Examples

Let's look at some real-world examples of TypeScript build performance optimizations:

**Example 1: Microsoft VS Code** VS Code is a large TypeScript codebase with over 300,000 lines of TypeScript code.

Build optimization techniques:

- Heavy use of project references
- Custom task orchestration
- Targeted incremental builds
- Separate configurations for different build purposes

**Example 2: Angular Framework** Angular uses a complex TypeScript build system to manage its monorepo structure.

Build optimization techniques:

- Bazel build system for fine-grained caching
- Custom TypeScript transformers
- Selective compilation based on affected files
- Parallelized type checking and transpilation

### Advanced Build Optimizations

For projects that have exhausted standard optimizations, consider these advanced techniques:

**Key Points**

- Custom TypeScript transformers for specialized code generation
- Language Service plugins for project-specific optimizations
- Targeted type checking with type-checking guard files

Example of a custom TypeScript transformer:

```typescript
// custom-transformer.ts
import * as ts from 'typescript';

export default function transformer(program: ts.Program): ts.TransformerFactory<ts.SourceFile> {
  return (context: ts.TransformationContext) => {
    return (sourceFile: ts.SourceFile) => {
      // Only transform specific files
      if (!sourceFile.fileName.includes('/src/')) {
        return sourceFile;
      }
      
      const visitor = (node: ts.Node): ts.Node => {
        // Example: Replace certain patterns for optimization
        if (ts.isCallExpression(node) && 
            ts.isPropertyAccessExpression(node.expression) &&
            node.expression.name.text === 'debugLog') {
          // Remove debug logs in production builds
          return ts.factory.createEmptyStatement();
        }
        
        return ts.visitEachChild(node, visitor, context);
      };
      
      return ts.visitNode(sourceFile, visitor);
    };
  };
}
```

Using the custom transformer with ts-loader:

```javascript
// webpack.config.js
const customTransformer = require('./custom-transformer').default;

module.exports = {
  // ...
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: [
          {
            loader: 'ts-loader',
            options: {
              getCustomTransformers: program => ({
                before: [customTransformer(program)]
              })
            }
          }
        ]
      }
    ]
  }
};
```

### Conclusion

Optimizing TypeScript build performance is essential for maintaining developer productivity in large projects. By implementing incremental compilation, project references, and optimized tsconfig settings, most projects can achieve significant build time improvements. For more complex scenarios, advanced techniques like custom transformers and specialized build tools can provide additional optimizations.

The key is to match your optimization strategy to your specific project needs and development workflow, focusing on the areas that will provide the greatest benefit.

### Related Topics

- TypeScript bundlers (esbuild, swc, Vite) for faster development experience
- Migrating from tsc to faster TypeScript compilers
- Advanced TypeScript project architecture
- Memory optimization for TypeScript compiler
- TypeScript build visualization tools

---

