## Monorepos with TypeScript


### Introduction to TypeScript Monorepos

A monorepo (monolithic repository) is a development strategy where multiple projects or packages are stored in a single repository. When combined with TypeScript, monorepos offer powerful type safety across your entire codebase while maintaining separation of concerns. This approach has been adopted by major companies like Google, Facebook, and Microsoft to manage large-scale applications efficiently.

### Setting Up Monorepos

#### Tools for TypeScript Monorepos

There are several tools available for managing TypeScript monorepos:

- **Nx**: A powerful build system with built-in TypeScript support
- **Turborepo**: Optimized for high-performance builds and caching
- **Lerna**: One of the original monorepo management tools
- **pnpm Workspaces**: Lightweight solution with efficient package linking
- **Yarn Workspaces**: Integrated workspace management for Yarn users
- **npm Workspaces**: Native workspaces in npm 7+

#### Basic Monorepo Structure

```
my-monorepo/
├── package.json          # Root package.json
├── tsconfig.json         # Base TypeScript configuration
├── tsconfig.base.json    # Shared TypeScript settings
├── packages/
│   ├── common/           # Shared utilities and types
│   │   ├── package.json
│   │   ├── tsconfig.json # Extends base config
│   │   └── src/
│   ├── api/
│   │   ├── package.json
│   │   ├── tsconfig.json # Extends base config
│   │   └── src/
│   └── web/
│       ├── package.json
│       ├── tsconfig.json # Extends base config
│       └── src/
└── node_modules/         # Hoisted dependencies
```

#### Setting Up with Nx

```bash
# Install Nx globally
npm install -g nx

# Create a new Nx workspace
npx create-nx-workspace my-monorepo --preset=ts

# Add new packages
nx g @nrwl/js:lib common
nx g @nrwl/js:lib api
nx g @nrwl/js:lib web
```

#### Setting Up with Turborepo

```bash
# Create a new Turborepo
npx create-turbo@latest

# The structure is created automatically
# You can customize it according to your needs
```

#### Root tsconfig.json Example

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "node",
    "esModuleInterop": true,
    "strict": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "baseUrl": ".",
    "paths": {
      "@my-org/common": ["packages/common/src"],
      "@my-org/api": ["packages/api/src"],
      "@my-org/web": ["packages/web/src"]
    }
  },
  "exclude": ["**/node_modules", "**/dist"]
}
```

### Sharing Types Across Packages

#### Path Aliases and References

```json
// tsconfig.base.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@my-org/*": ["packages/*/src"]
    }
  }
}

// packages/api/tsconfig.json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "references": [
    { "path": "../common" }
  ]
}
```

#### Package Exports and Imports

```typescript
// packages/common/src/index.ts
export interface User {
  id: string;
  name: string;
  email: string;
}

export enum UserRole {
  ADMIN = 'admin',
  USER = 'user'
}

// packages/api/src/users/service.ts
import { User, UserRole } from '@my-org/common';

export class UserService {
  createUser(name: string, email: string): User {
    // Implementation
    return { id: '123', name, email };
  }
}
```

#### Project References

TypeScript's project references enable faster builds and better organization:

```json
// packages/web/tsconfig.json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "composite": true
  },
  "references": [
    { "path": "../common" }
  ]
}
```

Build with project references:

```bash
# Build all packages in correct order
tsc -b packages/web
```

#### Type-Only Imports

For performance optimization:

```typescript
// Only import types, not implementation
import type { User } from '@my-org/common';

// The function implementation doesn't rely on runtime code
function validateUser(user: User): boolean {
  return Boolean(user.id && user.name && user.email);
}
```

### Managing Dependencies

#### Package Management Strategies

- **Hoisting**: Most dependencies are lifted to the root node_modules
- **Nohoist**: Specific packages kept in local node_modules
- **Peer Dependencies**: Used for shared dependencies across packages

#### Root package.json

```json
{
  "name": "my-monorepo",
  "private": true,
  "workspaces": [
    "packages/*"
  ],
  "scripts": {
    "build": "tsc -b",
    "test": "jest",
    "lint": "eslint ."
  },
  "devDependencies": {
    "typescript": "^4.9.5",
    "eslint": "^8.38.0",
    "jest": "^29.5.0"
  }
}
```

#### Package-Specific Dependencies

```json
// packages/api/package.json
{
  "name": "@my-org/api",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc"
  },
  "dependencies": {
    "@my-org/common": "workspace:*",
    "express": "^4.18.2"
  }
}
```

#### Versioning Strategies

1. **Fixed versioning**: All packages share the same version
2. **Independent versioning**: Each package has its own version
3. **Graduated versioning**: Core packages move slowly, feature packages move quickly

#### Dependency Management with pnpm

```bash
# Install package in all workspaces
pnpm add -w typescript

