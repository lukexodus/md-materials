## Debugging TypeScript


### Introduction to TypeScript Debugging

Debugging TypeScript applications requires understanding both the TypeScript compilation process and the runtime behavior of the resulting JavaScript. TypeScript's static type system helps prevent many bugs during development, but runtime debugging is still essential for resolving complex issues, understanding application flow, and optimizing performance. Effective debugging tools and strategies can significantly speed up development and improve code quality.

### Source Maps

Source maps are files that map compiled JavaScript code back to the original TypeScript source, enabling you to debug TypeScript directly even though the browser or Node.js is running JavaScript.

**How Source Maps Work**

Source maps create a relationship between:

1. The compiled JavaScript files that run in the browser/Node.js
2. The original TypeScript source files you wrote

This mapping allows debuggers to show you the TypeScript code instead of the transpiled JavaScript, making debugging much more intuitive.

**Generating Source Maps**

Enable source maps in your `tsconfig.json`:

```json
{
  "compilerOptions": {
    "sourceMap": true,
    // For better debugging experience with inline source maps:
    // "inlineSourceMap": true,
    "inlineSources": true
  }
}
```

For production, you might want to disable source maps or use a different configuration:

```json
{
  "compilerOptions": {
    "sourceMap": false,
    // Or for production builds with protected but debuggable source:
    // "sourceMap": true,
    // "inlineSources": false
  }
}
```

**Source Map Configuration Options**

- `sourceMap`: Generates separate `.js.map` files
- `inlineSourceMap`: Embeds source map information in the JavaScript files
- `inlineSources`: Includes the original TypeScript code within the source map
- `mapRoot`: Specifies the location where debuggers should find map files
- `sourceRoot`: Specifies the location where debuggers should find the TypeScript files

**Webpack Source Map Configuration**

If you're using Webpack, you can configure the quality and type of source maps:

```javascript
// webpack.config.js
module.exports = {
  mode: 'development',
  devtool: 'source-map', // or 'cheap-module-source-map' for faster builds
  // For production:
  // devtool: 'hidden-source-map', // creates source maps but doesn't reference them
};
```

Common `devtool` options for TypeScript projects:

- `source-map`: Full source maps (separate files)
- `eval-source-map`: Faster rebuilds, good for development
- `cheap-module-source-map`: Faster builds, less detailed
- `hidden-source-map`: Generates source maps but doesn't reference them in the bundle (good for error reporting in production)

**Verifying Source Maps**

To verify source maps are working:

1. Open your browser developer tools
2. Navigate to the Sources panel (Chrome) or Debugger panel (Firefox)
3. Look for a "webpack://" or similar section containing your TypeScript files
4. Set a breakpoint in a TypeScript file and confirm it works when that code executes

**Common Source Map Issues**

1. **404 Errors for map files**: Check file paths and ensure your server is configured to serve `.map` files
2. **Incorrect source locations**: Verify your `sourceRoot` and `mapRoot` settings
3. **Seeing JavaScript instead of TypeScript**: Make sure source maps are enabled in the browser devtools
4. **Source maps not updated**: Clear browser cache or use cache-busting techniques

**Protecting Source Maps in Production**

For production environments, consider:

1. **Not publishing source maps publicly**: Configure your server to restrict access
2. **Using hidden source maps**: Generate them but don't reference them in your JS files
3. **Generating source maps only for error tracking**: Use tools like Sentry that can process source maps securely

### Debugging in VS Code

Visual Studio Code offers excellent integrated debugging support for TypeScript in both browser and Node.js environments.

**Setting Up VS Code for TypeScript Debugging**

1. Install the necessary extensions:
    
    - JavaScript Debugger (built into VS Code)
    - Debugger for Chrome (for browser debugging)
2. Create a `launch.json` configuration file:
    
    - Click the Debug icon in the sidebar
    - Click "create a launch.json file"
    - Select the environment (Node.js or Chrome)

**Debugging Node.js TypeScript Applications**

Basic `launch.json` configuration for Node.js:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug TypeScript",
      "program": "${workspaceFolder}/src/index.ts",
      "preLaunchTask": "tsc: build - tsconfig.json",
      "outFiles": ["${workspaceFolder}/dist/**/*.js"],
      "sourceMaps": true,
      "resolveSourceMapLocations": [
        "${workspaceFolder}/**",
        "!**/node_modules/**"
      ],
      "smartStep": true,
      "internalConsoleOptions": "openOnSessionStart"
    }
  ]
}
```

**For ts-node users**:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug with ts-node",
      "runtimeArgs": ["-r", "ts-node/register"],
      "args": ["${workspaceFolder}/src/index.ts"],
      "sourceMaps": true
    }
  ]
}
```

