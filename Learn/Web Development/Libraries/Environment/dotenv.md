# Comprehensive Guide to dotenv

---

## What is dotenv?

dotenv is a zero-dependency Node.js module that loads environment variables from a `.env` file into `process.env`. It allows you to separate configuration from code — a practice outlined in the [Twelve-Factor App](https://12factor.net/config) methodology.

Rather than hardcoding values like database URLs, API keys, or port numbers into source files, you store them in a `.env` file that is excluded from version control.

---

## Installation

```bash
npm install dotenv
```

---

## Basic Usage

### Create a `.env` file

```env
PORT=3000
DATABASE_URL=postgres://localhost:5432/mydb
API_KEY=abc123
NODE_ENV=development
```

### Load it at the entry point of your application

```js
// As early as possible — typically the first lines of your entry file
require('dotenv').config();

console.log(process.env.PORT);        // '3000'
console.log(process.env.DATABASE_URL); // 'postgres://localhost:5432/mydb'
```

### ES Modules

```js
import 'dotenv/config';
// or
import dotenv from 'dotenv';
dotenv.config();
```

### The Return Value

`dotenv.config()` returns an object with either a `parsed` key (on success) or an `error` key:

```js
const result = require('dotenv').config();

if (result.error) {
  throw result.error;
}

console.log(result.parsed); // { PORT: '3000', DATABASE_URL: '...', ... }
```

---

## .env File Syntax

### Key-Value Pairs

```env
KEY=value
```

### Quoted Values

Quotes are optional for most values. Use them when the value contains spaces or special characters:

```env
GREETING="Hello, World"
MESSAGE='Single quoted value'
```

Surrounding quotes are stripped from the parsed value.

### Inline Comments

```env
PORT=3000  # This is a comment
API_KEY=abc123  # Comments after values are supported
```

Inline comments require a space before the `#`.

### Multi-line Values

Use double quotes and a literal newline:

```env
PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA...
-----END RSA PRIVATE KEY-----"
```

Or use `\n` escape sequences (requires `multiline` option — see Options):

```env
PRIVATE_KEY="line one\nline two"
```

### Empty Values

```env
EMPTY=
ALSO_EMPTY=""
```

Both result in an empty string `''`.

### Variable Expansion

dotenv does not expand variables by default. Use `dotenv-expand` for that (see Expanding Variables).

---

## Options

`dotenv.config()` accepts an options object:

```js
require('dotenv').config({
  path: './.env.local',       // Custom path (default: '.env' in cwd)
  encoding: 'utf8',           // File encoding (default: 'utf8')
  debug: true,                // Log debug info to console (default: false)
  override: true,             // Override existing process.env values (default: false)
  processEnv: myCustomObj,    // Load into a custom object instead of process.env
});
```

### `path`

Load a different file:

```js
require('dotenv').config({ path: '/absolute/path/to/.env' });
```

Load multiple files (dotenv >= 16.1):

```js
require('dotenv').config({ path: ['.env.local', '.env'] });
```

Files are processed left to right. Earlier files take precedence when `override` is false (default).

### `override`

By default, dotenv does not overwrite variables already set in `process.env`. Set `override: true` to force overwriting:

```js
require('dotenv').config({ override: true });
```

This is useful in testing when you want the `.env` file to take precedence over shell-level variables.

### `debug`

Logs which keys were loaded and which were skipped:

```js
require('dotenv').config({ debug: true });
// [dotenv][DEBUG] "PORT" was pre-defined and was NOT overwritten
```

### `processEnv`

Load variables into a custom object instead of `process.env`:

```js
const myConfig = {};
require('dotenv').config({ processEnv: myConfig });

console.log(myConfig.PORT); // '3000'
console.log(process.env.PORT); // undefined
```

---

## Parsing Without Loading

Use `dotenv.parse()` to parse a `.env`-formatted string or buffer without writing to `process.env`:

```js
const dotenv = require('dotenv');
const fs = require('fs');

const buf = fs.readFileSync('.env');
const config = dotenv.parse(buf);

console.log(config); // { PORT: '3000', API_KEY: 'abc123', ... }
```

Or from a string:

```js
const config = dotenv.parse('PORT=3000\nAPI_KEY=abc123');
console.log(config.PORT); // '3000'
```

This is useful for reading `.env` files in scripts, build tools, or configuration loaders without side effects.

---

## Expanding Variables

dotenv does not expand variable references by default. Install `dotenv-expand`:

```bash
npm install dotenv-expand
```

```env
BASE_URL=https://api.example.com
USERS_URL=${BASE_URL}/users
AUTH_URL=${BASE_URL}/auth
HOME=/home/user
CONFIG_PATH=${HOME}/.config
```

```js
const dotenv = require('dotenv');
const dotenvExpand = require('dotenv-expand');

const config = dotenv.config();
dotenvExpand.expand(config);

console.log(process.env.USERS_URL); // 'https://api.example.com/users'
console.log(process.env.CONFIG_PATH); // '/home/user/.config'
```

Expansion also works with existing `process.env` variables:

```env
# If NODE_ENV is already set in the shell, this references it
LOG_LEVEL=${NODE_ENV}_verbose
```

---

## Multiple Environments

A common pattern is to maintain separate `.env` files per environment:

```
.env              # Default / shared values
.env.local        # Local overrides (not committed)
.env.development  # Development-specific
.env.test         # Test-specific
.env.production   # Production-specific
```

Load the appropriate file based on `NODE_ENV`:

```js
const path = require('path');
require('dotenv').config({
  path: path.resolve(__dirname, `.env.${process.env.NODE_ENV || 'development'}`),
});
```

Or load multiple with fallback ordering (dotenv >= 16.1):

```js
require('dotenv').config({
  path: [
    `.env.${process.env.NODE_ENV}.local`,
    `.env.${process.env.NODE_ENV}`,
    '.env.local',
    '.env',
  ],
});
```

### What to Commit

|File|Commit?|
|---|---|
|`.env`|Only if it contains no secrets and only safe defaults|
|`.env.example`|Yes — documents all required keys with dummy values|
|`.env.local`|No|
|`.env.*.local`|No|
|`.env.production`|No — never commit production secrets|

Always add sensitive `.env` files to `.gitignore`:

```
# .gitignore
.env
.env.local
.env.*.local
.env.production
```

---

## .env.example

Maintain a `.env.example` (or `.env.template`) file committed to version control. It documents all required environment variables with placeholder values:

```env
# .env.example
PORT=3000
DATABASE_URL=postgres://localhost:5432/your_db_name
API_KEY=your_api_key_here
JWT_SECRET=your_jwt_secret_here
NODE_ENV=development
```

New contributors copy this file and fill in real values:

```bash
cp .env.example .env
```

---

## Preloading Without Code Changes

You can load dotenv before your application starts without modifying source files using Node's `--require` flag:

```bash
node --require dotenv/config server.js
```

Pass options via environment variables:

```bash
DOTENV_CONFIG_PATH=./.env.local DOTENV_CONFIG_DEBUG=true node --require dotenv/config server.js
```

This is especially useful for scripts or when you cannot modify the entry file.

---

## Using with TypeScript

dotenv works with TypeScript with no extra packages needed:

```ts
import * as dotenv from 'dotenv';
dotenv.config();

const port: string | undefined = process.env.PORT;
```

### Typed Environment Variables

`process.env` values are always `string | undefined`. A common pattern is to validate and cast them at startup:

```ts
// env.ts
import * as dotenv from 'dotenv';
dotenv.config();

function requireEnv(key: string): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
}

export const config = {
  port: parseInt(requireEnv('PORT'), 10),
  databaseUrl: requireEnv('DATABASE_URL'),
  apiKey: requireEnv('API_KEY'),
  nodeEnv: process.env.NODE_ENV ?? 'development',
};
```

### With zod (Schema Validation)

```bash
npm install zod
```

```ts
import { z } from 'zod';
import * as dotenv from 'dotenv';
dotenv.config();

const envSchema = z.object({
  PORT: z.string().regex(/^\d+$/).transform(Number),
  DATABASE_URL: z.string().url(),
  API_KEY: z.string().min(1),
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('Invalid environment variables:', parsed.error.format());
  process.exit(1);
}

export const env = parsed.data;
```

---

## Using with Testing (Mocha / Jest)

### Jest

Load dotenv in `setupFiles` or a global setup file:

```js
// jest.config.js
module.exports = {
  setupFiles: ['dotenv/config'],
};
```

Or use a specific test env file:

```js
// jest.config.js
module.exports = {
  setupFiles: ['<rootDir>/test/loadEnv.js'],
};
```

```js
// test/loadEnv.js
require('dotenv').config({ path: '.env.test' });
```

### Mocha

```js
// .mocharc.js
module.exports = {
  require: ['dotenv/config'],
};
```

Or with a custom path:

```js
// test/setup.js
require('dotenv').config({ path: '.env.test' });
```

```js
// .mocharc.js
module.exports = {
  require: ['./test/setup.js'],
};
```

---

## Using with Popular Frameworks

### Express

```js
// server.js — require dotenv before anything else
require('dotenv').config();

const express = require('express');
const app = express();

app.listen(process.env.PORT || 3000);
```

### Next.js

Next.js has built-in `.env` support and does not require dotenv directly. It loads `.env`, `.env.local`, `.env.development`, `.env.production` automatically. See Next.js docs for details.

### Vite

Vite also has built-in `.env` support via `import.meta.env`. Variables must be prefixed with `VITE_` to be exposed to the client. dotenv is not needed in Vite projects for standard use.

### NestJS

```ts
// app.module.ts
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
  ],
})
export class AppModule {}
```

NestJS's `ConfigModule` wraps dotenv internally.

---

## Security Considerations

### Never commit secrets

Add all files containing real secrets to `.gitignore`. Assume that any file committed to version control will eventually be seen by others.

### Do not expose `.env` files over HTTP

If your project has a static file server, ensure `.env` files are not in the public directory and are not served as static assets.

### Validate environment variables at startup

Do not assume a variable exists. Check for required variables before your application starts serving requests (see the `requireEnv` pattern above, or use a library like `envalid` or `zod`).

### Production environments

In production, prefer setting environment variables via your platform's native mechanism (e.g. Heroku Config Vars, AWS Secrets Manager, Kubernetes Secrets, Docker secrets) rather than deploying a `.env` file. dotenv is primarily a development convenience tool.

### Avoid logging `process.env`

```js
// Do not do this in production
console.log(process.env);
```

This can expose secrets in log output.

---

## Alternatives and Related Packages

### dotenv-safe

Throws an error if any variable defined in `.env.example` is missing from the actual environment. Useful for enforcing that all required variables are present:

```bash
npm install dotenv-safe
```

```js
require('dotenv-safe').config();
```

### dotenv-expand

Adds variable expansion to dotenv (covered above).

### envalid

A library for validating and parsing environment variables with built-in type coercion:

```bash
npm install envalid
```

```js
const { cleanEnv, str, port, url } = require('envalid');

const env = cleanEnv(process.env, {
  PORT: port({ default: 3000 }),
  DATABASE_URL: url(),
  API_KEY: str(),
});
```

### t3-env

Type-safe environment variable validation using zod, popular in the T3 stack (Next.js + TypeScript projects).

### Node.js Built-in (>= v20.6)

Node.js 20.6 introduced experimental built-in `.env` file loading:

```bash
node --env-file=.env server.js
```

This does not require the dotenv package. As of Node 22, the flag is no longer experimental. However, it has fewer features than dotenv (no variable expansion, no multi-file loading, no `parse()` utility).

---

## Common Pitfalls

### All values are strings

`process.env` values are always strings, regardless of what you write in `.env`:

```env
PORT=3000
DEBUG=true
MAX_RETRIES=5
```

```js
typeof process.env.PORT        // 'string', not number
typeof process.env.DEBUG       // 'string', not boolean
process.env.DEBUG === true     // false — always use === 'true'
```

Always coerce values explicitly:

```js
const port = parseInt(process.env.PORT, 10);
const debug = process.env.DEBUG === 'true';
```

### Calling `config()` too late

If you access `process.env` values before calling `dotenv.config()`, they will be undefined. Always call `config()` as early as possible — before importing other modules that read `process.env` at module load time.

### Variables already set in the shell are not overwritten by default

If `PORT` is already set in your shell environment, dotenv will not overwrite it unless `override: true` is passed. This is intentional but can cause confusion.

### `.env` file not found silently

By default, dotenv does not throw if the `.env` file does not exist — it silently returns `{ error: ... }`. Check the return value if you need to assert the file exists:

```js
const result = require('dotenv').config();
if (result.error) {
  console.warn('No .env file found');
}
```

### Spaces around `=`

```env
PORT = 3000   # Parsed as '3000' — spaces around = are trimmed
```

Spaces around `=` are trimmed by dotenv. This is fine but can look misleading.