# Install package in specific workspace
pnpm add express --filter @my-org/api

# Link workspace packages
pnpm add @my-org/common --filter @my-org/web --workspace
```

### Build Optimization

#### Incremental Builds

```json
// tsconfig.base.json
{
  "compilerOptions": {
    "incremental": true,
    "composite": true,
    "tsBuildInfoFile": "./buildcache/.tsbuildinfo"
  }
}
```

#### Parallel Building

With Turborepo:

```json
// turbo.json
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": []
    }
  }
}
```

#### Caching Strategies

```bash
# Turborepo with remote caching
npx turbo build --team="my-team" --token="xxx"

# Nx with computation caching
nx build web --skip-nx-cache=false
```

### Monorepo Best Practices

#### Consistent Code Style

```json
// Root .eslintrc.js
module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended'
  ],
  rules: {
    // Custom rules
  }
};
```

#### Automated Testing

```json
// jest.config.js
module.exports = {
  projects: [
    '<rootDir>/packages/*/jest.config.js'
  ],
  collectCoverageFrom: [
    'packages/*/src/**/*.ts'
  ]
};
```

#### CI/CD Integration

```yaml
# .github/workflows/ci.yml
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      - run: npm ci
      - run: npm run build
      - run: npm test
```

### Advanced TypeScript Features in Monorepos

#### Type Generation and Publishing

```json
// packages/common/package.json
{
  "name": "@my-org/common",
  "scripts": {
    "build": "tsc",
    "prepublishOnly": "npm run build"
  },
  "files": [
    "dist",
    "src"
  ],
  "types": "dist/index.d.ts"
}
```

#### API Extractor

Microsoft's API Extractor can generate a single declaration file:

```json
// api-extractor.json
{
  "$schema": "https://developer.microsoft.com/json-schemas/api-extractor/v7/api-extractor.schema.json",
  "mainEntryPointFilePath": "<projectFolder>/dist/index.d.ts",
  "dtsRollup": {
    "enabled": true,
    "untrimmedFilePath": "<projectFolder>/dist/index.d.ts"
  }
}
```

#### Type Testing

```typescript
// packages/common/src/__tests__/types.test.ts
import { expectType } from 'tsd';
import { User } from '../index';

// Type tests
test('User has correct structure', () => {
  expectType<User>({
    id: '123',
    name: 'John',
    email: 'john@example.com'
  });
});
```

### Common Issues and Solutions

#### Circular Dependencies

Problem: Package A depends on B, which depends on A.

Solution:

1. Create a separate package C that both A and B depend on
2. Use interfaces over concrete implementations
3. Use dependency injection

#### Version Conflicts

Problem: Different packages require different versions of the same dependency.

Solution:

1. Use peer dependencies
2. Update all packages to use compatible versions
3. For truly incompatible dependencies, use nohoist

#### Build Performance

Problem: Slow builds as the monorepo grows.

Solution:

1. Use incremental compilation
2. Implement caching
3. Use project references correctly
4. Consider task-based parallelization (e.g., Turborepo, Nx)

**Key Points**:

- Monorepos with TypeScript improve type safety across multiple packages while maintaining separation of concerns
- Project references in TypeScript enable faster builds and better code organization
- Path aliases make imports cleaner and more maintainable
- Package management tools like pnpm, Yarn workspaces, or npm workspaces simplify dependency management
- Build systems like Nx and Turborepo optimize the build process through caching and parallelization

### Real-World Examples

#### Example Monorepo Structure for a Full-Stack Application

```
my-fullstack-app/
├── package.json
├── tsconfig.base.json
├── turbo.json
├── apps/
│   ├── web/                 # React frontend
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── src/
│   │       ├── app.tsx
│   │       └── main.tsx
│   └── api/                 # Express backend
│       ├── package.json
│       ├── tsconfig.json
│       └── src/
│           ├── server.ts
│           └── routes/
├── packages/
│   ├── ui/                  # Shared UI components
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── src/
│   │       ├── button/
│   │       └── index.ts
│   ├── dto/                 # Data transfer objects
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── src/
│   │       ├── user.ts
│   │       └── index.ts
│   ├── config/              # Shared configuration
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── src/
│   │       ├── env.ts
│   │       └── index.ts
│   └── utils/               # Shared utilities
│       ├── package.json
│       ├── tsconfig.json
│       └── src/
│           ├── validation.ts
│           └── index.ts
└── tools/                   # Build and development tools
    ├── eslint-config/
    ├── typescript-config/
    └── scripts/