**Debugging TypeScript in the Browser**

Configuration for Chrome:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "chrome",
      "request": "launch",
      "name": "Launch Chrome",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}",
      "sourceMaps": true,
      "sourceMapPathOverrides": {
        "webpack:///./*": "${webRoot}/*",
        "webpack:///src/*": "${webRoot}/src/*"
      }
    }
  ]
}
```

**For React applications with Create React App**:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "chrome",
      "request": "launch",
      "name": "Debug React",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}",
      "sourceMapPathOverrides": {
        "webpack:///src/*": "${webRoot}/src/*"
      }
    }
  ]
}
```

**Advanced VS Code Debugging Features**

1. **Conditional Breakpoints**:
    
    - Right-click on a breakpoint
    - Select "Edit Breakpoint"
    - Enter a condition like `count > 5`
2. **Logpoints** (non-pausing breakpoints that log information):
    
    - Right-click on the gutter (where breakpoints appear)
    - Select "Add Logpoint"
    - Enter a message like `Count is {count}` (variables in curly braces)
3. **Data Inspection**:
    
    - Hover over variables to see values
    - Use the Debug Console to evaluate expressions
    - Add watches for variables you want to monitor
4. **Debug Console**:
    
    - Access the Debug Console during a debug session
    - Evaluate expressions and call functions
    - Access variables in current scope

**VS Code Debugging Keyboard Shortcuts**

- `F5`: Start debugging
- `Shift+F5`: Stop debugging
- `F9`: Toggle breakpoint
- `F10`: Step over
- `F11`: Step into
- `Shift+F11`: Step out
- `Ctrl+F5` (Windows/Linux) or `Cmd+F5` (Mac): Run without debugging

**Debugging with Jest in VS Code**

For Jest test debugging:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Jest Tests",
      "program": "${workspaceFolder}/node_modules/.bin/jest",
      "args": ["--runInBand"],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "disableOptimisticBPs": true,
      "windows": {
        "program": "${workspaceFolder}/node_modules/jest/bin/jest"
      }
    }
  ]
}
```

### Chrome DevTools with TypeScript

Chrome DevTools offers powerful debugging capabilities that work well with TypeScript when source maps are properly configured.

**Setting Up Chrome DevTools for TypeScript**

1. Open DevTools (`F12` or `Ctrl+Shift+I` / `Cmd+Option+I`)
2. Go to Settings (gear icon) > Preferences
3. Under Sources, enable "Enable JavaScript source maps"
4. Optional: Enable "Enable CSS source maps"

**Loading TypeScript Files in DevTools**

With source maps enabled, you should see your TypeScript files under:

- Sources tab > Page > webpack:// (for webpack projects)
- Sources tab > Page > [your domain] (for simpler setups)

If your TypeScript files don't appear, check:

1. Source maps are correctly generated
2. The server is serving the `.map` files
3. The paths in the source maps match your project structure

**Chrome DevTools Debugging Features**

**Breakpoints**:

- Click on the line number to set a breakpoint
- Right-click on the line number for advanced breakpoint options:
    - Conditional breakpoints
    - Logpoints (Console messages without stopping)

**Breakpoint Types**:

- **Line breakpoints**: Break at specific lines
- **DOM breakpoints**: Break when DOM elements change
- **XHR/Fetch breakpoints**: Break when requests are made
- **Event listener breakpoints**: Break when specific events fire
- **Exception breakpoints**: Break on thrown exceptions

**Debugging Controls**:

- Resume script execution: Continue until next breakpoint
- Step over: Execute current line and move to next line
- Step into: Enter function calls
- Step out: Complete current function and return to caller
- Deactivate breakpoints: Run with breakpoints temporarily disabled

**Watch Expressions**:

- Add expressions to monitor in the Watch panel
- Watches are evaluated at each step

**Call Stack**:

- View the function call hierarchy
- Click on stack frames to navigate between different points in execution

**Debugging Asynchronous Code**:

For promises and async/await:

1. Enable "Async" in the call stack panel to see async call chains
2. Use the "Async" option when setting breakpoints for better async debugging

**Performance Profiling**:

1. Go to the Performance tab
2. Click Record
3. Perform actions in your app
4. Stop recording to see a breakdown of execution time

The source maps will help you see TypeScript code in the profiles rather than compiled JavaScript.

**Memory Analysis**:

1. Go to the Memory tab
2. Take a heap snapshot
3. Analyze memory usage
4. Look for memory leaks through comparison snapshots

**TypeScript-specific DevTools Tricks**:

1. **Type checking in Console**: TypeScript's types are erased at runtime, but you can check types during debugging:
    
    ```typescript
    // In your code
    console.log('Variable type check:', { myVar });
    ```
    
2. **Logpoints for non-invasive debugging**:
    
    - Right-click line number > Add logpoint
    - Use `{variableName}` syntax to output values
    - Doesn't require code changes
3. **Blackboxing transpiled code**:
    
    - Go to DevTools Settings > Blackboxing
    - Add patterns for generated code (e.g., `/node_modules/`, `/dist/`)
    - This keeps the debugger focused on your source code

### Logging Strategies

Effective logging is a complementary approach to interactive debugging that helps track application behavior over time.

**Basic TypeScript Logging**

Simple console logging:

```typescript
function processOrder(order: Order): void {
  console.log('Processing order:', order.id);
  try {
    // Order processing logic
    console.log('Order processed successfully');
  } catch (error) {
    console.error('Failed to process order:', error);
  }
}
```

**Creating a Simple Logger**

Basic TypeScript logger with levels:

```typescript
enum LogLevel {
  DEBUG,
  INFO,
  WARN,
  ERROR
}

