# Complete Zod Schema Validation Guide

## Installation and Setup

```bash
npm install zod
# or
yarn add zod
# or
pnpm add zod
```

```typescript
import { z } from 'zod';
```

## Basic Schema Types

### Primitive Types

```typescript
// String
const stringSchema = z.string();

// Number
const numberSchema = z.number();

// Boolean
const booleanSchema = z.boolean();

// Date
const dateSchema = z.date();

// BigInt
const bigintSchema = z.bigint();

// Symbol
const symbolSchema = z.symbol();

// Undefined
const undefinedSchema = z.undefined();

// Null
const nullSchema = z.null();

// Void
const voidSchema = z.void();

// Any
const anySchema = z.any();

// Unknown
const unknownSchema = z.unknown();

// Never
const neverSchema = z.never();
```

### String Validations

```typescript
const stringSchema = z.string()
  .min(1, "String must not be empty")
  .max(100, "String too long")
  .email("Invalid email format")
  .url("Invalid URL format")
  .uuid("Invalid UUID format")
  .regex(/^[a-zA-Z]+$/, "Only letters allowed")
  .startsWith("prefix")
  .endsWith("suffix")
  .includes("substring")
  .trim() // removes whitespace
  .toLowerCase()
  .toUpperCase();

// Custom string validations
const customString = z.string().refine(
  (val) => val.length >= 8 && /[A-Z]/.test(val) && /[0-9]/.test(val),
  {
    message: "Password must be at least 8 characters with uppercase and number"
  }
);
```

### Number Validations

```typescript
const numberSchema = z.number()
  .min(0, "Must be non-negative")
  .max(100, "Must be at most 100")
  .int("Must be an integer")
  .positive("Must be positive")
  .negative("Must be negative")
  .nonnegative("Must be non-negative")
  .nonpositive("Must be non-positive")
  .finite("Must be finite")
  .safe("Must be a safe integer")
  .multipleOf(5, "Must be multiple of 5");
```

### Array Schemas

```typescript
// Basic array
const stringArray = z.array(z.string());

// Array with constraints
const constrainedArray = z.array(z.string())
  .min(1, "Array must not be empty")
  .max(10, "Array too large")
  .length(5, "Array must have exactly 5 items")
  .nonempty("Array must not be empty");

// Non-empty array shorthand
const nonEmptyArray = z.string().array().nonempty();
```

### Object Schemas

```typescript
// Basic object
const userSchema = z.object({
  id: z.number(),
  name: z.string(),
  email: z.string().email(),
  age: z.number().optional(),
  isActive: z.boolean().default(true)
});

// Nested objects
const addressSchema = z.object({
  street: z.string(),
  city: z.string(),
  zipCode: z.string()
});

const userWithAddressSchema = z.object({
  id: z.number(),
  name: z.string(),
  address: addressSchema
});

// Object methods
const extendedSchema = userSchema
  .extend({
    createdAt: z.date()
  })
  .partial() // makes all properties optional
  .pick({ id: true, name: true }) // select specific properties
  .omit({ age: true }) // exclude specific properties
  .passthrough() // allow additional properties
  .strict() // disallow additional properties
  .strip(); // remove additional properties

// Record type (dictionary/map)
const recordSchema = z.record(z.string(), z.number()); // { [key: string]: number }
const keyedRecordSchema = z.record(z.enum(['a', 'b', 'c']), z.string());
```

## Advanced Schema Types

### Union Types

```typescript
// Union (OR)
const stringOrNumber = z.union([z.string(), z.number()]);
// Shorthand
const stringOrNumberShort = z.string().or(z.number());

// Discriminated union
const shapeSchema = z.discriminatedUnion('type', [
  z.object({ type: z.literal('circle'), radius: z.number() }),
  z.object({ type: z.literal('rectangle'), width: z.number(), height: z.number() })
]);
```

### Intersection Types

```typescript
// Intersection (AND)
const nameSchema = z.object({ name: z.string() });
const ageSchema = z.object({ age: z.number() });
const personSchema = z.intersection(nameSchema, ageSchema);
// Shorthand
const personSchemaShort = nameSchema.and(ageSchema);
```

### Literal and Enum Types

