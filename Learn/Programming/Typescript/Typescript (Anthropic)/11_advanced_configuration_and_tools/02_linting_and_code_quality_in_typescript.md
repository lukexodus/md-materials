## Linting and Code Quality in TypeScript


### Understanding Linting in TypeScript

Linting is the process of analyzing code for potential errors, code style violations, and suspicious constructs. In TypeScript projects, linting enhances code quality by enforcing consistent coding practices and identifying issues before runtime.

**Key Points**

- Linting catches syntax errors and potential bugs
- Enforces consistent coding standards across team members
- Identifies TypeScript-specific issues like improper type usage
- Integrates with IDEs and CI/CD pipelines for continuous code quality

### ESLint with TypeScript

ESLint has become the standard linting tool for TypeScript projects, replacing TSLint which was deprecated in 2019.

#### Setting Up ESLint with TypeScript

To set up ESLint with TypeScript:

```bash
npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

Create a `.eslintrc.js` configuration file:

```javascript
module.exports = {
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended'
  ],
  rules: {
    // Custom rules here
  }
};
```

#### Popular TypeScript ESLint Configurations

Several pre-configured rule sets are available:

- `eslint:recommended` - ESLint's built-in recommended rules
- `plugin:@typescript-eslint/recommended` - TypeScript-specific recommended rules
- `plugin:@typescript-eslint/recommended-requiring-type-checking` - Stricter rules that require type information

#### Type-Aware Linting

One major advantage of ESLint with TypeScript is type-aware linting:

```javascript
parserOptions: {
  project: './tsconfig.json', // Path to your TypeScript configuration
  tsconfigRootDir: __dirname,
}
```

This enables rules that leverage TypeScript's type system to catch more sophisticated issues.

### TSLint (Legacy)

TSLint was the original TypeScript linter but has been deprecated in favor of ESLint.

#### Migration from TSLint to ESLint

For projects still using TSLint:

```bash
npx tslint-to-eslint-config
```

This tool helps convert TSLint configurations to ESLint equivalents.

#### Why TSLint Was Deprecated

- Community consolidation around ESLint
- Performance issues with TSLint
- Duplicate effort maintaining two linting ecosystems

### Custom Lint Rules

Creating custom lint rules allows teams to enforce project-specific conventions.

#### Creating a Custom ESLint Rule for TypeScript

```typescript
// my-custom-rule.js
module.exports = {
  meta: {
    type: "suggestion",
    docs: {
      description: "Enforce specific TypeScript pattern",
    },
    fixable: "code"
  },
  create: function(context) {
    return {
      // AST node visitors
      TSInterfaceDeclaration(node) {
        // Rule implementation
      }
    };
  }
};
```

#### Sharing Custom Rules with Teams

Custom rules can be packaged and shared:

```bash
npm init -y
npm install --save-dev eslint
```

Structure for a shareable configuration:

```
eslint-config-my-rules/
├── index.js
├── package.json
└── rules/
    └── my-custom-rule.js
```

### Integration with Development Workflow

#### IDE Integration

Most modern IDEs support ESLint with TypeScript:

- VS Code: ESLint extension
- WebStorm: Built-in support
- Vim/Neovim: ALE or CoC ESLint

#### Pre-commit Hooks

Using Husky and lint-staged:

```json
// package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.{ts,tsx}": "eslint --fix"
  }
}
```

#### CI/CD Pipeline Integration

Example GitHub Actions workflow:

```yaml
name: Lint

on: [push, pull_request]

jobs:
  eslint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '16'
      - run: npm ci
      - run: npm run lint
```

### Advanced ESLint Configuration

#### Combining with Prettier

```bash
npm install --save-dev eslint-config-prettier eslint-plugin-prettier prettier
```

`.eslintrc.js` configuration:

```javascript
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'prettier',
    'plugin:prettier/recommended'
  ],
  // Other configuration...
};
```

#### Project-Specific Rule Overrides

```javascript
module.exports = {
  // Base rules...
  overrides: [
    {
      files: ['src/legacy/**/*.ts'],
      rules: {
        '@typescript-eslint/no-explicit-any': 'off'
      }
    },
    {
      files: ['src/components/**/*.tsx'],
      rules: {
        'react/prop-types': 'off'
      }
    }
  ]
};
```

### Performance Optimization

#### Caching ESLint Results

```bash
eslint --cache --cache-location ./node_modules/.cache/eslint/ src/
```

Or in `package.json`:

```json
{
  "scripts": {
    "lint": "eslint --cache --cache-location ./node_modules/.cache/eslint/ src/"
  }
}
```

#### Selective Linting

For large codebases:

```bash
eslint --ext .ts,.tsx src/components
```

### Common TypeScript-Specific Rules

#### Strict Type Checking

```javascript
rules: {
  '@typescript-eslint/no-explicit-any': 'error',
  '@typescript-eslint/explicit-function-return-type': 'error',
  '@typescript-eslint/strict-boolean-expressions': 'error'
}
```

#### Nullability Handling

```javascript
rules: {
  '@typescript-eslint/no-non-null-assertion': 'error',
  '@typescript-eslint/no-unnecessary-condition': 'error'
}
```

### Industry Best Practices

#### Popular ESLint Configs for TypeScript

- AirBnB TypeScript: `eslint-config-airbnb-typescript`
- Google: `gts` (Google TypeScript Style)
- Standard with TypeScript: `eslint-config-standard-with-typescript`

#### Rule Categories for Different Project Types

- Libraries: Stricter rules for public APIs
- Applications: Focus on consistency and maintainability
- Monorepos: Configuration sharing with overrides for package-specific needs

### Troubleshooting

#### Common Issues and Solutions

1. Rules conflicting with Prettier:
    
    - Add `eslint-config-prettier` to turn off conflicting rules
2. Performance issues:
    
    - Use `--cache` flag
    - Run ESLint only on changed files
    - Disable resource-intensive rules selectively
3. False positives with type-aware linting:
    
    - Ensure tsconfig.json paths are correct
    - Check for excluded files in tsconfig.json

### Recommended Related Tools

- SonarQube/SonarLint - Static code analysis
- TypeScript Project References - For large codebases
- Rome - Unified frontend toolchain (linting, formatting, bundling)

---