class Logger {
  constructor(private name: string, private level: LogLevel = LogLevel.INFO) {}

  debug(message: string, ...data: any[]): void {
    if (this.level <= LogLevel.DEBUG) {
      console.debug(`[${this.name}] DEBUG:`, message, ...data);
    }
  }

  info(message: string, ...data: any[]): void {
    if (this.level <= LogLevel.INFO) {
      console.info(`[${this.name}] INFO:`, message, ...data);
    }
  }

  warn(message: string, ...data: any[]): void {
    if (this.level <= LogLevel.WARN) {
      console.warn(`[${this.name}] WARN:`, message, ...data);
    }
  }

  error(message: string, ...data: any[]): void {
    if (this.level <= LogLevel.ERROR) {
      console.error(`[${this.name}] ERROR:`, message, ...data);
    }
  }
}

// Usage
const userLogger = new Logger('UserService', LogLevel.DEBUG);
userLogger.debug('User login attempt', { userId: '123' });
```

**Using Structured Logging**

Structured logging makes logs searchable and analyzable:

```typescript
interface LogEntry {
  timestamp: string;
  level: string;
  component: string;
  message: string;
  data?: Record<string, any>;
  error?: {
    message: string;
    stack?: string;
  };
}

class StructuredLogger {
  constructor(private component: string) {}

  private log(level: string, message: string, data?: any, error?: Error): void {
    const entry: LogEntry = {
      timestamp: new Date().toISOString(),
      level,
      component: this.component,
      message
    };

    if (data !== undefined) {
      entry.data = data;
    }

    if (error) {
      entry.error = {
        message: error.message,
        stack: error.stack
      };
    }

    // In production, you might want to send this to a logging service
    console.log(JSON.stringify(entry));
  }

  debug(message: string, data?: any): void {
    this.log('DEBUG', message, data);
  }

  info(message: string, data?: any): void {
    this.log('INFO', message, data);
  }

  warn(message: string, data?: any): void {
    this.log('WARN', message, data);
  }

  error(message: string, error?: Error, data?: any): void {
    this.log('ERROR', message, data, error);
  }
}
```

**Popular Logging Libraries**

Several excellent logging libraries exist for TypeScript projects:

1. **Winston**:

```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// In development, also log to console
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    )
  }));
}

// Usage
logger.info('User logged in', { userId: '123' });
```

2. **Pino**:

```typescript
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  serializers: {
    err: pino.stdSerializers.err
  }
});

// Usage
logger.info({ userId: '123' }, 'User logged in');
logger.error({ err: new Error('Failed'), userId: '123' }, 'Login failed');
```

3. **debug**:

```typescript
import debug from 'debug';

// Create namespaced debuggers
const debugAuth = debug('app:auth');
const debugApi = debug('app:api');
const debugDb = debug('app:db');

// Usage
debugAuth('User %s logged in', userId);
debugApi('API request received: %O', request);
debugDb('Database query: %s', query);

// Enable via DEBUG=app:* environment variable
```

**Context-Preserving Logging**

For async operations, preserve context in logs:

```typescript
class ContextLogger {
  private requestId: string;
  