```typescript
// Literal values
const literalSchema = z.literal("hello");
const numberLiteral = z.literal(42);

// Enum
const colorEnum = z.enum(['red', 'green', 'blue']);
const nativeEnum = z.nativeEnum(MyEnum); // for TypeScript enums

// Multiple literals
const statusSchema = z.union([
  z.literal('pending'),
  z.literal('approved'),
  z.literal('rejected')
]);
```

### Tuple Types

```typescript
// Fixed-length array with specific types
const tupleSchema = z.tuple([z.string(), z.number(), z.boolean()]);

// Tuple with rest element
const tupleWithRest = z.tuple([z.string(), z.number()]).rest(z.boolean());
```

### Optional and Nullable

```typescript
const schema = z.object({
  required: z.string(),
  optional: z.string().optional(),
  nullable: z.string().nullable(),
  nullish: z.string().nullish(), // optional and nullable
  withDefault: z.string().default("default value"),
  withDefaultFunction: z.date().default(() => new Date())
});
```

## Schema Validation

### Basic Parsing

```typescript
const userSchema = z.object({
  name: z.string(),
  age: z.number()
});

// Safe parsing (returns result object)
const result = userSchema.safeParse({ name: "John", age: 30 });

if (result.success) {
  console.log(result.data); // { name: "John", age: 30 }
} else {
  console.log(result.error.issues); // validation errors
}

// Direct parsing (throws on error)
try {
  const user = userSchema.parse({ name: "John", age: 30 });
  console.log(user);
} catch (error) {
  console.log(error.issues);
}
```

### Async Validation

```typescript
const asyncSchema = z.string().refine(async (val) => {
  // Simulate async validation (e.g., checking if username exists)
  const exists = await checkUsernameExists(val);
  return !exists;
}, "Username already exists");

// Use parseAsync or safeParseAsync
const result = await asyncSchema.safeParseAsync("username");
```

## Custom Validation and Transformations

### Custom Validation with Refine

```typescript
const passwordSchema = z.string()
  .refine((val) => val.length >= 8, {
    message: "Password must be at least 8 characters"
  })
  .refine((val) => /[A-Z]/.test(val), {
    message: "Password must contain uppercase letter"
  })
  .refine((val) => /[0-9]/.test(val), {
    message: "Password must contain a number"
  });

// Multiple field validation
const userSchema = z.object({
  password: z.string(),
  confirmPassword: z.string()
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ["confirmPassword"] // specify which field the error applies to
});
```

### Transformations

```typescript
// Transform data during validation
const stringToNumber = z.string().transform((val) => parseInt(val, 10));

const userSchema = z.object({
  name: z.string().transform((val) => val.trim().toLowerCase()),
  age: z.string().transform((val) => parseInt(val, 10)),
  email: z.string().email().transform((val) => val.toLowerCase()),
  tags: z.string().transform((val) => val.split(',').map(tag => tag.trim()))
});

// Preprocess before validation
const preprocessedSchema = z.preprocess(
  (val) => typeof val === "string" ? parseInt(val, 10) : val,
  z.number()
);
```

### Superrefine for Complex Validation

```typescript
const schema = z.object({
  startDate: z.date(),
  endDate: z.date()
}).superRefine((data, ctx) => {
  if (data.startDate >= data.endDate) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: "End date must be after start date",
      path: ["endDate"]
    });
  }
});
```

## Error Handling

### Custom Error Messages

```typescript
const schema = z.object({
  email: z.string({
    required_error: "Email is required",
    invalid_type_error: "Email must be a string"
  }).email("Please enter a valid email address"),
  
  age: z.number({
    required_error: "Age is required",
    invalid_type_error: "Age must be a number"
  }).min(18, "Must be at least 18 years old")
});
```

### Error Formatting

```typescript
const result = schema.safeParse(invalidData);

if (!result.success) {
  // Access individual issues
  result.error.issues.forEach(issue => {
    console.log(`${issue.path.join('.')}: ${issue.message}`);
  });

  // Format errors for forms
  const fieldErrors = result.error.flatten();
  console.log(fieldErrors.fieldErrors);
  
  // Custom error formatting
  const customErrors = result.error.format();
  console.log(customErrors);
}
```

## TypeScript Integration

### Type Inference

