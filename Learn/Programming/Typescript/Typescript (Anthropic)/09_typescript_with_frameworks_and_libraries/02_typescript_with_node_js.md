## TypeScript with Node.js


### Introduction to TypeScript in Node.js Development

TypeScript has revolutionized Node.js development by bringing static typing to JavaScript, enhancing developer experience through improved tooling, code completion, and error detection during development rather than runtime. This powerful combination enables building robust, maintainable, and scalable server-side applications with increased confidence and productivity.

**Key Points**

- TypeScript is a superset of JavaScript that adds static typing
- Compiles to plain JavaScript that can run in any JavaScript runtime
- Provides early error detection and improved IDE support
- Enhances code documentation through explicit type definitions
- Facilitates easier refactoring and maintenance of large codebases

### Setting Up a TypeScript Node.js Project

Setting up a new TypeScript Node.js project involves initializing npm, installing TypeScript dependencies, and configuring the TypeScript compiler.

```bash
# Initialize a new Node.js project
npm init -y

# Install TypeScript and Node.js type definitions
npm install typescript @types/node --save-dev

# Initialize TypeScript configuration
npx tsc --init
```

The generated `tsconfig.json` file controls how TypeScript compiles your code. Here's a recommended configuration for Node.js projects:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "esModuleInterop": true,
    "strict": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "sourceMap": true,
    "declaration": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.test.ts"]
}
```

Add useful npm scripts to your `package.json`:

```json
"scripts": {
  "build": "tsc",
  "start": "node dist/index.js",
  "dev": "ts-node-dev --respawn src/index.js",
  "lint": "eslint . --ext .ts"
}
```

### Type Definitions for Node.js

Working with Node.js in TypeScript requires proper type definitions for the Node.js API and modules. The `@types/node` package is essential for this purpose.

**Key Points**

- `@types/node` provides TypeScript definitions for all built-in Node.js modules
- TypeScript can infer types from these definitions, improving IntelliSense and catching errors
- The definitions are regularly updated to match the latest Node.js releases

Here's how you can use these definitions with Node.js built-in modules:

```typescript
import * as fs from 'fs';
import * as path from 'path';
import { IncomingMessage, ServerResponse } from 'http';

// TypeScript knows the exact shape of these objects
const readFile = async (filePath: string): Promise<string> => {
  const absolutePath = path.resolve(__dirname, filePath);
  return fs.promises.readFile(absolutePath, 'utf-8');
};

// Using Node.js HTTP types
function requestHandler(req: IncomingMessage, res: ServerResponse): void {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ message: 'Hello TypeScript!' }));
}
```

### Using External Modules with TypeScript

When working with external npm packages in TypeScript, you'll need their type definitions as well.

```typescript
// For packages with built-in TypeScript support (e.g., Axios)
import axios from 'axios';

// For packages without built-in TypeScript support, install @types
// npm install lodash @types/lodash --save
import * as _ from 'lodash';
```

If no type definitions exist for a package, you can create a declaration file:

```typescript
// src/types/untyped-module.d.ts
declare module 'untyped-module' {
  export function doSomething(param: string): boolean;
  export default class SomeClass {
    constructor(options?: { option1?: string });
    methodA(): void;
  }
}
```

### Express with TypeScript

Express is one of the most popular web frameworks for Node.js, and TypeScript adds type safety to Express applications.

**Key Points**

- Type definitions for Express improves middleware and route handler development
- Use of interfaces for request and response objects enhances code clarity
- Type-safe route parameters and query strings prevent runtime errors

First, install Express with its type definitions:

```bash
npm install express
npm install @types/express --save-dev
```

Basic Express setup with TypeScript:

```typescript
import express, { Request, Response, NextFunction } from 'express';

const app = express();
const PORT = process.env.PORT || 3000;

// Define interfaces for type safety
interface UserRequest extends Request {
  body: {
    username: string;
    email: string;
    password: string;
  }
}

// Middleware with proper types
const loggerMiddleware = (req: Request, res: Response, next: NextFunction) => {
  console.log(`${req.method} ${req.path}`);
  next();
};