  constructor(requestId: string) {
    this.requestId = requestId;
  }
  
  info(message: string, data?: any): void {
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      level: 'INFO',
      requestId: this.requestId,
      message,
      data
    }));
  }
  
  // Other log levels...
}

// Usage in an Express middleware
import { v4 as uuidv4 } from 'uuid';

app.use((req, res, next) => {
  const requestId = uuidv4();
  res.locals.logger = new ContextLogger(requestId);
  res.locals.logger.info('Request started', { 
    path: req.path,
    method: req.method
  });
  next();
});
```

**Logging Decorators with TypeScript**

Decorators provide a clean way to add logging:

```typescript
// Method decorator for logging
function Log(level: 'debug' | 'info' | 'warn' | 'error' = 'info') {
  return function (
    target: any,
    propertyKey: string,
    descriptor: PropertyDescriptor
  ) {
    const originalMethod = descriptor.value;
    
    descriptor.value = function (...args: any[]) {
      const className = target.constructor.name;
      console[level](`${level.toUpperCase()} [${className}.${propertyKey}] Called with:`, args);
      
      try {
        const result = originalMethod.apply(this, args);
        
        // Handle promises
        if (result instanceof Promise) {
          return result
            .then(value => {
              console[level](`${level.toUpperCase()} [${className}.${propertyKey}] Resolved:`, value);
              return value;
            })
            .catch(error => {
              console.error(`ERROR [${className}.${propertyKey}] Error:`, error);
              throw error;
            });
        }
        
        console[level](`${level.toUpperCase()} [${className}.${propertyKey}] Returned:`, result);
        return result;
      } catch (error) {
        console.error(`ERROR [${className}.${propertyKey}] Error:`, error);
        throw error;
      }
    };
    
    return descriptor;
  };
}

// Usage
class UserService {
  @Log('info')
  async getUserById(id: string): Promise<User> {
    // Implementation...
    return user;
  }
}
```

**Advanced Logging Patterns**

1. **Sampling Logs** - Reduce volume by sampling frequent events:

```typescript
class SampledLogger {
  private samplingRates: Record<string, number> = {};
  
  constructor(samplingRates: Record<string, number>) {
    this.samplingRates = samplingRates;
  }
  
  log(category: string, message: string, data?: any): void {
    const rate = this.samplingRates[category] || 1.0;
    
    if (Math.random() <= rate) {
      console.log({
        timestamp: new Date().toISOString(),
        category,
        message,
        data,
        sampled: rate < 1.0
      });
    }
  }
}

// Sample 10% of db queries, 100% of errors
const logger = new SampledLogger({
  'db.query': 0.1,
  'error': 1.0
});
```

2. **Circuit Breaker for Error Logs** - Prevent log flooding:

```typescript
class CircuitBreakerLogger {
  private errorCounts: Record<string, number> = {};
  private lastReported: Record<string, number> = {};
  private threshold: number;
  private windowMs: number;
  
  constructor(threshold: number = 5, windowMs: number = 60000) {
    this.threshold = threshold;
    this.windowMs = windowMs;
  }
  
  error(category: string, message: string, error?: Error): void {
    const now = Date.now();
    
    if (!this.errorCounts[category]) {
      this.errorCounts[category] = 0;
      this.lastReported[category] = 0;
    }
    
    this.errorCounts[category]++;
    
    if (this.errorCounts[category] <= this.threshold ||
        now - this.lastReported[category] >= this.windowMs) {
      
      console.error({
        timestamp: new Date().toISOString(),
        category,
        message,
        error: error ? { message: error.message, stack: error.stack } : undefined,
        count: this.errorCounts[category]
      });
      
      this.lastReported[category] = now;
      
      if (this.errorCounts[category] === this.threshold) {
        console.warn(`Suppressing further logs of type ${category} for ${this.windowMs}ms`);
      }
    }
    
    // Reset counter after window
    setTimeout(() => {
      this.errorCounts[category] = 0;
    }, this.windowMs);
  }
}
```

### Integration Testing with TypeScript

TypeScript can be used effectively in debug-oriented testing strategies.

**Jest with TypeScript**

Configure Jest for TypeScript debugging:

```javascript
// jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  transform: {
    '^.+\\.tsx?$': 'ts-jest'
  },
  collectCoverage: true,
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts'
  ]
};
```

Writing debuggable tests:

```typescript
import { UserService } from '../services/user.service';