```

#### Example of Shared Types

```ts
// packages/dto/src/user.ts
export interface UserBase {
  id: string;
  email: string;
  username: string;
  createdAt: Date;
}

export interface UserWithProfile extends UserBase {
  profile: {
    firstName: string;
    lastName: string;
    avatar?: string;
  };
}

export type UserCreateInput = Omit<UserBase, 'id' | 'createdAt'> & {
  password: string;
  profile?: Omit<UserWithProfile['profile'], 'avatar'>;
};

export type UserUpdateInput = Partial<Omit<UserWithProfile, 'id' | 'createdAt'>>;

// packages/dto/src/index.ts
export * from './user';
export * from './auth';
export * from './product';

// packages/api/src/controllers/user.controller.ts
import { UserCreateInput, UserWithProfile } from '@my-org/dto';
import { validateUser } from '@my-org/utils';

export class UserController {
  async createUser(input: UserCreateInput): Promise<UserWithProfile> {
    // Validate input
    validateUser(input);
    
    // Create user logic...
    return {
      id: '123',
      email: input.email,
      username: input.username,
      createdAt: new Date(),
      profile: {
        firstName: input.profile?.firstName || '',
        lastName: input.profile?.lastName || ''
      }
    };
  }
}

// apps/web/src/features/user/create-user.tsx
import { useState } from 'react';
import { UserCreateInput } from '@my-org/dto';
import { Button } from '@my-org/ui';

export function CreateUserForm() {
  const [formData, setFormData] = useState<UserCreateInput>({
    email: '',
    username: '',
    password: '',
    profile: {
      firstName: '',
      lastName: ''
    }
  });
  
  // Form handling logic...
  
  return (
    <form>
      {/* Form fields */}
      <Button type="submit">Create User</Button>
    </form>
  );
}
```

#### Example of Managing Dependencies

```json
// Root package.json
{
  "name": "my-fullstack-app",
  "version": "0.0.0",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev",
    "lint": "turbo run lint",
    "test": "turbo run test",
    "clean": "turbo run clean && rm -rf node_modules"
  },
  "devDependencies": {
    "@typescript-eslint/eslint-plugin": "^5.59.0",
    "@typescript-eslint/parser": "^5.59.0",
    "eslint": "^8.38.0",
    "eslint-config-prettier": "^8.8.0",
    "prettier": "^2.8.7",
    "turbo": "^1.9.3",
    "typescript": "^5.0.4"
  },
  "engines": {
    "node": ">=16.0.0"
  },
  "packageManager": "pnpm@8.0.0"
}

// turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"]
    },
    "lint": {
      "outputs": []
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": ["coverage/**"],
      "inputs": ["src/**/*.tsx", "src/**/*.ts", "test/**/*.ts", "test/**/*.tsx"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "clean": {
      "cache": false
    }
  }
}