```typescript
const userSchema = z.object({
  id: z.number(),
  name: z.string(),
  email: z.string().email(),
  age: z.number().optional()
});

// Infer TypeScript type from schema
type User = z.infer<typeof userSchema>;
// Type is: { id: number; name: string; email: string; age?: number }

// Input type (before parsing/transformation)
type UserInput = z.input<typeof userSchema>;

// Output type (after parsing/transformation)
type UserOutput = z.output<typeof userSchema>;
```

### Generic Schemas

```typescript
function createPageSchema<T extends z.ZodTypeAny>(itemSchema: T) {
  return z.object({
    items: z.array(itemSchema),
    total: z.number(),
    page: z.number(),
    limit: z.number()
  });
}

const userPageSchema = createPageSchema(userSchema);
type UserPage = z.infer<typeof userPageSchema>;
```

## Common Patterns and Use Cases

### Form Validation

```typescript
const loginFormSchema = z.object({
  email: z.string()
    .min(1, "Email is required")
    .email("Invalid email format"),
  password: z.string()
    .min(8, "Password must be at least 8 characters")
    .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, 
      "Password must contain uppercase, lowercase, and number"),
  rememberMe: z.boolean().default(false)
});

// Usage with form libraries
function handleSubmit(formData: FormData) {
  const result = loginFormSchema.safeParse({
    email: formData.get('email'),
    password: formData.get('password'),
    rememberMe: formData.get('rememberMe') === 'on'
  });

  if (!result.success) {
    // Handle validation errors
    return { errors: result.error.flatten() };
  }

  // Process valid data
  return { data: result.data };
}
```

### API Response Validation

```typescript
const apiResponseSchema = z.object({
  success: z.boolean(),
  data: z.array(z.object({
    id: z.number(),
    title: z.string(),
    createdAt: z.string().transform((str) => new Date(str))
  })),
  meta: z.object({
    total: z.number(),
    page: z.number(),
    limit: z.number()
  })
});

async function fetchData() {
  const response = await fetch('/api/data');
  const json = await response.json();
  
  const result = apiResponseSchema.safeParse(json);
  if (!result.success) {
    throw new Error('Invalid API response format');
  }
  
  return result.data;
}
```

### Environment Variable Validation

```typescript
const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  PORT: z.string().transform((val) => parseInt(val, 10)),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  REDIS_URL: z.string().url().optional()
});

const env = envSchema.parse(process.env);
// Now env is fully typed and validated
```

### Configuration Schema

```typescript
const configSchema = z.object({
  app: z.object({
    name: z.string(),
    version: z.string(),
    port: z.number().default(3000)
  }),
  database: z.object({
    host: z.string(),
    port: z.number(),
    name: z.string(),
    ssl: z.boolean().default(false)
  }),
  features: z.object({
    auth: z.boolean().default(true),
    analytics: z.boolean().default(false)
  }).default({})
}).default({});

const config = configSchema.parse(userConfig);
```

## Performance Tips

1. **Reuse schemas**: Create schemas once and reuse them instead of recreating
    
2. **Use lazy evaluation** for recursive schemas:
    
    ```typescript
    const categorySchema: z.ZodType<Category> = z.lazy(() =>
      z.object({
        id: z.number(),
        name: z.string(),
        parent: categorySchema.optional()
      })
    );
    ```
    
3. **Prefer safeParse**: Use `safeParse` instead of `parse` to avoid throwing exceptions
    
4. **Cache compiled schemas**: In performance-critical applications, consider caching
    

## Best Practices

1. **Define schemas close to usage**: Keep schemas near the code that uses them
2. **Use descriptive error messages**: Provide clear, user-friendly error messages
3. **Validate at boundaries**: Validate data when it enters your system (API endpoints, form submissions)
4. **Type-first approach**: Use Zod's inferred types throughout your application
5. **Compose schemas**: Build complex schemas from simpler ones for reusability
6. **Document schemas**: Add comments explaining complex validation logic
7. **Test your schemas**: Write tests for your validation logic
8. **Use strict mode**: Enable strict mode for objects when you want to prevent extra properties

This guide covers the essential concepts and patterns you'll need to effectively use Zod for schema validation in your TypeScript applications.