describe('UserService', () => {
  let userService: UserService;
  
  beforeEach(() => {
    userService = new UserService();
    // Add debug information in beforeEach
    console.log('Test setup complete', { service: userService });
  });
  
  test('should create a user', async () => {
    const userData = { name: 'Test User', email: 'test@example.com' };
    
    // Add debug point
    console.log('Creating user with data:', userData);
    
    const user = await userService.createUser(userData);
    
    // Debug verification
    console.log('Created user:', user);
    
    expect(user).toHaveProperty('id');
    expect(user.name).toBe(userData.name);
  });
});
```

**Debugging specific Jest tests**:

```bash
# Run only specific test file with NODE_OPTIONS for debugging
NODE_OPTIONS=--inspect-brk jest --runInBand path/to/test.spec.ts
```

### Best Practices for TypeScript Debugging

1. **Organize Code for Debuggability**:
    
    - Keep functions small and focused
    - Use meaningful variable names
    - Use type annotations to help identify issues
2. **Use TypeScript's Strict Mode**:
    
    ```json
    {
      "compilerOptions": {
        "strict": true
      }
    }
    ```
    
3. **Enable Additional Type Checking**:
    
    ```json
    {
      "compilerOptions": {
        "noImplicitAny": true,
        "strictNullChecks": true,
        "strictFunctionTypes": true,
        "strictBindCallApply": true,
        "strictPropertyInitialization": true,
        "noImplicitThis": true,
        "alwaysStrict": true,
        "noUnusedLocals": true,
        "noUnusedParameters": true,
        "noImplicitReturns": true,
        "noFallthroughCasesInSwitch": true
      }
    }
    ```
    
4. **Handle Errors Properly**:
    
    ```typescript
    try {
      const result = await riskyOperation();
      return result;
    } catch (error) {
      // Enhance error with context
      if (error instanceof Error) {
        console.error('Operation failed:', {
          operation: 'riskyOperation',
          error: {
            message: error.message,
            stack: error.stack
          },
          context: { /* relevant context */ }
        });
      }
      throw error;
    }
    ```
    
5. **Create Debug-Friendly Objects**:
    
    ```typescript
    class DebugFriendly {
      [Symbol.for('nodejs.util.inspect.custom')]() {
        // Return a simplified representation for console.log
        return {
          id: this.id,
          name: this.name,
          // Include important properties, exclude verbose ones
        };
      }
      
      toString() {
        return `${this.constructor.name}(${this.id})`;
      }
    }
    ```
    
6. **Use Custom Type Guards**:
    
    ```typescript
    // Type guard to narrow down error types
    function isApiError(error: unknown): error is ApiError {
      return typeof error === 'object' && 
             error !== null && 
             'statusCode' in error &&
             'apiMessage' in error;
    }
    
    try {
      await apiCall();
    } catch (error) {
      if (isApiError(error)) {
        // TypeScript knows this is an ApiError
        console.error(`API Error ${error.statusCode}: ${error.apiMessage}`);
      } else if (error instanceof Error) {
        console.error('Standard error:', error.message);
      } else {
        console.error('Unknown error:', error);
      }
    }
    ```
    
7. **Debug Configuration Templates**:
    
    Create a `.vscode/launch.json.template` with commented options:
    
    ```json
    {
      "version": "0.2.0",
      "configurations": [
        {
          "name": "Debug Current Test File",
          "type": "node",
          "request": "launch",
          "program": "${workspaceFolder}/node_modules/.bin/jest",
          "args": ["${relativeFile}", "--coverage=false"],
          "console": "integratedTerminal",
          "internalConsoleOptions": "neverOpen"
        },
        // More configurations with explanatory comments...
      ]
    }
    ```
    
8. **Document Debugging Process**:
    
    Add a `DEBUGGING.md` file to your project:
    
    ```markdown
    # Debugging Guide
    
    ## Common Issues and Solutions
    
    ### "Cannot find module" errors
    - Check if the module is installed
    - Verify import path is correct
    - Run `npm install` to ensure dependencies are updated
    
    ## Debugging Tools
    
    ### VS Code Debugging
    1. Open the file you want to debug
    2. Set breakpoints
    3. Press F5 or select the debug configuration
    
    ### Remote Debugging
    4. Start the application with `--inspect` flag
    5. Connect with Chrome DevTools or VS Code
    ```
    

**Recommended Related Topics**

- TypeScript Error Handling Patterns
- Performance Profiling TypeScript Applications
- Testing TypeScript Applications
- Continuous Integration for TypeScript Projects
- Memory Leak Detection in TypeScript

---