// packages/ui/package.json
{
  "name": "@my-org/ui",
  "version": "0.1.0",
  "main": "./dist/index.js",
  "module": "./dist/index.mjs",
  "types": "./dist/index.d.ts",
  "files": ["dist"],
  "scripts": {
    "build": "tsup src/index.ts --format esm,cjs --dts",
    "dev": "tsup src/index.ts --format esm,cjs --watch --dts",
    "lint": "eslint src/",
    "test": "jest",
    "clean": "rm -rf dist .turbo node_modules"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.0.38",
    "@types/react-dom": "^18.0.11",
    "tsup": "^6.7.0",
    "typescript": "^5.0.4"
  }
}

// apps/web/package.json
{
  "name": "@my-org/web",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint src/",
    "test": "vitest run",
    "clean": "rm -rf dist .turbo node_modules"
  },
  "dependencies": {
    "@my-org/ui": "workspace:*",
    "@my-org/dto": "workspace:*",
    "@my-org/utils": "workspace:*",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.10.0",
    "axios": "^1.3.6"
  },
  "devDependencies": {
    "@types/react": "^18.0.38",
    "@types/react-dom": "^18.0.11",
    "@vitejs/plugin-react": "^3.1.0",
    "typescript": "^5.0.4",
    "vite": "^4.3.1",
    "vitest": "^0.30.1"
  }
}
```

### Testing in TypeScript Monorepos

#### Test Setup Strategies

Creating consistent test environments across packages is crucial:

```typescript
// packages/test-utils/src/setup.ts
import { afterEach } from 'vitest';
import { cleanup } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

// Global teardown
afterEach(() => {
  cleanup();
});