app.use(express.json());
app.use(loggerMiddleware);

// Route with typed request body
app.post('/users', (req: UserRequest, res: Response) => {
  const { username, email, password } = req.body;
  
  if (!username || !email || !password) {
    return res.status(400).json({ error: 'Missing required fields' });
  }
  
  // Process user registration
  res.status(201).json({ message: 'User created', username });
});

// Typed route parameters
app.get('/users/:id', (req: Request<{ id: string }>, res: Response) => {
  const userId = req.params.id;
  
  // Fetch user by ID
  res.json({ id: userId, username: 'example_user' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### Advanced Express Patterns with TypeScript

For larger applications, organizing Express routes and middleware with TypeScript becomes essential.

```typescript
// src/types/express/index.d.ts
import 'express';

declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        username: string;
        roles: string[];
      };
    }
  }
}
```

Implementing modular routes:

```typescript
// src/routes/user.routes.ts
import { Router } from 'express';
import { UserController } from '../controllers/user.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();
const userController = new UserController();

router.get('/', userController.getAllUsers);
router.get('/:id', userController.getUserById);
router.post('/', authMiddleware(['admin']), userController.createUser);
router.put('/:id', authMiddleware(['admin', 'user']), userController.updateUser);
router.delete('/:id', authMiddleware(['admin']), userController.deleteUser);

export default router;
```

Controller with TypeScript:

```typescript
// src/controllers/user.controller.ts
import { Request, Response } from 'express';
import { UserService } from '../services/user.service';

export class UserController {
  private userService = new UserService();

  public getAllUsers = async (req: Request, res: Response): Promise<void> => {
    try {
      const users = await this.userService.findAll();
      res.json(users);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch users' });
    }
  };

  public getUserById = async (req: Request<{ id: string }>, res: Response): Promise<void> => {
    try {
      const user = await this.userService.findById(req.params.id);
      if (!user) {
        res.status(404).json({ error: 'User not found' });
        return;
      }
      res.json(user);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch user' });
    }
  };

  // Other controller methods...
}
```

### Creating Typed APIs

Developing typed APIs with TypeScript ensures consistency between your API contracts and implementation.

**Key Points**

- Define interfaces for request/response bodies for type safety
- Use generics for reusable API components
- Create utility types for common API patterns
- Document API endpoints with JSDoc comments

Define shared models and interfaces:

```typescript
// src/models/user.model.ts
export interface User {
  id: string;
  username: string;
  email: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateUserDto {
  username: string;
  email: string;
  password: string;
}

export interface UpdateUserDto {
  username?: string;
  email?: string;
  password?: string;
}

// Generic API response types
export interface ApiResponse<T> {
  data: T;
  message: string;
  status: number;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}
```

Implementing typed service class:

```typescript
// src/services/user.service.ts
import { User, CreateUserDto, UpdateUserDto, PaginatedResponse } from '../models/user.model';
import { DatabaseError } from '../errors/database.error';

export class UserService {
  public async findAll(page = 1, limit = 10): Promise<PaginatedResponse<User>> {
    try {
      // Implementation to fetch users from database
      const users: User[] = []; // Replace with actual database query
      const total = 100; // Replace with count query
      
      return {
        items: users,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      throw new DatabaseError('Failed to fetch users', error);
    }
  }

  public async findById(id: string): Promise<User | null> {
    try {
      // Implementation to fetch user by ID
      return null; // Replace with actual database query
    } catch (error) {
      throw new DatabaseError('Failed to fetch user', error);
    }
  }

  public async create(userData: CreateUserDto): Promise<User> {
    try {
      // Implementation to create user
      const newUser: User = {
        id: 'generated-id',
        username: userData.username,
        email: userData.email,
        createdAt: new Date(),
        updatedAt: new Date()
      };
      
      return newUser;
    } catch (error) {
      throw new DatabaseError('Failed to create user', error);
    }
  }

  // Other service methods...
}
```

### Error Handling with TypeScript

TypeScript enhances error handling through custom error classes and type checking.

```typescript
// src/errors/base.error.ts
export abstract class BaseError extends Error {
  public readonly statusCode: number;
  public readonly isOperational: boolean;

  constructor(
    message: string,
    statusCode: number,
    isOperational = true,
    stack = ''
  ) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    
    if (stack) {
      this.stack = stack;
    } else {
      Error.captureStackTrace(this, this.constructor);
    }
  }
}

// src/errors/api.error.ts
import { BaseError } from './base.error';

export class ApiError extends BaseError {
  constructor(message: string, statusCode = 500) {
    super(message, statusCode);
  }
}

export class NotFoundError extends ApiError {
  constructor(message = 'Resource not found') {
    super(message, 404);
  }
}

export class BadRequestError extends ApiError {
  constructor(message = 'Bad request') {
    super(message, 400);
  }
}

// Express error handler middleware
import { Request, Response, NextFunction } from 'express';
import { BaseError } from '../errors/base.error';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  if (err instanceof BaseError) {
    res.status(err.statusCode).json({
      status: 'error',
      message: err.message
    });
    return;
  }

  console.error('Unexpected error:', err);
  res.status(500).json({
    status: 'error',
    message: 'Internal server error'
  });
};
```

### Database Integration with TypeScript

TypeScript provides type safety when working with databases in Node.js applications.

**Example** Using TypeORM with TypeScript:

```typescript
// src/entities/user.entity.ts
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('users')
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  username: string;

  @Column({ unique: true })
  email: string;

  @Column()
  passwordHash: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

// src/repositories/user.repository.ts
import { Repository, EntityRepository } from 'typeorm';
import { UserEntity } from '../entities/user.entity';
import { CreateUserDto } from '../models/user.model';

@EntityRepository(UserEntity)
export class UserRepository extends Repository<UserEntity> {
  public async createUser(userData: CreateUserDto): Promise<UserEntity> {
    const user = new UserEntity();
    user.username = userData.username;
    user.email = userData.email;
    user.passwordHash = 'hashed_password'; // Use a proper hashing function
    
    return this.save(user);
  }
  
  public async findByUsername(username: string): Promise<UserEntity | undefined> {
    return this.findOne({ where: { username } });
  }
}
```

### Testing TypeScript Node.js Applications

TypeScript enhances testability with type safety in unit and integration tests.

```typescript
// src/services/__tests__/user.service.test.ts
import { UserService } from '../user.service';
import { UserRepository } from '../../repositories/user.repository';
import { CreateUserDto } from '../../models/user.model';
import { NotFoundError } from '../../errors/api.error';

// Mock the repository
jest.mock('../../repositories/user.repository');

describe('UserService', () => {
  let userService: UserService;
  let userRepository: jest.Mocked<UserRepository>;

  beforeEach(() => {
    userRepository = new UserRepository() as jest.Mocked<UserRepository>;
    userService = new UserService(userRepository);
  });

  describe('createUser', () => {
    it('should create a new user', async () => {
      // Arrange
      const createUserDto: CreateUserDto = {
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123'
      };
      
      const expectedUser = {
        id: 'test-id',
        username: 'testuser',
        email: 'test@example.com',
        createdAt: new Date(),
        updatedAt: new Date()
      };
      
      userRepository.createUser.mockResolvedValue(expectedUser as any);
      
      // Act
      const result = await userService.create(createUserDto);
      
      // Assert
      expect(userRepository.createUser).toHaveBeenCalledWith(expect.objectContaining({
        username: createUserDto.username,
        email: createUserDto.email
      }));
      expect(result).toEqual(expectedUser);
    });
  });

  describe('findById', () => {
    it('should find a user by id', async () => {
      // Arrange
      const userId = 'test-id';
      const expectedUser = {
        id: userId,
        username: 'testuser',
        email: 'test@example.com'
      };
      
      userRepository.findOne.mockResolvedValue(expectedUser as any);
      
      // Act
      const result = await userService.findById(userId);
      
      // Assert
      expect(userRepository.findOne).toHaveBeenCalledWith({ where: { id: userId } });
      expect(result).toEqual(expectedUser);
    });
    
    it('should throw NotFoundError when user does not exist', async () => {
      // Arrange
      const userId = 'non-existent-id';
      userRepository.findOne.mockResolvedValue(undefined);
      
      // Act & Assert
      await expect(userService.findById(userId)).rejects.toThrow(NotFoundError);
    });
  });
});
```

### Advanced TypeScript Features for Node.js

TypeScript offers advanced features that can be leveraged in Node.js development.

#### Type Guards and Type Narrowing

```typescript
// Custom type guard
function isUser(obj: any): obj is User {
  return (
    obj &&
    typeof obj === 'object' &&
    'id' in obj &&
    'username' in obj &&
    'email' in obj
  );
}

// Using type guards
function processEntity(entity: User | Organization): string {
  if (isUser(entity)) {
    // TypeScript knows entity is User here
    return `User: ${entity.username}`;
  } else {
    // TypeScript knows entity is Organization here
    return `Organization: ${entity.name}`;
  }
}
```

#### Utility Types for API Development

```typescript
// Using TypeScript utility types for API models
type UserResponse = Omit<User, 'password'>;
type UserWithRoles = User & { roles: string[] };
type OptionalUser = Partial<User>;
type ReadonlyUser = Readonly<User>;

// API response mapper
function mapToUserResponse(user: User): UserResponse {
  const { password, ...userWithoutPassword } = user;
  return userWithoutPassword;
}

// Ensuring immutability
function processUser(user: ReadonlyUser): void {
  // This would cause a TypeScript error
  // user.username = 'newname';
  
  // Instead, create a new object
  const updatedUser = { ...user, lastSeen: new Date() };
  // Process the updated user...
}
```

#### Decorators for Node.js Applications

```typescript
// Method decorator for logging
function LogMethod(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;
  
  descriptor.value = function(...args: any[]) {
    console.log(`Calling ${propertyKey} with arguments: ${JSON.stringify(args)}`);
    const result = originalMethod.apply(this, args);
    console.log(`Method ${propertyKey} returned: ${JSON.stringify(result)}`);
    return result;
  };
  
  return descriptor;
}

class UserController {
  @LogMethod
  public getUserInfo(userId: string) {
    return { id: userId, username: 'example' };
  }
}
```

### Performance Optimization with TypeScript

TypeScript can help identify and resolve performance issues in Node.js applications.

**Key Points**

- TypeScript helps detect memory leaks through proper typing
- Async/await patterns are type-safe and easier to maintain
- Proper typing of Promise chains improves readability and error handling

```typescript
// Memory-efficient stream processing with proper typing
import { Readable, Transform, Writable } from 'stream';
import { promisify } from 'util';
import * as fs from 'fs';

interface DataChunk {
  id: number;
  content: string;
}

const pipeline = promisify(require('stream').pipeline);

async function processLargeFile(filePath: string, outputPath: string): Promise<void> {
  const readStream = fs.createReadStream(filePath, { encoding: 'utf-8' });
  const writeStream = fs.createWriteStream(outputPath);
  
  const parseJson = new Transform({
    objectMode: true,
    transform(chunk: string, encoding: string, callback: Function) {
      try {
        const data = JSON.parse(chunk) as DataChunk;
        callback(null, data);
      } catch (error) {
        callback(error);
      }
    }
  });
  
  const processData = new Transform({
    objectMode: true,
    transform(data: DataChunk, encoding: string, callback: Function) {
      // Process the data
      const processed = {
        ...data,
        content: data.content.toUpperCase()
      };
      callback(null, JSON.stringify(processed) + '\n');
    }
  });
  
  try {
    await pipeline(readStream, parseJson, processData, writeStream);
    console.log('Processing completed');
  } catch (error) {
    console.error('Pipeline failed', error);
    throw error;
  }
}
```

### Debugging TypeScript Node.js Applications

TypeScript enhances the debugging experience through source maps and type information.

Configure debugging in VS Code with `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug TypeScript",
      "skipFiles": ["<node_internals>/**"],
      "program": "${workspaceFolder}/src/index.ts",
      "preLaunchTask": "tsc: build - tsconfig.json",
      "outFiles": ["${workspaceFolder}/dist/**/*.js"],
      "sourceMaps": true
    },
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Current Test",
      "program": "${workspaceFolder}/node_modules/.bin/jest",
      "args": ["--runInBand", "${relativeFile}"],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "disableOptimisticBPs": true
    }
  ]
}
```

### Deployment Considerations for TypeScript Node.js Applications

When deploying TypeScript Node.js applications, consider these approaches:

1. **Compile-then-deploy**: Build your TypeScript code to JavaScript before deployment
    
    ```bash
    npm run build
    # Deploy the contents of the dist folder
    ```
    
2. **Runtime transpilation**: Use ts-node in production (not recommended for performance-critical applications)
    
    ```bash
    npm install ts-node --save
    # Set NODE_ENV=production
    node -r ts-node/register src/index.ts
    ```
    
3. **Docker-based deployment**:
    
    ```dockerfile
    FROM node:18-alpine as builder
    WORKDIR /app
    COPY package*.json ./
    RUN npm ci
    COPY tsconfig.json ./
    COPY src/ ./src/
    RUN npm run build
    
    FROM node:18-alpine
    WORKDIR /app
    COPY package*.json ./
    RUN npm ci --production
    COPY --from=builder /app/dist ./dist
    CMD ["node", "dist/index.js"]
    ```
    

**Key Points**

- Always include source maps for error tracking
- Set appropriate NODE_ENV values
- Consider using process managers like PM2
- Implement health checks and monitoring

### Best Practices for TypeScript with Node.js

**Key Points**

- Use strict mode in TypeScript for maximum type safety
- Create domain-specific interfaces and types
- Leverage enums for constants and state management
- Use discriminated unions for type-safe handling of different states
- Document code with JSDoc comments for better IDE integration

```typescript
/**
 * Represents the current state of a job in the system.
 */
enum JobStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed'
}

/**
 * Base interface for all job types.
 */
interface JobBase {
  id: string;
  status: JobStatus;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Represents an email sending job.
 */
interface EmailJob extends JobBase {
  type: 'email';
  recipient: string;
  subject: string;
  body: string;
}

/**
 * Represents a file processing job.
 */
interface FileProcessingJob extends JobBase {
  type: 'file_processing';
  filePath: string;
  outputPath: string;
  processingOptions: {
    resize?: boolean;
    format?: 'jpg' | 'png' | 'webp';
  };
}

/**
 * Union type for all job types in the system.
 */
type Job = EmailJob | FileProcessingJob;

/**
 * Processes a job based on its type.
 * @param job The job to process
 * @returns A promise that resolves when the job is processed
 */
async function processJob(job: Job): Promise<void> {
  // Common job processing logic
  console.log(`Processing job ${job.id} with status ${job.status}`);
  
  // Type-specific processing using discriminated union
  switch (job.type) {
    case 'email':
      await sendEmail(job.recipient, job.subject, job.body);
      break;
    case 'file_processing':
      await processFile(job.filePath, job.outputPath, job.processingOptions);
      break;
    default:
      // Exhaustiveness check - will cause compile error if a job type is added without handling
      const exhaustiveCheck: never = job;
      throw new Error(`Unhandled job type: ${exhaustiveCheck}`);
  }
}
```

### Conclusion

TypeScript transforms Node.js development by bringing strong typing, better tooling, and improved code quality to server-side JavaScript. Its seamless integration with Express and other frameworks makes it an excellent choice for building robust APIs and web applications. By leveraging TypeScript's advanced features and adhering to best practices, developers can create maintainable, scalable, and reliable Node.js applications that are easier to develop, test, and deploy.

### Related Topics

- TypeScript with GraphQL for API development
- TypeScript with WebSockets for real-time applications
- Microservices architecture with TypeScript and Node.js
- TypeScript with serverless functions (AWS Lambda, Azure Functions)
- Advanced type manipulation techniques for complex domain models

---

