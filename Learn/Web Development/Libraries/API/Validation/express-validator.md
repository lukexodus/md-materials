# express-validator

## Overview

`express-validator` is a set of Express.js middleware wrapping the `validator.js` library. It provides a declarative API for validating and sanitizing request data — body fields, query parameters, route params, headers, and cookies — and collecting validation errors into a structured result.

**Source of truth:** [express-validator.github.io/docs](https://express-validator.github.io/docs)

---

## Installation

```bash
npm install express-validator
```

Peer dependency: `express` must already be installed. `validator.js` is bundled — no separate install needed.

---

## Core Concepts

express-validator operates in two phases: **declaration** and **extraction**.

- **Declaration** — you call chain methods (e.g., `body('field').isEmail()`) to describe rules. These return middleware functions.
- **Extraction** — after the middleware runs, you call `validationResult(req)` to retrieve any errors collected during that request.

Validation does not short-circuit the request by default. You must explicitly check errors and decide what to do with them.

---

## Importing

```js
const { body, query, param, header, cookie, validationResult, matchedData, checkSchema } = require('express-validator');
```

Or ESM:

```js
import { body, query, param, header, cookie, validationResult, matchedData, checkSchema } from 'express-validator';
```

---

## Location Functions

Each location function scopes validation to a specific part of the request.

|Function|Source|
|---|---|
|`body(field)`|`req.body`|
|`query(field)`|`req.query`|
|`param(field)`|`req.params`|
|`header(field)`|`req.headers`|
|`cookie(field)`|`req.cookies`|
|`check(field)`|All of the above|

```js
body('email')         // req.body.email
query('page')         // req.query.page
param('id')           // req.params.id
header('x-api-key')   // req.headers['x-api-key']
cookie('session')     // req.cookies.session
```

All location functions return a **ValidationChain**.

---

## ValidationChain

A `ValidationChain` is both a middleware and a fluent builder. You call methods on it to add validators and sanitizers, then pass it to your route handler as middleware.

```js
app.post('/register',
  body('username').notEmpty().isLength({ min: 3, max: 20 }),
  body('email').normalizeEmail().isEmail(),
  body('age').toInt().isInt({ min: 18 }),
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    res.send('ok');
  }
);
```

---

## Validators

### Existence Checks

```js
.exists()                  // field is present (not undefined)
.exists({ checkNull: true }) // also rejects null
.exists({ checkFalsy: true }) // rejects '', 0, null, undefined, false
.notEmpty()                // shorthand: rejects empty string ''
.optional()                // skips remaining validators if field is absent
.optional({ nullable: true }) // also skips if null
.optional({ checkFalsy: true }) // skips if falsy
```

`.optional()` must appear before other validators in the chain. It does not remove the field from the request — it only skips subsequent validators.

### String Validators

```js
.isLength({ min: 1, max: 100 })
.isAlpha()
.isAlphanumeric()
.isLowercase()
.isUppercase()
.contains('substring')
.matches(/regex/)
.matches('pattern', 'flags')
.isURL()
.isURL({ protocols: ['https'], require_tld: true })
.isEmail()
.isMobilePhone('en-PH')
.isIP()
.isIP('4')
.isUUID()
.isUUID('4')
.isSlug()
.isHexColor()
.isBase64()
.isJSON()
.isJWT()
.isDataURI()
.isMimeType()
.isPostalCode('PH')
.isCreditCard()
.isIBAN()
.isBIC()
.isISBN()
.isISBN('13')
.isISO8601()
.isRFC3339()
.isIn(['a', 'b', 'c'])
.isStrongPassword()
.isStrongPassword({
  minLength: 8,
  minLowercase: 1,
  minUppercase: 1,
  minNumbers: 1,
  minSymbols: 1
})
```

### Numeric Validators

```js
.isNumeric()
.isInt()
.isInt({ min: 0, max: 100 })
.isFloat()
.isFloat({ min: 0.0, max: 1.0 })
.isDecimal()
.isDivisibleBy(5)
.isPort()
.isLatLong()
```

### Boolean

```js
.isBoolean()
.isBoolean({ strict: true }) // only 'true' and 'false' strings, or actual booleans
```

### Date

```js
.isDate()
.isDate({ format: 'YYYY-MM-DD', strictMode: true, delimiters: ['-'] })
.isAfter('2020-01-01')
.isBefore('2099-12-31')
```

### Array/Object

```js
.isArray()
.isArray({ min: 1, max: 10 })
.isObject()
```

---

## Sanitizers

Sanitizers transform the field value in place. They run in chain order.

```js
.trim()
.trim('_')              // trims specific characters
.ltrim()
.rtrim()
.escape()               // HTML entity encoding: < > & " ' /
.unescape()
.stripLow()             // removes ASCII control characters
.whitelist('abc123')    // removes chars not in set
.blacklist('abc')       // removes chars in set
.normalizeEmail()
.normalizeEmail({ gmail_remove_dots: false })
.toInt()
.toInt(16)              // radix
.toFloat()
.toBoolean()
.toBoolean(true)        // strict: 'true' → true, '1' → true, everything else → false
.toDate()
.toLowerCase()
.toUpperCase()
```

Sanitizers modify `req.body`, `req.query`, etc. in place. The sanitized value is what `matchedData()` and subsequent code see.

---

## Custom Validators

### `.custom(fn)`

```js
body('username').custom(async (value, { req }) => {
  const user = await User.findOne({ username: value });
  if (user) {
    throw new Error('Username already taken');
  }
});
```

The function receives `(value, { req, location, path })`. Throw an error or return a rejected Promise to fail validation. Returning normally (including `undefined`) means the field passed.

### `.customSanitizer(fn)`

```js
body('tags').customSanitizer((value) => {
  return Array.isArray(value) ? value : [value];
});
```

The return value of the function becomes the new field value.

---

## Custom Error Messages

```js
body('email')
  .notEmpty().withMessage('Email is required')
  .isEmail().withMessage('Must be a valid email address');
```

`.withMessage()` applies to the immediately preceding validator.

Dynamic message with access to value and request:

```js
body('age')
  .isInt({ min: 18 })
  .withMessage((value, { req, path }) => `${value} is not a valid age for field ${path}`);
```

---

## `validationResult(req)`

Extracts collected errors from the request after all validators have run.

```js
const errors = validationResult(req);

errors.isEmpty()         // true if no errors
errors.array()           // [{ type, path, msg, value, location }, ...]
errors.mapped()          // { fieldName: firstError, ... }
errors.formatWith(fn)    // returns new result with custom format function applied
errors.throw()           // throws if any errors (use in try/catch)
```

### Error Object Shape

```js
{
  type: 'field',          // always 'field' for field errors
  path: 'email',          // dot-notation path
  location: 'body',       // 'body' | 'query' | 'params' | 'headers' | 'cookies'
  msg: 'Invalid value',
  value: 'not-an-email'
}
```

### Custom Formatter

```js
const result = validationResult(req).formatWith(({ msg, path, value }) => ({
  field: path,
  message: msg,
  received: value
}));

res.status(400).json({ errors: result.array() });
```

---

## `matchedData(req)`

Returns an object containing only the validated fields — those that were declared in a chain and passed validation.

```js
const data = matchedData(req);
// { email: 'user@example.com', username: 'luke' }
```

Options:

```js
matchedData(req, {
  includeOptionals: true,   // include optional fields even if absent
  onlyValidData: false,     // include fields even if they failed
  locations: ['body']       // restrict to specific sources
});
```

Useful as a safe extraction alternative to reading from `req.body` directly.

---

## Nested Fields

Use dot notation or bracket notation for nested objects and arrays.

```js
body('address.city').notEmpty()
body('address.zip').isPostalCode('PH')

body('contacts[0].email').isEmail()
body('contacts.*.email').isEmail()    // wildcard: all items in array
body('tags.*').isString()
```

Wildcards expand at validation time, matching all array indices present in the request.

---

## `checkSchema(schema)`

Defines all validation rules as a single schema object instead of separate chains. Useful for large or dynamic validation configs.

```js
const schema = {
  username: {
    in: ['body'],
    notEmpty: true,
    isLength: {
      options: { min: 3, max: 20 },
      errorMessage: 'Username must be 3–20 characters'
    },
    errorMessage: 'Username is required'
  },
  email: {
    in: ['body'],
    isEmail: {
      errorMessage: 'Invalid email'
    },
    normalizeEmail: true
  },
  age: {
    in: ['body'],
    optional: true,
    isInt: {
      options: { min: 0 },
      errorMessage: 'Age must be a non-negative integer'
    },
    toInt: true
  }
};

app.post('/register', checkSchema(schema), (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
  res.send('ok');
});
```

Each key is a field name. Each value is a config object where keys correspond to validator/sanitizer names. The `in` key specifies one or more request locations.

---

## Conditional Validation

### `.if(condition)`

Runs the rest of the chain only if the condition is met.

```js
body('paymentMethod').notEmpty(),

body('cardNumber')
  .if(body('paymentMethod').equals('card'))
  .notEmpty()
  .isCreditCard(),

body('bankAccount')
  .if(body('paymentMethod').equals('bank'))
  .notEmpty()
  .isIBAN()
```

The condition can be another ValidationChain or a custom function:

```js
body('promoCode')
  .if((value, { req }) => req.body.hasMembership === true)
  .notEmpty()
```

---

## `oneOf(chainGroups)`

Passes if at least one group of validators passes. Fails if all groups fail.

```js
const { oneOf } = require('express-validator');

app.post('/login',
  oneOf([
    [body('email').isEmail(), body('password').notEmpty()],
    [body('token').isJWT()]
  ]),
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
    res.send('ok');
  }
);
```

Error shape for `oneOf` failures uses `type: 'alternative'` and nests the individual group errors under `nestedErrors`.

---

## Reusable Validation Chains

Since chains are just arrays of middleware, they can be extracted and reused:

```js
const validateEmail = [
  body('email')
    .notEmpty().withMessage('Email required')
    .isEmail().withMessage('Invalid email format')
    .normalizeEmail()
];

const validatePassword = [
  body('password')
    .isLength({ min: 8 }).withMessage('Minimum 8 characters')
    .isStrongPassword().withMessage('Password is not strong enough')
];

app.post('/register', [...validateEmail, ...validatePassword], handler);
app.post('/reset', [...validateEmail], handler);
```

---

## Error Handling Middleware Pattern

A common pattern is a shared middleware that checks errors and terminates early:

```js
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json({ errors: errors.array() });
  }
  next();
};

app.post('/user',
  body('name').notEmpty(),
  body('email').isEmail(),
  validate,
  async (req, res) => {
    const data = matchedData(req);
    // safe to use data here
  }
);
```

---

## `.bail()`

Stops running validators in the chain after the first failure. Without `.bail()`, all validators in a chain run regardless of prior failures.

```js
body('email')
  .notEmpty().bail()       // stops here if empty; won't run isEmail on empty string
  .isEmail().bail()
  .custom(checkEmailExists)
```

`.bail({ level: 'request' })` stops all chains on the request, not just the current field's chain. This is useful when one field's validity determines whether others make sense to check.

---

## Running Validators Imperatively

Chains can be run manually outside of Express middleware, useful for testing or programmatic use:

```js
const { body, validationResult } = require('express-validator');

const req = {
  body: { email: 'not-an-email' }
};

const chain = body('email').isEmail();
await chain.run(req);

const result = validationResult(req);
console.log(result.array());
// [{ type: 'field', path: 'email', msg: 'Invalid value', ... }]
```

---

## File Upload Validation

express-validator does not parse `multipart/form-data` directly. Use a middleware like `multer` first, then validate fields:

```js
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

app.post('/upload',
  upload.single('file'),
  body('description').notEmpty(),
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
    // req.file holds the uploaded file metadata
    res.send('ok');
  }
);
```

File validation (type, size) must be handled in multer's `fileFilter` option or in a custom validator reading from `req.file`.

---

## TypeScript Usage

express-validator ships its own type declarations. No `@types` package needed.

```ts
import { body, ValidationChain, validationResult } from 'express-validator';
import { Request, Response, NextFunction } from 'express';

const validateUser: ValidationChain[] = [
  body('email').isEmail(),
  body('age').isInt({ min: 0 }).toInt()
];

const handleValidation = (req: Request, res: Response, next: NextFunction): void => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    res.status(400).json({ errors: errors.array() });
    return;
  }
  next();
};
```

---

## Common Patterns and Notes

**Order of chain methods matters.** Sanitizers run in the order declared. A sanitizer placed before a validator operates on the transformed value; placed after, the validator sees the original.

```js
// toInt runs first; isInt sees an integer
body('age').toInt().isInt({ min: 0 })

// isEmail sees the raw input; normalizeEmail transforms after
body('email').isEmail().normalizeEmail()
```

**`req.body` must be parsed.** express-validator reads from `req.body`, so `express.json()` or `express.urlencoded()` must be applied before validation middleware runs.

```js
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
```

**Validation does not mutate `req.body` unless sanitizers are used.** Validators only check; they do not change values. Sanitizers do change values in place.

**`validationResult` only captures errors from chains that have already run.** If a chain is not included as middleware on the route, its errors will not appear.

**Array of chains must be spread or used with route's variadic middleware signature.**

```js
// Correct
app.post('/route', ...validators, handler);

// Also correct
app.post('/route', validators, handler); // Express flattens arrays automatically in v4+
```

---

## Version Notes

express-validator v7 introduced `checkSchema` improvements, `oneOf` error nesting changes, and stricter TypeScript types. The `.bail({ level: 'request' })` option was added in v6.14. Behavior differences between major versions are not always backward-compatible — consult the changelog when upgrading.