// Global mocks
global.fetch = vi.fn();
```

#### Component Testing

```typescript
// packages/ui/src/button/__tests__/button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '../button';

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button')).toHaveTextContent('Click me');
  });

  it('calls onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

#### Integration Testing

```typescript
// apps/web/src/features/auth/__tests__/login.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { LoginForm } from '../login-form';
import { AuthProvider } from '../../../context/auth-context';

vi.mock('@my-org/api-client', () => ({
  login: vi.fn().mockResolvedValue({ token: 'fake-token' })
}));

describe('LoginForm', () => {
  it('submits credentials and redirects on success', async () => {
    render(
      <AuthProvider>
        <LoginForm />
      </AuthProvider>
    );
    
    fireEvent.change(screen.getByLabelText('Email'), {
      target: { value: 'user@example.com' }
    });
    
    fireEvent.change(screen.getByLabelText('Password'), {
      target: { value: 'password123' }
    });
    
    fireEvent.click(screen.getByRole('button', { name: /sign in/i }));
    
    await waitFor(() => {
      expect(window.location.pathname).toBe('/dashboard');
    });
  });
});
```

### Deploying TypeScript Monorepos

#### Build Optimization for Deployment

```json
// packages/tsconfig.build.json
{
  "extends": "../tsconfig.base.json",
  "compilerOptions": {
    "noEmit": false,
    "sourceMap": false,
    "declaration": true
  }
}
```

#### Deployment Scripts

```bash
#!/bin/bash
# scripts/deploy-api.sh

# Build the API and its dependencies
pnpm turbo run build --filter=@my-org/api...

# Copy deployment files
cp -r apps/api/dist/ deployment/
cp apps/api/package.json deployment/
cp apps/api/Dockerfile deployment/

# Execute deployment (e.g., to a cloud provider)
cd deployment && docker build -t my-api:latest . && docker push my-api:latest
```

#### Continuous Deployment Example

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - uses: pnpm/action-setup@v2
        with:
          version: 8
      - uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'pnpm'
      
      - name: Install dependencies
        run: pnpm install
      
      - name: Build affected apps
        run: pnpm turbo run build --filter=[HEAD^1]...
      
      - name: Deploy API
        if: ${{ contains(steps.filter.outputs.changes, 'apps/api') }}
        run: ./scripts/deploy-api.sh
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      
      - name: Deploy Web
        if: ${{ contains(steps.filter.outputs.changes, 'apps/web') }}
        run: ./scripts/deploy-web.sh
        env:
          VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
```

### Advanced Monorepo Patterns

#### Module Federation

For large applications that need to be split into micro-frontends:

```javascript
// apps/shell/webpack.config.js
const { ModuleFederationPlugin } = require('webpack').container;

module.exports = {
  // ... webpack config
  plugins: [
    new ModuleFederationPlugin({
      name: 'shell',
      remotes: {
        dashboard: 'dashboard@http://localhost:3001/remoteEntry.js',
        profile: 'profile@http://localhost:3002/remoteEntry.js'
      },
      shared: {
        react: { singleton: true },
        'react-dom': { singleton: true }
      }
    })
  ]
};
```

#### Architectural Boundaries

```typescript
// packages/domain/src/user/index.ts
// Domain layer - business logic

export class User {
  constructor(
    public readonly id: string,
    public readonly email: string,
    public readonly username: string,
    private _isActive: boolean = false
  ) {}

  activate() {
    this._isActive = true;
    return this;
  }

  deactivate() {
    this._isActive = false;
    return this;
  }

  get isActive() {
    return this._isActive;
  }
}

// packages/infrastructure/src/repositories/user.repository.ts
// Infrastructure layer - data access

import { User } from '@my-org/domain';
import { PrismaClient } from '@prisma/client';

export class UserRepository {
  constructor(private prisma: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    const userData = await this.prisma.user.findUnique({
      where: { id }
    });

    if (!userData) return null;

    return new User(
      userData.id,
      userData.email,
      userData.username,
      userData.isActive
    );
  }
}
```

#### Feature Toggles

```typescript
// packages/config/src/features.ts
export const FEATURES = {
  NEW_USER_FLOW: process.env.FEATURE_NEW_USER_FLOW === 'true',
  BETA_DASHBOARD: process.env.FEATURE_BETA_DASHBOARD === 'true',
  DARK_MODE: true
};

// apps/web/src/components/user-registration.tsx
import { FEATURES } from '@my-org/config';
import { NewUserFlow } from './new-user-flow';
import { LegacyUserFlow } from './legacy-user-flow';

export function UserRegistration() {
  return FEATURES.NEW_USER_FLOW ? <NewUserFlow /> : <LegacyUserFlow />;
}
```

### Migration Strategies

#### Gradually Adopting a Monorepo

1. Start with a core package
2. Move shared code to separate packages
3. Establish clear dependencies between packages
4. Implement proper tooling

#### Migrating from JavaScript to TypeScript

1. Add TypeScript as a dev dependency
2. Create initial tsconfig.json
3. Rename files from .js to .ts (or .jsx to .tsx)
4. Add type definitions incrementally
5. Enable stricter TypeScript settings over time

#### Example Migration Plan

```
Phase 1: Setup & Infrastructure
- Set up monorepo tooling
- Create base tsconfig files
- Establish CI/CD pipelines

Phase 2: Core Libraries
- Migrate common utilities to TypeScript
- Create shared type definitions
- Update build processes

Phase 3: Applications
- Migrate applications one by one
- Update import paths to use workspace references
- Implement comprehensive testing

Phase 4: Optimization
- Optimize build performance
- Implement caching strategies
- Deploy with proper bundling and minification
```

### Conclusion

TypeScript monorepos provide substantial benefits for managing complex applications with multiple packages. By leveraging the type system across package boundaries, teams can build more maintainable and robust applications. The tools and patterns presented here offer a solid foundation for implementing your own TypeScript monorepo strategy.

When implemented correctly, a TypeScript monorepo can:

- Enforce type safety across package boundaries
- Simplify dependency management
- Enable code sharing while maintaining clear boundaries
- Improve developer experience with faster builds
- Enhance collaboration between teams working on different packages

**Key Points**:

- Choose the right tools based on your project scale (Nx for large projects, Turborepo for simpler setups)
- Establish clear architectural boundaries between packages
- Use project references to improve build performance
- Implement comprehensive testing across package boundaries
- Adopt incremental migration strategies when converting existing projects

### Additional Resources

- TypeScript Project References: [Official Documentation](https://www.typescriptlang.org/docs/handbook/project-references.html)
- Nx Documentation: [nx.dev](https://nx.dev/)
- Turborepo Documentation: [turbo.build](https://turbo.build/)
- pnpm Workspaces: [pnpm.io/workspaces](https://pnpm.io/workspaces)
- Microsoft's API Extractor: [api-extractor.com](https://api-extractor.com/)

---

